/**************************************************************************************************
* Program Name   : GroupMean_Individual_combined.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is used to plot group mean and individual in combined manner
******************************************************************************************************/



%macro cfwplot(data=,where=,con=);
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
proc sort data=ads.&data. out=&data(drop=&con.);
	by usubjid;
	where &where.;
run;

/*Merge adsl with input dataset*/
data inds_;
    merge adsl(in=a) &data(in=b);
    by usubjid;
    if a & b;	
    keep usubjid subjid param: avisit: aval avalc trtgrp: parcat1 chg;
run;

*Valid flag;
proc sort data=inds_ out=trans_ (keep=usubjid paramcd avisitn aval );
	by usubjid paramcd;
run;

proc transpose data=trans_ out=trans_a;
	by USUBJID paramcd;
	id avisitn;
	var aval;
run;

data flg;
	merge trans_a;
	if _3 not in (.) and _2 not in (.) and 
    _1 not in (.) then &con.="Y";	
run;
proc sort data=flg ;by usubjid paramcd;run;
proc sort data=inds_;by usubjid paramcd;run;

data inds;
	merge inds_(in=a) flg(in=b);
	by usubjid paramcd;
	if &con. eq "Y";
run;

/*Check nobs */
proc sql noprint;
	select count(*) into :obs from inds;
quit; 

%if &obs ne 0 %then %do;

/*Generating required macro variables*/
proc sql noprint;
	create table param as select distinct paramn,paramcd,param from inds;
quit;

proc sql noprint;
	select paramcd into: paramcd separated by '$'  from param;
	select strip(tranwrd(param,"ABC","")) into: param separated by '$' from param;
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
	keep usubjid subjid param paramn paramcd parcat1 trtgrp trtgrpn avisitn avisit aval chg;
run;

/*Group Mean Calculation*/
proc sort data=inds1(keep=usubjid subjid trtgrpn trtgrp paramn param paramcd avisitn avisit aval chg);
	by trtgrpn trtgrp avisitn avisit paramn paramcd;
run;

proc means data=inds1 noprint;
	by trtgrpn trtgrp avisitn avisit paramn paramcd;
	var chg;
	output out = stat(drop=_type_ _freq_) mean = mean std=std;
quit;

/*Standard Error Calculation*/
data inds2(drop=mean std);
	set stat;
	if missing(mean) then mean=0;
	if missing(std) then std=0;
	yvalue=mean;
	yhigh=mean + std;
	ylow=mean - std;
	ylow_=ylow;
	yhigh_=yhigh;
	mean_n1=mean;
	if avisitn=1 then do;
		mean_n1=.;ylow_=.;yhigh_=.;
	end;

run;

/*Merge with original datasets to get subject information for the individual plot*/
data inds3;
	merge inds2(in=a) inds1(in=b);
	by trtgrpn trtgrp avisitn avisit paramn paramcd;
/*	Find the max value comparing all variables*/
	maxval=max(yvalue,yhigh,ylow,chg);
	minval=min(yvalue,yhigh,ylow,chg);
	proc sort;by trtgrpn avisitn paramn;
run;

/*Series Plot Mean value*/
data inds4;
	set inds3;
	by  trtgrpn avisitn paramn;
	if first.paramn then mean=yvalue;
	else mean=.;
	if missing(chg) then chg=0;
run;

/*Final dataset*/
proc sort data=inds4 out=final;
    by paramn trtgrpn avisitn subjid ;
run;

/*Title dataset for proc report*/
data tit;  
	text=1;
run;

/*Generating individual macro variables for min, max and by values for axis scaling*/
%macro loop();
%do i=1 %to %sysfunc(countw(&paramcd));
	data _null_;
	%let paramcd_ = %scan(&paramcd,&i);
	%let param2_ = %scan(&param,&i,'$');
	call execute ('%nrstr(%axisorder(data=final,var=yvalue yhigh ylow chg,prefix=&paramcd_,majtarg=15,
	where=paramcd=("&paramcd_"),param=&param2_))');
	run;
%end;
%mend loop;
%loop;
%clean;
*************************************************************************
								QC
*************************************************************************;
data v_fig.&progname2;
	set final;
	keep  USUBJID SUBJID TRTGRPN TRTGRP AVISITN AVISIT PARAMN PARAM AVAL CHG YVALUE YHIGH YLOW;
run; 

*************************************************************************
								Output									
*************************************************************************;

ods listing close;
ods path template.RTFtemplate sashelp.tmplmst;   
ods rtf file="&ecce_out_graphs.\&progname..rtf" style=tables nogtitle nogfootnote;  
ods escapechar="~";
options nobyline;
ods graphics on / width=8in height=4.3in noborder;

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

/*Atrribute map dataset for individual subjects*/
proc sort data=inds4 out=subj1;
	by subjid;
	where paramcd="&paramcd_";

data subj;
	length value  linecolor id $100.;
	set subj1;
	by subjid;
	if first.subjid;
	value=subjid;
	id='MakeAttr1';
/*Colour individual subject treatment wise*/
	if trtgrpn=1 then linecolor='black';
	if trtgrpn=2 then linecolor='blue';
	keep value  linecolor id ;
run;

/*Atrribute map dataset for individual treatment groups*/
data attr_map;
	length id value linecolor markercolor markersymbol linepattern $100;
	id='MakeAttr';
/*TRTA*/
	value = "TRTA;
	linecolor ='black';
	markercolor='black';
	markersymbol='circle';
	linethickness=4;
	linepattern='Solid';
	output;
