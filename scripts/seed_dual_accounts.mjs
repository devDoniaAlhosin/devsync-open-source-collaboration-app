/**
 * Seed two real Auth UIDs for a full maintainer ↔ contributor E2E flow,
 * including enough like/skip feedback for Insights + Prompt quality charts.
 *
 * Usage:
 *   set GOOGLE_APPLICATION_CREDENTIALS=path\to\serviceAccount.json
 *   node scripts/seed_dual_accounts.mjs --maintainer <UID> --contributor <UID> \
 *     [--maintainer-name "Name"] [--contributor-name "Name"] \
 *     [--maintainer-email a@b.com] [--contributor-email c@d.com] \
 *     [--project-id devsync-36ef3]
 *
 * Email / photo / providers are read from Firebase Auth when present.
 * Requires: npm i firebase-admin  (from repo root or scripts/)
 * Never commit the service account JSON.
 */

import { createRequire } from 'node:module';
import { randomUUID } from 'node:crypto';

const require = createRequire(import.meta.url);

function parseArgs(argv) {
  const out = {
    projectId: 'devsync-36ef3',
    maintainerName: null,
    contributorName: null,
    maintainerEmail: null,
    contributorEmail: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = argv[i + 1];
    if (a === '--maintainer' && next) out.maintainer = next;
    else if (a === '--contributor' && next) out.contributor = next;
    else if (a === '--maintainer-name' && next) out.maintainerName = next;
    else if (a === '--contributor-name' && next) out.contributorName = next;
    else if (a === '--maintainer-email' && next) out.maintainerEmail = next;
    else if (a === '--contributor-email' && next) out.contributorEmail = next;
    else if (a === '--project-id' && next) out.projectId = next;
  }
  return out;
}

function mulberry32(seed) {
  let t = seed >>> 0;
  return () => {
    t += 0x6d2b79f5;
    let r = Math.imul(t ^ (t >>> 15), 1 | t);
    r ^= r + Math.imul(r ^ (r >>> 7), 61 | r);
    return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
  };
}

function buildActivity(seed) {
  const rnd = mulberry32(seed);
  const weeks = 20;
  const days = 7;
  const flat = [];
  for (let w = 0; w < weeks; w++) {
    for (let d = 0; d < days; d++) {
      const r = rnd();
      if (r < 0.45) flat.push(0);
      else if (r < 0.65) flat.push(1);
      else if (r < 0.82) flat.push(2);
      else if (r < 0.93) flat.push(3);
      else flat.push(4);
    }
  }
  return flat;
}

function githubHandleFrom(name, uid) {
  const base = name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 18);
  return base || `dev-${uid.slice(0, 6)}`;
}

async function loadAuthUser(getAuth, uid) {
  try {
    return await getAuth().getUser(uid);
  } catch (err) {
    console.error(`Could not load Auth user ${uid}: ${err.message}`);
    process.exit(1);
  }
}

function buildUserDoc({
  uid,
  authUser,
  nameOverride,
  emailOverride,
  role,
  extraSkills,
  FieldValue,
}) {
  const authName = (authUser.displayName || '').trim();
  const emailLocal = (authUser.email || '').split('@')[0]?.trim() || '';
  const name =
    (nameOverride || '').trim() ||
    authName ||
    emailLocal ||
    (role === 'maintainer' ? 'Maintainer' : 'Contributor');

  const email =
    (emailOverride || '').trim() ||
    (authUser.email || '').trim() ||
    null;

  const photoUrl = authUser.photoURL || null;
  const authProviders = [
    ...new Set((authUser.providerData || []).map((p) => p.providerId)),
  ].sort();

  const githubLogin = githubHandleFrom(name, uid);
  const skills =
    role === 'maintainer'
      ? ['Flutter', 'Dart', 'Firebase', 'Backend', ...extraSkills]
      : ['Flutter', 'Dart', 'Firebase', 'UI', ...extraSkills];

  const languages =
    role === 'maintainer'
      ? [
          { name: 'Dart', percent: 68, colorArgb: 0xff2ee0c8 },
          { name: 'Kotlin', percent: 18, colorArgb: 0xff8fbfb4 },
          { name: 'JS', percent: 14, colorArgb: 0xff3e5a57 },
        ]
      : [
          { name: 'Dart', percent: 72, colorArgb: 0xff2ee0c8 },
          { name: 'Python', percent: 18, colorArgb: 0xff8fbfb4 },
          { name: 'JS', percent: 10, colorArgb: 0xff3e5a57 },
        ];

  const repos = role === 'maintainer' ? 24 : 16;
  const commits = role === 'maintainer' ? 1280 : 860;
  const topRepositories = [
    `https://github.com/${githubLogin}/devsync-notes`,
    `https://github.com/${githubLogin}/pulse-tracker`,
    `https://github.com/${githubLogin}/flutter-kit`,
    `https://github.com/${githubLogin}/auth-sandbox`,
  ];

  const bio =
    role === 'maintainer'
      ? 'Open-source maintainer. Shipping Flutter apps and mentoring contributors.'
      : 'Flutter contributor. Looking for projects that need UI and Firebase help.';

  const profile = {
    name,
    bio,
    githubUrl: `github.com/${githubLogin}`,
    repos,
    commits,
    languageCount: languages.length,
    languages,
    activity: buildActivity(role === 'maintainer' ? 11 : 29),
    skills,
    suggestedSkills: role === 'maintainer' ? ['CI', 'Docs'] : ['Animation'],
    topRepositories,
  };

  return {
    resolvedName: name,
    resolvedEmail: email,
    doc: {
      uid,
      email,
      displayName: name,
      photoUrl,
      authProviders: authProviders.length > 0 ? authProviders : ['password'],
      githubLogin,
      githubUrl: `github.com/${githubLogin}`,
      declaredSkills: skills,
      skills,
      publicRepoCount: repos,
      totalContributions: commits,
      topRepositories,
      bio,
      profile,
      updatedAt: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    },
  };
}

