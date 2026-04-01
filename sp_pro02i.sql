--------------------------------------------
---            POLIZAS VIGENTES            ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Modificado por Amado Perez Octubre 2001 
---  Modificado por Armando Moreno Nov. 2001 (sacar psuscrita de endosos y no de emipomae)
---  Modificado por Armando Moreno Sep. 2007 (sacar suma aseg. de unidad para ramo 002,y no de emipomae)
---  Modificado por Amado Perez Abril 2009 Reporte especial para Omar Wong para las reaseguradoras
---  Modificado por Henry Giron utilizar varias series  [ANT:a_serie char(4) DEFAULT "1900")] Solicitud: Omar Wong 23/07/2010
---  Ref. Power Builder - d_sp_pro02  execute procedure sp_pro02i("001","*",'31/03/2011',"*","014;", "2008,2009,2010,2011;" )
--------------------------------------------
drop procedure sp_pro02i;
create procedure "informix".sp_pro02i(
a_compania		char(3),
a_agencia		char(03)	default "*",
a_periodo		date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_serie			char(255)	default "*" )
returning dec(16,2),
		  dec(16,2),
		  smallint,
		  dec(16,2),
          dec(16,2),
          smallint,
          smallint,
          char(03),
          char(45),
          date,
          char(45),
          char(255),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          smallint,
          dec(16,2);

begin

define v_filtros			char(255);
define v_desc_ramo			char(45);
define descr_cia			char(45);
define s_ano_serie_ini		char(25);
define s_ano_serie_fin		char(25);
define v_cod_cliente		char(10);
define _no_poliza			char(10);
define periodo1				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _serie				char(4);
define ano					char(4);
define _cod_cober_reas		char(3);
define v_cod_tipoprod		char(3);
define _cod_ramo_tmp		char(3);
define v_codsucursal      	char(3);
define v_codramo			char(3);
define mes1					char(2);
define _tipo				char(1);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_retenida		dec(16,2);
define v_suma_aseg_end		dec(16,2);
define v_rango_inicial		dec(16,2);
define _prima_retenida		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_tot		dec(16,2);
define v_rango_final		dec(16,2);
define _suma_unidad			dec(16,2);
define _sum_fac_car			dec(16,2);
define _limite_2_a			dec(16,2);
define _limite_1_b			dec(16,2);
define _limite_2_c			dec(16,2);
define _limite_max			dec(16,2);
define _rango_min			dec(16,2);
define _sum_cont			dec(16,2);
define _sum_ret				dec(16,2);
define _sum_fac				dec(16,2);
define _prima				dec(16,2);
define codigo1				smallint;
define v_cant_coasegur1		smallint;
define v_cant_coasegur2		smallint;
define v_cant_polizas		smallint;
define _tipo_contrato		smallint;
define _ano_serie_ini		smallint;
define _ano_serie_fin		smallint;
define _cant_unidad			smallint;
define _fronting			smallint;
define _conteo				smallint;
define _mes					smallint;
define _rango_max			integer;
define _cnt					integer;
define _fecha_cancelacion	date;
define _fecha_serie_ini		date;
define _fecha_serie_fin		date;
define _fecha_emision		date;
define _fecha_cancel		date;

create temp table temp_ubica
	(no_poliza		char(10),
	no_unidad		char(5),
	suma_asegurada	dec(16,2),
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	prima_ret_caso	dec(16,2),
	sum_ret			dec(16,2) default 0,
	sum_ret_casco	dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	sum_fac_car		dec(16,2) default 0,
	serie			char(4),
	seleccionado	smallint  default 1,
	primary key (no_poliza,no_unidad)) with no log;
create index iend1_temp_ubica on temp_ubica(no_poliza);
create index iend2_temp_ubica on temp_ubica(no_unidad);

create temp table temp_conteo
	(no_poliza		char(10),
	no_unidad		char(5),
	seleccionado	smallint  default 1,
	primary key (no_poliza,no_unidad)) with no log;
create index iend1_temp_conteo on temp_conteo(no_poliza);
create index iend2_temp_conteo on temp_conteo(no_unidad);


create temp table temp_unidad
	(no_poliza		char(10),
	no_unidad		char(5),
	suma_asegurada	dec(16,2),
	cod_ramo		char(3),
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	prima_ret_caso	dec(16,2),
	serie			char(4),
	sum_ret			dec(16,2) default 0,
	sum_ret_casco	dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	sum_fac_car		dec(16,2) default 0,
	seleccionado	smallint default 1,
	primary key (no_poliza,no_unidad,cod_ramo))	with no log;
create index iend1_temp_unidad on temp_unidad(no_poliza);
create index iend2_temp_unidad on temp_unidad(no_unidad);
create index iend3_temp_unidad on temp_unidad(cod_ramo);

let descr_cia = sp_sis01(a_compania);

create temp table temp_civil
	(cod_sucursal	char(03),
	cod_ramo		char(03),
	rango_inicial	dec(16,2),
	rango_final		dec(16,2),
	cant_polizas	smallint,
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	prima_ret_caso	dec(16,2),
	cant_coasegur1	smallint,
	cant_coasegur2	smallint,
	seleccionado	smallint default 1,
	suma_asegurada	dec(16,2),	
	sum_ret			dec(16,2) default 0,
	sum_ret_casco	dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	cant_unidad		smallint,
	sum_fac_car		dec(16,2) default 0,
	primary key (cod_ramo,rango_inicial)) with no log;
