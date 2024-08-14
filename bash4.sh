#!/usr/bin/env bash
#Run the following script to verify the active authselect profile doesn't include the `remember` argument on the `pam_unix.so` module lines:
{
 l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"
 if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
 l_pam_profile_path="/etc/authselect/$l_pam_profile"
 else
 l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
 fi
 grep -P -- '^\h*password\h+([^#\n\r]+\h+)pam_unix\.so\b' "$l_pam_profile_path"/{password,system}-auth
}

Output should be similar to:
/etc/authselect/custom/custom-profile/password-auth:password sufficient pam_unix.so sha512 shadow {if not "without-nullok":nullok} use_authtok
/etc/authselect/custom/custom-profile/system-auth:password sufficient pam_unix.so sha512 shadow {if not "without-nullok":nullok} use_authtok

- IF - any line includes `remember=`, run the following script to remove the `remember=` from the `pam_unix.so` lines in the active authselect profile `password-auth` and system-auth` templates:
#!/usr/bin/env bash
{
 l_pam_profile="$(head -1 /etc/authselect/authselect.conf)"
 if grep -Pq -- '^custom\/' <<< "$l_pam_profile"; then
 l_pam_profile_path="/etc/authselect/$l_pam_profile"
 else
 l_pam_profile_path="/usr/share/authselect/default/$l_pam_profile"
 fi
 for l_authselect_file in "$l_pam_profile_path"/password-auth "$l_pam_profile_path"/system-auth; do
 sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_unix\.so\s+.*)(remember=[1-9][0-9]*)(\s*.*)$/\1\4/g' "$l_authselect_file"
 done
}

Run the following command to update the `password-auth` and system-auth` files in `/etc/pam.d` to include pam_unix.so without the remember argument:
# authselect apply-changes