--POLIZAS VIGENTES POR RAMO incluyendo Prima cobrada. Presenta Distribucion de reaseguro.
--Creado : 10/05/2021 - Autor: Henry Giron
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_rea43('001','001','31/03/2021','*','017;','*','*','*','*','*','*','01/07/2020','*','001,004;')


drop procedure sp_rea43;
create procedure "informix".sp_rea43(
a_cia			char(3),
a_agencia		char(3),
a_fecha			date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_agente		char(255)	default "*",
a_usuario		char(255)	default "*",
a_cod_cliente	char(255)	default "*",
a_acreedor		char(255)	default "*",
a_no_documento	char(255)	default "*",
a_fecha2        date,
a_serie			char(255) default "*",
a_subramo		char(255) default "*")

returning	char(3)  as v_cod_ramo,
			char(50) as v_desc_ramo,
			char(20) as _no_documento,
			char(45) as v_asegurado,
			date     as v_vigencia_inic,
			date     as v_vigencia_final,
			char(40) as v_desc_grupo,
			dec(16,2) as v_suma_asegurada,
			dec(16,2) as v_prima_suscrita,
			char(255) as v_filtros,
			char(50) as v_descr_cia,
			dec(16,2) as v_prima_bruta,
			char(3) as tipo_prod,
			char(10) as temp_poliza,
			dec(16,2) as prima_cobrada,			
			dec(16,2) as suma_retencion,
			dec(16,2) as suma_contratos,
			dec(16,2) as suma_facultativos,
			dec(16,2) as prima_cob_retencion,
			dec(16,2) as prima_cob_contratos,
			dec(16,2) as prima_cob_facultativos,
			smallint  as serie,
            DEC(16,2) as ld_ps_casco , 
			DEC(16,2) as ld_ps_rctercero,
			DEC(16,2) as ld_ps_acc_pers, 
			DEC(16,2) as ld_ps_gts_med		
			
		  ;

					
					
define v_filtros		char(255);
define v_desc_agente	char(50);
define v_descr_cia		char(50);
define v_desc_ramo		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define _temp_poliza		char(10);
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
define _tipo_contrato, _es_terremoto	 	   smallint;
define _suma, _prima 		  			 	   dec(16,2);
define _cod_cober_reas                         char(3);
define _no_unidad			char(5);
define _no_cambio			smallint;
define _porc_partic_prima	dec(9,6);
define _serie				smallint;
DEFINE _ld_ps_casco		    dec(16,2);
DEFINE _ld_ps_rctercero		dec(16,2);
DEFINE _ld_ps_acc_pers		dec(16,2);
DEFINE _ld_ps_gts_med	    dec(16,2);
DEFINE _ld_pc_casco		    dec(16,2);
DEFINE _ld_pc_rctercero		dec(16,2);
DEFINE _ld_pc_acc_pers		dec(16,2);
DEFINE _ld_pc_gts_med	    dec(16,2);

--CASCO Y MAQUINARIA	RESPONSABILIDAD CIVIL A TERCEROS  ( PANDI )	ACCIDENTES PERSONALES	GASTOS MEDICOS
set debug file to "sp_rea43.trc"; 
trace on;

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

let _prima_cob_facultativos = 0; 
let _prima_cob_retencion   = 0;
let _prima_cob_contratos   = 0;
let _serie = 0;
 Drop table if exists temp_perfil;
 Drop table if exists tmp_contratos;
CREATE TEMP TABLE tmp_contratos
            (no_poliza          CHAR(10),	
             serie				smallint,			
			 no_documento       CHAR(20),			 
			 no_unidad          CHAR(5),	
			 cod_cober_reas     CHAR(3),	
			 cod_contrato       CHAR(5),						
             suma_retencion     DEC(16,2),
             suma_contratos     DEC(16,2),
             suma_facultativos  DEC(16,2),
			 porc_partic_prima	dec(9,6),
			 porc_coas          dec(7,4),
			ld_ps_casco		    dec(16,2),
			ld_ps_rctercero		dec(16,2),
			ld_ps_acc_pers		dec(16,2),
			ld_ps_gts_med	    dec(16,2),
			ld_pc_casco		    dec(16,2),
			ld_pc_rctercero		dec(16,2),
			ld_pc_acc_pers		dec(16,2),
			ld_pc_gts_med	    dec(16,2),
            seleccionado		smallint default 1			
			 );
