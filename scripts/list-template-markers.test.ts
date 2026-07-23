import { execFileSync } from 'node:child_process';
import { strictEqual, throws } from 'node:assert/strict';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';

import { scanTemplateMarkers } from './list-template-markers.ts';

await test('the marker scan reports tracked files but not untracked files', async (context) => {
  const repositoryRoot = await mkdtemp(join(tmpdir(), 'vibe-mono-template-markers-'));
  context.after(() => rm(repositoryRoot, { recursive: true, force: true }));

  const markers = [
    ['name', 'placeholder'].join('_'),
    ['description', 'placeholder'].join('_'),
    ['name', 'placeholder', 'workspace'].join('-'),
  ];
  await writeFile(
    join(repositoryRoot, 'identity.txt'),
    markers.map((marker) => `found ${marker}\n`).join(''),
  );
  await writeFile(join(repositoryRoot, '.env'), `ignored ${markers[0]}\n`);
  execFileSync('git', ['init', '--quiet'], { cwd: repositoryRoot });
  execFileSync('git', ['add', 'identity.txt'], { cwd: repositoryRoot });

  strictEqual(
    scanTemplateMarkers(repositoryRoot),
    markers.map((marker, index) => `identity.txt:${String(index + 1)}:found ${marker}\n`).join(''),
  );

  await writeFile(join(repositoryRoot, 'identity.txt'), 'adopted repository\n');
  strictEqual(scanTemplateMarkers(repositoryRoot), '');
});

await test('the marker scan reports Git failures', async (context) => {
  const repositoryRoot = await mkdtemp(join(tmpdir(), 'vibe-mono-template-markers-error-'));
  context.after(() => rm(repositoryRoot, { recursive: true, force: true }));

  throws(() => scanTemplateMarkers(repositoryRoot), /Failed to scan template markers/);
});
