/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : Lab 6
*
* Author            : Ted Henson
*
* Date created      : 2018-10-04
*
*  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
ods noproctitle;
run;





option mergenoby=error;
options nodate nonumber;


libname echo "C:/Users/tedhe/OneDrive/Documents/GitHub/BIOS-511-FALL-2018/data/echo";


/*********************************************************************
                        SAS Code for Task # 1
 *********************************************************************/

proc print data = echo.vs (obs = 10);
run;



/*********************************************************************
                        SAS Code for Task # 2
 *********************************************************************/

data WORK.DIABP;
 set echo.vs;
where VSTESTCD = 'DIABP';
rename vsstresn = DIABP;
run;

proc sort data = WORK.DIABP; by USUBJID VISITNUM; run;


data WORK.SYSBP;
 set echo.vs;
where VSTESTCD = 'SYSBP';
rename vsstresn = SYSBP;
run;

proc sort data = WORK.SYSBP; by USUBJID VISITNUM; run;

data WORK.BP1;
 merge WORK.SYSBP WORK.DIABP ;
  by USUBJID VISITNUM;
  keep usubjid visitnum visit sysbp diabp;
run;



proc sort data = echo.vs out = work.VS;
by usubjid visitnum visit vstestcd;
where VSTESTCD = 'DIABP' | VSTESTCD = 'SYSBP';
run;




data work.BP2;
set work.vs;
by usubjid visitnum visit vstestcd; 



retain sysbp diabp;

 if FIRST.USUBJID = 1 then do;
  sysbp = .;
  diabp = .;
 end;

if VSTESTCD = 'SYSBP' then sysbp = VSSTRESN;
if VSTESTCD = 'DIABP' then diabp = VSSTRESN;


if LAST.VISIT;

keep usubjid visitnum visit sysbp diabp;
run;


PROC PRINT DATA = WORK.BP2(OBS = 10);
RUN;




proc sort data = echo.vs out = work.VS;
by usubjid visitnum visit vstestcd;
run;

PROC TRANSPOSE DATA = WORK.VS
OUT = BP3 (DROP = _LABEL_ _NAME_);
by usubjid visitnum visit;
where VSTESTCD = 'DIABP' | VSTESTCD = 'SYSBP';
ID VSTESTCD;
IDLABEL VSTEST;
VAR VSSTRESN;
RUN;

PROC PRINT DATA = WORK.BP3 (OBS = 10);
RUN;

/*********************************************************************
                        SAS Code for Task # 3
 *********************************************************************/



DATA WORK.VS;
SET ECHO.VS;
where vstestcd in ('DIABP' 'SYSBP');
run; 
proc sort data = work.vs; by usubjid visitnum visit vstestcd; run;

DATA ECHO.BP4;
SET WORK.VS;
by usubjid visitnum visit vstestcd;

retain DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32
        SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;

 array bp[2,6] DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32 
               SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;

IF FIRST.USUBJID THEN DO;
do r = 1 to 2;
do c = 1 to 6;
bp[r, c] = .;
end;
end;
end;

      if vstestcd = 'DIABP' then array_row = 1;
 else if vstestcd = 'SYSBP' then array_row = 2;

IF VISITNUM = -1 THEN ARRAY_COL = VISITNUM + 2;
ELSE ARRAY_COL = VISITNUM + 1;


bp[array_row, array_col] = vsstresn;


if LAST.USUBJID;

keep  usubjid dbp: sbp:;
run;

proc print data = ECHO.bp4 (obs = 10);
run;



/*********************************************************************
                        SAS Code for Task # 4
 *********************************************************************/


data WORK.BP5;
 set echo.VS;
 where vstestcd in ('DIABP' 'SYSBP');



  length VARNAME $20.;
	if vstestcd = 'DIABP' & visitnum = -1 then varname = catx('_', 'DBP', 'SCR');
		if vstestcd = 'DIABP' & visitnum = 1 then varname = catx('_', 'DBP', 'WK00');
		if vstestcd = 'DIABP' & visitnum = 2 then varname = catx('_', 'DBP', 'WK08');
			if vstestcd = 'DIABP' & visitnum = 3 then varname = catx('_', 'DBP', 'WK16');
				if vstestcd = 'DIABP' & visitnum = 4 then varname = catx('_', 'DBP', 'WK24');
					if vstestcd = 'DIABP' & visitnum = 5 then varname = catx('_', 'DBP', 'WK32');
					
		if vstestcd = 'SYSBP' & visitnum = -1 then varname = catx('_', 'SBP', 'SCR');
		if vstestcd = 'SYSBP' & visitnum = 1 then varname = catx('_', 'SBP', 'WK00');
		if vstestcd = 'SYSBP' & visitnum = 2 then varname = catx('_', 'SBP', 'WK08');
			if vstestcd = 'SYSBP' & visitnum = 3 then varname = catx('_', 'SBP', 'WK16');
				if vstestcd = 'SYSBP' & visitnum = 4 then varname = catx('_', 'SBP', 'WK24');
					if vstestcd = 'SYSBP' & visitnum = 5 then varname = catx('_', 'SBP', 'WK32');
									
	
run; 



proc sort data = work.BP5 out = work.BP5;

by usubjid visitnum visit vstestcd VARNAME;
run;

proc print data = ECHO.bp5 (obs = 10);
run;




PROC TRANSPOSE DATA = WORK.BP5
OUT = BP6 (DROP = _LABEL_ _NAME_);
by usubjid;

ID VARNAME;
VAR VSSTRESN;

RUN;



DATA ECHO.BP5;
format USUBJID DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32 SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;
SET WORK.BP6;

RUN;





