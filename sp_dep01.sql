-- Depuracion de Clientes - Encuestas Numero 1 - Salud

-- Creado    : 10/09/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_dep01;

create procedure sp_dep01()
returning integer,
		  char(50);

define _codigo		char(255);
define _direccion1	char(255);
define _direccion2	char(255);
define _apartado	char(255);
define _dia			smallint;
define _mes			smallint;
define _ano			smallint;
define _cedula		char(255);
define _telefono	char(255);
define _telefono2	char(255);
define _telefono3	char(255);
define _celular		char(255);
define _email		char(255);

define _error		integer;
define _error_desc	char(50);

define _cod_cliente	char(10);
define _fecha		date;

begin work;

begin 
on exception set _error
	rollback work;
	return _error, _error_desc;
end exception

foreach
 select codigo,
		direccion1,
		direccion2,
		apartado,	
		dia,			
		mes,			
		ano,			
		cedula,		
		telefono,	
		telefono2,	
		telefono3,	
		celular,		
		email		
   into _codigo, 
		_direccion1,
		_direccion2,
		_apartado,	
		_dia,			
		_mes,			
		_ano,			
		_cedula,		
		_telefono,	
		_telefono2,	
		_telefono3,	
		_celular,		
		_email		
   from clienc01
   
	let _cod_cliente = trim(_codigo);
	let _error_desc  = "Procesando cliente " || _cod_cliente;
	let _fecha       = mdy(_mes, _dia, _ano);

	delete from cliclibk
	 where cod_cliente = _cod_cliente;

	insert into cliclibk(
	cod_cliente,
	direccion_1,
	direccion_2,
	apartado,
	fecha_aniversario,
	telefono1,
	telefono2,
	telefono3,
	celular,
	e_mail
	)
	select 
	cod_cliente,
	direccion_1,
	direccion_2,
	apartado,
	fecha_aniversario,
	telefono1,
	telefono2,
	telefono3,
	celular,
	e_mail
	from cliclien
	where cod_cliente = _cod_cliente;	
	
	update cliclien
	   set apartado			 = _apartado,
		   fecha_aniversario = _fecha,
		   telefono1		 = _telefono,
		   telefono2		 = _telefono2,
		   telefono3		 = _telefono3,
		   celular			 = _celular,
		   e_mail			 = _email
	 where cod_cliente       = _cod_cliente;
 
end foreach 

end

--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure