-- Procedimiento que carga la nota de apertura de reclamo para automovil y soda
-- Creado    : 03/07/2013 - Autor: Federico Coronado

-- drop procedure sp_rec211;

create procedure "informix".sp_rec211(a_no_tramite varchar(25)
)returning varchar(100), 
          char(13),
		  date,
		  char(5),
		  char(10),
		  char(10);

define v_no_poliza		   char(10);
define v_no_documento      char(13);
define v_fecha_siniestro   date;
define v_no_unidad         char(5);
define v_asegurado         varchar(100);
define v_cod_asegurado     char(10);
define _no_motor           char(30);
define v_placa             char(10);

/*define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);*/


begin
/*on exception set _error, _error_isam, _error_desc
	return _error, _error_desc,'','','','';
end exception*/

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rec211.trc"; 
--trace on;

	select no_poliza, 
		   no_documento, 
	       fecha_siniestro, 
	       no_unidad
	  into v_no_poliza,
		   v_no_documento,
		   v_fecha_siniestro,
		   v_no_unidad
      from recrcmae 
	 where no_tramite = a_no_tramite;
	 
	 select cod_contratante
	   into v_cod_asegurado 
	   from emipomae 
	  where no_poliza = v_no_poliza;
	  
	 let _no_motor = null;
	 let v_placa = null;
	 
	 select no_motor
	   into _no_motor
	   from emiauto
	  where no_poliza = v_no_poliza
	    and no_unidad = v_no_unidad;
		
     if _no_motor is null then	 
		foreach
		 select no_motor
		   into _no_motor
		   from endmoaut
		  where no_poliza = v_no_poliza
			and no_unidad = v_no_unidad
			exit foreach;
		end foreach
	end if
	
	select placa
	  into v_placa
	  from emivehic
	 where no_motor = _no_motor;
	    
	 select nombre
	   into v_asegurado
	   from cliclien
	  where cod_cliente = v_cod_asegurado;
	  
	  RETURN v_asegurado,
			 v_no_documento,
			 v_fecha_siniestro,
			 v_no_unidad,
			 a_no_tramite,
			 v_placa
			 WITH RESUME;

end
end procedure
