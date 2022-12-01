# Advent-Of-Code
Solutions to Advent of Code

## 2022 Advent of Code

This year I'm implementing the solutions in Forth.  Why Forth?

I have a history with Forth.  My first computer was a Commodore VIC-20 that we
got when I was a kid, in the early 80's.  My brother and I mostly used it for
playing cartridge games.  My Dad would occasionally pick up new game cartridges
for us from the bargain bin at Toys-R-Us.

One of these cartridges was VIC Forth (the HES version, there is a different
version that confusingly is also called VIC Forth).  Here is a PDF of
[the manual](https://ia600408.us.archive.org/14/items/VIC_Forth_1982_HES/VIC_Forth_1982_HES.pdf).

After I got over my initial disappointment (that it wasn't a game), I was hooked
on programming in a way that BASIC never did for me.  The reason I was so
fascinated is because Forth invited me to understand the way that it was
implemented.  (And so my career has been as a programming language implementer.)

I'm running my solutions using gforth (GNU Forth), but I'm going to try to stick
to the words in the VIC Forth manual so that they could conceivably be run on a
VIC-20 or emulator.

### Running the Code

First install gforth.

The programs are self-contained.  They will take their input from a hardcoded
file.  You can run them as a simple script, for example:

```shell
gforth day-01-1.fs
```
