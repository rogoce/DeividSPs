--------------------------------------------
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Modificado por Armando Moreno Sep. 2007 (sacar suma aseg. de unidad para ramo 002,y no de emipomae)
---  Modificado por Amado Perez Abril 2009 Reporte especial para Omar Wong para las reaseguradoras
---  Modificado por Henry Giron Junio 2009 Reporte para Omar Wong por contrato excluyendo fronting y retenciones
---  Modificado por Henry Giron utilizar varias series  [ANT:a_serie char(4) DEFAULT "1900")] Solicitud: Omar Wong 23/07/2010
---  Ref. Power Builder - d_sp_pro02  
---  COpia de sp_rea21b
--   CREATE procedure "informix".sp_rea21a(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codramo CHAR(255),a_serie CHAR(255), a_contrato CHAR(255))
--RETURNING CHAR(255);
--------------------------------------------
drop procedure sp_rea21b;
create procedure "informix".sp_rea21b(
a_compania		char(3),
a_agencia		char(3),
a_codsucursal	char(255),
a_periodo		date,
a_codramo		char(255),
a_serie			char(255),
a_contrato		char(255))
returning	char(255);

begin

define _concat				varchar(255);
define _a_codsucursal		char(255);
define _a_codramo			char(255);
define v_filtros			char(255);
define v_desc_ramo			char(45);
define descr_cia			char(45);
define s_ano_serie_ini		char(25);
define s_ano_serie_fin		char(25);
define _no_documento		char(20);
define v_cod_cliente		char(10);
define v_contratante		char(10);
define _c_asegurado			char(10);
define _no_factura			char(10);
define x_no_poliza			char(10);
define _no_poliza			char(10);
define v_usuario			char(8);
define periodo1				char(7);
define _cod_contrato		char(5);
define v_cod_agente			char(5);
define v_cod_grupo			char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _serie				char(4);
define _a_serie				char(4);
define ano					char(4);
define _cod_ramo_tmp		char(3);
define v_cod_subramo		char(3);
define _cod_cober_reas		char(3);
define v_cod_tipoprod		char(3);
define v_codsucursal		char(3);
define _a_compania			char(3); 
define _a_agencia			char(3);
define v_codramo			char(3);
define mes1					char(2);
define _tipo				char(1);
define v_porc_partic		dec(9,6);
define _porc_prima			dec(9,6);
define v_prima_suscrita		dec(16,2);
define v_prima_retenida		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_suma_aseg_end		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_retenida		dec(16,2);
define v_rango_inicial		dec(16,2);
define _suma_aseg_tot		dec(16,2);
define v_rango_final		dec(16,2);
define _suma_unidad			dec(16,2);
define _limite_2_a			dec(16,2);
define _limite_2_c			dec(16,2);
define _limite_1_b			dec(16,2);
define _limite_max			dec(16,2);
define _prima_cont			dec(16,2);
define _sum_pcont			dec(16,2);
define _sum_fcont			dec(16,2);
define _sum_rcont			dec(16,2);
define rango_min			dec(16,2);
define _sum_cont			dec(16,2);
define _sum_ret				dec(16,2);
define _sum_fac				dec(16,2);
define _prima				dec(16,2);
define _sum_5				dec(16,2);
define _sum_7				dec(16,2);
define tx_dif				dec(16,2);
define x_dif				dec(16,2);	
define v_cant_coasegur1		smallint;
define v_cant_coasegur2		smallint;
define v_cant_polizas		smallint;
define _tipo_contrato		smallint;
define _ano_serie_ini		smallint;
define _ano_serie_fin		smallint;
define _cantidad			smallint;
define _bouquet				smallint;
define codigo1				smallint;
define _front				smallint;
define mes					smallint;
define rango_max			integer;
define _cnt					integer;
define _fecha_cancelacion	date;
define _fecha_serie_ini		date;
define _fecha_serie_fin		date;
define v_vigencia_final		date;
define v_vigencia_inic		date;
define v_fecha_suscrip		date;
define _fecha_emision		date;
define v_fecha_cancel		date;
define _a_periodo			date; 

let descr_cia = sp_sis01(a_compania);

create temp table temp_bouquet
	(no_poliza		char(10),
	no_endoso		char(5),
	cod_contrato	char(5),
	bouquet			smallint default 0,
	front			smallint default 0,
primary key (no_poliza,no_endoso,cod_contrato,bouquet,front)) with no log;
create index i_temp_bouquet0 on temp_bouquet(no_poliza);
create index i_temp_bouquet1 on temp_bouquet(no_endoso);
create index i_temp_bouquet3 on temp_bouquet(cod_contrato);
create index i_temp_bouquet4 on temp_bouquet(bouquet);
create index i_temp_bouquet5 on temp_bouquet(front);

