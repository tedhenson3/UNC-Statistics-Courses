/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Part 2
*
* Author            : Ted Henson
*
* Date created      : 2018-12-06
*
* Purpose           : To create Part 2 PDF
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


DATA WORK.GRAPHS;
SET OUT.ADSIS;
WHERE QSTESTCD = 'SIS16';
RUN;


ods pdf file="&outputPath./PART2-730115172.pdf" startpage = no title=  "Distribution of SIS-16 Scores";
ods graphics / height=4in width=6in;



proc sgplot data = work.graphs noborder    ;
label AVAL = "SIS-16 Score";

 histogram AVAL  /   scale=proportion fillattrs=(color =  lightred);
 yaxis grid;
 xaxis minor;
 
run;

proc sgplot data = work.graphs noborder  ;
label AVAL = "SIS-16 Score";

 hbox AVAL  /  fillattrs=(color =  lightred);
 xaxis grid;
 
run;


ods pdf close;

