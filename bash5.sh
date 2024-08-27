#!/bin/bash

echo "Starting Script 5"
# Define the subpolicy filename
PMOD_FILE="/etc/crypto-policies/policies/modules/NO-SSHCHACHA20.pmod"

# Create or append the subpolicy content to the .pmod file
printf '%s\n' \
"# This is a subpolicy to disable the chacha20-poly1305 ciphers" \
"# for the SSH protocol (libssh and OpenSSH)" \
"cipher@SSH = -CHACHA20-POLY1305" \
>> "$PMOD_FILE"

# Output a message to confirm the file was updated
echo "Updated $PMOD_FILE with the new subpolicy."

# Update the system-wide cryptographic policy
update-crypto-policies --set DEFAULT:NO-SHA1:NO-WEAKMAC:NO-SSHCBC:NO-SSHCHACHA20

# Output a message to confirm the cryptographic policy was updated
echo "System-wide cryptographic policy updated with the new subpolicy."

echo "Ensure unused filesystems kernel modules are not available"
# List of modules to unload
modules=(
    "afs"            # CVE-2022-37402
    "ceph"           # CVE-2022-0670
    "cifs"           # CVE-2022-29869
    "exfat"          # CVE-2022-29973
    "fat"            # CVE-2022-22043
    "fscache"        # CVE-2022-3630
    "fuse"           # CVE-2023-0386
    "gfs2"           # CVE-2023-3212
    "nfs_common"     # CVE-2023-6660
    "nfsd"           # CVE-2022-43945
    "smbfs_common"   # CVE-2022-2585
)

# Attempt to unload each module
for module in "${modules[@]}"; do
    if lsmod | grep -q "^$module"; then
        echo "Unloading module: $module"
        modprobe -r "$module"
        if [[ $? -eq 0 ]]; then
            echo "Successfully unloaded $module"
        else
            echo "Failed to unload $module. It might be in use or not loaded."
        fi
    else
        echo "Module $module is not currently loaded."
    fi
done

# Define the parameter and value
PARAMETER="kernel.yama.ptrace_scope"
VALUE="1"
CONF_FILE="/etc/sysctl.d/99-yama-ptrace.conf"

# Check if the parameter is already set in /etc/sysctl.conf or any .conf file in /etc/sysctl.d/
if grep -q "^$PARAMETER" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null; then
    echo "The parameter $PARAMETER is already set. Updating its value to $VALUE."
    sed -i "s/^$PARAMETER.*/$PARAMETER = $VALUE/" /etc/sysctl.conf /etc/sysctl.d/*.conf
else
    echo "The parameter $PARAMETER is not set. Adding it to $CONF_FILE."
    echo "$PARAMETER = $VALUE" | tee -a "$CONF_FILE"
fi

# Apply the changes
sysctl -p "$CONF_FILE"

# Verify the change
sysctl $PARAMETER

# Directory and file paths
CONF_DIR="/etc/security/pwquality.conf.d"
MAIN_CONF="/etc/security/pwquality.conf"

# The desired setting
SETTING="maxsequence = 3"

# Create or modify the main configuration file
if grep -q "^\s*maxsequence\s*=" "$MAIN_CONF"; then
    sed -ri 's/^\s*maxsequence\s*=.*/maxsequence = 3/' "$MAIN_CONF"
else
    echo "$SETTING" >> "$MAIN_CONF"
fi

# Create or modify a .conf file in the directory
CONF_FILE="$CONF_DIR/50-pwmaxsequence.conf"

# Ensure the directory exists
mkdir -p "$CONF_DIR"

if grep -q "^\s*maxsequence\s*=" "$CONF_FILE"; then
    sed -ri 's/^\s*maxsequence\s*=.*/maxsequence = 3/' "$CONF_FILE"
else
    echo "$SETTING" >> "$CONF_FILE"
fi

echo "Completed Script 5"
# Ensure maxsequence is set to 3 or less, but not 0
if grep -q "^\s*maxsequence\s*= 0" "$MAIN_CONF" || grep -q "^\s*maxsequence\s*= 0" "$CONF_FILE"; then
    echo "Error: maxsequence cannot be set to 0."
    exit 1
fi
