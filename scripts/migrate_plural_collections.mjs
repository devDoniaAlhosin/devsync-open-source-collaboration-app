/**
 * Migrate singular Firestore collections to plural:
 *   match → matches, feedback → feedbacks
 * Then delete leftover singular docs (and any stale dual-writes already in matches
 * that came from the old legacy mirror — kept if already under matches).
 *
 * Usage:
 *   set GOOGLE_APPLICATION_CREDENTIALS=path\to\credentials.json
 *   node scripts/migrate_plural_collections.mjs [--project-id devsync-36ef3]
 *
 * Requires: npm i firebase-admin
 */

import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

function parseArgs(argv) {
  const out = { projectId: 'devsync-36ef3' };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--project-id' && argv[i + 1]) out.projectId = argv[++i];
  }
  return out;
}

async function copyCollection(db, fromName, toName) {
  const from = db.collection(fromName);
  const snapshot = await from.get();
  console.log(`Copy ${fromName} → ${toName}: ${snapshot.size} doc(s)`);
  let n = 0;
  for (const doc of snapshot.docs) {
    await db.collection(toName).doc(doc.id).set(doc.data(), { merge: true });
    n++;
  }
  return n;
}

async function deleteCollection(db, name) {
  const snapshot = await db.collection(name).get();
  console.log(`Delete ${name}: ${snapshot.size} doc(s)`);
  let n = 0;
  for (const doc of snapshot.docs) {
    await doc.ref.delete();
    n++;
  }
  return n;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error(
      'Set GOOGLE_APPLICATION_CREDENTIALS to your Firebase credentials JSON path.',
    );
    process.exit(1);
  }

  const { initializeApp, getApps, applicationDefault } = require(
    'firebase-admin/app',
  );
  const { getFirestore } = require('firebase-admin/firestore');

  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId: args.projectId,
    });
  }

  const db = getFirestore();

  await copyCollection(db, 'match', 'matches');
  await copyCollection(db, 'feedback', 'feedbacks');

  await deleteCollection(db, 'match');
  await deleteCollection(db, 'feedback');

  console.log('\nDone. Collections in use: matches, feedbacks.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
