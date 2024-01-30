/**************************************************************************************************
* Program Name   : Individual Plot.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use Macrotize the process of generating individual plot so that no manual subject addition is required
******************************************************************************************************/

/*SETUP*/
options nosource;
%if DMS=%sysfunc(getoption(dms)) %then %do;
%macro closevts;
    %do i=1 %to 10; 
        data _null_;
            dm 'next VIEWTABLE:; end;'; 
        run;
    %end; 
%mend;
%closevts
proc delete data=work._all_;run;
dm 'odsresults; clear';
dm "log" clear continue;
%end;
options source;

/*DATASET LOCATION*/
libname ads "O:\Eisai\projects\f7029\a001-001\biostats\csr\dev\data\ads" access=readonly;
***********************************************************************;
**                        Required datasets                          **;
***********************************************************************;
proc sort data=ads.adsl out=adsl;
	by usubjid;
	where pdfl='Y' and trt01a ne "";
run;

/*Bign Count Calculation*/
proc sql noprint;
	create table Bign as 
	select distinct count(distinct usubjid) as T_Bign, trt01an, trt01a
	from adsl
	group by trt01an
	order by trt01an;
quit;

/*Creating Dummy*/
data dummy;
	length trt01a $30.;
	trt01a='Placebo';trt01an=1;Output;
	trt01a='Cohort1 f7029 1 mg';trt01an=2;Output;
	trt01a='Cohort2 f7029 2.5 mg';trt01an=3;Output;
	trt01a='Cohort3 f7029 5 mg';trt01an=4;Output;
	trt01a='Cohort4 f7029 10 mg';trt01an=5;Output;
	trt01a='Cohort5 f7029 25 mg';trt01an=6;Output;
	trt01a='Cohort6 f7029 50 mg';trt01an=7;Output;
	trt01a='Cohort7 f7029 100 mg';trt01an=8;Output;
	trt01a='Cohort8 f7029 25 mg';trt01an=9;Output;
run;
proc sort; by trt01an; run;

data bign_;
	merge dummy bign;
	by trt01an;
	if T_Bign=. then T_Bign=0;
run;

data _null_;
  set Bign_;
  call symputx("Bign"||strip(put(trt01an,best.)),T_Bign);
run;

%put &bign1 &bign2 &bign3 &bign4 &bign5 &bign6 &bign7 &bign8 &bign9 ;


data adpc;
    set ads.adpc;
/*	PCSPEC eq PLASMA is the proper condition but for simulation purpose PCSPEC is assigned as BLOOD*/
    where pcstat ne 'NOT DONE' & PCSPEC = "BLOOD" & anl01fl="Y";
/*	Since aval is missing random values are populated for simulation*/
	if missing(aval) then aval = floor(ranuni(0) * 50) + 0;
run;

data adpc_t;
    merge adsl(in=a) adpc(in=b);
    by usubjid;
    if a & b;
    keep usubjid subjid param: avisit: atpt: aval avalc trt01a: avisit: ady;
run;

proc sort data=adpc_t out=final;
  by trt01an usubjid avisitn atptn ;
run;


/*Attribute Map Dataset*/

%macro rep(attr_data=, list=, big=, trt=, sub=, line=);
%if &&&big. ^= 0 %then %do;

/*Unique Subjcects Dataset*/
proc sql noprint;
	create table uq as
	select distinct trt01an,trt01a,subjid
	from final
	order by trt01an,subjid;
quit;

