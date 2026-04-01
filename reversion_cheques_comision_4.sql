-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
drop procedure rv_agtsalra_2;

create procedure rv_agtsalra_2()
returning integer,
          char(100);

define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cod_ramo    char(3);
define _fecha_hasta date;
define _no_poliza   char(10);

define _error		integer;

begin work;
begin
on exception set _error
    rollback work;
	return _error, "Error Actualizando Deuda de Agentes";
end exception

--SET DEBUG FILE TO "rv_agtsalra_2.trc"; 
--trace on;


foreach
  SELECT chqcomis.cod_agente,   
         chqcomis.comision,   
         chqcomis.fecha_hasta,
         chqcomis.no_poliza 
    INTO _cod_agente,
         _monto,     
         _fecha_hasta,
         _no_poliza 
    FROM chqcomis 
   WHERE chqcomis.no_requis = 'RV' 
     and cod_agente = '00199'

    IF _no_poliza <> "00000" THEN
	   	SELECT cod_ramo
		  INTO _cod_ramo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
	ELSE
	    LET _cod_ramo = "002";
   	END IF
         
    update agtsalra
       set monto = monto + _monto
     where cod_agente = _cod_agente
       and cod_ramo = _cod_ramo;       

	update agtagent
	   set saldo      = saldo + _monto
	 where cod_agente = _cod_agente;

   delete from agtsalhi
    where cod_agente = _cod_agente
	  and cod_ramo =  _cod_ramo
	  and fecha_hasta = _fecha_hasta;

end foreach


end
commit work;


return 0, "Actualizacion Exitosa";

end procedure