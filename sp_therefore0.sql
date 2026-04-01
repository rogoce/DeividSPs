-- Procedimiento que determina todas las unidades de una factura y sus dependientes (Ramos Generales)
-- Creado    : 21/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_therefore0;
create procedure sp_therefore0(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5), a_cod_cliente char(10), a_tipo_llave char(4))
returning	integer		as cod_error,
			varchar(50)	as llave_int;

define _error_desc			varchar(50);
define _llave_int			varchar(50);
define _cedula				varchar(30);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _cod_cliente			char(10);
define _no_factura			char(10);
define _no_unidad			char(5);
define _cod_tiporamo		char(3);
define _cod_ramo			char(3);
define _error_isam			integer;
define _error				integer;
define _fecha_emision		date;

set isolation to dirty read;

--set debug file to "sp_therefore0.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;         
end exception

select no_factura,
	   vigencia_inic,
	   no_documento
  into _no_factura,
	   _fecha_emision,
	   _no_documento
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select cod_tiporamo
  into _cod_tiporamo
  from prdramo
 where cod_ramo = _cod_ramo;

if a_tipo_llave = 'FACT' then

	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = a_no_poliza;

	if _cod_cliente is null then
		return 1,'El Código de cliente no es el contratante de la póliza. ' || a_cod_cliente;
	end if

	select cedula
	  into _cedula
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if a_no_endoso = '00000' then
		let _llave_int = trim(_no_documento);
	else
		let _llave_int = trim(_no_factura);
	end if
elif a_tipo_llave = 'UNID' then

	if _cod_ramo = '018' then --Ramos Personales	
		select cod_cliente
		  into _cod_cliente
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = a_no_unidad;

		if _cod_cliente <> a_cod_cliente then
			select cod_cliente
			  into _cod_cliente
			  from emidepen
			 where no_poliza = a_no_poliza
			   and no_unidad = a_no_unidad
			   and cod_cliente = a_cod_cliente
			   and _fecha_emision between fecha_efectiva and no_activo_desde;

			if _cod_cliente is null then
				return 1,'El Código de cliente no es asegurado/dependiente de la póliza. ' || a_cod_cliente;
			end if
		end if

		select cedula
		  into _cedula
		  from cliclien
		 where cod_cliente = _cod_cliente;
	else
		let _cedula = '';
	end if

	let _llave_int = trim(_no_factura) || trim(a_no_unidad) || trim(_cedula);	
else
	return 2,'El tipo de Llave no ha sido detectado';
end if

return 0,_llave_int;

end
end procedure;