--,primary key (no_poliza,no_documento,serie,no_unidad )) with no log;

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
let _cod_coasegur = sp_sis02(a_cia,a_agencia);
let _ld_ps_casco  = 0;
let _ld_ps_rctercero  = 0;
let _ld_ps_acc_pers  = 0;
let _ld_ps_gts_med  = 0;
let _ld_pc_casco  = 0;
let _ld_pc_rctercero  = 0;
let _ld_pc_acc_pers  = 0;
let _ld_pc_gts_med  = 0;


call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;
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

if a_codgrupo <> "*" then
	let v_filtros = trim(v_filtros) ||"Grupo "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_agente <> "*" then
	let v_filtros = trim(v_filtros) ||"Corredor: "; --||trim(a_agente);
	let _tipo = sp_sis04(a_agente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	
		let v_saber = "";
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);

		let v_saber = " Ex";
	end if

	foreach
		select a.nombre,
			   t.codigo
		  into v_desc_agente,
			   v_codigo
		  from agtagent a,tmp_codigos t
		 where a.cod_agente = t.codigo
		 
		let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_agente) || trim(v_saber);
	end foreach
	drop table tmp_codigos;
end if

if a_usuario <> "*" then
	let v_filtros = trim(v_filtros) ||"Corredor: "||trim(a_usuario);
	let _tipo = sp_sis04(a_usuario); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and usuario not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and usuario in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_cod_cliente <> "*" then
	let v_filtros = trim(v_filtros) ||"Cliente: "||trim(a_cod_cliente);
	let _tipo = sp_sis04(a_cod_cliente); -- separa los valores del string

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

if a_acreedor <> "*" then

	create temp table tmp_acree
	(cod_acreedor	char(5),
	no_poliza		char(10),
	limite			dec(16,2),
	seleccionado	smallint default 1) with no log;

	foreach
		select no_poliza 
		  into _temp_poliza
		  from temp_perfil
		 where seleccionado = 1
		 
		foreach
			select cod_acreedor,
				   limite
			  into _cod_acreedor,
				   _limite
			  from emipoacr
			 where no_poliza = _temp_poliza

			insert into tmp_acree
			values(	_cod_acreedor,
					_temp_poliza,
					_limite,
					1);
		end foreach
	end foreach

	let v_filtros = trim(v_filtros) ||"Acreedor: "||trim(a_acreedor);
	let _tipo = sp_sis04(a_acreedor); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update tmp_acree
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_acreedor not in(select codigo from tmp_codigos);
	else
		update tmp_acree
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_acreedor in(select codigo from tmp_codigos);
	end if

	update temp_perfil
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_poliza not in(select no_poliza from tmp_acree where seleccionado = 1);

	drop table tmp_codigos;
	drop table tmp_acree;
end if


if a_subramo <> "*" then
	let v_filtros = trim(v_filtros) ||" Sub Ramo "||trim(a_subramo);
	Let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