create index iend1_temp_civil on temp_civil(cod_ramo);
create index iend2_temp_civil on temp_civil(rango_inicial);
create index iend3_temp_civil on temp_civil(rango_final);

create temp table temp_fact
	(no_poliza		char(10),
	no_endoso		char(5),
	no_factura		char(10),
	seleccionado	smallint  default 1,
	suma_asegurada	dec(16,2),	
	sum_ret			dec(16,2) default 0,
	sum_ret_casco	dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	sum_fac_car		dec(16,2) default 0,
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
primary key (no_poliza,no_endoso,no_factura)) with no log;
create index iend1_temp_fact on temp_fact(no_poliza);
create index iend2_temp_fact on temp_fact(no_endoso);
create index iend3_temp_fact on temp_fact(no_factura);

let v_codramo			= null;
let v_desc_ramo			= null;
let v_cant_coasegur1	= 0;
let v_cant_coasegur2	= 0;
let v_prima_suscrita	= 0;
let v_prima_retenida	= 0;
let v_suma_asegurada	= 0;
let v_cant_coasegur1	= 0;
let v_cant_coasegur2	= 0;
let _prima_suscrita		= 0;
let _prima_retenida		= 0;
let v_suma_aseg_end		= 0;
let v_rango_inicial		= 0;
let v_cant_polizas		= 0;
let v_rango_final		= 0;
let _cant_unidad		= 0;
let _fronting			= 0;
let _conteo				= 1;
let s_ano_serie_ini		= "";
let s_ano_serie_fin		= "";
let _cod_cober_reas		= "";
let _no_poliza			= null;
let v_filtros			= "";
let _ano_serie_ini		= year(today);
let _ano_serie_fin		= year(today);

let _mes = month(a_periodo);

if _mes <= 9 then
   let mes1[1,1] = '0';
   let mes1[2,2] = _mes;
else
   let mes1 = _mes;
end if

let ano = year(a_periodo);
let periodo1[1,4] = ano;
let periodo1[5] = "-";
let periodo1[6,7] = mes1;

set isolation to dirty read;
--set debug file to "sp_pro02.trc";

if a_serie <> "*" then
	let v_filtros = trim(v_filtros) || "Serie " || TRIM(a_serie);
	let _tipo = sp_sis04(a_serie); 
	let a_serie = trim(a_serie); 
	let _tipo = trim(_tipo); 
	
	if _tipo <> "E" THEN 
		foreach 
			select codigo 
			  into s_ano_serie_ini
			  from tmp_codigos 
			 order by 1 
			exit foreach; 
		end foreach 
		
		foreach 
			select codigo
			  into s_ano_serie_fin
			  from tmp_codigos
			 order by 1 desc 
			exit foreach; 
		end foreach 
	end if 
	
	drop table tmp_codigos; 

	let _ano_serie_ini   = s_ano_serie_ini; 
	let _ano_serie_fin   = s_ano_serie_fin; 

	let _fecha_serie_ini = "01/01/" || trim(s_ano_serie_ini);
	let _fecha_serie_fin = "31/12/" || trim(s_ano_serie_fin);
else
	let a_serie = "1900";	 -- si no selecciona serie entonces se mantien en serie default
	let _ano_serie_ini   = a_serie;
	let _ano_serie_fin   = _ano_serie_ini + 1;
	let _fecha_serie_ini = "01/01/" || _ano_serie_ini;	
	let _fecha_serie_fin = "31/12/" || periodo1[1,4];
	let v_filtros = trim(v_filtros) || "Serie " || trim(a_serie)||" ; ";
end if

if _fecha_serie_fin > a_periodo then
	let _fecha_serie_fin = a_periodo;
end if


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
				   year(a.vigencia_inic)
			  into _no_poliza,
				   _fecha_cancel,
				   v_codramo,
				   v_codsucursal,
				   v_suma_asegurada,
				   v_cod_tipoprod,
				   _no_endoso,
				   _serie
			  from emipomae a, endedmae b
			 where a.cod_compania       = a_compania
			   and (a.vigencia_final   >= a_periodo
				or a.vigencia_final    is null)
			   and a.fecha_suscripcion <= a_periodo
			   and a.actualizado        = 1
			   and a.cod_ramo          in(select codigo from tmp_codigos)
			   and b.no_poliza          = a.no_poliza
			   and b.periodo           <= periodo1
			   and b.fecha_emision     <= a_periodo
			   and b.actualizado 	    = 1
			   and a.vigencia_inic     >= _fecha_serie_ini
			   and a.vigencia_inic     <= _fecha_serie_fin
