/**************************************************************************************************
* Program Name   : Boxplot.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used generate box plot figure for individual param using do loop
******************************************************************************************************/

***********************************************************************;
**                        Required datasets                          **;
***********************************************************************;
proc sort data=ads.adsl out=adsl; 
	by usubjid; 
	where pkfl='Y' and not missing (trt01p); 
run;

proc sort data=ads.adpp out=adpp;
	by usubjid ppspec  ppstat aval ;
    where parcat1="k2542" and aval not in (.,0) and upcase(ppstat) ne ("NOT DONE");
run;

data final;
	length param2 $50.;
	merge adpp(in=a) adsl(in=b keep=usubjid);
	by usubjid;
	if a and b;
run;

proc sql noprint;
	create table uq as select distinct ppspec,paramcd,param,param2 from final;
	select param into: param separated by '$'  from uq;
	select param2 into: param2 separated by '$'  from uq;
	select paramcd into: paramcd separated by ' '  from uq;
	select ppspec into: tit separated by ' '  from uq;
quit;
%put %superq(param);
%put &paramcd;
%put &tit;
%put &param2;

data tit;  
	text=1;
run;

proc sort data=final;
by usubjid trt01an;
run;

/*Generating individual macro variables for min, max and by values for axis scaling*/
options nomprint nomlogic nosymbolgen;
%macro loop();
%do i=1 %to %sysfunc(countw(&paramcd));
	data _null_;
	%let paramcd_ = %scan(&paramcd,&i);
	call execute ('%nrstr(%axisorder(data=final,var=aval,prefix=&paramcd_,where=paramcd=("&paramcd_")))');
	run;
%end;
%mend loop;
%loop;

*************************************************************************
								Output
*************************************************************************;

options mprint mlogic symbolgen;
options orientation=landscape;
ods listing close;
ods rtf file="O:\Users\Balaji.M\Axis Scaling\BOXPLOT_0.rtf" style=tables nogtitle nogfootnote;  
ods escapechar="~";
options nobyline;
ods graphics on / width=8in height=4.2in noborder;	
%macro plot;	  

	%do i=1 %to %sysfunc(countw(&paramcd));
    %let param_ =%scan(&param2, &i, "$");
	%put   %superq(&param_);
	%let paramcd_ =%scan(&paramcd, &i);
	%put  &paramcd_;
	%let tit_ = %scan(&tit,&i);
	%put  &tit_;

	ods rtf startpage = No;
	title3 "Box Plot of k2542 &param_ by Cohort";
	title4 "Pharmacokinetic Analysis Set";
	title5 "&tit_";

	proc report nowd missing split = '\' spacing=4 data = tit
	style(report)={rules=groups frame=above borderwidth=0.75} ;
	columns text ;
	define text / order noprint;
	run;

proc sgplot data=final(where=(paramcd="&paramcd_")) noautolegend ;
	vbox aval  /  boxwidth=.2 category=dose nomean  fillattrs=(color=lightgray) whiskerattrs=(color=black) medianattrs=(color=black) meanattrs=(color=black) ;
	xaxis label="Dose(mg)" labelattrs=(size=10pt) fitpolicy=none display=all values=(1 2.5 5 10 25 50);
	yaxis label="&param_"  labelattrs=(size=10pt) values=(0 to &&_&paramcd_.Axisend by &&_&paramcd_.Axisby);
run;

%end;
ods graphics off;
ods rtf close;
ods path reset;
%mend plot;
ods rtf startpage = Yes;


%plot;