-- Filtro por Serie
IF a_serie <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" Serie "||TRIM(a_serie);
END IF

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
		   y.no_poliza
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
		   _temp_poliza
	  from temp_perfil y 
	 where y.seleccionado = 1 
	  --AND y.cod_ramo IN ('017')   AND y.cod_subramo IN ('001','004')
	-- and y.no_documento = '1721-00004-01'

	 order by y.cod_ramo,y.no_documento 

	select a.nombre
	  into v_desc_ramo
	  from prdramo a
	 where a.cod_ramo  = v_cod_ramo;

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
	if _cod_tipoprod = '001' then
		let _tipo_prod = 'MAY';
		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _temp_poliza
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
			   suma_asegurada
		  into _no_unidad,
			   _suma
		  from emipouni
		 where no_poliza = _temp_poliza

		let _no_cambio = null;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _temp_poliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			let _no_cambio = 0;
		end if		
		
		foreach
			select r.cod_contrato,
				   r.porc_partic_prima,
				   r.cod_cober_reas,
				   c.tipo_contrato, c.serie
			  into _cod_contrato,
				   _porc_partic_prima,
				   _cod_cober_reas,
				   _tipo_contrato, _serie
			  from emireaco r, reacomae c
			 where r.cod_contrato = c.cod_contrato
			   and no_poliza = _temp_poliza
			   and no_unidad = _no_unidad
			   and no_cambio = _no_cambio 
			   
			SELECT es_terremoto
			  INTO _es_terremoto
			  FROM reacobre
			 WHERE cod_cober_reas = _cod_cober_reas;			   		 		 

				LET _suma_retencion    = 0;
				LET _suma_facultativos = 0;
				LET _suma_contratos    = 0;	
			
			IF   _tipo_contrato = 1 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_retencion    = 0;
				ELSE
					LET _suma_retencion    = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
				END IF			
			ELIF _tipo_contrato = 3 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_facultativos    = 0;
				ELSE
					LET _suma_facultativos = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
				END IF			
			ELSE
				IF _es_terremoto = 1 THEN
					LET _suma_contratos    = 0;
				ELSE
					LET _suma_contratos    = _suma * (_porc_partic_prima/100) * _porc_coas / 100;
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

			let _ld_pc_casco  = 0;
			let _ld_pc_rctercero  = 0;
			let _ld_pc_acc_pers  = 0;
			let _ld_pc_gts_med  = 0;			 
			
			let _ld_ps_casco  = 0;
			let _ld_ps_rctercero  = 0;
			let _ld_ps_acc_pers  = 0;
			let _ld_ps_gts_med  = 0;		
		
			foreach			
			SELECT emipocob.limite_1
			into _ld_ps_casco
				  FROM prdcober, emipocob
				 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
				   AND ( emipocob.no_poliza = _temp_poliza ) 
				   AND ( emipocob.no_unidad = _no_unidad)	
				   AND (nombre like ('%CASCO%') 
				   or nombre like ('%CASCO Y MAQUINARIA%')
				   or emipocob.cod_cobertura in ("00486","00495","00504","00505","00520","00664","00811")
)			
		   
				   exit foreach;
			   end foreach	 	
		   if _ld_ps_casco is null then
			let _ld_ps_casco = 0;
		   end if			   
		   
			foreach			
			SELECT emipocob.limite_1
			into _ld_ps_rctercero
				  FROM prdcober, emipocob
				 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
				   AND ( emipocob.no_poliza = _temp_poliza ) 
				   AND ( emipocob.no_unidad = _no_unidad)	
				   AND (nombre like ('%RESPONSABILIDAD CIVIL%') 				   
				   or nombre like ('%RESPONSABILIDAD CIVIL A TERCEROS%') 
				   or emipocob.cod_cobertura in ("00489","00493","00497","00527","00752","01242"))			
				   
  
		   
				   exit foreach;
			   end foreach	 	
		   if _ld_ps_rctercero is null then
			let _ld_ps_rctercero = 0;
		   end if			   

			foreach			
			SELECT emipocob.limite_1
			into _ld_ps_acc_pers
				  FROM prdcober, emipocob
				 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
				   AND ( emipocob.no_poliza = _temp_poliza ) 
				   AND ( emipocob.no_unidad = _no_unidad)	
				   AND (nombre like ('%ACCIDENTES PERSONALES%' )			
				   or emipocob.cod_cobertura in ("00493","00512","00513"))
		   
				   exit foreach;
			   end foreach	 	
		   if _ld_ps_acc_pers is null then
			let _ld_ps_acc_pers = 0;
		   end if			   

			foreach			
			SELECT emipocob.limite_1
			into _ld_ps_gts_med
				  FROM prdcober, emipocob
				 WHERE prdcober.cod_cobertura = emipocob.cod_cobertura
				   AND ( emipocob.no_poliza = _temp_poliza ) 
				   AND ( emipocob.no_unidad = _no_unidad)	
				   AND (nombre like ('%GASTOS MEDICOS%' )			
				   or emipocob.cod_cobertura in ("00494","00522"))

		   
				   exit foreach;
			   end foreach	 	
		   if _ld_ps_gts_med is null then
			let _ld_ps_gts_med = 0;
		   end if		   		   

			insert into tmp_contratos(
					no_poliza,
					serie,
					no_documento,
					no_unidad,
					cod_cober_reas,
					cod_contrato,
					suma_retencion,
					suma_contratos,
					suma_facultativos,
					porc_partic_prima,
					porc_coas,
					ld_ps_casco,
					ld_ps_rctercero,
					ld_ps_acc_pers,
					ld_ps_gts_med,
					ld_pc_casco,
					ld_pc_rctercero,
					ld_pc_acc_pers,
					ld_pc_gts_med
					)
			values(	_temp_poliza,
					_serie, 
			        _no_documento,
					_no_unidad,
					_cod_cober_reas,
					_cod_contrato,
					_suma_retencion,
					_suma_contratos,
					_suma_facultativos,
					_porc_partic_prima,
					_porc_coas,
					_ld_ps_casco,
					_ld_ps_rctercero,
					_ld_ps_acc_pers,
					_ld_ps_gts_med,
					_ld_pc_casco,
					_ld_pc_rctercero,
					_ld_pc_acc_pers,
					_ld_pc_gts_med
					);					
					
		end foreach		
	end foreach		
	
