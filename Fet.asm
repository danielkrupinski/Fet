format PE GUI 6.0
entry start

include 'INCLUDE/win32ax.inc'

struct PROCESSENTRY32
       dwSize                  dd ?
       cntUsage                dd ?
       th32ProcessID           dd ?
       th32DefaultHeapID       dd ?
       th32ModuleID            dd ?
       cntThreads              dd ?
       th32ParentProcessID     dd ?
       pcPriClassBase          dd ?
       dwFlags                 dd ?
       szExeFile               dw MAX_PATH dup (?)
ends

struct MODULEENTRY32
       dwSize                  dd ?
       th32ModuleID            dd ?
       th32ProcessID           dd ?
       GlblcntUsage            dd ?
       ProccntUsage            dd ?
       modBaseAddr             dd ?
       modBaseSize             dd ?
       hModule                 dd ?
       szModule                dw 256 dup (?)
       szExeFile               dw MAX_PATH dup (?)
ends

struct CLIENT_ID
       UniqueProcess dd ?
       UniqueThread  dd ?
ends

struct OBJECT_ATTRIBUTES
       Length                      dd ?
       RootDirectory               dd ?
       ObjectName                  dd ?
       Attributes                  dd ?
       SecurityDescriptor          dd ?
       SecurityQualityOfService    dd ?
ends

section '.text' code executable

start:
    invoke CreateToolhelp32Snapshot, 0x2, 0
    mov [snapshot], eax
    mov [processEntry.dwSize], sizeof.PROCESSENTRY32
    invoke Process32First, [snapshot], processEntry
    cmp eax, 1
    jne exit
    loop2:
        invoke Process32Next, [snapshot], processEntry
        cmp eax, 1
        jne exit
        cinvoke strcmp, <'csgo.exe', 0>, processEntry.szExeFile
        test eax, eax
        jnz loop2


    mov eax, [processEntry.th32ProcessID]
    mov [clientId.UniqueProcess], eax

    invoke CreateToolhelp32Snapshot, 0x8, eax
    mov [snapshot], eax
    mov [clientDll.dwSize], sizeof.MODULEENTRY32
    invoke Module32First, [snapshot], clientDll
    cmp eax, 1
    jne exit
    loop3:
        invoke Module32Next, [snapshot], clientDll
        cmp eax, 1
        jne exit
        cinvoke strcmp, <'client_panorama.dll', 0>, clientDll.szModule
        test eax, eax
        jnz loop3

    mov eax, [clientDll.modBaseAddr]

    mov [clientBase], eax
    mov [forceAttack], eax
    mov [entityList], eax
    mov [gameTypeCvar], eax
    mov [objectAttributes.Length], sizeof.OBJECT_ATTRIBUTES
    invoke NtOpenProcess, processHandle, PROCESS_VM_READ + PROCESS_VM_WRITE + PROCESS_VM_OPERATION, objectAttributes, clientId
    test eax, eax
    jnz exit
    add [forceAttack], 0x3114BC4
    add [entityList], 0x4CE34FC
    add [gameTypeCvar], 0x3F3AB4
    invoke NtReadVirtualMemory, [processHandle], [gameTypeCvar], gameTypeCvar, 4, NULL

triggerbot:
    invoke NtDelayExecution, FALSE, sleepDuration
    mov eax, [clientBase]
    add eax, [localPlayerOffset]
    invoke NtReadVirtualMemory, [processHandle], eax, localPlayer, 4, NULL
    test eax, eax
    jnz exit
    invoke GetAsyncKeyState, 0x12
    test eax, eax
    jz triggerbot
    mov eax, [localPlayer]
    add eax, [crosshairIdOffset]
    invoke NtReadVirtualMemory, [processHandle], eax, crosshairID, 4, NULL
    cmp [crosshairID], 0
    je triggerbot
    cmp [crosshairID], 64
    ja triggerbot
    mov eax, [gameTypeCvar]
    add eax, 48
    invoke NtReadVirtualMemory, [processHandle], eax, gameTypeValue, 4, NULL
    mov eax, [gameTypeCvar]
    xor eax, [gameTypeValue]
    cmp eax, 6
    je shoot
    mov eax, [localPlayer]
    add eax, [teamOffset]
    invoke NtReadVirtualMemory, [processHandle], eax, team, 4, NULL
    mov eax, [crosshairID]
    dec eax
    mov ecx, 0x10
    mul ecx
    add eax, [entityList]
    invoke NtReadVirtualMemory, [processHandle], eax, entity, 4, NULL
    mov eax, [entity]
    add eax, [teamOffset]
    invoke NtReadVirtualMemory, [processHandle], eax, entityTeam, 4, NULL
    mov eax, [entityTeam]
    cmp eax, [team]
    je triggerbot
    
shoot:
    invoke NtWriteVirtualMemory, [processHandle], [forceAttack], force, 4, NULL
    jmp triggerbot

exit:
    retn

section '.bss' data readable writable

processEntry PROCESSENTRY32 ?
clientDll MODULEENTRY32 ?
snapshot dd ?
clientId CLIENT_ID ?
objectAttributes OBJECT_ATTRIBUTES ?
processHandle dd ?
clientBase dd ?
localPlayer dd ?
crosshairID dd ?
forceAttack dd ?
team dd ?
entityList dd ?
entity dd ?
entityTeam dd ?
gameTypeCvar dd ?
gameTypeValue dd ?

section '.rdata' data readable

localPlayerOffset dd 0xCD2764
crosshairIdOffset dd 0xB394
teamOffset dd 0xF4
force dd 6
sleepDuration dq -1

section '.idata' import readable

library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll', \
        user32, 'user32.dll', \
        ntdll, 'ntdll.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       Module32First, 'Module32First', \
       Module32Next, 'Module32Next', \
       Process32First, 'Process32First', \
       Process32Next, 'Process32Next'

import msvcrt, \
       strcmp, 'strcmp'

import user32, \
       GetAsyncKeyState, 'GetAsyncKeyState'

import ntdll, \
       NtDelayExecution, 'NtDelayExecution', \
       NtOpenProcess, 'NtOpenProcess', \
       NtReadVirtualMemory, 'NtReadVirtualMemory', \
       NtWriteVirtualMemory, 'NtWriteVirtualMemory'
