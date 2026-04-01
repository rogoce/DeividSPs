-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
drop procedure rv_agtagent2;

create procedure rv_agtagent2(_cod_agente CHAR(10), _fecha_desde date)
returning integer,
          char(100);

--define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cod_ramo    char(3);
define _no_poliza   char(10);
define _fecha_hasta date;
define _no_requis   char(10);
define _desc_cheque varchar(100);
--define _fecha_desde date;
define _dia         char(2);
define _mes         char(2);
define _ano2         char(4);
define _origen_cheque char(1);

define _error		integer;

begin work;
begin
on exception set _error
    rollback work;
	return _error, "Error Actualizando Deuda de Agentes";
end exception

--SET DEBUG FILE TO "rv_agtagent.trc"; 
--trace on;

          
  	FOREACH 
	  SELECT comision,   
	         no_poliza,
	         fecha_hasta
	    INTO _monto,     
	         _no_poliza,
	         _fecha_hasta
	    FROM chqcomis  
	   WHERE no_requis = "RV"
		 AND cod_agente = _cod_agente

	    IF _no_poliza <> "00000" THEN
		   	SELECT cod_ramo
			  INTO _cod_ramo
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;
		ELSE
		    LET _cod_ramo = "002";
	   	END IF

        select count(*) 
          into _renglon
          from agtsalra
	     where cod_agente = _cod_agente
	       and cod_ramo = _cod_ramo; 
	       
	    if _renglon > 0 Then         
		    update agtsalra
		       set monto = monto + _monto
		     where cod_agente = _cod_agente
		       and cod_ramo = _cod_ramo; 
		else
		    insert into agtsalra(
			   cod_agente,
			   cod_ramo,
			   monto)
			values(
			   _cod_agente,
			   _cod_ramo,
			   _monto
			   );

		end if      

		update agtagent
		   set saldo           = saldo + _monto,
		       fecha_ult_comis = _fecha_desde
		 where cod_agente = _cod_agente;

	   delete from agtsalhi
	    where cod_agente = _cod_agente
		  and cod_ramo =  _cod_ramo
		  and fecha_hasta = _fecha_hasta;

	END FOREACH



end
commit work;
return 0, "Actualizacion Exitosa";

end procedure