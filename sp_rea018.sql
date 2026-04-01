-- Reporte de Siniestros Incurridos Cedidos 
-- (Solo salvamento y Recupero)
--
-- Creado    : 05/08/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec38a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rea018;

CREATE PROCEDURE "informix".sp_rea018(a_periodo1 CHAR(7),a_periodo2 CHAR(7), a_ramo CHAR(255) DEFAULT "*") 
RETURNING CHAR(20),
		  CHAR(10),
		  CHAR(20),
		  DECIMAL(16,2),
		  DECIMAL(16,2);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE _transaccion      CHAR(10); 

define _no_tranrec		char(10);
define _no_registro		char(10);
define _monto_reas		dec(16,2);

DEFINE v_filtros        CHAR(255);

SET ISOLATION TO DIRTY READ; 

-- Cargar el Incurrido
{
LET v_filtros = sp_rec38(
"001",
"001",
a_periodo1,
a_periodo2,
"*",
'*', 
a_ramo,
'*', 
'*', 
'*', 
'*',
"*"  
); 


FOREACH
 SELECT pagado_neto,
		numrecla,
		transaccion,
		doc_poliza
   INTO	v_pagado_neto,
	    v_doc_reclamo,
		_transaccion,
		v_doc_poliza
   FROM tmp_sinis
  WHERE seleccionado = 1
  ORDER BY nombre_contrato,cod_ramo
 
	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where transaccion = _transaccion;
	 
	select no_registro
	  into _no_registro
	  from sac999:reacomp
	 where no_tranrec = _no_tranrec;

	select sum(debito - credito)
	  into _monto_reas
	  from sac999:reacompasie
	 where no_registro = _no_registro
	   and cuenta      like "417%";

	RETURN v_doc_reclamo,
		   _transaccion,
	 	   v_doc_poliza,
	 	   v_pagado_neto,
		   _monto_reas * -1
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
}

foreach
 select no_tranrec
   into _no_tranrec
   from sac999:reacomp
  where tipo_registro = 3
    and periodo       = a_periodo1

	select transaccion,
	       monto,
		   numrecla
	  into _transaccion,
	       v_pagado_neto,
		   v_doc_reclamo
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	if _transaccion is null then
	 
		return v_doc_reclamo,
			   _transaccion,
		 	   _no_tranrec,
		 	   v_pagado_neto,
			   0
			   with RESUME;

	end if

end foreach

END PROCEDURE;