--				   and b.no_documento       = "1411-00014-01" --"0109-00401-01"

			let _fronting = 0;
			let _fronting = sp_sis135(_no_poliza);

			if _fronting = 1 then -- es fronting
				continue foreach;
			end if

			let _fecha_emision = null;

			if _fecha_cancel <= a_periodo then
				foreach
					select fecha_emision
					  into _fecha_emision
					  from endedmae
					 where no_poliza     = _no_poliza
					   and cod_endomov   = '002'
					   and vigencia_inic = _fecha_cancel
				end foreach

				if  _fecha_emision <= a_periodo then
					let _prima_suscrita   = 0;
					let _prima_retenida   = 0;
					continue foreach;
				end if
			end if

			--sacar suma asegurada de la unidad
			if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
				let _prima = 0;
{					foreach
					select suma_asegurada,
						   no_unidad
					  into _suma_unidad,
						   _no_unidad
					  from emipouni
					 where no_poliza = _no_poliza	}
				foreach
					select b.no_unidad,
						   b.suma_asegurada
					  into _no_unidad,
						   _suma_unidad
					  from endedmae a, endeduni b
					 where a.no_poliza = _no_poliza
					   and a.no_endoso = _no_endoso
					   and a.no_poliza = b.no_poliza
					   and a.no_endoso = b.no_endoso

					select sum(prima_suscrita),
						   sum(prima_retenida)
					  into _prima_suscrita,
						   _prima_retenida
					  from endeduni
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;

					if v_codramo = "002" then
					   let _prima_retenida = 0;
					end if

					let _prima_ret_rasco  = 0.00;
					let _sum_ret_casco  = 0.00;
					let _sum_ret      = 0.00;
					let _sum_cont     = 0.00;
					let _sum_fac      = 0.00;
					let _sum_fac_car  = 0.00;
					
					foreach
						select a.cod_contrato,
							   a.cod_cober_reas,
							   sum(a.suma_asegurada),
							   sum(a.prima)
						  into _cod_contrato,
							   _cod_cober_reas,
							   _suma_aseg_tot,
							   _prima
						  from emifacon a, endedmae b
						 where a.no_poliza = _no_poliza
						   and a.no_poliza = b.no_poliza
						   and a.no_endoso = b.no_endoso
						   and a.no_unidad = _no_unidad
						   and a.no_endoso = _no_endoso
						   and b.cod_endomov <> '002'
						 group by a.cod_contrato,a.cod_cober_reas
						 order by a.cod_contrato,a.cod_cober_reas

						if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
						   continue foreach;
						end if

						select tipo_contrato
						  into _tipo_contrato
						  from reacomae
						 where cod_contrato = _cod_contrato;
						
						if _tipo_contrato = 1 then
							if v_codramo = '002' then
								if _cod_cober_reas = '002' then	--Retención RC
									let _sum_ret = _sum_ret + _suma_aseg_tot;
									let _prima_retenida = _prima_retenida + _prima;
								else							--Retencion Casco
									let _sum_ret_casco = _sum_ret_casco + _suma_aseg_tot;
									let _prima_ret_rasco = _prima_ret_rasco + _prima;
								end if
							else
								let _sum_ret = _sum_ret + _suma_aseg_tot;
							end if
						elif _tipo_contrato = 3 then
							let _sum_fac = _sum_fac + _suma_aseg_tot;
						else
							if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
							   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
							else
							   let _sum_cont = _sum_cont + _suma_aseg_tot;
							end if
						end if
					end foreach	
						
					let v_suma_asegurada = _sum_ret_casco + _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

					if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
						continue foreach;
					end if

					begin
						on exception in(-239,-268)
							update temp_unidad
							   set sum_ret			= sum_ret     + _sum_ret, 
								   sum_ret_casco	= sum_ret_casco    + _sum_ret_casco,
								   sum_cont			= sum_cont    + _sum_cont,
								   sum_fac			= sum_fac     + _sum_fac,
								   sum_fac_car		= sum_fac_car + _sum_fac_car		
							 where no_poliza		= _no_poliza
							   and no_unidad		= _no_unidad;
						end exception

						insert into temp_unidad
						values(
						_no_poliza,
						_no_unidad,
						_suma_unidad,
						v_codramo,
						_prima_suscrita,
						_prima_retenida,
						_prima_ret_rasco,
						_serie,
						_sum_ret,
						_sum_ret_casco,
						_sum_cont,
						_sum_fac,
						_sum_fac_car,
						1);
					end

					begin
						on exception in(-239,-268)
						end exception

						insert into temp_fact	( no_poliza,    
											  no_endoso,    
											  no_factura,   
											  seleccionado,
											  suma_asegurada,  
											  sum_ret,         
											  sum_cont,        
											  sum_fac,              
											  sum_fac_car,
											  prima_suscrita,
											  prima_retenida							      						       								      						  
											  )
						select no_poliza,  
							   no_endoso,
							   no_factura,
							   1,
							   v_suma_asegurada,
							   _sum_ret,
							   _sum_cont,
							   _sum_fac,
							   _sum_fac_car,
							   prima_suscrita,
							   prima_retenida							      		   				     
						  from endedmae
						 where no_poliza = _no_poliza 
						   and no_endoso = _no_endoso;
					end
				end foreach
			end if
			
			foreach
				select b.no_unidad,
					   b.prima_suscrita, 
					   b.prima_retenida
				  into _no_unidad,
					   _prima_suscrita,
					   _prima_retenida
				  from endedmae a, endeduni b
				 where a.no_poliza = _no_poliza
				   and a.no_endoso = _no_endoso
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso

				let _sum_ret  = 0.00;
				let _sum_cont = 0.00;
				let _sum_fac  = 0.00;
				let _sum_fac_car  = 0.00;

				foreach
					select a.cod_contrato,
						   a.cod_cober_reas,
						   sum(a.suma_asegurada)
					  into _cod_contrato,
						   _cod_cober_reas,
						   _suma_aseg_tot
					  from emifacon a, endedmae b
					 where a.no_poliza = _no_poliza
					   and a.no_poliza = b.no_poliza
					   and a.no_endoso = b.no_endoso
					   and a.no_unidad = _no_unidad
					   and a.no_endoso = _no_endoso
					   and b.cod_endomov <> '002'
					 group by a.cod_contrato,a.cod_cober_reas
					 order by a.cod_contrato,a.cod_cober_reas

					if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
					   continue foreach;
					end if

					select tipo_contrato
					  into _tipo_contrato
					  from reacomae
					 where cod_contrato = _cod_contrato;

					if _tipo_contrato = 1 then
						let _sum_ret = _sum_ret + _suma_aseg_tot;
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
					else
						if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
						   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
						else
						   let _sum_cont = _sum_cont + _suma_aseg_tot;
						end if
					end if
				end foreach	

				let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

				if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					continue foreach;
				end if

				if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
				else
					begin
						on exception in(-239,-268)
							update temp_ubica
							   set prima_suscrita = prima_suscrita + _prima_suscrita,
								   prima_retenida = prima_retenida + _prima_retenida,
								   sum_ret        = sum_ret     + _sum_ret, 
								   sum_cont       = sum_cont    + _sum_cont,
								   sum_fac        = sum_fac     + _sum_fac,
								   sum_fac_car    = sum_fac_car + _sum_fac_car,
								   suma_asegurada = suma_asegurada + v_suma_asegurada										
							 where no_poliza      = _no_poliza; 
						end exception

						insert into temp_ubica
						values
						(
						_no_poliza,
						_no_unidad,
						v_suma_asegurada,
						_prima_suscrita,
						_prima_retenida,
						_sum_ret, 
						_sum_cont,
						_sum_fac,
						_sum_fac_car,
						_serie,
						1
						);
				   end

					begin
						on exception in(-239,-268)
						end exception

						insert into temp_fact	(
								no_poliza,    
								no_endoso,    
								no_factura,   
								seleccionado,
								suma_asegurada,  
								sum_ret,         
								sum_cont,        
								sum_fac,              
								sum_fac_car,
								prima_suscrita,
								prima_retenida)
						select	no_poliza,  
								no_endoso,  
								no_factura, 
								1,
								v_suma_asegurada,
								_sum_ret,
								_sum_cont,
								_sum_fac,
								_sum_fac_car,
								prima_suscrita,
								prima_retenida
						  from endedmae
						 where no_poliza = _no_poliza 
						   and no_endoso = _no_endoso;
					end
				end if
			end foreach
		end foreach
	else
		foreach
			select a.no_poliza,
				   a.fecha_cancelacion,
				   a.cod_ramo,
				   a.cod_sucursal,
				   a.suma_asegurada,
				   a.cod_tipoprod,
				   b.no_endoso,
				   year(a.vigencia_inic)
			  into _no_poliza,
				   _fecha_cancel,
				   v_codramo,
				   v_codsucursal,
				   v_suma_asegurada,
				   v_cod_tipoprod,
				   _no_endoso,
				   _serie
			  from emipomae a, endedmae b
			 where a.cod_compania      = a_compania
			   and (a.vigencia_final   >= a_periodo or a.vigencia_final    is null)
			   and a.fecha_suscripcion <= a_periodo
			   and a.actualizado       = 1
			   and a.cod_ramo         not in(select codigo from tmp_codigos)
			   and b.no_poliza         = a.no_poliza
			   and b.periodo           <= periodo1
			   and b.fecha_emision     <= a_periodo
			   and b.actualizado 	   = 1
			   and a.vigencia_inic     >= _fecha_serie_ini
			   and a.vigencia_inic     <=  _fecha_serie_fin

			let _fecha_emision = null;

			if _fecha_cancel <= a_periodo then
				foreach
					select fecha_emision
					  into _fecha_emision
					  from endedmae
					 where no_poliza     = _no_poliza
					   and cod_endomov   = '002'
					   and vigencia_inic = _fecha_cancel
				end foreach

				if  _fecha_emision <= a_periodo then
					let _prima_suscrita   = 0;
					let _prima_retenida   = 0;
					continue foreach;
				end if
			end if

			--sacar suma asegurada de la unidad
			if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
				let _prima = 0;

				foreach
					select suma_asegurada,
						   no_unidad
					  into _suma_unidad,
						   _no_unidad
					  from emipouni
					 where no_poliza = _no_poliza

					select sum(prima_suscrita),
						   sum(prima_retenida)
					  into _prima_suscrita,
						   _prima_retenida
					  from endeduni
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;

					if v_codramo = "002" then
					   let _prima_retenida = _prima_suscrita;
					end if

					begin
						on exception in(-239)
						end exception

						insert into temp_unidad
						values(
						_no_poliza,
						_no_unidad,
						_suma_unidad,
						v_codramo,
						_prima_suscrita,
						_prima_retenida,
						_serie,
						0.00,
						0.00,
						0.00,
						0.00,
						1);
					end

					begin
						on exception in(-239,-268)
						end exception

						insert into temp_fact	( no_poliza,    
								no_endoso,    
								no_factura,   
								seleccionado,
								suma_asegurada,  
								sum_ret,         
								sum_cont,        
								sum_fac,              
								sum_fac_car,
								prima_suscrita,
								prima_retenida)
						select	no_poliza,  
								no_endoso,  
								no_factura, 
								1,
								v_suma_asegurada, 
								_sum_ret,     				      
								_sum_cont,    				      
								_sum_fac,     				      			      
								_sum_fac_car,
								prima_suscrita,
								prima_retenida							      		   				     
						  from endedmae
						 where no_poliza = _no_poliza 
						   and no_endoso = _no_endoso;
					end
				end foreach
			end if

			foreach
				select b.no_unidad,
					   b.prima_suscrita, 
					   b.prima_retenida
				  into _no_unidad,
					   _prima_suscrita,
					   _prima_retenida
				  from endedmae a, endeduni b
				 where a.no_poliza = _no_poliza
				   and a.no_endoso = _no_endoso
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso

				let _sum_ret  = 0.00;
				let _sum_cont = 0.00;
				let _sum_fac  = 0.00;
				let _sum_fac_car  = 0.00;

				foreach
					select a.cod_contrato,
						   a.cod_cober_reas,
						   sum(a.suma_asegurada)
					  into _cod_contrato,
						   _cod_cober_reas,
						   _suma_aseg_tot
					  from emifacon a, endedmae b
					 where a.no_poliza = _no_poliza
					   and a.no_poliza = b.no_poliza
					   and a.no_endoso = b.no_endoso
					   and a.no_unidad = _no_unidad
					   and a.no_endoso = _no_endoso
					   and b.cod_endomov <> '002'
					 group by a.cod_contrato,a.cod_cober_reas
					 order by a.cod_contrato,a.cod_cober_reas

					if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
					   continue foreach;
					end if

					select tipo_contrato
					  into _tipo_contrato
					  from reacomae
					 where cod_contrato = _cod_contrato;

					if _tipo_contrato = 1 then
						let _sum_ret = _sum_ret + _suma_aseg_tot;
					elif _tipo_contrato = 3 then
						let _sum_fac = _sum_fac + _suma_aseg_tot;
					else
						if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
						   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
						else
						   let _sum_cont = _sum_cont + _suma_aseg_tot;
						end if
					end if
				end foreach					   
						
				let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

				if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
					continue foreach;
				end if

				if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
				else
					begin
						on exception in(-239,-268)
							update temp_ubica
							   set prima_suscrita = prima_suscrita + _prima_suscrita,
								   prima_retenida = prima_retenida + _prima_retenida,
								   sum_ret        = sum_ret     + _sum_ret, 
								   sum_cont       = sum_cont    + _sum_cont,
								   sum_fac        = sum_fac     + _sum_fac,
								   sum_fac_car    = sum_fac_car + _sum_fac_car,
								   suma_asegurada = suma_asegurada + v_suma_asegurada										
							 where no_poliza      = _no_poliza; 

						end exception

						insert into temp_ubica
						values(
						_no_poliza,
						_no_unidad,
						v_suma_asegurada,
						_prima_suscrita,
						_prima_retenida,
						_sum_ret, 
						_sum_cont,
						_sum_fac,
						_sum_fac_car,
						_serie,
						1);
					end

					begin
						on exception in(-239,-268)
						end exception

						insert into temp_fact
								(no_poliza,    
								no_endoso,    
								no_factura,   
								seleccionado,
								suma_asegurada,  
								sum_ret,         
								sum_cont,        
								sum_fac,              
								sum_fac_car,
								prima_suscrita,
								prima_retenida)
						select	no_poliza,  
								no_endoso,  
								no_factura, 
								1,
								v_suma_asegurada, 
								_sum_ret,     				      
								_sum_cont,    				      
								_sum_fac,     				      			      
								_sum_fac_car,
								prima_suscrita,
								prima_retenida							      		   				     
						  from endedmae
						 where no_poliza = _no_poliza 
						   and no_endoso = _no_endoso;
					end
				end if
			end foreach
		end foreach
	end if
	drop table tmp_codigos;
