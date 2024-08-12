#!/bin/bash

#####  TASK 1 ### the module will enforce password history for the root user as well
# Define the line to add
line_to_add="enforce_for_root"

# Check if the line already exists in the file
if grep -q "^$line_to_add" /etc/security/pwhistory.conf; then
  echo "The line '$line_to_add' already exists in /etc/security/pwhistory.conf."
else
  # Add the line to the file
  echo "$line_to_add" | sudo tee -a /etc/security/pwhistory.conf > /dev/null
  echo "The line '$line_to_add' has been added to /etc/security/pwhistory.conf."
fi

#####  TASK 2 ## This will set inactive period for newly created users to 45
# Set the default inactive period for new users to 45 days
useradd -D -f 45

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "Default inactive period set to 45 days successfully."
else
  echo "Failed to set the default inactive period."
  exit 1
fi

#####  TASK 3  ### users cannot use last 24 passwords
# Define the line to add or update
password_history_line="remember = 24"
password_history_file="/etc/security/pwhistory.conf"

# Check if the line is already present in the file
if grep -q "^\s*remember\s*=" "$password_history_file"; then
  # If the line is present, update it
  sudo sed -i "s/^\s*remember\s*=.*/$password_history_line/" "$password_history_file"
  echo "Updated existing 'remember' setting to '$password_history_line'."
else
  # If the line is not present, add it
  echo "$password_history_line" | sudo tee -a "$password_history_file" > /dev/null
  echo "Added new 'remember' setting: '$password_history_line'."
fi

#####  TASK 4 ### Update or add the `unlock_time` setting in /etc/security/faillock.conf
echo "Updating /etc/security/faillock.conf to set unlock_time to 900 seconds..."
unlock_time_config_file="/etc/security/faillock.conf"
if grep -q "^unlock_time" "$unlock_time_config_file"; then
  sudo sed -i 's/^unlock_time\s*=.*/unlock_time = 900/' "$unlock_time_config_file"
  echo "Updated 'unlock_time' to 900 seconds."
else
  echo "unlock_time = 900" | sudo tee -a "$unlock_time_config_file" > /dev/null
  echo "Added 'unlock_time = 900' to $unlock_time_config_file."
fi

#####  TASK 5 ### Create or modify a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf to set `difok` to `2` or more
echo "Setting 'difok' to 2 in a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf..."
pwquality_dir="/etc/security/pwquality.conf.d"
pwquality_file="/etc/security/pwquality.conf"
difok_line="difok = 2"

if [ -d "$pwquality_dir" ]; then
  conf_file=$(mktemp "$pwquality_dir/tempfile.XXXXXX")
  if grep -q "^difok" "$conf_file"; then
    sudo sed -i "s/^difok\s*=.*/$difok_line/" "$conf_file"
    echo "Updated 'difok' to 2 in $conf_file."
  else
    echo "$difok_line" | sudo tee -a "$conf_file" > /dev/null
    echo "Added 'difok = 2' to $conf_file."
  fi
  sudo mv "$conf_file" "$pwquality_dir/$(basename "$conf_file" .XXXXXX).conf"
else
  if grep -q "^difok" "$pwquality_file"; then
    sudo sed -i "s/^difok\s*=.*/$difok_line/" "$pwquality_file"
    echo "Updated 'difok' to 2 in $pwquality_file."
  else
    echo "$difok_line" | sudo tee -a "$pwquality_file" > /dev/null
    echo "Added 'difok = 2' to $pwquality_file."
  fi
fi

#####  TASK 6 ### Create or modify a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf to set `maxrepeat` to `3` or less and not `0`
echo "Setting 'maxrepeat' to 3 in a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf..."
maxrepeat_line="maxrepeat = 3"

if [ -d "$pwquality_dir" ]; then
  conf_file=$(mktemp "$pwquality_dir/tempfile.XXXXXX")
  if grep -q "^maxrepeat" "$conf_file"; then
    sudo sed -i "s/^maxrepeat\s*=.*/$maxrepeat_line/" "$conf_file"
    echo "Updated 'maxrepeat' to 3 in $conf_file."
  else
    echo "$maxrepeat_line" | sudo tee -a "$conf_file" > /dev/null
    echo "Added 'maxrepeat = 3' to $conf_file."
  fi
  sudo mv "$conf_file" "$pwquality_dir/$(basename "$conf_file" .XXXXXX).conf"
else
  if grep -q "^maxrepeat" "$pwquality_file"; then
    sudo sed -i "s/^maxrepeat\s*=.*/$maxrepeat_line/" "$pwquality_file"
    echo "Updated 'maxrepeat' to 3 in $pwquality_file."
  else
    echo "$maxrepeat_line" | sudo tee -a "$pwquality_file" > /dev/null
    echo "Added 'maxrepeat = 3' to $pwquality_file."
  fi
fi

#####  TASK 7 ### Add `enforce_for_root` to a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf
echo "Adding 'enforce_for_root' to a .conf file in /etc/security/pwquality.conf.d/ or /etc/security/pwquality.conf..."
pwquality_root_file="$pwquality_dir/50-pwroot.conf"

if [ -d "$pwquality_dir" ]; then
  if grep -q "^$line_to_add" "$pwquality_root_file"; then
    echo "The line '$line_to_add' already exists in $pwquality_root_file."
  else
    echo "$line_to_add" | sudo tee -a "$pwquality_root_file" > /dev/null
    echo "Added '$line_to_add' to $pwquality_root_file."
  fi
else
  if grep -q "^$line_to_add" "$pwquality_file"; then
    echo "The line '$line_to_add' already exists in $pwquality_file."
  else
    echo "$line_to_add" | sudo tee -a "$pwquality_file" > /dev/null
    echo "Added '$line_to_add' to $pwquality_file."
  fi
fi