# Security

Buddy Switch is meant to be a shareable pattern, not a dump of a live Hermes
home directory. Before publishing your own fork or examples, check for:

- Bot tokens, API keys, passwords, OAuth secrets, cookies, and GitHub tokens.
- Telegram user IDs, group IDs, channel IDs, thread IDs, phone numbers, and
  private chat names.
- `state.db`, `sessions/`, memories, logs, process snapshots, PID files, and
  lock files.
- Absolute local paths that identify a person or machine.
- Full persona files that contain private history or character material.

Recommended practice:

1. Keep live `.env` files out of git.
2. Use placeholders such as `__HOME__`, `__PROFILE_NAME__`, and
   `__TELEGRAM_CHAT_ID__` in examples.
3. Publish raw runtime logs only after manual review.
4. Push privately first, run a secret scan, then make the repository public.

If you find a sensitive value in this repository, rotate that credential before
opening an issue or pull request.

