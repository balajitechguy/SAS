/**************************************************************************************************
* Program Name   : Openexcel_word.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to open excel and word files using sas
******************************************************************************************************/
/*TO OPEN WORD FILES*/
%let rc=%sysfunc(system(start winword)); 
filename cmds dde 'winword|system';
 
data _null_;
	file cmds;
	/* STUDY PROTOCOL*/
	put '[FileOpen.Name = "C:\Users\balajim\Desktop\MY CODES\Protocol-or-Amendment.docx"]';
	/*MOCK SHELL*/
	put '[FileOpen.Name = "C:\Users\balajim\Desktop\MY CODES\TLG Shells FInal.docx"]';
	/*STUDY SAP*/
	put '[FileOpen.Name = "C:\Users\balajim\Desktop\MY CODES\Final SAP.docx"]';
run;
 
/*TO OPEN EXCEL FILES*/
%let rc1=%sysfunc(system(start excel)); 
filename excel dde 'excel|system';
 
data _null_;
	file excel;
	/*TRACKING LOG*/
	put '[open("C:\Users\balajim\Desktop\MY CODES\Tracking log.xlsx")]'; 
	/* SDTM SPEC*/
	put  '[open("C:\Users\balajim\Desktop\MY CODES\SDTM Mapping Specification.xlsx")]';
	/*ADAM SPEC*/
	put '[open("C:\Users\balajim\Desktop\MY CODES\ADaM_Mapping_Specification - Copy.xlsx")]';
	/*STUDY ISSUE LOG*/
	put '[open("C:\Users\balajim\Desktop\MY CODES\Study_Issuelog.xlsx")]';
run;