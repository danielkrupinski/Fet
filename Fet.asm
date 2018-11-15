format PE console 6.0
entry main

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

section '.text' code executable

main:
    stdcall findProcessId
    mov [processId], eax
    stdcall findModuleBase, eax
    mov [clientBase], eax
    cinvoke printf, <'Client base: %d', 0>, [clientBase]
    cinvoke getchar
    cinvoke printf, <'PID: %d', 0>, [processId]
    invoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, [processId]
    mov [processHandle], eax
    cinvoke printf, <'Handle: %d', 0>, eax

    loop1:
    lea eax, [localPlayer]
    mov ebx, [clientBase]
    add ebx, [localPlayerOffset]
    invoke ReadProcessMemory, dword [processHandle], ebx, eax, 4, NULL
    cmp [localPlayer], 0
    je loop1

    cinvoke printf, <'LocalPlayer: %d', 0>, [localPlayer]
    cinvoke getchar

    triggerbot:
    mov [crosshairID], 0
    mov [team], 0
    cmp [localPlayer], 0
    je loop1
    invoke GetAsyncKeyState, 0x12
    cmp eax, 0
    je triggerbot
    lea eax, [crosshairID]
    mov ebx, [localPlayer]
    add ebx, [crosshairIdOffset]
    invoke ReadProcessMemory, dword [processHandle], ebx, eax, 4, NULL
    cmp [crosshairID], 0
    jle triggerbot
    cmp [crosshairID], 64
    jg triggerbot
    lea eax, [team]
    mov ebx, [localPlayer]
    add ebx, [teamOffset]
    invoke ReadProcessMemory, dword [processHandle], ebx, eax, 4, NULL
    dec [crosshairID]
    mov eax, [crosshairID]
    mov ecx, 0x10
    mul ecx
    mov eax, [clientBase]
    add eax, [entityListOffset]
    lea ebx, [entity]
    invoke ReadProcessMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [entity]
    add eax, [teamOffset]
    lea ebx, [entityTeam]
    invoke ReadProcessMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [entityTeam]
    cmp eax, [team]
    je triggerbot
    mov eax, [clientBase]
    add eax, [forceAttackOffset]
    lea ebx, [force1]
    invoke WriteProcessMemory, dword [processHandle], eax, ebx, 4, NULL
    invoke Sleep, 1
    mov eax, [clientBase]
    add eax, [forceAttackOffset]
    lea ebx, [force2]
    invoke WriteProcessMemory, dword [processHandle], eax, ebx, 4, NULL
    jmp triggerbot
    invoke ExitProcess, 0

error:
    invoke ExitProcess, 1

proc findProcessId
    locals
        processEntry PROCESSENTRY32 ?
        snapshot dd ?
    endl

    invoke CreateToolhelp32Snapshot, 0x2, 0
    mov [snapshot], eax
    mov [processEntry.dwSize], sizeof.PROCESSENTRY32
    lea eax, [snapshot]
    lea ebx, [processEntry]
    invoke Process32First, dword [eax], ebx
    cmp eax, 1
    jne error
    loop2:
        lea eax, [snapshot]
        lea ebx, [processEntry]
        invoke Process32Next, dword [eax], ebx
        cmp eax, 1
        jne error
        lea eax, [processEntry.szExeFile]
        cinvoke strcmp, <'csgo.exe', 0>, eax
        cmp eax, 0
        jne loop2

    mov eax, [processEntry.th32ProcessID]
    ret
endp

proc findModuleBase, processID
    locals
        moduleEntry MODULEENTRY32 ?
        snapshot dd ?
    endl

    invoke CreateToolhelp32Snapshot, 0x8, [processID]
    mov [snapshot], eax
    mov [moduleEntry.dwSize], sizeof.MODULEENTRY32
    lea eax, [snapshot]
    lea ebx, [moduleEntry]
    invoke Module32First, dword [eax], ebx
    cmp eax, 1
    jne error
    loop3:
        lea eax, [snapshot]
        lea ebx, [moduleEntry]
        invoke Module32Next, dword [eax], ebx
        cmp eax, 1
        jne error
        lea eax, [moduleEntry.szModule]
        cinvoke strcmp, <'client_panorama.dll', 0>, eax
        cmp eax, 0
        jne loop3

    mov eax, [moduleEntry.modBaseAddr]
    ret
endp

section '.bss' data readable writable

processId dd ?
processHandle dd ?
clientBase dd ?
localPlayer dd ?
crosshairID dd ?
forceAttack dd ?
team dd ?
entityList dd ?
entity dd ?
entityTeam dd ?

section '.rdata' data readable

localPlayerOffset dd 0xC648AC
crosshairIdOffset dd 0xB2DC
forceAttackOffset dd 0x3082DEC
teamOffset dd 0xF0
entityListOffset dd 0x4C41704
force1 dd 5
force2 dd 4

section '.idata' data readable import

library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll', \
        user32, 'user32.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       Module32First, 'Module32First', \
       Module32Next, 'Module32Next', \
       OpenProcess, 'OpenProcess', \
       Process32First, 'Process32First', \
       Process32Next, 'Process32Next', \
       ReadProcessMemory, 'ReadProcessMemory', \
       WriteProcessMemory, 'WriteProcessMemory', \
       ExitProcess, 'ExitProcess', \
       GetLastError, 'GetLastError', \
       Sleep, 'Sleep'

import msvcrt, \
       strcmp, 'strcmp', \
       printf, 'printf', \
       getchar, 'getchar'

import user32, \
       GetAsyncKeyState, 'GetAsyncKeyState'
