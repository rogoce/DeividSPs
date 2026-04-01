--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Incentivo 1, proyecto CCP
--***********************************************************************************
-- Creado    : 10/05/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_bonoccp04;
CREATE PROCEDURE sp_bonoccp04(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_usuario           CHAR(8)
) RETURNING SMALLINT,
            char(50),
		    char(7);


define a_periodo        char(7);
define v_periodo_ap     char(7);


define _prima_cobrada   dec(16,2);
define _error_isam		integer;
define _error_desc		char(50);
define _tipo			char(1);
define _cod_tipo        char(1);
define _cod_tipo1       char(1);
define _beneficios      smallint;
define _porc_bono	    dec(5,2);
define _prima_suscrita  DEC(16,2);
define a_periodo_anio    integer;
define v_periodo_ap_anio integer;
define _anio_procesar,_periodo	 char(4);
define _error            integer;
define _cod_agente       char(5);
define _return,_cnt 	 integer;

--SET DEBUG FILE TO "sp_bonoccp04.trc";
--TRACE ON;

let _error          = 0;
let _prima_cobrada  = 0;
let _prima_suscrita = 0;

--Poner esta linea en comentario cuando se vaya a utilizar.
--return 0, 'Actualizacion Exitosa...',a_periodo;

select par_periodo_act,
	   ult_per_inc_ccp
  into a_periodo,
	   v_periodo_ap
  from parparam
 where cod_compania = a_compania;
 
--let a_periodo = '2022-01';	--ELIMINAR ESTA LINEA

let a_periodo_anio    = a_periodo[1,4] - 1;
let _periodo          = a_periodo_anio;
let v_periodo_ap_anio = v_periodo_ap[1,4]; 

{if a_periodo_anio <= v_periodo_ap_anio then
   return 1,'Bonificacion de Rentabilidad ya fue Generado.',v_periodo_ap;
end if}

let a_periodo_anio = v_periodo_ap[1,4] + 1;
let _anio_procesar = a_periodo_anio;
let a_periodo      = _anio_procesar||v_periodo_ap[5,7];

delete from chqboccp where periodo = a_periodo;

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

-- Realiza el Pase de la tabla de carga hacia la tabla de generacion de las requisiciones de cheque para el pago.
foreach
	select cod_agente_uni,
		   sum(prima_cobrada),
		   sum(prima_suscrita)
	  into _cod_agente,
		   _prima_cobrada,
		   _prima_suscrita
	  from bono_ccpl
	 group by cod_agente_uni
     having sum(prima_suscrita) >= 2000

	let _porc_bono  = 0.00;

	select porc_bono
	  into _porc_bono
	  from ccprango
	 where periodo = _periodo
	   and _prima_suscrita between rangops1 and rangops2;

	if _porc_bono is null then
		let _porc_bono = 0;
	end if

	let _return = sp_bonoccp05(_cod_agente,_porc_bono, a_periodo);

end foreach

SELECT count(*)
  INTO _cnt
  FROM chqboccp
 WHERE periodo = a_periodo;
 
if _cnt > 0 then

	foreach
		SELECT cod_agente
		  INTO _cod_agente
		  FROM chqboccp
		 WHERE periodo = a_periodo
		 GROUP BY cod_agente
		 ORDER BY cod_agente

		call sp_bonoccp06(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

		if _error <> 0 then
			return _error,'Error sp_bono06',a_periodo;
		end if

	end foreach	

	-- Actualiza parametros
	update parparam
	   set ult_per_inc_ccp = a_periodo
	 where cod_compania    = a_compania;
else
	return 0, 'Ningun Corredor Clasificó, verifique...',a_periodo;
end if
end  
return 0, 'Actualizacion Exitosa...',a_periodo;
END PROCEDURE;	  