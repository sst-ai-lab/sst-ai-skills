---
description: Review changed code against the standards of every enabled plugin that provides a check-* skill (check-conventions, check-security, ...). Asks which changes to review, then judges only against those standards.
argument-hint: optional scope — a file, a folder, a branch name, "staged", "last commit"; leave empty to be asked
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git symbolic-ref:*), Bash(git fetch:*), Bash(git grep:*), Read, Grep, Glob, Skill
---

Review changed code against this repository's development standards.

Scope argument for this invocation: $ARGUMENTS

**One language per reply. Never mix.** Pick it once, before you write anything, and hold it for
the whole response — the scope question, the file list, the findings, the closing line.

Pick it this way, first rule that applies:

1. the language the user wrote to you in, if they wrote any prose
2. the language used earlier in this conversation
3. English

A bare `/sst-common:review-code` with no prose is case 3. The language of this file, of `SKILL.md`, and of the
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

Running these is not reviewing yet. Reading source files is, so do not open any until the user has chosen the scope.

### Then tell the user what you found, in words

Say what the change looks like it is about and which areas it touches — package, layer, feature or
screen names. "11 files, 125 insertions" tells them nothing they did not already know; "6 Java files across
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
- it contains no file that any standard found in step 3 covers — documentation, configuration and
  build files are not violations of a coding standard

## 3. Load the rules

This command carries no standards of its own. They come from the other plugins enabled in this
repository: **every skill whose name starts with `check-` (`check-conventions`, `check-security`,
...), in any enabled plugin, is a set of standards**, and its description says which files it
covers. A skill with any other name is not a standard, even when its name or description mentions
review — `code-review` and `security-review` look for bugs, which is not what this command
does.

1. List the available skills and pick out every `<plugin>:check-*`.
2. Keep each one whose description covers a file type in scope. Several can cover the same file —
   a stack-wide set and a service's own additions — and then all of them apply to it.
3. Load each kept skill and follow it to every reference document it points at, including documents
   that sit in other skills of its plugin. Read all of them.
4. Say which standards you loaded and which files each one covers, in one line per standard.

When a file type in scope is covered by none of them, say so and leave those files out of the
review. When no standard covers anything in scope, stop there.

**Those documents are the only basis for a violation.** If they do not say it, it is not a
violation — no matter how wrong the code looks. When a skill ranks its documents — a standard over
a checklist, say — follow its ranking.

## 4. Review the change, not the file

Judge the diff. A pre-existing problem on a line this change did not touch is out of scope, even
when it sits in a file that is in scope.

A renamed file is not a new file. Its content came along with the rename, so only the lines the
diff marks as added or changed are in scope — the rest is somebody else's earlier work, however
new the path looks.

Work through the scope file by file. Do not stop at the first finding, and do not sample — a
file in scope is a file you read.

Take line numbers from a tool that prints them, never from counting. Hunk headers only say where a
hunk starts, and counting lines of a diff or of `git show` output drifts by a few lines. Before you
report, get every line number from numbered output of the file at the reviewed revision:

- when the working tree is at that revision — uncommitted work, or a clean tree whose `HEAD` is the
  reviewed commit, as in CI — Read the file and use the line numbers Read prints;
- otherwise run `git grep -n -F '<exact code on that line>' <revision> -- <path>`.

## 5. Report

Findings only: no preamble, no closing summary, no praise, no restating what the code does.

For each finding give, in this order:

- the file path from the repository root and the line or line range
- the rule you applied, quoted verbatim from the reference document, in the language that
  document is written in, with the identifier that document gives it — a section number or a
  checklist ID. When a lower-ranked document conflicts with a higher one, quote the higher one and
  say that the other differs. Copy the sentence out of the file you read — never retype it from
  memory, shorten it, reflow it or translate it. A rule you cannot find in the document is not a
  rule: drop the finding rather than paraphrase one into place
- what to change, concretely

One finding per location. When the same root cause surfaces at another file or line, report it
there as its own finding rather than mentioning it inside a fix — otherwise its coordinates are
lost. Two locations are two findings even when they break the same rule or sit a few lines apart,
and two different rules at one location are two findings as well.

Anything the standards do not cover is a suggestion, not a violation: label it as a suggestion
and say plainly that the standards are silent on it.

If there is nothing to report, say so in one line.

## 6. Never modify anything

This is a review. Do not edit, create, delete, stage, commit or format any file — not even to
demonstrate a fix. A fix mode that a `check-*` skill offers does not apply to this command.
Show the change as text in the report instead.
