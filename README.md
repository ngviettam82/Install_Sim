# PX4 Development Environment Installation

This folder contains automated installation scripts for setting up a complete PX4 development environment on Windows.

## What Gets Installed

1. **WSL (Windows Subsystem for Linux)** - Ubuntu 22.04
2. **PX4 Autopilot** - Latest version from GitHub
3. **PX4 Dependencies** - All required build tools and libraries
4. **QGroundControl** - Ground control station software

## Quick Start

### Option 1: Complete Automated Setup

Run as **Administrator**:
```batch
setup_all.bat
```

This will install everything automatically.

### Option 2: Step-by-Step Installation

Run each script in order as **Administrator**:

1. Install WSL:
   ```batch
   install_wsl.bat
   ```
   ⚠️ **May require restart** - If first-time WSL install, restart and continue to step 2

2. Setup PX4 in WSL:
   ```batch
   setup_px4_in_wsl.bat
   ```

3. Build PX4 SITL:
   ```batch
   build_px4.bat
   ```

4. Install QGroundControl:
   ```batch
   install_qgroundcontrol.bat
   ```

## Usage

### Running PX4 SITL

From Windows:
```batch
px4s.bat
```

From WSL (inside Ubuntu):
```bash
px4s
```

This is an alias for: `cd ~/PX4-Autopilot && make px4_sitl none_iris`

### Running QGroundControl

From the project root directory:
```batch
qgc.bat
```

## Files Description

| File | Description |
|------|-------------|
| `setup_all.bat` | Master script that runs all installation steps |
| `install_wsl.bat` | Installs WSL 2 with Ubuntu 22.04 |
| `setup_px4_in_wsl.bat` | Clones PX4 and installs dependencies in WSL |
| `build_px4.bat` | Builds PX4 SITL for the first time |
| `install_qgroundcontrol.bat` | Downloads and installs QGroundControl |
| `px4s.bat` | Quick launcher for PX4 SITL |

## Requirements

- Windows 10 version 2004 or higher (Build 19041 or higher) or Windows 11
- Administrator privileges
- Internet connection
- At least 10 GB free disk space

## Troubleshooting

### WSL Installation Issues

If WSL installation fails:
1. Ensure Windows is up to date
2. Enable virtualization in BIOS
3. Run: `wsl --install` manually

### PX4 Build Errors

If PX4 build fails:
1. Open WSL: `wsl -d Ubuntu-22.04`
2. Navigate to PX4: `cd ~/PX4-Autopilot`
3. Run setup again: `bash ./Tools/setup/ubuntu.sh`
4. Try building: `make px4_sitl none_iris`

### QGroundControl Not Starting

If QGroundControl launcher doesn't work:
1. Find QGroundControl installation directory
2. Edit `qgc.bat` with correct path
3. Run QGroundControl directly from installation folder

## Manual PX4 Commands

Inside WSL, you can use these commands:

```bash
# Navigate to PX4
cd ~/PX4-Autopilot

# Build and run SITL
make px4_sitl none_iris

# Clean build
make clean
make distclean

# Update PX4
git pull
git submodule update --init --recursive
```

## Network Configuration

PX4 SITL runs on these ports:
- **UDP 14540**: MAVLink communication
- **UDP 14550**: QGroundControl default port
- **TCP 4560**: Simulator connection

Make sure these ports are not blocked by firewall.

## Additional Resources

- [PX4 Documentation](https://docs.px4.io/)
- [QGroundControl User Guide](https://docs.qgroundcontrol.com/)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)

## Support

If you encounter issues:
1. Check the error messages carefully
2. Ensure you're running as Administrator
3. Check internet connection
4. Review PX4 and WSL documentation
5. Check Windows Event Viewer for system-level errors

## Notes

- First-time PX4 build can take 10-20 minutes
- WSL installation may require a system restart
- QGroundControl can connect automatically to PX4 SITL when both are running
