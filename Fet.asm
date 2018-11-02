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

    mov [processEntry.dwSize], sizeof.PROCESSENTRY32
    invoke CreateToolhelp32Snapshot, 0x2, 0
    ret
endp

section '.idata' data readable import

library kernel32, 'kernel32.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       OpenProcess, 'OpenProcess', \
       ExitProcess, 'ExitProcess'
