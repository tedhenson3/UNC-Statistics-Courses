/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Part 1
*
* Author            : Ted Henson
*
* Date created      : 2018-12-05
*
* Purpose           : To create ADSIS Dataset
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/
option mergenoby=nowarn nodate nonumber validvarname=any;
title ;

footnote;

%let root     = C:/Users/tedhe/OneDrive/Documents/BIOS 511/Final Exam; 
%let outputPath = &root./output;
%let qualtrics_path = &root./qualtrics_data;
%let analysis = &root./analysis_data;
libname qual "&qualtrics_path";
libname out  "&analysis";


proc import out = work.stroke datafile = "&qualtrics_path./SIS16.csv" 
dbms = csv 
replace ;
getnames = YES;
run;


data work.stroke2;
  set work.stroke (firstobs=2) ;
run;


/* proc transpose data=work.stroke(obs=1) out=names ; */
/*   var _all_; */
/* run; */
/*  */
/* proc sql noprint ; */
/*   select cat(trim(_name_),"'", "n",  '=',  "'", trim(col1), "'", "n")  */
/*     into :rename separated by ' ' */
/*     from names */
/*   ; */
/* quit; */
/*  */
/* %put  &=rename; */

data work.stroke2;
set work.stroke2;
usubjid  = input(ResponseId, 4.);
/* usubjid2  = input(put(usubjid1, best.), 4.); */
drop ResponseId;
run;

proc sort data = work.stroke2 out = sorted; by usubjid;run;

data work.sorted ;
RETAIN USUBJID Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q14 Q15 Q16 ;
set work.sorted;

run;



proc transpose data = sorted out = vert;
by usubjid ;
var Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12 Q13 Q14 Q15 Q16;
run;

DATA WORK.VERT;
SET WORK.VERT;
AVAL = INPUT(COL1, 8.);
DROP COL1;
RUN;


DATA WORK.VERT;
SET WORK.VERT;
RENAME  _NAME_ = QSTEST;
idnum=put(usubjid, z4.);
drop usubjid;
RUN;

DATA WORK.VERT;
SET WORK.VERT;
RENAME idnum = USUBJID;
RUN;

DATA WORK.VERT;
retain USUBJID QSTEST AVAL;
SET WORK.VERT;
RUN;

/* PROC FORMAT;  */
/* VALUE FMT */
/* &RENAME.; */
/* RUN; */


/* Manually Create QS Test*/
data work.ted;
set work.vert;

LENGTH QSTEST_FORMAT $200;
LENGTH QSTESTCD $10;
IF QSTEST = "Q12" THEN DO ;QSTEST_FORMAT =  "In the past 2 weeks, how difficult was it to walk fast?";
QSSEQ =  12;
QSTESTCD =  'ITEM12';
END;

IF QSTEST = "Q10" THEN DO ;QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to walk without losing your balance?";
QSSEQ =  10;
QSTESTCD =  'ITEM10';
END;
IF QSTEST = "Q11" THEN DO; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to move from a bed to a chair?";
QSSEQ =  11;
QSTESTCD =  'ITEM11';
END;
IF QSTEST = "Q13" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to climb one flight of stairs?";
QSSEQ =  13;
QSTESTCD =  'ITEM13';
END;
IF QSTEST = "Q14" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to walk one block?"; 
QSSEQ =  14;
QSTESTCD =  'ITEM14';
END;
IF QSTEST = "Q15" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to get in and out of a car?"; 
QSSEQ =  15;
QSTESTCD =  'ITEM15';
END;
IF QSTEST = "Q16" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to carry heavy objects (e.g. bag of groceries) with your affected hand?";
QSSEQ =  16;
QSTESTCD =  'ITEM16';
END;


IF QSTEST =  "Q1" THEN DO ;
QSTEST_FORMAT =  "In the past 2 weeks, how difficult was it to dress the top part of your body?" ;
QSSEQ =  1;
QSTESTCD =  'ITEM01';
END;


IF QSTEST = "Q2" THEN DO; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to bathe yourself?" ;
QSSEQ =  2;
QSTESTCD =  'ITEM02';
END;
IF QSTEST = "Q3" THEN DO; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to get to the toilet on time?" ;
QSSEQ =  3;
QSTESTCD =  'ITEM03';
END;

IF QSTEST = "Q4" THEN DO; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to control your bladder (not have an accident)?";


