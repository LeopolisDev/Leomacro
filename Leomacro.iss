#define MyAppName "Leomacro"
#define MyAppVersion "1.0.7"
#define MyAppExeName "Leomacro.exe"

[Setup]
AppId={{B1A73B6E-1111-4444-8888-123456789ABC}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=dist
OutputBaseFilename=Leomacro_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=TDS_Macro\icon.ico

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Files]
Source: "release\Leomacro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\Resources\*"; DestDir: "{app}\Resources"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "release\lib\*"; DestDir: "{app}\lib"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "release\submacros\*"; DestDir: "{app}\submacros"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "release\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
