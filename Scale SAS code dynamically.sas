/**************************************************************************************************
* Program Name   : SAS_code_scaler.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is used to scale sas code dynamically. In below code the legend statements are dynamically generated based on the dataset and it's conditions
******************************************************************************************************/

options mprint mlogic symbolgen;

*Generate linecolour for individual names;
data subj;
    set sashelp.class(obs=10);
    array col[10] $10. ('blue', 'green', 'orange', 'purple', 'yellow', 'cyan', 'magenta', 'brown', 'pink', 'gray');
    index = mod(_n_ - 1, dim(col)) + 1;
    linecolour = col[index];
    drop index col1-col10;
run;

*Pass all names for keylegend statement;
proc sql noprint;	
	select distinct compress(cat('''',name,''''))  into :name separated by ' ' from subj;
quit;

*Generate dataset to scale legened statements dynamically;
data keyleg;
	length kl $1000.;
	set subj;
	kl = catx(' ', 'legenditem', 'type=LINE', 'name="' || strip(name) || '"', '/label="' || strip(name) || '"',
	'lineattrs=(color="' || strip(linecolour) || '");');
run;

proc sql noprint noprint;
	select kl into :Keyleg separated by "" from keyleg;
quit;


proc sgplot data=keyleg;
	series x=age y=height;
	&keyleg.;
	keylegend &name./ noborder valueattrs=(Size=9pt Weight=Normal);
run;
