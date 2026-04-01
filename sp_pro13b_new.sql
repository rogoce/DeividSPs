-- INFORME DE FIANZAS POR CLIENTE VIGENTES A LA FECHA          
-- Creado por:     Yinia M. Zamora:      22/08/2000 
-- Modificado por: Marquelda Valdelamar: 22/08/2001 (Para incluir filtro de clientes)
-- Modificado por: Henry Girón: 20/02/2017 Solicitud: LINNETT, COLATERAL
-- execute procedure sp_pro13b('001','001','*','*',today,'*')

drop procedure sp_pro13b;
create procedure 'informix'.sp_pro13b(
a_cia			char(3),
a_agencia		char(3),
a_codsucursal	varchar(255) default '*',
a_contratante	varchar(255) default '*',
a_fecha_hasta	date,
a_codsubramo	varchar(255) default '*')
returning	varchar(50)		as compania,
			char(20)		as poliza,
			char(10)		as factura,
			char(3)			as cod_subramo,
			date			as fecha_suscripcion,
			date			as vigencia_final,
			char(10)		as cod_contratante,
			dec(16,2)		as suma_asegurada,
			varchar(50)		as desc_unidad,
			dec(16,2)		as prima_retenida,
			varchar(50)		as contratante,
			varchar(50)		as direccion_1,
			char(10)		as telefono1,
			char(20)		as apartado,
			varchar(50)		as subramo,
			dec(16,2)		as prima_suscrita,
			date			as fecha_hasta,
			dec(16,2)		as prima_cedida,
			varchar(255)	as filtros,
			varchar(255)	as colateral,
			varchar(255)	as banco,
			varchar(255)	as fecha_vencimiento;
			
define _fecha_vence_gar		varchar(255);
define _nombre_banco		varchar(255);
define v_colateral			varchar(255);
define v_filtros			varchar(255);
define v_nombre_cliente		varchar(50);
define v_desc_subramo		varchar(50);
define v_descripcion		varchar(50);
define v_direccion1			varchar(50);
define v_descsubra			varchar(50);
define v_descr_cia			varchar(50);
define v_valor1				char(30);
define v_valor2				char(30);
define v_valor3				char(30);
define v_documento			char(20);
define v_apartado			char(20);
define v_contratante		char(10);
define v_nofactura			char(10);
define v_telefono1			char(10);
define v_nopoliza			char(10);
define v_codigo				char(10);
define v_cod_sucursal		char(3);
define v_codsubramo			char(3);
define v_cod_ramo			char(3);
define v_saber				char(2);
define _tipo				char(1);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_retenida		dec(16,2);
define v_reaseguro			dec(16,2);
define _tam					smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_cancelacion	date;
define v_vigencia_final		date;
define v_fecha_suscrip		date;
define _fecha_emision		date;

--set debug file to 'sp_pro13b.trc';
--trace on;

begin
on exception set _error, _error_isam, v_filtros
	drop table if exists tmp_fianzas;
	drop table if exists tmp_cliente;

	return	'',
			'',
			'',
			'',
			null,
			null,
			'',
			_error,
			'',
			_error_isam,
			'',
			'',
			'',
			'',
			'',
			0.00,
			null,
			0.00,
			v_filtros,
			'',
			'',
			'';
end exception

let v_vigencia_final = null;
let v_fecha_suscrip = null;
let v_cod_sucursal = null;
let v_contratante = null;
let v_descripcion = null;
let v_codsubramo = null;
let v_nofactura = null;
let v_documento = null;
let v_descsubra = null;
let v_descr_cia = null;
let v_cod_ramo = null;
let v_nopoliza = null;
let v_filtros = null;
let v_prima_suscrita = 0.00;
let v_suma_asegurada = 0.00;
let v_prima_retenida = 0.00;
let _fecha_vence_gar = '';
let _nombre_banco = '';
let v_colateral = '';	

let v_descr_cia = sp_sis01(a_cia);

