import { exec } from "../utils/exec.js";

export const gitTools = [
  {
    name: "git_branch_name",
    description:
      "Suggest a valid git branch name from a short description. Follows <type>/<kebab-description> convention.",
    inputSchema: {
      type: "object" as const,
      properties: {
        description: {
          type: "string",
          description: "What the branch is for (e.g. 'add user auth')",
        },
        type: {
          type: "string",
          enum: ["feat", "fix", "chore", "docs", "refactor", "test"],
          description: "Branch type prefix (default: feat)",
        },
      },
      required: ["description"],
    },
  },
  {
    name: "git_commit_message",
    description:
      "Generate a conventional commit message from a summary of changes.",
    inputSchema: {
      type: "object" as const,
      properties: {
        summary: {
          type: "string",
          description: "Plain-language description of what changed",
        },
        type: {
          type: "string",
          enum: ["feat", "fix", "chore", "docs", "refactor", "test", "style"],
          description: "Commit type (default: feat)",
        },
        scope: {
          type: "string",
          description: "Optional scope (e.g. 'auth', 'api')",
        },
      },
      required: ["summary"],
    },
  },
];

export async function handleGitTool(
  name: string,
  args: Record<string, string>
): Promise<string> {
  switch (name) {
    case "git_branch_name": {
      const type = args.type ?? "feat";
      const slug = args.description
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, "")
        .trim()
        .replace(/\s+/g, "-")
        .slice(0, 50);
      return `${type}/${slug}`;
    }

    case "git_commit_message": {
      const type = args.type ?? "feat";
      const scope = args.scope ? `(${args.scope})` : "";
      const subject = args.summary
        .replace(/^./, (c) => c.toLowerCase())
        .replace(/\.$/, "");
      return `${type}${scope}: ${subject}`;
    }

    default:
      throw new Error(`Unknown git tool: ${name}`);
  }
}

export async function getGitStatus(cwd?: string): Promise<string> {
  try {
    const { stdout } = await exec("git", ["status", "--short"], cwd);
    return stdout || "(clean)";
  } catch {
    return "(not a git repo)";
  }
}
