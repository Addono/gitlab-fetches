import { exec } from 'child_process';
import test from 'node:test';
import assert from 'node:assert';
import { promisify } from 'util';

const execAsync = promisify(exec);
const scriptPath = './src/gitlab-fetches.sh';

test('displays help', async () => {
  const { stdout } = await execAsync(`${scriptPath} --help`);
  assert.ok(stdout.includes('Usage:'));
});

test('displays version', async () => {
  const { stdout } = await execAsync(`${scriptPath} --version`);
  assert.ok(stdout.includes('1.0.0'));
});

test('fails without project url', async () => {
  try {
    await execAsync(scriptPath);
    assert.fail('The script should have failed.');
  } catch (error) {
    assert.ok(error.stderr.includes('Error: At least one GitLab project URL is required.'));
  }
});

test('fails without token', async () => {
  try {
    await execAsync(`${scriptPath} https://gitlab.com/gitlab-org/gitlab`);
    assert.fail('The script should have failed.');
  } catch (error) {
    assert.ok(error.stderr.includes('Error: GitLab token is required.'));
  }
});

test('fails with invalid token', async () => {
  try {
    await execAsync(`${scriptPath} --token "invalid-token" https://gitlab.com/gitlab-org/gitlab`);
    assert.fail('The script should have failed.');
  } catch (error) {
    assert.ok(error.stderr.includes('Error fetching data for project gitlab-org/gitlab: 401 Unauthorized'));
  }
});

// End-to-end test for a single project.
test('successfully fetches data for a single project', { skip: !process.env.GITLAB_E2E_TOKEN }, async () => {
  const projectUrl = 'https://gitlab.com/gitlab-org/gitlab-runner';
  const projectPath = 'gitlab-org/gitlab-runner';
  const command = `GITLAB_TOKEN="${process.env.GITLAB_E2E_TOKEN}" ${scriptPath} ${projectUrl}`;

  const { stdout } = await execAsync(command);
  const result = JSON.parse(stdout);

  assert.ok(result[projectPath], `The result should have a key for ${projectPath}`);
  assert.ok(Array.isArray(result[projectPath].historical), 'The historical data should be an array.');
  assert.strictEqual(typeof result[projectPath].total, 'number', 'The total should be a number.');
});

// End-to-end test for multiple projects.
test('successfully fetches and aggregates data for multiple projects', { skip: !process.env.GITLAB_E2E_TOKEN }, async () => {
  const projectUrl1 = 'https://gitlab.com/gitlab-org/gitlab-runner';
  const projectPath1 = 'gitlab-org/gitlab-runner';
  const projectUrl2 = 'https://gitlab.com/gitlab-org/gitlab';
  const projectPath2 = 'gitlab-org/gitlab';
  const command = `GITLAB_TOKEN="${process.env.GITLAB_E2E_TOKEN}" ${scriptPath} ${projectUrl1} ${projectUrl2}`;

  const { stdout } = await execAsync(command);
  const result = JSON.parse(stdout);

  assert.ok(result[projectPath1], `The result should have a key for ${projectPath1}`);
  assert.ok(Array.isArray(result[projectPath1].historical), `Historical data for ${projectPath1} should be an array.`);
  assert.strictEqual(typeof result[projectPath1].total, 'number', `Total for ${projectPath1} should be a number.`);

  assert.ok(result[projectPath2], `The result should have a key for ${projectPath2}`);
  assert.ok(Array.isArray(result[projectPath2].historical), `Historical data for ${projectPath2} should be an array.`);
  assert.strictEqual(typeof result[projectPath2].total, 'number', `Total for ${projectPath2} should be a number.`);
});