function initials(name) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '??';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

function shortId() {
  return randomUUID().replace(/-/g, '').slice(0, 12);
}

function daysAgoTimestamp(Timestamp, days) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - days);
  d.setUTCHours(14, 0, 0, 0);
  return Timestamp.fromDate(d);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.maintainer || !args.contributor) {
    console.error(
      'Missing UIDs. Example:\n' +
        '  node scripts/seed_dual_accounts.mjs --maintainer UID_M --contributor UID_C',
    );
    process.exit(1);
  }
  if (args.maintainer === args.contributor) {
    console.error('Maintainer and contributor UIDs must be different.');
    process.exit(1);
  }
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error(
      'Set GOOGLE_APPLICATION_CREDENTIALS to your Firebase service account JSON path.',
    );
    process.exit(1);
  }

  let initializeApp;
  let getApps;
  let applicationDefault;
  let getFirestore;
  let FieldValue;
  let Timestamp;
  let getAuth;
  try {
    ({ initializeApp, getApps, applicationDefault } = require('firebase-admin/app'));
    ({ getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore'));
    ({ getAuth } = require('firebase-admin/auth'));
  } catch {
    console.error('Install firebase-admin first: npm i firebase-admin');
    process.exit(1);
  }

  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId: args.projectId,
    });
  }

  const db = getFirestore();
  const now = FieldValue.serverTimestamp();

  const m = args.maintainer.trim();
  const c = args.contributor.trim();

  console.log('Loading Auth users (email, photo, providers)…');
  const mAuth = await loadAuthUser(getAuth, m);
  const cAuth = await loadAuthUser(getAuth, c);

  const maintainer = buildUserDoc({
    uid: m,
    authUser: mAuth,
    nameOverride: args.maintainerName,
    emailOverride: args.maintainerEmail,
    role: 'maintainer',
    extraSkills: [],
    FieldValue,
  });
  const contributor = buildUserDoc({
    uid: c,
    authUser: cAuth,
    nameOverride: args.contributorName,
    emailOverride: args.contributorEmail,
    role: 'contributor',
    extraSkills: [],
    FieldValue,
  });

  const mName = maintainer.resolvedName;
  const cName = contributor.resolvedName;
  const sharedSkills = ['Flutter', 'Dart', 'Firebase'];
  const batchKey = shortId();

  console.log('Seeding full user profiles…');
  console.log(
    `  Maintainer : ${mName} <${maintainer.resolvedEmail || 'no-email'}>`,
  );
  console.log(
    `  Contributor: ${cName} <${contributor.resolvedEmail || 'no-email'}>`,
  );

  async function upsertUser(uid, payload) {
    const ref = db.collection('users').doc(uid);
    const existing = await ref.get();
    const doc = { ...payload };
    if (existing.exists) delete doc.createdAt;
    await ref.set(doc, { merge: true });
  }

  await upsertUser(m, maintainer.doc);
  await upsertUser(c, contributor.doc);

  // Join-request project (maintainer inbox) + catalog projects for feedback/analytics.
  const joinProjectId = `seed_join_${batchKey}`;
  const catalog = [
    {
      id: `seed_cat_${shortId()}`,
      title: 'Open Canvas Notes',
      description: 'Collaborative notes app with offline sync.',
      techStack: ['Flutter', 'Dart', 'Firebase'],
      githubUrl: 'https://github.com/flutter/packages',
      action: 'like',
      daysAgo: 6,
      promptVersion: 'v1',
      score: 88,
    },
    {
      id: `seed_cat_${shortId()}`,
      title: 'Pulse Tracker',
      description: 'Habit tracker with lightweight charts.',
      techStack: ['Flutter', 'Dart'],
      githubUrl: 'https://github.com/flutter/samples',
      action: 'like',
      daysAgo: 5,
      promptVersion: 'v1',
      score: 76,
    },
    {
      id: `seed_cat_${shortId()}`,
      title: 'Route Kit CLI',
      description: 'CLI helpers for Flutter routing experiments.',
      techStack: ['Dart', 'Firebase'],
      githubUrl: 'https://github.com/dart-lang/sdk',
      action: 'skip',
      daysAgo: 4,
      promptVersion: 'v1',
      score: 41,
    },
    {
      id: `seed_cat_${shortId()}`,
      title: 'Team Board Lite',
      description: 'Kanban-style board for small open-source teams.',
      techStack: ['Flutter', 'Firebase'],
      githubUrl: 'https://github.com/flutter/flutter',
      action: 'like',
      daysAgo: 3,
      promptVersion: 'v2',
      score: 91,
    },
    {
      id: `seed_cat_${shortId()}`,
      title: 'Auth Sandbox',
      description: 'Reference patterns for email and OAuth flows.',
      techStack: ['Flutter', 'Dart', 'Firebase'],
      githubUrl: 'https://github.com/firebase/flutterfire',
      action: 'skip',
      daysAgo: 2,
      promptVersion: 'v2',
      score: 38,
    },
    {
      id: `seed_cat_${shortId()}`,
      title: 'Match Lab UI',
      description: 'Card deck UI kit used for matching experiments.',
      techStack: ['Flutter', 'Dart', 'UI'],
      githubUrl: 'https://github.com/flutter/gallery',
      action: 'like',
      daysAgo: 1,
      promptVersion: 'v2',
      score: 84,
    },
  ];

  const joinProject = {
    ownerId: m,
    ownerName: mName,
    title: 'DevSync Seed Project',
    description:
      'Open-source project for maintainer/contributor E2E demos. Safe to delete.',
    githubUrl: 'https://github.com/flutter/flutter',
    githubRepo: 'flutter/flutter',
    techStack: sharedSkills,
    requiredContributors: 2,
    viewsCount: 0,
    requestsCount: 1,
    createdAt: now,
    updatedAt: now,
  };

  console.log(`Seeding join project ${joinProjectId}…`);
  await db.collection('projects').doc(joinProjectId).set(joinProject);

  for (const item of catalog) {
    console.log(`Seeding catalog project ${item.id}…`);
    await db
      .collection('projects')
      .doc(item.id)
      .set({
        ownerId: m,
        ownerName: mName,
        title: item.title,
        description: item.description,
        githubUrl: item.githubUrl,
        githubRepo: item.githubUrl.replace('https://github.com/', ''),
        techStack: item.techStack,
        requiredContributors: 2,
        viewsCount: 0,
        requestsCount: 0,
        createdAt: now,
        updatedAt: now,
      });
  }

  const requestId = `${c}_${joinProjectId}`;
  const request = {
    projectId: joinProjectId,
    senderId: c,
    ownerId: m,
    initials: initials(cName),
    title: joinProject.title,
    subtitle: 'Pending',
    status: 'pending',
    type: 'sent',
    message: 'Hi — I would like to contribute to this project.',
    displayName: cName,
    targetName: joinProject.title,
    matchPercent: 82,
    matchSummary: 'Strong overlap on Flutter / Dart / Firebase.',
    repositoryCount: 0,
    commitCount: 0,
    languageCount: 0,
    skills: sharedSkills,
    createdAt: now,
    respondedAt: null,
  };

  console.log(`Seeding pending request ${requestId}…`);
  await db.collection('requests').doc(requestId).set(request);

  console.log('Seeding contributor likes / skips for Insights + Prompt guide…');
  for (const item of catalog) {
    const docId = `${c}_${item.id}`;
    const stamped = daysAgoTimestamp(Timestamp, item.daysAgo);

    await db.collection('feedbacks').doc(docId).set({
      userId: c,
      projectId: item.id,
      action: item.action,
      promptVersion: item.promptVersion,
      updatedAt: stamped,
      createdAt: stamped,
      timestamp: stamped,
    });

    if (item.action === 'like') {
      await db.collection('matches').doc(docId).set({
        matchId: docId,
        userId: c,
        projectId: item.id,
        score: item.score,
        reason: `Overlap on ${item.techStack.join(' / ')}.`,
        promptVersion: item.promptVersion,
        projectName: item.title,
        description: item.description,
        githubUrl: item.githubUrl,
        neededSkills: item.techStack,
        maintainerId: m,
        createdAt: stamped,
      });
    }
  }

  const likes = catalog.filter((p) => p.action === 'like').length;
  const skips = catalog.filter((p) => p.action === 'skip').length;

  console.log('\nDone.');
  console.log(`  Maintainer : ${m} (${mName}) ${maintainer.resolvedEmail || ''}`);
  console.log(`  Contributor: ${c} (${cName}) ${contributor.resolvedEmail || ''}`);
  console.log(`  Join project / request: projects/${joinProjectId}`);
  console.log(`  Catalog projects      : ${catalog.length}`);
  console.log(`  Feedback               : ${likes} likes, ${skips} skips (multi-day, v1+v2)`);
  console.log('\nProfiles include email, bio, GitHub, languages, activity, skills.');
  console.log('Sign in as contributor → Profile + Insights / Prompt guide.');
  console.log('Sign in as maintainer → Requests → Accept/Decline the pending join request.');
  console.log('Done seeding. Check Requests / Liked matches / Insights on device.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
