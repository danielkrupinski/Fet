format PE GUI 6.1
entry main

section '.text' code executable

main:

section '.idata' data readable import

library kernel32, 'kernel32.dll'
