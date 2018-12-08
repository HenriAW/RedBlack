# We have:
#	%r10 p1 deck
#	%r11 p2 deck
#	%r8 number of cards in the pickup
#	%dl number of cards in p1 deck
#	%dh number of cards in p2 deck
#	#bl player to go
#	#bh round_colour flag
#
# We'll use %edi to create the new deck
# if round_colour flag is 1, we need 111...10
# if round colour flag is 0, we need 000...01
# (which is just 1)

.section .data

.equ INFINITE_BOUND, 10000

.section .text

.global _start
_start:
 # Setup vars
 movq $12, %r8
 movq $2830, %r9 # Deck configuration 101100,001110 - 44,14

# Split decks
 movq $1, %rax
 movb %r8b, %cl
 shrb $1, %cl 	# Divide %cl by 2
# Save number of cards in %rsi, %rdi
 movb %cl, %dl # P1 deck count
 movb %cl, %bl # P2 deck count
 movq $0, %rdi # Move counter

 shlq %cl, %rax # Shift bit to card place
 decq %rax #Should be 00..011..1 with number of cards amount of 1's
 movq %rax, %r11 # Player 2's deck
 andq %r9, %r11
 notq %rax
 movq %rax, %r10 # Player 1's deck
 andq %r9, %r10
 movb $64, %ch
 subb %cl, %ch
 movb %ch, %cl
 shlq %cl, %r11 # Shift to the right
 movb $64, %cl
 subb %r8b, %cl
 shlq %cl, %r10 # Shift far right
# Now player 1 and player 2 decks should be as far right as possible
 
 movq $0, %rsi	# Round counter
 
p1_first_turn:
 incq %rsi
 cmpq $INFINITE_BOUND, %rsi	#Infinite check
 je infinite
 movb $1, %dil
 decb %dl	# Decrease player 1 count
 jz finite
 shl $1, %r10 	# Play a card
 jnc p2_turn_0
 jmp p2_turn_1

p2_first_turn:
 incq %rsi
 cmpq $INFINITE_BOUND, %rsi
 je infinite
 movb $1, %dil
 decb %bl
 jz finite
 shl $1, %r11 	# Play a card
 jnc p1_turn_0
 jmp p1_turn_1

p1_turn_0:  	# The 0 represents the "round colour"
 incb %dil	# Increase pile counter
 shl $1, %r10 	# Play a card
 jc p1_pickup_0
 decb %dl	# Must be after pickup check
 jz finite 
 # jmp p2_turn_0

p2_turn_0:
 incb %dil
 shl $1, %r11
 jc p2_pickup_0
 decb %bl
 jz finite
 jmp p1_turn_0

p1_turn_1:
 incb %dil      # Increase pile counter
 shl $1, %r10   # Play a card
 jnc p1_pickup_1
 decb %dl       # Must be after pickup check
 jz finite
 # jmp p2_turn_1

p2_turn_1:
 incb %dil      # Increase pile counter
 shl $1, %r10   # Play a card
 jnc p2_pickup_1
 decb %bl       # Must be after pickup check
 jz finite
 jmp p1_turn_1

p1_pickup_0:
 addb %dil, %dl # Update cards in p1's pile
 movq $1, %rax 	# Pile to add
 movb $64, %cl
 subb %dl, %cl 	# Number of places to shift
 shlq %cl, %rax
 addq %rax, %r10 # Add new cards to p1_pile 
 jmp p2_first_turn

p1_pickup_1:
 movb %dil, %cl	# Where the 1s start (end of current pile)
 movq $1, %rax
 shlq %cl, %rax
 decq %rax	# This should be our string of 1's
 
 movb $64, %cl
 subb %cl, %dl 
 shlq %cl, %rax	# Here is where we'll make our pile to or with
 addq %rax, %r10
 addb %dil, %dl
 jmp p2_first_turn 

p2_pickup_0:
 addb %dil, %bl # Update cards in p2's pile count
 movq $1, %rax  # Pile to add
 movb $64, %cl
 subb %bl, %cl  # Number of places to shift
 shlq %cl, %rax
 addq %rax, %r11 # Add new cards to p2'spile 
 jmp p1_first_turn

p2_pickup_1:
 movb %dil, %cl # Where the 1s start (end of current pile)
 movq $1, %rax
 shlq %cl, %rax
 decq %rax      # This should be our string of 1's
 
 movb $64, %cl
 subb %cl, %bl
 shlq %cl, %rax # Here is where we'll make our pile to or with
 addq %rax, %r11
 addb %dil, %bl	#Update p2's pile count
 jmp p2_first_turn

finite:
 jmp end

infinite:


#Output resuls
end:
 movb %r14b, %bl
 movq $1, %rax
 int $0x80

