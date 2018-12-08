.include "linux.s"
# Experiment 2
#%rax - Number
#%rbx - And result
#%rcx - And flag
#%rdx - 1 count. This will keep track of how many 1's we need to add at the end

.section .bss
.equ MAX_SIG_INT32_SZ, 52
.lcomm INT_TEXT, MAX_SIG_INT32_SZ

.section .text
.global _start
_start:
 movb $32, %r8b # Number of cards
 movq $1, %r9 # Last card checker
 movb %r8b, %cl
 shlq %cl, %r9

# Calculate starting point
 movb %r8b, %cl
 shrb $1, %cl  # Divide by 2
 movq $1, %rax
 shlq %cl, %rax
 decq %rax

get_next_number:
 movq $1, %rcx  # Bit checker
 movq $1, %rdx  # The count
 movq $1, %rbx  # Temporary and storage
 # Check first number
 andq %rax, %rbx
 jnz get_next_number_first_one

find_first_one:
 addq %rcx, %rcx  # Shift inspection bit to the left
 movq %rcx, %rbx  # Copy inspection bit to %rbx
 andq %rax, %rbx  # See if bit is in %rax
 jz find_first_one

get_next_number_first_one:
 subq %rcx, %rax
 addq %rcx, %rcx
 movq %rcx, %rbx
 andq %rax, %rbx
 jz end
 
get_next_number_many_ones:
 addq %rdx, %rdx # We now need to keep track of %rdx
 subq %rcx, %rax # We've found a 1 so let's remove it from %eax
 addq %rcx, %rcx # Shift %ecx to the left 
 movq %rcx, %rbx # Move to %rbx so we can do and
 andq %rax, %rbx # Check if this digit is present
 jnz get_next_number_many_ones # End if we've found next

 # So we want to add this number
end:
 addq %rcx, %rax
 decq %rdx
 addq %rdx, %rax

# Check if count completed
 movq %r9, %rbx
 andq %rax, %rbx
 jz get_next_number

# Output result
output_results:
 # Call int_to_ascii
 pushq $INT_TEXT
 pushq %rax
 call int_to_ascii
 addq $4, %rsp

 # Print result
 #movq $SYS_WRITE, %rax
 #movq $STDOUT, %rbx
 #movq $INT_TEXT, %rcx
 #movq $MAX_SIG_INT32_SZ, %rdx
 #int $LINUX_SYSCALL

exit:
 movq %rax, %rbx
 movq $1, %rax
 int $LINUX_SYSCALL
