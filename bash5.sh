#!/bin/bash

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
# Replace <CRYPTO_POLICY>, <CRYPTO_SUBPOLICY1>, <CRYPTO_SUBPOLICY2>, <CRYPTO_SUBPOLICY3> with actual policy names
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
    "nfs_common"     # CVE-2023-6660 (this may refer to a component rather than a module; typically "nfs" or "nfs_common" is not a direct module)
    "nfsd"           # CVE-2022-43945
    "smbfs_common"   # CVE-2022-2585 (typically refers to the "cifs" module or a similar one)
)

# Attempt to unload each module
for module in "${modules[@]}"; do
    if lsmod | grep -q "^$module"; then
        echo "Unloading module: $module"
        modprobe -r $module
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
    sudo sed -i "s/^$PARAMETER.*/$PARAMETER = $VALUE/" /etc/sysctl.conf /etc/sysctl.d/*.conf
else
    echo "The parameter $PARAMETER is not set. Adding it to $CONF_FILE."
    echo "$PARAMETER = $VALUE" | sudo tee -a "$CONF_FILE"
fi

# Apply the changes
sudo sysctl -p "$CONF_FILE"

# Verify the change
sysctl $PARAMETER

