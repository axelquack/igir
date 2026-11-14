## Documentation, commit & push

Standing rule from Axel (2026-11-12), for every Grok bot and herdr agent working in this repo:

- Document every change in this project: README, `docs/`, and the changelog (`CHANGELOG.md` or `docs/changelog.md`), with date and what/why.
- Commit with a clear message, then push to the repo's existing remote, public or private, after the secret check.
- Before each commit, run a secret check: `git diff --cached --name-only` and `git diff --cached`. Never commit `.env*`, keys, tokens, `auth.json`, credentials, session exports, or `*.bak*` files. If one is staged, unstage it and add it to `.gitignore`.
- Public repos (`gh repo view --json visibility`): be extra strict. Before pushing, review the full diff being pushed (`git diff @{u}..HEAD`) for secrets, tokens, private IPs and hostnames the repo does not already contain, personal data, and session exports. If anything looks sensitive, do not push; report it to Axel.
- If the repo has no remote, commit locally and report that.
- Commit only your own change; do not sweep in someone else's uncommitted work.

Confirmed by Axel (2026-11-14) for every Grok Bot and Herdr agent:

- Document each change in this repo's own files (README, `docs/`, changelog). A memory note, chat message, or handoff outside the repo does not count.
- Then commit and push to the existing remote after the secret check. Stage by explicit path only (no `git add -A` or `git add .`).
- Force-pushes and history rewrites need Axel's explicit approval.

## Work tracking

Rule from the owner (2026-11-13): all open work goes on the owner's private GitHub Project board, not into new TODO.md items or chat-only lists.

1. File an issue in this repo (or a draft item on the board if no repo fits) and add it to the board with `gh project item-add` (find the board with `gh project list --owner @me`).
2. Link each pull request to its issue (`Closes #<n>` in the PR body) and add the PR to the board too.
3. Set **Status** (Inbox / Waiting on Axel / In progress / Done) and **Owner** (your agent or bot name; if your name is not an Owner option yet, pick your lead bot and write your name in the item).
4. Anything that needs the owner gets Status "Waiting on Axel" and the `waiting-on-axel` label. Ping the owner only if it is urgent; the morning digest covers the rest.
5. Use `gh` on the owner's machine (it has the `project` scope). The GitHub connector cannot reach personal Projects.
6. Existing TODO.md files stay for now; do not add new items to them.
