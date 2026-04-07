# Secrets Management

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Everything in CLAUDE.md is sent on every API call. If you put a secret in CLAUDE.md, it travels over the network on every turn of every session. Don't do this.

## What NOT to put in CLAUDE.md

CLAUDE.md content is part of the system prompt, sent with every API request to Anthropic's servers.

**Never put these in CLAUDE.md:**
- API keys or tokens (ANTHROPIC_API_KEY, AWS_SECRET_ACCESS_KEY, etc.)
- Database connection strings with credentials
- Passwords or passphrases
- Private keys or certificates
- OAuth client secrets
- Webhook secrets
- Any credential, even for "development" or "test" environments

**Why it's worse than you think:** CLAUDE.md isn't just read once. It's sent on every API call for the entire session. A 40-turn session sends your CLAUDE.md 40 times. If a secret is in there, it crosses the network 40 times.

## Where secrets should live

| Secret type | Where to store | How Claude accesses it |
|---|---|---|
| API keys | `.env` file (gitignored) | Reads .env when needed |
| Database URLs | `.env` file or env vars | Environment variable at runtime |
| SSH keys | `~/.ssh/` | Claude doesn't need these directly |
| Cloud credentials | Cloud provider CLI config | `aws configure`, `gcloud auth` |
| CI secrets | GitHub/GitLab secrets | Injected as env vars in CI |

## .env handling

The `.env` file is the standard place for development secrets:

```bash
# .env (MUST be in .gitignore)
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
ANTHROPIC_API_KEY=sk-ant-...
STRIPE_SECRET_KEY=sk_test_...
```

**Checklist:**
1. `.env` is in `.gitignore` (check: `grep -q '.env' .gitignore`)
2. `.env.example` exists with placeholder values (no real secrets)
3. CLAUDE.md references env vars by name, not value: "The database URL is in DATABASE_URL"
4. Deny rules prevent reading credential files if needed

## CLAUDE.md safe patterns

**Bad (secret in CLAUDE.md):**
```markdown
## Database
Connection string: postgresql://admin:supersecret@prod.db.com:5432/app
```

**Good (reference in CLAUDE.md, value in .env):**
```markdown
## Database
Connection string is in DATABASE_URL env var. Load from .env file.
```

**Bad (hardcoded API key):**
```markdown
## API Access
Use this key for testing: sk-ant-abc123...
```

**Good (env var reference):**
```markdown
## API Access
The Anthropic API key is configured as ANTHROPIC_API_KEY in .env.
Never hardcode API keys.
```

## MCP server credentials

MCP servers often need credentials (database passwords, API tokens). These are configured in `.mcp.json`:

```json
{
  "servers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

**Risks:**
- `.mcp.json` might be committed to the repo (check `.gitignore`)
- Credentials in `env` are visible to anyone who reads the file
- MCP server processes inherit the credentials in memory

**Mitigations:**
- Add `.mcp.json` to `.gitignore` if it contains credentials
- Use environment variable references instead of literal values where supported
- Use separate credentials for MCP servers (not your primary admin credentials)
- Rotate credentials if `.mcp.json` was ever committed to version control

## Credential rotation

If you suspect a credential was exposed (committed to git, visible in terminal output, included in CLAUDE.md):

1. **Rotate immediately.** Don't wait to confirm exposure.
2. **Check git history.** `git log --all -p -- .env CLAUDE.md .mcp.json` for any commits containing credentials.
3. **Clean git history** if needed. `git filter-branch` or BFG Repo-Cleaner to remove credential commits.
4. **Audit API usage.** Check dashboards for unexpected usage of the exposed key.
5. **Update all copies.** .env, CI secrets, team members' local configs.

## What to take away

1. **CLAUDE.md = sent on every API call.** Never put secrets in it.
2. **Use .env files.** Always gitignored, with .env.example for documentation.
3. **Reference by name, not value.** "DATABASE_URL in .env" not the actual connection string.
4. **Watch .mcp.json.** It can contain credentials and might not be gitignored.
5. **Rotate on exposure.** Don't wait to confirm. Rotate first, investigate second.

---

*Related: [Threat Model](threat-model.md) for secrets exposure risks, [Permissions](permissions.md) for deny rules on credential files.*
