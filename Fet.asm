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
    stdcall findModuleBase, eax
    cinvoke printf, <'Client base: %d', 0>, eax
    cinvoke getchar
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
    loop1:
        lea eax, [snapshot]
        lea ebx, [processEntry]
        invoke Process32Next, dword [eax], ebx
        cmp eax, 1
        jne error
        lea eax, [processEntry.szExeFile]
        cinvoke strcmp, <'csgo.exe', 0>, eax
        cmp eax, 0
        jne loop1

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
    loop2:
        lea eax, [snapshot]
        lea ebx, [moduleEntry]
        invoke Module32Next, dword [eax], ebx
        cmp eax, 1
        jne error
        lea eax, [moduleEntry.szModule]
        cinvoke strcmp, <'client_panorama.dll', 0>, eax
        cmp eax, 0
        jne loop2

    mov eax, [moduleEntry.modBaseAddr]
    ret
endp

section '.bss' data readable writable

localPlayer dd ?
crosshairID dd ?
forceAttack dd ?
team dd ?
entityList dd ?

section '.rdata' data readable

localPlayerOffset dd 0xC618AC
crosshairIdOffset dd 0xB2DC
forceAttackOffset dd 0x307FD44
teamOffset dd 0xF0
entityListOffset dd 0x4C3E674

section '.idata' data readable import

library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       Module32First, 'Module32First', \
       Module32Next, 'Module32Next', \
       OpenProcess, 'OpenProcess', \
       Process32First, 'Process32First', \
       Process32Next, 'Process32Next', \
       ExitProcess, 'ExitProcess'

import msvcrt, \
       strcmp, 'strcmp', \
       printf, 'printf', \
       getchar, 'getchar'
