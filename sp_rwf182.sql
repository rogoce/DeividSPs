-- Procedimiento que actualiza los reclamos que no tienen
-- reserva con el valor de la reserva que viene de Yoseguro

-- Creado    : 07/09/2023 - Autor: Amado Perez  
-- Similar al sp_rwf67 pero es para los de yoseguro

drop procedure sp_rwf182;

create procedure sp_rwf182(a_no_reclamo char(10), a_reserva dec(16,2) default 0.00) 
returning dec(16,2);

define _no_poliza               CHAR(10);
define _cod_compania, _cod_ramo CHAR(3);
define _periodo_rec             CHAR(7);
define _reserva_inicial         dec(16,2);
define _no_documento			char(20);
define _fecha                   date;
define _cod_evento				CHAR(3);
define _tipo, _cnt_cob, _cnt_cob2, _cnt smallint;
define _suma_asegurada      	dec(16,2);
define _cod_cobertura           char(5);
define _reserva_inicial_div     dec(16,2);
define _reserva_inicial_res     dec(16,2);

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

let _fecha = current;
let _reserva_inicial = 0.00;
let _tipo = 1;
let _cnt_cob = 0;
let _cnt_cob2 = 0;
let _cnt = 0;

set isolation to dirty read;

select count(*)
  into _cnt_cob2
  from recrccob
 where no_reclamo = a_no_reclamo;
 
if _cnt_cob2 is null or _cnt_cob2 = 0 then
	let _cnt_cob2 = 1;
end if

if _cnt_cob2 = 1 then
	 update recrccob
		set reserva_inicial = a_reserva,
			reserva_actual  = a_reserva
	  where no_reclamo      = a_no_reclamo;
else
	-- Distribución de la reserva inicial entre las coberturas seleccionadas
	let _reserva_inicial_res = a_reserva;
	let _reserva_inicial_div = a_reserva / _cnt_cob2;
	
	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from recrccob
	  where no_reclamo = a_no_reclamo
	  
	 let _cnt = _cnt + 1;

	 if _cnt = _cnt_cob2 then
		let _reserva_inicial_div = _reserva_inicial_res;
	 end if

	 update recrccob
		set reserva_inicial = _reserva_inicial_div,
			reserva_actual  = _reserva_inicial_div
	  where no_reclamo      = a_no_reclamo
		and cod_cobertura   = _cod_cobertura;

	 let _reserva_inicial_res = _reserva_inicial_res - _reserva_inicial_div;
	-- exit foreach;

	end foreach
end if
--end if

return a_reserva;

end procedure