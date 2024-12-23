# MIPS Dots & Boxes User Manual
## Starting the game
a.	In order to run this game, you must first ensure that you have Java 8 installed on your computer. In the case that this has not been done, follow the instructions on https://www.java.com/en/download/
b.	After it has been installed, double click on the MarsPlusPlus.jar file that exists within the submission. Wait until the Editor for MIPS pops up. Optionally, go to the menu and enable Dark Theme* (Settings -> Dark Theme (Applied on Restart)), one of the new features to help MARS be easier on the eyes. After selecting this, please close MARS, and then proceed to reopen it. You should see a new Dark Theme.
c.	Load the three .asm files located within the submission by pressing File -> Open and then select each file separately.
d.	Next, open the Bitmap Display by going to Tools -> Bitmap Display on the top menu. Once this opens, select 1, 1, 512, 512, and 0x10040000 (heap). The screen should look like below. If the entire black space is not visible, please resize the popup window to show the entire black grid.
e.	Next, open the MMIO simulator. To do this, go to Tools -> Keyboard and Display MMIO Simulator, and open it up.
f.	Press “Connect to MIPS” on both of the popups and position the two popups as follows.
g.	Next, go to Settings -> Assemble All Files in Directory and enable it. 
h.	Finally, select BitmapExample.asm press the Wrench and Screwdriver icon to assemble the code, and then press the play button. The game will immediately begin. You know it is working when a grid is shown and a blinking line appears in the top left corner.
## Playing the game
a.	The goal of this game is to obtain more boxes than the computer opponent that you are playing against. In order to obtain a box, you must draw the last line surrounding that box. For example, imagine a box that has only 3 sides surrounding it. If you place the 4th line, that box will then be marked as yours, and add one point to your score. Whenever a box is scored, the player who scored it will be allowed to move again. The players alternate turns (save for the move again rule) until all boxes have been claimed. The final score is calculated, and the winner is the one with more boxes.
b.	The primary controls of this game involve only 6 keys on the keyboard. Make sure that before you type anything in, you have the MMIO Simulator popup as the active tab, and have the bottom text input area highlighted. Once you have ensured this, proceed.
c.	The 6 Keys used by this game are W, A, S, D, Space, and Enter
i.	W,A,S,D are used by the player to move their line selector around the screen. W will move the selector up, A will move it left, S will move it down, and D will move the selector to the right. There is bounds checking that will prevent you from moving this selector outside the grid bounds.
ii.	The Space key is used to change the orientation of the line from horizontal to vertical and vice versa. This will take any horizontal (vertical resp.) line and flip it to a vertical (horizontal resp.) orientation.
iii.	The Enter key is used to confirm the choice that the selector is currently hovering over. This will then cause the Computer to make a move, and then control returns to the player.
## Ending the game
a.	When all boxes have been filled in, a dialog box will open. Depending on whoever scored the most boxes (either the player or the AI), a victory or defeat message will appear.
b.	After this, you may simply click “Reset” on both the Bitmap Display popup and the MMIO popup, reassemble BitmapExample.asm, and then play again! 
c.	If you would not like to play again, simply close the popups and MarsPlusPlus.jar.
