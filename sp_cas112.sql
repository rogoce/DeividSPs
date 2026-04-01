-- Procedimiento que trae la informacion de la campana y sus gestores
																 
-- Creado    : 16/05/2012 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas112;

create procedure sp_cas112(
a_cod_campana	char(10))

returning	char(50),		--
			char(50),		--
			char(3),		--
			date,			--
			date,			-- 
			integer;		-- 



define _nom_campana		char(50);
define _nom_cobrador	char(50);
define _cod_cobrador	char(3);
define _cant_registros	integer;
define _fecha_desde		date;
define _fecha_hasta		date;


--set debug file to "sp_cas112.trc";
--trace on;

set isolation to dirty read;

select nombre,
	   fecha_desde,
	   fecha_hasta	
  into _nom_campana,
	   _fecha_desde,
	   _fecha_hasta
  from cascampana
 where cod_campana = a_cod_campana;

select count(*)
  into _cant_registros
  from cascliente
 where cod_campana = a_cod_campana;

foreach
	select cod_cobrador,
		   nombre
	  into _cod_cobrador,
	  	   _nom_cobrador
	  from cobcobra
	 where cod_campana = a_cod_campana
	 
	return _nom_campana,	   
		   _nom_cobrador,
		   _cod_cobrador,
		   _fecha_desde,		
		   _fecha_hasta,
		   _cant_registros with resume;
end foreach
end procedure
