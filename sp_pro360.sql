-- Procedimiento que busca todos los pdf de las evaluaciones de salud que fueron insertados en la estructura de correos masivos
-- creado    : 02/04/2012 - Autor: Roman Gordon

drop procedure sp_pro360;

create procedure "informix".sp_pro360(a_no_evaluacion char(10))
returning	integer,char(50),char(250);

define _mail_secuencia	integer;
define _email			char(250);
define _nom_tipo		char(50);
define _cod_tipo		char(5);

									 

set isolation to dirty read;

--set debug file to "sp_pro360.trc"; 
--trace on;

foreach
	select mail_secuencia
	  into _mail_secuencia
	  from parmailcomp
	 where no_remesa = a_no_evaluacion
	   and renglon = 0	
	
	select cod_tipo,
		   email
	  into _cod_tipo,
		   _email
	  from parmailsend
	 where secuencia = _mail_secuencia;
	 
	if _cod_tipo not in ('00002','00003','00005','00006','00007','00008','00009') then
		continue foreach;
	end if

	select nombre
	  into _nom_tipo
	  from parmailtipo
	 where cod_tipo = _cod_tipo;
	
	return _mail_secuencia,
		   _nom_tipo,
		   _email 			with resume;	
end foreach
end procedure 
