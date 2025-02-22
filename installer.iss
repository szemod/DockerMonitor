; -- installer.iss --
; Inno Setup script for DockerMonitorInstaller

[Setup]
AppName=Docker Monitor
AppVersion=1.0
AppId={code:GetAppId}
DefaultDirName={code:GetDefaultDirName}
DefaultGroupName=Docker Monitor
UninstallDisplayIcon={app}\uninstall.exe
OutputBaseFilename=DockerMonitorInstaller
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=userdocs: Inno Setup Output
UsePreviousLanguage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "web_ctop_original.py"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "templates\index.html"; DestDir: "{app}\templates"; Flags: ignoreversion
Source: "templates\login.html"; DestDir: "{app}\templates"; Flags: ignoreversion
Source: "nssm.exe"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "cmd.exe"; Parameters: "/C where python > ""{tmp}\python_path.txt"""; Flags: runhidden
Filename: "cmd.exe"; Parameters: "/C copy ""{tmp}\web_ctop_original.py"" ""{app}\web_ctop_original.py"""; Flags: runhidden; StatusMsg: "Copying to the web_ctop.py file..."
Filename: "powershell.exe"; Parameters: "-Command ""Get-Content -Path '{app}\web_ctop_original.py' | Set-Content -Path '{app}\web_ctop.py' -Encoding UTF8"""; Flags: runhidden; StatusMsg: "Resetting to UTF-8 encoding for the web_ctop.py file..."
Filename: "{app}\nssm.exe"; Parameters: "install ""{code:GetServiceName}"" ""{app}\venv\Scripts\python.exe"" ""{app}\web_ctop.py"""; WorkingDir: "{app}"; Flags: runhidden; StatusMsg: "Installing the DockerMonitor service..."
Filename: "{app}\nssm.exe"; Parameters: "start ""{code:GetServiceName}"""; Flags: runhidden; StatusMsg: "Starting the DockerMonitor service..."

[UninstallRun]
Filename: "{app}\nssm.exe"; Parameters: "stop ""{code:GetServiceName}"""; Flags: runhidden; RunOnceId: "StopDockerMonitor"
Filename: "{app}\nssm.exe"; Parameters: "remove ""{code:GetServiceName}"" confirm"; Flags: runhidden; RunOnceId: "RemoveDockerMonitor"

[Code]
var
  SSHHostPage: TInputQueryWizardPage;
  SSHUserPage: TInputQueryWizardPage;
  SSHPasswordPage: TInputQueryWizardPage;
  PortPage: TInputQueryWizardPage;  
  ServiceNamePage: TInputQueryWizardPage; 
  PythonExecutablePath: String;

procedure InitializeWizard;
begin
  ServiceNamePage := CreateInputQueryPage(wpWelcome,
    'Service Name', 'Enter the service name for Docker Monitor',
    'Please provide the name for the Windows Service (default is DockerMonitor).');
  ServiceNamePage.Add('Service Name:', False); 

  PortPage := CreateInputQueryPage(wpWelcome,
    'Docker Monitor Port', 'Enter the desired port for Docker Monitor',
    'Please provide the port on which the Docker Monitor service should run.');
  PortPage.Add('Desired Port (e.g. 5434):', False);

  SSHHostPage := CreateInputQueryPage(wpWelcome,
    'Docker SSH Connection Details', 'Enter the Docker host SSH connection details',
    'Please provide the IP address, username, and password for the Docker host SSH connection.');
  SSHHostPage.Add('SSH Host IP Address:', False);

  SSHUserPage := CreateInputQueryPage(SSHHostPage.ID,
    'SSH User', 'Enter the SSH username',
    'Please enter the username for the SSH connection.');
  SSHUserPage.Add('Username:', False);

  SSHPasswordPage := CreateInputQueryPage(SSHUserPage.ID,
    'SSH Password', 'Enter the SSH password',
    'Please enter the password for the SSH user.');
  SSHPasswordPage.Add('Password:', False);
end;

function GetPythonPath: String;  
var
  ResultCode: Integer;
  Lines: TArrayOfString;
