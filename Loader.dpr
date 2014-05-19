library Loader;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Windows,
  Classes,
  Dialogs,
  PSAPI,
  Common in 'Common.pas',
  GetFileNameUnit in 'GetFileNameUnit.pas',
  HookLib in 'HookLib.pas';

{$R *.res}

function eadem_mutata_resurgo : BOOL; export;
begin
  Result := True;
end;

function CreateFileWH(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
    hTemplateFile: THandle): THandle; stdcall;
var
  newlpFileName : PWideChar;
begin
   newlpFileName := ChangeFileDir(lpFileName,'data\local_cn.pack','clanlong\clanlong.bin');
   Result := CreateFileW(newlpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
                       dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function CreateFileAH(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
    hTemplateFile: THandle): THandle; stdcall;
var
  newlpFileName : PChar;
  pa : string;  
begin
  newlpFileName := ChangeFileDirA(lpFileName,'data\local_cn.pack','clanlong\clanlong.bin');
  Result := CreateFileA(newlpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
                       dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function ReadFileH(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
var
  sFileName : string;
  bRet : BOOL;
begin
   bRet := ReadFile(hFile,Buffer,nNumberOfBytesToRead,lpNumberOfBytesRead,lpOverlapped);
   if bRet = True then
   begin
     sFileName := GetFileNameByHandle(hFile);
     if sFileName = 'clanlong.bin' then
     begin
      Decrypt(Buffer,nNumberOfBytesToRead);
     end;
   end;
   Result := bRet;
end;

function MapViewOfFileH(hFileMappingObject: THandle; dwDesiredAccess: DWORD;
  dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap: DWORD): Pointer; stdcall;
var
  pMem : Pointer;
  sFileName:string;
begin
  sFileName := GetFileNameByMap(hFileMappingObject);

  if sFileName = 'clanlong.bin' then
  begin
    pMem := MapViewOfFile(hFileMappingObject, FILE_MAP_COPY,dwFileOffsetHigh,dwFileOffsetLow,dwNumberOfBytesToMap);
    Decrypt(pMem^,dwNumberOfBytesToMap);
  end
  else
    pMem := MapViewOfFile(hFileMappingObject, dwDesiredAccess,dwFileOffsetHigh,dwFileOffsetLow,dwNumberOfBytesToMap);

  Result := pMem;
end;

function MapViewOfFileExH(hFileMappingObject: THandle; dwDesiredAccess: DWORD; dwFileOffsetHigh: DWORD; dwFileOffsetLow: DWORD;
   dwNumberOfBytesToMap: DWORD; lpBaseAddress: pointer): pointer;stdcall;
var
  pMem : Pointer;
  sFileName:string;
begin
  sFileName := GetFileNameByMap(hFileMappingObject);

  if sFileName = 'clanlong.bin' then
  begin
    pMem := MapViewOfFileEx(hFileMappingObject, FILE_MAP_COPY,dwFileOffsetHigh,dwFileOffsetLow,dwNumberOfBytesToMap,lpBaseAddress);
    Decrypt(pMem^,dwNumberOfBytesToMap);
  end
  else
    pMem := MapViewOfFileEx(hFileMappingObject, dwDesiredAccess,dwFileOffsetHigh,dwFileOffsetLow,dwNumberOfBytesToMap,lpBaseAddress);
    
  Result := pMem;
end;


exports
  eadem_mutata_resurgo;

begin
    HookApi('Rome2.dll','Kernel32.dll','CreateFileW',@CreateFileWH);
    HookApi('Rome2.dll','Kernel32.dll','CreateFileA',@CreateFileAH);
    HookApi('Rome2.dll','Kernel32.dll','ReadFile',@ReadFileH);
    HookApi('Rome2.dll','Kernel32.dll','MapViewOfFile',@MapViewOfFileH);
    HookApi('Rome2.dll','Kernel32.dll','MapViewOfFileEx',@MapViewOfFileExH);
end.
