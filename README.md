# New Klipper Printer Checklist for a Modular Klipper Configuration

This guide outlines the necessary steps to add a new printer to your existing modular Klipper configuration.

### **Phase 1: Initial Host & Git Setup**

*This phase covers preparing the host computer (e.g., Raspberry Pi) and downloading your master configuration from GitHub.*

1. **Install the Operating System:**
  
  - Using Raspberry Pi Imager or your favorite imaging software, choose a lightweight OS and install it to the SD card.
    
  - **Recommended OS:**
    
    - Raspberry Pi OS Lite (Bookworm or newer)
      
    - DietPi
      
2. **Install Klipper and Dependencies:**
  
  - Once the OS is installed and you can connect to the host via SSH, install Klipper, Moonraker, Mainsail, etc.
    
  - **Recommended Method:** Use the **KIAUH** (Klipper Installation And Update Helper) script. It provides a simple, menu-driven interface to install everything you need.
    
3. **Install and Configure Cartographer:**
  
  - If your new printer uses the Cartographer probe, it needs to be installed separately.
    
  - **a. Connect to your printer** via SSH and run the following commands to install the necessary software:
    
    ```
    cd ~
    git clone https://github.com/Cartographer3D/cartographer-klipper.git
    ./cartographer-klipper/install.sh
    ```
    
  - **b. Add the update manager section to `moonraker.conf`:** This allows Mainsail to manage updates for Cartographer.
    
    ```
    [update_manager cartographer]
    type: git_repo
    path: ~/cartographer-klipper
    channel: stable
    origin: https://github.com/Cartographer3D/cartographer-klipper.git
    is_system_service: False
    managed_services: klipper
    info_tags:
     desc=Cartographer Probe
    ```
    
  - **c. Configure Cartographer in Klipper:** Follow the official documentation to add the required sections to your main hardware config file.
    
    - **Link:** [Cartographer Klipper Configuration Guide](https://docs.cartographer3d.com/cartographer-probe/installation-and-setup/installation/klipper-configuation "null")
4. **Restore Your Configuration from GitHub:**
  
  - This process replaces the default configuration directory with your customized version from your GitHub repository. (Directions are from the following source: [Eric Zimmerman's GitHub Backup Guide](https://github.com/EricZimmerman/Voron-Documentation/blob/main/community/howto/EricZimmerman/BackupConfigToGithub.md "null"))
    
  - **a. Connect to your printer** via SSH.
    
  - **b. Configure your global Git credentials:**
    
    ```
    git config --global user.email "your@email.com"
    git config --global user.name "your name"
    ```
    
  - **c. Generate a GitHub Access Token:** Follow the official GitHub guide to generate a new Personal Access Token with repository access. This is safer than using your password.
    
  - **d. Run the restore commands:**
    
    ```
    cd ~/printer_data/config
    git init -b main
    git remote add origin https://<YOUR_GITHUB_ACCESS_TOKEN>@github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>.git
    git fetch
    git reset origin/main --hard
    ```
    

### **Phase 2: Create the Printer-Specific File Structure**

*Next, create the necessary files and folders to keep your new printer's configuration organized.*

1. **Create the Main `printer.cfg` in the Root Directory:**
  
  - This file will now act as the master "switch" that points to your active printer's configuration.
    
  - **Action:** Create a file named `printer.cfg` in the `~/printer_data/config/` directory.
    
  - The *entire content* of this file should be a single `[include]` line pointing to the new printer's hardware config file:
    
    ```
    # This file selects the active printer.
    [include trident350_config.cfg]
    ```
    
2. **Create the Printer-Specific Hardware File (in Root):**
  
  - Create the main hardware config file in the `~/printer_data/config/` directory.
    
    - `touch ~/printer_data/config/trident350_config.cfg`
3. **Create the Printer-Specific Settings File (in Subdirectory):**
  
  - Create a new directory for your printer's settings:
    
    - `mkdir -p ~/printer_data/config/configs/printers/trident350`
  - Create the settings file inside the new directory:
    
    - `touch ~/printer_data/config/configs/printers/trident350/trident350_settings.cfg`
  - **Action:** Copy the contents of an existing settings file (like `micron_settings.cfg`) into this new settings file as a starting template.
    
4. **Create New Board Alias Files:**
  
  - For any new control boards, create the alias file and place it in `~/printer_data/config/configs/boards/`.

### **Phase 3: Configure System Services for the New Paths**

*This step points the Klipper ecosystem to your new printer's configuration files.*

1. **Moonraker:**
  
  - Stop the moonraker service:
    
    ```
    sudo systemctl stop moonraker
    ```
    
  - Copy the `moonraker.conf` from another printer's directory to your new printer's directory:
    
    ```
    cp ~/printer_data/config/configs/printers/micron/moonraker.conf ~/printer_data/config/configs/printers/trident350/
    ```
    
  - Update the Symbolic Link to point to the new file. The `-f` flag will force overwrite the existing link.
    
    ```
    ln -sf ~/printer_data/config/configs/printers/trident350/moonraker.conf ~/printer_data/config/moonraker.conf
    ```
    
  - Restart the service:
    
    ```
    sudo systemctl start moonraker
    ```
    
2. **KlipperScreen:**
  
  - Stop the KlipperScreen service:
    
    ```
    sudo systemctl stop KlipperScreen
    ```
    
  - Copy the `KlipperScreen.conf` to your new printer's directory:
    
    ```
    cp ~/printer_data/config/configs/printers/micron/KlipperScreen.conf ~/printer_data/config/configs/printers/trident350/
    ```
    
  - Update the Symbolic Link:
    
    ```
    ln -sf ~/printer_data/config/configs/printers/trident350/KlipperScreen.conf ~/printer_data/config/KlipperScreen.conf
    ```
    
  - Restart the service:
    
    ```
    sudo systemctl start KlipperScreen
    ```
    
3. **Crowsnest (for webcams):**
  
  - Stop the Crowsnest service:
    
    ```
    sudo systemctl stop crowsnest
    ```
    
  - Copy the `crowsnest.conf` to your new printer's directory:
    
    ```
    cp ~/printer_data/config/configs/printers/micron/crowsnest.conf ~/printer_data/config/configs/printers/trident350/
    ```
    
  - Update the Symbolic Link:
    
    ```
    ln -sf ~/printer_data/config/configs/printers/trident350/crowsnest.conf ~/printer_data/config/crowsnest.conf
    ```
    
  - Restart the service:
    
    ```
    sudo systemctl start crowsnest
    ```
    

### **Phase 4: Configure the Hardware (`trident350_config.cfg`)**

*This is the most critical phase, where you define all the physical components of your new printer.*

1. **Define MCUs:** Set the correct `serial` path or `canbus_uuid` for each board.
  
2. **Include Board Alias Files:** Add `[include]` statements for the new boards.
  
3. **Define Steppers and Axes:** Use aliases for all pins and set the correct `rotation_distance`, `microsteps`, `position_max`, and TMC settings.
  
4. **Define Extruder, Heaters, Fans, Sensors, and Lights:** Configure all remaining hardware sections using the appropriate pin aliases.
  
5. **Mandatory Device Names for Macros:**
  
  - Chamber Light: `[output_pin Chamber_Light]` (white LED) or `[neopixel Chamber_Light]` (RGB/W LED)
    
  - Toolhead LED: `[neopixel Toolhead_Led]`
    
  - Bed Fans: `[fan_generic Bed_Fans]`
    
  - Skirt Fans: `[fan_generic Skirt_Fans]`
    

### **Phase 5: Configure the Software Profile (`trident350_settings.cfg`)**

*Customize the settings profile for the new printer.*

1. **Update Variables:** Adjust all variables in the new `trident350_settings.cfg` file for the new hardware (e.g., parking location, nozzle brush, etc.).
  
2. **Set Up Includes:** In `trident350_config.cfg`, ensure you are including the correct new settings file (`[include configs/printers/trident350/trident350_settings.cfg]`) and all your shared macro files.
  

### **Phase 6: Calibrate and Tune**

*Perform all necessary calibrations before starting a print.*

1. **Initial Checks:** Verify stepper directions and endstop functionality.
  
2. **PID Tuning:** PID tune the hotend and heated bed.
  
3. **Leveling and Z-Offset:** Calibrate the probe Z-offset, run gantry leveling, and generate a new bed mesh.
  
4. **Performance Tuning:** Calibrate pressure advance and input shaper.
