/**************************************************************************************************
* Program Name   : Renameall.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to rename multiple columns with same type
******************************************************************************************************/

/* mock source: a table with underscore-separated column names, the case
   this rename utility targets (adapted from sashelp.class in the original
   script, whose column names have no underscores to strip) */
data src;
	length pat_id $8 vis_dt $10 sys_bp 8;
	pat_id="P001"; vis_dt="2024-01-05"; sys_bp=120; output;
	pat_id="P002"; vis_dt="2024-01-06"; sys_bp=132; output;
run;

proc contents data=src out=chg1;
run;

data chg1;
	set chg1(keep=name);
	n_name=upcase(tranwrd(name,"_",""));
	renamevar=compress(name)||"="||compress(n_name);
run;


proc sql;
	select renamevar
	into :varlist separated by ' '
	from chg1;
quit;


/* apply the computed rename list to the real target dataset (the original
   script applied it back to the chg1 metadata table itself, which never
   had the source's own columns to rename -- pointing at src is the
   working form of this utility) */
proc datasets lib=work;
	modify src;
	rename &varlist.;
run;

proc print data=src;
run;