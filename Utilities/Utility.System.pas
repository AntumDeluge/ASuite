{
Copyright (C) 2006-2021 Matteo Salvi

Website: http://www.salvadorsoftware.com/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

unit Utility.System;

{$MODE DelphiUnicode}

interface

uses
  Kernel.Consts, LCLIntf, LCLType, SysUtils, Classes, Registry, process,
  Forms, Dialogs;

{ Check functions }
function IsValidURLProtocol(const URL: string): Boolean;
function IsPathExists(const Path: String): Boolean;
function IsExecutableFile(APathFile: String): Boolean;
function CreateProcessEx(APathFile: String; AParameters: String = ''; AWorkingDir: String = '';
                         AWindowState: Integer = 1;
                         AEnvironmentVars: TStringList = nil): Integer;

{ Registry }
procedure SetASuiteAtOsStartup;
procedure DeleteASuiteAtOsStartup;
function GetAutoStartFolder: String;

{ Misc }
function ConvertWindowStateToSWOptions(AWindowState: Integer): TShowWindowOptions;
procedure EjectDialog(Sender: TObject);
function ExtractDirectoryName(const APath: string): string;

implementation

uses
  Forms.Main, Utility.Misc, Kernel.Logger,
  LazFileUtils{$IFDEF MSWINDOWS} , ShellApi, Windows {$ELSE}, IniFiles {$ENDIF}, LazUTF8,
  Utility.FileFolder, Kernel.Instance;

function IsValidURLProtocol(const URL: string): Boolean;
  {Checks if the given URL is valid per RFC1738. Returns True if valid and False
  if not.}
const
  Protocols: array[1..12] of string = (
    // Array of valid protocols - per RFC 1738
    'ftp://', 'http://', 'gopher://', 'mailto:', 'news:', 'nntp://',
    'telnet://', 'wais://', 'file://', 'prospero://', 'https://', 'steam://'
  );
var
  I: Integer;   // loops thru known protocols
begin
  // Scan array of protocols checking for a match with start of given URL
  Result := False;
  for I := Low(Protocols) to High(Protocols) do
    if Pos(Protocols[I], SysUtils.LowerCase(URL)) = 1 then
    begin
      Result := True;
      Exit;
    end;
end;

function IsPathExists(const Path: String): Boolean;
var
  PathTemp : String;
begin
  PathTemp := ASuiteInstance.Paths.RelativeToAbsolute(Path);
  Result := (PathTemp = 'shell:AppsFolder') or IsUNCPath(PathTemp) or IsValidURLProtocol(PathTemp) or FileExists(PathTemp) or SysUtils.DirectoryExists(PathTemp);
end;

function IsExecutableFile(APathFile: String): Boolean;
{$IFDEF MSWINDOWS}
var
  lowerStrPath: String;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  lowerStrPath := ExtractLowerFileExt(APathFile);
  Result := (lowerStrPath = EXT_EXE) or (lowerStrPath = EXT_BAT) or (lowerStrPath = EXT_CMD);
  {$ELSE}
  //TODO: Insert check if file has not extension or .desktop (or command file -b)
  //      https://ostoday.org/other/how-executable-files-are-identified-in-linux-and-unix.html
  Result := FileIsExecutable(APathFile);
  {$ENDIF}
end;

function CreateProcessEx(APathFile: String; AParameters: String;
  AWorkingDir: String; AWindowState: Integer;
  AEnvironmentVars: TStringList): Integer;
var
  Process: TProcess;
  I: Integer;
begin
  Result := -1;

  Process := TProcess.Create(nil);
  try
    try
      Process.Executable := APathFile;
      Process.ShowWindow := ConvertWindowStateToSWOptions(AWindowState);
      Process.StartupOptions := [suoUseShowWindow];
      Process.CurrentDirectory := AWorkingDir;
      Process.Parameters.Text := AParameters;

      //Add custom environment vars
      if Assigned(AEnvironmentVars) then
        for I := 0 to AEnvironmentVars.Count - 1 do
          Process.Environment.Add(AEnvironmentVars[I]);

      //Add actual environment vars
      for I := 0 to GetEnvironmentVariableCountUTF8 - 1 do
        Process.Environment.Add(GetEnvironmentStringUTF8(I));

      Process.Execute;

      Result := Process.ProcessID;
    except
      on E: EProcess do
      begin
        {$IFDEF MSWINDOWS}
        if not ShellExecuteW(GetDesktopWindow, nil, PChar(APathFile), PChar(AParameters),
           PChar(AWorkingDir), AWindowState) > 32 then
        {$ENDIF}
        TASuiteLogger.Exception(E);
      end;
    end;
  finally
    Process.Free;
  end;
end;

function ConvertWindowStateToSWOptions(AWindowState: Integer
  ): TShowWindowOptions;
begin
  Result := swoNone;
  case AWindowState of
    SW_SHOWDEFAULT: Result := swoShowDefault;
    SW_SHOWMINNOACTIVE: Result := swoshowMinNOActive;
    SW_SHOWMAXIMIZED: Result := swoShowMaximized;
  end;
end;

procedure EjectDialog(Sender: TObject);
{$IFDEF MSWINDOWS}
var
  WindowsPath : string;
  bShellExecute: Boolean;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}

  if not AskUserCloseApp then
    Exit;

  //Call "Safe Remove hardware" Dialog
  WindowsPath := SysUtils.GetEnvironmentVariable('WinDir');
  if FileExists(PChar(WindowsPath + '\System32\Rundll32.exe')) then
  begin
    TASuiteLogger.Info('Call Eject Dialog', []);
    bShellExecute := ShellExecuteW(0,'open',
                     PChar(WindowsPath + '\System32\Rundll32.exe'),
                     PChar('Shell32,Control_RunDLL hotplug.dll'),
                     PChar(WindowsPath + '\System32'),SW_SHOWNORMAL) > 32;
    //Error message
    if not bShellExecute then
      ShowMessageEx(Format('%s [%s]', [SysErrorMessage(GetLastOSError), 'Rundll32']), True);
  end;
  //Force close ASuite (already asked the user for confirmation with method AskUserCloseApp)
  frmMain.CloseASuite(True);
  {$ENDIF}
