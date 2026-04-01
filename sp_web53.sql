-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web53;

create procedure "informix".sp_web53(a_poliza char(10)) 
returning	smallint,varchar(200);

define _prima_neta_emi 	dec(16,2);
define _prima_neta 		dec(16,2);
define _dif_prima 		dec(16,2);
define _cant_iter 		smallint;
define _cont 			smallint;
define _error           smallint;
define _cod_cobertura   char(5);
define _no_unidad       char(5);
define _error_desc		varchar(200);
define _error_isam		smallint;
define _error_title		varchar(30);
define li_return		smallint;
define v_codcompania    char(3);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_web53.trc"; 
	--trace on;

--begin work;

	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	let v_codcompania = '001';
	let _error_desc = "";   
	   
	select sum(prima_neta)
	  into _prima_neta_emi
	  from emipomae
	 where no_poliza = a_poliza;
	 
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = a_poliza
		 
		 call sp_proe01(a_poliza,_no_unidad,'001') returning _error;
		 
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
	end foreach
	
	--Cargar el Reaseguro Individual de la Unidad
	call sp_sis107a(a_poliza)	returning _error,_error_desc;

	if _error <> 0 then
		return _error,_error_desc;
	end if

	--Actualizar los valores en las unidades
	call sp_proe02(a_poliza, "00001", v_codcompania) returning li_return;

	if li_return = 0 then
		let li_return = sp_proe03(a_poliza,v_codcompania);
		if li_return <> 0 then
			return li_return,_error_desc;
		end if
	else
		return li_return,_error_desc;
	end if
{
	call sp_proe03(a_poliza,'001') returning li_return;

	if li_return <> 0 then
		return li_return,'Error al Emitir la Póliza ';
	end if
}
	-- Actualización de la Póliza
	call sp_pro374 (a_poliza) returning _error,_error_isam,_error_title,_error_desc;

	if _error <> 0 then
		return _error,_error_desc;
	end if
--commit work;
	return 0,"Actualización Exitosa";
	end
end procedure