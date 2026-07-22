import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

export interface TemplateMarkerMatch {
  readonly path: string;
  readonly line: number;
  readonly text: string;
}

export interface TemplateMarkerScanOptions {
  readonly repositoryRoot: string;
  readonly markers: readonly string[];
  readonly roots: readonly string[];
}

const namePlaceholder = ['name', 'placeholder'].join('_');
const descriptionPlaceholder = ['description', 'placeholder'].join('_');
const npmWorkspacePlaceholder = ['name', 'placeholder', 'workspace'].join('-');

export const templateMarkers = [
  namePlaceholder,
  descriptionPlaceholder,
  `hack-ink/${namePlaceholder}`,
  `Welcome to use ${namePlaceholder}`,
  npmWorkspacePlaceholder,
] as const;

export const templateRoots = [
  'README.md',
  'Cargo.toml',
  'Cargo.lock',
  'package.json',
  'package-lock.json',
  'apps',
  'scripts',
  '.github',
  'openwiki',
] as const;

function parseGitGrepOutput(output: string): readonly TemplateMarkerMatch[] {
  const matches: TemplateMarkerMatch[] = [];
  let cursor = 0;

  while (cursor < output.length) {
    const pathEnd = output.indexOf('\0', cursor);
    const lineEnd = output.indexOf('\0', pathEnd + 1);
    const textEnd = output.indexOf('\n', lineEnd + 1);

    if (pathEnd === -1 || lineEnd === -1) {
      throw new Error('git grep returned malformed output.');
    }

    const recordEnd = textEnd === -1 ? output.length : textEnd;
    const line = Number.parseInt(output.slice(pathEnd + 1, lineEnd), 10);

    if (!Number.isSafeInteger(line) || line < 1) {
      throw new Error('git grep returned an invalid line number.');
    }

    matches.push({
      path: output.slice(cursor, pathEnd),
      line,
      text: output.slice(lineEnd + 1, recordEnd),
    });
    cursor = recordEnd + 1;
  }

  return matches.toSorted((left, right) => {
    if (left.path !== right.path) {
      return left.path < right.path ? -1 : 1;
    }

    return left.line - right.line;
  });
}

export function scanTemplateMarkers(
  options: TemplateMarkerScanOptions,
): readonly TemplateMarkerMatch[] {
  const patternArguments = options.markers.flatMap((marker) => ['-e', marker]);
  const result = spawnSync(
    'git',
    [
      'grep',
      '--null',
      '--line-number',
      '--no-color',
      '--fixed-strings',
      ...patternArguments,
      '--',
      ...options.roots,
    ],
    {
      cwd: options.repositoryRoot,
      encoding: 'utf8',
      shell: false,
    },
  );

  if (result.error !== undefined) {
    throw new Error('Failed to start git while scanning template markers.', {
      cause: result.error,
    });
  }

  if (result.status === 1) {
    return [];
  }

  if (result.status !== 0) {
    const detail = result.stderr.trim() || `git exited with status ${String(result.status)}`;
    throw new Error(`Failed to scan template markers: ${detail}`);
  }

  return parseGitGrepOutput(result.stdout);
}

function main(): void {
  const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
  const matches = scanTemplateMarkers({
    repositoryRoot,
    markers: templateMarkers,
    roots: templateRoots,
  });

  for (const match of matches) {
    console.log(`${match.path}:${String(match.line)}:${match.text}`);
  }
}

if (import.meta.main) {
  try {
    main();
  } catch (error: unknown) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}
