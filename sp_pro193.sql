-- informes de detalle de produccion por grupo

-- sis v.2.0 - deivid, s.a.
-- creado    : 22/10/2000 - autor: yinia m. zamora.
-- modificado: 05/09/2001 - autor: amado perez -- inclusion del campo subramo

--drop procedure sp_pro193;

create procedure 'informix'.sp_pro193(
a_compania		char(03),
a_agencia		char(03),
a_fecha1		date,
a_fecha2		date,
a_codsucursal	char(255) default '*',
a_codgrupo		char(255) default '*',
a_codagente		char(255) default '*',
a_codusuario	char(255) default '*',
a_codramo		char(255) default '*',
a_reaseguro		char(255) default '*',
a_tipopol		char(1)   default '1')
returning	char(255);

define v_filtros			char(255);
define v_desc_grupo			char(50);
define v_descr_cia			char(50);
define v_desc_nombre		char(35);
define v_nodocumento		char(20);
define v_cod_contratante	char(10);
define v_nofactura          char(10);
define v_nopoliza			char(10);
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
define _nueva_renov			char(1);
define _tipo				char(1);
define _porc_partic_agt		dec(5,2);
define v_comision			dec(9,2);
define v_porc_comis			dec(5,2);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define _tot_prima_sus		dec(16,2);
define v_prima_neta			dec(16,2);
define v_cant_pagos			smallint;
define v_estatus			smallint;
define v_vigencia_inic		date;

set isolation to dirty read;

create temp table temp_det(
cod_sucursal		char(3),
cod_grupo			char(5),
cod_agente			char(5),
cod_usuario			char(8),
cod_ramo			char(3),
cod_subramo			char(3),
cod_tipoprod		char(3),
tipo_produccion		char(1),
no_poliza			char(10),
no_endoso			char(5),
no_factura			char(10),
no_documento		char(20),
cod_contratante		char(10),
estatus				smallint,
forma_pago			char(3),
cant_pagos			smallint,
suma_asegurada		dec(16,2),
prima				dec(16,2),
prima_neta			dec(16,2),
comision			dec(9,2),
vigencia_inic		date,
nueva_renov			char(1),
prima_sus_tot		dec(16,2),
porc_comis_agt		dec(5,2),
seleccionado		smallint default 1) with no log;

create index id1_temp_det on temp_det(cod_sucursal);
create index id2_temp_det on temp_det(cod_grupo);
create index id3_temp_det on temp_det(cod_agente);
create index id4_temp_det on temp_det(cod_usuario);
create index id5_temp_det on temp_det(cod_ramo);
create index id6_temp_det on temp_det(cod_tipoprod);
create index id7_temp_det on temp_det(cod_contratante);

let v_forma_pago = ' ';
let v_cod_contratante = null;
let v_cod_agente = null;
let s_tipopro = null;
let v_estatus = null;
let v_prima_suscrita = 0;
let v_suma_asegurada = 0;
let v_cant_pagos = 0;
let v_comision = 0;
let v_cant_pagos = 0;

let v_descr_cia = sp_sis01(a_compania);

foreach
	select no_poliza,
		   no_endoso,
		   no_factura,
		   prima_suscrita,
		   prima_neta,
		   suma_asegurada,
		   user_added,
		   vigencia_inic
	  into v_nopoliza,
		   v_noendoso,
		   v_nofactura,
		   v_prima_suscrita,
		   v_prima_neta,
		   v_suma_asegurada,
		   v_cod_usuario,
		   v_vigencia_inic
	  from endedmae
	 where fecha_emision between a_fecha1 and a_fecha2 
	   and actualizado  = 1
	   and cod_compania = a_compania

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
	  from emipomae
	 where no_poliza = v_nopoliza
	   and cod_compania = a_compania
	   and actualizado = 1;

	if v_cod_ramo is null or v_cod_ramo = ''   then
		continue foreach;
	end if;

	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = v_cod_tipoprod;

	let _tot_prima_sus = 0.00;
	let v_comision = 0;

	foreach
		select cod_agente,
			   porc_comis_agt,
			   porc_partic_agt
		  into v_cod_agente,
			   v_porc_comis,
			   _porc_partic_agt
		  from endmoage
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso

		if v_porc_comis is null then
			let v_porc_comis = 0.00;
		end if

		let _tot_prima_sus = v_prima_suscrita * _porc_partic_agt / 100;
		let v_comision     = _tot_prima_sus   * v_porc_comis / 100;

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
				_tot_prima_sus,
				_porc_partic_agt,
				1);
	end foreach;

	let v_forma_pago      = '';
	let v_cant_pagos      = 0;
	let v_suma_asegurada  = 0;
end foreach

-- procesos v_filtros
let v_filtros ='';

--filtro por sucursal
if a_codsucursal <> '*' then
	let v_filtros = trim(v_filtros) ||'sucursal '||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros

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
	drop table if exists tmp_codigos;
end if

--filtro por grupo
if a_codgrupo <> '*' then
	let v_filtros = trim(v_filtros) ||'grupo '||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
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
	drop table if exists tmp_codigos;
end if

--filtro por agente
if a_codagente <> '*' then
	let v_filtros = trim(v_filtros) ||'agente '||trim(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
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
	drop table if exists tmp_codigos;
end if

--filtro por usuario
if a_codusuario <> '*' then
	let v_filtros = trim(v_filtros) ||'usuario '||trim(a_codusuario);
	let _tipo = sp_sis04(a_codusuario); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registroo

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
	drop table if exists tmp_codigos;
end if

--filtro por ramo
if a_codramo <> '*' then
	let v_filtros = trim(v_filtros) ||'ramo '||trim(a_codramo);
	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in(select codigo from tmp_codigos);
	end if
	drop table if exists tmp_codigos;
end if

--filtro por reaseguro
if a_reaseguro = '*' then
	let v_filtros = trim(v_filtros) || ' con reaseguro asumido ';
end if

if a_reaseguro <> '*' then
	let _tipo = sp_sis04(a_reaseguro);  -- separa los valores del string en una tabla de codigos

	if _tipo <> 'E' then -- incluir los registros
		let v_filtros = trim(v_filtros) || ' reaseguro asumido: solamente ';
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		let v_filtros = trim(v_filtros) || ' reaseguro asumido: excluido ';

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion in (select codigo from tmp_codigos);
	end if

	drop table if exists tmp_codigos;
end if

--filtro por tipo de poliza
if a_tipopol <> '1' then
	if a_tipopol = '2' then
		let v_filtros = trim(v_filtros) || ' polizas nuevas ';

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and nueva_renov not in ('N');

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso not in ('00000');
	elif a_tipopol = '3' then

		let v_filtros = trim(v_filtros) || ' polizas renovadas ';

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and nueva_renov not in ('R');

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso not in ('00000');
	else
		let v_filtros = trim(v_filtros) || ' polizas endosos ';

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso in ('00000');
	end if
end if

return v_filtros;

end procedure;