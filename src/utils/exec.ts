import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export interface ExecResult {
  stdout: string;
  stderr: string;
}

export async function exec(
  cmd: string,
  args: string[],
  cwd?: string
): Promise<ExecResult> {
  const { stdout, stderr } = await execFileAsync(cmd, args, {
    cwd: cwd ?? process.cwd(),
    encoding: "utf8",
  });
  return { stdout: stdout.trim(), stderr: stderr.trim() };
}
