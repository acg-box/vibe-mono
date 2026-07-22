import { execFileSync } from 'node:child_process';
import { deepStrictEqual, equal, throws } from 'node:assert/strict';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';

import { scanTemplateMarkers, templateMarkers, templateRoots } from './list-template-markers.ts';

await test('the marker scan reads tracked files and reports a clean repository', async (context) => {
  const repositoryRoot = await mkdtemp(join(tmpdir(), 'vibe-mono-template-markers-'));
  context.after(() => rm(repositoryRoot, { recursive: true, force: true }));

  const marker = ['name', 'placeholder'].join('_');
  const lockMarker = ['name', 'placeholder', 'workspace'].join('-');
  await writeFile(join(repositoryRoot, 'README.md'), `found ${marker}\n`);
  await writeFile(join(repositoryRoot, 'package-lock.json'), `locked ${lockMarker}\n`);
  await writeFile(join(repositoryRoot, '.env'), `ignored ${marker}\n`);
  execFileSync('git', ['init', '--quiet'], { cwd: repositoryRoot });
  execFileSync('git', ['add', 'README.md', 'package-lock.json'], { cwd: repositoryRoot });

  const matches = scanTemplateMarkers({
    repositoryRoot,
    markers: templateMarkers,
    roots: templateRoots,
  });

  equal(matches.length, 2);
  deepStrictEqual(matches, [
    {
      path: 'README.md',
      line: 1,
      text: `found ${marker}`,
    },
    {
      path: 'package-lock.json',
      line: 1,
      text: `locked ${lockMarker}`,
    },
  ]);

  await writeFile(join(repositoryRoot, 'README.md'), 'adopted repository\n');
  await writeFile(join(repositoryRoot, 'package-lock.json'), 'adopted repository\n');
  deepStrictEqual(
    scanTemplateMarkers({
      repositoryRoot,
      markers: templateMarkers,
      roots: templateRoots,
    }),
    [],
  );
});

await test('the marker scan reports Git failures', async (context) => {
  const repositoryRoot = await mkdtemp(join(tmpdir(), 'vibe-mono-template-markers-error-'));
  context.after(() => rm(repositoryRoot, { recursive: true, force: true }));

  throws(
    () =>
      scanTemplateMarkers({
        repositoryRoot,
        markers: [['name', 'placeholder'].join('_')],
        roots: ['.'],
      }),
    /Failed to scan template markers/,
  );
});
