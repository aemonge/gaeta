# Artifacts and Local Serving

Gaeta keeps generated artifacts under `.gaeta/artifacts` by default.

## Server defaults

`gaeta serve` uses safe local defaults:

- root: `.gaeta/artifacts`
- host: `127.0.0.1`
- port: random free port when not provided
- metadata: `.gaeta/server.json`
- no repo-root serving by default

Commands:

- `gaeta serve`
- `gaeta serve status`
- `gaeta serve stop`

## TUI usage

- `/serve` exposes current artifact URL and location.
- `/design` updates HTML artifacts and reviews results using local serving.

Default `/design` does not require browser automation. Experimental profile may optionally add browser-driven capture/review loops.
