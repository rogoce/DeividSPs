--  COASEGURO CEDIDO POR COMPANIA       ---
--  Yinia M. Zamora - octubre 2000 - YMZM

-- Modificado por: Marquelda Valdelamar 28/08/2001 Para incluir filtro de cliente
-- Modificado por: Marquelda Valdelamar 06/09/2001 Para filtro de poliza

-- Modificado por: Demetrio Hurtado Almanza 22/09/2004 Usar la Tabla endcoama

-- Modificado por: Demetrio Hurtado Almanza 03/02/2006 
                   -- Se cambio el programa para que utilice los datos de prima de la Tabla endcoama
-- 
-- Modificado por: Henry Girón 5/09/2016 Se adiciona TipoProd(1-Mayor,3-Menor)

drop procedure sp_pro41a;
create procedure "informix".sp_pro41a(
a_compania 		char(3),
a_agencia 		char(3),
a_periodo1 		char(7),
a_periodo2 		char(7),
a_codsucursal 	char(255) default "*",
a_codramo 		char(255) default "*",
a_codcoasegur 	char(255) default "*", 
a_cod_cliente 	char(255) default "*", 
a_no_documento 	char(255) default "*",
a_tipoprod      smallint) 
returning	char(3)			as cod_coasegur,
			varchar(50)		as nom_coasegur,
			char(10)		as factura,
			char(20)		as poliza,
            varchar(100)	as contratante,
            dec(7,2)		as partic_ancon,
            dec(16,2)		as prima_neta,
            dec(16,2)		as suma_asegurada,
            dec(6,2)		as impuesto_5,
            dec(6,2)		as impuesto_1,
            dec(16,2)		as prima_total,
            dec(5,2)		as porc_gastos,
            varchar(50)		as compania,
            varchar(255)	as filtros,
			date			as vigencia_inic,
			date			as vigencia_final,
			varchar(50)		as corredor;

begin

define v_filtros			varchar(255);
define v_desc_nombre		varchar(100);
define _n_agente			varchar(50);
define v_descr_cia			varchar(50);
define v_desc_coaseg		varchar(50);
define v_nodocumento		char(20);
define v_cod_contratante	char(10);
define v_nofactura  		char(10);
define v_nopoliza			char(10);
define _cod_agente			char(5);
define v_noendoso			char(5);
define v_cod_coasegur		char(3);
define _cod_ramo			char(3);
define v_codimp5			char(3);
define v_codimp1			char(3);
define _tipo				char(1);
define v_porc_partic		dec(7,4);
define v_porc_gastos		dec(5,2);
define _suma_asegurada		dec(16,2);
define v_total_prima		dec(16,2);
define v_prima_neta			dec(16,2);
define v_impuesto1			dec(16,2);
define v_impuesto			dec(16,2);
define _imp					dec(16,2);
define _factor_impuesto		smallint;
define v_vigencia_final		date;
define v_vigencia_inic		date;


let v_porc_gastos = 0;


create temp table temp_coaseguro
(no_factura			char(10),
no_documento		char(20),
cod_contratante		char(10),
cod_coasegur		char(3),
prima				dec(16,2),
suma_asegurada		dec(16,2),
porc_partic_coas	dec(7,4),
porc_gastos			dec(5,2),
porc_impuesto1		dec(9,2),
porc_impuesto2		dec(9,2),
cod_ramo			char(3),
cod_agente			char(5),
vig_inicial			date,
vig_final			date,
seleccionado		smallint default 1);
create index id1_temp_coaseguro on temp_coaseguro(cod_coasegur);
create index id2_temp_coaseguro on temp_coaseguro(no_factura);


let v_descr_cia = sp_sis01(a_compania);
let v_cod_contratante = null;
let v_impuesto1 = 0;
let v_impuesto = 0;
let _imp = 0;

set isolation to dirty read;

--set debug file to "sp_pro41.trc";
--trace on;

let v_filtros = "";

