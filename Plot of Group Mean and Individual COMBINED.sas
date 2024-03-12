/**************************************************************************************************
* Program Name   : GroupMean_Individual.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is used to plot group mean and individual in combined manner
******************************************************************************************************/

%macro cfwplot(data=,where=);
***********************************************************************;
**                           Formats used                            **;
***********************************************************************;
proc format;
	value vsnin
	1= 'Week 0'
	2 = 'Week 24'
	3 = 'Week 52'
;
run;
***********************************************************************;
**                        Required datasets                          **;
***********************************************************************;
/*ADSL Dataset*/
proc sort data=ads.adsl out=adsl;
	by usubjid;
	where trtgrp ne "";
run;

/*ADCA OR ADPC dataset*/
proc sort data=ads.&data. out=&data;
	by usubjid;
	where &where.;
run;

/*Merge adsl with input dataset*/
data inds;
    merge adsl(in=a) &data(in=b);
    by usubjid;
    if a & b;
    keep usubjid subjid param: avisit: aval avalc trtgrp: parcat1;
run;

/*Check nobs */
proc sql noprint;
	select count(*) into :obs from inds;
quit; 

%if &obs ne 0 %then %do;

/*Generating required macro variables*/
proc sql noprint;
	create table param as select distinct paramn,paramcd,param from inds;
	select paramcd into: paramcd separated by '$'  from param;
	select param into: param separated by '$' from param;
quit;

/*Retain Subjects with Week0 and respective postbaseline records for plotting*/
proc sort data=inds out=subj1(keep=usubjid) nodupkey;
	by usubjid;
	where avisitn=1;
run;

proc sort data=inds out=subj2(keep=usubjid) nodupkey;
	by usubjid;
	where avisitn>1;
run;

/*Subjects with Week0 and Post Week0 records*/
data subj3;
	merge subj1(in=x) subj2(in=y);
	by usubjid;
	if x and y;
	proc sort nodupkey;
	by usubjid;
run;

/*Merge back with original dataset to retain only week0 and post Week0 subjects*/
data inds1;
  merge inds(in=a) subj3(in=b);
  by usubjid;
  if a and b;
  keep usubjid subjid param paramn paramcd parcat1 trtgrp trtgrpn avisitn avisit aval;
run;

/*Group Mean Calculation*/
proc sort data=inds1(keep=usubjid subjid trtgrpn trtgrp paramn param paramcd avisitn avisit aval);
	by trtgrpn trtgrp avisitn avisit;
run;

proc means data=inds1 noprint;
	by trtgrpn trtgrp avisitn avisit;
	var aval;
	output out = stat(drop=_type_ _freq_) mean = mean std=std;
quit;

/*Standard Error Calculation*/
data inds2(drop=mean std);
	set stat;
	if missing(mean) then mean=0;
	if missing(std) then std=0;
	mean_n=mean;
	max_n=mean + std;
	min_n=mean - std;
run;

/*Merge with original datasets to get subject information for the individual plot*/
data inds3;
	merge inds2(in=a) inds1(in=b);
	by trtgrpn trtgrp avisitn avisit;
/*	Find the max value comparing all variables*/
	maxval=max(mean_n,max_n,min_n,aval);
	proc sort;by paramn avisitn trtgrpn;
run;

/*Series Plot Mean value*/
data inds4;
	set inds3;
	by paramn avisitn trtgrpn;
	if first.trtgrpn then mean=mean_n;
	else mean=.;
run;

/*Final dataset*/
proc sort data=inds4 out=final;
  by trtgrpn usubjid avisitn ;
run;

data tit;  
	text=1;
run;

data empty;
	just_txt=''; 
run;

/*Atrribute map dataset for individual subjects*/
proc sort data=inds4;
by subjid;

data subj;
	length value linepattern linecolor id $100.;
	set inds4;
	by subjid;
	if first.subjid;
	value=subjid;
	id='MakeAttr1';
	linepattern='Shortdash';
	linethickness=1.5;
	if trtgrpn=1 then linecolor='red';
	if trtgrpn=2 then linecolor='black';
	keep value linepattern linecolor id linethickness;
run;

