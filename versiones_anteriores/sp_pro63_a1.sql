-- Modificado 07/09/2001 - Autor: Marquelda Valdelamar(inclusion de filtro d poliza)
---24102022 desglosar por unidad  HGIRON

DROP procedure sp_pro63_a;

CREATE procedure "informix".sp_pro63_a(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo DATE, a_cod_ramo CHAR(255) DEFAULT "*", a_codcliente CHAR(255) DEFAULT "*" ,a_subramo CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. cliente
          CHAR(20),		 --poliza
          DATE,			 --vig ini
          DATE,			 --vig fin
          DECIMAL(16,2), --prima suscrita
          DATE,			 --fecha
          DECIMAL(16,2), --suma asegurada
          CHAR(255),	 --v_filtros
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --prima
		  CHAR(5),
		  CHAR(50),
		  CHAR(50),char(5),char(30);

----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS VIGENTES  ---
---  Amado Perez mayo 2001 - APM          	 ---
---  Ref. Power Builder - dw_pro63				 ---
----------------------------------------------------
 BEGIN


define v_filtros		char(255);
define v_desc_agente	char(50);
define v_descr_cia		char(50);
define v_desc_ramo		char(50);
define v_desc_contrato	char(50);
DEFINE v_desc_subramo    CHAR(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define v_nopoliza		char(10);
define v_contratante	char(10);
define v_codigo			char(10);
define _cod_acreedor	char(5);
define v_cod_grupo		char(5);
define _limite			char(5);
define v_cod_sucursal	char(3);
define _cod_tipoprod	char(3);
define v_cod_ramo		char(3);
define _tipo_prod		char(3);
define v_saber			char(2);
define _tipo			char(1);
define v_prima_suscrita	dec(16,2);
define v_suma_asegurada	dec(16,2);
define v_prima_bruta	dec(16,2);
define v_cant_polizas	integer;
define v_vigencia_final	date;
define v_vigencia_inic	date;
define _cod_coasegur    char(3);
define _porc_coas       dec(7,4);
define _prima_cobrada   dec(16,2);
define _suma_retencion, _prima_retencion, _prima_cob_retencion    dec(16,2);
define _suma_contratos,	_prima_contratos, _prima_cob_contratos    dec(16,2);
define _suma_facultativos, _prima_facultativos, _prima_cob_facultativos dec(16,2);
define _cod_contrato					 	   char(5);
define _tipo_contrato, _es_terremoto, _orden	 	   smallint;
define _suma, _prima 		  			 	   dec(16,2);
define _cod_cober_reas                         char(3);
define _no_unidad			char(5);
define _no_cambio			smallint;
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma 	dec(9,6);
DEFINE _fecha_emision, _fecha_cancelacion, _fecha_added, _fecha_rehabilito DATE;
DEFINE  _cod_subramo			 		CHAR(3);


define _cod_grupo			char(5);
define _n_grupo			    char(30);

let v_cod_sucursal   = null;
let v_contratante    = null;
let _no_documento    = null;
let v_cod_grupo      = null;
let v_desc_ramo      = null;
let v_descr_cia      = null;
let v_cod_ramo       = null;
let _tipo            = null;
let _no_unidad = null;
let _no_cambio = null;
let v_prima_suscrita = 0;
let v_cant_polizas   = 0;
let v_prima_bruta    = 0;

let _suma_facultativos = 0; 
let _suma_retencion   = 0;
let _suma_contratos   = 0;

let _prima_facultativos = 0; 
let _prima_retencion   = 0;
let _prima_contratos   = 0;

let _prima_cob_facultativos = 0; 
let _prima_cob_retencion   = 0;
let _prima_cob_contratos   = 0;
let v_desc_contrato = '';

drop table if exists tmp_codigos;
drop table if exists temp_perfil;
drop table if exists tmp_contratos;

CREATE TEMP TABLE tmp_contratos
            (no_poliza          CHAR(10),	
			 no_documento       CHAR(20),			 
			 no_unidad          CHAR(5),	
			 cod_cober_reas     CHAR(3),	
			 cod_contrato       CHAR(5),	
             nombre            CHAR(50),
			 tipo_contrato     SMALLINT,
			 orden             SMALLINT,
             suma              DEC(16,2),
             prima             DEC(16,2),
             prima_suscrita    DEC(16,2),
             suma_asegurada    DEC(16,2),		 
             suma_retencion     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2)
             );
CREATE INDEX i_no_poliza1 ON tmp_contratos(cod_contrato);
CREATE INDEX i_no_poliza2 ON tmp_contratos(no_poliza);
CREATE INDEX i_no_poliza3 ON tmp_contratos(no_unidad);
CREATE INDEX i_no_poliza4 ON tmp_contratos(cod_cober_reas);

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
let _cod_coasegur = sp_sis02(a_cia,a_agencia);
 let _no_unidad = null;
 let _n_grupo = null;
 let v_suma_asegurada = 0.00;
 
LET v_filtros =  'Ramo 001,003,006,010,011,012,013,014,021,022;';
let a_cod_ramo = '001,003,006,010,011,012,013,014,021,022;';

LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_cod_ramo);
--set debug file to "sp_pro03.trc"; 
--trace on;
--Se Aplica el Filtro de Sucursales
if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_codcliente <> "*" then
	let v_filtros = trim(v_filtros) ||"Cliente: "||trim(a_codcliente);
	let _tipo = sp_sis04(a_codcliente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro de poliza
if a_no_documento <> "*" and a_no_documento <> "" then
	let v_filtros = trim(v_filtros) ||"Documento: "||trim(a_no_documento);

	update temp_perfil
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_documento <> a_no_documento;
end if

set isolation to dirty read;

foreach with hold
	select y.no_documento,
		   y.cod_ramo,
		   y.cod_contratante,
		   y.vigencia_inic,
		   y.vigencia_final,
		   y.cod_grupo,
		   y.suma_asegurada,
		   y.prima_suscrita,
		   y.prima_bruta,
		   y.cod_tipoprod,
		   y.no_poliza,
		   y.cod_subramo
	  into _no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_cod_grupo,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   v_prima_bruta,
		   _cod_tipoprod,
		   v_nopoliza,
		   _cod_subramo
	  from temp_perfil y
 WHERE no_documento in (
 '0108-00025-06',
 '0119-00279-01',
 '1021-00002-01',
 '2215-00016-01',
 '2218-00010-01',
 '2220-00002-01',
 '0622-00071-01',
 '0619-00002-12',
 '0620-00054-01'
 ) --and seleccionado = 1
	 order by y.cod_ramo,y.no_documento
	 
	 let v_nopoliza = v_nopoliza;
	 
    select fecha_cancelacion, cod_grupo
	  into _fecha_cancelacion, _cod_grupo
	  from emipomae
	 where no_poliza  = v_nopoliza

	   and vigencia_inic <= a_periodo
	   and actualizado = 1;  
	   
	    if _fecha_cancelacion is null then 

			SELECT max(fecha_emision)
			  INTO _fecha_cancelacion
			  FROM endedmae
			 WHERE no_poliza = v_nopoliza
			   AND cod_endomov = '002'
			   AND fecha_emision <= a_periodo;	
		end if		 

	select a.nombre
	  into v_desc_ramo
	  from prdramo a
	 where a.cod_ramo  = v_cod_ramo;
	 
   SELECT c.nombre
     INTO v_desc_subramo
     FROM prdsubra c
    WHERE c.cod_ramo = v_cod_ramo
      AND c.cod_subramo = _cod_subramo;	 

	select nombre
	  into v_asegurado
	  from cliclien
	 where cod_cliente = v_contratante;

	select nombre
	  into v_desc_grupo
	  from cligrupo
	 where cod_grupo = v_cod_grupo;

	let _tipo_prod = '';
	LET _porc_coas = 100;

	
	{
•	Si se canceló antes del 30/06 no se muestra.
•	Si la Póliza se cancelo y se rehabilitó antes del 30/06 se debe mostrar.
•	Si la Póliza se canceló antes del 30/06 y se rehabilitó después del 30/06 NO se Muestra.
 
	}
	
	if _cod_tipoprod = '001' then
		let _tipo_prod = 'MAY';
		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = v_nopoliza
		   AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF
		
		let v_suma_asegurada = v_suma_asegurada * _porc_coas / 100;
		--let v_prima_suscrita = v_prima_suscrita * _porc_coas / 100;
	elif _cod_tipoprod = '002' then
		let _tipo_prod = 'MIN';
	end if		
	
	let _suma_facultativos = 0; 
	let _suma_retencion   = 0;
	let _suma_contratos   = 0;	
	
	foreach
		select no_unidad,
			   suma_asegurada,
			   prima
		  into _no_unidad,
			   _suma,
			   _prima
		  from emipouni
		 where no_poliza = v_nopoliza

		let _no_cambio = null;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = v_nopoliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			let _no_cambio = 0;
		end if		
		
		foreach
			select r.cod_contrato,
				   r.porc_partic_prima,
				   r.cod_cober_reas,
				   c.tipo_contrato,
				   c.nombre
			  into _cod_contrato,
				   _porc_partic_prima,
				   _cod_cober_reas,
				   _tipo_contrato,
				   v_desc_contrato
			  from emireaco r, reacomae c
			 where r.cod_contrato = c.cod_contrato
			   and no_poliza = v_nopoliza
			   and no_unidad = _no_unidad
			   and no_cambio = _no_cambio			   		   
			   
			SELECT es_terremoto
			  INTO _es_terremoto
			  FROM reacobre
			 WHERE cod_cober_reas = _cod_cober_reas;			   		 		 

				LET _suma_retencion    = 0;
				LET _suma_facultativos = 0;
				LET _suma_contratos    = 0;	
				LET _prima_retencion    = 0;
				LET _prima_facultativos = 0;
				LET _prima_contratos    = 0;					
			
			IF   _tipo_contrato = 1 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_retencion    = 0;
					LET _prima_retencion    = 0;
				ELSE
					LET _suma_retencion    = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
					LET _prima_retencion    = _prima * (_porc_partic_prima/100) * _porc_coas / 100;
				END IF			
			ELIF _tipo_contrato = 3 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_facultativos    = 0;
					LET _prima_facultativos    = 0;
				ELSE
					LET _suma_facultativos = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
					LET _prima_facultativos = _prima * (_porc_partic_prima/100) * _porc_coas / 100;
				END IF			
			ELSE
				IF _es_terremoto = 1 THEN
					LET _suma_contratos    = 0;
					LET _prima_contratos    = 0;
				ELSE
					LET _suma_contratos    = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
					LET _prima_contratos    = _prima * (_porc_partic_prima/100) * _porc_coas / 100;
				END IF			
			END IF		
			
			  if _suma_facultativos is null then
				let _suma_facultativos = 0;
			 end if
			  if _suma_retencion is null then
				let _suma_retencion = 0;
			  end if
			 if _suma_contratos is null then
				let _suma_contratos = 0;
			 end if		
			 
		     if _prima_facultativos is null then
				let _prima_facultativos = 0;
			 end if
			  if _prima_retencion is null then
				let _prima_retencion = 0;
			  end if
			 if _prima_contratos is null then
				let _prima_contratos = 0;
			 end if				 

		let _prima = _prima;
		let _suma = _suma;
		
		let _prima = _prima_facultativos + _prima_retencion + _prima_contratos;
		let _suma = _suma_facultativos + _suma_retencion + _suma_contratos;

		
		let _orden = 0;
		
			BEGIN
					  ON EXCEPTION IN(-239)
						 UPDATE tmp_contratos
							SET prima_suscrita = prima_suscrita + _prima ,
							suma_asegurada = suma_asegurada + _suma
						  WHERE cod_contrato = _cod_contrato
						    and no_poliza  = v_nopoliza
							AND no_unidad = _no_unidad
							and cod_cober_reas = _cod_cober_reas;

			END EXCEPTION
			
			insert into tmp_contratos(
					no_poliza,
					no_documento,
					no_unidad,
					cod_cober_reas,
					cod_contrato,nombre,tipo_contrato,orden,suma,prima,prima_suscrita,suma_asegurada,
					suma_retencion,
					suma_contratos,
					suma_facultativos)
			values(	v_nopoliza,
			        _no_documento,
					_no_unidad,
					_cod_cober_reas,
					_cod_contrato, v_desc_contrato, _tipo_contrato, _orden, _suma, _prima,_prima,_suma,					
					_suma_retencion,
					_suma_contratos,
					_suma_facultativos);
	       END					
					
		end foreach		
	end foreach			
	
	{return	v_cod_ramo,
			v_desc_ramo,
			_no_documento,
			v_asegurado,
			v_vigencia_inic,
			v_vigencia_final,
			v_desc_grupo,
			v_suma_asegurada,
			v_prima_suscrita,
			v_filtros,
			v_descr_cia,
			v_prima_bruta,
			_tipo_prod,
			v_nopoliza,
			_prima_cobrada,
			_suma_retencion,
			_suma_contratos,
			_suma_facultativos,
			_prima_cob_retencion,
			_prima_cob_contratos,
			_prima_cob_facultativos			
			with resume;}
end foreach
--drop table temp_perfil;

	FOREACH
	 SELECT no_unidad,
	        nombre,
			sum(prima_suscrita),
			sum(suma_asegurada),
	        SUM(suma),
	        SUM(prima)
	   INTO _no_unidad,
	        v_desc_contrato,
			v_prima_suscrita,
			v_suma_asegurada,
	        _suma,
	        _prima
	   FROM tmp_contratos
	  WHERE no_poliza = v_nopoliza
	  GROUP BY no_unidad,nombre 
	  ORDER BY no_unidad,nombre
	  

       RETURN v_descr_cia,
       		  v_cod_ramo,
              v_desc_ramo,
              v_asegurado,
              _no_documento,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
              a_periodo,
			  v_suma_asegurada,
              v_filtros,
              _suma,
              _prima,
			  _cod_contrato,
			  v_desc_contrato,
			  v_desc_subramo,
			  _no_unidad,
			  _n_grupo
              WITH RESUME;
	END FOREACH




END

END PROCEDURE;