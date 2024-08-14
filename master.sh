#!/bin/bash

# Run bash1.sh
./bash1.sh

# Check if bash1.sh executed successfully
if [ $? -eq 0 ]; then
    echo "bash1.sh executed successfully."

    # Sleep for 30 seconds
    echo "Sleeping for 30 seconds before running bash2.sh..."
    sleep 30

    # Run bash2.sh
    ./bash2.sh

    # Check if bash2.sh executed successfully
    if [ $? -eq 0 ]; then
        echo "bash2.sh executed successfully."
    else
        echo "bash2.sh failed to execute."
    fi

else
    echo "bash1.sh failed to execute. Skipping bash2.sh."
fi