QSSEQ =  4;
QSTESTCD =  'ITEM04';
END;
IF QSTEST = "Q5" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to control your bowels (not have an accident)?";
QSSEQ =  5;
QSTESTCD =  'ITEM05';
END;
IF QSTEST = "Q6" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to stand without losing balance?";
QSSEQ =  6;
QSTESTCD =  'ITEM06';
END;
IF QSTEST = "Q7" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to go shopping?";
QSSEQ =  7;
QSTESTCD =  'ITEM07';
END;
IF QSTEST = "Q8" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to do heavy household chores (e.g. vacuum, laundry or yard work)?" ;
QSSEQ =  8;
QSTESTCD =  'ITEM08';
END;
IF QSTEST = "Q9" THEN DO ; QSTEST_FORMAT = "In the past 2 weeks, how difficult was it to stay sitting without losing your balance?";
QSSEQ =  9;
QSTESTCD =  'ITEM09';
END;
RUN;

DATA WORK.TED;
SET WORK.TED;
DROP QSTEST;
RUN;

DATA WORK.TED2;
SET WORK.TED;
RENAME QSTEST_FORMAT = QSTEST;
RUN;

PROC SORT DATA = WORK.TED2 OUT = WHY; BY USUBJID QSSEQ; RUN;

DATA WORK.WHY;
SET WORK.WHY;

LENGTH AVALC $20;

IF AVAL = 1 THEN AVALC = 'Could not do at all';
IF AVAL = 2 THEN AVALC = 'Very difficult';
IF AVAL = 3 THEN AVALC = 'Somewhat difficult';
IF AVAL = 4 THEN AVALC = 'A little difficult';
IF AVAL = 5 THEN AVALC = 'Not difficult at all';
run;

PROC MEANS DATA = WHY NOPRINT; 
BY USUBJID;
VAR AVAL;
OUTPUT OUT = WORK.TEDSAS N = NUMBER_NON_MISSING NMISS = NMISS SUM = RAW_SCORE;
RUN;


DATA WORK.TEDSAS;
SET WORK.TEDSAS;
IF USUBJID ^= '';
DROP _TYPE_ _FREQ_;
RUN;


DATA WORK.CALC(keep = USUBJID AVAL AVALC QSTEST QSTESTCD QSTYP QSSTAT QSREASND QSSEQ) ;
SET WORK.TEDSAS;
MAX_RAW = 5*(16-NMISS);
MIN_RAW = 1*(16-NMISS);
LENGTH QSTYP $10;
LENGTH QSSTAT $50;
LENGTH QSREASND $50;

IF NUMBER_NON_MISSING >= 12 THEN SIS_SCORE = (RAW_SCORE-MIN_RAW) / (MAX_RAW-MIN_RAW) * 100;
IF NUMBER_NON_MISSING < 12 THEN QSREASND = catx(" ", "Only", NUMBER_NON_MISSING, "Items Answered");
IF NUMBER_NON_MISSING < 12 THEN QSSTAT = "NOT CALCULATED";
AVAL = ROUND(SIS_SCORE, .01);
AVALC = input(AVAL, $20.);
QSTEST = 'Stroke Impact Scale 16 Score';
QSTESTCD = 'SIS16';
QSTYP = 'DERIVED';
QSSEQ = 17;
RUN;

data _null_;
set work.calc end=last;
put _n_;

call symput('id'||strip(put(_n_,best.)), put(USUBJID, $4.));
if last = 1 then call symput('numsub', _n_);

run;

%put &=numsub;


%macro stacker(questions = work.why, scores = work.calc, numsub = 3);


%do i = 1 %to &numsub.; 


data questions1;
set &questions.;
where USUBJID = "&&id&i";
run;

data scores1;
set &scores.;
where USUBJID = "&&id&i";
run;


%if &i. = 1 %then %do;

data results;
set questions1 scores1;
run;
%end;

%if &i. ^= 1 %then %do;

data results;
set results questions1 scores1;
run;
%end;



%end;

data out.ADSIS;
LABEL USUBJID = 'Unique Subject ID'
QSSEQ = 'Item Sequence Number'
QSTESTCD = 'Survey Item Code'
QSTEST = 'Survey Item'
QSTYP = 'Survey Item Type'
AVALC = 'Analysis Value (Character)'
AVAL = 'Analysis Value'
QSSTAT = 'SIS-16 Score Status'
QSREASND = 'Reason SIS-16 Score Not Calculated';
retain USUBJID QSSEQ QSTESTCD QSTEST QSTYP QVALC AVALC AVAL QSSTAT QSREASND;
set results;

%mend;

%stacker(numsub = &numsub.);



 

