#!/usr/bin/env python3

import pathlib
import subprocess
import tempfile


def check_text(text: str) -> bool:
    with tempfile.NamedTemporaryFile(
        "w", delete=False, suffix=".sh", encoding="utf-8"
    ) as tmp:
        tmp.write(text)
        path = tmp.name
    proc = subprocess.run(
        ["shellharden", "--transform", path], capture_output=True, text=True
    )
    pathlib.Path(path).unlink(missing_ok=True)
    return proc.returncode == 0


def main() -> int:
    source = pathlib.Path("gaeta").read_text(encoding="utf-8").splitlines(keepends=True)
    low, high = 1, len(source)

    if check_text("".join(source)):
        print("full file parses")
        return 0

    while low < high:
        mid = (low + high) // 2
        ok = check_text("".join(source[:mid]))
        if ok:
            low = mid + 1
        else:
            high = mid

    print(low)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
