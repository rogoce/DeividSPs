---------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL  ---
---            POLIZAS VIGENTES           ---
---  Yinia M. Zamora - agosto 2000 - YMZM ---
---  Ref. Power Builder - d_sp_pro03	  ---
---------------------------------------------
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA

drop procedure sp_pro03i;
create procedure "informix".sp_pro03i(
a_cia		char(3),
a_agencia	char(3),
a_periodo	date,
a_codramo	char(255),
a_codvend   char(255) DEFAULT "*")   -- Filtro de Zona DALBA
returning	varchar(255);

define v_filtros			varchar(255);
define _no_documento		char(20);
define v_cod_subramo		char(3);
define v_contratante		char(10);
define _no_factura			char(10);
define _no_poliza			char(10);
define v_usuario			char(8);
define _periodo				char(7);
define v_cod_agente			char(5);
define v_cod_grupo			char(5);
define ano					char(4);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define v_cod_ramo			char(3);
define mes1					char(2);
define _tipo				char(1);
define v_porc_partic		dec(5,2);
define v_prima_retenida		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_bruta		dec(16,2);
define mes					smallint;
define v_vigencia_final		date;
define v_fecha_suscrip		date;
define v_vigencia_inic		date;
define _fecha_cancelacion	date;
define _fecha_emision		date;
define _suc_prom        	char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor	    char(50);

--Se crea la tabla temporal que contendra la información del proceso
create temp table temp_perfil(
no_poliza			char(10),
no_documento		char(20),
no_factura			char(10),
cod_ramo			char(3),
cod_subramo			char(3),
cod_sucursal		char(3),
cod_grupo			char(5),
cod_tipoprod		char(3),
cod_contratante		char(10),
cod_agente			char(5),
prima_suscrita		dec(16,2),
prima_retenida		dec(16,2),
vigencia_inic		date,
vigencia_final		date,
fecha_suscripcion	date,
usuario				char(08),
suma_asegurada		dec(16,2),
prima_bruta			dec(16,2),
seleccionado		smallint default 1,
cod_vendedor	     CHAR(3),       -- cod_vendedor   -- Para manejo de Zonas, DALBA 19/04/2018
nombre_vendedor      CHAR(50)       -- nombre vendedor
) with no log;
--     PRIMARY KEY(no_poliza))
create index i_perfil1 on temp_perfil(no_poliza);
create index i_perfil2 on temp_perfil(cod_ramo);
create index i_perfil3 on temp_perfil(cod_subramo);
create index i_perfil4 on temp_perfil(cod_tipoprod);
create index i_perfil5 on temp_perfil(cod_sucursal);

--Se inicializan las variables
let v_cod_tipoprod = null;
let v_cod_sucursal = null;
let v_cod_subramo  = null;
let _no_documento = null;
let v_cod_agente = null;
let v_cod_grupo = null;
let _no_factura = null;
let v_cod_ramo = null;
let _no_poliza = null;
let _tipo = null;
let v_prima_suscrita = 0;
let v_prima_retenida = 0;
let v_prima_bruta = 0;
let v_filtros = " ";

{let mes = month(a_periodo);
if mes <= 9 then
	   let mes1[1,1] = '0';
	   let mes1[2,2] = mes;
	else
	   let mes1 = mes;
	end if
    let ano = year(a_periodo);
	let _periodo[1,4] = ano;
	let _periodo[5] = "-";
	let _periodo[6,7] = mes1;}

--Se busca el periodo de la fecha hasta la que se quiere generar el reporte. 
let _periodo = sp_sis39(a_periodo);

--set debug file to "sp_pro03.trc"; 
--trace on;

set isolation to dirty read;

