/**
 * Seed projects with diverse tech stacks for AI matching tests.
 *
 * Usage (Firebase CLI already logged in):
 *   node scripts/seed_diverse_match_projects.mjs --owner <UID>
 *
 * Or with a service account:
 *   set GOOGLE_APPLICATION_CREDENTIALS=path\to\serviceAccount.json
 *   node scripts/seed_diverse_match_projects.mjs --owner <UID>
 *
 * Sign in as a *different* account to generate matches — owned projects are excluded.
 */

import { createRequire } from 'node:module';
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';

const require = createRequire(import.meta.url);

function parseArgs(argv) {
  const out = {
    projectId: 'devsync-36ef3',
    owner: null,
    ownerName: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = argv[i + 1];
    if (a === '--owner' && next) out.owner = next;
    else if (a === '--owner-name' && next) out.ownerName = next;
    else if (a === '--project-id' && next) out.projectId = next;
  }
  return out;
}

function shortId() {
  return randomUUID().replace(/-/g, '').slice(0, 10);
}

function firebaseToolsTokensPath() {
  return join(homedir(), '.config', 'configstore', 'firebase-tools.json');
}

async function accessTokenFromFirebaseCli() {
  const path = firebaseToolsTokensPath();
  if (!existsSync(path)) return null;
  const raw = JSON.parse(readFileSync(path, 'utf8'));
  const tokens = raw?.tokens;
  if (!tokens) return null;

  const expiresAt = Number(tokens.expires_at || 0);
  if (tokens.access_token && expiresAt > Date.now() + 60_000) {
    return tokens.access_token;
  }

  const refreshToken = tokens.refresh_token;
  if (!refreshToken) return null;

  const body = new URLSearchParams({
    client_id:
      '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
    client_secret: 'j9iVZfS8kkCEFUPaAeJV0sAi',
    refresh_token: refreshToken,
    grant_type: 'refresh_token',
  });
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OAuth refresh failed (${res.status}): ${text}`);
  }
  const json = await res.json();
  return json.access_token;
}

function stringValue(v) {
  return { stringValue: v };
}

function integerValue(v) {
  return { integerValue: String(v) };
}

function arrayValue(strings) {
  return {
    arrayValue: {
      values: strings.map((s) => stringValue(s)),
    },
  };
}

const CATALOG = [
  {
    title: 'Flutter Pulse Board',
    description:
      'Mobile kanban for open-source teams. Needs Flutter UI and Firebase sync.',
    techStack: ['Flutter', 'Dart', 'Firebase'],
    githubUrl: 'https://github.com/flutter/gallery',
  },
  {
    title: 'React Collab Hub',
    description:
      'Web dashboard for contributor onboarding. React + TypeScript frontend.',
    techStack: ['React', 'TypeScript', 'Node.js'],
    githubUrl: 'https://github.com/facebook/react',
  },
  {
    title: 'Python Skill Graph',
    description:
      'ML pipeline that clusters developer skills from public GitHub activity.',
    techStack: ['Python', 'Machine Learning', 'Pandas'],
    githubUrl: 'https://github.com/scikit-learn/scikit-learn',
  },
  {
    title: 'Go Match API',
    description:
      'High-throughput ranking service. Go microservices and Postgres.',
    techStack: ['Go', 'PostgreSQL', 'Docker'],
    githubUrl: 'https://github.com/golang/go',
  },
  {
    title: 'Rust CLI Toolkit',
    description:
      'Fast local tooling for repo health checks. Rust systems programming.',
    techStack: ['Rust', 'CLI', 'Systems'],
    githubUrl: 'https://github.com/rust-lang/rust',
  },
  {
    title: 'Kotlin Android Notes',
    description:
      'Offline-first notes app. Kotlin, Jetpack Compose, Room.',
    techStack: ['Kotlin', 'Android', 'Jetpack Compose'],
    githubUrl: 'https://github.com/android/compose-samples',
  },
  {
    title: 'SwiftUI Team Timer',
    description: 'iOS focus timer for remote teams. SwiftUI and Combine.',
    techStack: ['Swift', 'SwiftUI', 'iOS'],
    githubUrl: 'https://github.com/apple/swift',
  },
  {
    title: 'DevOps Deploy Rails',
    description:
      'CI/CD templates and infra-as-code for small OSS projects.',
    techStack: ['DevOps', 'Kubernetes', 'Terraform'],
    githubUrl: 'https://github.com/kubernetes/kubernetes',
  },
];

async function writeProjectRest({
  accessToken,
  projectId,
  docId,
  fields,
}) {
  const url =
    `https://firestore.googleapis.com/v1/projects/${projectId}` +
    `/databases/(default)/documents/projects?documentId=${encodeURIComponent(docId)}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Firestore write failed for ${docId} (${res.status}): ${text}`);
  }
}

