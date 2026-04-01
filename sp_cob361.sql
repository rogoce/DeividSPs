-- Detalle de pólizas Anuladas Nva. Ley.
-- Creado:       22/04/2015  - Autor:  Armando Moreno M.
-- Modificado: 22/04/2015  - Autor:  Armando Moreno M.
-- Modificado: 24/06/2015  - Autor:  Román Gordón	--Agregar al Usuario que hizo la gestión

drop procedure sp_cob361;
create procedure sp_cob361(
a_cia			char(3),
a_agencia		char(3),
a_codramo		varchar(255)	default "*",
a_periodo		char(7),
a_periodo2		char(7),
a_no_documento	varchar(255)	default "*",
a_agente		varchar(255)	default "*")
returning	varchar(50),
			char(20),
			varchar(50),
			char(3),
			varchar(50),
			char(3),
			varchar(50),
			char(3),
			varchar(50),
			char(3),
			varchar(50),
			char(5),
			varchar(50),
			char(3),
			varchar(50),
			smallint,
			smallint,
			date,
			date,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(5),
			varchar(50),
			varchar(100),
			date,
			dec(16,2),
			char(3),
			varchar(50),
			date,
			varchar(50);
begin

define _error_desc		varchar(100);
define _filtros			varchar(100);
define _nom_div_cob		varchar(50);
define _zona_cobros		varchar(50);
define _n_formapag		varchar(50);
define _nom_agente		varchar(50);
define _n_acreedor		varchar(50);
define _n_sucursal		varchar(50);
define _descr_cia		varchar(50);
define _nom_grupo		varchar(50);
define _n_subramo		varchar(50);
define _n_gestion		varchar(50);
define _nom_ramo		varchar(50);
define _nom_cliente		varchar(45);
define _nom_cobrador	varchar(50);
define _no_documento	char(20);
define _cod_contratante	char(10);
define _cod_campana		char(10);
define _no_poliza		char(10);
define _usuario			char(8);
define _periodo			char(7);
define _cod_acreedor	char(5);
define _cod_agente		char(5);
define v_codigo			char(5);
define _cod_sucursal	char(3);
define _cod_cobrador	char(3);
define _cod_formapag	char(3);
define _cod_gestion		char(3);
define _cod_subramo		char(3);
define _cod_zona		char(3);
define _cod_ramo		char(3);
define _anula			char(3);
define _cancela			char(3);
define v_saber			char(2);
define _cod_div_cob		char(1);
define _tipo			char(1);
define _porc_partic_agt	dec(5,2);
define _monto_promesa	dec(16,2);
define _prima_bruta		dec(16,2);
define _saldo_total		dec(16,2);
define _corriente		dec(16,2);
define _por_vencer		dec(16,2);
define _monto_180		dec(16,2);
define _monto_150		dec(16,2);
define _monto_120		dec(16,2);
define _monto_90		dec(16,2);
define _monto_60		dec(16,2);
define _monto_30		dec(16,2);
define _exigible		dec(16,2);
define _estatus_poliza	smallint;
define _cnt_caspoliza	smallint;
define _cnt_ajuste		smallint;
define _leasing			smallint;
define _no_pagos		smallint;
define _error			smallint;
define  _fecha_ult_pro	date;
define _fecha_promesa	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define _vig_fin			date;
define _vig_ini			date;
define _fecha			date;
	
--set debug file to "sp_cob361.trc";
--trace on;

create temp table tmp_cancela(
no_documento		char(20),
cod_ramo			char(3),
cod_subramo			char(3),
cod_sucursal		char(3),
cod_contratante		char(10),
prima_bruta			dec(16,2),
no_poliza			char(10),
vig_ini				date,
vig_fin				date,
cod_agente			char(5),
seleccionado		smallint default 1,
cod_formapag		char(3),
cod_zona			char(3),
nombre_zona			varchar(50),
estatus_poliza		smallint,
no_pagos			smallint,
cod_motiv			char(3),
cod_acreedor		char(5),
n_agente			varchar(50),
cod_campana			char(10),
fecha_promesa		date,
monto_promesa		dec(16,2),
cod_gestion			char(3),
fecha_ult_pro		date,
cod_cobrador		char(3));

create index i_cancela1 on tmp_cancela(cod_ramo);
create index i_cancela2 on tmp_cancela(cod_sucursal);
create index i_cancela3 on tmp_cancela(cod_subramo);
--   create index i_cancela5 on tmp_cancela(cod_contratante);

