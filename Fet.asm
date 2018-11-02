format PE GUI 6.0
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

section '.text' code executable

main:
    stdcall findProcessId
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
    invoke Process32First, dword [eax], dword [ebx]
    ret
endp

section '.idata' data readable import

library kernel32, 'kernel32.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       OpenProcess, 'OpenProcess', \
       Process32First, 'Process32First', \
       ExitProcess, 'ExitProcess'
