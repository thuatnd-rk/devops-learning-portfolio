# Linux Commands for DevOps

**Video Reference:** https://www.youtube.com/watch?v=GzIFoJBVwh8

## Part I. Linux OS Fundamentals
### 1. What is Linux?
- Definition and history
- Linux distributions (Ubuntu, CentOS, RHEL, etc.)
- Linux vs Windows vs macOS

### 2. Why Linux is Preferred in DevOps?
- Open source nature
- Stability and reliability
- Command-line efficiency
- Container ecosystem compatibility
- Cloud-native development
- Cost-effectiveness

### 3. Linux Architecture Overview
- Kernel, Shell, and Applications
- File system hierarchy
- User and permission system

## Part II. Essential Linux Commands for DevOps

### 1. File and Directory Management
- `ls` — List directory contents
- `ls -la` — List with detailed information (permissions, size, date)
- `ls -lh` — List with human-readable file sizes
- `pwd` — Print working directory
- `cd` — Change directory
- `mkdir` — Create directories
- `mkdir -p` — Create directories with parent directories
- `rmdir` — Remove empty directories
- `rm` — Remove files and directories
- `rm -rf` — Remove recursively and forcefully
- `cp` — Copy files and directories
- `cp -r` — Copy directories recursively
- `mv` — Move/rename files and directories
- `find` — Search for files and directories
- `find . -name "*.log"` — Find files by name pattern
- `locate` — Find files using database
- `which` — Locate a command
- `whereis` — Locate binary, source, and manual pages
- `file` — Determine file type
- `du` — Display disk usage of files and directories
- `du -sh` — Display disk usage summary in human-readable format

### 2. File Operations and Permissions
- `touch` — Create empty files or update timestamps
- `chmod` — Change file permissions
- `chmod +x` — Make file executable
- `chown` — Change file owner and group
- `chgrp` — Change group ownership
- `umask` — Set default file permissions
- `ln` — Create links between files
- `ln -s` — Create symbolic links
- `tar` — Archive files
- `tar -czf` — Create compressed tar archive
- `tar -xzf` — Extract compressed tar archive
- `gzip` — Compress files
- `gunzip` — Decompress files
- `zip` — Create zip archives
- `unzip` — Extract zip archives

### 3. Text Processing and File Content
- `cat` — Display file contents
- `less` — View file contents page by page
- `more` — View file contents page by page
- `head` — Display first lines of file
- `tail` — Display last lines of file
- `tail -f` — Follow file changes in real-time
- `grep` — Search text using patterns
- `grep -r` — Search recursively in directories
- `grep -i` — Case-insensitive search
- `awk` — Pattern scanning and processing language
- `sed` — Stream editor for filtering and transforming text
- `cut` — Extract columns from files
- `sort` — Sort lines of text files
- `uniq` — Remove duplicate lines
- `wc` — Count lines, words, and characters
- `diff` — Compare files line by line
- `comm` — Compare two sorted files line by line
- `join` — Join lines of two files on a common field
- `paste` — Merge lines of files
- `tr` — Translate or delete characters

### 4. Process and System Monitoring
- `ps` — Display running processes
- `ps aux` — Display all running processes
- `top` — Display running processes dynamically
- `htop` — Enhanced version of top
- `kill` — Terminate processes
- `killall` — Kill processes by name
- `pkill` — Kill processes by pattern
- `jobs` — Display active jobs
- `bg` — Run job in background
- `fg` — Bring job to foreground
- `nohup` — Run command immune to hangups
- `free` — Display memory usage
- `df` — Display disk space usage
- `iostat` — Display I/O statistics
- `vmstat` — Display virtual memory statistics
- `lsof` — List open files

### 5. User and Permission Management
- `sudo` — Execute commands as another user (usually root)
- `su` — Switch user
- `id` — Display user and group information
- `whoami` — Display current username
- `who` — Display who is logged in
- `w` — Display who is logged in and what they are doing
- `passwd` — Change user password
- `useradd` — Add new user
- `userdel` — Delete user
- `usermod` — Modify user account

### 6. Networking
- `ssh` — Secure Shell for remote login
- `scp` — Secure copy files over SSH
- `rsync` — Synchronize files and directories
- `ifconfig` — Configure network interfaces
- `ip` — Show/manipulate routing, devices, and tunnels
- `netstat` — Network statistics
- `ss` — Socket statistics
- `nslookup` — Query Internet domain name servers
- `dig` — DNS lookup utility
- `ping` — Check network connectivity
- `traceroute` — Trace route to host
- `curl` — Transfer data from or to a server
- `wget` — Download files from web
- `telnet` — Telnet client
- `nc` — Netcat utility

### 7. Environment and Package Management
- `env` — Show environment variables
- `export` — Set environment variables
- `unset` — Unset environment variables
- `apt` — Advanced Package Tool (Debian/Ubuntu)
- `apt update` — Update package lists
- `apt upgrade` — Upgrade packages
- `apt install` — Install packages
- `apt remove` — Remove packages
- `yum` — Package manager for RHEL/CentOS
- `apk` — Alpine Linux package manager

### 8. System Information and Logs
- `uname` — Display system information
- `hostname` — Display or set hostname
- `uptime` — Display system uptime
- `date` — Display or set date and time
- `cal` — Display calendar
- `history` — Show command history
- `journalctl` — Query systemd journal
- `dmesg` — Display kernel messages
- `last` — Display last logged in users
- `who` — Display who is logged in

### 9. Disk and Storage Management
- `fdisk` — Partition table manipulator
- `parted` — Partition manipulation program
- `mount` — Mount file systems
- `umount` — Unmount file systems
- `df -h` — Display disk space usage in human-readable format
- `du -sh` — Display disk usage summary
- `lsblk` — List block devices
- `blkid` — Locate/print block device attributes
- `dd` — Convert and copy files
- `sync` — Synchronize cached writes to persistent storage

### 10. Advanced DevOps Commands
- `crontab` — Schedule tasks
- `systemctl` — Control systemd services
- `service` — Control system services
- `chkconfig` — Configure services
- `iptables` — Configure firewall rules
- `firewall-cmd` — Configure firewall (firewalld)
- `docker` — Docker container management
- `kubectl` — Kubernetes command-line tool
- `ansible` — Configuration management tool
- `terraform` — Infrastructure as code tool



## Part III. Shell Scripting Basics


## Part IV. Git Commands for DevOps


## Part V. Practical DevOps Scenarios
