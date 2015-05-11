# Advanced widget tutorial

In this tutorial, I will introduce a couple of new concepts, using an example of calculator widget. We will want
to prompt user for the first number, then operation (one of: +, -, *, /, ^), then seond number, and finally display
calculated result. Simple enough. If you were doing it "normal" way - without akrOS - the code would look somewhat
like this:
```
local num1 is prompt_for_number().
local op is prompt_for_option(list("+","-","*","/","^")).
local num2 is prompt_for_number().
local result is calculate(num1,op,num2).
print "The result is "+result.
```

I hope you understand the above code, since it will be the basis for further discussion. Don't worry about all the
functions right now - they are just abstractions, keeping the code simple.

## Run modes

The above code contains a couple of main process states: waiting for first number, waiting for operator, waiting
for second number, displaying result. The akrOS processes are ran in an infinite loop, so we need to somehow
differentiate between them. The easiest way to do this, is by using *run modes* - variable, usually string one,
denoting current state. So the update function would look like:
```
if run_mode="prompt_number1"{
	set num1 to prompt_for_number().
	set run_mode to "prompt_operator".
}
else if run_mode="prompt_operator"{
	set operator to prompt_for_option("+","-","*","/","^").
	set run_mode to "prompt_number2".
}
else if
	...
```
and so on. The code might look broken - only one `if` will be fulfilled at any time, and even if `run_mode` is
changed, the next `if` won't be ran. But recall that the above code is ran in a loop, so in the next iteration,
that next `if` will be ran, so there will be no problems with that. Just remember to restore `run_mode` from 
process structure in the beginning of the update function and save it for later in the end of it.

## Child processes

Since the whole widget code in akrOS is always ran in an update loop, we cannot simply use the above code, because
it would hang the whole system until you finally choose an option - so that your, for example, auto-pilot won't be
able to keep your plane upright while you input your numbers. We need to do something different.

akrOS omes with a couple of simple utility widgets. One of them is `job_number_dialog`, and the other `job_menu`.
First of them prompts user for a number, and the second one for a choice from the list. They are processes like
any other widget, with just one difference - they accept some more arguments in their constructor, so they
cannot be ran from the main menu - running number dialog from main menu would be nonsense - what would the input 
number mean, after all?

So, we can use number dialog as a first part of our program. It should be ran as a *child process*. In order
to do this, you should remember child process' structure as one of the fields in your own process, for example
as `process[1]`. In the very first frame, you should create that child process.

TODO: finish
