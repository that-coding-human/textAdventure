# What is this?
This is a script that runs a textadventure on the Linux command line.
The main script is "startAdventureTime.sh". It parses an input file (e.g. "adventure.txt") which contains the textblocks for the adventure. The input file needs to be written with a certain syntax in order to make it parseable. 
The syntax for the adventure files supports the following features:
- Printing the textblocks for the adventure line by line and character by character, in order to get a more "typewriter" or "chat" like enduser feeling.
- Pausing at certain points (Sleep), e.g. to simulate that something is happening in the adventure that the player has to wait for (e.g. machines working, NPCs doing something, etc.).
- Different colors for the output text, which can be used to simulate different NPCs talking (you can assign each NPC his/her own text color).
- Waiting for user input
  - For making a choice of how to proceed in the adventure (option A, B, C, etc.), and jumping to the according textblock to continue the story.
  
# Are there enhancements planned?
Yes definitely. 
For example more comprehensive input options (e.g. for working with variable character names, or enabling more sophisticated riddles where the user needs to input a password etc.)
Another idea I am working on is to make this playable using SSH, so you can put it on a server and create a user that automatically gets "trapped" in the adventure when he connects via SSH.
 
# Why does this exist?
I found a lot of text adventure code out there. But most has been built for working only locally or being played via the old telnet. I wanted to create a universal text adventure "framework", that can:
- run different adventures based on input files that can be shared with others
- have structured input files that can be read by regular people who just want to write an adventure without too much knowledge about technical formats like json or xml. 
- provide more functionality in the input files to work with (colors, waiting actions, etc.)
- can be used to be played via SSH, plain and simple. No need to rely on the old telnet or having the need to setup a web server with javascript etc. 
 
And finally the best reason why this exists: Curiosity. I wanted to know how this can be done. 

# I wrote an adventure, can I share it?
Sure. Just create pull request and include the adventure file. I am happy to add it here.
If you are not tech savy, just open issue for this project and add the file/content there. I can add it to the repository manually for you.
