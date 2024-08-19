#!/usr/bin/env bash

echo "Starting Script 4"

# Get the current authselect profile
l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"

# Determine the path of the authselect profile
if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
    l_pam_profile_path="/etc/authselect/$l_pam_profile"
else
    l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
fi

# Search for pam_unix.so lines in the authselect profile files and check for 'remember=' argument
grep_output=$(grep -P -- '^\s*password\s+([^#\n\r]+\s+)pam_unix\.so\b' "$l_pam_profile_path"/{password,system}-auth)
echo "$grep_output"

# If any line contains 'remember=', remove it
if echo "$grep_output" | grep -q 'remember='; then
    for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)(remember=[1-9][0-9]*)(\s*.*)$/\1\4/g' "$l_authselect_file"
    done

    # Apply the changes to update the files in /etc/pam.d
    authselect apply-changes
fi

echo "Ending Script 4"
