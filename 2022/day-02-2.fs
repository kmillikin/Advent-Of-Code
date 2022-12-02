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
: ?NOT-EOF ( -- FLAG ) PEEK-CHAR 26 = 0= ;

( FETCH THE NEXT LINE OF INPUT, INCLUDING NEWLINE, INTO PAD.  )
( COPY CHARACTER-BY-CHARACTER TO HANDLE THE END OF THE BLOCK. )
( ASSUME NOT AT EOF.  RETURNS FALSE FOR BLANK LINES.          )
( THE COUNT NOT INCLUDING THE NEWLINE IS IN THE FIRST         )
( CHARACTER POSITION.                                         )
: GET-NEXT-LINE ( -- FLAG )
    PAD 1+                        ( DST )
    BEGIN
	GET-CHAR DUP 10 = 0=      ( DST CHAR NOT-CR? )
    WHILE
	    OVER C! 1+            ( DST+1 )
    REPEAT
    OVER C!  ( WRITE THE CR AS WELL )
    PAD 1+ - DUP  ( COUNT COUNT )
    PAD C! 0 >  ( STORE THE COUNT, RETURN THE FLAG )
;

( RETURN THE WINNER OF A GAME, GIVEN THE TWO STRATEGIES.  )
( 'A' = ROCK, 'B' = PAPER, 'C' = SCISSORS                 )
( RESULT IS 2 FOR THE FIRST PLAYER WINNING, 1 FOR A DRAW, )
( AND 0 FOR THE FIRST PLAYER LOSING.                      )
: WINNER ( FST SND -- RES )
    ( IT'S A DRAW IF THEY'RE EQUAL, PLAYER 1 WINS IF    )
    ( THEY CHOOSE A STRATEGY THAT IS ONE MORE, EG A < B )
    ( OR ELSE TWO LESS, C - A = 2.                      )
    ( P1 P2 RES P1-P2 +1 MOD3 )
    ( A  A  D    0     1  1   )
    ( A  B  L   -1     0  0   )
    ( A  C  W   -2    -1  2   )
    ( B  A  W    1     2  2   )
    ( B  B  D    0     1  1   )
    ( B  C  L   -1     0  0   )
    ( C  A  L    2     3  0   )
    ( C  B  W    1     2  2   )
    ( C  C  D    0     1  1   )
    - 1+ 3 MOD
;

( RETURN THE SCORE FOR THE FIRST PLAYER.)
: SCORE ( FST SND -- N )
    OVER SWAP WINNER  ( FST RESULT )
    3 *               ( FST 3*RESULT )
    + 64 -            ( REMEMBER TO SCALE 'A'=1, ETC. )
;

( MAP A DESIRED OUTCOME X=LOSE, Y=DRAW, Z=WIN AND THE OPPONENT'S )
( PLAY INTO YOUR STRATEGY A, B, OR C.                            )
: STRATEGY ( OUT OPP -- STRAT )
    ( THE IMPLEMENTATION OF WINNER IS: )
    (     STRAT - OPP + 1 MOD 3 = OUT  )
    ( SOLVE THIS FOR STRAT MOD 3       )
    ( IT IS OUT+OPP-1                  )
    + 1- 3 MOD 65 +    ( MAP IT BACK TO A, B, C )
;
    

VARIABLE TOTAL
0 TOTAL !

: RUN ( -- )
    BEGIN
	?NOT-EOF
    WHILE
	    GET-NEXT-LINE DROP   ( DROP THE FLAG, ASSUME IT SUCCEEDS )

	    ( DESIRED OUTCOME IS LISTED SECOND. )
	    ( THERE IS A SPACE BETWEEN.         )
	    PAD 1+ DUP C@           ( PAD OPP )
	    SWAP 2 + C@             ( OPP OUT )
	    OVER STRATEGY           ( OPP STRAT )
	    SWAP SCORE TOTAL DUP @  ( SCORE @TOTAL TOTAL)
	    ROT + SWAP !
    REPEAT
;

RUN
TOTAL @ . CR
BYE