create temp table tmp_fianzas(
no_documento		char(20),
no_factura			char(10),
cod_ramo			char(3),
cod_subramo			char(3),
cod_sucursal		char(3),
fecha_emision		date,
fecha_vencmto		date,
cod_contratante		char(10),
suma_asegurada		dec(16,2),
descripcion			char(50),
prima_suscrita		dec(16,2),
prima_retenida		dec(16,2),
seleccionado		smallint default 1,
nopoliza			char(10));
create index ind1_tmp_fianzas on tmp_fianzas(no_factura);
create index ind2_tmp_fianzas on tmp_fianzas(cod_contratante);

set isolation to dirty read;

foreach
	select a.no_poliza,
		   a.cod_sucursal,
		   a.no_documento,
		   a.no_factura,
		   a.prima_suscrita,
		   a.cod_ramo,
		   a.cod_subramo,
		   a.fecha_suscripcion,
		   a.vigencia_final,
		   a.cod_contratante,
		   a.fecha_cancelacion
	  into v_nopoliza,
		   v_cod_sucursal,
		   v_documento,
		   v_nofactura,
		   v_prima_suscrita,
		   v_cod_ramo,
		   v_codsubramo,
		   v_fecha_suscrip,
		   v_vigencia_final,
		   v_contratante,
		   _fecha_cancelacion
	  from emipomae a, prdramo r
	 where r.cod_ramo = a.cod_ramo
	   and a.cod_compania = a_cia
	   and a.vigencia_final >= a_fecha_hasta
	   and a.actualizado = 1
	   and a.vigencia_inic <= a_fecha_hasta
	   and r.ramo_sis = 3

	let _fecha_emision = null;

	if _fecha_cancelacion <= a_fecha_hasta then
		foreach
			select fecha_emision
			  into _fecha_emision
			  from endedmae
			 where no_poliza = v_nopoliza
			   and cod_endomov = '002'
			   and vigencia_inic = _fecha_cancelacion
			   and actualizado = 1
		end foreach

		if  _fecha_emision <= a_fecha_hasta then
			continue foreach;
		end if
	end if

	foreach
		select b.suma_asegurada,
			   b.desc_unidad,
			   b.prima_retenida
		  into v_suma_asegurada,
			   v_descripcion,
			   v_prima_retenida
		  from emipouni b
		 where b.no_poliza = v_nopoliza

		insert into tmp_fianzas(
				no_documento,
				no_factura,
				cod_ramo,
				cod_subramo,
				cod_sucursal,
				fecha_emision,
				fecha_vencmto,
				cod_contratante,
				suma_asegurada,
				descripcion,
				prima_suscrita,
				prima_retenida,
				seleccionado,
				nopoliza)
		values(	v_documento,
				v_nofactura,
				v_cod_ramo, 
				v_codsubramo,
				v_cod_sucursal,
				v_fecha_suscrip,
				v_vigencia_final,
				v_contratante,
				v_suma_asegurada,
				v_descripcion,
				v_prima_suscrita,
				v_prima_retenida,
				1,
				v_nopoliza);
	end foreach
end foreach

if a_codsucursal <> '*' then
	let v_filtros = trim(v_filtros) ||'Sucursal '||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros

        update tmp_fianzas
               set seleccionado = 0
             where seleccionado = 1
               and cod_sucursal not in(select codigo from tmp_codigos);
     else
        update tmp_fianzas
               set seleccionado = 0
             where seleccionado = 1
               and cod_sucursal in(select codigo from tmp_codigos);
     end if
     drop table tmp_codigos;
end if

