---
description: Review changed code against the development standards in the convention-review skill of this plugin. Asks which changes to review, then judges only against those standards.
argument-hint: optional scope — a file, a folder, a branch name, "staged", "last commit"; leave empty to be asked
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git symbolic-ref:*), Bash(git fetch:*), Read, Grep, Glob, Skill
---

Review changed code against this repository's development standards.

Scope argument for this invocation: $ARGUMENTS

**One language per reply. Never mix.** Pick it once, before you write anything, and hold it for
the whole response — the scope question, the file list, the findings, the closing line.

Pick it this way, first rule that applies:

1. the language the user wrote to you in, if they wrote any prose
2. the language used earlier in this conversation
3. English

A bare `/review-code` with no prose is case 3. The language of this file, of `SKILL.md`, and of the
reference documents does **not** decide it — those are written in whatever language they happen to
be written in, and that is not a signal about the reader.

One exception: text you quote from a reference document keeps that document's language, because a
quotation that has been translated can no longer be checked against its source. A Japanese rule
quoted inside an English reply is correct and expected.

## 1. Settle the scope — every single time

**This invocation settles its own scope.** Anything agreed earlier in this conversation belongs
to an earlier invocation and does not carry over. Having reviewed something a moment ago is not
an answer to this run. Ask again.

Skip the question **only** when this invocation itself carries a scope argument.

### Measure before you speak

Run exactly these, and nothing else, before your first word:

```
git status --short
git diff --stat
git diff --staged --stat
git symbolic-ref --short refs/remotes/origin/HEAD
git log --oneline <that-default-branch>..HEAD
```

Running them is not reviewing. Opening source files is, so do not.

### Then tell the user what you found, in words

Say what the change looks like it is about and which areas it touches — package, layer, feature
names. "11 files, 125 insertions" tells them nothing they did not already know; "6 Java files across
the auth services and the manual controllers" tells them where they are standing. Counts belong in
parentheses after the words, not instead of them.

Keep it to a few short lines. A list of areas reads; one sentence carrying six parenthetical asides
does not. If more than about three areas are touched, use bullets, one area per line.

Two things never appear:

- **Narration of your own process.** Not "I ran the required commands", not "Now let me look at the
  diffs". The user asked for a review, not a log of your turn.
- **Git plumbing.** Staged versus unstaged versus untracked is your bookkeeping, not their decision.
  Mention it only where it changes what they would get.

### Then offer the scopes

Ask which changes to review and **stop. Wait for the reply.** Do not read source files, do not
load skills, do not review anything until it arrives.

Keep the list short and honest:

- **Drop any option that measures empty.** Do not print it in order to announce that it is empty.
- **When two options cover the same thing, list it once** and note the overlap in half a sentence.
  Never print the same content twice under two numbers.
- **Name each option by the question it answers**, not by its git command. "What I am writing right
  now", "what the pull request will show" — the developer is choosing a question, not a command.

The full set to draw from, before dropping and merging:

1. Uncommitted work — everything modified, staged or untracked
2. Staged only
3. The last commit — name its subject line
4. This whole branch against a base — default to the branch `origin/HEAD` points at, and say how
   many commits that is. If `origin/<base>` is missing locally or stale, fetch it before diffing
5. A file or folder the user names

Recommend exactly one and give half a sentence of reason. Take the first rule that holds:

- uncommitted work exists → **1**, it is what the user has just been writing
- otherwise the branch is ahead of its base → **4**
- otherwise → **3**

Close with one plain question. When every option measures empty, say the tree is clean and there is
nothing to review — do not ask a question that no answer can satisfy.

## 2. Show what is in scope

List every file in scope with its change type (modified / added / deleted / renamed), then say
in one line what the scope is. Review nothing outside that list.

Stop and say so plainly, without reviewing, when:

- the scope turns out to be empty
- it contains no source files the loaded standards apply to — documentation, configuration and
  build files are not violations of a coding standard

## 3. Load the rules

Use the `convention-review` skill of this plugin (`${CLAUDE_PLUGIN_ROOT}/skills/convention-review/SKILL.md`).
Read its `SKILL.md` and follow it to the reference document it points at,
`references/backend-conventions.md`, and read that too.

**Those documents are the only basis for a violation.** If they do not say it, it is not a
violation — no matter how wrong the code looks.

## 4. Review the change, not the file

Judge the diff. A pre-existing problem on a line this change did not touch is out of scope, even
when it sits in a file that is in scope.

Work through the scope file by file. Do not stop at the first finding, and do not sample — a
file in scope is a file you read.

## 5. Report

Findings only: no preamble, no closing summary, no praise, no restating what the code does.

For each finding give, in this order:

- the file path from the repository root and the line or line range
- the rule you applied, quoted verbatim from the reference document, in the language that
  document is written in
- what to change, concretely

One finding per location. When the same root cause surfaces at another file or line, report it
there as its own finding rather than mentioning it inside a fix — otherwise its coordinates are
lost.

Anything the standards do not cover is a suggestion, not a violation: label it as a suggestion
and say plainly that the standards are silent on it.

If there is nothing to report, say so in one line.

## 6. Never modify anything

This is a review. Do not edit, create, delete, stage, commit or format any file — not even to
demonstrate a fix. Show the change as text in the report instead.
