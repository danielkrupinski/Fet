format PE GUI 6.1
entry main

include 'INCLUDE/win32ax.inc'

section '.text' code executable

main:

proc findProcessId
    locals
        processEntry PROCESSENTRY32 ?
        snapshot HANDLE ?
    endl

    mov [processEntry.dwSize], sizeof(PROCESSENTRY32)
endp

section '.idata' data readable import

library kernel32, 'kernel32.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       OpenProcess, 'OpenProcess', \
       ExitProcess, 'ExitProcess'
