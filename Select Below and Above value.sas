/**************************************************************************************************
* Program Name   : Select.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to filter the row above and below using point option
******************************************************************************************************/

data class;
set sashelp.class;
run;

data select;
set class;
if Name="Jeffrey" then do p=max(_n_-1,1) to min(_n_+1,nobs);
  set class point=p nobs=nobs;
  output;
  end;
run;