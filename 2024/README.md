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

[December 1](#december-1)

[December 2](#december-2)

[December 3](#december-3)

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
