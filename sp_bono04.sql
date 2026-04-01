--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Rentabilidad Ramos Generales
--***********************************************************************************
-- Creado    : 15/10/2015 - Autor: Armando Moreno

DROP PROCEDURE sp_bono04;
CREATE PROCEDURE sp_bono04(
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
define _porc_bono	dec(5,2);
define _prima_suscrita  DEC(16,2);

define a_periodo_anio    integer;
define v_periodo_ap_anio integer;
define _anio_procesar	 char(4);
define _error            integer;
define _cod_agente       char(5);
define _return,_cnt 	 integer;


--SET DEBUG FILE TO "sp_che94.trc";
--TRACE ON;

let _error          = 0;
let _prima_cobrada  = 0;
let _prima_suscrita = 0;

--Poner esta linea en comentario cuando se vaya a utilizar.

--return 0, 'Actualizacion Exitosa...',a_periodo;

select par_periodo_act,
	   ult_per_renta_rg
  into a_periodo,
	   v_periodo_ap
  from parparam
 where cod_compania = a_compania;

let a_periodo_anio    = a_periodo[1,4] - 1;
let v_periodo_ap_anio = v_periodo_ap[1,4]; 

{if a_periodo_anio <= v_periodo_ap_anio then
   return 1,'Bonificacion de Rentabilidad ya fue Generado.',v_periodo_ap;
end if}

let a_periodo_anio = v_periodo_ap[1,4] + 1;
let _anio_procesar = a_periodo_anio;
let a_periodo      = _anio_procesar||v_periodo_ap[5,7];


delete from chqborege where periodo = a_periodo;

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
	  from bono_prod_d
	 group by cod_agente_uni
	 
	{if _cod_agente = '02311' then --Solicitud de GS -- Román --30/03/2023
		let _prima_suscrita = _prima_suscrita - 10749.47;
		let _prima_cobrada = _prima_cobrada - 10749.47;			
	end if}

	if _prima_suscrita >= 25000 And _prima_suscrita <= 50000 then
	    let _porc_bono = 1;
		let _return = sp_bono05(_cod_agente,_porc_bono, a_periodo);
	 elif _prima_suscrita > 50000 And _prima_suscrita <= 100000 then
	 	let _porc_bono = 2.5;
		let _return = sp_bono05(_cod_agente,_porc_bono, a_periodo);
	 elif _prima_suscrita > 100000 then
   	    let _porc_bono = 5;
		let _return = sp_bono05(_cod_agente,_porc_bono, a_periodo);
	 end if	 
end foreach

SELECT count(*)
  INTO _cnt
  FROM chqborege
 WHERE periodo = a_periodo;
 
if _cnt > 0 then

	foreach
		SELECT cod_agente
		  INTO _cod_agente
		  FROM chqborege
		 WHERE periodo = a_periodo
		 GROUP BY cod_agente
		 ORDER BY cod_agente

		call sp_bono06(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

		if _error <> 0 then
			return _error,'Error sp_bono06',a_periodo;
		end if

	end foreach	

	-- Actualiza parametros
	update parparam
	   set ult_per_renta_rg = a_periodo
	 where cod_compania     = a_compania;
else
	return 0, 'Ningun Corredor Clasificó, verifique...',a_periodo;
end if
end  
return 0, 'Actualizacion Exitosa...',a_periodo;
--Para año 2022 en tabla chqborege, hay una diferencia vs el reporte final, esto debido a un calculo especial,
--para el corredor 02311 realizado por Roman por petición de GS.
END PROCEDURE;	  