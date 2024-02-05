/**************************************************************************************************
* Program Name   : RFPENDTC.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to compute rfpendtc value in simplified manner
******************************************************************************************************/

data alldate;
    set raw.ic(rename=(icdat_yyyy=yyyy icdat_mm=mm icdat_dd=dd) keep=subject icdat_yyyy icdat_mm icdat_dd) 
     raw.sdd(rename=(rtrndt_yyyy=yyyy rtrndt_mm=mm rtrndt_dd=dd) keep=subject rtrndt_yyyy rtrndt_mm rtrndt_dd)
     raw.sd(rename=(lastdt_yyyy=yyyy lastdt_mm=mm lastdt_dd=dd) keep=subject lastdt_yyyy lastdt_mm lastdt_dd)
/*     AESTART*/
     raw.ae(rename=(aestdat_yyyy=yyyy aestdat_mm=mm aestdat_dd=dd) keep=subject aestdat_yyyy aestdat_mm aestdat_dd)
/*     AEND*/
     raw.ae(rename=(aeendat_yyyy=yyyy aeendat_mm=mm aeendat_dd=dd) keep=subject aeendat_yyyy aeendat_mm aeendat_dd)
     raw.visit(rename=(visitdat_yyyy=yyyy visitdat_mm=mm visitdat_dd=dd) keep=subject visitdat_yyyy visitdat_mm visitdat_dd)
     raw.pt(rename=(ptdat_yyyy=yyyy ptdat_mm=mm ptdat_dd=dd) keep=subject ptdat_yyyy ptdat_mm ptdat_dd)
/*     CMSTART*/
     raw.cm(rename=(cmstdat_yyyy=yyyy cmstdat_mm=mm cmstdat_dd=dd) keep=subject cmstdat_yyyy cmstdat_mm cmstdat_dd)
/*     CMEND*/
     raw.cm(rename=(cmendat_yyyy=yyyy cmendat_mm=mm cmendat_dd=dd) keep=subject cmendat_yyyy cmendat_mm cmendat_dd)
     raw.cssr_scr(rename=(csrdt_yyyy=yyyy csrdt_mm=mm csrdt_dd=dd) keep=subject csrdt_yyyy csrdt_mm csrdt_dd)
     raw.cssr_scr2(rename=(csrdt_yyyy=yyyy csrdt_mm=mm csrdt_dd=dd) keep=subject csrdt_yyyy csrdt_mm csrdt_dd)
     raw.cssr_slv(rename=(csrdt_yyyy=yyyy csrdt_mm=mm csrdt_dd=dd) keep=subject csrdt_yyyy csrdt_mm csrdt_dd)
     raw.echo(rename=(echodt_yyyy=yyyy echodt_mm=mm echodt_dd=dd) keep=subject echodt_yyyy echodt_mm echodt_dd)
     raw.eg(rename=(egdat_yyyy=yyyy egdat_mm=mm egdat_dd=dd) keep=subject egdat_yyyy egdat_mm egdat_dd)
     raw.eq5d5l(rename=(eq5ddt_yyyy=yyyy eq5ddt_mm=mm eq5ddt_dd=dd) keep=subject eq5ddt_yyyy eq5ddt_mm eq5ddt_dd)
      raw.eq5d5li(rename=(eq5ddt_yyyy=yyyy eq5ddt_mm=mm eq5ddt_dd=dd) keep=subject eq5ddt_yyyy eq5ddt_mm eq5ddt_dd)
     raw.fad(rename=(faddat_yyyy=yyyy faddat_mm=mm faddat_dd=dd) keep=subject faddat_yyyy faddat_mm faddat_dd)
     raw.fall(rename=(falldt_yyyy=yyyy falldt_mm=mm falldt_dd=dd) keep=subject falldt_yyyy falldt_mm falldt_dd)
     raw.mfars(rename=(mfarsdt_yyyy=yyyy mfarsdt_mm=mm mfarsdt_dd=dd) keep=subject mfarsdt_yyyy mfarsdt_mm mfarsdt_dd)
     raw.mfis(rename=(mfisdt_yyyy=yyyy mfisdt_mm=mm mfisdt_dd=dd) keep=subject mfisdt_yyyy mfisdt_mm mfisdt_dd)
     raw._1mwt(rename=(_1mwtdt_yyyy=yyyy _1mwtdt_mm=mm _1mwtdt_dd=dd) keep=subject _1mwtdt_yyyy _1mwtdt_mm _1mwtdt_dd)
     raw.pe2(rename=(pedat_yyyy=yyyy pedat_mm=mm pedat_dd=dd) keep=subject pedat_yyyy pedat_mm pedat_dd);
 
     if not missing(yyyy) & not missing(mm) & not missing(dd) then rfpendtc=compress(put(yyyy,4.0)||"-"||put(mm,z2.)||"-"||put(dd,z2.));
run;
 
proc sort data=alldate;by subject rfpendtc;run;
 
data alldate_(keep=subject rfpendtc);set alldate;by subject;if last.subject;run;