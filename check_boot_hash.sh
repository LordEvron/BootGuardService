#!/bin/bash

# Define variables
BOOT_DIRECTORY="/boot"  # Path to the boot directory
HASH_FILE="/var/lib/boot_partition_hashes.txt"  # Location to store the previous hash
DESKTOP_WARNING_FILE="/home/YOURUSER/Desktop/WARNING.bootTampering"  # Warning file on the user's Desktop
NEW_HASH_FILE="/tmp/current_boot_hashes.txt"  # Temporary file to store current hashes

# Generate current hashes for each file in the boot directory and save to a temporary file
find "$BOOT_DIRECTORY" -type f -exec sha256sum {} \; > "$NEW_HASH_FILE"

# Initialize a flag to track if any changes have been detected
changes_detected=false

# Check for modified or added files
while IFS= read -r line; do
    current_hash=$(echo "$line" | awk '{print $1}')
    filepath=$(echo "$line" | awk '{print $2}')

    # Extract the stored hash for this file path from the main hash file, if it exists
    stored_hash=$(grep -F "$filepath" "$HASH_FILE" 2>/dev/null | awk '{print $1}')

    if [[ -n "$stored_hash" ]]; then
        # If the file exists in the stored hashes, check for modifications
        if [[ "$current_hash" != "$stored_hash" ]]; then
            echo "WARNING: Hash mismatch detected for file: $filepath. Hash changed from $stored_hash to $current_hash"
            changes_detected=true
            echo "File modified: $filepath. Hash changed from $stored_hash to $current_hash" >> "$DESKTOP_WARNING_FILE"
        fi
    else
        # If the file is not in the stored hashes, it is a new file
        echo "WARNING: New file detected: $filepath"
        changes_detected=true
        echo "File added: $filepath" >> "$DESKTOP_WARNING_FILE"
    fi
done < "$NEW_HASH_FILE"

# Check for removed files
while IFS= read -r line; do
    stored_hash=$(echo "$line" | awk '{print $1}')
    filepath=$(echo "$line" | awk '{print $2}')

    # If the file is in the stored hashes but not in the current hashes, it was removed
    if ! grep -Fq "$filepath" "$NEW_HASH_FILE"; then
        echo "WARNING: File removed: $filepath"
        changes_detected=true
        echo "File removed: $filepath" >> "$DESKTOP_WARNING_FILE"
    fi
done < "$HASH_FILE"

# If any changes were detected, add a general warning message on the desktop
if [[ "$changes_detected" == true ]]; then
    echo "WARNING: Changes detected in the boot partition. See details above." >> "$DESKTOP_WARNING_FILE"
fi

# Update the main hash file with the current hashes for future comparisons
mv "$NEW_HASH_FILE" "$HASH_FILE"