create temp table temp_perfil
	(no_poliza			char(10),
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
	seleccionado		smallint default 0,
	serie				smallint,
	cod_contrato		char(5),
	bouquet				smallint,
	sum_ret				dec(16,2) default 0,
	sum_cont			dec(16,2) default 0,
	sum_fac				dec(16,2) default 0,
	sum_pcont			dec(16,2) default 0,
	sum_fcont			dec(16,2) default 0,
	sum_rcont			dec(16,2) default 0,
	sum_5				dec(16,2) default 0,
	sum_7				dec(16,2) default 0,
	front				smallint  default 0,
primary key (no_poliza)) with no log;

--        PRIMARY KEY (no_poliza,cod_contrato))
--        WITH NO LOG;

--   PRIMARY KEY(no_poliza))
--	CREATE INDEX i_perfil1 ON temp_perfil(no_poliza);
create index i_perfil1 on temp_perfil(cod_contrato);
create index i_perfil2 on temp_perfil(cod_ramo);
create index i_perfil3 on temp_perfil(cod_subramo);
create index i_perfil4 on temp_perfil(cod_tipoprod);
create index i_perfil5 on temp_perfil(cod_sucursal);

let _a_codsucursal		= a_codsucursal;
let _a_compania			= a_compania;
let _a_agencia			= a_agencia;
let _a_periodo			= a_periodo; 
let _a_codramo			= a_codramo;
let v_desc_ramo			= null;
let _no_poliza			= null;
let v_codramo			= null;
let v_cant_coasegur1	= 0;
let v_cant_coasegur2	= 0;
let v_prima_suscrita	= 0;
let v_prima_retenida	= 0;
let v_cant_coasegur1	= 0;
let v_cant_coasegur2	= 0;
let v_suma_asegurada	= 0;
let _prima_suscrita		= 0;
let v_suma_aseg_end		= 0;
let _prima_retenida		= 0;
let v_rango_inicial		= 0;
let v_cant_polizas		= 0;
let v_rango_final		= 0;
let s_ano_serie_fin		= "";
let s_ano_serie_ini		= "";
let v_filtros			= "";
let _ano_serie_ini		= year(today);
let _ano_serie_fin		= year(today);
let mes					= month(a_periodo);

if mes <= 9 then
   let mes1[1,1] = '0';
   let mes1[2,2] = mes;
else
   let mes1 = mes;
end if

let ano = year(a_periodo);
let periodo1[1,4] = ano;
let periodo1[5] = "-";
let periodo1[6,7] = mes1;

set isolation to dirty read;
--   set debug file to "sp_pro02.trc";

if a_serie <> "*" then
	let v_filtros = trim(v_filtros) || "Serie " || trim(a_serie);
	let _tipo = sp_sis04(a_serie); 
--		trace on;
	let a_serie = trim(a_serie);
	let _tipo = trim(_tipo);
	if _tipo <> "E" then
		foreach
			select codigo into s_ano_serie_ini  from tmp_codigos order by 1 
			exit foreach;
		end foreach
		foreach
			select codigo into s_ano_serie_fin  from tmp_codigos order by 1 desc 
			exit foreach;
		end foreach
	end if
	drop table tmp_codigos;

	let _ano_serie_ini   = s_ano_serie_ini;
	let _ano_serie_fin   = s_ano_serie_fin;

	let _fecha_serie_ini = "01/01/" || trim(s_ano_serie_ini);
	let _fecha_serie_fin = "31/12/" || trim(s_ano_serie_fin);

else
	let a_serie = "1900";	 -- si no selecciona serie entonces se mantiene en serie default

	let _ano_serie_ini   = a_serie;
	let _ano_serie_fin   = _ano_serie_ini + 1;
	let _fecha_serie_ini = "01/01/" || _ano_serie_ini;
	let _fecha_serie_fin = "31/12/" || _ano_serie_ini;

	let v_filtros = trim(v_filtros) || "Serie " || trim(a_serie)||" ; ";
end if

if _fecha_serie_fin > a_periodo then
	let _fecha_serie_fin = a_periodo;
end if

--trace off;
--set debug file to "sp_rea21b.trc";
--trace on;

