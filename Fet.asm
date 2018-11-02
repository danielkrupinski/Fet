format PE GUI 6.1
entry main

include 'INCLUDE/win32ax.inc'

section '.text' code executable

main:

proc findProcessId

endp

section '.idata' data readable import

library kernel32, 'kernel32.dll'

import kernel32, \
       OpenProcess, 'OpenProcess'
