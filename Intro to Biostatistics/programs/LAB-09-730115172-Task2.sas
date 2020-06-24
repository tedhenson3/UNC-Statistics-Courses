/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Lab 09
*
* Author            : Ted Henson
*
* Date created      : 2018-11-1
*
* Purpose           : This program is Lab 09 Task 2

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
                        SAS Code for Task # 2
 *********************************************************************/

ods pdf file = 'C:/Users/tedhe/OneDrive/Documents/BIOS 511/output/lab-09-730115172-output.pdf';

proc import datafile = 'C:/Users/tedhe/OneDrive/Documents/BIOS 511/ADLB.csv'
 out = work.GRAPHS
 dbms = CSV
 ;
run;


data INPUT;
 set WORK.GRAPHS;
  output; 
  country = 'ALL';
  output;
run; 

DATA ALBUMIN;

SET WORK.INPUT;






WHERE LBTESTCD = 'ALB';

if lbblfl = 'Y' then visit = 'Baseline';
RUN;




PROC MEANS DATA = ALBUMIN NOPRINT;
CLASS ARMCD COUNTRY VISIT;
VAR PCT_CHANGE;
OUTPUT OUT = SUMALB MEAN = MEAN N = N LCLM = lower UCLM = upper;
RUN;



DATA SUMALB;
SET SUMALB;
WHERE ARMCD ^= '' & COUNTRY ^= '' & VISIT ^= '';
DROP _TYPE_;
RUN; 

ods graphics / height=4.5in width=8in;

title1 "Plot of Percent Change in Albumin by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
PROC SGpanel DATA = SUMALB ;



panelby COUNTRY   / rows = 1 onepanel ;


  highlow x=visit low=lower high=upper / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;



  series x=visit y=mean                / group=armcd groupdisplay=cluster clusterwidth=0.2
                                         markers markerattrs=(symbol=circleFilled)
                                         ;

  rowaxis label = "Percent Change from Baseline";
  colaxistable  N /  class = armcd ;
  colaxis label  = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');
run;
ods graphics / reset=all;



DATA ALBUMIN;

SET WORK.INPUT;






WHERE LBTESTCD = 'CA';

if lbblfl = 'Y' then visit = 'Baseline';
RUN;




PROC MEANS DATA = ALBUMIN NOPRINT;
CLASS ARMCD COUNTRY VISIT;
VAR PCT_CHANGE;
OUTPUT OUT = SUMALB MEAN = MEAN N = N LCLM = lower UCLM = upper;
RUN;



DATA SUMALB;
SET SUMALB;
WHERE ARMCD ^= '' & COUNTRY ^= '' & VISIT ^= '';
DROP _TYPE_;
RUN; 

ods graphics / height=4.5in width=8in;

title1 "Plot of Percent Change in Calcium by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
PROC SGpanel DATA = SUMALB ;



panelby COUNTRY   / rows = 1 onepanel ;


  highlow x=visit low=lower high=upper / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;



  series x=visit y=mean                / group=armcd groupdisplay=cluster clusterwidth=0.2
                                         markers markerattrs=(symbol=circleFilled)
                                         ;

  rowaxis label = "Percent Change from Baseline";
  colaxistable  N /  class = armcd ;
  colaxis label  = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');
run;
ods graphics / reset=all;



DATA ALBUMIN;

SET WORK.INPUT;






WHERE LBTESTCD = 'HCT';

if lbblfl = 'Y' then visit = 'Baseline';
RUN;




PROC MEANS DATA = ALBUMIN NOPRINT;
CLASS ARMCD COUNTRY VISIT;
VAR PCT_CHANGE;
OUTPUT OUT = SUMALB MEAN = MEAN N = N LCLM = lower UCLM = upper;
RUN;



DATA SUMALB;
SET SUMALB;
WHERE ARMCD ^= '' & COUNTRY ^= '' & VISIT ^= '';
DROP _TYPE_;
RUN; 

ods graphics / height=4.5in width=8in;

title1 "Plot of Percent Change in Hermatocrit by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
PROC SGpanel DATA = SUMALB ;



panelby COUNTRY   / rows = 1 onepanel ;


  highlow x=visit low=lower high=upper / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;



  series x=visit y=mean                / group=armcd groupdisplay=cluster clusterwidth=0.2
                                         markers markerattrs=(symbol=circleFilled)
                                         ;

  rowaxis label = "Percent Change from Baseline";
  colaxistable  N /  class = armcd ;
  colaxis label  = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');
run;
ods graphics / reset=all;

ods pdf close;


