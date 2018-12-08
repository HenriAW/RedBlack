# We have:
#	%rax p1 deck
#	%rbx p2 deck
#	%cl number of cards in the pickup
#	%dl number of cards in p1 deck
#	%dh number of cards in p2 deck
#	#ch player to go
#	#xx round_colour flag
#
# We'll use %edi to create the new deck
# if round_colour flag is 1, we need 111...10
# if round colour flag is 0, we need 000...01
# (which is just 1)

.section .data

playerOneDeck:
 .ascii "1110011"

playerTwoDeck:
 .ascii "1101001"

p1Count:
 .word 64 - 7

p2Count:
 .word 64 - 7

.section .text

.global _start
_start:
 # This will add 2 and 3
 movb p1Count, %dl
 movb p2Count, %dh

 # Setup player decks
 movq $8, %r8
 movq $15, %r9

 movq $0, %rbx
 movq $1, %r8
 movq %r8, %rbx
 movq $4, %rcx 

 shlq %cl, %rbx # Can shift from %cl only!

# Experiment 2

#%rax - Number
#%rbx - And result
#%rcx - And flag
#%rdx - 1 count. This will keep track of how many 1's we need to add at the end
 movq $5, %rax # The number to process
 movq $1, %rcx # Bit checker
 movq $1, %rdx # The count
 movq $1, %rbx # Temporary and storage

 # Check first number
 andq %rax, %rbx
 jnz get_next_number_first_one
 
find_first_one:
 addq %rcx, %rcx  # Shift inspection bit to the left
 movq %rcx, %rbx  # Copy inspection bit to %rbx
 andq %rax, %rbx  # See if bit is in %rax
 jz find_first_one
 jnz get_next_number_first_one

get_next_number_many_ones:
 addq %rdx, %rdx
get_next_number_first_one:
 subq %rcx, %rax # We've found a 1 so let's remove it from %eax
 addq %rcx, %rcx # Shift %ecx to the left 
 movq %rcx, %rbx # Move to %rbx so we can do and
 andq %rax, %rbx # Check if this digit is present
 jnz get_next_number_many_ones # End if we've found next
 
 # So we want to add this number
 addq %rcx, %rax
 decq %rdx
 addq %rdx, %rax
 
# Output result
 movq %rax, %rbx
 movq $1, %rax
 int $0x80