else
	foreach
		select a.no_poliza,
	           a.fecha_cancelacion,
	           a.cod_ramo,
	           a.cod_sucursal,
	           a.suma_asegurada,
	           a.cod_tipoprod,
			   b.no_endoso,
			   year(a.vigencia_inic)
	      into _no_poliza,
	           _fecha_cancel,
	           v_codramo,
	           v_codsucursal,
	           v_suma_asegurada,
	           v_cod_tipoprod,
			   _no_endoso,
			   _serie
	      from emipomae a, endedmae b
	     where a.cod_compania      = a_compania
	       and (a.vigencia_final   >= a_periodo
	   	    or a.vigencia_final    is null)
		   and a.fecha_suscripcion <= a_periodo
		   and a.actualizado       = 1
		   and b.no_poliza         = a.no_poliza
		   and b.periodo           <= periodo1
		   and b.fecha_emision     <= a_periodo
	   	   and b.actualizado 	   = 1
	   	   and a.vigencia_inic     >= _fecha_serie_ini
		   and a.vigencia_inic     <=  _fecha_serie_fin

	    let _fecha_emision = null;

	    if _fecha_cancel <= a_periodo then
		    foreach
				select fecha_emision
				  into _fecha_emision
				  from endedmae
				 where no_poliza     = _no_poliza
				   and cod_endomov   = '002'
				   and vigencia_inic = _fecha_cancel
			end foreach

			if  _fecha_emision <= a_periodo then
			    let _prima_suscrita   = 0;
				let _prima_retenida   = 0;
				continue foreach;
			end if
		end if

		--sacar suma asegurada de la unidad

		if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			let _prima = 0;

			foreach
			    select suma_asegurada,
				       no_unidad
				  into _suma_unidad,
					   _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza

				select sum(prima_suscrita),
				       sum(prima_retenida)
				  into _prima_suscrita,
					   _prima_retenida
				  from endeduni
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;

				if v_codramo = "002" then
				   let _prima_retenida = _prima_suscrita;
				end if

				begin
					on exception in(-239)
					end exception

					insert into temp_unidad
					values(
						_no_poliza,
						_no_unidad,
						_suma_unidad,
						v_codramo,
						_prima_suscrita,
						_prima_retenida,
						_serie,
						0.00,
						0.00,
						0.00,
						0.00,
						1);

					insert into temp_conteo
					values(
						_no_poliza,
						_no_unidad,
						1 );
				end
				
				begin
					on exception in(-239,-268)
					end exception

					insert into temp_fact	( no_poliza,    
							no_endoso,    
							no_factura,   
							seleccionado,
							suma_asegurada,  
							sum_ret,         
							sum_cont,        
							sum_fac,              
							sum_fac_car,
							prima_suscrita,
							prima_retenida)
					select	no_poliza,  
							no_endoso,  
							no_factura, 
							1,
							v_suma_asegurada, 
							_sum_ret,     				      
							_sum_cont,    				      
							_sum_fac,     				      			      
							_sum_fac_car,
							prima_suscrita,
							prima_retenida							      		   				     
					  from endedmae
					 where no_poliza = _no_poliza 
					   and no_endoso = _no_endoso;
				end
			end foreach
		end if

		foreach
			select b.no_unidad,
				   b.prima_suscrita, 
				   b.prima_retenida
			  into _no_unidad,
				   _prima_suscrita,
				   _prima_retenida
			  from endedmae a, endeduni b
			 where a.no_poliza = _no_poliza
			   and a.no_endoso = _no_endoso
			   and a.no_poliza = b.no_poliza
			   and a.no_endoso = b.no_endoso

			let _sum_ret  = 0.00;
			let _sum_cont = 0.00;
			let _sum_fac  = 0.00;
			let _sum_fac_car  = 0.00;

			foreach
				select a.cod_contrato,a.cod_cober_reas,
					   sum(a.suma_asegurada)
				  into _cod_contrato,
					   _cod_cober_reas,
					   _suma_aseg_tot
				  from emifacon a, endedmae b
				 where a.no_poliza = _no_poliza
				   and a.no_poliza = b.no_poliza
				   and a.no_endoso = b.no_endoso
				   and a.no_unidad = _no_unidad
				   and a.no_endoso = _no_endoso
				   and b.cod_endomov <> '002'
				 group by a.cod_contrato,a.cod_cober_reas
				 order by a.cod_contrato,a.cod_cober_reas

				if (v_codramo = "001" or v_codramo = "003") and _cod_cober_reas = '021' then
				   continue foreach;
				end if

				select tipo_contrato
				  into _tipo_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _tipo_contrato = 1 then
					let _sum_ret = _sum_ret + _suma_aseg_tot;
				elif _tipo_contrato = 3 then
					let _sum_fac = _sum_fac + _suma_aseg_tot;
				else
					if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
					   let _sum_fac_car = _sum_fac_car + _suma_aseg_tot;
					else
					   let _sum_cont = _sum_cont + _suma_aseg_tot;
					end if
				end if

			end foreach					   
					
			let v_suma_asegurada = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

			if _sum_fac = v_suma_asegurada and _sum_fac > 0 then
				continue foreach;
			end if

			if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			else
				begin
					on exception in(-239,-268)
						update temp_ubica
						   set prima_suscrita = prima_suscrita + _prima_suscrita,
							   prima_retenida = prima_retenida + _prima_retenida,
							   sum_ret        = sum_ret     + _sum_ret, 
							   sum_cont       = sum_cont    + _sum_cont,
							   sum_fac        = sum_fac     + _sum_fac,
							   sum_fac_car    = sum_fac_car + _sum_fac_car,
							   suma_asegurada = suma_asegurada + v_suma_asegurada										
						 where no_poliza      = _no_poliza;
					end exception

					insert into temp_ubica
					values(
					_no_poliza,
					_no_unidad,
					v_suma_asegurada,
					_prima_suscrita,
					_prima_retenida,
					_sum_ret, 
					_sum_cont,
					_sum_fac,
					_sum_fac_car,
					_serie,
					1);
				end

				begin
					on exception in(-239,-268)
					end exception

					insert into temp_fact	( no_poliza,    
						no_endoso,    
						no_factura,   
						seleccionado,
						suma_asegurada,  
						sum_ret,         
						sum_cont,        
						sum_fac,              
						sum_fac_car,
						prima_suscrita,
						prima_retenida)
					select	no_poliza,  
							no_endoso,  
							no_factura, 
							1,
							v_suma_asegurada, 
							_sum_ret,     				      
							_sum_cont,    				      
							_sum_fac,     				      			      
							_sum_fac_car,
							prima_suscrita,
							prima_retenida							      		   				     
					  from endedmae
					 where no_poliza = _no_poliza 
					   and no_endoso = _no_endoso;
				end
			end if
		end foreach
	end foreach