end;

function ExtractDirectoryName(const APath: string): string;
begin
  Result := ExtractFileName(ExcludeTrailingPathDelimiter(APath));
end;

procedure SetASuiteAtOsStartup;
var
{$IFDEF MSWINDOWS}
  Registry : TRegistry;
{$ELSE}
  AutoStartFolder: String;
  DesktopFile: TIniFile;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Registry := TRegistry.Create;
  try
    with Registry do
    begin
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',False) then
        if Not(ValueExists(APP_NAME)) then
          WriteString(APP_NAME,(Application.ExeName));
    end
  finally
    Registry.Free;
  end;

  {$ELSE}

  AutoStartFolder := GetAutoStartFolder;

  if not DirPathExists(AutoStartFolder) then
      ForceDirectory(AutoStartFolder);

  DesktopFile := TIniFile.Create(AppendPathDelim(AutoStartFolder) + APP_NAME + '.desktop', [ifoWriteStringBoolean]);
  try
    DesktopFile.WriteString(DESKTOP_GROUP, DESKTOP_KEY_TYPE, DESKTOP_TYPE_APPLICATION);
    DesktopFile.WriteString(DESKTOP_GROUP, DESKTOP_KEY_NAME, APP_NAME);
    DesktopFile.WriteString(DESKTOP_GROUP, DESKTOP_KEY_EXEC, ExpandFileName(Application.ExeName));
    DesktopFile.WriteBool(DESKTOP_GROUP, DESKTOP_KEY_STARTUPNOTIFY, False);
    DesktopFile.WriteBool(DESKTOP_GROUP, DESKTOP_KEY_TERMINAL, False);

    DesktopFile.UpdateFile;
  finally
    DesktopFile.Free;
  end;
  {$ENDIF}
end;

procedure DeleteASuiteAtOsStartup;
var
{$IFDEF MSWINDOWS}
  Registry: TRegistry;
{$ELSE}
  AutoStartFile: String;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Registry := TRegistry.Create;
  try
    with Registry do
    begin
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',False) then
        DeleteValue(APP_NAME)
    end
  finally
    Registry.Free;
  end;

  {$ELSE}
  AutoStartFile := AppendPathDelim(GetAutoStartFolder) + APP_NAME + '.desktop';

  if FileExistsUTF8(AutoStartFile) then
    DeleteFileUTF8(AutoStartFile);
  {$ENDIF}
end;

function GetAutoStartFolder: String;
begin
  Result := AppendPathDelim(GetUserDir) + '.config/autostart';
end;

end.
