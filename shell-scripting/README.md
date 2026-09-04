# Shell Scripting

Student: **Prabhav Semwal**  
Enrollment number: **24BCS10358**

The executable [`system-info.sh`](system-info.sh) completes every requested
operation: it prints the date, hostname, username, disk usage and processes;
stores values in variables; collects input with `read -p`; creates a
directory and file with `mkdir` and `touch`; and redirects `ps` output
into the file with `>`.

## Run it

```bash
chmod +x system-info.sh
./system-info.sh
```

Example responses to the prompts:

```text
Enter a directory name: system-info-output
Enter an output file name: processes.txt
```

The complete real execution is saved in
[`evidence/system-info-output.txt`](evidence/system-info-output.txt).

## What I learned

- Quoted variables prevent spaces and wildcard characters in input from being
  split unexpectedly.
- `mkdir -p` is repeatable because an existing directory is not an error.
- `touch` creates an empty file, while `ps > file` replaces that file with
  the current process listing.
- `set -euo pipefail` makes failures and unset variables visible early.