/*Subjects list generation*/
proc sql noprint;
	%global lis_placebo lis_1mg lis_2_5mg lis_5mg lis_10mg lis_25mg lis_100mg lis_e25mg;
    select  compress(cat('''',subjid,''''))  into :&list separated by " "	from uq where trt01a=&trt;
quit;

/*Markersymbol and linepattern*/
data x1;
length X Y $50;
n=1; x='SquareFilled'; y='Solid'; output;
n=2; x='DiamondFilled'; y='longdash'; output;
n=3; x='Asterisk'; y='dashdashdot'; output;
n=4; x='CircleFilled'; y='shortdash'; output; 
n=5; x='HomeDownFilled'; y='dashdotdot'; output; 
n=6; x='HomeDown'; y='dash'; output;
n=7; x='ArrowDown'; y='shortdashdot'; output;
n=8; x='Ibeam'; y='thindot'; output;
n=9; x='Square'; y='mediumdashshortdash'; output;
n=10; x='Triangle'; y='longdashshortdash'; output;
run;

/*Generating list of markersymbol and linepattern according to bign value*/
proc sql noprint;
	select compress(cat('''',x,''''))  into :Xvar separated by ', ' from X1 where n <= &&&big.;
	select compress(cat('''',y,''''))  into :Yvar separated by ', ' from X1 where n <= &&&big.;
quit;

/*Attribute dataset for individual treatment groups*/
data &attr_data.;	
	length value markersymbol markercolor linecolor linepattern $100;
	array sub[&&&big.] $100 (&&&list.);
	array marker_sym[&&&big.] $100 (&Xvar.);
	array line_pat[&&&big.] $100 (&Yvar.);
		do i=1 to &&&big.;
		 	id='MakeAttr';
	        value = sub[i];
	        markersymbol = marker_sym[i];
	        markercolor = 'blue';
	        linecolor = 'blue';  /*Plasma: Blue*/
	        linepattern = line_pat[i];
	        output;
	    end;
	keep id value markersymbol markercolor linecolor linepattern;
run;

/*Generating individual macro variables of subjects and linepattern*/
data _null_;
	set &attr_data.;
   call symputx(&sub||compress(put(_n_,2.)),compress((cat('''',value,''''))),"G");                                                                             
   call symputx(&line||compress(put(_n_,2.)),strip(linepattern),"G");                                                                             
run;

%end;
%mend rep; 

/*Macro variables description*/
/*
*attr_data: attribute dataset name for individual treatment group
*list: 		contains a list of subjects  for individual treatment group
*big: 		bign value for indiviudal dataset
*trt: 		treatment group name
*sub:		contains all individual subjects in individual macro variables
*line: 		contains all individual linepatterns in individual macro variables
*/

/*Placebo*/
%rep(attr_data=attr_placebo,list=lis_placebo,big=bign1,trt="Placebo",sub="sub_placebo",line="line_placebo");
/*Cohort1 f7029 1 mg*/
%rep(attr_data=attr_1mg,list=lis_1mg,big=bign2,trt="Cohort1 f7029 1 mg",sub="sub_1mg",line="line_1mg");
/*Cohort2 f7029 2.5 mg*/
%rep(attr_data=attr_2_5mg,list=lis_2_5mg,big=bign3,trt="Cohort2 f7029 2.5 mg",sub="sub_2_5mg",line="line_2_5mg");
/*Cohort3 f7029 5 mg*/
%rep(attr_data=attr_5mg,list=lis_5mg,big=bign4,trt="Cohort3 f7029 5 mg",sub="sub_5mg",line="line_5mg");
/*Cohort4 f7029 10 mg*/
%rep(attr_data=attr_10mg,list=lis_10mg,big=bign5,trt="Cohort4 f7029 10 mg",sub="sub_10mg",line="line_10mg");
/*Cohort5 f7029 25 mg*/
%rep(attr_data=attr_25mg,list=lis_25mg,big=bign6,trt="Cohort5 f7029 25 mg",sub="sub_25mg",line="line_25mg");
/*Cohort6 f7029 50 mg*/
%rep(attr_data=attr_50mg,list=lis_50mg,big=bign7,trt="Cohort6 f7029 50 mg",sub="sub_50mg",line="line_50mg");
/*Cohort7 f7029 100 mg*/
%rep(attr_data=attr_100mg,list=lis_100mg,big=bign8,trt="Cohort7 f7029 100 mg",sub="sub_100mg",line="line_100mg");
/*Cohort8 f7029 25 mg*/
%rep(attr_data=attr_e25mg,list=lis_e25mg,big=bign9,trt="Cohort8 f7029 25 mg",sub="sub_e25mg",line="line_e25mg");


*************************************************************************
								Output									
*************************************************************************;
%macro rpt1(attr_data=, list=, chk=, sub=, line=, title=, cond=, clr=);

%if &chk.>0 %then %do;
	title &title.;
	proc sgplot data=final dattrmap=&attr_data. noautolegend;
    series x=atptn y=aval  / group=subjid grouporder= ascending attrid=makeattr lineattrs=(color=&clr. ) name="2086";
	yaxis label="Plasma Concentration (nmol/L)"  labelattrs=(size=10pt) values=(0 to 50 by 10);
    xaxis label="Actual Time(h)" labelattrs=(size=10pt) values=(0 12 18 24 48 72 96 120 144 216) fitpolicy=rotate;

	where trt01a=&cond.;

	%if &&chk. >= 1  %then %do;
	legenditem type=LINE name=&&&sub.1/ label=&&&sub.1 lineattrs=(color=&clr. pattern=&&&line.1) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 2 %then %do;
	legenditem type=LINE name=&&&sub.2 / label=&&&sub.2. lineattrs=(color=&clr. pattern=&&&line.2) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 3 %then %do;
	legenditem type=LINE name=&&&sub.3 / label=&&&sub.3 lineattrs=(color=&clr. pattern=&&&line.3) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 4 %then %do;
	legenditem type=LINE name=&&&sub.4 / label=&&&sub.4 lineattrs=(color=&clr. pattern=&&&line.4) markerattrs=(color=&clr.);
	%end;
    %if &&chk. >= 5 %then %do;
	legenditem type=LINE name=&&&sub.5 / label=&&&sub.5 lineattrs=(color=&clr. pattern=&&&line.5) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 6 %then %do;
	legenditem type=LINE name=&&&sub.6 / label=&&&sub.6 lineattrs=(color=&clr. pattern=&&&line.6) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 7 %then %do;
	legenditem type=LINE name=&&&sub.7 / label=&&&sub.7 lineattrs=(color=&clr. pattern=&&&line.7) markerattrs=(color=&clr.);
	%end;
	%if &&chk. >= 8 %then %do;
	legenditem type=LINE name=&&&sub.8 / label=&&&sub.8 lineattrs=(color=&clr. pattern=&&&line.8) markerattrs=(color=&clr.);
	%end;
/*	 Incase of incrementing the legenditem. Please add the if condition step and macro variable &chk.>=N */
	 keylegend &&&list./ noborder   valueattrs=(Color=&clr. Size=9pt Weight=Normal);
run;
%end;
%mend rpt1;


/*Macro variables description*/
/*
*attr_data: attribute dataset name for individual treatment group
*list: contains a list of subjects each treatment group
*chk: Bign_pc count for each treatment group
*sub: contains all individual subjects in individual macro variables
*line: contains all individual linepatterns in individual macro variables
*cond: unique treatment group
*title:  to modify title according to your treatment group
*clr  :
*/

/*For placebo*/
%rpt1(attr_data=attr_placebo,list=lis_placebo,chk=&Bign1.,sub=sub_placebo,line=line_placebo,
cond="Placebo",title="Placebo",clr=black);

/*For Cohort1 f7029 1 mg*/
%rpt1(attr_data=attr_1mg,list=lis_1mg,chk=&Bign2.,sub=sub_1mg,line=line_1mg,
cond="Cohort1 f7029 1 mg", title="f7029 1 mg",clr=blue);

/*For Cohort2 f7029 2.5 mg*/
%rpt1(attr_data=attr_2_5mg,list=lis_2_5mg,chk=&Bign3.,sub=sub_2_5mg,line=line_2_5mg,
cond="Cohort2 f7029 2.5 mg",title="f7029 2.5 mg",clr=red);

/*For Cohort3 f7029 5 mg*/
%rpt1(attr_data=attr_5mg,list=lis_5mg,chk=&Bign4.,sub=sub_5mg,line=line_5mg,
cond="Cohort3 f7029 5 mg",title="f7029 5 mg",clr=Green);

/*For Cohort4 f7029 10 mg*/
%rpt1(attr_data=attr_10mg,list=lis_10mg,chk=&Bign5.,sub=sub_10mg,line=line_10mg,
cond="Cohort4 f7029 10 mg",title="f7029 10 mg",clr=Brown);

/*For Cohort5 f7029 25 mg*/
%rpt1(attr_data=attr_25mg,list=lis_25mg,chk=&Bign6.,sub=sub_25mg,line=line_25mg,
cond="Cohort5 f7029 25 mg",title="f7029 25 mg",clr=purple);

/*For Cohort6 f7029 50 mg*/
%rpt1(attr_data=attr_50mg,list=lis_50mg,chk=&Bign7.,sub=sub_50mg,line=line_50mg,
cond="Cohort6 f7029 50 mg",title="f7029 50 mg",clr=VIB);

/*For Cohort7 f7029 100 mg*/
%rpt1(attr_data=attr_100mg,list=list100mg,chk=&Bign8.,sub=sub_100mg,line=line_100mg,
cond="Cohort7 f7029 100 mg",title="f7029 100 mg",clr=Orange);

/*For Cohort8 f7029 25 mg*/
%rpt1(attr_data=attr_e25mg,list=lis_e25mg,chk=&Bign9.,sub=sub_e25mg,line=line_e25mg,
cond="Cohort8 f7029 25 mg",title="f7029 25 mg",clr=Grey);