--Se Deben incluir todos los Ramos
if a_codramo = "*" then
	foreach with hold
		select no_poliza,
			   no_documento,
			   no_factura,
			   sucursal_origen,
			   cod_grupo,
			   cod_ramo,
			   cod_subramo,
			   cod_tipoprod,
			   cod_contratante,
			   prima_suscrita,
			   prima_retenida,
			   vigencia_inic,
			   vigencia_final,
			   fecha_suscripcion,
			   user_added,
			   suma_asegurada,
			   fecha_cancelacion,
			   prima_bruta
		  into _no_poliza,
			   _no_documento,
			   _no_factura,
			   v_cod_sucursal,
			   v_cod_grupo,
			   v_cod_ramo,
			   v_cod_subramo,
			   v_cod_tipoprod,
			   v_contratante,
			   v_prima_suscrita,
			   v_prima_retenida,
			   v_vigencia_inic,
			   v_vigencia_final,
			   v_fecha_suscrip,
			   v_usuario,
			   v_suma_asegurada,
			   _fecha_cancelacion,
			   v_prima_bruta
		  from emipomae
		 where cod_compania = a_cia
		   and (vigencia_final >= a_periodo or vigencia_final is null)
		   and fecha_suscripcion <= a_periodo
		   and vigencia_inic <= a_periodo
		   and actualizado = 1

		let _fecha_emision = null;

		if _fecha_cancelacion <= a_periodo then
			--foreach
			select max(fecha_emision)
			  into _fecha_emision
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and actualizado = 1;
				--   and vigencia_inic = _fecha_cancelacion
			--end foreach

			if  _fecha_emision <= a_periodo then
				continue foreach;
			end if
		end if

		foreach
			select cod_agente,
				   porc_partic_agt
			  into v_cod_agente,
				   v_porc_partic
			  from emipoagt
			 where no_poliza = _no_poliza
			exit foreach; 
			-- let v_prima_suscrita = v_prima_suscrita * (v_porc_partic/100);
		end foreach
		
		select sucursal_promotoria
		  into _suc_prom
		  from insagen
		 where codigo_agencia  = v_cod_sucursal
		   and codigo_compania = '001';

	   select cod_vendedor
		 into _cod_vendedor
		 from parpromo
		where cod_agente  = v_cod_agente
		  and cod_agencia = _suc_prom
		  and cod_ramo	   = v_cod_ramo;
		
		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;	
		 

		insert into temp_perfil
		values(	_no_poliza,
				_no_documento,
				_no_factura,
				v_cod_ramo,
				v_cod_subramo,
				v_cod_sucursal,
				v_cod_grupo,
				v_cod_tipoprod,
				v_contratante,
				v_cod_agente,
				v_prima_suscrita,
				v_prima_retenida,
				v_vigencia_inic,
				v_vigencia_final,
				v_fecha_suscrip,
				v_usuario,
				v_suma_asegurada,
				v_prima_bruta,
				1,				
				_cod_vendedor,
				_nombre_vendedor);
	end foreach