begin
  Result := '';

  if Exec('cmd.exe', '/C where python > "' + ExpandConstant('{tmp}\python_path.txt') + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin

    if FileExists(ExpandConstant('{tmp}\python_path.txt')) then
    begin

      if LoadStringsFromFile(ExpandConstant('{tmp}\python_path.txt'), Lines) then
      begin
      
        if GetArrayLength(Lines) > 0 then
          Result := Trim(Lines[0]);
      end;
    end;
  end;

  if Result = '' then
    MsgBox('Python executable not found. Please ensure Python is installed and added to PATH.', mbError, MB_OK);
end;

function GetServiceName(Param: String): String;
begin
  Result := ServiceNamePage.Values[0];  
end;

procedure ModifyWebCtopFile(FilePath: string);
var
  Lines: TArrayOfString;
  I: Integer;
begin
  if LoadStringsFromFile(FilePath, Lines) then begin
    for I := 0 to GetArrayLength(Lines) - 1 do begin
      if Pos('SSH_PASSWORD =', Lines[I]) > 0 then
        Lines[I] := 'SSH_PASSWORD = ''' + SSHPasswordPage.Values[0] + '''';
      if Pos('SSH_HOST =', Lines[I]) > 0 then
        Lines[I] := 'SSH_HOST = ''' + SSHHostPage.Values[0] + '''';
      if Pos('SSH_USER =', Lines[I]) > 0 then
        Lines[I] := 'SSH_USER = ''' + SSHUserPage.Values[0] + '''';
      if Pos('PORT =', Lines[I]) > 0 then  
        Lines[I] := 'PORT = ' + PortPage.Values[0];
    end;
    SaveStringsToFile(FilePath, Lines, False);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then begin

    ModifyWebCtopFile(ExpandConstant('{app}\web_ctop.py'));

    PythonExecutablePath := GetPythonPath();
    if PythonExecutablePath = '' then
      Exit; 

    if not DirExists(ExpandConstant('{app}\venv')) then begin
      if Exec(PythonExecutablePath, '-m venv venv', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then begin
        if ResultCode = 0 then begin
          Exec(ExpandConstant('{app}\venv\Scripts\pip.exe'), 'install paramiko flask', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode);
          if ResultCode <> 0 then
            MsgBox('Failed to install required Python packages.', mbError, MB_OK);
        end else
          MsgBox('Failed to create Python virtual environment. Please ensure Python installation is correct.', mbError, MB_OK);
      end;
    end;

    if not Exec(ExpandConstant('{app}\nssm.exe'), 'install "' + GetServiceName('') + '" "' + ExpandConstant('{app}\venv\Scripts\python.exe') + '" "' + ExpandConstant('{app}\web_ctop.py') + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      MsgBox('Failed to install DockerMonitor service.', mbError, MB_OK);
    
    if not Exec(ExpandConstant('{app}\nssm.exe'), 'start "' + GetServiceName('') + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      MsgBox('Failed to start DockerMonitor service.', mbError, MB_OK);
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
    WizardForm.FinishedLabel.Caption := 'Please ensure the latest version of Python is installed. The DockerMonitor service is available here:  http://localhost:' + PortPage.Values[0] + '/';
end;

function GetDefaultDirName(Param: string): string;
begin
  if Assigned(ServiceNamePage) and (Trim(ServiceNamePage.Values[0]) <> '') then
    Result := 'C:\Apps\DockerMonitor_' + ServiceNamePage.Values[0]
  else
    Result := 'C:\Apps\DockerMonitor';
end;

function GetAppId(Param: string): string;
var
  svc: string;
  hash: Cardinal;
  i: Integer;
begin
  if Assigned(ServiceNamePage) and (Trim(ServiceNamePage.Values[0]) <> '') then
    svc := ServiceNamePage.Values[0]
  else
    svc := 'DockerMonitor';
  hash := 0;
  for i := 1 to Length(svc) do
    hash := (hash * 31) + Ord(svc[i]);
  Result := Format('{D0CKR%8.8x-0000-0000-0000-000000000000}', [hash]);
end;

function InitializeSetup: Boolean;
begin
  Result := True; 
end;
