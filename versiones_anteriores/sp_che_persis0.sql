--******************************************************
-- Reporte Totales bono de persistencia para corredores
--******************************************************

-- Creado    : 14/02/2022 - Autor: Armando Moreno M.
-- Modificado: 01/03/2023 HGIRON SD#5742 AMORENO

DROP PROCEDURE sp_che_persis0;
CREATE PROCEDURE sp_che_persis0(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_usuario           CHAR(8)
) RETURNING SMALLINT,
            char(50),
		    char(7);


define a_periodo        char(7);
define v_periodo_ap     char(7);
define _prima_cobrada   dec(16,2);
define _tipo			char(1);
define _cod_tipo        char(1);
define _cod_tipo1       char(1);
define _beneficios      smallint;
define _porc_bono	dec(5,2);
define _prima_suscrita  DEC(16,2);
define a_periodo_anio    integer;
define v_periodo_ap_anio integer;
define _anio_procesar	 char(4);
define _return	 integer;

DEFINE _cod_agente      CHAR(5);
define _cnt             integer;
define _cant_pol         integer;
define _error,_persis			integer;
define _error_isam,_no_pol_ren_aa_per		integer;
define _error_desc		char(50);
define _bono            smallint;
define _n_corredor,_n_zona varchar(50);
define _cod_vendedor char(3);

let _error    = 0;
let _cant_pol = 0;
let _bono     = 0;
let _persis = 0;

--SET DEBUG FILE TO "sp_che_persis0.trc";
--TRACE ON;

let _prima_cobrada  = 0;
let _prima_suscrita = 0;

--Poner esta linea en comentario cuando se vaya a utilizar.

--return 0, 'Actualizacion Exitosa...',a_periodo;

select par_periodo_act,
	   ult_per_bopersis
  into a_periodo,
	   v_periodo_ap
  from parparam
 where cod_compania = a_compania;

let a_periodo_anio    = a_periodo[1,4] - 1;
let v_periodo_ap_anio = v_periodo_ap[1,4]; 

{if a_periodo_anio <= v_periodo_ap_anio then
   return 1,'Bonificacion de Persistencia ya fue Generado. ',v_periodo_ap;
end if}

let a_periodo_anio = v_periodo_ap[1,4] + 1;
let _anio_procesar = a_periodo_anio;
let a_periodo      = _anio_procesar||v_periodo_ap[5,7];


delete from chqbopersis where periodo = a_periodo;

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

-- Realiza el Pase de la tabla de carga hacia la tabla de generacion de las requisiciones de cheque para el pago.

foreach
	select cod_agente,
		   cant_pol 
	  into _cod_agente,
		   _cant_pol  
	  from chepersisapt
	 where cant_pol >= 100
	 order by cod_agente
 
    select sum(no_pol_ren_aa_per)
	  into _no_pol_ren_aa_per
	  from chepersisaa
	 where cod_agente = _cod_agente;
	 
	let _persis = (_no_pol_ren_aa_per / _cant_pol) * 100;

	if _persis >= 75 and _persis < 80 then
		let _bono = 500;
	elif _persis >= 80 and _persis < 90 then
		let _bono = 750;
	elif _persis >= 90 and _persis < 100 then
		let _bono = 1000;
    end if
			
	select nombre,
           cod_vendedor
	  into _n_corredor,
	       _cod_vendedor
	  from agtagent
     where cod_agente = _cod_agente;
	
	select nombre into _n_zona from agtvende
    where cod_vendedor = _cod_vendedor;
	
	--return _cod_agente,	_n_corredor, _cant_pol, _no_pol_ren_aa_per, _persis, _bono,_cod_vendedor,_n_zona with resume;
	
	
	insert into chqbopersis	(
				cod_agente,
				n_corredor,
				tot_pol_ap,
				tot_pol_ren_aa,
				persis,
				monto_bono,
				cod_vendedor,
				n_vendedor,
				periodo,
				fecha_genera,
				no_requis,
				tipo_requis )
        values(	_cod_agente,
				_n_corredor, 
				_cant_pol, 
				_no_pol_ren_aa_per, 
				_persis, 
				_bono,
				_cod_vendedor,
				_n_zona,
				0,
				a_periodo,
				CURRENT, 
				'',
				''
				);				
			

	
end foreach

SELECT count(*)
  INTO _cnt
  FROM chqbopersis
 WHERE periodo = a_periodo;
 
if _cnt > 0 then

	foreach
		SELECT cod_agente
		  INTO _cod_agente
		  FROM chqbopersis
		 WHERE periodo = a_periodo
		 GROUP BY cod_agente
		 ORDER BY cod_agente

		call sp_che_persisach(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

		if _error <> 0 then
			return _error,'Error sp_che_persisach ',a_periodo;
		end if

	end foreach	

	-- Actualiza parametros
	update parparam
	   set ult_per_bopersis = a_periodo
	 where cod_compania     = a_compania;
else
	return 0, 'Ningun Corredor Clasificó, verifique...',a_periodo;
end if
end  
return 0, 'Actualizacion Exitosa...',a_periodo;
END PROCEDURE;	  