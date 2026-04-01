--- INFORME DE FIANZAS POR CLIENTE    
--- VIGENTES A LA FECHA          
--- Creado por:     Yinia M. Zamora:      22/08/2000 
--  Modificado por: Marquelda Valdelamar: 22/08/2001 (Para incluir filtro de clientes)
--  Modificado por: Henry Girón: 20/02/2017 Solicitud: LINNETT, COLATERAL
-- execute procedure sp_pro13b("001","001","*","*","03/03/2017","*")
drop procedure sp_pro13b;
create procedure "informix".sp_pro13b(
a_cia			char(3),
a_agencia		char(3),
a_codsucursal	char(3) default "*",
a_contratante	varchar(255) default "*",
a_periodo1		date,
a_codsubramo	varchar(255) default "*")
returning	char(45),
			char(20),
			char(10),
			char(03),
			date,
			date,
			char(10),
			dec(16,2),
			char(50),
			dec(16,2),
			char(50),
			char(50),
			char(10),
			char(20),
			char(50),
			dec(16,2),
			date,
			dec(16,2),
			char(255),
			char(255),
			char(255),
			char(255);


begin

define v_nombre_cliente		varchar(50);
define v_desc_subramo		varchar(50);
define v_descsubra			varchar(50);
define v_descripcion		varchar(50);
define v_direccion1			varchar(50);
define v_descr_cia			varchar(50);
define v_prueba				varchar(50);
define v_filtros			varchar(255);
define v_colateral			varchar(255);
define v_valor				varchar(255);
define _nombre_banco		varchar(255);
define _fecha_vence_gar|	varchar(255);
define _fin					char(3);
define _tipo				char(1);
define v_saber				char(2);
define v_codigo				char(10);
define v_valor1				char(30); --255);
define v_valor2				char(30); --255);
define v_valor3				char(30); --255);
define v_contratante		char(10);
define v_nofactura			char(10);
define v_telefono1			char(10);
define v_cod_cliente		char(10);
define v_nopoliza			char(10);
define v_documento			char(20);
define v_apartado			char(20);
define v_cod_subramo		char(3);
define v_codsubramo			char(3);
define v_cod_sucursal		char(3);
define v_cod_ramo			char(3);
define v_ver				char(3);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_retenida		dec(16,2);
define v_reaseguro			dec(16,2);
define _fila_ultima			smallint;
define _fila				smallint;
define _tam					smallint;
define v_vigencia_final		date;
define v_fecha_suscrip		date;
define _fecha_cancelacion	date;
define _fecha_emision		date;

	--set debug file to "\\nemesis\ancon\store procedures\debug\sp_pro13.trc"; 

let v_nopoliza       = null;
let v_contratante    = null;
let v_nofactura      = null;
let v_documento      = null;
let v_cod_ramo       = null;
let v_cod_sucursal   = null;
let v_codsubramo     = null;
let v_fecha_suscrip  = null;
let v_vigencia_final = null;
let v_filtros        = null;
let v_prima_suscrita = 0;
let v_suma_asegurada = 0;
let v_prima_retenida = 0;
let v_descripcion    = null;
let v_descsubra      = null;
let v_descr_cia      = null;
let v_colateral      = '';
let v_valor      = '';
let _fin      = '';
let _nombre_banco = '';
let _fecha_vence_gar  = '';
	

let v_descr_cia = sp_sis01(a_cia);
create temp table tmp_fianzas(
no_documento	char(20),
no_factura       char(10),
cod_ramo         char(3),
cod_subramo      char(3),
cod_sucursal     char(3),
fecha_emision    date,
fecha_vencmto    date,
cod_contratante  char(10),
suma_asegurada   dec(16,2),
descripcion      char(50),
prima_suscrita   dec(16,2),
prima_retenida   dec(16,2),
seleccionado     smallint default 1,
nopoliza         char(10));
create index ind1_tmp_fianzas on tmp_fianzas(no_factura);
create index ind2_tmp_fianzas on tmp_fianzas(cod_contratante);

call sp_pro13a(a_cia,a_agencia,a_codsucursal,a_contratante) returning  v_filtros;
	
let v_filtros = "";

set isolation to dirty read;

