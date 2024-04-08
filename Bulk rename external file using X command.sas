/**************************************************************************************************
* Program Name   : Rename_external.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is rename any external file using SAS X command 
******************************************************************************************************/

*Macro Variable Description
Generate excel file with columm old_name & new_name
mention the excel filename with location in rename_file macro variable
loc: location were external files are preset;

%let rename_file=O:\Users\Balaji.M\Rename check\info.xlsx;
%let loc=O:\Users\Balaji.M\Rename check;

/*Excel file to get old file names and new file names*/
proc import datafile="&rename_file" dbms=xlsx out=names replace;
run;

/*Generate X commands in a datastep*/
data name_;
	set names;
	ren=cat('x ren', "", strip(old_name),"", strip(new_name), '"',";");
run;

/*Pass all X commads steps to a macro variable*/
proc sql noprint;
	select ren into :rename_ separated by "" from name_;
quit;

/*Execute X commands*/
options noxwait;
x "cd &loc";
%str(&rename_);




