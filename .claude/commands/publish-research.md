---
description: Publish the active research to GitHub — safety-check for PII, commit, and push via the gh CLI.
argument-hint: [-m "custom commit message"]
---

Publish the currently active research to the GitHub remote using the `gh` CLI.
This is an **explicit** publish step — it is never run automatically, because
captures can contain sensitive data and this repo may be public.

Steps:

1. **Locate the research.** Resolve the target study per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this
   terminal's binding, else the sole active study, else ask). If the registry is
   empty, tell the user there's no active research and stop.

2. **Confirm the remote & auth.** Run `gh auth status`. If not logged in, tell the
   user to run `gh auth login` themselves (never handle their credentials) and stop.
   Ensure git is configured to use gh for HTTPS pushes:
   `gh auth setup-git`. If the repo has no `origin`, ask the user for the repo
   (or create one only if they explicitly ask) — do not invent a remote.

3. **PII / paywall safety gate (required).** Before staging, verify the guardrails
   in `CLAUDE.md` are satisfied for what you're about to publish:
   - **Benchmark captures:** skim the new/changed files in `platforms/*/screenshots/`
     and `flow.gif` for un-redacted personal data — the account holder's **and third
     parties'** names, avatars, emails (e.g. leaderboard/comment/social surfaces).
   - **Usability sessions:** skim every new/changed `sessions/session-*.md` for
     participant PII — real names, emails, or identifying quotes. Participants must be
     pseudonymized (P01, P02…); if a real identity is present, STOP and flag it.
   - If the remote repo is **public** (`gh repo view --json visibility`), and any
     capture or session note may contain PII, STOP and flag it to the user before
     pushing.
   - Confirm no paid-feature transaction happened.
   - **Litreview corpus guard:** if the study is `Type: litreview`, confirm `corpus/`
     is not staged (it must stay gitignored via `research/*/corpus/`). If any
     `research/*/corpus/*` file is tracked or staged, STOP and tell the user — supplied
     source documents (copyright/PII) must never be pushed. Only `sources.md` records
     what was used.
   - **Mobbin redistribution guard (required).** Run:

     ```bash
     git diff --cached --name-only | grep -E '(/reference/|\.visual\.md$)' && echo LEAK
     git diff --cached --name-only | grep -E '\.docx$' | grep -v '/docx/' && echo DOCX_LEAK
     ```

     If either prints a path, **STOP** and tell the user exactly which files are staged and
     why they cannot be pushed: `reference/` holds licensed Mobbin library images,
     `*.visual.md` embeds them, and a `.docx` outside the gitignored `docx/` folder may embed
     them invisibly. This repo is public. Unstage them and re-run the gate — do not use
     `git add -f` to override.
   Only continue once this is clean.

4. **Stage & commit.** Stage the active research folder (and any workspace docs you
   changed this session — `README.md`, `CLAUDE.md`, `.claude/`). Show
   `git status --short` first. Commit with a clear, conventional message
   summarizing what was captured/synthesized (or use the user's `-m` message).
   End the commit body with the standard `Co-Authored-By` trailer.

5. **Push.** `git push` (set upstream with `-u origin <branch>` on first push).
   If on the default branch and the user prefers PRs, offer to branch + `gh pr
   create` instead — otherwise push directly per this workspace's convention.

6. **Report** the pushed commit hash, the branch, the remote URL
   (`gh repo view --json url -q .url`), and a one-line summary of what went public.
