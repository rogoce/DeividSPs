-- No cheque y  remesa para el Informe de Estatus del Reclamo
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Modificado: 13/14/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_re40d;

CREATE PROCEDURE "informix".sp_re40d(
a_compania     CHAR(3),
a_sucursal     CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(10),
		  CHAR(10);
		  	  		         
DEFINE _transaccion  		CHAR(10);
DEFINE _no_cheque			integer;
DEFINE _no_reclamo          CHAR(10);
DEFINE _no_requis           CHAR(10);



select no_reclamo
  into _no_reclamo
  from recrcmae
 where numrecla    = a_numrecla
   and actualizado = 1;

FOREACH
  SELECT t.no_requis,
         t.transaccion
  	INTO _no_requis,
	     _transaccion
	FROM rectrmae t, rectitra h
   WHERE t.cod_tipotran     = h.cod_tipotran
     AND t.no_reclamo       = _no_reclamo
	 AND h.tipo_transaccion in(4,6)
	 AND t.actualizado      = 1

	if _no_requis is not null then
	  SELECT no_cheque
		INTO _no_cheque
		FROM chqchmae
	   WHERE no_requis = _no_requis;
	else
		continue foreach;
	end if   
   
   RETURN _transaccion,_no_cheque WITH RESUME;
END FOREACH;
END PROCEDURE;