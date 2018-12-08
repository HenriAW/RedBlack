#include <stdio.h>
#include <stdbool.h>
#include <string.h>

struct stateVector {
    bool *deck;
    int *split;
    int *noCards;
};

void turn(struct stateVector current);
bool *next(bool *binArray, int length);

int main() {
  int limit = 1500;
  int start = 6;
  int split = start;
  int noCards = 2*split;
  
  struct stateVector current;
  bool counter[noCards];
  for(int i=0; i<split; i++)
  	counter[i] = true;
  for (int j=split; j<noCards; j++)
    counter[j] = false;
  current.noCards = &noCards;
  current.split = &split;
  
  bool deck[noCards];
  int count;
  
  while(counter[noCards - 1] == false){
  	  memcpy(deck, counter, noCards);
	  count = 0;
	  split = start;
	  current.deck = deck;
	  while(split < noCards && count < limit){
		    turn(current);
		    count = count + 1;
	  }
	  if(count == limit){
		  for(int i = 0; i<noCards; i++)
		    printf("%s", counter[i] ? "1" : "0");
		  printf("\n");
	  }
	  next(counter, noCards);
  }

  return 0;
}

bool *next(bool *binArray, int length)
{
    int noBits = 0;    
    for(int place=0; place < length-1; place++)
    {
        if(binArray[place] == true) {
            if(binArray[place + 1] == false) {
                //Switch binArray[place] and binArray[place+1]
                //And move all the preceding bits down
                for(int i=0; i< noBits; i++)
                    binArray[i] = true;
                for(int i=noBits; i<=place; i++)
                    binArray[i] = false;
                binArray[place + 1] = true;
                break;
                }
            noBits ++;
        }
    }

    return binArray;
}

void turn(struct stateVector current) {
  /**
  * Red Black Vector:
  *    Takes a vector (a,b,c) where:
  *        a = binary of starting setup
  *        b = number of cards
  *        c = number of cards owned by player 1
  * I want a process that will take an input vector and output an output vector.
  **/

  int b = *current.noCards;
  int c = *current.split;

  bool p1[c];
  bool p2[b-c];

    //Setup p1 and p2 hands
  for(int i=0; i<c; i++)
    p1[i] = current.deck[i];
  for(int i=0; i<b-c; i++)
    p2[i] = current.deck[i+c];

  bool col = p1[0];
  bool gameOver = false;

  for(int i=0; i < b-1; i++) {

    if(p1[i] != col) {

      // 2*i + 1 cards on the pile

      //New Player 2 cards
      //New Player 1 cards
      //Pile

      //Player 2 has played i cards
      for(int j = 0; j < b-c-i; j++)
        current.deck[j] = p2[j + i];

      //Player 1 has played i+1 cards
      //We want to fill current.deck from b - c - i
      for(int j = 0; j<c - (i+1); j++)
        current.deck[b - c - i + j] = p1[j + i + 1];

      //We want to fill current.deck from b - c - i + c -i - 1 = b - 2*i - 1
      for(int j = b - 2*i - 1; j < b - 1; j++)
        current.deck[j] = col;
      current.deck[b-1] = !col;

      //c = length of new Player 2 cards
      c = b - c - i;
      break;
    }

    if(c < i+2) {
      gameOver = true;
      break;
    }

    if(p2[i] != col) {

      // 2*i + 2 cards on the pile

      //New Player 1 cards
      //New Player 2 cards
      //Pile

      //Player 1 has played i+1 cards
      for(int j = 0; j < c-i-1; j++)
        current.deck[j] = p1[j + i + 1];

      //Player 2 has played i+1 cards
      //We want to fill current.deck from c - i - 1
      for(int j = 0; j < b-c - (i+1); j++)
        current.deck[c - i - 1 + j] = p2[j + i + 1];

      //We want to fill current.deck from c - i - 1 + b - c - i - 1 = b - 2*i - 2
      for(int j = b - 2*i - 2; j < b - 1; j++)
        current.deck[j] = col;
      current.deck[b-1] = !col;

      //c = length of new Player 1 cards
      c = c - i - 1;
      break;

    }

    if(b-c < i+2) {
      gameOver = true;
      break;
    }
  }

  if(gameOver == true) {
          *current.split = b;
  }

  else {
          *current.split = c;
  }
  return;
}
