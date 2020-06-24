/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 01-midterm-review.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-10-08
*
* Purpose           : This program is designed to provide practice for the midterm
*
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

%let root     = C:/Users/tedhe/OneDrive/Documents/GitHub/BIOS-511-FALL-2018; 
%let dataPath = &root./data/echo;
libname echo "&dataPath";


/*********** practice question #1 ********************
   What was the mean change from baseline in heart rate
   at week 32 for each of the two echo trial treatment groups?
 *****************************************************/
data work.vs1;
set echo.vs;
run;

data work.ae1;
set echo.ae;
run;


proc sort data = work.vs1;
where vsseq = 2;
by  USUBJID;
RUN;


proc sort data = work.ae1;
by  USUBJID AESTDTC;
RUN;


data work.both;
merge work.vs1 work.ae1;
by  USUBJID;
RUN;

data work.bad;

set work.both;
where AETERM ^= '';

if length(AESTDTC) < 8 then aestdtc = catx('-', AESTDTC, 15);



change = input(AESTDTC, yymmdd10.) - input(VSDTC, yymmdd10.) + 1;


RUN;

DATA WORK.BAD2;

SET WORK.BAD;
by USUBJID;
if FIRST.USUBJID;
where change > 0;
RUN;

proc means data = work.bad2 median;
var change;
run;







