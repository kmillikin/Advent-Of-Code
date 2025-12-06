# Advent of Code 2024

This year I'm hoping to actually make it all the way through to the end.  I've
decided to write my solutions using Scheme, because it would be a good idea to
refresh my Scheme skills for professional reasons.

I'm using Chez Scheme version 10.0.0.  I write separate solutions for each part
of each day's puzzle.  For day X, the solutions are in files `day-Xa.ss` and
`day-Xb.ss`.  A lot of time there is significant copying of code between the two
parts, specifically the input parsing code.  It would probably be better to
share this code and have the two parts in the same file.

I develop the solutions using the test input in the problem description, which
I'll put in a file named `day-X.test`.  Sometimes there are different test
inputs for parts one and two so I'll call them `day-Xa.test` and `day-Xb.test`.
My actual problem input is in `day-X.input`.

The implementations take their input from a hard-coded filename so I edit the
source code to switch between the test and real input.

I am running the solutions in a Mac terminal as scripts, by using the command

```
chez --script day-Xa.ss
```

and I've made each solution display their result before terminating.

[1](#december-1)
[2](#december-2)
[3](#december-3)
[4](#december-4)
[5](#december-5)
[6](#december-6)
[7](#december-7)

## December 1

The input consists of two columns of numbers.

### Part One

Part one is to compute the sum of the absolute value of the differences between
successive pairs of input values, one from the first column and one from the
second column.

As usual in Advent of Code, sometimes the biggest challenge is just parsing the
input.  In this case, I built a pair of lists, one for each column.  The lists
are reversed from their order in the input file because Scheme lists are linked
lists built by adding elements to the front.

The solution to part one is to simply sort the lists into ascending order using
the builtin `list-sort` procedure, and then "zip" them together by computing the
absolute value of the difference of each pair and accumulating that difference
into a running sum.  This is easily done as a "fold" in most functional
languages.

Folding is O(*n*) where *n* is the length of the list.  If we have an O(*n* log
*n*) sort procedure then the complexity of this solution is O(*n* log *n*).

### Part Two

Part two is to compute a sum of all the elements in the first column, each
weighted by the number of occurrences of that element in the second column.  So
if there is an occurrence of 5 in the first column and 3 occurrences of 5 in the
second column, that is weighted as 15.  The trick here is that there can be
multiple occurrences of the same value in the first column and they are *each*
weighted according to the count in the second column.

To do this without repeatedly traversing the list representing the second
column, I used a simple trick.  Traverse the second column once to build a hash
table mapping values as keys to their number of occurrences (in the second
column) as values.  Then traverse the first column once, multiplying each value
by the frequency in the second column and accumulating the weighted sum.

Traversing each list is O(*n*), and if our hash table insertions and lookups are
amortized constant time, then the complexity of this solution is O(*n*).

## December 2

The input consists of lines each consisting of a space separated sequence of
numbers.  To parse it, I read a line at a time into a string, and then read
numbers from the string using Scheme builtin I/O procedures.

### Part One

Part one is to count the number of input sequences that are "safe", meaning that
the sequence is either strictly ascending or strictly descending, and the values
do not differ by more than 3.

I parsed the input file into a list of sequences (represented as lists).  Both
the lines from the input file and the sequences themselves are reversed because
they are built by adding elements to the front of a Scheme list.  An important
insight is that this doesn't really matter.  The total number of safe sequences
doesn't depend on the order we inspect them, and a safe ascending sequence is a
safe descending sequence when reversed and vice versa.

I built a helper procedure `safe?` that took a pair of lists and "zipped" them
into a boolean value.  Each element of the first list was required to be greater
than the corresponding element of the second list, but not by more than 3.  I
allowed the lists to have different lengths, in which case the extra elements of
the longer one were simply ignored for a reason that you'll see later.

I looped over all the sequences in the input and counted the number that were
safe.  To determine if the sequence was ascending or descending I looked at the
first two elements.  To handle edge cases, I classified empty sequences and
singleton sequences as safe, because they do not violate the rules for safe
sequences.  (Note that I don't think there were any such sequences in the input
but I didn't even check.)

If the first element was strictly greater than the second one, I used my `safe?`
predicate on the pair of lists where the first (expected to be greater) one was
the entire sequence and the second one was its tail.  In that way, the procedure
would march down the list and its tail in lockstep comparing successive pairs of
adjacent values.

If the first element was less than or equal to the second one, I again used
`safe?` but swapped the order of the first (expected to be greater) and second
arguments.

This works because nothing was mutating the lists while I was traversing them.
There are obviously other ways to do it.  For instance, you could pass a
procedure that was applied to the difference of successive values like:

```scheme
(lambda (diff) (and (>= diff 1) (<= diff 3)))
```

An especially cute thing would be to pass a procedure that returned a boolean
and a procedure to apply to the next pair of elements.  The initial one would
determine the direction of the next one based on the relative order of the first
two elements.  Then you wouldn't have to inspect them in the driver loop.

The `safe?` procedure has to traverse the tail of the entire sequence to
determine that it's safe so it's O(*n*) where *n* is the length of a sequence.
To count the number of safe sequences we have to inspect all of them, so the
entire solution is O(*m* * *n*) where *m* is the number of sequences and *n* is
the length of the longest one.

### Part Two

Part two adds a wrinkle that we can repair an unsafe sequence by dropping one of
the values from it.  So conceptually, if the original sequence was not safe, we
would try dropping each of the values in turn until we found one that was safe
or discovered that there was no such value.

However, this does too much work.  If we've gotten, say, 100 values into a
sequence and discovered a pair of values that violate the constraints, then
there is no reason to consider dropping any of the previous 99 values---that
would always leave the violating pair in the sequence.  Likewise there's no
reason to consider dropping later values, because that would also leave this
violating pair.

So this insight means that we don't have to consider all possible values to
drop.  When we discover a violating pair of values at indexes *i* and *i*+1, we
only have to consider dropping one of those two values.

I implemented this solution and found that it didn't work, the total was too
low.  That is, it seemed like it was not repairing enough repairable sequences.

The solution did however work on the "test" input in the description.  The
organizers are very clever about this, they do not include corner cases in the
description's test input but they ensure (I believe) that corner cases occur in
the actual problem input.

I logged what the code was trying (`printf` debugging) to see if there was
anything I could spot about the sequences it didn't repair.  Randomly inspecting
them, it looked like it was doing the right thing.  So I looked on Reddit ---
not to find a solution but to try to find some insight.  I found a list of 10
"edge cases" that were all supposed to be repairable and my code only repaired 8
of them!

The problem was when the sequence could be repaired by dropping the first
element because the first pair of elements were, say, descending and the rest of
the elements were ascending.  In that case, I would detect a violation of the
descending sequence with the second and third elements.  So I would try to
repair the sequence by dropping one of those and the actual repair was to drop
the first one.

When I figured that out, I was able to get the solution.

The actual solution is pretty ugly.  I ended up reversing both the order of the
sequences in the input and the order of each sequence, so they matched the
original order.  This wasn't necessary but it helped me understand what was
happening when I was debugging it.

To try repairing a sequence, I passed a flag to the `safe?` procedure indicating
whether it was allowed to repair the sequence.  Initially it was, but if I
detected a violation I would recursively call it with the flag set to false.  I
would call it up to three times.  When a violation was discovered between
element *i* and element *i*+1 I would try (1) removing the first element, (2)
removing the *i* element if it wasn't the first, and (3) removing the *i*+1
element.

To implement this, I converted the sequence from a list to a vector and I
mutated the vector when trying to repair it, to replace the potentially dropped
element with `#f` (the Scheme false value).  I saved the original value to
restore it if that potential repair didn't work.  This seems really hacky, and I
only realized afterward that it would be nicer to pass the index of the
potentially removed element instead of mutating the vector.

My excuse is that it was late.  I actually did both the December 1 and 2 puzzles
late on December 2.

This solution will traverse each sequence up to four times, but that's still
O(*n*) where *n* is the length of the sequence, so the overall solution is
O(*m* * *n*) where *m* is the number of sequences and *n* is the longest
sequence.

## December 3

The input is a "program" with `mul` function calls, represented as a single
line.  To parse it I just read the file in as a single string and then operated
on that string.

### Part One

Part one is to perform all the well-formed `mul` operations in the input and
compute the running sum.  I implemented this with a hand-written lexer as a
finite state machine.

* In the start state, it is looking for an `m`.  If it sees an `m` it
  transitions to the `M` state.  Otherwise it stays in the start state.

* In the `M` state, it is looking for a `u`.  If it sees a `u` it transitions to
  the `U` state.  Otherwise it transitions back to the start state (to look for
  an `m`).
  
And so on.  After matching `mul(` it enters an `ARG0` state where it reads
decimal digits and computes a number until a comma is seen.  If a non-digit,
non-comma character is seen it discards the number it was building and goes back
to the start state (to look for an `m`).

Likewise, when it gets into an `ARG1` state it builds a number until it sees a
closing `)`.  Then it multiplies the two argument values it's built and
accumulates it into the sum.

If I were doing this for production code I'd probably make it data driven,
giving it some description of the input.  But my PhD supervisor warned be to
beware of frameworks with only one instance and so I just did it by hand here.

The solution has to scan the entire input so it's O(*n*) where *n* is the length
of the input.

### Part Two

Part two is like part one, but there are `do()` and `don't()` commands that
should cause the state machine to enable or disable multiplication of values and
accumulating them into the sum.

A tricky thing about testing this was that the description used a different test
string for part two.  This isn't usual.

I added a boolean flag whether multiplication was enabled, initially enabled.
Then I actually built a second finite state machine for when it was disabled ---
it only has to look for `do()`, not `mul` and numbers.  And I added states to
the original state machine to recognize `don't()` and then to disable
multiplication.

It would be possible to continue recognizing `mul` and numbers, and simply
disable multiplication and/or accumulating into the sum; but this did too much
work for my taste.

The solution still scans the entire input so it's still O(*n*) where *n* is the
length of the input.

## December 4

The input is a word search board consisting of a grid of characters.  I read a
line at a time as a string, accumulating them into a list.  I reversed the list
so it occurred in input order, which wasn't strictly necessary but it's cheap
and I thought it might help with debugging.  I converted the list of rows into a
vector so I'd have constant-time indexing.

### Part One

Part one was a word search, looking for the word "XMAS" in any orientation.  An
insight is that you have to look for all the X's and then "MAS" in any direction
from an X.

I used a simple single loop over (row,col) positions in the board.  Then, when I
found an X I used a pair of nested loops to loop over all (x,y) directions to
search for "MAS" in that direction.  Each of x and y is in the range [-1,1]
which will include the "direction" (0,0).  I didn't worry about excluding that
because there definitely won't be "MAS" there because it contains an X.

I used (x,y) directions as cartesian ones, so x was the column delta and y was
the row delta (inverted).  That doesn't really matter as long as you can use it
to generate the row and column coordinates of the eight squares around the X.

I used a helper procedure that searched for "MAS" starting at a position in a
given direction.  And I used a helper procedure for that (and the main loop)
that was a predicate that reported if the character at a given position was an
expected one.  This was especially helpful because it can just return false for
positions that are out of bounds and the rest of the code doesn't have to be
especially careful about using positions that are out of bounds.

Checking a character at a position is constant time, and then so is checking for
"MAS" from a position in a direction, and then so is checking for "MAS" in eight
directions.  The program considers every position in the board, so it is O(*n*)
where *n* is the size of the board (number of rows times number of columns).

### Part Two

Part two changed the problem so that we had to instead find a pair of "MAS" in
the shape of an X (diagonally, so not a cross).

Every such cross is centered on an A on the board, so it's simplest to search
for the A's and then check if they form a cross.  There are four such crosses
and I just enumerated them by hand and wrote a brute force predicate to check
for them.  I'm sure I could generate the possibilities somehow but I didn't
think too long about it.

The predicate looks like a lot of code, but it's pretty efficient.  `and` and
`or` are short-circuited so it doesn't do a lot more comparisons than it needs.
I could tweak it to remove the redundant comparisons, but it was fast enough on
the actual input that I didn't bother.

Checking for a so called X is constant time and so the complexity is again
O(*n*) where *n* is the size of the board, because it has to inspect the whole
board to find the A's.

## December 5

The input consists of two sections, separated by a blank line.  The first
section has "constraints" of the form X|Y where X and Y are numbers.  It turns
out that they are always two-digit numbers but I didn't rely on that.  The
second section has multiple lines with a comma-separated list of (again,
two-digit) numbers on each line.

For some reason that I don't yet know, Chez Scheme's `get-datum` procedure
parses the floating point number `47.0` from the string `"47|53"`, so I couldn't
rely on `get-datum`.  Instead, I wrote my own simple non-negative integer parser
from a given input port.  The parser is hacky and consumes the character after
the number if any, but that's OK because it means I don't need to write code to
explicitly skip the bar and comma characters in the input.

### Part One

The constraint X|Y means that if both X and Y occur in a sequence, then Y must
occur after X.  A way to think of this constraint is to think of when it is
violated.  It is violated exactly when Y occurs before X in a sequence.  It's OK
if X occurs before Y and it's OK if either X or Y or both do not occur at all.

For a given X there can be multiple constraints X|Y.  When parsing the first
section of the input file, I built a hash table mapping the number X to the set
of numbers Y that appeared in such constraints.  Scheme doesn't have builtin
sets, so I implemented my own.  I chose a representation as a hash table mapping
the element as key to the value `#t` (boolean true).  The value doesn't actually
matter, because the presence of the key indicates that the element is a member
of the set.  This representation gives amortized constant time lookup and linear
operations like set intersection.

I parsed the sequences into a list of lists.

The problem asks us to sum up the middle number in each of the sequences that
satisfy the given constraints.  To implement this, I used a pair of nested loops
--- the outer one over the sequences and the inner one over each sequence in
turn.

To check for violation of a constraint X|Y, we need to check that if X occurs in
a sequence, Y does not occur before it.  To implement this, I built a set of the
numbers seen so far while iterating a sequence.  Then we can check all the
constraints for a given X by getting the set of all such Y and checking that the
intersection of these Ys and the already seen numbers is empty.  The only set
operation I needed was the predicate `intersection-empty?`.  For convenience (to
avoid allocating empty hash tables), I allowed the boolean false value to also
represent an empty set.

The last little bit is to find the middle element of a valid sequence.  I
guessed that the sequences would always have an odd length (which turns out to
be correct) and verified it with the example input in the description and a
"random" (the first two) selection of inputs in my actual problem input.

To find the middle element of a list with on odd length, I used the "hare and
tortoise".  I marched a pair of pointers down the list, with the hare taking two
steps for every one step that the tortoise takes.  The tortoise is initially the
first element of the list and the hare is initially the tail of the list.  When
the hare reaches the end of the list, the tortoise is the middle element.

If `hashtable-contains?` is constant time and `hashtable-keys` (which produces a
vector of the keys) is linear in the number of keys, then the
`intersection-empty?` predicate is linear in the size of the first set (the
already-seen elements of a sequence), so O(*n*) where *n* is the length of a
sequence.  It is called for every element of a valid sequence, so O(*n*^2).
Finding the middle element of a sequence is O(*n*), which we can ignore because
it grows more slowly than O(*n*^2).  All the sequences are checked, so the
algorithm is O(*m* * *n*^2) where *m* is the number of sequences and *n* is the
length of the longest sequence.

(Note when I sketch the complexity of my solutions, I ignore the work it takes
to parse the input file.  If I were being more rigorous, I shouldn't do that.)

### Part Two

Part two flips the problem around.  Instead of checking for valid sequences, we
are looking for the invalid ones.  The code that finds valid sequences can be
used to find invalid ones simply by negating the `intersection-empty?` test.

However, for part two we also need to repair the invalid sequences by putting
them in a correct order according to the constraints, before computing the sum
of the middle elements.

The insight here is that this just consists of sorting the sequences.  Scheme's
`list-sort` procedure takes a comparison procedure that takes a pair of elements
and returns true if the first must come before the second in the sorted list.
That is, if the elements are X and Y, the procedure returns true when there
exists a constraint X|Y.

This is easy to check with my solution --- get the list of all such Ys and check
if the given Y is an element.

Part two does all the same work as part one, plus it sorts the invalid
sequences.  The comparison function will be called up to O(*n* * log *n*) times.
Presuming that hash table lookup is constant time, then sorting will be O(*n* *
log *n*).  This grows more slowly than O(*n*^2) to check the sequence, so the
complexity is again O(*m* * *n*^2).

## December 6

The input is a map containing empty spaces (.), obstacles (#), and a single
guard pointing "north" (^).  I read this into a vector of vectors of characters.

### Part One

The guard marches in the direction they are pointing, until they walk off the
map.  If there is an obstacle in front of them, then they turn 90 degrees to
their right (clockwise) instead of taking a step.

The problem of part one is to count the number of (unique) empty spaces that the
guard will walk through before they leave the map.

I simulated the guard's walk until they left the map.  If their next step would
take them off the map, the simulation loop terminated and reported the count of
unique spaces visited.  If their next step would take them into an obstacle, I
rotated their direction 90 degrees to the right and continued walking from the
same position with the new direction.  If their next step would take them into
an empty space, I mutated the map to replace the dot (.) with an X, so that I
would not count that space again.  Then I incremented the count and continued
walking from the new position (with the same direction).  If their next step
would take them into a space they had already visited, I continued walking from
the new position and did not increment the count.

Developing in Scheme has been very pleasant because of the REPL (the interactive
Read Evaluate Print Loop).  I've just typed bits of the solution and tested them
interactively.  Most days, my program actually runs correctly the first time I
put it all together, because I've interactively tested and fixed the individual
pieces.

For this one, I had a small bug that I rotated the guard incorrectly from one
orientation (turning left when they were facing east).  I wrote a simple
procedure to display the map because Scheme's `display` procedure did not align
the rows nicely, and the bug was immediately apparent.

The complexity of this solution is the number of steps in the guard's path
before they leave the map.  Presuming that the walk terminates, that is at most
four times the number of empty spaces in the map (they could enter each space
multiple times, but always in a different direction if they don't get caught in
a loop).  So it's O(*n*) where *n* is the size of the map.

### Part Two

For part one, the guard's walk terminated by walking off the map.  Part two of
the task asks us to find ways to place a single obstacle in the map to cause the
guard's walk to enter a loop (not terminate).  The task is to count the number
of different ways we can place such an obstacle.

The insight you need is that the guard will loop if they ever enter a space they
have been in before, facing the same direction as before.  So it's not enough to
record the spaces the guard has walked through, we also need to record the
direction they were facing.

I tweaked my part one solution in some small ways.  Instead of representing the
direction the guard was facing by a pair of row delta and column delta (like
(-1,0) for north), I just used a character in {`^`, `>`, `V`, `<`}.  Then I
needed helper functions to rotate the direction (as before but with the new
representation) and to convert the direction to a position delta.

Then for the solution, I looped over all the empty spaces in the map.  For each
one, I copied the map because I was going to mutate it during the walk.  For
every space the guard walked through, I stored the list of directions they were
facing.  Then, if they walked off the map I could report false (no loop).  If
they encountered an obstacle, I could rotate them as before and continue
walking.  If they entered an empty space, I mutated the copy of the map to
replace the dot (.) with the singleton list of their direction.  If they entered
a space that they had been in before (represented by a list of directions), and
facing in a direction that they had been in before, I could report true (a loop
was detected).  Otherwise, I mutated the copy of the map to add the current
direction to the historical list of directions and to continue walking.

Scheme is also particularly attractive for solutions like this.  I didn't have
to define a bunch of type definitions to use a representation of a map where
some cells contained characters and some cells contained lists of characters.

Checking the map is O(*n*) where *n* is the size of the map.  Either the guard
walks off the map as before, or enters a loop.  In either case, they can only
visit at most the number of empty spaces in the map (up to four times each
space).  Placing obstacles in each emtpy space and checking the map gives a
total complexity of O(*n*^2).  This program took a second or two to run ---
noticably more than checking a single walk but still fast enough.

## December 7

The input is a number, a colon, and then a space separated list of numbers.

### Part One

The challenge for part one is to see if you can place additon (+) and
multiplication (*) operators between the numbers in the list to the right of the
colon, so that it evaluates (from left to right, ignoring the order of
operations) to the number on the left of the colon.

We need to compute the sum of the results of the input lines that are
"satisfiable", where there is at least one placement of addition and
multiplication operators that makes a valid equation.

This involves backtracking: we can try inserting an addition operator between a
pair of numbers and see if we can insert operators in the rest of the line to
make it satisfiable.  If not, we should backtrack and try inserting a
multiplication operator.

The easy way to do this in Scheme is with continuations.  I wrote a
`satisfiable?` procedure that used a helper that took a pair of continuations.
The first was a "success" continuation to apply if the equation was satisfiable,
and the second was a failure continuation to apply if it wasn't.  When we had
placed operators in every position, we chould apply one of these continuations.

The helper would try to place an addition operator, and then recur on the rest
of the input line.  The success continuation was passed unchanged, but the
failure continuation was to try to place an multiplication operator instead,
with the original success and failure continuation that was passed.

Note that the success continuations never change, so they're actually
unnecessary.  Instead of passing a continuation that was always `(lambda () #t)`
and applying it, I could have just used the value `#t`.

### Part Two

Part two introduced a third possible operator, concatenation.  I thought about
implementing a clever version of concatenation with arithmetic operations, but
it was fast enough to convert both numbers to strings, append the strings, and
convert back to a number.

The solution from part one was easily modified to backtrack twice (so to try all
three possible operators at a position).

## December 8

The input was a map with antennas labeled with digits or letters, and dots (.)
representing empty spaces.

### Part One

Part one was to find "antinodes" between all pairs of same-labeled antennas.
Each pair created two antinodes, on the same line with them and the same
distance away as the distance between the antennas.  Some of these could lie
outside the map, and are irrelevant.  That challenge was to count the number of
unique antinode positions on the map.

To avoid searching the map for pairs of antennas, I looped over the map once to
build a hash table mapping the antenna label to all pairs of coordinates for
antennas with that label.

Then I could loop over the hashtable values (lists of coordinates) and consider
each pair exactly once (by considering for each antenna, only the ones that came
later in the list of same-labeled antennas).  That is, my solution was three
nested loops.  The outer looped over the hash table keys (the antenna labels).
The middle loop looped over all antennas with a given label.  The inner loop
looped over all antennas with that same label that came later in the list of
antennas.

To count unique positions, I made a copy of the map (to mutate it), and then
marked antinodes with hash characters (`#`) when they were found.  I incremented
a counter whenever a new antinode was found.

### Part Two

Part two changes the problem so that antinodes occur evenly spaced all along the
line between a pair of antennas.  My solution was a modification of the three
nested loops.  The body of the previous inner loop had a pair of (non-nested)
loops.  I computed the direction vector from antenna X to antenna Y with the
same label.  Then I looped in that direction from Y until I left the map,
marking antinodes and counting them if they were new.  After that I looped in
the negative direction vector from X until I left the map.

## December 9

The input is a single line representing a disk as a sequence of digits.
Alternating digits represent the size of files or the size of free space, with a
file coming first.  Because they are digits, files and free space are limited to
have a size of 9 or less.  Free space can have size 0.  The files implicitly
have a numeric ID which is their position in the sequence of files.

### Part One

The task of part one is to compress the disk by moving files to the "left"
(beginning).  Files can be split to be packed into the free space.  To make the
result deterministic, the problem specifies that files should be moved from the
"right" (end) first.

I built a map of the disk as a vector (just as shown in the problem
description), where I expanded each file into a contiguous sequence with length
the file length and each element represented by the file ID.  Free spaces were
represented by dots.

Then the solution is to sweep a pair of indexes over the disk, one from the left
and one from the right, until they meet.  The left index skips files to find the
next free space, and the right index skips free space to find the next file
block.  When a pair of free space and file block are found, they are swapped on
the disk.

The challenge asks us to compute a checksum by weigthing each file ID with its
position on the disk, which can be done in a loop over the disk after it is
compacted.

### Part Two

Part two is a modification of the first part where files cannot be split.
Instead, they must be moved (again from the right) into the leftmost free space
that can fit them.

To solve this, I built a free list of empty spaces in order from left to right.
Each free space was represented by its starting position on the disk and its
size.  I also built a list of files to consider in turn, represented by starting
position, size, and file ID in order from right to left on the disk.  This list
was the list of files to consider moving.

To place a file, I would iterate the free list from the beginning until I found
a free space to the left of the file, that was large enough to hold it.  If
there was no position, the file did not move.  If a position was found and the
file fit exactly, then that free space was removed from the free list.  If the
file was smaller than the free space, the free space was "split" and the
remainder was put on the free list in place of the original (maintaining the
left to right order of free spaces).

My initial solution worked for the test input, but gave a result that was too
high for my actual input.  There were 1000 files in the actual input.  I first
tried logging all the intermediate disk maps and the free lists, but that was a
file that was several GB, took a long time to write, and crashed emacs
(actually, crashed my whole laptop) to try to open.

So instead, I randomly sampled specific indexes to look for anomalies.  I found
some suspicious spots and it turned out that I was actually moving files to the
right if there was a free space for them.  When I fixed this bug I had the
correct answer.

## December 10

The input is a map consisting of a rectangular grid of digits.  I read this into
a vector of vectors.

### Part One

We are asked to find paths in the map starting from a zero digit, ascending in
single steps, and reaching a nine digit.  The task is to count from each zero,
how many distinct nines we can reach, and sum up those scores.

I initially wrote a solution that counted distinct paths, which is pretty easy.
Use a procedure that finds paths reaching a nine from a position in the map.  If
the position is a nine, then there is one such path.  Otherwise, it is the sum
of the paths from each neighbor that is one higher than the current path.
That's just a simple recursive procedure.

However, the task is actually to find distinct nines.  I could have modified my
initial solution to keep a set of the coordinates of the nines to avoid
duplicates, but that does too much work for my taste.

The "correct" solution is DFS (depth-first search), to traverse the path
starting from a zero, keeping a worklist of coordinates yet to visit, and
marking coordinates when they were first reached on a path.  Remove coordinates
from the worklist until it is empty, if a coordinate has already been visited
discard it, otherwise explore from there by adding all the neighbors (that are
one higher in elevation) to the worklist.

Then we can loop over the input map and perform DFS starting from each zero,
counting the number of unique nines that were reached.

### Part Two

Part two is to find all paths, which I had already implemented.  You don't get
to see part two until you've solved part one, so I had deleted that code.

I quickly rewrote it and had a good solution.

## December 11

The input is a single line with a space separated sequence of numbers.

### Part One

There is a rule to transform each number, sometimes increasing and sometimes
splitting into two numbers and decreasing.

The problem was to run the rule over the input numbers 25 times.  I wrote a
`transform` procedure that transformed a number into a list of numbers (in case
it was split in two).  Then I wrote a `blink` procedure that took the count 25
and transformed all the numbers and then recursively blinked 24 times and so on.

Transforming all the numbers can be done by `map transform` over the list, which
gives a list of lists.  One of my favorite things in Scheme is that `apply
append` flattens a list of lists by one level.

The challenge was to count the length of the sequence after blinking 25 times.

### Part Two

The task for part two was exactly the same as part one except to blink 75 times.
When they do that, it's because your first algorithm was probably exponential
and they're going to expose that.

And in fact, trying my solution with 75 didn't terminate after a reasonable
amount of time.

To understand what's happening, we have a "forest" starting from the initial
sequence.  Each number in the initial sequence generates an infinite tree in the
forest.  For part one, we were generating these trees to a depth of 25.

My solution of mapping a single step transormation over the forest at each step
was generating it breadth first.

So to fix the slow running time, we need to memoize (record the results of) some
repeated computation and hope that we have enough similarity in the forest we're
generating that we can avoid drastic amounts of computation.

I changed my solution to generate trees depth-first.  The problem doesn't ask
for the specific forest, only how many nodes it has at a specific depth (in this
case, 75).  So I wrote a function that took a number and a depth, and returned
the number of nodes in the tree rooted at that number at the given depth.

The first number in my input was 7568, so my procedure `(blink-count 7568 75)`
would just report how many nodes were in the tree rooted at 7568 at a depth of
75.

Then I recorded these results in a hash table, mapping pairs (of the root number
and depth) to the number of leaves at that depth.  When `blink-count` was
called, it would first check if it's seen the same arguments and simply return
the result.  Otherwise it would compute the result and record it in the hash
table before returning it.

This worked, it was really quite fast.
