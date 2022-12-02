S" day-02-input.txt" OPEN-BLOCKS

VARIABLE BLOCK-NUMBER   ( CURRENT, NOT NEXT, BLOCK NUMBER. )
VARIABLE BLOCK-START
VARIABLE BLOCK-POS

0 BLOCK-NUMBER !
0 BLOCK DUP BLOCK-START ! BLOCK-POS !

( IF AT THE END OF THE BLOCK, FETCH THE NEXT ONE. )
: ENSURE-BLOCK ( -- )
    BLOCK-POS @ BLOCK-START @ - 1024 =  ( END? )
    IF
	BLOCK-NUMBER @ 1+ DUP           ( NUM+1 NUM+1 )
	BLOCK DUP                       ( NUM+1 START START )
	BLOCK-START ! BLOCK-POS ! BLOCK-NUMBER !
    THEN
;

: PEEK-CHAR ( -- CHAR ) ENSURE-BLOCK BLOCK-POS @ C@ ;
: GET-CHAR ( -- CHAR )
    ENSURE-BLOCK
    BLOCK-POS DUP @ DUP C@ ( @POS POS CHAR )
    SWAP 1+ ROT !
;
: ?NOT-EOF ( -- FLAG ) PEEK-CHAR 26 <> ;

( FETCH THE NEXT LINE OF INPUT, INCLUDING NEWLINE, INTO PAD.  )
( COPY CHARACTER-BY-CHARACTER TO HANDLE THE END OF THE BLOCK. )
( ASSUME NOT AT EOF.  RETURNS FALSE FOR BLANK LINES.          )
: GET-NEXT-LINE ( -- FLAG )
    PAD                           ( DST )
    BEGIN
	GET-CHAR DUP 10 <>        ( DST CHAR NOT-CR? )
    WHILE
	    OVER C! 1+            ( DST+1 )
    REPEAT
    OVER C! PAD <>  ( WRITE THE CR AS WELL )
;

( Return the winner of a game, given the two strategies.  )
( 'A' = rock, 'B' = paper, 'C' = scissors                 )
( Result is 2 for the first player winning, 1 for a draw, )
( and 0 for the first player losing.                      )
: winner ( fst snd -- res )
    ( It's a draw if they're equal, player 1 wins if    )
    ( they choose a strategy that is one more, eg A < B )
    ( or else two less, C - A = 2.                      )
    ( P1 P2 RES P1-P2 +1 mod3 )
    ( A  A  D    0     1  1   )
    ( A  B  L   -1     0  0   )
    ( A  C  W   -2    -1  2   )
    ( B  A  W    1     2  2   )
    ( B  B  D    0     1  1   )
    ( B  C  L   -1     0  0   )
    ( C  A  L    2     3  0   )
    ( C  B  W    1     2  2   )
    ( C  C  D    0     1  1   )
    - 1+ 3 mod
;

( Return the score for the first player.)
: score ( fst snd -- n )
    over swap winner  ( fst result )
    3 *               ( fst 3*result )
    + 64 -            ( remember to scale 'A'=1, etc. )
;

variable total
0 total !

: run ( -- )
    begin
	?not-eof
    while
	    get-next-line drop   ( drop the flag, assume it succeeds )

	    ( Your play is listed second and encrypted, X=A, etc.    )
	    ( Decrypt by subtracting 'W'.  There is a space between. )
	    pad dup 2 + c@ 23 -  ( pad fst )
	    swap c@              ( fst snd )
	    score total dup @    ( score @total total )
	    rot + swap !
    repeat
;

run
total @ . cr
bye
