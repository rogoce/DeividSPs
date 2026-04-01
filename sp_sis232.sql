-- Procedimiento actualiza la información de cheques devueltos desde la pantalla única.
-- Creado: 02/02/2017 - Autor: Román Gordón

drop procedure sp_sis232;
create procedure sp_sis232(a_documento char(20), a_area char(3))
returning	smallint		as cod_error,
			varchar(100)	as error_desc;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _cnt_contratante		smallint;
define _cant_dev			smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

set isolation to dirty read;

--set debug file to "sp_sis232.trc";
--trace on;

return 0,'Inhabilitado Temporalmente';

begin
on exception set _error,_error_isam,_mensaje
 	return _error, _mensaje;
end exception

if a_area = 'COB' then
	foreach
		select no_poliza,
			   doc_remesa
		  into _no_poliza,
			   _no_documento
		  from cobredet
		 where no_remesa = a_documento
		   and tipo_mov = 'P'

		select cod_contratante,
			   cod_pagador
		  into _cod_contratante,
			   _cod_pagador
		  from emipomae
		 where no_poliza = _no_poliza;

		select count(*)
		  into _cnt_contratante
		  from clichdev
		 where cod_cliente = _cod_contratante;

		if _cnt_contratante is null then
			let _cnt_contratante = 0;
		end if

		if _cnt_contratante = 0 then
			return 0,'Verificación Exitosa';
		end if

		foreach
			select cantidad
			  into _cant_dev
			  from clichdev
			 where (cod_cliente = _cod_contratante
				or cod_cliente = _cod_pagador)

			if _cant_dev >= 2 then
				return 1,'Cliente mantiene cheque devuelto';--'La Póliza: ' || trim(_no_documento) || 'No puede ser pagada con cheques Personales.';
			else
				return 0,'Verificación Exitosa';
			end if
		end foreach
	end foreach
elif a_area = 'REC' then
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where numrecla = a_documento;

	select no_documento,
		   cod_contratante,
		   cod_pagador
	  into _no_documento,
		   _cod_contratante,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cnt_contratante
	  from clichdev
	 where cod_cliente = _cod_contratante;

	if _cnt_contratante is null then
		let _cnt_contratante = 0;
	end if

	if _cnt_contratante = 0 then
		return 0,'Verificación Exitosa';
	end if
	
	foreach
		select cantidad,
			   date_added
		  into _cant_dev,
			   _date_added
		  from clichdev
		 where (cod_cliente = _cod_contratante
			or cod_cliente = _cod_pagador)

		if _cant_dev = 1 then
			return 1,'La Póliza: ' || trim(_no_documento) || ', intento ser pagada con un cheque devuelto el día ' || _date_added || '. Verifique la morosidad.';
		else
			return 0,'Verificación Exitosa';
		end if
	end foreach
end if

return 0,'Verificación Exitosa';
end
end procedure;