if a_codramo <> "*" then

  let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		foreach
			select a.no_poliza,
				   a.fecha_cancelacion,
				   a.cod_ramo,
				   a.cod_sucursal,
				   a.suma_asegurada,
				   a.cod_tipoprod,
				   b.no_endoso,
				   year(a.vigencia_inic),
				   a.no_documento,
				   a.no_factura,
				   a.cod_subramo,
				   a.cod_grupo,
				   a.cod_contratante,
				   a.vigencia_inic,
				   a.vigencia_final,
				   a.fecha_suscripcion,
				   a.user_added
			  into _no_poliza,
				   v_fecha_cancel,
				   v_codramo,
				   v_codsucursal,
				   v_suma_asegurada,
				   v_cod_tipoprod,
				   _no_endoso,
				   _serie,
				   _no_documento,
				   _no_factura,
				   v_cod_subramo,
				   v_cod_grupo,
				   v_contratante,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario
			  from emipomae a, endedmae b
			 where a.cod_compania      = a_compania
			   and (a.vigencia_final   >= a_periodo
				or a.vigencia_final    is null)
			   and a.fecha_suscripcion <= a_periodo
			   and a.actualizado       = 1
			   and a.cod_ramo          in(select codigo from tmp_codigos)
			   and b.no_poliza         = a.no_poliza
			   and b.periodo           <= periodo1
			   and b.fecha_emision     <= a_periodo
			   and b.actualizado 	   = 1
			   and a.vigencia_inic     >= _fecha_serie_ini
			   and a.vigencia_inic     <  _fecha_serie_fin

			let _fecha_emision = null;

			if v_fecha_cancel <= a_periodo then

				foreach
					select fecha_emision
					  into _fecha_emision
					  from endedmae
					 where no_poliza     = _no_poliza
					   and cod_endomov   = '002'
					   and vigencia_inic = v_fecha_cancel
				end foreach

				if  _fecha_emision <= a_periodo then
					let _prima_suscrita   = 0;
					let _prima_retenida   = 0;
					continue foreach;
				end if
			end if

			let _prima_suscrita   = 0;
			let _prima_retenida   = 0;

			select prima_suscrita,
				   prima_retenida
			  into _prima_suscrita,
				   _prima_retenida
			  from endedmae
			 where no_poliza = _no_poliza
			   and fecha_emision  <= a_periodo
			   and cod_endomov <> '002'
			   and no_endoso = _no_endoso;


			if _prima_suscrita   is null then 
				let _prima_suscrita   = 0;
			end if
			if  _prima_retenida    is null then 
				let _prima_retenida   = 0;
			end if

			let _sum_ret  	= 0.00;
			let _sum_cont 	= 0.00;
			let _sum_fac  	= 0.00;
			let _sum_pcont  = 0.00;
			let _sum_fcont  = 0.00;
			let _sum_rcont  = 0.00;
			let _sum_5 		= 0.00;
			let _sum_7 		= 0.00;
			let _suma_aseg_tot = 0.00;

			foreach
				select a.cod_contrato,
					   a.cod_cober_reas,
					   a.porc_partic_prima,
					   sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato,
					   _cod_cober_reas,
					   _porc_prima,
					   _suma_aseg_tot,
					   _prima_cont
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso
				   and b.cod_endomov <> '002'
				   and a.no_endoso = _no_endoso
				   and b.fecha_emision  <= a_periodo
				 group by a.cod_contrato, a.cod_cober_reas , a.porc_partic_prima
				 order by a.cod_contrato, a.cod_cober_reas , a.porc_partic_prima

				select tipo_contrato,
					   fronting,
					   serie
				  into _tipo_contrato,
					   _front,
					   _serie
				  from reacomae
				 where cod_contrato = _cod_contrato;
					
				select bouquet
				  into _bouquet
				  from reacocob
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas; --"008";

				if _bouquet is null then
					let _bouquet = 0;
				end if

				if _front = 0 then
					begin
						on exception in(-239,-268)
						end exception
							insert into temp_bouquet
									(no_poliza,
									no_endoso,
									cod_contrato,
									bouquet,
									front)
							values	(_no_poliza,
									_no_endoso,
									_cod_contrato,
									_bouquet,
									_front);
					end

					if _tipo_contrato = 1 then			-- Si 	es 100 % retencion entonces no contar 
						if _porc_prima = 100 then
							let _sum_ret  	= 0.00;
							let _sum_cont 	= 0.00;
							let _sum_fac  	= 0.00;
							let _sum_pcont  = 0.00;
							let _sum_fcont  = 0.00;
							let _sum_rcont  = 0.00;
							let _suma_aseg_tot = 0.00;
							let _prima_suscrita = 0.00;
							let _prima_retenida = 0.00;
						else
							let _sum_ret   = _sum_ret   + _suma_aseg_tot;
							let _sum_rcont = _sum_rcont + _prima_cont;
						end if
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
						let _sum_fcont = _sum_fcont + _prima_cont;
					else
						let _sum_cont = _sum_cont + _suma_aseg_tot;
						let _sum_pcont = _sum_pcont + _prima_cont;

						if _tipo_contrato = 5 then
							let _sum_5 = _sum_5 + _suma_aseg_tot;
						end if
						if _tipo_contrato = 7 then
							let _sum_7 = _sum_7 + _suma_aseg_tot;
						end if
					end if
				end if
			end foreach					   

			let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac;

			if  _sum_cont <= 0 then
				continue foreach;
			end if

