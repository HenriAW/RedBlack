# From chapter 6 of 'PGU'. This should make my main code easier to understand
# Common Linux Definitions

# System call numbers
.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ SYS_BREAK, 45

# System Call Interrupt Number
.equ LINUX_SYSCALL, 0x80

# Standart File Descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# Common Status Codes
.equ END_OF_FILE, 0
