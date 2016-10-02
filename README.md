## Plays the Chopsticks hand game

To play against another human:
`mix run -e Numbers.Play.play`

To play against the computer:
`mix run -e Numbers.Learn.play`

Rules:
- Each player starts with 1 of 5 possible fingers up on each hand.
- On each turn, one player gives the number of up fingers on one hand to one of the other player's hands.
- If a hand has exactly 5 fingers up, all are knocked down.
- If a hand plus the given fingers is more than 5, the new number is old + added mod 5
- If a player has an even number of fingers on one hand, and no fingers on the other hand,
they may use their turn to split their fingers evenly.
- The goal is to knock both the other player's hands to 0.
