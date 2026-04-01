-- Procedimiento reversa comisiones


{
drop procedure sp_demetrio;

create procedure "informix".sp_demetrio(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10))
--}

--{
drop procedure revercomi;

create procedure "informix".revercomi(a_fecha_captura date, a_fecha_al date, a_fecha_desde date)
returning integer, char(100);
--}

define _no_requis      char(10);
define _cod_agente     char(5);
--define a_fecha_captura date;
--define a_fecha_al      date;
--define a_fecha_desde   date;
define _cod_ramo	   char(3);
define _monto		   dec(16,2);
define _saldo          dec(16,2);
define _fecha_desde	   date;
define _fecha_ult_comis	   date;
define _error          int;

--- Actualizacion de Polizas

				
--SET DEBUG FILE TO "revercomi.trc"; 
--trace on;

--let a_fecha_captura = '19/07/2006';
--let a_fecha_al      = '15/07/2006';
--let a_fecha_desde	= '01/07/2006';

SET isolation to dirty read;

BEGIN

on exception set _error
	return _error, "Error reversando comision";
end exception

FOREACH
	select no_requis,
	       cod_agente
	  into _no_requis, 
	       _cod_agente
	  from chqchmae
	 where origen_cheque in ('2','7')
	   and fecha_captura = a_fecha_captura

{   	LET _monto = 0.00;
   	LET _saldo = 0.00;

    SELECT saldo, fecha_ult_
	  INTO _monto, _fecha_ult_comis
	  FROM agtf2
	 WHERE cod_agente = _cod_agente;
	 
	IF _monto <> 0 THEN 

	 	FOREACH
			SELECT cod_ramo,
			       monto,
				   fecha_desde
			  INTO _cod_ramo,
			       _monto,
				   _fecha_desde
			  FROM agtsalhi
			 WHERE cod_agente = _cod_agente
			   AND monto <> 0
			   AND fecha_al = a_fecha_al

	        IF _monto IS NULL THEN
				LET _monto = 0.00;
			END IF
	 
	   	    UPDATE agtsalra
	   		   SET monto = _monto
	   		 WHERE cod_agente = _cod_agente
	  		   AND cod_ramo = _cod_ramo;
	    END FOREACH

	    IF _monto IS NULL THEN
			LET _monto = 0.00;
		END IF

		SELECT SUM(monto)
		  INTO _saldo
		  FROM agtsalra
		 WHERE cod_agente = _cod_agente;

	    IF _saldo IS NULL THEN
			LET _saldo = 0.00;
		END IF

	end if

 {   FOREACH					   --> para buscar la ultima fecha de comision
		 SELECT fecha_ult_comis
		   INTO _fecha_ult_comis
		   FROM agtbitacora
		  WHERE cod_agente = _cod_agente
		    AND fecha_ult_comis <> a_fecha_al
		 ORDER BY 1 DESC 

		 EXIT FOREACH;

	END FOREACH
  }
  
{    UPDATE agtagent
	   SET saldo = _saldo,
	   	   fecha_ult_comis = _fecha_ult_comis	 
	 WHERE cod_agente = _cod_agente;

    DELETE FROM agtsalhi WHERE cod_agente = _cod_agente AND fecha_al = a_fecha_al;
	DELETE FROM chqcomis WHERE cod_agente = _cod_agente AND fecha_genera = a_fecha_captura;
}  
	UPDATE chqcomis
	   SET no_requis = "RV"
	 WHERE no_requis = _no_requis
	   AND cod_agente = _cod_agente
	   AND fecha_genera <> a_fecha_captura;
END FOREACH
end
return 0, "Actualizacion Exitosa";

--DELETE FROM chqcomis WHERE fecha_desde = a_fecha_desde;

--DELETE FROM chqchmae 
-- where origen_cheque in ('2','7')
--   and fecha_captura = a_fecha_captura;
 
end procedure;