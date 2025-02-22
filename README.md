# Docker Monitor

Docker Monitor is a lightweight Python-based web application that provides real-time monitoring of Docker container resource usage through a web dashboard. Inspired by the command-line tool ctop, it displays essential metrics such as CPU, memory, network I/O, and container status (running, paused, stopped) while also allowing basic container management actions.

You can access the monitoring dashboard remotely via `http://localhost:PORT`, where `PORT` is the port number you specified during installation.

Use the name and password you provided during installation to log in, which should match the SSH host login name/password.
![image](https://github.com/user-attachments/assets/8aa38cbd-881b-4182-943f-7b6e192dac4d)

![image](https://github.com/user-attachments/assets/d9ec264b-7c1c-42b8-9404-805a10c1267a)

## Features

- **Real-Time Monitoring:**
  - Retrieves and displays live data for Docker containers, including:
    - CPU usage
    - Memory usage (with progress bars)
    - Network traffic
    - I/O statistics
- **Container Status & Management:**
  - Shows the status of each container (running, paused, stopped) and provides actions for managing containers (start, stop, restart, pause, resume) through a context menu.
- **Remote Docker Host Access:**
  - Uses SSH (via Paramiko) to connect to a Docker host and execute commands for fetching container statistics.
- **Multiple Instance Support:**
  - The installer dynamically sets the service name and installation directory based on user input, allowing for multiple instances without conflicts.
- **Simple & Responsive UI:**
  - A minimal web interface built with HTML/CSS for easy monitoring.

## Getting Started

### Prerequisites

- **Python:** Ensure Python is installed and added to your system's PATH.
- **Docker Host:** Access to a Docker host (local or remote) with SSH privileges to run Docker commands.
- **Inno Setup** (Optional): Required only if you plan to rebuild/modify the installer.

### Installation Steps

1. **Run the Installer:**
   - Execute the generated `DockerMonitorInstaller.exe`.

2. **Provide Configuration Details:**
   - During the installation wizard, you will be prompted for:
     - **Service Name:** Enter a name for the Windows service (default is `DockerMonitor`).
     - **Docker Monitor Port:** Specify the port for the web dashboard (default is `5434`).
     - **SSH Details:** Provide the SSH host IP, username, and password for connecting to the Docker host.

3. **Installation Process:**
   - The installer copies the application files (`web_ctop_original.py`, `templates/index.html` and `templates/login.html`) to the selected directory.
   - It creates a Python virtual environment and automatically installs the required packages (`Flask` and `Paramiko`).
   - Ensures the Python file is properly encoded (UTF-8) for execution.
   - Configuration settings are modified based on the provided inputs, and the application is registered as a Windows service using `nssm.exe`.

### Accessing the Dashboard

- After installation, the service will start automatically. Open your web browser and navigate to `http://localhost:PORT`, replacing `PORT` with the port number you specified during installation.

### Repository Structure

- `web_ctop_original.py`: The main Python script that retrieves Docker container statistics and serves the web dashboard.
- `templates/index.html`: The HTML template for the web interface, styled for a minimal and responsive design.
- `templates/login.html`: The HTML template for the login window, styled for a minimal and responsive design.
- `installer.iss`: The Inno Setup script used to generate the Windows installer, configuring service name, installation directory, SSH settings, and port.
- `nssm.exe`: The executable used to manage the Windows service.

### Customization

- **SSH Configuration:** Default SSH credentials in `web_ctop_original.py` are overridden during installation with your provided values.
- **Port Setting:** Configurable via the installer.

## License

- MIT License 

## Acknowledgements

- **Flask:** Used as the web framework for building the dashboard.
- **Paramiko:** Enables SSH connectivity to the Docker host.
- **NSSM:** Used for managing the Docker Monitor service on Windows.
- Inspired by the functionality of ctop for real-time Docker monitoring.


