-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
--drop procedure rv_agtagent_3;

create procedure rv_agtagent_3()
returning integer,
          char(100);

define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cod_ramo    char(3);
define _no_poliza   char(10);
define _fecha_hasta date;
define _no_requis   char(10);
define _desc_cheque varchar(100);
define _fecha_desde date;
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

foreach	with hold
  SELECT distinct cod_agente
    INTO _cod_agente   
    FROM agtbitacora  
   WHERE fecha_ult_comis = '31/12/2008'

   FOREACH
	   SELECT fecha_ult_comis
	     INTO _fecha_desde
		 FROM agtbitacora
		WHERE cod_agente = _cod_agente
		  AND fecha_ult_comis < '31/12/2008'
	 order by fecha_ult_comis desc
	 exit foreach;
   END FOREACH
    
	update agtagent
	   set fecha_ult_comis = _fecha_desde
	 where cod_agente = _cod_agente;

END FOREACH
end
commit work;
return 0, "Actualizacion Exitosa";

end procedure