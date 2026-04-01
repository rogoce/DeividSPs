-- Procedimiento que determina todas las unidades de una factura y sus dependientes (Ramos Generales)
-- Creado    : 21/12/2016 - Autor: Román Gordón 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_therefore2;
create procedure sp_therefore2(a_no_poliza char(10), a_no_endoso char(5))
returning	integer		as cod_error,
			char(10)	as factura,
			char(5)		as unidad,
			char(10)	as cod_cliente,
			varchar(50)	as llave_int,
			smallint	as consecutivo;

define _error_desc			varchar(50);
define _llave_int			varchar(50);
define _cod_dependiente		char(10);
define _cod_asegurado		char(10);
define _no_factura			char(10);
define _no_unidad			char(5);
define _cod_tiporamo		char(3);
define _cod_ramo			char(3);
define _consecutivo			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_emision		date;

set isolation to dirty read;

--set debug file to "sp_therefore2.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	return _error,'','','',_error_desc,_error_isam;         
end exception

select no_factura,
	   vigencia_inic
  into _no_factura,
	   _fecha_emision
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

{select cod_tiporamo
  into _cod_tiporamo
  from prdramo
 where cod_ramo = _cod_ramo;}

foreach
	select no_unidad,
		   cod_cliente
	  into _no_unidad,
		   _cod_asegurado
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	 order by no_unidad

	let _consecutivo = 1;
	call sp_therefore0(a_no_poliza,a_no_endoso,_no_unidad,_cod_asegurado,'UNID') returning _error,_llave_int;

	if _error <> 0 then
		return _error,'','','',_llave_int,0;
	end if

	return 0,_no_factura,_no_unidad,_cod_asegurado,_llave_int,_consecutivo with resume;

	if _cod_ramo = '018' then --Salud
		foreach
			select cod_cliente
			  into _cod_dependiente
			  from emidepen
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and _fecha_emision between fecha_efectiva and no_activo_desde

			let _consecutivo = _consecutivo + 1;
			call sp_therefore0(a_no_poliza,a_no_endoso,_no_unidad, _cod_dependiente,'UNID') returning _error,_llave_int;

			if _error <> 0 then
				return _error,'','','',_llave_int,0;
			end if

			return 0,_no_factura,_no_unidad,_cod_dependiente,_llave_int,_consecutivo with resume;
		end foreach
	end if
end foreach

end
end procedure;