-- Filtro por Serie
IF a_serie <> "*" THEN
	--LET v_filtros = TRIM(v_filtros) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_contratos
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_contratos
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF
	
	foreach		
		select serie,
		    sum(suma_retencion),
			sum(suma_contratos),
			sum(suma_facultativos)      
	  Into 	_serie,
	       _suma_retencion,
		   _suma_contratos,
		   _suma_facultativos
	  From tmp_contratos			   		   
	 where no_documento = _no_documento
	   and no_poliza = _temp_poliza	
	   and seleccionado = 1
	   group by serie
	 
		  if _suma_facultativos is null then
			let _suma_facultativos = 0;
		 end if
		  if _suma_retencion is null then
			let _suma_retencion = 0;
		  end if
		 if _suma_contratos is null then
			let _suma_contratos = 0;
		 end if		 
		
		LET _prima_retencion    = 0;
		LET _prima_contratos    = 0;
		LET _prima_facultativos = 0;				
	
	
	  let _prima_cobrada = 0;	
	  let _prima_cobrada = sp_rea11(_no_documento, a_fecha2, a_fecha);  --> buscando la prima cobrada en terremoto
	  
	 if _prima_cobrada is null then
		let _prima_cobrada = 0;
	 end if	 


		let _prima_cob_facultativos = 0; 
		let _prima_cob_retencion   = 0;
		let _prima_cob_contratos   = 0;	
	--if  _prima_cobrada > 0 then	
	    select sum(retencion),
				sum(excedente),
				sum(facultativo)      
	      Into _prima_cob_retencion,
		       _prima_cob_contratos,
			   _prima_cob_facultativos
		  From tmp_prima_cobrada			   		   
		 where no_documento = _no_documento
		   and no_poliza = _temp_poliza	
		   and serie = _serie;		 
	-- else	 	 		
	--end if	
	let _prima_cobrada = _prima_cob_retencion + _prima_cob_contratos + _prima_cob_facultativos;
	
	if _prima_cobrada = 0 then
	    continue foreach;
    end if
	 
	 if _prima_cob_facultativos is null then
		let _prima_cob_facultativos = 0;
	 end if
	  if _prima_cob_retencion is null then
		let _prima_cob_retencion = 0;
	  end if
	 if _prima_cob_contratos is null then
		let _prima_cob_contratos = 0;
	 end if
	 
	 let _prima_cobrada = _prima_cob_contratos + _prima_cob_retencion + _prima_cob_facultativos;
	 let _suma = _suma_retencion + _suma_contratos + _suma_facultativos;
	 
	 {
	 if _no_documento in ('1720-00008-01','1720-00009-01','1716-00049-01','1720-00084-01') then 

	   let _ld_ps_casco = _suma;
	   let _ld_ps_rctercero = _suma;			   
	   let _ld_ps_gts_med = 0;
	   let _ld_ps_acc_pers = 0;				   
	   
    end if
	}
	
	if _prima_cobrada <= 0 then 
	    continue foreach;
	end if
		
	return	v_cod_ramo,
			v_desc_ramo,
			_no_documento,
			v_asegurado,
			v_vigencia_inic,
			v_vigencia_final,
			v_desc_grupo,
			_suma, --v_suma_asegurada,
			v_prima_suscrita,
			v_filtros,
			v_descr_cia,
			v_prima_bruta,
			_tipo_prod,
			_temp_poliza,
			_prima_cobrada,
			_suma_retencion,
			_suma_contratos,
			_suma_facultativos,
			_prima_cob_retencion,
			_prima_cob_contratos,
			_prima_cob_facultativos,
            _serie,
            _ld_ps_casco,
			_ld_ps_rctercero,
			_ld_ps_acc_pers,
			_ld_ps_gts_med				
			with resume;
			
	end foreach
end foreach


end procedure;