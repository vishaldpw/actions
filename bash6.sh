#!/usr/bin/env bash

echo "Starting the script#6 ..."

# Task 1: Edit the /etc/ssh/sshd_config file to set AllowUsers above any Include and Match statements
echo "Task 1: Updating SSH configuration to allow only ec2-user..."
sudo sed -i '/^Include/ i\AllowUsers ec2-user' /etc/ssh/sshd_config
echo "Task 1 completed: SSH configuration updated."

# Task 2: Set permissions on all files in /var/log/amazon/ to 640
echo "Task 2: Setting permissions to 640 on all files in /var/log/amazon/..."
sudo find /var/log/amazon/ -type f -exec chmod 640 {} \;
echo "Task 2 completed: Permissions updated."

# Task 3: Set the sticky bit on all world writable directories
echo "Task 3: Setting sticky bit on all world writable directories..."
sudo df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' sudo find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' sudo chmod a+t '{}'
echo "Task 3 completed: Sticky bit set on directories."

# Task 4: Remove other write permissions from world writable files and add sticky bit to directories
echo "Task 4: Removing write permissions from world writable files and adding sticky bit to directories..."
{
 l_smask='01000'
 a_file=(); a_dir=() # Initialize arrays
 a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path "*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path "*/kubelet/plugins/*" -a ! -path "/sys/*" -a ! -path "/snap/*")
 while IFS= read -r l_mount; do
 while IFS= read -r -d $'\0' l_file; do
 if [ -e "$l_file" ]; then
 l_mode="$(stat -Lc '%#a' "$l_file")"
 if [ -f "$l_file" ]; then # Remove excess permissions from WW files
 echo -e " - File: \"$l_file\" is mode: \"$l_mode\"\n - removing write permission on \"$l_file\" from \"other\""
 chmod o-w "$l_file"
 fi
 if [ -d "$l_file" ]; then # Add sticky bit
 if [ ! $(( $l_mode & $l_smask )) -gt 0 ]; then
 echo -e " - Directory: \"$l_file\" is mode: \"$l_mode\" and doesn't have the sticky bit set\n - Adding the sticky bit"
 chmod a+t "$l_file"
 fi
 fi
 fi
 done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2> /dev/null)
 done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^(\/run\/user\/|\/tmp|\/var\/tmp)/){print $2}')
}
echo "Task 4 completed: World writable files and directories processed."

# Task 5: Set SELinux to permissive
echo "Task 5: Setting SELinux to permissive..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
echo "Task 5 completed: SELinux set to permissive."

# Task 6: Create or edit a policy module file in /etc/crypto-policies/policies/modules/ to disable weak MACs
echo "Task 6: Disabling weak MACs in SSH policy module..."
sudo mkdir -p /etc/crypto-policies/policies/modules/
sudo printf '%s\n' "# This is a subpolicy to disable weak MACs" \
"# for the SSH protocol (libssh and OpenSSH)" \
"mac@SSH = -HMAC-MD5* -UMAC-64* -UMAC-128*" \
>> /etc/crypto-policies/policies/modules/NO-SSHWEAKMACS.pmod
echo "Task 6 completed: Weak MACs disabled."

echo "Script#6 completed successfully."
