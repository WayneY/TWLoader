unit HookLib;

interface
uses
  Windows;

  function ChangeFileDir(FileName : PWideChar; StrToReplace :string; Replacement : string) : PWideChar;
  function ChangeFileDirA(FileName : PAnsiChar; StrToReplace :string; Replacement : string) : PAnsiChar;
  function GetFileNameByHandle(hFile:THandle):String;
  function GetFileNameByMap(hFileMappingObject: THandle):String;
  procedure Decrypt(var Buffer; ByteToRead: DWORD);
  procedure HOOKAPI(HandleModel: PChar; lpModuleName : PChar; lpApiName : PChar; pCallbackFunc : Pointer);
implementation

uses
  SysUtils,
  PSAPI,
  Dialogs,
  uDecodeinGame;


type
  PIMAGE_IMPORT_DESCRIPTOR = ^IMAGE_IMPORT_DESCRIPTOR;
  IMAGE_IMPORT_DESCRIPTOR = record
    OriginalFirstThunk : DWORD;
    TimeDateStamp : DWORD;
    ForwarderChain : DWORD;
    Name : DWORD;
    FirstThunk : DWORD;
end;

function ChangeFileDir(FileName : PWideChar; StrToReplace :string; Replacement : string) : PWideChar;
var
 FullPath : string;
begin
 FullPath := WideCharToString(FileName);
 if Pos(strToReplace, FullPath) >0 then
 begin
    FullPath := StringReplace(FullPath, strToReplace, Replacement, []);
    GetMem(FileName, (Length(FullPath)+1)*SizeOf(WideChar));
    StringToWideChar(FullPath, FileName, length(FullPath)+1);
 end;
 Result := FileName;
end;

function ChangeFileDirA(FileName : PAnsiChar; StrToReplace :string; Replacement : string) : PAnsiChar;
var
 FullPath : string;
begin
 FullPath := FileName;
 if Pos(strToReplace, FullPath) >0 then
 begin
    FullPath := StringReplace(FullPath, strToReplace, Replacement, []);
   // FileName := PAnsiChar(FullPath);
   FileName := Addr(FullPath[1]);
 end;
 Result := FileName;
end;

function GetFileNameByHandle(hFile:THandle):String;
var
  hFileMap:Cardinal;
begin
  Result := '';
  try
    hFileMap := CreateFileMapping(hFile,nil, PAGE_READONLY,0,0,nil);
    if hFileMap<>0 then
    begin
      Result :=GetFileNameByMap(hFileMap);
    end
    else
      exit;
  finally
    CloseHandle(hFileMap);
  end;
end;

function GetFileNameByMap(hFileMappingObject: THandle):String;
var
  pMem:Pointer;
  FilePath:array [0..MAX_PATH-1] of Char;
  sFilePath :string;
  sFileName:string;
begin
  Result := '';
  try
    pMem := MapViewOfFile(hFileMappingObject, FILE_MAP_READ,0,0,1);
      if pMem <> nil then
      begin
        if GetMappedFileName(GetCurrentProcess(),pMem,@FilePath,SizeOf(FilePath))<>0 then
        begin
          sFilePath := StrPas(FilePath);
          sFileName := ExtractFileName(sFilePath);
          Result := sFileName;
        end
        else
          exit;
      end
      else
        exit;
  finally
    UnMapViewOfFile(pMem);
  end;
end;

procedure Decrypt(var Buffer; ByteToRead: DWORD);
begin
  DecodeRecvInGame(DWORD(@Buffer),ByteToRead);
  
end;

procedure HOOKAPI(HandleModel: PChar; lpModuleName : PChar; lpApiName : PChar; pCallbackFunc : Pointer);
var
  pImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
  pNtHdr : PImageNtHeaders;
  dwModuleBase : DWORD;
  pDosHdr : PImageDosHeader;
  pCode: ^Pointer;
  pProtoFill : Pointer;
  dwLoaded : DWORD;
  dwPeOffset : DWORD;
  dwOld : DWORD;
begin
  dwLoaded := LoadLibrary(lpModuleName);
  pProtoFill := GetProcAddress(dwLoaded, lpApiName);
  dwModuleBase := GetModuleHandle(HandleModel);
//  dwModuleBase := GetModuleHandle(nil);
  pDosHdr := PImageDosHeader(dwModuleBase);
  dwPeOffset := pDosHdr^._lfanew;
  pNtHdr := Pointer(dword(pDosHdr) + dwPeOffset);
  pImportDesc := Pointer(dword(pDosHdr) + pNtHdr.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
  while pImportDesc^.Name <> 0 do
  begin
    pCode := Pointer(dword(pDosHdr) + pImportDesc^.FirstThunk);
    while pCode^ <> nil do
    begin
      if (pCode^ = pProtoFill) then
      begin
       VirtualProtect(pCode, 4, PAGE_EXECUTE_READWRITE, @dwOld);
       pCode^ := pCallbackFunc;
      end;
      pCode := Pointer(dword(pCode) + 4);
    end;
    pImportDesc := Pointer(dword(pImportDesc) + 20);
  end;
end;


end.