let _prima_bruta = 0;
let _por_vencer = 0;
let _corriente = 0;
let _exigible = 0;
let _monto_30 = 0;
let _monto_60 = 0;
let _nom_cliente = null;
let _n_acreedor = null;
let _nom_agente = null;
let _descr_cia = null;
let _nom_ramo = null;
let _filtros = null;

let _fecha_desde = sp_sis36bk(a_periodo); --trae 01, mes y año
let _fecha_hasta = sp_sis36(a_periodo2);  --trae ultimo dia del mes, mes y año
let _descr_cia = sp_sis01(a_cia);
let _fecha = sp_sis36(a_periodo2);  --trae ultimo dia del mes, mes y año

set isolation to dirty read;

--falta excluir los registros con gestion de anular de este reporte
foreach
	select cod_campana
	  into _cod_campana
	  from cascampana 
	 where tipo_campana = 3
	 
	foreach	 
		select cod_cliente,
			   fecha_promesa,
			   monto_promesa,
			   cod_gestion,
			   fecha_ult_pro,
			   cod_cobrador
		  into _cod_contratante,
			   _fecha_promesa,
			   _monto_promesa,
			   _cod_gestion,
			   _fecha_ult_pro,
			   _cod_cobrador
		  from cascliente
		 where cod_campana = _cod_campana
  		   and cod_gestion is not null
		   and fecha_ult_pro >= _fecha_desde
		   and fecha_ult_pro <= _fecha_hasta

		select anula,
			   cancela
		  into _anula,
			   _cancela
		  from cobcages
		 where cod_gestion = _cod_gestion;

		if _anula is null then
			let _anula = '';
		end if

		if _cancela is null then
			let _cancela = '';
		end if

		if _anula <> '' or _cancela <> '' then
			continue foreach;
		end if

		let _cod_acreedor = null;

		foreach
			select no_documento
			  into _no_documento
			  from caspoliza
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_contratante


		    let _no_poliza = sp_sis21(_no_documento);			   

			foreach
				select x.cod_acreedor
				  into _cod_acreedor
				  from emipoacr x, emipouni e
				 where x.no_poliza = e.no_poliza
				   and x.no_unidad = e.no_unidad
				   and e.no_poliza = _no_poliza
				 exit foreach;
			end foreach

			select cod_ramo,
				   cod_subramo,
				   cod_sucursal,
				   prima_bruta,
				   vigencia_inic,
				   vigencia_final,
				   cod_formapag,
				   estatus_poliza,
				   no_pagos
			  into _cod_ramo,
				   _cod_subramo,
				   _cod_sucursal,
				   _prima_bruta,
				   _vig_ini,
				   _vig_fin,
				   _cod_formapag,
				   _estatus_poliza,
				   _no_pagos
			  from emipomae
			 where no_poliza = _no_poliza;

			if _estatus_poliza in (2,4) then
				continue foreach;
			end if

			call sp_cob346a(_no_documento) returning _error,_error_desc;

			let _cnt_ajuste = 0;

			select count(*)
			  into _cnt_ajuste 
			  from emiletra
			 where no_documento = _no_documento
			   and no_letra = 1
			   and pagada = 0;

			if _cnt_ajuste is null then
				let _cnt_ajuste = 0;
			end if

			if _cnt_ajuste = 0 then
				select count(*)
				  into _cnt_caspoliza
				  from caspoliza
				 where cod_campana = _cod_campana
				   and cod_cliente = _cod_contratante
				   and no_documento <> _no_documento;

				if _cnt_caspoliza is null then
					let _cnt_caspoliza = 0;
				end if

				if _cnt_caspoliza > 0 then
					delete from caspoliza
					 where cod_cliente = _cod_contratante
					   and no_documento = _no_documento
					   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3);
				else
					delete from caspoliza
					 where cod_cliente = _cod_contratante
					   and no_documento = _no_documento
					   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3);

					delete from cascliente
					 where cod_cliente = _cod_contratante
					   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3);
				end if

				continue foreach;
			end if
			
			call sp_cob116(_no_poliza)
			returning	_cod_agente,
						_nom_agente,
						_cod_zona,
						_zona_cobros,
						_leasing,
						_cod_div_cob,
						_nom_div_cob;

			if _cod_acreedor is null then
				let _cod_acreedor = '';
			end if	

			insert into tmp_cancela
			values(	_no_documento,        
					_cod_ramo,
					_cod_subramo,
					_cod_sucursal,
					_cod_contratante,
					_prima_bruta,
					_no_poliza,
					_vig_ini,
					_vig_fin,
					_cod_agente,
					1,
					_cod_formapag,
					_cod_zona,
					_zona_cobros,
					_estatus_poliza,
					_no_pagos,
					null,
					_cod_acreedor,
					_nom_agente,
					_cod_campana,
					_fecha_promesa,
					_monto_promesa,
					_cod_gestion,
					_fecha_ult_pro,
					_cod_cobrador);
	    end foreach		
	end foreach
