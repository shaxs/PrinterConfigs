New Klipper Printer Checklist for a Modular Klipper Configuration
This guide outlines the necessary steps to add a new printer to your existing modular Klipper configuration.

Phase 1: Initial Host & Git Setup
This phase covers preparing the host computer (e.g., Raspberry Pi) and downloading your master configuration from GitHub.

Install the Operating System:

Using Raspberry Pi Imager or your favorite imaging software, choose a lightweight OS and install it to the SD card.

Recommended OS:

Raspberry Pi OS Lite (Bookworm or newer)

DietPi

Install Klipper and Dependencies:

Once the OS is installed and you can connect to the host via SSH, install Klipper, Moonraker, Mainsail, etc.

Recommended Method: Use the KIAUH (Klipper Installation And Update Helper) script. It provides a simple, menu-driven interface to install everything you need.

Restore Your Configuration from GitHub:

This process replaces the default configuration directory with your customized version from your GitHub repository. (Directions are from the following source: Eric Zimmerman's GitHub Backup Guide)

a. Connect to your printer via SSH.

b. Configure your global Git credentials:

git config --global user.email "your@email.com"
git config --global user.name "your name"

c. Generate a GitHub Access Token: Follow the official GitHub guide to generate a new Personal Access Token with repository access. This is safer than using your password.

d. Run the restore commands:

cd ~/printer_data/config
git init -b main
git remote add origin https://<YOUR_GITHUB_ACCESS_TOKEN>@github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>.git
git fetch
git reset origin/main --hard

Phase 2: Create the Printer-Specific File Structure
Next, create the necessary files and folders to keep your new printer's configuration organized.

Create a New Printer Directory:

mkdir -p ~/printer_data/config/configs/printers/trident350

Copy Service Configuration Files:

Copy moonraker.conf, KlipperScreen.conf, and crowsnest.conf from an existing printer's directory into your new directory.

Create the Main Config File:

touch ~/printer_data/config/configs/printers/trident350/trident350_config.cfg

Create the Printer-Specific Settings File:

touch ~/printer_data/config/configs/printers/trident350/trident350_settings.cfg

Action: Copy the contents of an existing settings file (like micron_settings.cfg) into this new file as a starting template.

Create New Board Alias Files:

For any new control boards, create the alias file and place it in ~/printer_data/config/configs/boards/.

Phase 3: Configure System Services for the New Paths
This step points the Klipper ecosystem to your new printer's configuration files.

Update moonraker.conf: Open the new file and change the config_path in the [update_manager] section. Review for other paths like log_path.

Update crowsnest.conf & KlipperScreen.conf: Review these files and update any log_path or other paths as needed.

Update Service Symlinks: If necessary, update the symbolic links in ~/printer_data/config/ to point to the new service configuration files.

Phase 4: Configure the Hardware (trident350_config.cfg)
This is the most critical phase, where you define all the physical components of your new printer.

Define MCUs: Set the correct serial path or canbus_uuid for each board.

Include Board Alias Files: Add [include] statements for the new boards.

Define Steppers and Axes: Use aliases for all pins and set the correct rotation_distance, microsteps, position_max, and TMC settings.

Define Extruder, Heaters, Fans, Sensors, and Lights: Configure all remaining hardware sections using the appropriate pin aliases.

Mandatory Device Names for Macros:

Chamber Light: [output_pin Chamber_Light] (white LED) or [neopixel Chamber_Light] (RGB/W LED)

Toolhead LED: [neopixel toolhead_led]

Bed Fans: [fan_generic Bed_Fans]

Skirt Fans: [fan_generic Skirt_Fans]

Phase 5: Configure the Software Profile (trident350_settings.cfg)
Customize the settings profile for the new printer.

Update Variables: Adjust all variables in the new trident350_settings.cfg file for the new hardware (e.g., parking location, nozzle brush, etc.).

Set Up Includes: In trident350_config.cfg, ensure you are including the correct new settings file and all your shared macro files.

Phase 6: Calibrate and Tune
Perform all necessary calibrations before starting a print.

Initial Checks: Verify stepper directions and endstop functionality.

PID Tuning: PID tune the hotend and heated bed.

Leveling and Z-Offset: Calibrate the probe Z-offset, run gantry leveling, and generate a new bed mesh.

Performance Tuning: Calibrate pressure advance and input shaper.
