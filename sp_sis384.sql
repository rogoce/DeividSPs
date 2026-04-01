-- Numero Interno de Poliza de la ultima Vigencia
-- dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis384;

CREATE PROCEDURE "informix".sp_sis384(a_anio smallint, a_mes CHAR(2)) RETURNING CHAR(10);

DEFINE _no_poliza      CHAR(10);
DEFINE _vigencia_final DATE;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;

FOREACH
 SELECT	no_poliza,
	    vigencia_final
   INTO	_no_poliza,
	    _vigencia_final
   FROM	emipomae
  WHERE no_documento       = a_no_documento
	AND actualizado        = 1
  ORDER BY vigencia_final DESC
	EXIT FOREACH;
END FOREACH


	string ls_ult
	long ll_ult_1,ll_ult_2,ll_ult_3

	SELECT max(substr(cgltrx1.trx1_comprobante,4,8)-0)
	INTO :ls_ult
	FROM cgltrx1
	where substr(cgltrx1.trx1_comprobante,1,2) = :ls_mes
	and year(cgltrx1.trx1_fecha) 	= :li_anio 
	Using g_globales.sqlca_sac; 
//	and   month(cgltrx1.trx1_fecha) = :li_mes	;
  
   if isnull(ls_ult) then 
		ll_ult_1 = 0
	else
		ll_ult_1 = long(ls_ult)
	end if
	
	SELECT max(substr(cglresumen.res_comprobante,4,8)-0)
	INTO :ls_ult
	FROM cglresumen
   where substr(cglresumen.res_comprobante,1,2) = :ls_mes
   and  year(cglresumen.res_fechatrx) = :li_anio 
	Using g_globales.sqlca_sac; 
// and   month(cglresumen.res_fechatrx)	= :li_mes ;	

   if isnull(ls_ult) then 
		ll_ult_2 = 0
	else
		ll_ult_2 = long(ls_ult)
	end if

	if ll_ult_1 > ll_ult_2 then
		ls_ult = string(ll_ult_1)
	else
		ls_ult = string(ll_ult_2)
	end if	
	ll_ult_3 = long(ls_ult)
	
	return ll_ult_3


RETURN _no_poliza;

END PROCEDURE;