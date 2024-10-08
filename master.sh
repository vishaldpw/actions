#!/bin/bash

# Function to run a script and check its success
run_script() {
    local script_name=$1

    # Run the script
    ./$script_name

    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "$script_name executed successfully."

        # Sleep for 10 seconds before the next script
        echo "Sleeping for 10 seconds before proceeding..."
        sleep 10
    else
        echo "$script_name failed to execute. Skipping subsequent scripts."
        exit 1
    fi
}

# Run bash1.sh
run_script "bash1.sh"

# Run bash2.sh
run_script "bash2.sh"

# Run bash3.sh
run_script "bash3.sh"

# Run bash4.sh
### 
run_script "bash4.sh"

# Run bash5.sh
### 
run_script "bash5.sh"

# Run bash5.sh
### 
run_script "bash6.sh"

echo "All scripts executed successfully."
