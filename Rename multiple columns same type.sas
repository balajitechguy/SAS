/**************************************************************************************************
* Program Name   : Renameall.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to rename multiple columns with same type
******************************************************************************************************/

proc contents data=sashelp.class out=chg1;
run;

data chg1;
	set chg1(keep=name);
	n_name=upcase(tranwrd(name,"_",""));
	rename=compress(name)||"="||compress(n_name);
run;


proc sql;
	select rename
	into :varlist separated by ' '
	from chg1;
quit;


proc datasets lib=work;
	modify chg1;
	rename &varlist.;
run;