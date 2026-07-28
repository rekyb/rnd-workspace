---
description: Write a session handoff to SAVE.md — real git state, what shipped, what's next, and the decisions behind it — so the next session resumes without re-deriving anything.
argument-hint: [optional note to fold into the handoff]
---

Write **`SAVE.md`** at the repo root: the handoff a future session (or a future you, after a
`/clear` or a context compaction) reads first to pick the work back up.

The value is not a summary of what happened — a git log already does that. It is the
**state that is not recoverable from the repo**: which decisions were made and *why*, what
was deliberately deferred versus simply not done, what is verified versus assumed, and
which questions are still open. Write for a reader who has none of this conversation.

**`SAVE.md` is gitignored.** It is working state, not a repo artifact, so it never rides
along in a PR. Never `git add -f` it.

## Steps

1. **Read the current `SAVE.md` if one exists.** This is usually a *revision*, not a fresh
   write. Carry forward anything still true — especially standing constraints and open
   questions nobody has answered yet — and delete what the session has since resolved. An
   open question that got answered becomes a decision; say what was decided.

2. **Gather the real git state. Never state it from memory.** Run the commands and use what
   they return:

   ```
   git branch --show-current
   git log --oneline -5
   git status --short
   git log --oneline @{u}.. 2>/dev/null || echo "no upstream"
   ```

   Record the branch, the HEAD SHA **and** its subject line, whether HEAD is pushed
   (an unpushed commit is the single most common way work gets lost), and whether the
   working tree is clean. If the tree is dirty, say exactly what is uncommitted and whether
   that is deliberate.

3. **Establish what is verified versus assumed.** Any claim that tests pass, a gate is
   green, or a check succeeded must come from a command **run in this session**. If a check
   was run earlier and not since, label it with when it last ran. If a check could not be
   run, say so and why — a handoff that overstates confidence is worse than one that admits
   a gap. Do not copy a previous `SAVE.md`'s green results forward as if they were fresh.

4. **Capture the decisions, with their reasoning.** For each non-obvious call made this
   session: what was decided, what the alternatives were, and *why* this one. This is the
   part that cannot be reconstructed from the diff, and it is what stops the next session
   re-litigating a settled question or silently reversing it. Include decisions that
   **departed from the written plan** — flag those explicitly as departures.

5. **Be explicit about what is NOT done.** Separate three things that look alike in a diff
   and are not the same:
   - **Deliberately deferred** — scoped to a later phase, with the reason.
   - **Blocked** — needs something you do not have (a URL, a credential, an answer).
   - **Known forward references** — a pointer to something that does not exist yet, which
     will dangle until a later stage lands. Name them; they are easy to ship by accident.

6. **Carry the standing constraints.** The rules that must not be dropped, whatever the
   next session is doing — the `ui-library/` read-only guardrail, the disclosure boundary,
   commit identity, commit-only-when-asked, and any invariant this work established
   (paired command/skill registrations, counts that must match, and so on).

7. **Write `SAVE.md`** using the template below. Keep it scannable — the next session reads
   it cold. Prefer tables and short sections over prose. If `$ARGUMENTS` carries a note,
   fold it into the relevant section rather than appending it as a loose remark.

8. **Guardrails on the content.** `SAVE.md` is untracked but lives in a public repo's
   working tree, so hold it to the same bar as a committed file: no PII, no credentials, no
   internal identifiers (product / program / funder names, ticket IDs), and no upstream repo
   URL. Never invent a state you did not verify.

9. **Report** the path, the branch and HEAD it recorded, whether HEAD is pushed, and the
   single most important thing the next session should do first.

---

`SAVE.md` template:

```
# SAVE — session handoff

**Written:** <YYYY-MM-DD>
**Branch:** `<branch>` (branched from `<base>`)
**HEAD:** `<sha>` — *<commit subject>*
**Pushed:** ✅ yes | ❌ **no** — <what that means for the next session>
**Working tree:** clean | dirty — <exactly what is uncommitted, and whether that is deliberate>

---

## Where we are

<The spec or plan being executed, with its path and the section. One paragraph on what
phase/stage this is and what came before.>

## ✅ Done

<Per stage or commit: what shipped, with the SHA. A table of files and what each change
was, where that helps. Verified results only.>

### Verification

<Commands actually run this session and their real output. Anything not re-run gets
"last run <date>". Anything that could not be run gets a reason.>

## Decisions made (and why)

<Each non-obvious call: what was decided, the alternative, and the reasoning. Mark any
departure from the written plan as a departure.>

## ⏭ Next

<The next concrete steps, in order, specific enough to start without re-deriving them.>

## Not done — and which kind

- **Deferred:** <what, to which phase, why>
- **Blocked:** <what, on what>
- **Known forward references:** <pointers that dangle until a later stage lands>

## Open questions

<Anything still unanswered, including questions asked in a previous session that nobody
has resolved. Delete them as they get answered — a stale open question is noise.>

## Standing constraints (do not drop these)

<The invariants that outlive this session.>

## To resume

```bash
git checkout <branch>
git log --oneline -1        # expect <sha>
```

<Then the first thing to do.>
```
