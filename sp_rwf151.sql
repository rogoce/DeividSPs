-- Procedimiento que calcula la perdida total

-- Creado    : 13/07/2018 - Autor: Amado Perez  

drop procedure sp_rwf151;

create procedure sp_rwf151(a_no_reclamo char(10)) 
returning char(5) as cod_cobertura, varchar(100) as cobertura, dec(16,2) as reserva_inicial, dec(16,2) as reserva_actual, char(3) as cod_evento, varchar(50) as evento;

define _cod_evento      char(3);
define _evento          varchar(50);
define _cod_cobertura   char(5);
define _reserva_inicial dec(16,2);
define _reserva_actual  dec(16,2);
define _cobertura       varchar(100);


--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rwf146.trc"; 
--trace on;
set isolation to dirty read;

select cod_evento
  into _cod_evento
  from recrcmae
 where no_reclamo = a_no_reclamo;

select nombre
  into _evento
  from recevent
 where cod_evento = _cod_evento;
 
foreach
	select cod_cobertura,
	       reserva_inicial,
		   reserva_actual
	  into _cod_cobertura,
	       _reserva_inicial,
		   _reserva_actual
	  from recrccob
	 where no_reclamo = a_no_reclamo
	  
	select nombre
	  into _cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;
	 
    return _cod_cobertura,
	       _cobertura,
		   _reserva_inicial,
		   _reserva_actual,
		   _cod_evento,
		   _evento 
		   with resume;
end foreach
  
end procedure