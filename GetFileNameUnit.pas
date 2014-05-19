unit GetFileNameUnit;

interface
uses
  Windows, PsApi;

const
  BUFSIZE = 512;

function GetProcessModuleFileName(AProcess: THandle; AFile: THandle): String;

implementation

function GetProcessModuleFileName(AProcess: THandle; AFile: THandle): String;

const
  BUF_SIZE = 512;

var
  bFound       : Boolean;
  dwFileSizeHi : DWORD;
  dwFileSizeLo : DWORD;
  hFileMap     : THandle;
  lpTemp       : PByte;
  nDriveCount  : Integer;
  pMem         : Pointer;
  szFileName   : array[0 .. MAX_PATH] of Char;
begin
  Result   := '';

  dwFileSizeLo := GetFileSize(AFile, @dwFileSizeHi);
  if (dwFileSizeLo = 0) and (dwFileSizeHi = 0) then
    Exit;

  hFileMap := CreateFileMapping(AFile, nil, PAGE_WRITECOPY, 0, 0, nil);

  if (hFileMap <= 0) then
    Exit;

  pMem := MapViewOfFile(hFileMap, FILE_MAP_COPY, 0, 0, 0);

  if not Assigned(pMem) then
  begin
    CloseHandle(hFileMap);
    Exit;
  end;

  asm
    pushad
    mov eax, pMem
    mov dword ptr [eax], $67676767
    popad
  end;

  if (GetMappedFileName(GetCurrentProcess(), pMem, szFileName, MAX_PATH) <= 0) then
  begin
    UnmapViewOfFile(pMem);
    CloseHandle(hFileMap);
    Exit;
  end;


  UnmapViewOfFile(pMem);
  CloseHandle(hFileMap);
  Result:=szFileName;
end;

end.
