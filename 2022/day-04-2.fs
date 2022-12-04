S" day-04-input.txt" OPEN-BLOCKS

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

( PARSE A NUMBER AT ADDR ASSUMING AT LEAST ONE DIGIT. )
( RETURN THE ADDRESS ONE PAST THE LAST DIGIT.         )
: PARSE-NUMBER ( ADDR -- ADDR N )
    DUP C@ 48 -  ( ADDR N )
    SWAP 1+      ( ACC ADDR+1 )
    DUP C@       ( ACC ADDR+1 C )
    ( ASCII DIGITS ARE IN THE RANGE 47..58 EXCLUSIVE. )
    BEGIN
	DUP 47 > OVER 58 < AND
    WHILE
            48 -            ( ADDR+I ACC N )
	    ROT 10 * +      ( ADDR+I 10*ACC+N )
	    SWAP 1+ DUP C@  ( ACC ADDR+I+1 C )
    REPEAT
    DROP SWAP
;

( PARSE THE LINE AT PAD, EXTRACTING FOUR DIGITS WITH A )
( SINGLE DELIMINTER BETWEEN EACH OF THEM.              )
: PARSE-LINE ( -- N1 N2 M1 M2 )
    PAD 1+ PARSE-NUMBER
    3 0
    DO SWAP 1+ PARSE-NUMBER LOOP
    SWAP DROP
;

( TRUE IF THE INTERVALS OVERLAP )
: OVERLAPS ( N1 N2 M1 M2 -- FLAG )
    >R SWAP 1+ <  ( N1 M1<=N2 R:M2 )
    SWAP R> 1+ <  ( M1<=N2 N1<=M2 )
    AND
;

VARIABLE TOTAL
0 TOTAL !

: RUN ( -- )
    BEGIN
	?NOT-EOF
    WHILE
	    GET-NEXT-LINE DROP
	    PARSE-LINE
	    OVERLAPS
	    IF
		1 TOTAL +!
	    THEN
    REPEAT
;

RUN
TOTAL @ . CR
BYE