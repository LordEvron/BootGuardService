# Boot Partition Integrity Checker

This project monitors the integrity of the boot partition by hashing all files and detecting any changes (modifications, additions, or deletions). If changes are detected, a warning file is created on the user's desktop, listing the affected files.

## Features

- Scans all files in the boot partition.
- Detects changes in file hashes, including modifications, additions, and deletions.
- Creates a `WARNING.bootTampering` file on the desktop **only** if changes are detected.
- Uses a single hash file to store all file hashes for efficient monitoring.
- Automatically runs at system startup via a `systemd` service.

---

## Setup Instructions

### Step 1: Install the Script

1. Copy the script to `/usr/local/bin`:
    ```bash
    sudo cp check_boot_hash.sh /usr/local/bin/
    ```
2. Make the script executable:
    ```bash
    sudo chmod +x /usr/local/bin/check_boot_hash.sh
    ```

---

### Step 2: Configure `systemd` Service

1. Create a new `systemd` service file:
    ```bash
    sudo nano /etc/systemd/system/check_boot_hash.service
    ```
2. Add the following content to the file:

    ```ini
    [Unit]
    Description=Check Boot Partition Hash at Startup
    After=graphical.target

    [Service]
    Type=oneshot
    ExecStart=/usr/local/bin/check_boot_hash.sh

    [Install]
    WantedBy=default.target
    ```

3. Save and exit the file.

4. Reload the `systemd` daemon to recognize the new service:
    ```bash
    sudo systemctl daemon-reload
    ```

5. Enable the service to run at startup:
    ```bash
    sudo systemctl enable check_boot_hash.service
    ```

---

### Step 3: Test the Script

You can manually test the script and the service without restarting the system:

1. Run the script directly to verify functionality:
    ```bash
    sudo /usr/local/bin/check_boot_hash.sh
    ```

2. Start the service manually to ensure it works as intended:
    ```bash
    sudo systemctl start check_boot_hash.service
    ```

3. Check the status of the service:
    ```bash
    sudo systemctl status check_boot_hash.service
    ```

---

### Script Explanation

- **Hash Storage**:
    - All file hashes are stored in a single file, typically `/var/lib/boot_partition_hashes.txt`.
    - Each entry in the file contains the hash and path for a file in the boot partition.

- **Conditional Creation of `DESKTOP_WARNING_FILE`**:
    - The `DESKTOP_WARNING_FILE` will only be created if there is a detected change. Any `echo` command writing to the file will automatically create it if it does not already exist.

- **Setting `changes_detected`**:
    - If any changes are detected (modification, addition, or deletion), `changes_detected` is set to `true`, and the appropriate line is written to `DESKTOP_WARNING_FILE`.

- **Appending the General Warning**:
    - After looping through all comparisons, if `changes_detected` is `true`, the general warning message is appended to `DESKTOP_WARNING_FILE`.

This setup ensures that `DESKTOP_WARNING_FILE` is created **only** when there are actual changes to report.

---

## Maintenance

- **Updating the Script**:
    To modify the script, edit `/usr/local/bin/check_boot_hash.sh` and ensure it remains executable:
    ```bash
    sudo chmod +x /usr/local/bin/check_boot_hash.sh
    ```

- **Restarting the Service**:
    To apply changes to the script, restart the service:
    ```bash
    sudo systemctl restart check_boot_hash.service
    ```

- **Disabling the Service**:
    If you no longer need the service, disable it:
    ```bash
    sudo systemctl disable check_boot_hash.service
    ```

---

## License

This project is open-source and free to use. Modify and adapt as needed for your requirements.