-- Procedimiento que Actualiza el Codigo del Acreedor

-- Creado    : 16/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/06/2012 - Autor: Roman Gordon				--Insercion de una bitacora de cambios de Acreedores
-- execute procedure sp_cas018('01279','00136','RGORDON')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas018;

create procedure sp_cas018(
a_acreedor_bien char(5),
a_acreedor_mal  char(5),
a_user			char(8)
) returning integer,
			char(100);

define _error		integer;
define _cantidad	integer;
define _erro_isam	integer;
define _error_desc	char(100);
define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_unidad	char(5);
define _limite		dec(16,2);
define _fecha		date;

-- set debug file to "sp_cas018.trc";
-- trace on;

let _fecha = current;

if a_acreedor_bien = a_acreedor_mal then
	return 1, "Los Codigos de los Acreedores No Pueden Ser Igual";         
end if
	
--begin work;

begin 

on exception set _error,_erro_isam,_error_desc 
   --	rollback work;
 	return _error, _error_desc;--"Error al Cambiar el Acreedor";         
end exception           

-- Emipoacr

foreach
	select no_poliza,
		   no_unidad,
		   limite
	  into _no_poliza,
		   _no_unidad,
	 	   _limite
	  from emipoacr
	 where cod_acreedor = a_acreedor_mal 
	begin
		on exception in(-268)		
					
			insert into emiacrebi(
			cod_acreedor_bien,
			cod_acreedor_mal,
			user_added,
			date_added,
			no_poliza,
			no_unidad,
			limite)
			values(
			a_acreedor_bien,
			a_acreedor_mal,
			a_user,
			_fecha,
			_no_poliza,
			_no_unidad,
			_limite);

			delete from emipoacr
				  where no_poliza		= _no_poliza  
					and	no_unidad		= _no_unidad
					and cod_acreedor	= a_acreedor_mal;

		end exception	

		update emipoacr
		   set cod_acreedor = a_acreedor_bien
		 where no_poliza	= _no_poliza  
		   and no_unidad	= _no_unidad
		   and cod_acreedor	= a_acreedor_mal;
	end
end foreach

-- Endedacr
foreach
	select no_poliza,
		   no_endoso,
		   no_unidad,
		   limite
	  into _no_poliza,
		   _no_endoso,
		   _no_unidad,
	 	   _limite
	  from endedacr
	 where cod_acreedor = a_acreedor_mal 
	begin
		on exception in(-268)		
					
			insert into emiacrebi(
			cod_acreedor_bien,
			cod_acreedor_mal,
			user_added,
			date_added,
			no_poliza,
			no_endoso,
			no_unidad,
			limite)
			values(
			a_acreedor_bien,
			a_acreedor_mal,
			a_user,
			_fecha,
			_no_poliza,
			_no_endoso,
			_no_unidad,
			_limite);

			delete from endedacr
				  where no_poliza		= _no_poliza  
					and	no_endoso		= _no_endoso
					and	no_unidad		= _no_unidad
					and cod_acreedor	= a_acreedor_mal;

		end exception	

		update endedacr
		   set cod_acreedor = a_acreedor_bien
		 where no_poliza	= _no_poliza  
		   and no_endoso	= _no_endoso
		   and no_unidad	= _no_unidad
		   and cod_acreedor	= a_acreedor_mal;
	end
end foreach

-- emireacr

foreach
	select no_poliza,
		   no_unidad,
		   limite
	  into _no_poliza,
		   _no_unidad,
	 	   _limite
	  from emireacr
	 where cod_acreedor = a_acreedor_mal 
	begin
		on exception in(-268)		
					
			insert into emiacrebi(
			cod_acreedor_bien,
			cod_acreedor_mal,
			user_added,
			date_added,
			no_poliza,
			no_unidad,
			limite)
			values(
			a_acreedor_bien,
			a_acreedor_mal,
			a_user,
			_fecha,
			_no_poliza,
			_no_unidad,
			_limite);

			delete from emireacr
				  where no_poliza		= _no_poliza  
					and	no_unidad		= _no_unidad
					and cod_acreedor	= a_acreedor_mal;

		end exception	

		update emireacr
		   set cod_acreedor = a_acreedor_bien
		 where no_poliza	= _no_poliza  
		   and no_unidad	= _no_unidad
		   and cod_acreedor	= a_acreedor_mal;
	end
end foreach


{update emireacr
   set cod_acreedor = a_acreedor_bien
 where cod_acreedor = a_acreedor_mal;}
 
 update comisrep
   set cod_acreedor = a_acreedor_bien
 where cod_acreedor = a_acreedor_mal; 
 
 update endpool0
   set cod_acreedor = a_acreedor_bien
 where cod_acreedor = a_acreedor_mal;

-- avisocanc

update avisocanc
   set cod_acreedor = a_acreedor_bien
 where cod_acreedor = a_acreedor_mal;

update cobaviso
   set cod_acreedor = a_acreedor_bien
 where cod_acreedor = a_acreedor_mal;

-- equiacre
update equiacre
   set cod_acreedor_ancon = a_acreedor_bien
 where cod_acreedor_ancon = a_acreedor_mal;	

-- Emiacre

delete from emiacre
 where cod_acreedor = a_acreedor_mal;


insert into emiacrebi(
cod_acreedor_bien,
cod_acreedor_mal,
user_added,
date_added)
values(
a_acreedor_bien,
a_acreedor_mal,
a_user,
_fecha);

return 0,
       "Unificación de Acreedor Exitosa" ;


end

--commit work;

end procedure
