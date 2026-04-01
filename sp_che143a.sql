-- Informes de Detalle de Devolución de Cheques
-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 12/09/2013 - Autor: Román Gordón

drop procedure sp_che143a;

create procedure "informix".sp_che143a(
a_compania     char(03),
a_agencia      char(03),
a_periodo1     char(07),
a_periodo2     char(07),
a_codsucursal  char(255) default "*",
a_codgrupo     char(255) default "*",
a_codagente    char(255) default "*",
a_codusuario   char(255) default "*",
a_codramo      char(255) default "*",
a_reaseguro    char(255) default "*",
a_tipopol      char(1)   default "1"
) returning    char(255);

define _filtros			char(255);
define _no_documento	char(20);
define _cod_contratante	char(10);
define _no_requis		char(10);
define _no_poliza		char(10);
define _usuario			char(8);
define _cod_agente		char(5);
define _no_endoso		char(5);
define _cod_grupo		char(5);
define _cod_formapag	char(3);
define _cod_tipoprod	char(3);
define _cod_sucursal	char(3);
define _cod_subramo		char(3);
define _cod_ramo		char(3);
define _tipo_produccion	char(1);
define _nueva_renov		char(1);
define _tipo			char(1);
define _porc_partic_agt	dec(5,2);
define _porc_comis_agt	dec(5,2);
define _comision		dec(9,2);
define _prima_suscrita	dec(16,2);
define _suma_asegurada	dec(16,2);
define _tot_prima_sus	dec(16,2);
define _prima_neta		dec(16,2);
define _status_poliza	smallint;
define _cant_pagos		smallint;
define _vigencia_inic	date;

define _porc_partic_coas    dec(7,4);
define _cod_lider			char(3);

define _fecha_inic		date;
define _fecha_fin		date;

set isolation to dirty read;

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";


create temp table temp_det
   (cod_sucursal     char(3),
	cod_grupo        char(5),
	cod_agente       char(5),
	cod_usuario      char(8),
	cod_ramo         char(3),
	cod_subramo      char(3),
	cod_tipoprod     char(3),
	tipo_produccion  char(01),
	no_poliza        char(10),
	no_endoso        char(5),
	no_factura       char(10),
	no_documento     char(20),
	cod_contratante  char(10),
	estatus          smallint,
	forma_pago       char(03),
	cant_pagos       smallint,
	suma_asegurada   dec(16,2),
	prima            dec(16,2),
	prima_neta       dec(16,2),
	comision         dec(9,2),
	vigencia_inic    date,
	nueva_renov		 char(1),
	seleccionado     smallint default 1) with no log;

create index id1_temp_det on temp_det(cod_sucursal);
create index id2_temp_det on temp_det(cod_grupo);
create index id3_temp_det on temp_det(cod_agente);
create index id4_temp_det on temp_det(cod_usuario);
create index id5_temp_det on temp_det(cod_ramo);
create index id6_temp_det on temp_det(cod_tipoprod);
create index id7_temp_det on temp_det(cod_contratante);

let _prima_suscrita  = 0;
let _suma_asegurada  = 0;
let _cant_pagos      = 0;
let _status_poliza   = null;
let _comision        = 0;
let _cod_agente      = null;
let _cod_contratante = null;
let _cod_formapag    = " ";
let _cant_pagos      = 0;

let _fecha_inic      = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]); 
let _fecha_fin       = sp_sis36(a_periodo2);

-- Cheques Pagados
--{
foreach
	select "00000",
		   no_requis,
		   0.00,
		   0.00,
		   "informix",
		   fecha_impresion
	  into _no_endoso,
		   _no_requis,
		   _prima_suscrita,
		   _suma_asegurada,
		   _usuario,
		   _vigencia_inic
	  from chqchmae
	 where origen_cheque	= '6'
	   and fecha_impresion  >= _fecha_inic
	   and fecha_impresion	<= _fecha_fin
	   and pagado			= 1
	   
	foreach
		select no_poliza,
			   prima_neta
		  into _no_poliza,
			   _prima_neta
		  from chqchpol
		 where no_requis = _no_requis
		   
		select y.cod_grupo,
			   y.cod_ramo,
			   y.cod_formapag,
			   y.no_pagos,
			   y.estatus_poliza,
			   y.no_documento,
			   y.cod_tipoprod,
			   y.cod_contratante,
			   y.sucursal_origen,
			   y.nueva_renov,
			   y.cod_subramo
		  into _cod_grupo,
			   _cod_ramo,
			   _cod_formapag,
			   _cant_pagos,
			   _status_poliza,
			   _no_documento,
			   _cod_tipoprod,
			   _cod_contratante,
			   _cod_sucursal,
			   _nueva_renov,
			   _cod_subramo
		  from emipomae y
		 where y.no_poliza = _no_poliza;

		if _cod_ramo is null or _cod_ramo = " "   then
			continue foreach;
		end if;

		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;

		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_lider;
		
		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let _prima_suscrita = _prima_neta;

		let _cod_agente			= null;
		let _porc_partic_agt	= 100.00;
		let _porc_comis_agt		= 0.00;
		let _tot_prima_sus		= _prima_suscrita * _porc_partic_agt / 100;
		let _comision			= _tot_prima_sus   * _porc_comis_agt / 100;

		insert into temp_det
		values	(_cod_sucursal,
				_cod_grupo,
				_cod_agente,
				_usuario,
				_cod_ramo,
				_cod_subramo,
				_cod_tipoprod,
				_tipo_produccion,
				_no_poliza,
				_no_endoso,
				_no_requis,
				_no_documento,
				_cod_contratante,
				_status_poliza,
				_cod_formapag,
				_cant_pagos,
				_suma_asegurada,
				_tot_prima_sus,
				_prima_neta,
				_comision,
				_vigencia_inic,
				_nueva_renov,
				1);

		let _cod_formapag      = " ";
		let _cant_pagos      = 0;
		let _suma_asegurada  = 0;
	end foreach
end foreach
--}

