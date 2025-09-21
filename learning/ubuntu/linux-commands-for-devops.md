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

### 1. What is Shell Scripting?
- **Definition**: Shell scripting is writing a series of commands in a file that can be executed as a program
- **Purpose**: Automate repetitive tasks, system administration, and DevOps workflows
- **Common Shells**: Bash (Bourne Again Shell), Zsh, Fish
- **File Extension**: `.sh` (e.g., `script.sh`)

### 2. Basic Shell Script Structure

#### **Shebang Line**
```bash
#!/bin/bash
```
- **Purpose**: Telystls the sem which interpreter to use
- **Location**: Must be the first line of the script
- **Common Shebangs**:
  - `#!/bin/bash` - Bash shell
  - `#!/bin/sh` - POSIX shell
  - `#!/usr/bin/env bash` - Portable bash

#### **Comments**
```bash
# This is a single-line comment

: '
This is a multi-line comment
You can write multiple lines here
'
```

#### **Basic Script Template**
```bash
#!/bin/bash

# Script: example.sh
# Description: Basic shell script template
# Author: Your Name
# Date: $(date +%Y-%m-%d)

# Variables
SCRIPT_NAME="example.sh"
VERSION="1.0"

# Functions
function show_help() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
}

# Main script logic
echo "Hello, World!"
echo "Script: $SCRIPT_NAME"
echo "Version: $VERSION"

# Exit with success status
exit 0
```

### 3. Essential Shell Script Components

#### **Variables**
```bash
# Variable assignment
NAME="John Doe"
AGE=25
PATH="/usr/local/bin:$PATH"

# Variable usage
echo "Name: $NAME"
echo "Age: $AGE"

# Environment variables
echo "Home directory: $HOME"
echo "Current user: $USER"
echo "Current directory: $PWD"
```

#### **Input/Output**
```bash
# Reading user input
echo "Enter your name:"
read USER_NAME
echo "Hello, $USER_NAME!"

# Reading input with prompt
read -p "Enter your age: " USER_AGE
echo "You are $USER_AGE years old"

# Reading silent input (for passwords)
read -s -p "Enter password: " PASSWORD
echo
```

#### **Conditional Statements**
```bash
# If-else statements
if [ "$USER" = "root" ]; then
    echo "You are running as root"
else
    echo "You are running as $USER"
fi

# Multiple conditions
if [ -f "file.txt" ] && [ -r "file.txt" ]; then
    echo "File exists and is readable"
elif [ -f "file.txt" ]; then
    echo "File exists but not readable"
else
    echo "File does not exist"
fi

# Case statements
case "$1" in
    "start")
        echo "Starting service..."
        ;;
    "stop")
        echo "Stopping service..."
        ;;
    "restart")
        echo "Restarting service..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        ;;
esac
```

#### **Loops**
```bash
# For loop
for i in {1..5}; do
    echo "Iteration $i"
done

# For loop with array
FRUITS=("apple" "banana" "orange")
for fruit in "${FRUITS[@]}"; do
    echo "Fruit: $fruit"
done

# While loop
COUNTER=1
while [ $COUNTER -le 5 ]; do
    echo "Counter: $COUNTER"
    COUNTER=$((COUNTER + 1))
done

# Until loop
COUNTER=1
until [ $COUNTER -gt 5 ]; do
    echo "Counter: $COUNTER"
    COUNTER=$((COUNTER + 1))
done
```

### 4. Practical Shell Script Examples

#### **Example 1: System Information Script**
```bash
#!/bin/bash

# Script: system-info.sh
# Description: Display system information

echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime)"
echo "Memory Usage:"
free -h
echo "Disk Usage:"
df -h
```

#### **Example 2: File Backup Script**
```bash
#!/bin/bash

# Script: backup.sh
# Description: Backup files to a specified directory

# Configuration
SOURCE_DIR="/home/ndthuat/documents"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$SOURCE_DIR" .

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_DIR/$BACKUP_NAME"
else
    echo "Backup failed!"
    exit 1
fi
```