--Se Debe Aplicar el filtro de Ramos solicitado por el Usuario
else
	--Crear una tabla temporal con los codigos especificados por el usuario
	let _tipo = sp_sis04(a_codramo);
	
	--Se agregan los filtros a la etiqueta de filtros aplicados
	let v_filtros = trim(v_filtros) ||"Ramo "||trim(a_codramo);

	--Se Deben incluir los Ramos especificados
	if _tipo <> "E" then -- incluir los registros
		foreach with hold
			select no_poliza,
				   no_documento,
				   no_factura,
				   sucursal_origen,
				   cod_grupo,
				   cod_ramo,
				   cod_subramo,
				   cod_tipoprod,
				   cod_contratante,
				   prima_suscrita,
				   prima_retenida,
				   vigencia_inic,
				   vigencia_final,
				   fecha_suscripcion,
				   user_added,
				   suma_asegurada,
				   fecha_cancelacion,
				   prima_bruta
			  into _no_poliza,
				   _no_documento,
				   _no_factura,
				   v_cod_sucursal,
				   v_cod_grupo,
				   v_cod_ramo,
				   v_cod_subramo,
				   v_cod_tipoprod,
				   v_contratante,
				   v_prima_suscrita,
				   v_prima_retenida,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario,
				   v_suma_asegurada,
				   _fecha_cancelacion,
				   v_prima_bruta
			  from emipomae
			 where cod_compania = a_cia
			   and vigencia_final >= a_periodo
			   and fecha_suscripcion <= a_periodo
			   and vigencia_inic <= a_periodo
			   and actualizado = 1
			   and periodo <= _periodo
			   and cod_ramo in (select codigo from tmp_codigos)
			   --and (fecha_cancelacion is null or   fecha_cancelacion > a_periodo)

			let _fecha_emision = null;

			if _fecha_cancelacion <= a_periodo then
				--foreach
					select max(fecha_emision)
					  into _fecha_emision
					  from endedmae
					 where no_poliza = _no_poliza
					   and cod_endomov = '002';
					 --  and vigencia_inic = _fecha_cancelacion
				--end foreach

				if  _fecha_emision <= a_periodo then
					continue foreach;
				end if
			end if

			foreach
				select cod_agente,
					   porc_partic_agt
				  into v_cod_agente,
					   v_porc_partic
				  from emipoagt
				 where no_poliza = _no_poliza
				 order by porc_partic_agt desc
				exit foreach;
			end foreach
			
			select sucursal_promotoria
			  into _suc_prom
			  from insagen
			 where codigo_agencia  = v_cod_sucursal
			   and codigo_compania = '001';

		   select cod_vendedor
			 into _cod_vendedor
			 from parpromo
			where cod_agente  = v_cod_agente
			  and cod_agencia = _suc_prom
			  and cod_ramo	   = v_cod_ramo;
			
			select nombre
			  into _nombre_vendedor
			  from agtvende
			 where cod_vendedor = _cod_vendedor;				
			
			insert into temp_perfil
			values(	_no_poliza,
					_no_documento,
					_no_factura,
					v_cod_ramo,
					v_cod_subramo,
					v_cod_sucursal,
					v_cod_grupo,
					v_cod_tipoprod,
					v_contratante,
					v_cod_agente,
					v_prima_suscrita,
					v_prima_retenida,
					v_vigencia_inic,
					v_vigencia_final,
					v_fecha_suscrip,
					v_usuario,
					v_suma_asegurada,
					v_prima_bruta,
				   1,
				   _cod_vendedor,
				   _nombre_vendedor);
		end foreach
		drop table tmp_codigos;
	else 
		foreach with hold
			select no_poliza,
				   no_documento,
				   no_factura,
				   sucursal_origen,
				   cod_grupo,
				   cod_ramo,
				   cod_subramo,
				   cod_tipoprod,
				   cod_contratante,
				   prima_suscrita,
				   prima_retenida,
				   vigencia_inic,
				   vigencia_final,
				   fecha_suscripcion,
				   user_added,
				   suma_asegurada,
				   fecha_cancelacion,
				   prima_bruta
			  into _no_poliza,
				   _no_documento,
				   _no_factura,
				   v_cod_sucursal,
				   v_cod_grupo,
				   v_cod_ramo,
				   v_cod_subramo,
				   v_cod_tipoprod,
				   v_contratante,
				   v_prima_suscrita,
				   v_prima_retenida,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario,
				   v_suma_asegurada,
				   _fecha_cancelacion,
				   v_prima_bruta
			  from emipomae d
			 where cod_compania = a_cia
			   and vigencia_final >= a_periodo
			   and fecha_suscripcion <= a_periodo
			   and periodo <= _periodo
			   and actualizado = 1
			   and vigencia_inic <= a_periodo
			   and cod_ramo not in(select codigo from tmp_codigos)
			   --and (fecha_cancelacion is null or  fecha_cancelacion > a_periodo)

			let _fecha_emision = null;

			if _fecha_cancelacion <= a_periodo then
				--foreach
					select max(fecha_emision)
					  into _fecha_emision
					  from endedmae
					 where no_poliza = _no_poliza
					   and cod_endomov = '002';
					   --and vigencia_inic = _fecha_cancelacion
				--end foreach

				if  _fecha_emision <= a_periodo then
					continue foreach;
				end if
			end if

			foreach
				select cod_agente,
					   porc_partic_agt
				  into v_cod_agente,
					   v_porc_partic
				  from emipoagt z
				 where z.no_poliza = _no_poliza
				exit foreach;
			end foreach
			
			select sucursal_promotoria
			  into _suc_prom
			  from insagen
			 where codigo_agencia  = v_cod_sucursal
			   and codigo_compania = '001';

		   select cod_vendedor
			 into _cod_vendedor
			 from parpromo
			where cod_agente  = v_cod_agente
			  and cod_agencia = _suc_prom
			  and cod_ramo	   = v_cod_ramo;
			
			select nombre
			  into _nombre_vendedor
			  from agtvende
			 where cod_vendedor = _cod_vendedor;							 

			insert into temp_perfil
			values(_no_poliza,
				   _no_documento,
				   _no_factura,
				   v_cod_ramo,
				   v_cod_subramo,
				   v_cod_sucursal,
				   v_cod_grupo,
				   v_cod_tipoprod,
				   v_contratante,
				   v_cod_agente,
				   v_prima_suscrita,
				   v_prima_retenida,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario, 
				   v_suma_asegurada,
				   v_prima_bruta,
				   1,
				   _cod_vendedor,
				   _nombre_vendedor);
		end foreach
		drop table tmp_codigos;
	end if
end if

return v_filtros;
end procedure;