import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const namePlaceholder = ['name', 'placeholder'].join('_');
const descriptionPlaceholder = ['description', 'placeholder'].join('_');
const npmWorkspacePlaceholder = ['name', 'placeholder', 'workspace'].join('-');

const templateMarkers = [namePlaceholder, descriptionPlaceholder, npmWorkspacePlaceholder] as const;

export function scanTemplateMarkers(repositoryRoot: string): string {
  const patternArguments = templateMarkers.flatMap((marker) => ['-e', marker]);
  const result = spawnSync(
    'git',
    ['grep', '-n', '--no-color', '-F', ...patternArguments, '--', '.'],
    {
      cwd: repositoryRoot,
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
    return '';
  }

  if (result.status !== 0) {
    const detail = result.stderr.trim() || `git exited with status ${String(result.status)}`;
    throw new Error(`Failed to scan template markers: ${detail}`);
  }

  return result.stdout;
}

function main(): void {
  const repositoryRoot = fileURLToPath(new URL('..', import.meta.url));
  process.stdout.write(scanTemplateMarkers(repositoryRoot));
}

if (import.meta.main) {
  try {
    main();
  } catch (error: unknown) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}
