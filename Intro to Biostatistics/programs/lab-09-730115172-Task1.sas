/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Lab 09
*
* Author            : Ted Henson
*
* Date created      : 2018-10-30
*
* Purpose           : This program is Lab 09 Task 1

* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/
option mergenoby=nowarn nodate nonumber nobyline;
ods noproctitle;
title;
footnote;



/*********************************************************************
                        SAS Code for Task # 1
 *********************************************************************/


%let root     = C:/Users/tedhe/OneDrive/Documents/BIOS 511/data; 


libname echo "&root";

data work.dm;
set echo.dm;
keep STUDYID USUBJID AGE SEX RACE COUNTRY ARMCD ARM VISITNUM rfxstdtc;
run;



data work.lb;
set echo.lb;
keep USUBJID LBTESTCD LBTEST LBCAT LBSTRESN LBSTRESU lbstat lbreasnd visitnum visit LBDTC;
run;

proc sort data = work.lb;
by  USUBJID VISITNUM;
RUN;

proc sort data = work.DM;
by  USUBJID VISITNUM;
RUN;

data work.hope;
merge work.dm work.lb;
by  USUBJID;
RUN;

PROC SORT DATA = WORK.HOPE;
BY USUBJID LBTESTCD VISITNUM;
RUN;

data work.FIRST;
set work.HOPE;
BY USUBJID LBTESTCD VISITNUM;
length LBNRIND 8;


IF LBTESTCD = 'ALB' & . < LBSTRESN < 35 THEN LBRIND = 'L';
IF LBTESTCD = 'ALB' & 35 <= LBSTRESN <= 55 THEN LBRIND = 'N';
IF LBTESTCD = 'ALB' & 55 < LBSTRESN  THEN LBRIND = 'H';

IF LBTESTCD = 'CA' & . < LBSTRESN < 2.1 THEN LBRIND = 'L';
IF LBTESTCD = 'CA' & 2.1 <= LBSTRESN <= 2.7 THEN LBRIND = 'N';
IF LBTESTCD = 'CA' & 2.7 < LBSTRESN  THEN LBRIND = 'H';

IF LBTESTCD = 'HCT' & SEX = 'M' &  . < LBSTRESN < .388 THEN LBRIND = 'L';
IF LBTESTCD = 'HCT' & SEX = 'M' & .388 <= LBSTRESN <= .500 THEN LBRIND = 'N';
IF LBTESTCD = 'HCT' & SEX = 'M' & .500 < LBSTRESN  THEN LBRIND = 'H';

IF LBTESTCD = 'HCT' & SEX = 'F' &  . < LBSTRESN < .349 THEN LBRIND = 'L';
IF LBTESTCD = 'HCT' & SEX = 'F' & .349 <= LBSTRESN <= .445 THEN LBRIND = 'N';
IF LBTESTCD = 'HCT' & SEX = 'F' & .445 < LBSTRESN  THEN LBRIND = 'H';




length labdate $10;

length test  8;
LABDATE = trim(SCAN(LBDTC, 1, 'T'));


test = input(rfxstdtc, yymmdd10.) - input(LABDATE, yymmdd10.) + 1;
/* year = scan(labdate, 1, '-'); */
/* month = scan(labdate, 2, '-'); */
/* day = scan(labdate, 3, '-'); */
/*  */
/*  */
/* lab = catx(',' , year, month, day); */

/*test = start - lab; */




RUN;

proc sort data = work.first;
by usubjid lbtestcd visitnum;
run;


data work.hard;
set work.first;
if LBSTRESN ^= '' & test > 0;
run;



PROC SORT DATA = WORK.hard;
BY  usubjid lbtestcd test;
RUN;


data work.hard2;
set work.hard;
by usubjid lbtestcd test;

length LBBLFL $3;
if first.lbtestcd then LBBLFL = 'Y';
run;


proc sort data = work.hard2;
by usubjid lbtestcd visitnum;
run;





DATA WORK.HURRAY;
merge work.hard2 work.first;
by usubjid lbtestcd visitnum;
run;

data hurray;
set hurray;
if lbblfl NE 'Y' then lbblfl='Z';
run;

proc sort data=hurray; by usubjid lbtestcd lbblfl; run;




data work.base;
set work.hurray;
by usubjid lbtestcd;
length base 8;

retain base;

if first.lbtestcd then base = LBSTRESN;




run;

data work.base;
set work.base;


IF LBTESTCD = 'ALB' & . < base < 35 THEN basecat = 'L';
IF LBTESTCD = 'ALB' & 35 <= base <= 55 THEN basecat = 'N';
IF LBTESTCD = 'ALB' & 55 < base  THEN basecat = 'H';

IF LBTESTCD = 'CA' & . < base < 2.1 THEN basecat = 'L';
IF LBTESTCD = 'CA' & 2.1 <= base <= 2.7 THEN basecat = 'N';
IF LBTESTCD = 'CA' & 2.7 < base  THEN basecat = 'H';

IF LBTESTCD = 'HCT' & SEX = 'M' &  . < base < .388 THEN basecat = 'L';
IF LBTESTCD = 'HCT' & SEX = 'M' & .388 <= base <= .500 THEN basecat = 'N';
IF LBTESTCD = 'HCT' & SEX = 'M' & .500 < base  THEN basecat = 'H';

IF LBTESTCD = 'HCT' & SEX = 'F' &  . < base < .349 THEN basecat = 'L';
IF LBTESTCD = 'HCT' & SEX = 'F' & .349 <= base <= .445 THEN basecat = 'N';
IF LBTESTCD = 'HCT' & SEX = 'F' & .445 < base  THEN basecat = 'H';


change = lbstresn - base;

PCT_CHANGE = (LBSTRESN-BASE)/BASE*100;

keep studyid usubjid age sex race country armcd arm lbtestcd lbtest lbcat lbstresn lbstresu lbnrind lbstat 
lbreasnd lbblfl base basecat change pct_change visitnum visit lbdtc;
run;

proc sort data = work.base;
BY USUBJID LBTESTCD VISITNUM;
run;

data work.ADLB;
set work.base;
if visitnum = -1 then lbseq = visitnum + 2;
else lbseq = visitnum + 1;
IF LBBLFL = 'Z' THEN LBBLFL = '';
KEEP studyid usubjid age sex race country armcd arm lbseq lbtestcd lbtest lbcat lbstresn lbstresu lbnrind lbstat 
lbreasnd lbblfl base basecat change pct_change visitnum visit lbdtc;

proc print data=ADLB(obs=20);  
WHERE USUBJID = 'ECHO-011-003';
run;


PROC EXPORT DATA = WORK.ADLB
 outfile='C:/Users/tedhe/OneDrive/Documents/BIOS 511/ADLB.csv'
   dbms=csv
   replace;
run;
