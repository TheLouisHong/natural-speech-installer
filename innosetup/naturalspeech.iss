#define PathRoot ".."
#define PathPiper PathRoot + "\piper"
#define PathSAPI4OUT PathRoot + "\SAPI4OUT"
#define PathWSAPI4 PathRoot + "\wsapi4_installers"

#define PathSpeechAPI PathWSAPI4 + "\speechapi4"
#define PathMSTTS PathWSAPI4 + "\microsoftsam"
#define PathTruVoice PathWSAPI4 + "\truvoice"

#define TmpSpeechAPI "{tmp}\speechapi4"
#define TmpMSTTS  "{tmp}\microsoftsam"
#define TmpTruVoice "{tmp}\truvoice"


[Setup]
AppName=Natural Speech
AppPublisher=Natural Speech RuneLite Plugin
UninstallDisplayName=Natural Speech Text-To-Speech RuneLite Plugin
AppVersion=1.3
AppSupportURL=https://github.com/phyce/rl-natural-speech
DefaultDirName={localappdata}\NaturalSpeech
DisableDirPage=yes

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline

WizardSmallImageFile=icon.bmp
SetupIconFile=icon.ico
UninstallDisplayIcon=icon.ico

Compression=lzma2
SolidCompression=yes

OutputDir=output
OutputBaseFilename=NaturalSpeechSetup

[Tasks]
Name: piperInstall; Description: "{cm:piperInstall}";
Name: sapi4Install; Description: "{cm:sapi4Install}";

[Files]
; Piper
Source: "{#PathPiper}\*"; DestDir: "{%USERPROFILE}\.runelite\NaturalSpeech\piper"; Flags: ignoreversion recursesubdirs; Tasks: piperInstall
; SAPI4
Source: "{#PathSAPI4OUT}\*"; DestDir: "{%USERPROFILE}\.runelite\NaturalSpeech\sapi4out"; Flags: ignoreversion recursesubdirs; Tasks: sapi4Install
Source: "{#PathSpeechAPI}\*"; DestDir: "{#TmpSpeechAPI}"; Tasks: sapi4Install
Source: "{#PathMSTTS}\*"; DestDir: "{#TmpMSTTS}"; Tasks: sapi4Install
Source: "{#PathTruVoice}\*"; DestDir: "{#TmpTruVoice}"; Tasks: sapi4Install
; used as a marker to call AfterInstall after files finished copying
Source: "install_wsapi4.txt"; DestDir: "{tmp}"; AfterInstall: InstallWSAPI4; Tasks: sapi4Install

[Icons]

[Messages]
WizardSelectTasks=Select Optional Voices
SelectTasksDesc=Optional Voices for Natural Speech RuneLite Plugin
SelectTasksLabel2=Select additional voices you would like to install, then click Next.

[CustomMessages]
piperInstall= Piper Text-To-Speech
sapi4Install=(Require Admin) Microsoft Text-To-Speech v4 (Voice of Gary Gilbert)


[Run]

[InstallDelete]

[UninstallDelete]

[Code]
#ifdef UNICODE
  #define AW "W"
#else
  #define AW "A"
#endif
type
  HINSTANCE = THandle;

procedure ExitProcess(uExitCode: Integer);
  external 'ExitProcess@kernel32.dll stdcall';

function ShellExecute(hwnd: HWND; lpOperation: string; lpFile: string; lpParameters: string; lpDirectory: string; nShowCmd: Integer): HINSTANCE;
  external 'ShellExecute{#AW}@shell32.dll stdcall';

function AdvPackExecute(hwnd: HWND; hInstance: HINSTANCE; pszParams: ansistring; nShowCmd: Integer): Integer;
  external 'LaunchINFSection@advpack.dll stdcall';

procedure InstallWSAPI4(); 
begin
  AdvPackExecute(0, 0, ExpandConstant('{#TmpSpeechAPI}\spchapi.inf,DefaultInstall,1'), SW_SHOW);
  AdvPackExecute(0, 0, ExpandConstant('{#TmpMSTTS}\msTTS.inf,DefaultInstall,1'), SW_SHOW);
  AdvPackExecute(0, 0, ExpandConstant('{#TmpTruVoice}\tv_enua.inf,DefaultInstall,1'), SW_SHOW);
end;

procedure UninstallWSAPI4(); 
begin
  if FileExists(ExpandConstant('{win}\INF\spchapi.inf')) then begin
    AdvPackExecute(0, 0, ExpandConstant('{win}\INF\spchapi.inf,Uninstall,1'), SW_SHOW);
  end;
  if FileExists(ExpandConstant('{win}\INF\msTTS.inf')) then begin
    AdvPackExecute(0, 0, ExpandConstant('{win}\INF\msTTS.inf,Uninstall,1'), SW_SHOW);
  end;
  if FileExists(ExpandConstant('{win}\INF\tv_enua.inf')) then begin
    AdvPackExecute(0, 0, ExpandConstant('{win}\INF\tv_enua.inf,Uninstall,1'), SW_SHOW);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Params: string;
  RetVal: HINSTANCE;
begin
  Result := True;
  if CurPageID = wpSelectTasks then begin
    if WizardIsTaskSelected('sapi4Install') and not IsAdmin() then begin
      RetVal := ShellExecute(WizardForm.Handle, 'runas', ExpandConstant('{srcexe}'), Params, '', SW_SHOW);
      ExitProcess(0);
    end
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then begin
    UninstallWSAPI4();
  end;
end;