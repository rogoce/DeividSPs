--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

--drop procedure sp_sis209;
create procedure "informix".sp_sis209(
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
a_no_documento	char(255)	default "*")

returning	char(3),
			char(50),
			char(20),
			char(45),
			date,
			date,
			char(40),
			dec(16,2),
			dec(16,2),
			char(255),
			char(50),
			dec(16,2),
			char(3),
			char(50);

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
define _email           char(50);

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

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;

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
		 where agtagent.cod_agente = codigo
		 
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
		   y.cod_tipoprod
	  into _no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_cod_grupo,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   v_prima_bruta,
		   _cod_tipoprod
	  from temp_perfil y
	 where y.seleccionado = 1
	 order by y.cod_ramo,y.no_documento
	 
	 select e_mail
	   into _email
	   from cliclien
	  where cod_cliente =  v_contratante;
	  
	  if _email is null or _email = '' then
	  else
		continue foreach;
	  end if	

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
	if _cod_tipoprod = '001' then
		let _tipo_prod = 'MAY';
	elif _cod_tipoprod = '002' then
		let _tipo_prod = 'MIN';
	end if
	
	return	v_cod_ramo,
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
            _email
			with resume;
end foreach
drop table temp_perfil;
end procedure;