end if

--agregar limite maximo + suma asegurada
foreach
	select no_poliza,
	       no_unidad,
		   suma_asegurada,
		   prima_suscrita,
		   prima_retenida,
		   serie
	  into _no_poliza,
	       _no_unidad,
		   _suma_unidad,
		   _prima_suscrita,
		   _prima_retenida,
		   _serie
	  from temp_unidad
	 where cod_ramo = "002"

	select limite_2
	  into _limite_2_a
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00102";

	select limite_1
	  into _limite_1_b
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00113";

	if _limite_1_b is null then

		select limite_1						   
		  into _limite_1_b
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = "00671";

	end if

	if _limite_1_b is null then
		let _limite_1_b = 0;
	end if

	select limite_2
	  into _limite_2_c
	  from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = "00107";

	let _limite_max = _suma_unidad + _limite_2_a + _limite_1_b + _limite_2_c;

    begin
		on exception in(-239)
		end exception
		
		insert into temp_unidad
		values(
		_no_poliza,
		_no_unidad,
		_limite_max,
		'999',
		_prima_suscrita,
		_prima_retenida,
		_serie,
		1);
	end
end foreach

delete from tmp_sp_pro2i;

foreach
	select no_poliza,
		   no_unidad,
		   suma_asegurada,
		   prima_suscrita,
		   prima_retenida,
		   sum_ret,
		   sum_cont,
		   sum_fac,
		   sum_fac_car
	  into _no_poliza,
		   _no_unidad,
		   v_suma_asegurada,
		   _prima_suscrita,
		   _prima_retenida,
		   _sum_ret,
		   _sum_cont,
		   _sum_fac,
		   _sum_fac_car
	  from temp_ubica
	 where seleccionado = 1

	let _suma_aseg_tot = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

	if v_suma_asegurada <> _suma_aseg_tot then
		insert into tmp_sp_pro2i
		values(
		_no_poliza,
		v_suma_asegurada,
		_sum_ret, 
		_sum_cont,
		_sum_fac);
	end if

	insert into temp_conteo
	values(
	_no_poliza,
	_no_unidad,
	1);

	select cod_ramo
	  into v_codramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select emitipro.tipo_produccion
	  into codigo1
	  from emitipro,emipomae
	 where emitipro.cod_tipoprod = emipomae.cod_tipoprod 
	   and emipomae.no_poliza = _no_poliza;

	if codigo1 = 2 or codigo1 = 3  then
		let v_cant_coasegur1 = 1;
		let v_cant_coasegur2 = 0;
	else
		let v_cant_coasegur1 = 0;
		let v_cant_coasegur2 = 1;
	end if;

	select parinfra.rango1, 
		   parinfra.rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where parinfra.cod_ramo = v_codramo
	   and parinfra.rango1 <= v_suma_asegurada	   
	   and parinfra.rango2 >= v_suma_asegurada;

	if v_rango_inicial is null then
	  continue foreach;
	end if;

	if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
	else
		begin
			on exception in(-239)
			
				let _conteo = 0;
			
				select count(*)
				  into _conteo
				  from temp_conteo
				 where no_poliza = _no_poliza;
				
				if _conteo > 1 then
					let _conteo = 0;
				else
					let _conteo = 1;
				end if

				update temp_civil
                   set cant_polizas   = cant_polizas	+ _conteo, --1,
					   prima_suscrita = prima_suscrita	+ _prima_suscrita,
					   prima_retenida = prima_retenida	+ _prima_retenida,
					   cant_coasegur1 = cant_coasegur1	+ v_cant_coasegur1,
					   cant_coasegur2 = cant_coasegur2	+ v_cant_coasegur2,
					   suma_asegurada = suma_asegurada	+ v_suma_asegurada,
					   sum_ret        = sum_ret			+ _sum_ret,
					   sum_cont       = sum_cont	    + _sum_cont,
					   sum_fac        = sum_fac			+ _sum_fac,
					   sum_fac_car    = sum_fac_car		+ _sum_fac_car,
					   cant_unidad    = cant_unidad		+ 1
				 where cod_ramo       = v_codramo
				   and rango_inicial  = v_rango_inicial
				   and rango_final    = v_rango_final;
			end exception

			insert into temp_civil
			values(
			v_codsucursal,
			v_codramo,
			v_rango_inicial,
			v_rango_final,
			1,
			_prima_suscrita,
			_prima_retenida,
			v_cant_coasegur1,
			v_cant_coasegur2,
			1,
			v_suma_asegurada,
			_sum_ret, 
			_sum_cont,
			_sum_fac,
			1,
			_sum_fac_car);
		end
	end if

	let _prima_suscrita   = 0;
	let _prima_retenida   = 0;
