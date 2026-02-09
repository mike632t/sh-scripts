# Bash Scripts

A collection of lightweight portable scripts providing helper functions and utilities for interactive scripting, validation, downloads, and system maintenance.  

## Included Scripts

- **sh-confirm.sh** – Prompt the user for confirmation.  Yes returns `true`, No returns `false`.
- **sh-isnumeric.sh** – Returns `True` if the argument is an integer
- **sh-wait.sh** – Wait for a specified time, optionally displaying a countdown message
- **sh-download.sh** – Download files from a given URL with progress display (supports `zenity`, `dialog`, or `console` output)

- **sh-cleanup.sh** – Remove unwanted files, clear logs/history, and perform system cleanup
- **sh-purge.sh** – Purge a predefined list of non-essential packages from Linux Mint 22

## Usage Examples

### sh-confirm.sh
Prompt the user with a message and wait for a **Yes/No** response.
```bash
./sh-confirm.sh "Do you want to proceed?"
```

### sh-isnumeric.sh
Checks if argument is an integer.
```bash 
if ./sh-isnumeric.sh 123; then ... 
```

### sh-wait.sh
Wait for a specified number of seconds, optionally displaying a countdown message.
```bash
./sh-wait.sh 5
```
```bash
./sh-wait.sh 5 "Waiting"
```

### sh-cleanup.sh
Perform system cleanup tasks such as removing cached files, rotating logs, clearing histories, wipe unused space, and then shuts down the system ready to be imaged.

Use with caution.
```
sudo ./sh-cleanup.sh
```
Warning: This script will terminate any display manager, do not use from a terminal window. 

### sh-download.sh
Download files from a given URL, showing progress via zenity, dialog, or terminal output.
```bash
./sh-download.sh 'http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/*SUMS'
```

### sh-purge.sh
Purges packages from a list of packages defined in a file.

Use with caution. This script will uninstall many applications and libraries. 
Review the list of packages in the file before use.

```bash
sudo ./sh-purge.sh  <filename>
```


