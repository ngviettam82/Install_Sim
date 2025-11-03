@echo off
REM ========================================
REM Launch PX4 SITL in WSL
REM ========================================

echo Starting PX4 SITL...
echo.
echo Press Ctrl+C to stop the simulation
echo.

REM Run PX4 SITL in WSL
wsl -d Ubuntu-22.04 bash -c "cd ~/PX4-Autopilot && make px4_sitl none_iris"

pause
