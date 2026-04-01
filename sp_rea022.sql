drop procedure sp_rea022;
create procedure "informix".sp_rea022(
a_cia		char(03),
a_agencia	char(3),
a_fecha		date,
a_serie		char(255)	default "*",
a_contrato	char(255)	default "*",
a_subramo	char(255)	default "*",
a_cliente	char(255)	default "*")
returning	char(45),
			char(255),
			char(50),
			char(50),
			integer,
			smallint,
			dec(16,2),
			dec(16,2),
			varchar(30);

--------------------------------------------
---       POLIZAS VIGENTES POR RAMO      --- SOLO TOTALES
---  Amado Perez - Abril 2001 - YMZM
---  Ref. Power Builder - d_sp_pro60
--------------------------------------------

define _ruc				varchar(30);
define v_filtros1		char(255);
define v_filtros		char(255);
define v_desc_agente	char(50);
define v_descr_cia		char(50);
define v_desc_ramo		char(50);
define v_subramo		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define no_documento		char(20);
define v_contratante	char(10);
define _no_factura		char(10);
define _no_poliza		char(10);
define v_codigo			char(10);
define _periodo			char(7);
define _cod_agente		char(5);
define _cod_subramo		char(3);
define v_cod_grupo		char(5);
define v_cod_sucursal	char(3);
define _cod_coasegur	char(3);
define v_cod_ramo		char(3);
define v_saber			char(2);
define _tipo			char(1);
define v_prima_suscrita	dec(16,2);
define v_suma_asegurada	dec(16,2);
define _porc_comis_agt	dec(16,2);
define v_prima_pagada	dec(16,2);
define _porcentaje		dec(16,2);
define _fronting		smallint;
define _bouquet			smallint;
define v_count			smallint;
define v_cant_polizas	integer;
define _edadpol			integer;
define v_vigencia_inic	date;
define v_vigencia_final	date;

let v_cod_sucursal		= null;
let v_contratante		= null;
let no_documento		= null;
let v_cod_grupo			= null;
let v_desc_ramo			= null;
let v_descr_cia			= null;
let v_cod_ramo			= null;
let _ruc				= null;
let _tipo				= null;
let v_cant_polizas		= 0;
let v_prima_suscrita	= 0;
let _bouquet			= 0;	 

create temp table tmp_reat(
cod_ramo		char(3),
desc_ramo		char(50),
documento		char(20), 
asegurado		char(45), 
suma_asegurada	dec(16,2),
prima_suscrita	dec(16,2),
filtros			char(255),
descr_cia		char(50),
subramo			char(50),
vigencia_i		date,
vigencia_f		date,
edadpol			integer	default 0,
ruc				varchar(30)) with no log;
create index i_tmp_reat1 on tmp_reat(cod_ramo);
create index i_tmp_reat2 on tmp_reat(documento);
create index i_tmp_reat3 on tmp_reat(asegurado);
create index i_tmp_reat4 on tmp_reat(suma_asegurada);
create index i_tmp_reat5 on tmp_reat(prima_suscrita);
create index i_tmp_reat6 on tmp_reat(subramo);
create index i_tmp_reat7 on tmp_reat(vigencia_i);
create index i_tmp_reat8 on tmp_reat(vigencia_f);

--edadpol			 INTEGER,
--PRIMARY KEY (cod_ramo,desc_ramo,documento,asegurado,suma_asegurada,prima_suscrita,subramo,vigencia_i,vigencia_f)) WITH NO LOG;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_cia;

let v_descr_cia = sp_sis01(a_cia);
let v_filtros1 = "";
--    call sp_rea21a(a_cia,a_agencia,a_fecha,"008;",a_serie,a_contrato) returning v_filtros; -- solo fianzas
call sp_rea21b(a_cia,a_agencia,"001",a_fecha,"008;",a_serie,a_contrato) returning v_filtros; -- Solo Fianzas

-- Adicionar filtro cliente y subramo
-- Filtro por Contrato

if a_cliente <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Asegurado "||trim(a_cliente);
	let _tipo = sp_sis04(a_cliente); -- separa los valores del string

	if _tipo <> "E" then -- Incluir los Registros
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

if a_subramo <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Subramos "||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- Separa los valores del String

	if _tipo <> "E" then -- incluir los registros
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

let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros);

set isolation to dirty read;

--set debug file to "sp_rea022.trc";
--trace on;

foreach with hold
	select y.no_documento,
		   y.cod_ramo,
		   y.cod_contratante,
		   y.vigencia_inic,
		   y.cod_subramo,
		   y.vigencia_final,
		   y.cod_grupo,
		   y.suma_asegurada,
		   y.prima_suscrita,
		   y.cod_agente,
		   y.no_poliza,
		   y.no_factura,
		   y.bouquet
	  into no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   _cod_subramo,
		   v_vigencia_final,
		   v_cod_grupo,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   _cod_agente,
		   _no_poliza,
		   _no_factura,
		   _bouquet
	  from temp_perfil y
	 where y.seleccionado = 1
	 order by y.cod_ramo,y.cod_subramo,y.no_documento

	if _bouquet = 0 then
		continue foreach;
	end if

	select fronting,
		   periodo
	  into _fronting,
		   _periodo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fronting = 1 then
		continue foreach;
	end if

	select a.nombre
	  into v_desc_ramo
	  from prdramo a
	 where a.cod_ramo  = v_cod_ramo;

	select nombre 
	  into v_subramo
	  from prdsubra
	 where cod_ramo = v_cod_ramo
	   and cod_subramo = _cod_subramo;

	select porc_comis_agt
	  into _porc_comis_agt
	  from emipoagt
	 where cod_agente = _cod_agente
	   and no_poliza  = _no_poliza;

	select nombre,cedula
	  into v_asegurado,_ruc
	  from cliclien
	 where cod_cliente = v_contratante;

	select nombre
	  into v_desc_grupo
	  from cligrupo
	 where cod_grupo = v_cod_grupo;

	let _edadpol = v_vigencia_final - v_vigencia_inic ;

	insert into tmp_reat(
			cod_ramo,		
			desc_ramo,		
			documento,		
			asegurado,		
			suma_asegurada,
			prima_suscrita,
			filtros,			
			descr_cia,		
			subramo,			
			vigencia_i,		
			vigencia_f,
			edadpol,
			ruc)
	values	(v_cod_ramo,			   
			v_desc_ramo,
			no_documento,
			v_asegurado,
			v_suma_asegurada,
			v_prima_suscrita,
			v_filtros,
			v_descr_cia,
			v_subramo,
			v_vigencia_inic,
			v_vigencia_final,
			_edadpol,
			_ruc);
end foreach

foreach 
	select asegurado,
		   filtros,
		   descr_cia,		
		   subramo,		
		   edadpol,
		   ruc,		
		   count(documento),	
		   sum(suma_asegurada),
		   sum(prima_suscrita)				   		
	  into v_asegurado,
	       v_filtros,
		   v_descr_cia,
		   v_subramo,
		   _edadpol,
	       _ruc,
		   v_count,
		   v_suma_asegurada,
		   v_prima_suscrita
	  from tmp_reat
	 group by 4,1,5,2,3,6
	 order by 4,1,2,3,5 

	return v_asegurado,
		   v_filtros,
		   v_descr_cia,
		   v_subramo,
		   _edadpol,
		   v_count,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   _ruc
	with resume;
end foreach

drop table temp_perfil;
drop table tmp_reat;

end procedure;
