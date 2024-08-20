#!/bin/bash

##### TASK 1 ###
echo "Starting Task 1: Set ClientAliveCountMax to 3 in /etc/ssh/sshd_config"

SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -q "^ClientAliveCountMax" "$SSHD_CONFIG"; then
    sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 3/' "$SSHD_CONFIG"
else
    sed -i '/^Include /i ClientAliveCountMax 3' "$SSHD_CONFIG"
fi
echo "Task 1: Set ClientAliveCountMax to 3 in $SSHD_CONFIG completed."
echo "Ending Task 1"

##### TASK 2 ###
echo "Starting Task 2: Set gpgcheck=1 in /etc/dnf/dnf.conf"

DNF_CONFIG="/etc/dnf/dnf.conf"
if grep -q "^gpgcheck" "$DNF_CONFIG"; then
    sed -i 's/^gpgcheck=.*/gpgcheck=1/' "$DNF_CONFIG"
else
    echo "gpgcheck=1" >> "$DNF_CONFIG"
fi
echo "Task 2: Set gpgcheck=1 in $DNF_CONFIG completed."
echo "Ending Task 2"

##### TASK 3 ###
echo "Starting Task 3: Ensure home directories exist and are owned by the respective user"

for user in $(awk -F: '{ if ($3 >= 1000 && $7 != "/sbin/nologin") print $1 }' /etc/passwd); do
    HOME_DIR=$(eval echo ~$user)
    if [ ! -d "$HOME_DIR" ]; then
        mkdir -p "$HOME_DIR"
        chown "$user":"$user" "$HOME_DIR"
        echo "Task 3: Created and set ownership of home directory for $user."
    fi
done
echo "Task 3: Verified home directories for all users."
echo "Ending Task 3"

##### TASK 4 ###
echo "Starting Task 4: Disable udf module in /etc/modprobe.d/udf.conf"

MODPROBE_FILE="/etc/modprobe.d/udf.conf"
echo "install udf /bin/true" > "$MODPROBE_FILE"
echo "Task 4: Disabled udf module in $MODPROBE_FILE."

# Unload the udf module
rmmod udf && echo "Task 4: Unloaded udf module."
echo "Ending Task 4"

##### TASK 5 ###
echo "Starting Task 5: Check ForwardToSyslog setting in journald configuration"

JOURNALD_CONF=$(systemd-analyze cat-config systemd/journald.conf systemd/journald.conf.d/* | grep -E "^ForwardToSyslog=no")
if [ -z "$JOURNALD_CONF" ]; then
    echo "Task 5: ForwardToSyslog=no is not set or journald is not the logging method."
else
    echo "Task 5: Verified ForwardToSyslog is set to no."
fi
echo "Ending Task 5"

##### TASK 6 ###
echo "Starting Task 6: Set kernel.yama.ptrace_scope to 1 in /etc/sysctl.conf"

SYSCTL_CONF="/etc/sysctl.conf"
echo "kernel.yama.ptrace_scope = 1" >> "$SYSCTL_CONF"
sysctl -p
echo "Task 6: Set kernel.yama.ptrace_scope to 1 in $SYSCTL_CONF."
echo "Ending Task 6"

##### TASK 7 ###
echo "Starting Task 7: Set SELinux mode to Permissive"

setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
echo "Task 7: Set SELinux mode to Permissive."
echo "Ending Task 7"

##### TASK 8 ###
echo "Starting Task 8: Disable gfs2 kernel module in /etc/modprobe.d/gfs2.conf"

GFS2_CONF="/etc/modprobe.d/gfs2.conf"
printf '%s\n' "blacklist gfs2" "install gfs2 /bin/false" >> "$GFS2_CONF"
echo "Task 8: Disabled gfs2 kernel module in $GFS2_CONF."
echo "Ending Task 8"

##### TASK 9 ###
echo "Starting Task 9: Install systemd-journal-remote"

dnf install -y systemd-journal-remote && echo "Task 9: Installed systemd-journal-remote."
echo "Ending Task 9"

##### TASK 10 ###
echo "Starting Task 10: Set sticky bit on all world-writable directories"

df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'
echo "Task 10: Set sticky bit on all world-writable directories."
echo "Ending Task 10"

##### TASK 11 ###
echo "Starting Task 11: Set AllowUsers, AllowGroups, and DenyGroups in /etc/ssh/sshd_config"

if grep -q "^Include" "$SSHD_CONFIG"; then
    sed -i '/^Include /i AllowUsers <userlist>' "$SSHD_CONFIG"
    sed -i '/^Include /i AllowGroups <grouplist>' "$SSHD_CONFIG"
    sed -i '/^Include /i DenyGroups <grouplist>' "$SSHD_CONFIG"
    echo "Task 11: Set AllowUsers, AllowGroups, and DenyGroups in $SSHD_CONFIG."
fi
echo "Ending Task 11"

##### TASK 12 ###
echo "Starting Task 12: Disable chacha20-poly1305 ciphers for SSH"

CRYPTO_POLICY="/etc/crypto-policies/policies/modules/NO-SSHCHACHA20.pmod"
printf '%s\n' "# This is a subpolicy to disable the chacha20-poly1305 ciphers" "# for the SSH protocol (libssh and OpenSSH)" "cipher@SSH = -CHACHA20-POLY1305" >> "$CRYPTO_POLICY"
update-crypto-policies
echo "Task 12: Disabled chacha20-poly1305 ciphers for SSH."
echo "Ending Task 12"

##### TASK 13 ###
echo "Starting Task 13: Set deny option in /etc/security/faillock.conf"

FAILLOCK_CONF="/etc/security/faillock.conf"
echo "deny = 5" >> "$FAILLOCK_CONF"
echo "Task 13: Set deny option in $FAILLOCK_CONF."
echo "Ending Task 13"

##### TASK 14 ###
echo "Starting Task 14: Ensure Include line appears before MACs arguments in /etc/ssh/sshd_config"

if grep -q "^MACs" "$SSHD_CONFIG"; then
    sed -i '/^MACs/ i Include /etc/ssh/sshd_config.d/*.conf' "$SSHD_CONFIG"
    echo "Task 14: Ensured Include line appears before MACs arguments in $SSHD_CONFIG."
fi
echo "Ending Task 14"

##### TASK 15 ###
echo "Starting Task 15: Set ownership and permissions on /etc/cron.d"

if command -v crond >/dev/null 2>&1; then
    chown root:root /etc/cron.d/
    chmod og-rwx /etc/cron.d/
    echo "Task 15: Set ownership and permissions on /etc/cron.d."
fi
echo "Ending Task 15"

echo "All tasks completed of Script 2."