foreach
	select cod_ramo
	  into v_cod_ramo
	  from prdramo
	 where ramo_sis = 3

    foreach
		select cod_cliente
		  into v_cod_cliente
		  from tmp_cliente
		 where seleccionado = 1

		foreach with hold
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
				   v_fecha_suscrip,
				   v_codsubramo,
				   v_vigencia_final,
				   v_contratante,
				   _fecha_cancelacion
			  from emipomae a
			 where a.cod_compania = a_cia
			   and a.cod_ramo = v_cod_ramo
			   and a.cod_contratante = v_cod_cliente
			   and a.vigencia_final >= a_periodo1
			   and a.actualizado = 1
			   and a.vigencia_inic <= a_periodo1

			let _fecha_emision = null;

			if _fecha_cancelacion <= a_periodo1 then
				foreach
					select fecha_emision
					  into _fecha_emision
					  from endedmae
					 where no_poliza = v_nopoliza
					   and cod_endomov = '002'
					   and vigencia_inic = _fecha_cancelacion
				end foreach

				if  _fecha_emision <= a_periodo1 then
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

				  insert into tmp_fianzas
				  values(v_documento,
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
						 1,v_nopoliza);

			end foreach
		end foreach
    end foreach
end foreach

if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

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


--trace on;                                                                

if a_codsubramo <> "*" then
	let v_filtros = trim(v_filtros) || " Subramo: "; --||  trim(a_subramo);

	let _tipo = sp_sis04(a_codsubramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros

		update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in (select codigo from tmp_codigos);
	       let v_saber = "";
	else		        -- (e) excluir estos registros

		update tmp_fianzas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in (select codigo from tmp_codigos);
		   let v_saber = " ex";
	end if

if a_contratante <> "*" then
     let v_filtros = trim(v_filtros) ||"Cliente "||trim(a_contratante);
     let _tipo = sp_sis04(a_contratante); -- separa los valores del string

     if _tipo <> "E" then -- incluir los registros

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

		 foreach
			select prdsubra.nombre,tmp_codigos.codigo
              into v_desc_subramo,v_codigo
              from prdsubra,tmp_codigos
             where prdsubra.cod_ramo = "008"
			   and prdsubra.cod_subramo = codigo
	         let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_subramo) || trim(v_saber);
		 end foreach
		 --let v_ver 	  = v_cod_ramo;
		 --let v_prueba = v_desc_subramo;


	drop table tmp_codigos;
end if

let v_colateral = "";

foreach
	select no_documento,
		   no_factura,
		   cod_ramo,
		   cod_subramo,
		   fecha_emision,
		   fecha_vencmto,
		   cod_contratante,
		   suma_asegurada,
		   descripcion,
		   prima_suscrita,
		   prima_retenida,
		   nopoliza
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
		   v_nopoliza
	  from tmp_fianzas
	 where seleccionado = 1
     order by no_factura

	select d.nombre,
		   d.direccion_1,
		   d.telefono1,
		   d.apartado
	  into v_nombre_cliente,
		   v_direccion1,
		   v_telefono1,
		   v_apartado
	  from cliclien d
	 where d.cod_cliente = v_contratante;

	select e.nombre
	  into v_descsubra
	  from prdsubra e
	 where e.cod_subramo = v_codsubramo
	   and e.cod_ramo    = v_cod_ramo;

	let v_reaseguro = v_prima_suscrita - v_prima_retenida;
	let v_colateral = "";
	let _nombre_banco = "";
	let _fecha_vence_gar = "";	   
	let v_valor = "";
	let _fin = ",";
	let _fila = 0;	   
	let _fila_ultima = 0;	
	let v_valor1 = 0;
	let v_valor2 = 0;
	let v_valor3 = 0;
	   
	select count(*)
	  into _fila_ultima
	  from coltigar8 c, fiangarcol f
	 where c.cod_tipo = f.cod_tipo
	   and f.no_poliza  = v_nopoliza;

	foreach
		select trim(c.nombre),
			   decode(trim(f.nombre_banco),null,'**************************************************',trim(f.nombre_banco)),
			   decode(trim(cast(f.fecha_vencimiento as varchar(100))),null,'********************',trim(cast(f.fecha_vencimiento as varchar(100))))			  			  
		  into v_valor1,
			   v_valor2,
			   v_valor3
		  from coltigar8 c, fiangarcol f
		 where c.cod_tipo = f.cod_tipo
		   and f.no_poliza  = v_nopoliza		  

		let _tam = length(v_valor1);
		
		if _tam < 10 then
			let v_valor1 = trim(v_valor1)||"***************";
		end if

		let v_colateral = trim(v_colateral)||" "||v_valor1;			  
		let _nombre_banco = trim(_nombre_banco)||" "||v_valor2;
		let _fecha_vence_gar = trim(_fecha_vence_gar)||" "||v_valor3;

	end foreach

	let v_colateral =	 replace(trim(v_colateral),"*"," ");
	let _nombre_banco =	 replace(trim(_nombre_banco),"*"," ");
	let _fecha_vence_gar =	 replace(trim(_fecha_vence_gar),"*"," ");

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
			a_periodo1,
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