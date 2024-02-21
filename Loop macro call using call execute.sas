/**************************************************************************************************
* Program Name   : Loopmacrocall.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to loop a macro call for dynamic programming 
******************************************************************************************************/
/*Sample Macro*/
%macro data(data=);
data &data._;
	set sashelp.class;
	where name="&data.";
run;
%mend data;

/*List of all names in a macro variable*/
proc sql noprint;
	select name into: name separated by ' '  from sashelp.class;
quit;

/*Dynamic macro call with looping*/
%macro loop();
%do i=1 %to %sysfunc(countw(&name));
	data _null_;
	%let name_ = %scan(&name,&i);
	call execute ('%nrstr(%data(data=&name_))');
	run;
%end;
%mend loop;
%loop;