end foreach

let _cod_ramo_tmp = "";

foreach
	select no_poliza,
		   no_unidad,
		   suma_asegurada,
		   cod_ramo,
		   prima_suscrita,
		   prima_retenida,
		   sum_ret,
		   sum_cont,
		   sum_fac,
		   sum_fac_car
	  into _no_poliza,
		   _no_unidad,
		   v_suma_asegurada,
		   v_codramo,
		   _prima_suscrita,
		   _prima_retenida,
		   _sum_ret,
		   _sum_cont,
		   _sum_fac,
		   _sum_fac_car
	  from temp_unidad
	 where seleccionado = 1
	 order by cod_ramo
	  
	if v_codramo = "999" then
		let _cod_ramo_tmp = v_codramo;
		let v_codramo = "002";
	end if
	
	let _suma_aseg_tot = 0;
	let _suma_aseg_tot = _sum_ret + _sum_cont + _sum_fac + _sum_fac_car;

	if v_suma_asegurada <> _suma_aseg_tot then
		insert into tmp_sp_pro2i
		values(
		_no_poliza,
		v_suma_asegurada,
		_sum_ret, 
		_sum_cont,
		_sum_fac);

		continue foreach;
	end if

	insert into temp_conteo
	values(
		_no_poliza,
		_no_unidad,
		1 );

	select parinfra.rango1, 
		   parinfra.rango2
	  into v_rango_inicial,
	  	   v_rango_final
	  from parinfra
	 where parinfra.cod_ramo = v_codramo
	   and parinfra.rango1 <= v_suma_asegurada	   
	   and parinfra.rango2 >= v_suma_asegurada;

	if _cod_ramo_tmp = "999" then
		let v_codramo = _cod_ramo_tmp;
		let _cod_ramo_tmp = "";
	end if

	if v_rango_inicial is null then
		continue foreach;
	end if;

	select emitipro.tipo_produccion
	  into codigo1
	  from emitipro,emipomae
	 where emitipro.cod_tipoprod = emipomae.cod_tipoprod 
	   and emipomae.no_poliza = _no_poliza;

	if codigo1 = 2 or codigo1 = 3 then
		let v_cant_coasegur1 = 1;
		let v_cant_coasegur2 = 0;
	else
		let v_cant_coasegur1 = 0;
		let v_cant_coasegur2 = 1;
	end if;
	
	let _conteo = 1;

	begin
		on exception in(-239)
			if v_codramo = "016" then
				let _conteo = 0;
				
				select count(*)
				  into _conteo
				  from temp_conteo
				 where	no_poliza = _no_poliza;
				
				if _conteo > 1 then
					let _conteo = 0;
				else
					let _conteo = 1;
				end if
			end if

			update temp_civil
			   set suma_asegurada = suma_asegurada + v_suma_asegurada,
				   cant_polizas   = cant_polizas   + _conteo, --1,
				   prima_suscrita = prima_suscrita + _prima_suscrita,
				   prima_retenida = prima_retenida + _prima_retenida,
				   cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
				   cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2,
				   sum_ret        = sum_ret	    + _sum_ret,
				   sum_cont       = sum_cont	    + _sum_cont,
				   sum_fac        = sum_fac	    + _sum_fac,
				   sum_fac_car    = sum_fac_car    + _sum_fac_car,
				   cant_unidad    = cant_unidad    + 1
			 where cod_ramo       = v_codramo
			   and rango_inicial  = v_rango_inicial
			   and rango_final    = v_rango_final;
			end exception

			insert into temp_civil
			values(
				v_codsucursal,	   
				v_codramo,		   
				v_rango_inicial,	   
				v_rango_final,	   
				_conteo,				   
				_prima_suscrita,	   
				_prima_retenida,	   
				v_cant_coasegur1,	   
				v_cant_coasegur2,	   
				1,				   
				v_suma_asegurada,	   
				_sum_ret, 
				_sum_cont,
				_sum_fac,
				1,
				_sum_fac_car);
	end

	let _prima_suscrita   = 0;
	let _prima_retenida   = 0;
	let v_suma_asegurada  = 0;