--			  IF _front = 0 THEN   -- Si encuentran poliza distinta de fronting

			foreach
				select cod_agente,
					   porc_partic_agt
				  into v_cod_agente,
					   v_porc_partic
				  from emipoagt
				 where no_poliza = _no_poliza
				exit foreach;
			end foreach

			begin
				on exception in(-239,-268)
					update temp_perfil
					   set suma_asegurada = suma_asegurada + v_suma_asegurada,
						   prima_suscrita = prima_suscrita + _prima_suscrita,
						   prima_retenida = prima_retenida + _prima_retenida,
						   sum_ret        = sum_ret        + _sum_ret,
						   sum_cont       = sum_cont       + _sum_cont,
						   sum_fac        = sum_fac        + _sum_fac,
						   sum_rcont      = sum_rcont      + _sum_rcont,
						   sum_pcont      = sum_pcont      + _sum_pcont,
						   sum_fcont      = sum_fcont      + _sum_fcont,
						   sum_5          = sum_5          + _sum_5,
						   sum_7          = sum_7          + _sum_7
					 where no_poliza      = _no_poliza;
				end exception

				insert into temp_perfil (
						no_poliza,        
						no_documento,     				 
						no_factura,       				 
						cod_ramo,         				 
						cod_subramo,      				 
						cod_sucursal,     				 
						cod_grupo,        				 
						cod_tipoprod,     				 
						cod_contratante,  				 
						cod_agente,       				 
						prima_suscrita,   				 
						prima_retenida,   				 
						vigencia_inic,    				 
						vigencia_final,   				
						fecha_suscripcion,				 
						usuario,          				 
						suma_asegurada,   				 
						seleccionado,     				 
						serie,			  				 
						cod_contrato,     				  
						bouquet,          				 
						sum_ret,        					 
						sum_cont,         				
						sum_fac,          				 
						sum_pcont,        				 
						sum_fcont,        				 
						sum_rcont,        				 
						sum_5,            				 
						sum_7,
						front )       				 
				values	(_no_poliza,
						_no_documento,
						_no_factura,
						v_codramo,
						v_cod_subramo,
						v_codsucursal,
						v_cod_grupo,
						v_cod_tipoprod,
						v_contratante,
						v_cod_agente,
						_prima_suscrita,
						_prima_retenida,					  
						v_vigencia_inic,
						v_vigencia_final,
						v_fecha_suscrip,
						v_usuario,
						v_suma_asegurada,
						0,
						_serie,
						_cod_contrato,
						_bouquet,
						_sum_ret, 
						_sum_cont,
						_sum_fac,		
						_sum_pcont,
						_sum_fcont,
						_sum_rcont,
						_sum_5,
						_sum_7,	  				  
						_front);
			end
		end foreach
	end if
	drop table tmp_codigos;
end if
--trace off;

-- solo los bouquet y  <> fronting	
foreach
	select distinct no_poliza,
		   cod_contrato 
	  into _no_poliza,
		   _cod_contrato
	  from temp_bouquet 
     where bouquet = 1 
       and front = 0

	update temp_perfil
	   set seleccionado = 1,
	       cod_contrato = _cod_contrato,
	       bouquet      = 1, 
	       front        = 0
	 where no_poliza  = _no_poliza;
end foreach

-- Contratos
if a_contrato <> "*" then
	let v_filtros = trim(v_filtros) ||"Contratos: "||trim(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

{     if _tipo <> "e" then -- incluir los registros

        update temp_perfil
               set seleccionado = 0
             where seleccionado = 1
               and cod_contrato not in(select codigo from tmp_codigos);
     else
        update temp_perfil
               set seleccionado = 0
             where seleccionado = 1
               and cod_contrato in(select codigo from tmp_codigos);
     end if }
	drop table tmp_codigos;
end if	

drop table temp_bouquet;

return v_filtros;
end
end procedure;