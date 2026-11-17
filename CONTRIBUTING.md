# Contributing to inkomoko-erx

This project cleans up and links records across Inkomoko's CBS (core banking) and
IMS systems. It is built by a team, for a partner who will rely on the result —
treat it with the same discipline you'd want from a vendor.

Every contribution starts from an issue and ends in a reviewed pull request. No
exceptions, no "quick fix on main."

## Table of contents

- [Getting started](#getting-started)
- [The golden rule: issue first](#the-golden-rule-issue-first)
- [Branching](#branching)
- [Commit messages](#commit-messages)
- [Code style and quality gates](#code-style-and-quality-gates)
- [Pull requests](#pull-requests)
- [Data discipline](#data-discipline)
- [Documentation](#documentation)
- [Definition of done](#definition-of-done)

## Getting started

```bash
make create_environment   # create a uv-managed virtualenv for the target Python version
make requirements         # install dependencies
make lint                 # flake8 + isort --check + black --check
make test                 # run the test suite
```

Run `make format` before committing — it is `isort` and `black`, applied in place.
Run `make lint` before opening a pull request; CI runs the same check and a red
check blocks review.

## The golden rule: issue first

Work that isn't tracked in an issue doesn't exist as far as the team can tell. Before
writing code:

1. Find or open an issue describing the task. See
   [docs/ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md) for how issues are written, labeled,
   and assigned — read it once; it is the rulebook this file assumes.
2. Make sure the issue has a single assignee, and that assignee is you, before you
   start.
3. If the task turns out bigger or different from what the issue says, say so in
   the issue before you go further off the rails than that.

A pull request that doesn't close or reference an issue will be asked to go get
one.

## Branching

`main` is protected: no direct pushes, no force-pushes, no exceptions.

Branch names carry the issue number so anyone can trace work back to its task:

```
<type>/<issue-number>-<short-description>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `data`, `research`.

Examples:

```
feat/42-fuzzy-match-customer-names
fix/58-ims-null-tenant-id
docs/61-schema-readme-for-cbs-tenant-store
```

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

<optional body — the why, not the what>

Refs #<issue-number>
```

- `type` is one of `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `data`.
- `scope` is the area touched (`ierx`, `schemas`, `modeling`, `docs`, …).
- Keep the summary under ~72 characters, imperative mood ("add", not "added").
- Reference the issue in the body, not the subject line.

Squash messy work-in-progress history before review — a reviewer should be able to
read the commit log and understand the change without reconstructing your
debugging session.

## Code style and quality gates

- Formatting and import order are enforced by `black` and `isort`
  (`pyproject.toml`); line length is 99.
- `flake8` (`setup.cfg`) is the linter of record; its exclusions (`notebooks`,
  `references`, `models`, `data`) are deliberate — don't fight them, don't widen
  them without discussion.
- New logic in `ierx/` gets a test in `tests/`. If you can't test it, say why in
  the pull request.
- Notebooks are for exploration, not delivery. Logic that earns its keep moves
  into `ierx/` behind a test.

## Pull requests

- One pull request, one issue, one concern. Don't bundle an unrelated drive-by fix
  into a feature PR — open a second issue instead.
- Fill in the pull request template; an empty "what changed" section is a sign the
  PR is either too big to describe or not ready.
- Link the issue with a closing keyword (`Closes #42`) so merging the PR closes the
  issue automatically.
- CI (lint + test) must be green before review starts. Don't ask for review on a
  red build.
- At least one approval is required before merge. The author does not approve
  their own PR and does not merge it themselves unless the reviewer says to.
- Resolve every review comment — either with a code change or a reply explaining
  why not. Don't resolve a thread you didn't write the reply to.
- Prefer "Squash and merge" so `main`'s history reads one commit per issue.

## Data discipline

- `data/` is gitignored on purpose. Raw and interim data never enter version
  control, not even "just this once." If a fixture is needed for tests, make it
  small, synthetic, and put it under `tests/` deliberately.
- Changes to the CBS or IMS schemas, or to the entity-relationship diagrams under
  `docs/erd/` and `docs/schemas/`, need a reviewer who has looked at the source
  system, not just the diff.
- Anything that looks like a real customer, loan, or account identifier does not
  belong in a notebook output, a commit, or an issue comment. Use the synthetic
  data described in `docs/schemas/SYNTHETIC_CUSTOMER_MATCHING.md`.

## Documentation

- If a change affects how someone else would use `ierx/` or understand the data
  model, update the relevant doc in the same pull request — not "in a follow-up."
- `docs/schemas/README.md` and `docs/erd/` are the map of the two source systems.
  Keep them current or the map stops matching the territory.

## Definition of done

A task is done when, and only when:

- [ ] The linked issue's acceptance criteria are met.
- [ ] `make lint` and `make test` pass locally and in CI.
- [ ] A reviewer has approved the pull request.
- [ ] Relevant docs are updated.
- [ ] The issue is closed by the merge, not left open "for tidiness."

---

He that ships without review to find out if it works has left the path of
wisdom. Slow down at the review step — it is cheaper than the alternative.