end foreach

-- Filtro de Ramo
if a_codramo <> "*" then
	let _filtros = trim(_filtros) ||"Ramo "||trim(a_codramo);
	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update tmp_cancela
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in(select codigo from tmp_codigos);
	else
		update tmp_cancela
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

--Filtro de poliza
if a_no_documento not in ('*','') then
	let _filtros = trim(_filtros) ||"Documento: "|| trim(a_no_documento);

	update tmp_cancela
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_documento <> a_no_documento;
end if

--Filtro de corredor
if a_agente <> "*" then

	let _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos
	let _filtros = trim(_filtros) || " Corredor: "; --||  trim(a_agente);

	if _tipo <> "E" then -- Incluir los Registros
		update tmp_cancela
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in (select codigo from tmp_codigos);
		let v_saber = "";
	else		        -- Excluir estos Registros
		update tmp_cancela
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in (select codigo from tmp_codigos);
		   let v_saber = " Ex";
	end if

	foreach
		select agtagent.nombre,tmp_codigos.codigo
		  into _nom_agente,v_codigo
		  from agtagent,tmp_codigos
		 where agtagent.cod_agente = codigo
		 let _filtros = trim(_filtros) || " " || trim(v_codigo) || " " || trim(_nom_agente) || (v_saber);
	end foreach

	drop table tmp_codigos;
end if

foreach
	select no_documento,
		   cod_acreedor,
		   cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   prima_bruta,
		   no_poliza,
		   vig_ini,
		   vig_fin,
		   cod_agente,
		   n_agente,
		   cod_formapag,
		   cod_zona,
		   nombre_zona,
		   estatus_poliza,
		   cod_sucursal,
		   no_pagos,
		   cod_campana,
		   fecha_promesa,
		   monto_promesa,
		   cod_gestion,
		   fecha_ult_pro,
		   cod_cobrador
	  into _no_documento,
		   _cod_acreedor,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _prima_bruta,
		   _no_poliza,
		   _vig_ini,
		   _vig_fin,
		   _cod_agente,
		   _nom_agente,
		   _cod_formapag,
		   _cod_zona,
		   _zona_cobros,
		   _estatus_poliza,
		   _cod_sucursal,
		   _no_pagos,
		   _cod_campana,
		   _fecha_promesa,
		   _monto_promesa,
		   _cod_gestion,
		   _fecha_ult_pro,
		   _cod_cobrador
	  from tmp_cancela
	 where seleccionado = 1
	 order by cod_ramo,no_documento

	--Asegurado
	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	--Ramo
	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _n_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;		

	let _n_acreedor = null;	
	select nombre
	  into _n_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;

	select nombre
	  into _n_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select descripcion
	  into _n_sucursal
	  from insagen
	 where codigo_agencia = _cod_sucursal;

	select nombre
	  into _n_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	select usuario
	  into _usuario
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select upper(descripcion)
	  into _nom_cobrador
	  from insuser
	 where usuario = _usuario;

	call sp_cob245a("001","001",_no_documento,a_periodo2,_fecha)
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo_total;

	return	_descr_cia,
			_no_documento,
			_nom_cliente,
			_cod_ramo,
			_nom_ramo,
			_cod_subramo,
			_n_subramo,
			_cod_formapag,
			_n_formapag,
			_cod_zona,
			_zona_cobros,
			_cod_agente,
			_nom_agente,
			_cod_sucursal,
			_n_sucursal,
			_estatus_poliza,
			_no_pagos,
			_vig_ini,
			_vig_fin,			  
			_prima_bruta,
			_por_vencer,      
			_exigible,         
			_corriente,        
			_monto_30,         
			_monto_60,         
			_monto_90,
			_saldo_total,
			_cod_acreedor,
			_n_acreedor,
			_filtros,
			_fecha_promesa,
			_monto_promesa,
			_cod_gestion,
			_n_gestion,
			_fecha_ult_pro,
			_nom_cobrador with resume;
end foreach
drop table tmp_cancela;
end
end procedure;