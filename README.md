Docker Monitor
Docker Monitor is a lightweight Python-based web application that provides real-time monitoring of Docker container resource usage through a web dashboard. Inspired by the command-line tool ctop, it displays essential metrics such as CPU, memory, network I/O, and container status (running, paused, stopped) while also allowing basic container management actions.
Use the name and password you provided during installation to log in, which should match the SSH host login name/password.
![image](https://github.com/user-attachments/assets/8aa38cbd-881b-4182-943f-7b6e192dac4d)
![image](https://github.com/user-attachments/assets/d9ec264b-7c1c-42b8-9404-805a10c1267a)

Features
Real-Time Monitoring:
Retrieves and displays live data for Docker containers including CPU usage, memory usage (with progress bars), network traffic, and I/O statistics.

Container Status & Management:
Shows the status of each container (running, paused, stopped) and provides a context menu for actions such as start, stop, restart, pause, and resume.

Remote Docker Host Access:
Uses SSH (via Paramiko) to connect to a Docker host, execute commands, and fetch container statistics.

Multiple Instance Support:
The installer dynamically sets the service name and installation directory based on user input. This allows you to install multiple instances (on different ports) without conflicts.

Simple & Responsive UI:
A minimal web interface built with HTML/CSS for easy monitoring.

Installation:
The project comes with an Inno Setup script (installer.iss) that creates a Windows installer for Docker Monitor, installing it as a Windows service.

Prerequisites:
Python:
Make sure Python is installed and added to your system PATH.

Docker Host:
Access to a Docker host (local or remote) with an SSH account that has privileges to run Docker commands.

Inno Setup:
(Optional – only if you plan to rebuild the installer) Inno Setup is required for compiling the installer.

Steps
Run the Installer:

Execute the generated DockerMonitorInstaller.exe.
Provide Configuration Details:

During the installation wizard, you will be prompted for:

Service Name:
Enter the name for the Windows service (e.g., DockerMonitor). This name is used to uniquely identify the service, allowing you to install multiple instances if desired.

Docker Monitor Port:
Specify the port on which the web dashboard should run (e.g., 5434).

SSH Details:
Provide the SSH host IP, username, and password for connecting to the Docker host. These details are used to fetch container statistics via Docker commands.

Installation Process:

The installer copies the application files (web_ctop_original.py and templates/index.html) to the selected installation directory.
It creates a Python virtual environment and automatically installs the required Python packages (Flask and Paramiko).
The application configuration file is modified based on the provided SSH and port settings.
Using nssm.exe (Non-Sucking Service Manager), the installer registers and starts Docker Monitor as a Windows service.
Access the Dashboard:

Once installation is complete, the service will start automatically. Open your web browser and navigate to:
http://localhost:port/
Replace <port> with the port you specified during installation.

Repository Structure:
web_ctop_original.py
The main Python script that retrieves Docker container statistics and serves the web dashboard.

templates/index.html
The HTML template for the web interface, styled with CSS for a minimal and responsive design.

installer.iss
The Inno Setup script used to generate the Windows installer, which configures the service name, installation directory, SSH settings, and port.

nssm.exe
The executable used to manage the Windows service.

Customization:
SSH Configuration:
The default SSH credentials in web_ctop_original.py are overridden during installation based on the values you provide.

Port Setting:
The port on which Docker Monitor runs is also configurable via the installer.

License
(MIT License.)

Acknowledgements:
Flask: Used as the web framework for building the dashboard.
Paramiko: Enables SSH connectivity to the Docker host.
NSSM: Used for managing the Docker Monitor service on Windows.
Inspired by the functionality of ctop for real-time Docker monitoring.

