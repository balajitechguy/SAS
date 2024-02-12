/**************************************************************************************************
* Program Name   : Logcheck.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to display log errros and warnings of the program which is been executed 
				   in the result viewer for user convenience and easy debugging purpose
******************************************************************************************************/
/*Setup */
option nomprint nomlogic nosymbolgen nonotes nosource;
%if DMS=%sysfunc(getoption(dms)) %then %do;
%macro closevts;
    %do i=1 %to 10; 
        data _null_;
            dm 'next VIEWTABLE:; end;'; 
        run;
    %end; 
%mend;
%closevts
dm 'odsresults; clear';
%end;

/*For allocation of temporary sas directory*/
data chk;
	stop;
run;
proc delete data=chk;run;

/*Assign essential macro variables*/
%let pgname=temp.log;
%let pgname=%sysget(SAS_EXECFILENAME);
%let tmpath=%sysfunc(getoption(work));
%let path=%sysfunc(catx(\,&tmpath,&pgname));
%let path=%sysfunc(tranwrd(&path,.sas,.txt));

/*Save log using dm statement*/
dm 'log; file "&path" replace';
dm "log" clear;

/*Read log file and segregate errors, warnings and notes*/
data issue;
	infile "&path" delimiter = '@@'  dsd lrecl=32767 firstobs=1 TERMSTR=CRLF;
	informat CODE $char5000. ;
	input CODE $;
 	if index(upcase(CODE), "ERROR:") > 0 then do;
	ERROR = CODE;
	end;
	else if index(upcase(CODE), "WARNING:") > 0 then do;
	WARNING = CODE;
	end;
	else if index(upcase(CODE),"UNINITIALIZED") > 0 then do;
	NOTE=CODE;
	end;
run;

/*Drop Empty Columns*/
ods exclude all;
proc freq data=issue nlevels;
ods output nlevels=nlevels;
run;
ods exclude none;

proc sql noprint;
	select TableVar into :empty_columns separated by ","
	from nlevels
	where nnonmisslevels = 0;
	select TableVar into :nonempty_columns separated by " "
	from nlevels
	where nnonmisslevels gt 0;
	alter table issue
	drop &empty_columns;
quit;
dm 'odsresults; clear';

/*Display erros, warnings and notes*/
title "LOG ISSUES";
proc report data=issue nowd headline headskip spacing=1 split='~';
column &nonempty_columns;
define code / 'CODE' left; 
define error / 'ERROR' center; 
define warning / 'WARNING' center; 
define note / 'NOTE' center; 
compute error; 
call define(_col_, "style", "style=[background=lightred]"); 
endcomp; 
compute warning; 
call define(_col_, "style", "style=[background=lightyellow]"); 
endcomp; 
compute note; 
call define(_col_, "style", "style=[background=lightgreen]"); 
endcomp; 
run;
options source notes;

/**************************************************************************************************
HOW TO USE?

Your SAS CODE

data new;
	set sashelp.class
run;

Above CODE
%include "C:\Users\Balaji.M\Log Check\Log Check.sas";
******************************************************************************************************/
