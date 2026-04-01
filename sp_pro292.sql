-- Informe para la red de Doctores 
-- Creado    : 17 Agosto de 2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro292;

create procedure sp_pro292()
returning CHAR(50),  -- 1. Nombre del Doctor.  
		  CHAR(50),  -- 2. Especialidad del Doctor. 
		  CHAR(50),  -- 3. Centro Hospitalario donde labora el Doctor.
	      CHAR(10);	 -- 4. Telefono del Doctor.

define _nombre          char(50);
define _especialidad    char(50);
define _telefono        char(10);
define _cod_espmedica   char(3);

define _hospital        char(50);
define _cod_hosp        char(10);
define _cnt				integer;
define _cod_cliente     char(10);

SET ISOLATION TO DIRTY READ;

foreach 
	 select nombre,
		    consultorio_1,
			telefono1,
			cod_cliente
	   into _nombre,
	 	    _cod_hosp,
			_telefono,
			_cod_cliente
	   from cliclien
	  where cod_actividad = "003"

	  select count(*)
	    into _cnt
		from cliespe
	   where cod_cliente = _cod_cliente;

	  if _cnt = 0 then
			insert into cliespe(cod_cliente, cod_especialidad)
			values (_cod_cliente, "002");
	  end if

      foreach 
	       select cod_especialidad
	         into _cod_espmedica
	         from cliespe
	        where cod_cliente = _cod_cliente
	         	
	       select nombre 
		     into _especialidad
		     from cliespme
		    where cod_espmedica = _cod_espmedica; 
		    
		   select nombre
		     into _hospital
		     from cliclien
		    where cod_cliente = _cod_hosp;   

	   	   return _nombre,  		  -- 1. Nombre del Doctor. 
				  _especialidad,	  -- 2. Especialidad m‚dica del Doctor.
				  _hospital, 	      -- 3. Centro Hospitalario donde labora el Doctor.
				  _telefono    	      -- 4. Tel‚fono del Doctor. 
		  	 with resume;
 	  end foreach

end foreach
end procedure
