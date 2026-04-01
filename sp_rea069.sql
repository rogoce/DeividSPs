
-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea069;

create procedure sp_rea069()
returning integer,
          char(50);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _no_remesa     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tranrec    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _renglon			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
define _no_reclamo          char(10);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach

	select distinct c.no_remesa,
		   c.renglon
	  into _no_remesa,
		   _renglon
	 from verif_100 s, cobreaco c
	 where s.no_remesa = c.no_remesa
       and s.renglon = c.renglon 
	   and cod_contrato = '00649'


	update cobreaco
	   set porc_proporcion = 50
	 where no_remesa = _no_remesa
       and renglon = _renglon;
end foreach
end

return 0, "Actualizacion Exitosa";

end procedure