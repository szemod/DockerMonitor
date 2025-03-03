# DockerMonitor-WindowsVersion
A Docker host monitoring tool that runs in its own Docker container and can monitor both local and remote Docker hosts.

Docker Monitor is a lightweight Python-based web application that provides real-time monitoring of Docker container resource usage through a web dashboard. Inspired by the command-line tool `ctop`, it displays essential metrics such as CPU, memory, network I/O, and container status (running, paused, stopped) while also allowing basic container management actions.

You can access the monitoring dashboard locally or remotely (locally via `http://localhost:PORT`), where `PORT` is the port number specified during windows installation (default is 5434).

Use the SSH credentials you provide during setup to log in, which should match the SSH host login details.

![image](https://github.com/user-attachments/assets/7eaa0519-bdac-493c-a52e-f742d0ca1de7) ![image](https://github.com/user-attachments/assets/85377c1e-b3b3-4d18-a43d-cfc61aaf7865)

![image](https://github.com/user-attachments/assets/85a1c198-86ea-455a-a589-45196c799a2a)

## The Goal of the Project

- **Real-Time Visibility:**  
  Provide a lightweight dashboard that shows the resource usage of all running or filtered Docker containers on a single screen. This makes it easy to identify containers with excessive or abnormal resource consumption, which could impact overall performance.
- **Basic Container Management:**  
  Allow for simple intervention actions, such as stopping, restarting, or pausing containers, directly from the dashboard.

## Features

- **Simple & Responsive UI:**  
  - A minimal, clean interface built with HTML/CSS for straightforward monitoring,
  - Built as a progressive web application (PWA) for a complete experience on both mobile and desktop. (In mobile view on iOS, simply use the Shortcuts app for full-screen display as shown in the screenshots below.)
    
![image](https://github.com/user-attachments/assets/35982a9a-1ca2-4f73-9237-a53bbdac4900) ![image](https://github.com/user-attachments/assets/e30c6542-c78e-461e-8a60-2f600c6056ae)

- **Real-Time Monitoring:**  
  - Displays live data for Docker containers including CPU usage, memory usage (with progress bars), network traffic, and I/O statistics.

- **Container Status & Management:**  
  - Shows the status of each container (running, paused, stopped) and provides a context menu to perform actions (start, stop, restart, pause, resume).

- **Inspect Container Logs:**  
  - Offers a simple view of container logs that update periodically, making it easier to monitor log entries and errors.  
  ![Logs Screenshot](https://github.com/user-attachments/assets/87ae79f6-e6af-4cdc-a6a4-e15c0110fec0)

- **Filtering and Sorting:**  
  - Click on the "NAME" header to filter containers by name.
  - Click on "CPU" or "MEM" headers to sort containers by resource usage.  
  ![image](https://github.com/user-attachments/assets/24756c80-7cd9-44ec-9b32-76dcfe242c3b)
  ![image](https://github.com/user-attachments/assets/d20c9fb5-8493-4c7f-b14e-f94073b7a481)

- **Remote Docker Host Access & Statistics:**  
  - Connects via SSH (using Paramiko) to a Docker host to retrieve container statistics.
  - Utilizes CHART.JS for real-time and short-term historical data visualization.  
  ![Charts Screenshot](https://github.com/user-attachments/assets/dd745752-cd1c-46df-bb1d-1e46e884f109)

- **Multiple Instance Support:**  
  - Easily update the SSH settings to monitor different Docker hosts without conflicts.

- **Auto Logout & Dark/Light Mode:**  
  - Login page options allow for auto logout and switching between dark and light themes.

- **Production-Ready Deployment:**  
  - Runs with Gunicorn as the production WSGI server to ensure better performance and reliability.

## Getting Started

### Prerequisites

- **Operation System:** Installer designed for Windows 10 / Windows Server 2012 R2 or newer. It will also run on Linux distros with manual installation.
- **Python:** Ensure Python is installed and added to your system's PATH.
- **Docker Host:** Access to a Docker host (local or remote) with SSH & SUDO privileges to run Docker commands.
- **Inno Setup** (Optional): Required only if you plan to rebuild/modify the installer.

### Installation

### Installation Steps (on Windows systems)

1. **Run the Installer:**
   - Execute the generated `DockerMonitorInstaller.exe`.

2. **Provide Configuration Details:**
   - During the installation wizard, you will be prompted for:
     - **Service Name:** Enter a name for the Windows service (default is `DockerMonitor`).
     - **Docker Monitor Port:** Specify the port for the web dashboard (default is `5434`).

3. **Installation Process:**
   - The installer copies the application files to the selected directory.
   - It creates a Python virtual environment and automatically installs the required packages (`Flask` and `Paramiko`).
   - Ensures the Python file is properly encoded (UTF-8) for execution.
   - Configuration settings are modified based on the provided inputs, and the application is registered as a Windows service using `nssm.exe`.

4. **SSH Setup:**
   - DockerMonitor will be available at [http://localhost:5434/](http://localhost:5434/).
   - On the first launch, you will be directed to the SSH setup page.
   - Multiple hosts can be added, which can easily be selected later in the login window.

5. **Configure SSH Settings:**
   - The last used Docker/SSH host is selected by default, but you can change it by selecting a different host on the login page.
   - The setup page will prompt you for your SSH Host, SSH Username, and SSH Password.
   - Save the settings to configure the connection to your Docker host.
   - After a successful setup, you will be redirected to the login page.

6. **Login to the Dashboard:**
   - Use the SSH Username and SSH Password provided during setup to log in. 
   - Once authenticated, you can access real-time Docker container statistics via the web dashboard.
   - On the Login page, you can change the SSH Host, SSH Username, and SSH Password at any time, and you can connect to any HOST of your choice.
   
## Repository Structure

- **web_ctop_original.py**: Main Python script that retrieves Docker container statistics and serves the web dashboard.
- **config_original.py**: Configuration file where SSH credentials and port settings are stored.
- **templates/index.html**: HTML template for the desktop interface.
- **templates/login.html**: HTML template for the login page.
- **templates/setup.html**: HTML template for the SSH setup page.
- **templates/mobile.html**: HTML template for the mobile interface.
- **templates/service-worker.js**: Java script part for PWA.
- **templates/manifest.json**: Jason file for PWA.
- **templates/favicon.icon**: Icon file
- **templates/favicon.png**: Icon file

## Customization

### SSH Configuration

The default SSH credentials are stored in `config.py` and can be updated via the setup page.

### Port Setting

The application listens on port 5434 by default; modify the `PORT` variable in `config.py` to change this.

## License

This project is licensed under the MIT License.

## Acknowledgements

- **Flask**: Web framework for building the dashboard.
- **Paramiko**: Provides SSH connectivity to the Docker host.
- **Gunicorn**: Production-ready WSGI server used for deployment.
- **CHART.JS**: Used for real-time charting of container statistics.
- **Docker**: Containerization platform that powers this solution.
- Inspired by the functionality of ctop for real-time Docker monitoring.

## Future Developments

- Encrypted password management for enhanced security.
- Enhanced logging and alerting features.






