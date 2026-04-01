-- Procedimiento para sacar del callcenter las polizas que estan canceladas y con saldo cero
-- de las gestoras
-- Creado    : 23/01/2004 - Autor: Roman Gordon C.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas083;
																					 
create procedure sp_cas083()														 
returning char(10),
		  integer;																 
																					 
define _cant_reg	integer;
define _fecha_hoy	date;			 
define _cod_campana	char(10);										 
define _nombre	    char(50);										 

--set debug file to "sp_cob101.trc";


set isolation to dirty read;

let _fecha_hoy = today;

foreach
	select cod_campana,
		   fecha_hasta
	  into _cod_campana,
		   _fecha_hasta
	  from cascampana
	 where fecha_hasta = _fecha_hoy

	select count(*)
	  into _cant_reg
	  from cascliente
	 where cod_campana = _cod_campana
	   and cod_gestion is null

	foreach
		select cod_supervisor
		  into _cod_supervisor
		  from cobcobra
		 where cod_campana = _cod_campana

		select usuario
		  into _user_sup
		  from cobcobra
		 where cod_cobrador = _cod_supervisor;

		select email
		  into _email_supervisor
		  from insuser
		 where usuario = _user_sup;

	end foreach
	
	let _email = ''

	return _cant_reg,_cod_campana;
			
end foreach	 	


end
end procedure