/**************************************************************************************************
* Program Name   : Reduce length of variable without warning
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use reduce length of variable without warning
******************************************************************************************************/
data check;
	length name $200.;
	name="Balaji";
run;

proc sql;
	alter table check modify name char(10);
quit;