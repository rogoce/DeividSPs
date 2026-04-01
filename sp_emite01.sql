-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite01;

create procedure "informix".sp_emite01(a_poliza char(10), a_idpoliza integer, a_idendoso integer) 
returning	smallint,varchar(200);

define _error_desc		varchar(200);
define _error_d			varchar(200);
define _error_title		varchar(30);
define _no_documento	varchar(20);
define _cotizacion		varchar(20);
define _no_poliza_ant	char(10);
define _no_factura		char(10);
define _periodo			char(7);
define _cod_cobertura	char(5);
define _cod_agente		char(5);
define _no_unidad		char(5);
define v_codcompania	char(3);
define _suma_asegurada	dec(16,2);
define _prima_neta_emi	dec(16,2);
define _prima_neta		dec(16,2);
define _dif_prima		dec(16,2);
define _saldo			dec(16,2);
define _error_isam		smallint;
define _cant_iter		smallint;
define _no_pagos		smallint;
define li_return		smallint;
define _error			smallint;
define _cont			integer;
define _vigencia_final	date;
define _vigencia_inic	date;

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;

--if a_idpoliza = 1021074 then
--	set debug file to "sp_emite01.trc"; 
--	trace on;
--end if
--begin work;

	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	let v_codcompania = '001';
	let _error_desc = "";   
	   
	select no_documento,periodo,cotizacion,prima_neta
	  into _no_documento,_periodo,_cotizacion,_prima_neta_emi
	  from emipomae
	 where no_poliza = a_poliza;
	 

	foreach
		select no_unidad,
			   suma_asegurada
		  into _no_unidad,
			   _suma_asegurada
		  from emipouni
		 where no_poliza = a_poliza
{		 
		 call sp_proe01(a_poliza,_no_unidad,'001') returning _error;
}
{	 
		select sum(prima_neta)
		  into _prima_neta
		  from emipocob
		 where no_poliza = a_poliza
		   and no_unidad = _no_unidad;
		 
		let _dif_prima	= (_prima_neta - _prima_neta_emi);
		
			if _dif_prima < 1.00 then
				let _cant_iter	= abs(_dif_prima)	* 100;
				
				if _cant_iter > 0 then
					foreach
						select cod_cobertura
						  into _cod_cobertura
						  from emipocob
						 where no_poliza = a_poliza
						   and prima_neta > 0
						   and descuento > 0
						
						if _dif_prima < 0.00 then
							update emipocob
							   set prima_neta = prima_neta + 0.01,
								   descuento = descuento + 0.01
							 where no_poliza = a_poliza
							   and no_unidad = _no_unidad
							   and cod_cobertura = _cod_cobertura;
						elif _dif_prima > 0.00 then
							update emipocob
							   set prima_neta = prima_neta - 0.01,
								   descuento = prima_neta - 0.01
							 where no_poliza = a_poliza
							   and no_unidad = _no_unidad
							   and cod_cobertura = _cod_cobertura;
						end if
						
						let _cont = _cont + 1;
						if _cont >= _cant_iter then
							exit foreach;
						end if
					end foreach
				end if
			end if
}			
		call sp_pro323a(a_poliza,_no_unidad,_suma_asegurada,'001') returning li_return;
	
		if li_return <> 0 then
			return li_return,_error_desc;
		end if
		

		call sp_proe02(a_poliza, _no_unidad, v_codcompania) returning li_return;
		if li_return <> 0 then
			return li_return,_error_desc;
		end if
	end foreach
	
	let li_return = sp_proe03(a_poliza,v_codcompania);
		if li_return <> 0 then
			return li_return,_error_desc;
		end if	

{	--Cargar el Reaseguro Individual de la Unidad
	call sp_emite02(a_poliza)	returning _error,_error_desc;

	if _error <> 0 then
		return _error,_error_desc;
	end if
}
	--Actualizar los valores en las unidades


	{call sp_proe03(a_poliza,'001') returning li_return;

	if li_return <> 0 then
		return li_return,'Error al Emitir la Póliza ';
	end if
	}

	if _cotizacion[1,3] = 'INC' then
	
		if _prima_neta <= 150.00 then
			let _no_pagos = 1;
		end if
		
		if _prima_neta > 150.00 AND _prima_neta <= 300.00 then
			let _no_pagos = 4;
		end if
		
		if _prima_neta > 300.00 then
			let _no_pagos = 10;
		end if
	
		update emipomae
		   set no_pagos = _no_pagos
		 where no_poliza = a_poliza;

		insert into endesppol
				(no_poliza,
				no_endoso,
				cod_ramo,
				cod_endoso
				)
		values	(a_poliza,
				'00000',
				'001',
				'036'
				);
	end if
	/*if _periodo = '2024-02' then
		update emipomae
		   set periodo = '2024-03'
	    where no_poliza = a_poliza;
	end if*/
	-- Actualización de la Póliza
	call sp_pro374b(a_poliza) returning _error,_error_isam,_error_title,_error_desc;

	if a_idpoliza <> 584368 then
		if _error <> 0 then
			/*if _error = 328 then --Debe entrar al Reaseguro, Suma Asegurada Diferente, Por Favor Verifique...
				--Insert tabla deivid_integrapol
					insert into deivid_integrapol (
						no_poliza,
						no_endoso,
						idpoliza,
						idendoso,
						no_documento)
					values(	a_poliza,
							'00000',
							a_idpoliza,
							a_idendoso,
							_no_documento);
				return _error,_error_desc;
			else*/
				call sp_sis61b(a_poliza) returning _cont,_error_d;
				return _error,_error_desc;
			--end if
		end if
	end if

	-- Insert al Pool de Impresión en Deivid
	let _error = sp_pro326(a_poliza,'AUTOMATI');
	
	--Validacion de Información de Cobros de la vigencia anterior
	call sp_emite09b(_no_documento) returning _error,_error_desc;
			
	--Insert tabla deivid_integrapol
	insert into deivid_integrapol (
			no_poliza,
			no_endoso,
			idpoliza,
			idendoso,
			no_documento)
	values(a_poliza,
			'00000',
			a_idpoliza,
			a_idendoso,
			_no_documento);
	
	
--commit work;
	return 0,"Actualización Exitosa";
	end
end procedure