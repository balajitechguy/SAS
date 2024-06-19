/**************************************************************************************************
* Program Name   : Paste content on specific row and column in a excel sheet
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to paste content at particular row and column
******************************************************************************************************/
ods excel file="O:\Users\Balaji.M\test.xlsx" options(start_at="5,7");

proc sql;
	select name from sashelp.class where name="Alfred";
quit;
 
ods excel close;