-- Cheques Anulados

foreach
	select "00000",
		   no_requis,
		   0.00,
		   0.00,
		   "informix",
		   fecha_anulado
	  into _no_endoso,
		   _no_requis,
		   _prima_suscrita,
		   _suma_asegurada,
		   _usuario,
		   _vigencia_inic
	  from chqchmae
	 where origen_cheque	= '6'
	   and fecha_anulado    >= _fecha_inic
	   and fecha_anulado	<= _fecha_fin
	   and pagado			= 1
	   and anulado          = 1
	   
	foreach
		select no_poliza,
			   prima_neta
		  into _no_poliza,
			   _prima_neta
		  from chqchpol
		 where no_requis = _no_requis
		   
		select y.cod_grupo,
			   y.cod_ramo,
			   y.cod_formapag,
			   y.no_pagos,
			   y.estatus_poliza,
			   y.no_documento,
			   y.cod_tipoprod,
			   y.cod_contratante,
			   y.sucursal_origen,
			   y.nueva_renov,
			   y.cod_subramo
		  into _cod_grupo,
			   _cod_ramo,
			   _cod_formapag,
			   _cant_pagos,
			   _status_poliza,
			   _no_documento,
			   _cod_tipoprod,
			   _cod_contratante,
			   _cod_sucursal,
			   _nueva_renov,
			   _cod_subramo
		  from emipomae y
		 where y.no_poliza = _no_poliza;

		if _cod_ramo is null or _cod_ramo = " "   then
			continue foreach;
		end if;

		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;

		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_lider;
		
		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let _prima_suscrita = _prima_neta * -1;

		let _cod_agente			= null;
		let _porc_partic_agt	= 100.00;
		let _porc_comis_agt		= 0.00;
		let _tot_prima_sus		= _prima_suscrita * _porc_partic_agt / 100;
		let _comision			= _tot_prima_sus   * _porc_comis_agt / 100;

		insert into temp_det
		values	(_cod_sucursal,
				_cod_grupo,
				_cod_agente,
				_usuario,
				_cod_ramo,
				_cod_subramo,
				_cod_tipoprod,
				_tipo_produccion,
				_no_poliza,
				_no_endoso,
				_no_requis,
				_no_documento,
				_cod_contratante,
				_status_poliza,
				_cod_formapag,
				_cant_pagos,
				_suma_asegurada,
				_tot_prima_sus,
				_prima_neta,
				_comision,
				_vigencia_inic,
				_nueva_renov,
				1);

		let _cod_formapag      = " ";
		let _cant_pagos      = 0;
		let _suma_asegurada  = 0;
	end foreach
end foreach

-- Procesos _filtros
let _filtros = "";

--Filtro por Sucursal
if a_codsucursal <> "*" then
	let _filtros = TRIM(_filtros) ||"Sucursal "||trim(a_codsucursal);
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

--filtro por grupo
if a_codgrupo <> "*" then
	let _filtros = trim(_filtros) ||"Grupo "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
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

--filtro por agente
if a_codagente <> "*" then
	let _filtros = trim(_filtros) || "Agente "||trim(a_codagente);
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

--filtro por usuario
if a_codusuario <> "*" then
	let _filtros = trim(_filtros) ||"Usuario "||trim(a_codusuario);
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

--filtro por ramo
if a_codramo <> "*" then
	let _filtros = trim(_filtros) ||"Ramo "||trim(a_codramo);
	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
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
	drop table tmp_codigos;
end if

--filtro por reaseguro
if a_reaseguro = "*" then
	let _filtros = trim(_filtros) || " Con Reaseguro Asumido ";
end if
 
if a_reaseguro <> "*" then
	let _tipo = sp_sis04(a_reaseguro);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" THEN -- Incluir los Registros
		let _filtros = trim(_filtros) || " Reaseguro Asumido: Solamente ";
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		let _filtros = trim(_filtros) || " Reaseguro Asumido: Excluido ";
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion in (select codigo from tmp_codigos);
	end if
drop table tmp_codigos;
end if

--Filtro por Tipo de Poliza
if a_tipopol <> '1' then
	if a_tipopol = '2' then

		let _filtros = trim(_filtros) || " Polizas Nuevas ";
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and nueva_renov not in ('N');

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso not in ('00000');
	elif a_tipopol = '3' then	
		let _filtros = trim(_filtros) || " Polizas Renovadas ";
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and nueva_renov not in ('R');

		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso not in ('00000');
	else	 
		let _filtros = trim(_filtros) || " Polizas Endosos ";
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_endoso in ('00000');
	end if
end if

return _filtros;
   
end procedure;
