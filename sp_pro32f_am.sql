--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32f('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_pro32f_am;
create procedure sp_pro32f_am(
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
a_codvend       char(255)	default "*") 

returning	char(5)  as cod_grupo,
			char(50) as desc_grupo,
			char(50) as desc_ramo,
			char(50) as desc_subramo,
			char(20) as poliza,
			char(5)  as no_unidad,
			char(50) as marca,
			char(50) as modelo,
			char(50) as tipo_auto,
			char(30) as placa,
			smallint as anno_auto,
			dec(16,2) as v_suma_asegurada,
			dec(16,2) as v_prima_suscrita,
			char(40) as colision,
			char(40) as ded_colision,
			char(40) as comprensivo,
			char(40) as ded_comprensivo,
			char(40) as incendio,
			char(40) as ded_incendio,
			char(40) as robo,
			char(40) as ded_robo;

define v_filtros		char(255);
define v_desc_agente	char(50);
define v_descr_cia		char(50);
define v_desc_ramo,v_desc_subramo		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define _temp_poliza		char(10);
define v_contratante	char(10);
define v_codigo			char(10);
define _cod_acreedor	char(5);
define v_cod_grupo,_cod_marca,_cod_modelo		char(5);
define _limite,_no_unidad,_cod_cobertura			char(5);
define v_cod_sucursal,_cod_tipoauto	char(3);
define _placa           char(30);
define _cod_tipoprod	char(3);
define v_cod_ramo		char(3);
define _tipo_prod,_cod_subramo		char(3);
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
DEFINE _suc_prom        CHAR(3);
define _ano_auto        smallint;
DEFINE _cod_vendedor	char(3);
define _no_motor        char(30);
DEFINE _nombre_vendedor,_n_marca,_n_modelo,_n_tipoauto	    	     CHAR(50);
define _n_cober_col,_n_cober_comp,_n_cober_inc,_ded_col char(40);
define _ded_comp,_ded_inc,_n_cober_robo,_ded_robo char(40);


let v_cod_sucursal   = null;
let v_contratante    = null;
let _no_documento     = null;
let v_cod_grupo      = null;
let v_desc_ramo      = null;
let v_descr_cia      = null;
let v_cod_ramo       = null;
let _tipo            = null;
let v_prima_suscrita = 0;
let v_cant_polizas   = 0;
let v_prima_bruta    = 0;
let v_saber = '';

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
let _cod_coasegur = sp_sis02(a_cia,a_agencia);

---call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;
call sp_pro03i(a_cia,a_agencia,a_fecha,a_codramo,a_codvend) returning v_filtros;  -- Filtro de Zona DALBA  
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


	IF a_codvend <> "*" THEN   -- Aplica Filtro de Zona 
		LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
		LET v_filtros = TRIM(v_filtros) ||" Zona :"; --||TRIM(a_codvend);

		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = "";
		ELSE
			UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = " Ex";
		END IF
		
	    FOREACH
			SELECT distinct temp_perfil.nombre_vendedor,tmp_codigos.codigo
		      INTO _nombre_vendedor,v_codigo
		      FROM temp_perfil,tmp_codigos
		     WHERE temp_perfil.cod_vendedor = codigo
			 
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(_nombre_vendedor) || (v_saber);
	    END FOREACH		

		DROP TABLE tmp_codigos;
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
	 order by y.cod_ramo,y.no_documento

	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;
	 
	select cod_subramo into _cod_subramo from emipomae
	where no_poliza = _temp_poliza;
	 
	select nombre
	  into v_desc_subramo
	  from prdsubra
	 where cod_ramo    = v_cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre
	  into v_asegurado
	  from cliclien
	 where cod_cliente = v_contratante;

	select nombre
	  into v_desc_grupo
	  from cligrupo
	 where cod_grupo = v_cod_grupo;

	let _tipo_prod = '';
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
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _temp_poliza

		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = _temp_poliza
           and no_unidad = _no_unidad;

		select cod_marca,
		       cod_modelo,
			   ano_auto,
			   placa
		  into _cod_marca,
               _cod_modelo,
               _ano_auto,
               _placa
          from emivehic
         where no_motor = _no_motor;

		select nombre into _n_marca from emimarca
		where cod_marca = _cod_marca;
		
		select nombre,
		       cod_tipoauto
		  into _n_modelo,
		       _cod_tipoauto
		  from emimodel
		where cod_modelo = _cod_modelo;
			   
		select nombre into _n_tipoauto from emitiaut
		where cod_tipoauto = _cod_tipoauto;
		
		let _ded_col = "";
		let _n_cober_comp = "";
		let _n_cober_col  = "";
		let _n_cober_inc  = "";
		let _n_cober_robo = "";
		foreach
			select cod_cobertura,
				   deducible
			  into _cod_cobertura,
				   _ded_col
			  from emipocob
			 where no_poliza = _temp_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in('00121','00119')	--colision
			
			let _n_cober_col = "";
			select nombre into _n_cober_col from prdcober
			where cod_cobertura = _cod_cobertura;
		end foreach
		
		let _ded_comp = "";
		foreach
			select cod_cobertura,
				   deducible
			  into _cod_cobertura,
				   _ded_comp
			  from emipocob
			 where no_poliza = _temp_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in('00118','00606')	--comprensivo
			   
  			let _n_cober_comp = "";
			select nombre into _n_cober_comp from prdcober
			where cod_cobertura = _cod_cobertura;
		end foreach
		
		let _ded_inc = "";
		foreach
			select cod_cobertura,
				   deducible
			  into _cod_cobertura,
				   _ded_inc
			  from emipocob
			 where no_poliza = _temp_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in('00120','01146')	--incendio
			   
  			let _n_cober_inc = "";
			select nombre into _n_cober_inc from prdcober
			where cod_cobertura = _cod_cobertura;
		end foreach
		
		let _ded_robo = "";
		foreach
			select cod_cobertura,
				   deducible
			  into _cod_cobertura,
				   _ded_robo
			  from emipocob
			 where no_poliza = _temp_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in('00103','00901')	--robo
			   
  			let _n_cober_robo = "";
			select nombre into _n_cober_robo from prdcober
			where cod_cobertura = _cod_cobertura;
		end foreach
		
	return	v_cod_grupo,
	        v_desc_grupo,
	        v_desc_ramo,
			v_desc_subramo,
			_no_documento,
			_no_unidad,
			_n_marca,
			_n_modelo,
			_n_tipoauto,
			_placa,
			_ano_auto,
			v_suma_asegurada,
			v_prima_suscrita,
			_n_cober_col,
			_ded_col,
			_n_cober_comp,
			_ded_comp,
			_n_cober_inc,
			_ded_inc,
			_n_cober_robo,
			_ded_robo
			with resume;
	end foreach		
end foreach
drop table temp_perfil;
end procedure;