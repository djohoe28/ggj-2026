level based puzzle game
discrete grid of 60 by 60 tiles
two players
some objects in the level are visible to both players
some objects are visible only to one of the players

input
- input: P1 wasd p2 arrow up, arrow left, arrow down, arrow right
- input: R - restarts the layer

objcets:
P1 - moves with P1 input (more then 1 is possibe)
P2 - moves with P2 input
BOX - a movable object, may be pushed by either player or another moving object
|          Object        | C P1 | C P2 | P P1 | P P2 | S P1 | S P2 |
|------------------------|:----:|:----:|:----:|:----:|:----:|:----:|
| mutual box             | true | true | true | true | true | true |
| P1 prv box             | true | fals | true | fals | true | true |
| P2 prv box             | fals | true | fals | true | true | true |
| P1 gst box             | true | fals | true | fals | true | fals |
| P2 gst box             | fals | true | fals | true | fals | true |
| P1 hlp box             | true | fals | fals | true | true | true |
| P2 hlp box             | fals | true | true | fals | true | true |

