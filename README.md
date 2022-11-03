# Trivia Unite Together
 A trivia game made in ComputerCraft designed for 1-4 Players. Powered by [OpenTDB](https://opentdb.com/).
 A multiplayer fork of [Trivia Unite](https://github.com/cklidify/CCTriviaUnite).
 
 ![Showcase](/screenshots/showcase.gif)
 
 [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
 
## How it works
 Using the [OpenTDB API](https://opentdb.com/api_config.php), the game receives 10 questions at the start of the game.
 Each round, the game will type out a question, and present you with either True/False or Multiple Choice options.
 The quicker you answer, the more points you receive. The player with the highest score wins!

## Installation
 First you must create a setup similar to the image below
 
 (The position of the main monitor **must** be to the right of the computer)
 
 ![Guide](/screenshots/setup.png)
 
 Then enter the Advanced Computer, and enter `pastebin run AzxtVKfJ` into the terminal.
 
 Once it's been installed to your Computer, tun the game by entering `triviaunitetogether` into the terminal.

 If the game does not start properly, terminate the program with CTRL+T, then enter `edit triviaunitetogether` and look for the following code block:
 ```
 local podiumNames = {
    "monitor_0", "monitor_1", "monitor_2", "monitor_3"
 }
```
Replace `"monitor_x"` with the names of the 4 podium monitors in order of Player 1 to Player 4. You can get the name of each monitor in chat when you right click on their respective wired modems.