/*TRTB*/
	value = "TRTB";
	linecolor ='blue';
	markercolor='blue';
	markersymbol='plus';
	linethickness=4;
	linepattern='Solid';
	output;
	keep  id value linecolor markercolor markersymbol linepattern;
run;

/*Append Subject attr_map and treament attr_map dataset*/
data attr_map_;
	set attr_map subj;
run;

/*Filter only subjects*/
data subj;
	set attr_map_;
	where id='MakeAttr1';
	n=_n_;
run;

/*Attribute dataset*/
data sym;
	length  linepattern $100.;
	n=1; linepattern='ShortDash'; output;
	n=2; linepattern='MediumDash'; output;
	n=3; linepattern='LongDash'; output;
	n=4; linepattern='MediumDashShortDash'; output; 
	n=5; linepattern='DashDashDot'; output; 
	n=6; linepattern='DashDotDot'; output;
	n=7; linepattern='Dash'; output;
	n=8; linepattern='LongDashShortDash'; output;
	n=9; linepattern='ShortDashDot'; output;
	n=10;linepattern='MediumDashDotDot'; output;
	n=11; linepattern='ShortDash'; output;
	n=12; linepattern='MediumDash'; output;
	n=13; linepattern='LongDash'; output;
	n=14; linepattern='MediumDashShortDash'; output; 
	n=15; linepattern='DashDashDot'; output; 
	n=16; linepattern='DashDotDot'; output;
	n=17; linepattern='Dash'; output;
	n=18; linepattern='LongDashShortDash'; output;
	n=19; linepattern='ShortDashDot'; output;
	n=20;linepattern='MediumDashDotDot'; output;
run;

proc sql noprint;
	select count(*) into :subj from subj;
quit; 

/*Merge attributes with subjects*/
data subj_;
	merge subj(in=a) sym(in=b where=(n<=&subj));
	by n;
run;

proc sort data=attr_map;by value;run;

/*Merge attr_subject dataset with treatment attribute dataset*/
data attr_mapf;
	length markersymbol linepattern $100.;
	merge attr_map(in=a) subj_(in=b);
	by value;
	if id='MakeAttr1' then do; 
	keyleg = catx(' ', 'legenditem', 'type=LINE', 'name="' || strip(value) || '"', '/label="' || strip(value) || '"',
	 'lineattrs=(color=' || strip(linecolor) || '', 'pattern=' || strip(linepattern) || ');');
	end;
	drop n;
run;

/*Generate macro variables for keylegend and legend statements*/
proc sql noprint;
	select keyleg into :Keyleg separated by "" from attr_mapf where id='MakeAttr1';
	select distinct compress(cat('''',value,''''))  into :subjid separated by ' ' from attr_mapf where id='MakeAttr1';
quit;

/*SGPLOT*/
proc sgplot data=final(where=(paramcd="&paramcd_"))noautolegend dattrmap=attr_mapf;
	format avisitn vsnin.;
	
*Standard errors;
	scatter x=avisitn y=mean_n1 /yerrorlower=ylow_ yerrorupper=yhigh_ group=trtgrp attrid=MakeAttr markerattrs=(size=3);
*Group mean series;
	series x=avisitn y=yvalue/ group=trtgrp attrid=MakeAttr lineattrs=(thickness=3);
*Individual subjects;
	series x=avisitn y=chg/ group=subjid attrid=MakeAttr1 lineattrs=(thickness=2);
	
	xaxis labelattrs=(size=10pt) values=(1 2 3) display=(nolabel);
	
	yaxis display=all label="Change from Week : &param_"  
	
	labelattrs=(size=10pt) values=(&&_&paramcd_.Axisstart to &&_&paramcd_.Axisend by &&_&paramcd_.Axisby);
	legenditem type=line name="TRTA"/
	    label="TRTA" lineattrs=(color=black);

	legenditem type=line name="TRTB"/
	    label="TRTB" lineattrs=(color=blue);

	keylegend "TRTA" "TRTB" / location=inside POSITION=topleft across=1
	    valueattrs=(Color=black Size=8pt Weight=Normal) noborder;
		
/*Individual legend statements*/
	&keyleg.;
	
	 keylegend &subjid./ noborder   valueattrs=(Color=black Size=10pt Weight=Normal);
run;
run;

%end;
ods graphics off;
ods rtf close;
ods path reset;
%mend plot;
ods rtf startpage = Yes;

%plot;
%end;

/*NO DATA REPORT*/
%if &obs eq 0 %then %do;		
data finala;
	array temp{*} $200. usubjid subjid trtgrp avisit param paramcd; 
		paramn=.;avisitn=.;trtgrpn=.;mean_n=.; min_n=.; max_n=.;
run;

data tit;  
	text=1;
run;

data v_fig.&progname2;
	set finala;
run;

*************************************************************************
								Output
*************************************************************************;

	ods listing close;
	ods path template.RTFtemplate sashelp.tmplmst;   
	ods rtf file="&ecce_out_graphs.\&progname..rtf" style=tables;  
	ods escapechar="~";
	options nobyline;
	%toc(item=&progname,toctab1=Figures - Section B, getnames=yes); 

	 proc report nowd headline headskip  missing split = '\' spacing=4 data = tit
		 style(report) = {rules=groups frame=above borderwidth=0.75 outputwidth=100%} ;
		columns text  ;
		define text / order noprint;
	    compute before text/style=[just=c];
		line @1 "";
		line @1 "";
		line @1  "No Data to report";
		endcomp;
	  run;

	title;
	footnote;
%end;
ods rtf startpage = Yes; 
ods graphics off;
ods rtf close;

%mend cfwplot;

%cfwplot(data=adca,where=not missing(paramcd),con=flg1);