/*Atrribute map dataset for individual treatment groups*/
data attr_map;
	length id value linecolor markercolor linepattern $100;
	id='MakeAttr';
	value = "TRT1;
	linecolor ='red';
	markercolor='red';
	linethickness=1.5;
	linepattern='Solid';
	output;
	value = "TRT2";
	linecolor ='black';
	markercolor='black';
	linethickness=1.5;
	linepattern='Solid';
	output;
run;

/*Append Subject attr_map and treament attr_map dataset*/
data attr_map;
	set attr_map subj;
run;

/*Generate macro variables for dynamic axis scaling*/
%macro axiscale();

/*Remove non-essentail datasets*/
%macro clean();
proc datasets library=work nolist;
   delete info: max:;
quit;
%mend clean;

%do i=1 %to %sysfunc(countw(&paramcd)); 
%let paramcd_ = %scan(&paramcd,&i,"$");

/*Find max value*/
proc sort data=final out=max_;
	by paramn paramcd maxval;

data max;
	set max_(keep=paramn paramcd param maxval where=(paramcd="&paramcd_"));
	by paramn paramcd maxval;
	if last.paramn then output;
	call symputx("max",maxval,"G");

data info&paramcd_;
	set max;
/*Compute max and by value*/
	unit=&max/10; 
	grade=floor(log10(unit)); 
	sunit=unit/(10**grade); 
	if sunit<sqrt(2) then interval=10**grade*1; 
	else if sunit<sqrt(10) then interval=10**grade*2; 
	else if sunit<sqrt(50) then interval=10**grade*5; 
	else interval=10**grade*10;
	maxscale=ceil(&max/interval)*interval; 
/*Assign Global max and by macro variable*/
	%global &paramcd_.max &paramcd_.by;
	call symputx("&paramcd_.max",put(maxscale,best.),"G"); 
	call symputx("&paramcd_.by",put(interval,best.),"G"); 

/*Set all paramcd datasets with axisinfo*/
data axisinfo_check;
	set info:;
run; 
%end;

%mend axiscale;
 
%axiscale;
%clean;

*************************************************************************
								Output									
*************************************************************************;

ods listing close;
ods path template.RTFtemplate sashelp.tmplmst;   
ods rtf file="&progname..rtf" style=tables nogtitle nogfootnote;  
ods escapechar="~";
options nobyline;
ods graphics on / width=8in height=4.2in noborder;

%macro plot;	  

%do i=1 %to %sysfunc(countw(&paramcd));
%let paramcd_ =%scan(&paramcd,&i,"$");
%let param_ =%scan(&param,&i,"$");
ods rtf startpage = No;

%toc(item=&progname,toctab1=Figures - Section B, getnames=yes); 
proc report nowd missing split = '\' spacing=4 data = tit
	style(report)={rules=groups frame=above borderwidth=0.75} ;
	columns text ;
	define text / order noprint;
run;

proc sgplot data=final(where=(paramcd="&paramcd_"))noautolegend dattrmap=attr_map;
	format avisitn vsnin.;
	scatter x=avisitn y=mean_n /yerrorlower=min_n yerrorupper=max_n group=trtgrp attrid=MakeAttr;
	series x=avisitn y=mean/ group=trtgrp attrid=MakeAttr;
	series x=avisitn y=aval/ group=subjid attrid=MakeAttr1;
	xaxis labelattrs=(size=10pt) values=(1 2 3) display=(nolabel);
	yaxis display=all label="Change from Week 0 (+/-SE) in tau PET SUVr : &param_"  labelattrs=(size=10pt) values=(0 to &&&paramcd_.max by &&&paramcd_.by);
	
	legenditem type=line name="TRT1"/
	    label="Placebo + Lecanemab" lineattrs=(color=red);

	legenditem type=line name="TRT2/
	    label="E2814 + Lecanemab" lineattrs=(color=black);

	keylegend "TRT1" "TRT2" / location=inside POSITION=topright across=1
	    valueattrs=(Color=black Size=8pt Weight=Normal) noborder;
run;

%end;
ods graphics off;
ods rtf close;
ods path reset;
%mend plot;
ods rtf startpage = Yes;

%plot;

%end;

%mend cfwplot;

%cfwplot(data=adca,where=not missing(paramcd));
