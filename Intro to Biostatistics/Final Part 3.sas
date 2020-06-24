/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Part 3
*
* Author            : Ted Henson
*
* Date created      : 2018-12-07
*
* Purpose           : To create Part 3 pdf files
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
%let macros = &root./macros;
libname qual "&qualtrics_path";
libname out  "&analysis";


proc format;
value fmtA
1-3 = 'At Least Somewhat Difficult'
4 = 'A Little Difficult'
5 = 'No Difficulty';
value fmtB
1-4 = 'At Least Some Difficulty'
5 = 'No Difficulty';
run;

data work.freq;
set out.ADSIS;
run;


%include "&macros.\PART3-FREQ-730115172.sas";

ods pdf file="&outputPath.\PART3-730115172.pdf" style=sasweb;
  %FREQ(INSTRUCTIONS = ITEM01*FMTA|ITEM01*FMTB|ITEM01*NONE);
ods pdf close;
