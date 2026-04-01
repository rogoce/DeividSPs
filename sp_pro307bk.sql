-- Informes de Detalle de Produccion por Grupo

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo

drop procedure sp_pro307;
create procedure "informix".sp_pro307(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_codagente		char(255)	default "*",
a_codusuario	char(255)	default "*",
a_codramo		char(255)	default "*",
a_reaseguro		char(255)	default "*",
a_tipopol		char(1)		default "1")
returning		char(255);

define v_filtros			char(255);
define v_desc_grupo			char(50);
define v_descr_cia			char(50);
define v_desc_nombre		char(35);
define v_nodocumento		char(20);
define v_cod_contratante	char(10);
define v_nofactura			char(10);
define v_nopoliza			char(10);
define _no_remesa			char(10);
define v_cod_usuario		char(8);
define v_cod_agente			char(5);
define v_cod_grupo			char(5);
define v_noendoso			char(5);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define v_cod_subramo		char(3);
define v_forma_pago			char(3);
define v_cod_ramo			char(3);
define s_tipopro			char(3);
define s_cia				char(3);
define _tipo_produccion		char(1);
define _filtro_ramo			char(1);
define _nueva_renov			char(1);
define _tipo				char(1);
define _porc_partic_agt		dec(5,2);
define v_porc_comis			dec(5,2);
define v_comision			dec(9,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define _tot_prima_sus		dec(16,2);
define v_prima_neta			dec(16,2);
define v_cant_pagos			smallint;
define v_estatus			smallint;
define _cnt_filtro			smallint;
define _renglon				integer;
define v_vigencia_inic		date;

set isolation to dirty read;

create temp table temp_det(
cod_sucursal	char(3),
cod_grupo		char(5),
cod_agente		char(5),
cod_usuario		char(8),
cod_ramo		char(3),
cod_subramo		char(3),
cod_tipoprod	char(3),
tipo_produccion	char(01),
no_poliza		char(10),
no_endoso		char(5),
no_factura		char(10),
no_documento	char(20),
cod_contratante	char(10),
estatus			smallint,
forma_pago		char(03),
cant_pagos		smallint,
suma_asegurada	dec(16,2),
prima			dec(16,2),
prima_neta		dec(16,2),
comision		dec(9,2),
vigencia_inic	date,
nueva_renov		char(1),
seleccionado	smallint default 1,
no_remesa		char(10),
renglon			integer) with no log;

create index id1_temp_det on temp_det(cod_sucursal);
create index id2_temp_det on temp_det(cod_grupo);
create index id3_temp_det on temp_det(cod_agente);
create index id4_temp_det on temp_det(cod_usuario);
create index id5_temp_det on temp_det(cod_ramo);
create index id6_temp_det on temp_det(cod_tipoprod);
create index id7_temp_det on temp_det(cod_contratante);

let v_cod_contratante = null;
let v_cod_agente      = null;
let s_tipopro         = null;
let v_estatus         = null;
let v_prima_suscrita  = 0;
let v_suma_asegurada  = 0;
let v_cant_pagos      = 0;
let v_comision        = 0;
let v_forma_pago      = " ";
let _filtro_ramo		= '';

let v_descr_cia = sp_sis01(a_compania);
let v_noendoso = '00000';
let v_cod_usuario = 'informix';
let v_filtros = '';

--Filtro por Ramo
if a_codramo <> "*" then
	let v_filtros = trim(v_filtros) ||"Ramo "|| trim(a_codramo);
	let _filtro_ramo = sp_sis04(a_codramo); -- separa los valores del string

	select *
	  from tmp_codigos
	  into temp tmp_ramos;

	drop table tmp_codigos;
end if

foreach
	select no_poliza,
		   no_recibo,
		   prima_neta,
		   fecha,
		   no_remesa,
		   renglon
	  into v_nopoliza,
		   v_nofactura,
		   v_prima_neta,
		   v_vigencia_inic,
		   _no_remesa,
		   _renglon
	  from cobredet
	 where periodo      >= a_periodo1
	   and periodo      <= a_periodo2
	   and tipo_mov     in ('P','N')
	   and actualizado  = 1

	select cod_grupo,
		   cod_ramo,
		   cod_formapag,
		   no_pagos,
		   estatus_poliza,
		   no_documento,
		   cod_tipoprod,
		   cod_contratante,
		   sucursal_origen,
		   nueva_renov,
		   cod_subramo
	  into v_cod_grupo,
		   v_cod_ramo,
		   v_forma_pago,
		   v_cant_pagos,
		   v_estatus,
		   v_nodocumento,
		   v_cod_tipoprod,
		   v_cod_contratante,
		   v_cod_sucursal,
		   _nueva_renov,
		   v_cod_subramo
	  from emipomae y
	 where no_poliza = v_nopoliza;

	if v_cod_ramo is null or v_cod_ramo = " "   then
		continue foreach;
	end if

	let _cnt_filtro = 0;

	if _filtro_ramo <> '' then
		select count(*)
		  into _cnt_filtro
		  from tmp_ramos
		 where codigo = v_cod_ramo;

		if _cnt_filtro is null then
			let _cnt_filtro = 0;
		end if

		if (_filtro_ramo = 'E' and _cnt_filtro > 0) or (_filtro_ramo <> 'E' and _cnt_filtro = 0) then
			continue foreach;
		end if
	end if

	--filtro por tipo de poliza
	if a_tipopol <> '1' then
		if a_tipopol = '2' then
			if _nueva_renov <> 'N' then
				continue foreach;
			end if
		elif a_tipopol = '3' then
			if _nueva_renov <> 'R' then
				continue foreach;
			end if
		end if
	end if

	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = v_cod_tipoprod;

	let v_cod_agente     = null;
	let v_porc_comis     = 0.00;
	let _porc_partic_agt = 100.00;
	let _tot_prima_sus   = v_prima_suscrita * _porc_partic_agt / 100;
	let v_comision       = _tot_prima_sus   * v_porc_comis / 100;

	insert into temp_det
	values(	v_cod_sucursal,
			v_cod_grupo,
			v_cod_agente,
			v_cod_usuario,
			v_cod_ramo,
			v_cod_subramo,
			v_cod_tipoprod,
			_tipo_produccion,
			v_nopoliza,
			v_noendoso,
			v_nofactura,
			v_nodocumento,
			v_cod_contratante,
			v_estatus,
			v_forma_pago,
			v_cant_pagos,
			v_suma_asegurada,
			_tot_prima_sus,
			v_prima_neta,
			v_comision,
			v_vigencia_inic,
			_nueva_renov,
			1,
			_no_remesa,
			_renglon);

	let v_forma_pago      = " ";
	let v_cant_pagos      = 0;
	let v_suma_asegurada  = 0;
end foreach

-- procesos v_filtros
let v_filtros ="";

--Filtro por Sucursal
if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

--Filtro por Grupo
if a_codgrupo <> "*" then
	let v_filtros = trim(v_filtros) ||"Grupo "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

--Filtro por Agente
if a_codagente <> "*" then
	let v_filtros = trim(v_filtros) ||"Agente "||trim(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string
	
	if _tipo <> "E" then -- incluir los registros

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

--Filtro por Usuario
if a_codusuario <> "*" then
	let v_filtros = trim(v_filtros) ||"Usuario "||trim(a_codusuario);
	let _tipo = sp_sis04(a_codusuario); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registroo

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_usuario not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_usuario in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

--filtro por reaseguro
if a_reaseguro = "*" then
	let v_filtros = trim(v_filtros) || " Con Reaseguro Asumido ";
end if

if a_reaseguro <> "*" then

	let _tipo = sp_sis04(a_reaseguro);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		let v_filtros = trim(v_filtros) || " Reaseguro Asumido: Solamente ";
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion not in (select codigo from tmp_codigos);

	else	-- excluir estos registros

		let v_filtros = trim(v_filtros) || " Reaseguro Asumido: Excluido ";
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

return v_filtros;   
end procedure;