end foreach
-- procesos v_filtros

let v_filtros ="";

if a_serie <> "*" then
	--let v_filtros = trim(v_filtros) || "serie " || _fecha_serie_ini || " - " || _fecha_serie_fin || ";";
	let v_filtros = trim(v_filtros) || "Serie " ||trim(a_serie);
end if

if a_codramo <> "*" then
	let v_filtros = trim(v_filtros) ||"Ramo "||trim(a_codramo);
	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
        update temp_civil
           set seleccionado = 0
         where seleccionado = 1
           and cod_ramo not in(select codigo from tmp_codigos);
	else
        update temp_civil
           set seleccionado = 0
         where seleccionado = 1
           and cod_ramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
        update temp_civil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
        update temp_civil
           set seleccionado = 0
         where seleccionado = 1
           and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

select count(*)
  into _cnt
  from temp_civil
 where seleccionado = 1
   and cod_ramo = "002";

if _cnt > 0 then
	update temp_civil
	   set seleccionado = 1
	 where cod_ramo = "999";
end if

foreach
	select cod_ramo,
		   rango_inicial,
		   rango_final,
		   cant_polizas,
		   prima_suscrita,
		   prima_retenida,
		   cant_coasegur1,
		   cant_coasegur2,
		   suma_asegurada,
		   sum_ret, 
		   sum_cont,
		   sum_fac,
		   sum_fac_car,
		   cant_unidad
	  into v_codramo,
	  	   v_rango_inicial,
	  	   v_rango_final,
	  	   v_cant_polizas,
	       v_prima_suscrita,
	       v_prima_retenida,
	       v_cant_coasegur1,
	       v_cant_coasegur2,
		   v_suma_asegurada,
		   _sum_ret, 
		   _sum_cont,
		   _sum_fac,
		   _sum_fac_car,
		   _cant_unidad
	  from temp_civil
	 where seleccionado = 1
	 order by cod_ramo,rango_inicial		   

	select max(rango1)
	  into _rango_max
	  from parinfra
	 where cod_ramo = v_codramo;

	select min(rango1)
	  into _rango_min
	  from parinfra
	 where cod_ramo = v_codramo;

    if _rango_max = v_rango_inicial then
	    let v_rango_final = -1;
    end if;
    if _rango_min = v_rango_inicial then
	    let v_rango_inicial = -1;
    end if;
	if v_codramo <> "999" then
	    select nombre
	      into v_desc_ramo
	      from prdramo
	     where cod_ramo = v_codramo;
	else
		let	v_desc_ramo = "AUTOMOVIL (VALOR VEHICULO + LIMITE MAXIMO)";
	end if

	return	v_rango_inicial,
			v_rango_final,
			v_cant_polizas,
			v_prima_suscrita,
			v_prima_retenida,
			v_cant_coasegur1,
			v_cant_coasegur2,
			v_codramo,
			v_desc_ramo,
			a_periodo,
			descr_cia,
			v_filtros, 
			v_suma_asegurada,
			_sum_ret, 
			_sum_cont,
			_sum_fac,
			_cant_unidad,
			_sum_fac_car with resume;
end foreach

drop table temp_civil;
drop table temp_ubica;
drop table temp_unidad;
drop table temp_conteo;
drop table temp_fact;

end
end procedure;	  