async function seedWithAdminSdk(args, ownerId, ownerName) {
  const { initializeApp, getApps, applicationDefault } = require(
    'firebase-admin/app',
  );
  const { getFirestore, FieldValue } = require('firebase-admin/firestore');
  const { getAuth } = require('firebase-admin/auth');

  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId: args.projectId,
    });
  }

  let resolvedName = ownerName;
  try {
    const authUser = await getAuth().getUser(ownerId);
    resolvedName =
      ownerName ||
      (authUser.displayName || '').trim() ||
      (authUser.email || '').split('@')[0] ||
      'Maintainer';
  } catch {
    resolvedName = ownerName || 'Maintainer';
  }

  const db = getFirestore();
  const now = FieldValue.serverTimestamp();
  const batchKey = shortId();

  console.log(`Owner: ${resolvedName} (${ownerId})`);
  for (const item of CATALOG) {
    const id = `seed_ai_${batchKey}_${shortId()}`;
    await db.collection('projects').doc(id).set({
      ownerId,
      ownerName: resolvedName,
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
    console.log(`  + ${item.title}  [${item.techStack.join(', ')}]`);
  }
  return CATALOG.length;
}

async function seedWithRest(args, ownerId, ownerName, accessToken) {
  const resolvedName = ownerName || 'Maintainer';
  const batchKey = shortId();
  const nowIso = new Date().toISOString();

  console.log(`Owner: ${resolvedName} (${ownerId})`);
  console.log('Using Firebase CLI credentials via Firestore REST…');

  for (const item of CATALOG) {
    const id = `seed_ai_${batchKey}_${shortId()}`;
    const githubRepo = item.githubUrl.replace('https://github.com/', '');
    await writeProjectRest({
      accessToken,
      projectId: args.projectId,
      docId: id,
      fields: {
        ownerId: stringValue(ownerId),
        ownerName: stringValue(resolvedName),
        title: stringValue(item.title),
        description: stringValue(item.description),
        githubUrl: stringValue(item.githubUrl),
        githubRepo: stringValue(githubRepo),
        techStack: arrayValue(item.techStack),
        requiredContributors: integerValue(2),
        viewsCount: integerValue(0),
        requestsCount: integerValue(0),
        createdAt: { timestampValue: nowIso },
        updatedAt: { timestampValue: nowIso },
      },
    });
    console.log(`  + ${item.title}  [${item.techStack.join(', ')}]`);
  }
  return CATALOG.length;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.owner) {
    console.error(
      'Missing --owner UID.\n' +
        '  node scripts/seed_diverse_match_projects.mjs --owner axCJt3al4CZVWVxsAtcIxDO0SCu1',
    );
    process.exit(1);
  }

  const ownerId = args.owner.trim();
  const ownerName = (args.ownerName || '').trim() || null;
  let count;

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    count = await seedWithAdminSdk(args, ownerId, ownerName);
  } else {
    const token = await accessTokenFromFirebaseCli();
    if (!token) {
      console.error(
        'No credentials. Set GOOGLE_APPLICATION_CREDENTIALS or run: firebase login',
      );
      process.exit(1);
    }
    count = await seedWithRest(args, ownerId, ownerName, token);
  }

  console.log(`\nSeeded ${count} projects under ${ownerId}`);
  console.log('How to test AI matching:');
  console.log('  1. Sign in as a DIFFERENT user (not this owner).');
  console.log(
    '  2. Set profile skills that overlap some stacks (e.g. Flutter + Python).',
  );
  console.log('  3. Open Matches → generate / refresh.');
  console.log(
    '  4. Expect higher scores for overlapping stacks; low/no fit for Rust/iOS/etc.',
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
