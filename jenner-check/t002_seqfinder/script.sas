/**************************************************************************************************
* Program Name   : Filter records with a particular sequence of numbers row-wise.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to Filter records which doesnt satisfy the condition
******************************************************************************************************/

/*Test data objective is to find sequence 8, 0, 1 in a dataset*/
data testdata;
	subject=1001;seq=1;output;
	subject=1001;seq=2;output;
	subject=1002;seq=8;output;
	subject=1002;seq=0;output;
	subject=1002;seq=1;output;
	subject=1003;seq=1;output;
	subject=1003;seq=2;output;
	subject=1003;seq=3;output;
	subject=1004;seq=3;output;
	subject=1004;seq=7;output;
	subject=1004;seq=8;output;
run;
 
/*Use lag function to implement necessary variables*/
data seqfinder;
    set testdata;
	lag1=lag(seq);
	lag2=lag2(seq);
	obs=_n_;
	if lag2=8 and lag1=0 and seq=1 then seqfind="Y";
run;
 
/*Use proc sql to filter only necessary records*/
proc sql noprint;
	select distinct obs into:lastrow separated by "," from seqfinder where seqfind="Y";
	select distinct (obs-1) into:middlerow separated by "," from seqfinder where seqfind="Y";
	select distinct (obs-2) into:firstrow separated by "," from seqfinder where seqfind="Y";
	create table reqrecords as select subject,seq from seqfinder where obs in (&firstrow,&middlerow,&lastrow);
quit;

 