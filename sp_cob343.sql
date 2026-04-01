-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob343;
create procedure sp_cob343(a_no_remesa char(10))
returning	integer,
			varchar(200);

define _error_desc		char(50);
define _no_documento	char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _monto_pendiente	dec(16,2);
define _valor_holgura	dec(16,2);
define _letra_residuo	dec(16,2);
define _monto_residuo	dec(16,2);
define _monto_pagado	dec(16,2);
define _monto_pen		dec(16,2);
define _monto_letra		dec(16,2);
define _monto_bruto		dec(16,2);
define _residuo			dec(16,2);
define _resto           dec(16,2);
define _cnt_no_pagada	smallint;
define _cnt_caspoliza	smallint;
define _flag_nulidad	smallint;
define _letra_pagada	smallint;
define _ult_letra		smallint;
define _no_letra		smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_remesa	date;
define _fecha_pago		date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob343.trc";
--trace on;

let _error = 0;

--drop table if exists tmp_anulidad;
select cod_campana
  from cascampana
 where tipo_campana = 3
   and estatus = 2
 into temp tmp_anulidad;

foreach
	select no_poliza,
		   doc_remesa,
		   monto,
		   fecha
	  into _no_poliza,
		   _no_documento,
		   _monto_bruto,
		   _fecha_remesa
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov in ('P','N','X')

	--Proceso de Actualización de fecha de cobertura
	call sp_ley002(_no_documento,2) returning _error,_error_desc;
	
	if _error < 0 then
		let _error_desc = _error_desc || 'Proceso de Ley de Seguros. Póliza: ' || trim(_no_documento);
		return _error,_error_desc;
	end if

	let _residuo = _monto_bruto;

	select max(no_letra),
		   count(*)
	  into _ult_letra,
		   _cnt_no_pagada
	  from emiletra
	 where no_poliza = _no_poliza
	   and pagada = 0;

	if _cnt_no_pagada is null then
		let _cnt_no_pagada = 0;
	end if

	if _cnt_no_pagada = 0 then
		select max(no_letra)
		  into _ult_letra
		  from emiletra
		 where no_poliza = _no_poliza;
		
		update emiletra
		   set pagada = 0
		 where no_poliza = _no_poliza
		   and no_letra = _ult_letra;

		let _cnt_no_pagada = 1;
	end if

	foreach
		select no_letra,
			   monto_letra,
			   monto_pen,
			   monto_pag
		  into _no_letra,
			   _monto_letra,
			   _monto_pendiente,
			   _monto_pagado
		  from emiletra
		 where no_poliza = _no_poliza
		   and pagada = 0
		 order by no_letra

		let _letra_pagada = 0;
		let _flag_nulidad = 0;
		let _fecha_pago = null;

		if _residuo >= _monto_pendiente then
			let _letra_pagada = 1;
			let _flag_nulidad = 1;
			let _monto_pen = 0.00;
			let _fecha_pago = _fecha_remesa;

			if _ult_letra = _no_letra then
				let _monto_pen = _monto_pendiente - _residuo;
				let _monto_pagado = _monto_pagado + _residuo;
			else
				let _monto_pagado = _monto_letra;
			end if
		else
			let _monto_pen = _monto_pendiente - _residuo;
			let _monto_pagado = _monto_pagado + _residuo;
		end if
	
		let _residuo = _residuo - _monto_pendiente;

		update emiletra
		   set pagada = _letra_pagada,
			   monto_pen = _monto_pen,
			   monto_pag = _monto_pagado,
			   fecha_pago = _fecha_pago
		 where no_poliza = _no_poliza
		   and no_letra = _no_letra;

		if _residuo <= 0 then
			exit foreach;
		end if
	end foreach

	--Proceso de Eliminación de la estructura de nulidad por pagos --20/12/2016
	if _monto_bruto > 0 then

		--Detiene cualquier gestión de anulación
		delete from cobanula
		 where no_documento = _no_documento;

		let _cod_cliente = '';

		foreach
			select cod_cliente
			  into _cod_cliente
			  from caspoliza
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		if _cod_cliente is null then
			let _cod_cliente = '';
		end if

		select count(*)
		  into _cnt_caspoliza
		  from caspoliza
		 where cod_campana in (select cod_campana from tmp_anulidad)
		   and cod_cliente = _cod_cliente
		   and no_documento <> _no_documento;

		if _cnt_caspoliza is null then
			let _cnt_caspoliza = 0;
		end if

		if _cnt_caspoliza > 0 then
			delete from caspoliza
			 where cod_cliente = _cod_cliente
			   and no_documento = _no_documento
			   and cod_campana in (select cod_campana from tmp_anulidad);
		else
			delete from caspoliza
			 where cod_cliente = _cod_cliente
			   and no_documento = _no_documento
			   and cod_campana in (select cod_campana from tmp_anulidad);

			delete from cascliente
			 where cod_cliente = _cod_cliente
			   and cod_campana in (select cod_campana from tmp_anulidad);
		end if
	end if
end foreach

drop table tmp_anulidad;
return 0,'Actualización Exitosa';
end
end procedure;