# akrOS user overview

## Title screen

![Title screen](http://i.imgur.com/f0p8U5s.png)

This is the title screen of akrOS. The first thing you can see, is that the whole terminal screen is divided into
several parts. They are generally called *windows* in akrOS. Since akrOS uses graphical user interface, there won't
be any command typing - you do everything via action groups.

The main things visible on the screen since the beginning, are:
1. The title screen - it's the biggest window with akrOS logo and short instruction printed on it. It says: "Press
9 to start." So go ahead and press it. If nothing has happened, don't worry - everything is fine. Since kOS mod 
captures all the keystrokes while it is focused, you can't do anything in akrOS when terminal is active. So, if you
want to continue, you have to first click outside the terminal window (so that it loses focus), and only then press
the 9 button.
2. Status bar - this is a small bar shown in the botttom of the screen. It should always contain a short tip
about currently selected program.
3. Focus tip - this is the small rectangle in bottom right corner. It will always stay there, so if you ever forget
the focus controls, you can find it here.

## Program selection

Let's say you managed to do what I asked you in the beginning - pressed 9 with the terminal out of focus. Then, a
main menu should appear:

![Main menu](http://i.imgur.com/fMX5XW5.png)

Notice how the status bar changed - since we're no longer having title screen active, the original tip is useless.
Instead you should know the controls used in main menu: action groups 7, 8 and 9.

Let's say you are now interested in getting the result of some mathematical expression. A calculator is a widget
made just for that purpose. Go ahead and select it from menu by pressing AG8 a couple of times, and when 
"Calculator" is selected, press AG9 to confirm your choice.

## Window selection

You should now see the following screen:

![Window selection](http://i.imgur.com/ieIdXog.png)

The akrOS asks you where you wish to run the calculator. There are three windows currently available. You can get
the number of each window by looking at its upper left corner - there should be a window number written like this:
`[1]`. You could also run the program in the background, but it won't make much sense, since you will want to
see the result of your calculation.

Thus, you should choose something else - for the purpose of this tutorial, let's say you have chosen window 1.
Press AG9 to select it, just as in the program selection screen.

## Focus mechanics

You should now see the following screen:

![Unfocused](http://i.imgur.com/LnvoojU.png)

You may wonder how to input the first number you are prompted for. The status bar hasn't changed into a calculator
tip, as you might have expected. This is because of one more thing I haven't told you yet - the focus mechanics.
You might have noticed that the first window (main menu) has a much thicker border than all the others. This is
because it has *focus*. Only the focused window can gather user input. Thus, if you want to type a number
for the calculator, you'll need to switch focus to its window. As you remember, there is a tooltip on this topic
in the bottom right corner - "Use 1/2 to move focus." If you press AG1 or AG2, the focus will shift cyclically
around all the visible windows.

## Focused calculator

![Focused](http://i.imgur.com/PzOMoP4.png)

This is the akrOS with calculator screen focused. You can notice that now, the status bar shows calculator
controls. Go ahead and experiment with them. When you're ready, accept your number - you will be prompted for an
operator, and then for a second number. Finally, you will be shown the result of your calculation.

Note that at any moment you could switch focus to another window. You can, for example, open the "Vessel stats"
in window 2 and then go back and type your numbers for calculator. The vessel stats will update at the same
time as you type!