if a_codsubramo <> '*' then
	let v_filtros = trim(v_filtros) || ' Subramo: '; --||  trim(a_subramo);

	let _tipo = sp_sis04(a_codsubramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> 'E' then -- (i) incluir los registros

		update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in (select codigo from tmp_codigos);
	       let v_saber = '';
	else		        -- (e) excluir estos registros

		update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in (select codigo from tmp_codigos);
		   let v_saber = ' Ex';
	end if

	foreach
		select s.nombre,
			   t.codigo
		  into v_desc_subramo,
			   v_codigo
		  from prdsubra s,tmp_codigos t
		 where s.cod_subramo = t.codigo
		   and s.cod_ramo = '008'

		let v_filtros = trim(v_filtros) || ' ' || trim(v_codigo) || ' ' || trim(v_desc_subramo) || trim(v_saber);
	end foreach
	drop table tmp_codigos;
end if

if a_contratante <> '*' then
	let v_filtros = trim(v_filtros) ||'Cliente '||trim(a_contratante);
	let _tipo = sp_sis04(a_contratante); -- separa los valores del string

	if _tipo <> 'E' then -- incluir los registros

        update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante not in(select codigo from tmp_codigos);
	else
        update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante in(select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

let v_colateral = '';

foreach
	select t.no_documento,
		   t.no_factura,
		   e.cod_ramo,
		   t.cod_subramo,
		   t.fecha_emision,
		   t.fecha_vencmto,
		   t.cod_contratante,
		   t.suma_asegurada,
		   t.descripcion,
		   t.prima_suscrita,
		   t.prima_retenida,
		   t.nopoliza,
		   d.nombre,
		   d.direccion_1,
		   d.telefono1,
		   d.apartado,
		   e.nombre
	  into v_documento,
		   v_nofactura,
		   v_cod_ramo,
		   v_codsubramo,
		   v_fecha_suscrip,
		   v_vigencia_final,
		   v_contratante,
		   v_suma_asegurada,
		   v_descripcion,
		   v_prima_suscrita,
		   v_prima_retenida,
		   v_nopoliza,
		   v_nombre_cliente,
		   v_direccion1,
		   v_telefono1,
		   v_apartado,
		   v_descsubra
	  from tmp_fianzas t, cliclien d, prdsubra e
	 where d.cod_cliente = t.cod_contratante
	   and e.cod_ramo = t.cod_ramo
	   and e.cod_subramo = t.cod_subramo
	   and t.seleccionado = 1
     order by t.cod_contratante,t.no_factura


	let v_reaseguro = v_prima_suscrita - v_prima_retenida;
	let _fecha_vence_gar = '';	   
	let _nombre_banco = '';
	let v_colateral = '';
	let v_valor1 = '';
	let v_valor2 = '';
	let v_valor3 = '';

	foreach
		select trim(c.nombre),
			   decode(trim(f.nombre_banco),null,'**************************************************',trim(f.nombre_banco)),
			   decode(trim(cast(f.fecha_vencimiento as varchar(100))),null,'********************',trim(cast(f.fecha_vencimiento as varchar(100))))			  			  
		  into v_valor1,
			   v_valor2,
			   v_valor3
		  from coltigar8 c, fiangarcol f
		 where c.cod_tipo = f.cod_tipo
		   and f.no_poliza = v_nopoliza		  

		let _tam = length(v_valor1);
		
		if _tam < 10 then
			let v_valor1 = trim(v_valor1)||'***************';
		end if

		let _fecha_vence_gar = trim(_fecha_vence_gar)||' '||v_valor3;
		let _nombre_banco = trim(_nombre_banco)||' '||v_valor2;
		let v_colateral = trim(v_colateral)||' '||v_valor1;			  
	end foreach

	let _fecha_vence_gar = replace(trim(_fecha_vence_gar),'*',' ');
	let _nombre_banco = replace(trim(_nombre_banco),'*',' ');
	let v_colateral = replace(trim(v_colateral),'*',' ');

	return	v_descr_cia,
			v_documento,
			v_nofactura,
			v_codsubramo,
			v_fecha_suscrip,
			v_vigencia_final,
			v_contratante,
			v_suma_asegurada,
			v_descripcion,
			v_prima_retenida,
			v_nombre_cliente,
			v_direccion1,
			v_telefono1,
			v_apartado,
			v_descsubra,
			v_prima_suscrita,
			a_fecha_hasta,
			v_reaseguro,
			v_filtros,
			v_colateral,
			_nombre_banco,
			_fecha_vence_gar with resume;
end foreach

drop table if exists tmp_fianzas;
drop table if exists tmp_cliente;
end
end procedure;