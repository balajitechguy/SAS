/**************************************************************************************************
* Program Name   : SidebySideAlign.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to align graphs side by side in RTF
******************************************************************************************************/

options orientation=landscape;
 
ods rtf file='O:\Users\Balaji.M\demo.rtf' columns=2 style=seaside;
 
ods graphics / width= 4in height=5in;
 
/*GRAPH1*/
proc sgscatter data=sashelp.class;
matrix age weight height / group=sex;
run;
 
/*GRAPH2*/
proc sgscatter data=sashelp.cars;
matrix mpg_city mpg_highway msrp invoice;
run;
 
ods rtf close;