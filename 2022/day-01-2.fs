S" day-01-input.txt" OPEN-BLOCKS

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

VARIABLE MAX1
VARIABLE MAX2
VARIABLE MAX3
VARIABLE ACCUMULATOR

0 MAX1 !
0 MAX2 !
0 MAX3 !
0 ACCUMULATOR !

( STORE THE TOP THREE OF MAX1 MAX2 MAX3 AND THE ARG IN THE MAXN )
: TOP3 ( N -- )
    MAX3 @ SWAP MAX2 @ SWAP MAX1 @  ( MAX3 MAX2 N MAX1 )
    OVER OVER >                     ( MAX3 MAX2 N MAX1 N>MAX1 )
    IF
	( N > MAX1 > MAX2 )
	MAX2 ! MAX1 ! MAX3 ! DROP
    ELSE
	DROP OVER OVER <            ( MAX3 MAX2 N MAX2<N )
	IF
	    ( MAX1 > N > MAX2 )
	    MAX2 ! MAX3 ! DROP
	ELSE
            SWAP DROP SWAP OVER <   ( N MAX3<N )
	    IF
		( MAX1 > MAX2 > N )
		MAX3 !
	    THEN
	THEN
    THEN
;

: RUN ( -- )
    BEGIN
	?NOT-EOF
    WHILE
	    GET-NEXT-LINE
	    IF
		PAD NUMBER DROP       ( N; ASSUME SINGLE WIDTH )
		ACCUMULATOR DUP @ ROT ( @ACC ACC N )
		+ SWAP !
	    ELSE
		ACCUMULATOR @ TOP3
		0 ACCUMULATOR !
	    THEN
    REPEAT
;

RUN
MAX1 @ MAX2 @ + MAX3 @ + . CR
BYE
