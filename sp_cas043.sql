-- Asignacion diaria de las Polizas al Call Center
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas043;

create procedure sp_cas043()
returning integer,
          char(100);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cobra_poliza	char(1);
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _cantidad		smallint;
define _fecha_emision	date;

define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _nombre_formapag	char(50);
define _dias			smallint;
define _return			smallint;
define _error			integer;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

foreach
 select no_documento
   into	_no_documento
   from emipomae 
  where actualizado    = 1
	and cobra_poliza   = "A"
	and estatus_poliza = 1
	and cod_tipoprod   not in ("002", "004")
  group by no_documento		

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
		   cobra_poliza,
		   estatus_poliza,
		   fecha_suscripcion,
		   cod_formapag
	  into _cod_tipoprod,
		   _cobra_poliza,
		   _estatus_poliza,
		   _fecha_emision,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	if _cobra_poliza <> "A" then
		continue foreach;
	end if

	SELECT tipo_forma,
	       nombre
	  INTO _tipo_forma,
	       _nombre_formapag
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma = 6 then -- Corredor
		
		update emipomae
		   set cobra_poliza = "C"
		 where no_poliza    = _no_poliza;

		continue foreach;

	elif _tipo_forma = 7 then -- Acreedor Hipotecario

		update emipomae
		   set cobra_poliza = "1"
		 where no_poliza    = _no_poliza;

		continue foreach;

	elif _tipo_forma = 8 then -- Descuento Comision

		update emipomae
		   set cobra_poliza = "2"
		 where no_poliza    = _no_poliza;

		continue foreach;

	elif _tipo_forma = 9 then -- Canje

		update emipomae
		   set cobra_poliza = "3"
		 where no_poliza    = _no_poliza;

		continue foreach;

	elif _tipo_forma = 3 or   -- Descuento Directo
		 _tipo_forma = 5 then -- Call Center

{
		let _dias = today - _fecha_emision;

		if _dias <= 20 then
			continue foreach;
		end if
}

		select count(*)
		  into _cantidad
		  from caspoliza
		 where no_documento = _no_documento;

		if _cantidad = 0 then

			update emipomae
			   set cobra_poliza = "E"
			 where no_poliza    = _no_poliza;

			let _return = sp_cas022(_no_poliza);
		
		end if

	end if

end foreach

end 

return 0, "Actualizacion Exitosa ...";

end procedure