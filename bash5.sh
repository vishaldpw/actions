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

