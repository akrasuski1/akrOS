# Basic akrOS Inner Workings

This document will try to explain the internal details of akrOS. This won't be in any way exhaustive - if you
want to know every smallest detail, you'll have to look at the code. But a general overview of the functions
will be very helpful for the widget developers.

## Assumptions

Since kOS in itself is single-threaded, normally you are only allowed to run just one program and that's it. 
Some users have tried to emulate parallel processing by using multiple kOS cores
(https://github.com/KSP-KOS/KOS/issues/764), but it was always hard to do. akrOS is a kOS program, that gives
user a way to emulate multiprocessing in a somewhat better way. 

In real life, we have so called *interrupts* - a way for a processor to tell processes: 
"OK, your processing time is over, now it's other process' turn." But kOS, as a simple scripting language, 
lacks this functionability. Thus, I had to make an important design decision, which pretty much defines the
akrOS: we assume that processes (and their creators) are "nice" - they only use a small amount of 
instructions, and then, they give control back to other processes. If any one process is stuck in a long loop,
the whole system will be frozen until the guilty process finally finishes its job.

This might seem like a major limitation, as you cannot use long loops. But as long as developers cooperate, the
issue has a much simpler solution. Say for example, that your process was supposed to calculate a sum of all
numbers from 1 to 100 (I know there's a formula for that, but it's an example). The ordinary code for that would
look something like this:

```
set sum to 0.
set i to 1.
until i>100{
  set sum to sum+i.
  set i to i+1.
}
```

But as I said, this code will take a couple of hundred instructions, freezing the system for a couple of tenths
of a second. The way to do this in akrOS, would be similar to this:

```
if not began{
  set sum to 0.
  set i to 1.
  set finished to false.
}
else if not finished{
  set end to min(100,i+10).
  until i>end{
    set sum to sum+i.
    set i to i+1.
  }
  if end=100{
    set finished to true.
  }
}
```

This code is a bit longer, but it works much better in akrOS environment. What it does, is it initializes all
variables, and then adds numbers to the sum *ten numbers at a time*. The code on its own might look as though it
adds only ten numbers at all (or none, for that matter), but **akrOS calls process update function every
couple of KSP updates**. That means that in the first KSP update you might calculate the sum of first ten numbers,
then akrOS will skip our process in the second KSP update, but then in the third or fourth update, you could
get two loop revolutions. This is dependent on what other processes do - if they take too long time, it means your
process will be slowed down. If they are quick enough - your process will get updates more often.

TODO:finish
