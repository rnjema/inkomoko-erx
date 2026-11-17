# Issue Guide: creation, tracking, and discipline

This is the rulebook for how work gets tracked on this project. It exists because
a task that isn't written down belongs to no one, and work that belongs to no one
doesn't get done. Read it once, then follow it by habit.

If you haven't read [CONTRIBUTING.md](../CONTRIBUTING.md), start there — this
document assumes it.

## Table of contents

- [Why issues are the unit of work](#why-issues-are-the-unit-of-work)
- [Opening an issue](#opening-an-issue)
- [Labels](#labels)
- [Assignment](#assignment)
- [Lifecycle](#lifecycle)
- [Linking issues to branches and pull requests](#linking-issues-to-branches-and-pull-requests)
- [Size and estimation](#size-and-estimation)
- [Check-ins and stale issues](#check-ins-and-stale-issues)
- [Blocked issues](#blocked-issues)
- [Closing an issue](#closing-an-issue)
- [Escalation](#escalation)

## Why issues are the unit of work

Every task on this project — a bug, a feature, a schema change, a research
question — is an issue before it is anything else. Not a Slack message, not a
verbal "can you look at X", not a line in someone's personal notes. If it's worth
doing, it's worth one issue, assigned to one person, with a visible status.

This matters more here than on a typical side project: this repo touches a real
partner's data model (CBS and IMS), and the team is distributed across people with
different availability. The issue tracker is the only shared memory that survives
a dropped meeting or a missed message.

## Opening an issue

Use a template — do not start from a blank issue. Templates live in
`.github/ISSUE_TEMPLATE/` and cover:

- **Task** — a piece of planned work with a known shape (most issues are this).
- **Bug report** — something that worked and now doesn't, or never worked as
  specified.
- **Feature / enhancement** — new capability, not a fix.
- **Data question** — a question about CBS/IMS semantics that needs an answer
  before work can proceed (e.g. "what does a null `tenant_id` mean in this
  table?"). These often block other issues — label them `blocked-by` candidates
  and resolve them fast.

Every issue needs:

1. **A title that names the outcome, not the activity.**
   Good: "Resolve duplicate customer records sharing a phone number across CBS
   and IMS." Bad: "Look into duplicates."
2. **Context** — one or two sentences on why this matters, linking the source
   system or doc (`docs/schemas/...`, `docs/erd/...`) if relevant.
3. **Acceptance criteria** — a checklist of what must be true for this to be done.
   If you can't write acceptance criteria, the issue isn't ready to be worked;
   it's still a question.
4. **Definition of done inputs** — does this need a test? A doc update? A schema
   diagram refresh? Say so up front, not as a surprise in review.
5. **Labels** — at minimum one `type:` and one `area:` label (see below).
6. **An estimate or size** (see [Size and estimation](#size-and-estimation)).

No assignee is required to open an issue — anyone can flag work. An assignee is
required before work starts.

## Labels

Labels are how the board stays legible at a glance. Every issue carries one label
from each of these groups:

| Group | Labels | Meaning |
|---|---|---|
| `type:` | `type:task`, `type:bug`, `type:feature`, `type:docs`, `type:research`, `type:data-question` | What kind of work this is. |
| `priority:` | `priority:p0`, `priority:p1`, `priority:p2`, `priority:p3` | `p0` blocks everything (e.g. broken pipeline), `p3` is nice-to-have. |
| `area:` | `area:cbs`, `area:ims`, `area:record-linkage`, `area:modeling`, `area:pipeline`, `area:docs`, `area:infra` | Which part of the system this touches. |
| `status:` | `status:triage`, `status:ready`, `status:in-progress`, `status:blocked`, `status:in-review`, `status:done` | Where it sits in the lifecycle — mirrors the board column; see below. |

Don't invent new labels ad hoc. If none of these fit, say so in the weekly
check-in and the team adds one deliberately — an unbounded label set is as
useless as no labels.

## Assignment

- **One assignee per issue.** Pair work happens, but one name is accountable for
  the issue moving. If two people are genuinely co-driving, say so in a comment,
  but assign one.
- **Self-assign only out of `status:ready`.** An issue sitting in `status:triage`
  hasn't been scoped enough to start — acceptance criteria may still be fuzzy.
- **No orphan issues.** An issue with `status:in-progress` and no assignee is a
  bug in the tracker, not a valid state. Fix it the moment you see it.
- **Reassigning is fine, silently dropping it is not.** If you can't finish
  something, say so in the issue and un-assign yourself rather than letting it go
  stale under your name.

## Lifecycle

Issues move left to right through a single GitHub Project board:

```
Triage → Ready → In Progress → In Review → Done
```

- **Triage** — newly opened, needs acceptance criteria, labels, and an estimate
  before anyone picks it up.
- **Ready** — scoped, labeled, estimated, unassigned, available to claim.
- **In Progress** — assigned, branch exists, active work.
- **In Review** — pull request open and linked, waiting on review per
  `CONTRIBUTING.md`.
- **Done** — merged, acceptance criteria verified, issue closed by the merge.

Move the card yourself when your situation changes — don't wait for someone else
to notice. The board is only honest if everyone keeps it honest in real time.

## Linking issues to branches and pull requests

- Branch name includes the issue number: `feat/42-fuzzy-match-customer-names`.
- Pull request description includes a closing keyword: `Closes #42`,
  `Fixes #58`, or `Resolves #61`. This is what moves the card to **Done**
  automatically on merge — don't rely on someone remembering to close it by hand.
- If a pull request only partially addresses an issue, say so explicitly
  (`Partially addresses #42 — follow-up in #67`) rather than closing early.

## Size and estimation

Use t-shirt sizes on every issue before it leaves **Triage**:

- **S** — half a day or less, narrow and well-understood.
- **M** — one to three days, some unknowns.
- **L** — most of a week, real design or research involved.
- **XL** — split it. An issue this big hides its own scope creep; break it into
  a tracking issue plus S/M children before anyone is assigned.

If an issue grows past its size mid-work, don't silently absorb the overrun —
comment on the issue, re-estimate, and flag it in the next check-in.

## Check-ins and stale issues

- **Weekly check-in**: every assigned issue gets a one-line status comment —
  on track, blocked, or needs re-scoping. This takes two minutes and prevents a
  week of silent drift.
- **Stale after 7 days with no comment**: anyone (not just the assignee) may
  comment asking for a status update. After 14 days with no response, the issue
  is un-assigned and returned to `status:ready`.
- Silence is not a status. If you're stuck, say "blocked" and say on what — that
  is useful information; disappearing is not.

## Blocked issues

- Label it `status:blocked` and name the blocker in a comment — link the issue,
  external dependency, or data question that's holding it up.
- A blocked issue is not a dead issue: whoever is blocked checks back on the
  blocker at least weekly and comments when it clears.
- If an issue has been blocked for more than two weeks, raise it at the check-in
  so the team can decide whether to re-scope around the blocker rather than wait
  on it indefinitely.

## Closing an issue

An issue closes when, and only when:

- [ ] Every item in its acceptance criteria is checked off.
- [ ] The linked pull request is merged (or, for non-code issues, the described
      outcome is actually true — a doc exists, a decision is recorded, a question
      is answered in the issue itself).
- [ ] Anything the issue promised to update (docs, schema diagrams, tests) is
      actually updated.

Don't close an issue "to clean up the board" while the underlying work is
unfinished — reopen it or split the remainder into a new issue instead. A closed
issue is a claim that the work is done; don't make a claim you haven't verified.

## Escalation

Disagreement about scope, priority, or whether something is actually done belongs
in the issue thread first — in writing, where the next person can see the
reasoning. If it can't be resolved there, raise it at the weekly check-in rather
than letting the issue sit contested and stalled. Even the very wise cannot see
all ends; write down the disagreement so the next person inherits the reasoning,
not just the verdict.
