# Linux Fundamentals

Student: **Prabhav Semwal**  
Enrollment number: **24BCS10358**

## 1. Soft links and hard links

A soft (symbolic) link stores a path to another file. It can cross file
systems, can point to a directory, and becomes broken when its target is
removed. A hard link is another directory entry for the same inode. It cannot
normally cross file systems or link directories, and the data remains
available until the last hard link is removed.

```bash
printf 'DevOps link practice\n' > original.txt
ln -s original.txt soft-link.txt
ln original.txt hard-link.txt
ls -li original.txt soft-link.txt hard-link.txt
readlink soft-link.txt
rm soft-link.txt hard-link.txt original.txt
```

The inode listing in [the real command output](evidence/linux-output.txt)
shows that the original and hard link share an inode while the symbolic link
has its own inode.

## 2. `adduser` versus `useradd`

`useradd` is a low-level account creation utility. Options must be supplied
for details such as the home directory, shell, and groups. On Debian and
Ubuntu, `adduser` is the friendlier interactive wrapper: it selects sensible
defaults, creates the home directory, and prompts for account details.

```bash
sudo adduser --disabled-password --gecos '' coursework-user
getent passwd coursework-user
sudo deluser --remove-home coursework-user
```

For normal interactive administration on Ubuntu I would choose `adduser`;
scripts that need exact cross-distribution control may use `useradd`.

## 3. `journalctl`

`journalctl` reads logs stored by systemd-journald. Useful forms include:

```bash
journalctl --no-pager -n 20
journalctl -u docker --since today --no-pager
journalctl -p warning --boot --no-pager
journalctl -f
```

The Codespace development container does not run systemd as PID 1, so its
journal can be empty. The captured output records that limitation instead of
inventing service logs. On an Ubuntu system with systemd, the same `-u`
command filters entries for one service and `-f` follows new entries.

## 4. Linux command cheat sheet

| Purpose | Command example |
| --- | --- |
| Current location | `pwd` |
| List files | `ls -lah` |
| Navigate | `cd /path` |
| Create directory/file | `mkdir demo && touch demo/file.txt` |
| Copy/move/remove | `cp source dest`, `mv old new`, `rm file` |
| Read/search text | `cat file`, `less file`, `grep pattern file` |
| Permissions | `chmod u+x script.sh` |
| Ownership | `chown user:group file` |
| Disk and memory | `df -h`, `du -sh .`, `free -h` |
| Processes | `ps aux`, `top`, `kill PID` |
| Archives | `tar -czf archive.tar.gz directory` |
| Help | `man command`, `command --help` |

Full practice output: [`evidence/linux-output.txt`](evidence/linux-output.txt).