foreach
	select x.no_poliza,
		   x.no_endoso,
		   x.no_factura,
		   x.no_documento,
		   x.prima_neta,
		   x.suma_asegurada,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.impuesto,
		   e.cod_ramo,
		   e.cod_contratante,
		   cod_coasegur,
		   porc_partic_ancon
	  into v_nopoliza,
		   v_noendoso,
		   v_nofactura,
		   v_nodocumento,
		   v_prima_neta,
		   _suma_asegurada,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_impuesto,
		   _cod_ramo,
		   v_cod_contratante,
		   v_cod_coasegur,
		   v_porc_partic
	  from endedmae x, emipomae e, emitipro t, emicoami c
	 where e.no_poliza = x.no_poliza
	   and e.cod_tipoprod = t.cod_tipoprod
	   and e.no_poliza = c.no_poliza
	   and x.periodo >= a_periodo1
	   and x.periodo <= a_periodo2
	   and t.tipo_produccion = a_tipoprod
	   and x.prima_neta <> 0.00
	   and x.actualizado = 1

	let v_impuesto1 = 0.00;
	let v_impuesto = 0.00;
	foreach
		select factor_impuesto
		  into _factor_impuesto
		  from endedimp e, prdimpue i
		 where e.cod_impuesto = i.cod_impuesto
		   and no_poliza    = v_nopoliza
		   and no_endoso    = v_noendoso 

		let _imp = v_prima_neta * (_factor_impuesto/100);

		if _factor_impuesto = 1 then
			let v_impuesto1 = _imp;
		elif _factor_impuesto = 5 then
			let v_impuesto = _imp;
		end if
	end foreach

	foreach
		select cod_agente
		  into _cod_agente
		  from endmoage
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso
		 order by porc_partic_agt desc
		exit foreach;
	end foreach
		
	insert into temp_coaseguro(
			no_factura,
			no_documento,
			cod_contratante,
			cod_coasegur,
			prima,
			suma_asegurada,
			porc_partic_coas,
			porc_gastos,
			porc_impuesto1,
			porc_impuesto2,
			cod_ramo,
			cod_agente,
			vig_inicial,
			vig_final,
			seleccionado)
	values(	v_nofactura,
			v_nodocumento,
			v_cod_contratante,
			v_cod_coasegur,
			v_prima_neta,
			_suma_asegurada,
			v_porc_partic,
			v_porc_gastos,
			v_impuesto,
			v_impuesto1,
			_cod_ramo,
			_cod_agente,
			v_vigencia_inic,
			v_vigencia_final,
			1);
end foreach

if a_codcoasegur <> "*" then
	let v_filtros = trim(v_filtros) ||"Coaseguradora "|| trim(a_codcoasegur);
	let _tipo = sp_sis04(a_codcoasegur); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update temp_coaseguro
		  set seleccionado = 0
		where seleccionado = 1
		  and cod_coasegur not in(select codigo from tmp_codigos);
	else
		update temp_coaseguro
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_coasegur in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_cod_cliente <> "*" then

	let v_filtros = trim(v_filtros) ||"Cliente "|| trim(a_cod_cliente);
	let _tipo = sp_sis04(a_cod_cliente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update temp_coaseguro
		  set seleccionado = 0
		where seleccionado = 1
		  and cod_contratante not in(select codigo from tmp_codigos);
	else
		update temp_coaseguro
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

-- filtro de poliza

if a_no_documento <> "*" and a_no_documento <> "" then

	let v_filtros = trim(v_filtros) ||"Documento: "|| trim(a_no_documento);

	update temp_coaseguro
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_documento <> a_no_documento;
end if

-- filtro de ramo

if a_codramo <> "*" then
	let v_filtros = trim(v_filtros) ||"Ramo: "||trim(a_codramo);
	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_coaseguro
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in(select codigo from tmp_codigos);
	else
		update temp_coaseguro
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

foreach
	select no_factura,
		   no_documento,
		   cod_contratante,
		   cod_coasegur,
		   cod_agente,
		   prima,
		   suma_asegurada,
		   porc_partic_coas,
		   porc_gastos,
		   porc_impuesto1,
		   porc_impuesto2,
		   vig_inicial,
		   vig_final
	  into v_nofactura,
		   v_nodocumento,
		   v_cod_contratante,
		   v_cod_coasegur,
		   _cod_agente,
		   v_prima_neta,
		   _suma_asegurada,
		   v_porc_partic,
		   v_porc_gastos,
		   v_impuesto,
		   v_impuesto1,
		   v_vigencia_inic,
		   v_vigencia_final
	  from temp_coaseguro
	 where seleccionado = 1
	 order by cod_coasegur

	select nombre
	  into _n_agente
	  from agtagent 
	 where cod_agente = _cod_agente;

	select nombre
	  into v_desc_coaseg
	  from emicoase
	 where cod_coasegur = v_cod_coasegur;

	select nombre
	  into v_desc_nombre
	  from cliclien
	 where cod_cliente = v_cod_contratante;

	let v_total_prima = v_prima_neta + v_impuesto +	v_impuesto1;

	return v_cod_coasegur,
		   v_desc_coaseg,
		   v_nofactura,
		   v_nodocumento,
		   v_desc_nombre,
		   v_porc_partic,
		   v_prima_neta,
		   _suma_asegurada,
		   v_impuesto,
		   v_impuesto1,
		   v_total_prima,
		   v_porc_gastos,
		   v_descr_cia,
		   v_filtros,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _n_agente
		   with resume;
end foreach

drop table if exists temp_coaseguro;

end
end procedure;