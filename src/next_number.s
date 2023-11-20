.include "linux.s"

.section .data

newline:
 .ascii "\n"

.section .bss
.equ MAX_SIG_INT32_SZ, 20
.equ NUM_CARDS, 32
.lcomm INT_TEXT, MAX_SIG_INT32_SZ

.section .text
.global _start
_start:

create_last_bit_check:
  movq $1, %r9  # %r9 will be used to check the last bit so we can stop
  mov  $(NUM_CARDS - 1), %cl
  shlq %cl, %r9

create_initial_deck:
  # Create inital deck
  movq $1, %r8 # r8 is used to hold the current starting deck
  shlq $(NUM_CARDS / 2), %r8
  subq $1, %r8
  jmp print

get_next_number:
  movq $1,   %rax  # %rax tracks the bit we currently have
  movq %r8,  %rbx  # %rbx is a copy of %r8 used to check the bit in r8
  movq %rax, %rcx  # %rcx is used to create the final 1s string
  andq %rax, %rbx  # Check the fist number
  jnz get_next_number_first_one

find_first_one:
 addq %rax, %rax  # Shift inspection bit to the left
 movq %r8,  %rbx  # Copy %r8 to %rbx
 andq %rax, %rbx  # Check next bit
 jz find_first_one

get_next_number_first_one:
 subq %rax, %r8   # We found a one so we remove it from %r8
 addq %rax, %rax
 movq %rax, %rbx    
 andq %r8 , %rbx  # Check next bit, if this is a zero we're done
 jz found_next_first_one

get_next_number_many_ones:
 addq %rcx, %rcx  # We now use %rcx to keep track of 1s
 subq %rax, %r8   # We've found a 1 so we remove it from %r8
 addq %rax, %rax  # Shift %rax to the left 
 movq %r8,  %rbx  # Copy %r8 to %rbx
 andq %rax, %rbx  # Check next bit
 jnz get_next_number_many_ones # End if we've found next

found_next:
 xor  %rax, %r8  # Add the new bit to %r8
 decq %rcx       # We used %rdx to check 1s so we can now turn it to a string of 1s
 xor  %rcx, %r8  # Add the string of 1s to %r8

 # Check if count completed
 movq %r9, %rbx
 andq %r8, %rbx
 jnz exit

print:
# # Output result
# # Call int_to_ascii
# pushq $INT_TEXT
# pushq %r8
# call int_to_ascii
# addq $8, %rsp

# # Print result
# movq $SYS_WRITE, %rax
# movq $STDOUT, %rbx
# movq $INT_TEXT, %rcx
# movq $MAX_SIG_INT32_SZ, %rdx
# int $LINUX_SYSCALL

# # Print newline
# movq $SYS_WRITE, %rax
# movq $STDOUT, %rbx
# movq $newline, %rcx
# movq $1, %rdx
# int $LINUX_SYSCALL

  jmp get_next_number

exit:
 movq %rax, %rbx
 movq $1, %rax
 int $LINUX_SYSCALL

found_next_first_one:
 xor %rax, %r8  # Add the new bit to %r8
 jmp print      # Skipping the check so this won't work if we only have 1 bit
