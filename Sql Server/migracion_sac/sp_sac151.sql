-- Ultima secuencia de comprobante por anio-mes
-- Creado    : 02/03/2001 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sac151;

CREATE PROCEDURE "informix".sp_sac151(a_anio smallint, a_mes CHAR(2)) RETURNING INTEGER;
define ls_ult          char(5);
define ll_ult_d        INTEGER;
define ll_ult_1        integer;
define ll_ult_2        integer;
define ll_ult_3        integer;
define ls_ult_auditoria char(5);
define ll_ult_auditoria integer;
define ls_anofiscal     char(4);
define ls_mesfiscal   	char(2);


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_sac151.trc";
--trace on;
let ls_ult = 0;
let ll_ult_auditoria = 0;
let ls_ult_auditoria = "";
FOREACH
	SELECT substr(cgltrx1.trx1_comprobante,4,8)
	  INTO ls_ult
	  FROM cgltrx1
	 where substr(cgltrx1.trx1_comprobante,1,2) = a_mes 
	   and year(cgltrx1.trx1_fecha) 	        = a_anio
	 order by substr(cgltrx1.trx1_comprobante,4,8)-0 desc 
EXIT FOREACH;
END FOREACH

if ls_ult is null  then 
	let ls_ult = 0;
end if
if ls_ult = 0 then 
	let ll_ult_1 = 0;
else
	let ll_ult_1 = ls_ult;
end if
FOREACH
SELECT substr(cglresumen.res_comprobante,4,8)
INTO ls_ult
FROM cglresumen
where substr(cglresumen.res_comprobante,1,2) = a_mes and year(cglresumen.res_fechatrx) = a_anio --; 
  and substr(cglresumen.res_comprobante,4,8) not in ("32224051","32224052","32224053","32224054","32224055") --<> "32224"
order by substr(cglresumen.res_comprobante,4,8)-0 desc
EXIT FOREACH;
END FOREACH

if ls_ult is null  then 
	let ls_ult = 0;
end if
if ls_ult = 0 then 
	let ll_ult_2 = 0;
else
	let ll_ult_2 = ls_ult;
end if

if ll_ult_1 > ll_ult_2 then
	let ll_ult_d = ll_ult_1;
else
	let ll_ult_d = ll_ult_2 ;
end if	

-- se coloco por la variacion de que se pueda registrar comprobantes sin haber cerrado 14
SELECT cglparam.par_mesfiscal,par_anofiscal
  INTO ls_mesfiscal, ls_anofiscal  
  FROM cglparam ; 
let ll_ult_auditoria = 0;

if ls_mesfiscal = "13" or ls_mesfiscal = "14" then
	FOREACH
	SELECT substr(cgltrx1.trx1_comprobante,4,8)
	INTO ls_ult_auditoria
	FROM cgltrx1
	where substr(cgltrx1.trx1_comprobante,1,2) = a_mes and year(cgltrx1.trx1_fecha) = ls_anofiscal --;  
	and cgltrx1.trx1_concepto in ("020","021")
	order by substr(cgltrx1.trx1_comprobante,4,8)-0 desc 
	EXIT FOREACH;
	END FOREACH
end if

if ls_ult_auditoria is null then 
	let ll_ult_auditoria = 0;
else
	let ll_ult_auditoria = ls_ult_auditoria;
end if

if ll_ult_auditoria >  ll_ult_d then
	let ll_ult_d = ll_ult_auditoria;
end if


return ll_ult_d	;

END PROCEDURE;	  	  




