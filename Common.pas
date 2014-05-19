unit Common;

interface

uses
  Classes, SysUtils;

const
  PVFVer= $0000BCC3;
  VerStr= '13ff9a94-0204-0410-845a-ceeffe637190';
  DecodeingXorKey= $81A79011;

type
  TFileInfo = packed record
    FullFileName: string;                     //文件名
    RealLen: integer;                     //数据解压后的长度
    HexBuf: array of byte;                //首次解密后的2进制数据
    TxtBuf: TStringList;                  //转换成文本后的数据
  end;

  TFileList = packed record
    Items: array of TFileInfo;
    Count: integer;
  end;

var
  KeyTabel: array [0..$3FF] of byte;
  WorkPath: string;
  PakFile: string;
  FileListTabelBuf: array of byte;
  Stop: Boolean;
  FileList: TFileList;
  StringTableList: TStringList;

  function CutString(var Str: string; const SubStr: string): string;

implementation

function CutString(var Str: string; const SubStr: string): string;
var
  I: integer;
begin
  I:= Pos(SubStr, Str);
  if I > 0 then
  begin
    if I < 2 then
    begin
      Result:= Trim(copy(Str, 1, length(SubStr)));
      Str:= Trim(copy(Str, I+length(SubStr), length(Str)-length(SubStr)));
    end else
    begin
      Result:= Trim(copy(Str, 1, I-1));
      Str:= Trim(copy(Str, I+length(SubStr), length(Str)-I-length(SubStr)+1));
    end;
  end else
  begin
    Result:= Str;
  end;
end;

end.
