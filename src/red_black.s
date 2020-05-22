.include "linux.s"
# %rax - Number
# %rbx - And result
# %rcx - And flag
# %rdx - 1 count. This will keep track of how many 1's we need to add at the end

.section .data

newline:
 .ascii "\n"
.equ INFINITE_BOUND, 10000

.section .bss
.equ MAX_SIG_INT32_SZ, 20
.lcomm INT_TEXT, MAX_SIG_INT32_SZ

.section .text
.global _start
_start:
 movb $52, %r11b # Number of cards. !CHANGE THIS NUMBER TO CHANGE DECK SIZE!
 movb %r11b, %r13b # Number of cards per person
 shrb $1, %r13b   # Halve %r11b
 movb $65, %r14b # 65 - no cards
 subb %r11b, %r14b
 movq $1, %r15 # Last card checker
 movb %r11b, %cl
 decb %cl       # Don't need to consider positions with leading 1
 shlq %cl, %r15

# Calculate starting point
 movb %r13b, %cl
 movq $1, %r12
 shlq %cl, %r12
 decq %r12

get_next_number:
 movb $52, %r11b # Last card checker. !CHANGE THIS NUMBER TO CHANGE DECK SIZE!
 movq $1, %rcx  # Bit checker
 movq $1, %rdx  # The count
 movq $1, %rbx  # Temporary and storage
 
 # Check first number
 andq %r12, %rbx
 jnz get_next_number_first_one

find_first_one:
 addq %rcx, %rcx  # Shift inspection bit to the left
 movq %rcx, %rbx  # Copy inspection bit to %rbx
 andq %r12, %rbx  # See if bit is in %rax
 jz find_first_one

get_next_number_first_one:
 subq %rcx, %r12
 addq %rcx, %rcx
 movq %rcx, %rbx
 andq %r12, %rbx
 jz found_next
 
get_next_number_many_ones:
 addq %rdx, %rdx # We now need to keep track of %rdx
 subq %rcx, %r12 # We've found a 1 so let's remove it from %r12
 addq %rcx, %rcx # Shift %ecx to the left 
 movq %rcx, %rbx # Move to %rbx so we can do and
 andq %r12, %rbx # Check if this digit is present
 jnz get_next_number_many_ones # End if we've found next
 # jmp found_next

 # So we want to add this number
found_next:
 addq %rcx, %r12
 decq %rdx
 addq %rdx, %r12

# Check if count completed
 movq %r15, %rbx
 andq %r12, %rbx
 jnz exit
 # jmp play_game

play_game:
# Split decks
 movb %r13b, %cl 	# Number of cards per player
 movq $1, %rax
 shlq %cl, %rax # Shift bit to card place
 decq %rax # Should be 00..011..1 with number of cards amount of 1's
 
 movq %r12, %r9 # Player 2's deck
 andq %rax, %r9
 
 notq %rax
 movq %r12, %r8 # Player 1's deck
 andq %rax, %r8
 
 movb $64, %cl
 subb %r13b, %cl
 shlq %cl, %r9 # Shift to the right
 subb %r13b, %cl
 shlq %cl, %r8 # Shift far right
# Now player 1 and player 2 decks should be as far right as possible

# Reset player card counts 
 movb %r13b, %dl # P1 deck count
 movb %r13b, %bl # P2 deck count

 movq $0, %rsi	# Reset counter
 
p1_first_turn:
 incq %rsi
 cmpq $INFINITE_BOUND, %rsi     # Infinite check
 je infinite
 decb %dl       # Decrease player 1 count
 jz finite
 shl $1, %r8   # Play a card
 jc p2_turn_1
 jmp p2_turn_0

p2_first_turn:
 incq %rsi
 cmpq $INFINITE_BOUND, %rsi
 je infinite
 decb %bl
 jz finite
 shl $1, %r9   # Play a card
 jc p1_turn_1
 # jmp p1_turn_0

p1_turn_0:  	# The 0 represents the "round colour"
 shl $1, %r8 	# Play a card
 jc p1_pickup_0
 decb %dl	# Must be after pickup check
 jz finite 
 # jmp p2_turn_0

p2_turn_0:
 shl $1, %r9
 jc p2_pickup_0
 decb %bl
 jz finite
 jmp p1_turn_0

p1_turn_1:
 shl $1, %r8   # Play a card
 jnc p1_pickup_1
 decb %dl       # Must be after pickup check
 jz finite
 # jmp p2_turn_1

p2_turn_1:
 shl $1, %r9   # Play a card
 jnc p2_pickup_1
 decb %bl       # Must be after pickup check
 jz finite
 jmp p1_turn_1

p1_pickup_0:
 movb %r11b, %dl
 subb %bl, %dl  # Update p1's pile
 movq $1, %rax 	# Pile to add
 movb $64, %cl
 subb %dl, %cl 	# Number of places to shift
 shlq %cl, %rax
 addq %rax, %r8 # Add new cards to p1_pile 
 jmp p2_first_turn

p1_pickup_1:
 movb %r11b, %cl
 subb %bl, %cl
 subb %dl, %cl

 movq $1, %rax
 shlq %cl, %rax
 decq %rax	# This should be our string of 1's
 
 movb %r14b, %cl # 65 - no cards
 addb %bl, %cl
 
 shlq %cl, %rax	# Here is where we'll make our pile to or with
 addq %rax, %r8
 movb %r11b, %dl
 subb %bl, %dl
 jmp p2_first_turn 

p2_pickup_0:
 movb %r11b, %bl
 subb %dl, %bl  # Update p2's pile
 movq $1, %rax 	# Pile to add
 movb $64, %cl
 subb %bl, %cl 	# Number of places to shift
 shlq %cl, %rax
 addq %rax, %r9 # Add new cards to p1_pile 
 jmp p1_first_turn

p2_pickup_1:
 movb %r11b, %cl
 subb %dl, %cl
 subb %bl, %cl

 movq $1, %rax
 shlq %cl, %rax
 decq %rax	# This should be our string of 1's
 
 movb %r14b, %cl
 addb %dl, %cl

 shlq %cl, %rax	# Here is where we'll make our pile to or with
 addq %rax, %r9
 movb %r11b, %bl
 subb %dl, %bl
 jmp p1_first_turn 

finite:
 jmp get_next_number

infinite:
# Output result
 # Call int_to_ascii
 pushq $INT_TEXT
 pushq %r12
 call int_to_ascii
 addq $8, %rsp

 # Print result
 movq $SYS_WRITE, %rax
 movq $STDOUT, %rbx
 movq $INT_TEXT, %rcx
 movq $MAX_SIG_INT32_SZ, %rdx
 int $LINUX_SYSCALL

 # Print newline
 movq $SYS_WRITE, %rax
 movq $STDOUT, %rbx
 movq $newline, %rcx
 movq $1, %rdx
 int $LINUX_SYSCALL

 jmp get_next_number

exit:
 movq %rax, %rbx
 movq $1, %rax
 int $LINUX_SYSCALL


