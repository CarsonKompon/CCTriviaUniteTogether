# Trivia Unite Together
 A trivia game made for ComputerCraft designed for 1-4 Players. Powered by [OpenTDB](https://opentdb.com/).
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
 
 Then enter the Advanced Computer, and enter `pastebin get EwswWL4S triviatogether` into the terminal.
 
 Once it's been downloaded to your Computer, run the installer by entering `triviatogether` into the terminal.
 Your computer will download all the neccessary APIs, Images, and LUA files, and automatically reboot when it's done.

 If the game does not start after rebooting, terminate the program with CTRL+T, then enter `edit startup.lua` and find the following code block:
 ```
 local podiumNames = {
    "monitor_5", "monitor_4", "monitor_6", "monitor_7"
 }
```
Replace `"monitor_x"` with the names of the 4 podium monitors in order of Player 1 to Player 4. You can get the name of each monitor in chat when you right click on their respective wired modems.