#### **Example 3: Service Monitoring Script**
```bash
#!/bin/bash

# Script: service-monitor.sh
# Description: Monitor service status and restart if needed

SERVICE_NAME="nginx"
LOG_FILE="/var/log/service-monitor.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check service status
if systemctl is-active --quiet "$SERVICE_NAME"; then
    log_message "$SERVICE_NAME is running"
else
    log_message "$SERVICE_NAME is not running, attempting to start..."
    systemctl start "$SERVICE_NAME"
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_message "$SERVICE_NAME started successfully"
    else
        log_message "Failed to start $SERVICE_NAME"
        exit 1
    fi
fi
```

#### **Example 4: Log Analysis Script**
```bash
#!/bin/bash

# Script: log-analyzer.sh
# Description: Analyze log files for errors

LOG_FILE="/var/log/nginx/error.log"
ERROR_THRESHOLD=10

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file $LOG_FILE does not exist"
    exit 1
fi

# Count errors in the last hour
ERROR_COUNT=$(journalctl -u nginx --since "1 hour ago" -p err --no-pager | wc -l)

echo "Error count in the last hour: $ERROR_COUNT"

if [ "$ERROR_COUNT" -gt "$ERROR_THRESHOLD" ]; then
    echo "WARNING: High error count detected!"
    echo "Top errors:"
    journalctl -u nginx --since "1 hour ago" -p err --no-pager | \
    awk '{print $NF}' | sort | uniq -c | sort -nr | head -5
else
    echo "Error count is within acceptable limits"
fi
```

### 5. Advanced Shell Scripting Features

#### **Functions**
```bash
#!/bin/bash

# Function definition
function greet_user() {
    local name=$1
    local time_of_day=$2
    
    case "$time_of_day" in
        "morning")
            echo "Good morning, $name!"
            ;;
        "afternoon")
            echo "Good afternoon, $name!"
            ;;
        "evening")
            echo "Good evening, $name!"
            ;;
        *)
            echo "Hello, $name!"
            ;;
    esac
}

# Function usage
greet_user "ndthuat" "morning"
greet_user "rookie" "evening"
```

#### **Error Handling**
```bash
#!/bin/bash

# Exit on any error
set -e

# Exit on undefined variables
set -u

# Function to handle errors
error_handler() {
    echo "Error occurred in line $1"
    echo "Command: $2"
    exit 1
}

# Set error trap
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

# Your script commands here
echo "This will work"
# This will cause an error and trigger the trap
ls /nonexistent/directory
```

#### **Command Line Arguments**
```bash
#!/bin/bash

# Script: deploy.sh
# Usage: ./deploy.sh [environment] [version]

# Default values
ENVIRONMENT="development"
VERSION="latest"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-e|--environment ENV] [-v|--version VER]"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo "Deploying version $VERSION to $ENVIRONMENT environment"
```

### 6. Best Practices for Shell Scripting

#### **Code Organization**
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use consistent indentation (2 or 4 spaces)

#### **Error Handling**
- Always check return codes
- Use `set -e` for immediate exit on errors
- Implement proper error messages
- Log important operations

#### **Security**
- Quote variables to prevent word splitting
- Use `read -s` for password input
- Validate user input
- Avoid using `eval` with user input

#### **Performance**
- Use built-in commands when possible
- Avoid unnecessary subshells
- Use arrays for multiple values
- Minimize external command calls

### 7. Common Shell Scripting Patterns

#### **Configuration Management**
```bash
#!/bin/bash

# Load configuration
CONFIG_FILE="/etc/myapp.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi
```

#### **Logging**
```bash
#!/bin/bash

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "/var/log/myapp.log"
}

# Usage
log "INFO" "Application started"
log "ERROR" "Failed to connect to database"
```

#### **Process Management**
```bash
#!/bin/bash

# Check if process is running
is_process_running() {
    local process_name=$1
    pgrep -f "$process_name" > /dev/null
}

# Start process if not running
if ! is_process_running "myapp"; then
    echo "Starting myapp..."
    nohup ./myapp > /dev/null 2>&1 &
    echo "myapp started with PID: $!"
fi
```