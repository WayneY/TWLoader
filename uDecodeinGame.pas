unit uDecodeinGame;

interface

uses
  mmsystem, Windows;

var
  TmpKey_1: byte;
  TmpKey_2,TimeKey: integer;

  procedure DecodeRecvInGame(Packet: DWORD; Len: Integer);
  procedure EncodeRecvInGame(var Packet: array of byte; Len: Integer);
  procedure Sub008D5240;

implementation

//uses VMProtectSDK;


procedure EncodeRecvInGame(var Packet: array of byte; Len: Integer);
begin
asm
       mov esi, Packet
       mov eax, Len
       push esi
       push 0
       push eax
       lea edi, dword ptr [esi]
       push edi
       call @Start
       jmp @Exit

@Start:

//  push eax
//  call VMProtectBeginMutation
        push ebp
        mov ebp,esp
        push ebx
        push esi
        mov esi,dword ptr [ebp+$010]
        test esi,esi
        push edi
        mov eax,$04453EB5
        je @_DNF_00799565
        push esi
        call Sub008D5240
        add esp,4

@_DNF_00799565:

        movzx edx,ah
        and edx,$080000007
        mov byte ptr TmpKey_1,al
        jns @_DNF_0079957A
        dec edx
        or edx,$FFFFFFF8
        inc edx

@_DNF_0079957A:

        mov eax,dword ptr [ebp+$0C]
        xor esi,esi
        test eax,eax
        mov dword ptr TmpKey_2,edx
        jle @_DNF_007995C1
        mov edi,dword ptr [ebp+8]
        lea esp,dword ptr [esp]

@_DNF_00799590:

        mov al,byte ptr TmpKey_1
        mov cl,byte ptr [esi+edi]
        xor cl,al
        mov byte ptr [esi+edi],cl
        mov edx,dword ptr TmpKey_2
        mov al,cl
        mov ecx,8
        sub ecx,edx
        mov bl,al
        shl bl,cl
        mov cl,dl
        shr al,cl
        or bl,al
        mov eax,dword ptr [ebp+$0C]
        mov byte ptr [esi+edi],bl
        inc esi
        cmp esi,eax
        jl @_DNF_00799590

@_DNF_007995C1:

        pop edi
        pop esi
        pop ebx
        pop ebp
        ret $10
//  call VMProtectEnd
@Exit:
end;
end;

procedure DecodeRecvInGame(Packet: DWORD; Len: Integer);
begin
asm
       mov esi, $115D2312
       mov TimeKey, esi
       mov esi, Packet
       mov eax, Len
       push esi
       push 0
       push eax
       lea edi, dword ptr [esi]
       push edi
       call @Start
       jmp @Exit

@Start:

//  push eax
//  call VMProtectBeginMutation
        push ebp
        mov ebp,esp
        mov ecx,dword ptr [ebp+$010]
        test ecx,ecx
        mov eax,$04453EB5
        je @_DNF_00799178
        push ecx
        call Sub008D5240
        add esp,4

@_DNF_00799178:

        push ebx
        movzx ebx,ah
        and ebx,$080000007
        push esi
        mov byte ptr TmpKey_1,al
        jns @_DNF_0079918F
        dec ebx
        or ebx,$FFFFFFF8
        inc ebx

@_DNF_0079918F:

        mov eax,dword ptr [ebp+$0C]
        xor esi,esi
        test eax,eax
        mov dword ptr TmpKey_2,ebx
        jle @_DNF_007991D6
        push edi
        mov edi,dword ptr [ebp+8]
        jmp @_DNF_007991B0

@_DNF_007991A4:

        mov ebx,dword ptr TmpKey_2
        lea ebx,dword ptr [ebx]

@_DNF_007991B0:

        mov dl,byte ptr [esi+edi]
        mov cl,8
        sub cl,bl
        mov al,dl
        shr al,cl
        mov ecx,ebx
        shl dl,cl
        or al,dl
        mov byte ptr [esi+edi],al
        xor al,byte ptr TmpKey_1
        mov byte ptr [esi+edi],al
        mov eax,dword ptr [ebp+$0C]
        inc esi
        cmp esi,eax
        jl @_DNF_007991A4
        pop edi

@_DNF_007991D6:

        pop esi
        pop ebx
        pop ebp
        ret $10
//  call VMProtectEnd
@Exit:

end;
end;

procedure Sub008D5240;
begin
//VMProtectBeginMutation('Sub');
asm

@_DNF_008D5240:

        push ebp
        mov ebp,esp
        push esi
        mov esi,dword ptr [ebp+8]
        test esi,esi
        jnz @_DNF_008D525C
        call timeGetTime
        add dword ptr TimeKey,eax
        lea esi,TimeKey

@_DNF_008D525C:

        mov eax,dword ptr [esi]
        imul eax,eax,$041C64E6D
        add eax,$03039
        mov edx,eax
        imul eax,eax,$041C64E6D
        add eax,$03039
        mov ecx,eax
        imul eax,eax,$041C64E6D
        shr edx,$010
        shr ecx,$010
        add eax,$03039
        and edx,$07FF
        and ecx,$03FF
        mov dword ptr [esi],eax
        shl edx,$0A
        xor ecx,edx
        shr eax,$010
        and eax,$03FF
        shl ecx,$0A
        xor eax,ecx
        pop esi
        pop ebp
        ret
end;
//VMProtectEnd;
end;

end.
