-- Traer toda la informacion del cobrador para la Pantalla Unica de Cobros
-- Creado    : 08/02/2012 - Autor: Roman Gordon

drop procedure sp_cob302;
create procedure "informix".sp_cob302(a_usuario char(8))
returning	char(3),
			char(3),
			char(3),
			char(10),
			char(1),
			date;

define _cod_campana		char(10);
define _cod_supervisor	char(3);
define _cod_cobrador	char(3);
define _cod_sucursal	char(3);
define _tipo_cobrador	char(1);
define _fecha_ult_pro	date;

set isolation to dirty read;

--set debug file to "sp_cob302.trc";
--trace on;

let	_cod_supervisor	= '';
let _cod_cobrador	= '';
let	_cod_sucursal	= '';
let	_cod_campana	= '';	
let	_tipo_cobrador	= '0';
let _fecha_ult_pro	= '01/01/1900';

foreach
	select cod_supervisor, 											  
		   cod_cobrador,												  
		   cod_sucursal,												  
		   tipo_cobrador,											  
		   cod_campana,
		   fecha_ult_pro
	  into _cod_supervisor,
		   _cod_cobrador,		
		   _cod_sucursal,		
		   _tipo_cobrador,	
		   _cod_campana,
		   _fecha_ult_pro
	  from cobcobra
	 where usuario = a_usuario
	   and tipo_cobrador in (1,3,4,5,7,8,9)
	   and activo = 1
	 order by tipo_cobrador asc

	if _cod_campana <> '00000' then
		exit foreach;
	end if
	if _cod_sucursal = '010' then
		let _cod_sucursal = '001';
	end if
end foreach

if _cod_cobrador is null or _cod_cobrador = '' then
	foreach	
		select cod_supervisor, 					 
			   cod_cobrador,					
			   cod_sucursal,					
			   tipo_cobrador,				
			   cod_campana
		  into _cod_supervisor,
			   _cod_cobrador,		
			   _cod_sucursal,		
			   _tipo_cobrador,	
			   _cod_campana
		  from cobcobra
		 where usuario = a_usuario
		   and tipo_cobrador not in (1,3,4,5,7,8,9)
		  order by tipo_cobrador desc

		if _cod_sucursal = '010' then		
			let _cod_sucursal = '001';
		end if

		exit foreach;
	end foreach
end if

return _cod_supervisor, 
	   _cod_cobrador,
	   _cod_sucursal,
	   _cod_campana,
	   _tipo_cobrador,
	   _fecha_ult_pro;
end procedure;