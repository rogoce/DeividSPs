-- prima cobrada devengada  Desde sp_cob29
-- Creado: 31/01/2020 - Autor: Armando Moreno M.

drop procedure sp_dev08a;
create procedure sp_dev08a(a_no_remesa char(10))
returning	smallint		as cod_error;

define _no_documento        char(20);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_neta			dec(16,2);
define _error				integer;
define _fecha_inicio		date;

set isolation to dirty read;

begin
on exception set _error	--,_error_isam,_mensaje
return _error;
end exception

--SET DEBUG FILE TO "sp_dev08a.trc"; 
--TRACE ON; 
foreach

	select monto,
	       prima_neta,
		   doc_remesa
	  into _monto_cobrado,
	       _prima_neta,
		   _no_documento
	  from cobredet
	 where no_remesa = a_no_remesa
	   and actualizado = 1
	   and tipo_mov in ('P','N','X')

	if _monto_cobrado is null then
		let _monto_cobrado = 0.00;
	end if
	if _prima_neta is null then
		let _prima_neta = 0.00;
	end if

	let _fecha_inicio = null;

	select min(fecha)
	  into _fecha_inicio
	  from devengada
	 where no_documento = _no_documento;

	--***Ciclo para la prima bruta cobrada devengada***
	while _monto_cobrado <> 0.00 
		select prima_db
		  into _prima_diaria
		  from devengada
		 where no_documento = _no_documento
		   and fecha        = _fecha_inicio;

		if _prima_diaria is null then
			select min(fecha)
			  into _fecha_inicio
			  from devengada
			 where no_documento = _no_documento
			   and fecha        > _fecha_inicio;

			if _fecha_inicio is null then
				exit while;
			else
				select prima_db
				  into _prima_diaria
				  from devengada
				 where no_documento = _no_documento
				   and fecha        = _fecha_inicio;
			end if
		end if
		if _monto_cobrado >= _prima_diaria then
			let _monto_cobrado = _monto_cobrado - _prima_diaria;

			update devengada
			   set prima_dcb     = _prima_diaria
			 where no_documento  = _no_documento
			   and fecha         = _fecha_inicio;
		else
			update devengada
			   set prima_dcb     = _monto_cobrado
			 where no_documento  = _no_documento
			   and fecha         = _fecha_inicio;

			let _monto_cobrado = 0;
		end if

		let _fecha_inicio = _fecha_inicio + 1 units day;
	end while
	--***Ciclo para prima cobrada neta devengada***
	let _fecha_inicio = null;

	select min(fecha)
	  into _fecha_inicio
	  from devengada
	 where no_documento = _no_documento;
	 
	while _prima_neta <> 0.00 
		select prima_dn
		  into _prima_diaria
		  from devengada
		 where no_documento = _no_documento
		   and fecha        = _fecha_inicio;

		if _prima_diaria is null then
			select min(fecha)
			  into _fecha_inicio
			  from devengada
			 where no_documento = _no_documento
			   and fecha        > _fecha_inicio;

			if _fecha_inicio is null then
				exit while;
			else
				select prima_dn
				  into _prima_diaria
				  from devengada
				 where no_documento = _no_documento
				   and fecha        = _fecha_inicio;
			end if
		end if
		if _prima_neta >= _prima_diaria then
			let _prima_neta = _prima_neta - _prima_diaria;

			update devengada
			   set prima_dcn     = _prima_diaria
			 where no_documento  = _no_documento
			   and fecha         = _fecha_inicio;
		else
			update devengada
			   set prima_dcn     = _prima_neta
			 where no_documento  = _no_documento
			   and fecha         = _fecha_inicio;

			let _prima_neta = 0;
		end if

		let _fecha_inicio = _fecha_inicio + 1 units day;
	end while
end foreach	

return 0;
end
end procedure;