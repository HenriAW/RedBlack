# RedBlack
## Rules
RedBlack is a simple but interesting card game me and my friend thought up a few years ago. The rules are as follows:
 1. A full deck of cards is shuffled and divided evenly between two players
 2. The first player plays their top card. The colour of this card is known as the "round colour"
 3. Now players alternate turns playing their top card (starting from player 2), until one of them plays a card which is not the same colour as the "round colour". If this happens the player loses the round.
 4. When a player loses a round, they must pickup the played cards and place them at the bottom of their deck (without shuffling). It's then the turn of the winner of the round.
 
Play continues until one player has no more cards left in their hand. Note: If a player plays their last card and it's not the same as the round colour then they must pick up!

## Infinite games
What's interesting about this game is how long it goes on for. When my friend and I started playing, we were surprised when some games felt neverending! After some experimentation, I was able to find an infinite game with 5 cards. In the example below I'll use 0 to represent red and 1 to represent black.

| Player 1 Pile | Player 2 Pile | Played Pile | Comment|
|---|---|---|---|
| 10 | 110  | - | Starting hand, player 1 to go |
| 0  | 110  | 1 | Player 1 plays 1 |
| 0  | 10  | 11 | Player 2 plays 1 |
| -  | 10  | 110 | Player 1 plays 0 |
| 110 | 10 | - | Player 1 picks up. Player 2 to go |
| 110 | 0 | 1 | Player 2 plays 1 |
| 10 | 0 | 11 | Player 1 plays 1 |
| 10 | - | 110 | Player 2 plays 0 |
| 10 | 110 | - | Player 2 picks up, player 1 to go. Same as the initial state |

As you can see, this game will go on forever if no mistakes are made by the players.
The goal of this project is to find an infinite game that can be played with a full deck (or prove one does not exist)
The file 'infinite.txt', is used to store a list of known infinite games where both players have the same amount of cards, and there are an equal number of red and black cards. 

## Running the code
### Requirements to run code
This code is written to run on a Linux operating system (I'm using Ubuntu 16.04) which I'm running on [Google Cloud Compute](https://cloud.google.com/).
To run the code you'll need to `sudo apt-get install gcc`.
### Building
If gcc is installed you can simply run `build.sh` which will compile the code into a binary called `red_black`.
