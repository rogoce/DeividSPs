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
--------------------------------------------

drop procedure sp_pro02m;
create procedure "informix".sp_pro02m(
a_compania		char(3),
a_agencia		char(03)	default "*", 
a_periodo		date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_serie			char(255)	default "*",
a_subramo		char(255)	default "*" ) 
returning	dec(16,2),
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
			dec(16,2),
			dec(16,2),
			dec(16,2),
			smallint,
			dec(16,2),
			dec(16,2);

 begin

define _a_compania			char(3); 
define _a_agencia			char(03);
define _a_periodo			date; 
define _a_codsucursal		char(255);
define _a_codramo			char(255);
define _a_serie				char(4);
define x_no_poliza			char(10);
define x_dif				dec(16,2);	
define tx_dif				dec(16,2);
define v_codsucursal		char(3);
define v_codramo			char(3);
define v_desc_ramo			char(45);
define descr_cia			char(45);
define _no_unidad			char(5);
define v_cant_polizas		smallint;
define v_cant_coasegur1		smallint;
define v_cant_coasegur2		smallint;
define mes					smallint;
define v_prima_suscrita		dec(16,2);
define v_prima_retenida		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_retenida		dec(16,2);
define v_rango_inicial		dec(16,2);
define v_rango_final		dec(16,2);
define v_suma_asegurada		dec(16,2);
define _suma_unidad			dec(16,2);
define v_suma_aseg_end		dec(16,2);
define codigo1				smallint;
define v_fecha_cancel		date;
define _no_poliza			char(10);
define v_filtros2			char(255);
define v_filtros			char(255);
define _tipo2				char(1);
define _tipo				char(1);
define rango_max			integer;
define _cnt					integer;
define rango_min			dec(16,2);
define _limite_2_a			dec(16,2);
define _prima				dec(16,2);
define _limite_2_c			dec(16,2);
define _limite_1_b			dec(16,2);
define _limite_max			dec(16,2);
define mes1					char(2);
define ano					char(4);
define periodo1				char(7);
define v_cod_tipoprod		char(3);
define v_cod_cliente		char(10);
define _fecha_emision		date;
define _fecha_cancelacion	date;
define _no_endoso			char(5);
define _cod_ramo_tmp		char(3);
define _suma_aseg_tot		dec(16,2);
define _sum_ret				dec(16,2);
define _sum_cont			dec(16,2);
define _sum_fac				dec(16,2);
define _sum_5				dec(16,2);
define _sum_7				dec(16,2);
define _sum_pcont			dec(16,2);
define _sum_fcont			dec(16,2);
define _sum_rcont			dec(16,2);
define _prima_cont			dec(16,2);
define _porc_prima			dec(9,6);
define _tipo_contrato		smallint;
define _cod_contrato		char(5);
define _serie				char(4);
define s_ano_serie_ini		char(25);
define s_ano_serie_fin		char(25);
define _ano_serie_ini		smallint;
define _ano_serie_fin		smallint;
define _fecha_serie_ini		date;
define _fecha_serie_fin		date;
define _front				smallint;
define _c_asegurado			char(10);
define _cantidad			smallint;
define _concat				varchar(255);
define _bouquet				smallint;
define _cod_cober_reas		char(3);
define v_porc_partic		dec(9,6);
define _cod_subramo			char(3);
define _existe				smallint;

--set debug file to "sp_pro2m.trc";
--trace on;
create temp table temp_bouquet
	(no_poliza		char(10),
	no_endoso		char(5),
	cod_contrato	char(5),
	bouquet			smallint,
	front			smallint,
primary key (no_poliza,no_endoso,cod_contrato,bouquet,front))with no log;

create index i_temp_bouquet0 on temp_bouquet(no_poliza);
create index i_temp_bouquet1 on temp_bouquet(no_endoso);
create index i_temp_bouquet3 on temp_bouquet(cod_contrato);
create index i_temp_bouquet4 on temp_bouquet(bouquet);
create index i_temp_bouquet5 on temp_bouquet(front);

create temp table temp_ubica
	(no_poliza		char(10),
	suma_asegurada	dec(16,2),
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	sum_ret			dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	sum_pcont		dec(16,2) default 0,
	sum_fcont		dec(16,2) default 0,
	sum_rcont		dec(16,2) default 0,
	sum_5			dec(16,2) default 0,
	sum_7			dec(16,2) default 0,
	serie			char(4),
	seleccionado	smallint  default 0,
primary key (no_poliza)) with no log;

create temp table temp_unidad
	(no_poliza          char(10),
	no_unidad          char(5),
	suma_asegurada     dec(16,2),
	cod_ramo           char(3),
	prima_suscrita     dec(16,2),
	prima_retenida     dec(16,2),
	serie				 char(4),
	seleccionado       smallint default 0,
primary key (no_poliza,no_unidad,cod_ramo)) with no log;

create temp table temp_cliente
	(cod_ramo         char(03),
	cod_asegurado	   char(10),
	rango_inicial    dec(16,2),
	rango_final      dec(16,2),
	cantidad         smallint,
	seleccionado       smallint default 1,
primary key (cod_ramo,cod_asegurado,rango_inicial,rango_final))
with no log;

let descr_cia = sp_sis01(a_compania);

create temp table temp_civil
	(cod_sucursal	char(03),
	cod_ramo		char(03),
	rango_inicial	dec(16,2),
	rango_final		dec(16,2),
	cant_polizas	smallint,
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	cant_coasegur1	smallint,
	cant_coasegur2	smallint,
	seleccionado	smallint default 1,
	suma_asegurada	dec(16,2),	
	sum_ret			dec(16,2) default 0,
	sum_cont		dec(16,2) default 0,
	sum_fac			dec(16,2) default 0,
	sum_pcont		dec(16,2) default 0,
	sum_fcont		dec(16,2) default 0,
	sum_rcont		dec(16,2) default 0,
	sum_5			dec(16,2) default 0,
	sum_7			dec(16,2) default 0,
primary key (cod_ramo,rango_inicial)) with no log;

create index iend1_temp_civil on temp_civil(cod_sucursal);
create index iend2_temp_civil on temp_civil(cod_ramo);

let _a_compania = a_compania;
let  _a_agencia = a_agencia;
let  _a_periodo = a_periodo; 
let  _a_codsucursal = a_codsucursal;
let  _a_codramo = a_codramo;

let v_codramo        = null;
let v_desc_ramo      = null;
let v_rango_inicial  = 0;
let v_rango_final    = 0;
let v_cant_polizas   = 0;
let v_cant_coasegur1 = 0;
let v_cant_coasegur2 = 0;
let v_prima_suscrita = 0;
let v_prima_retenida = 0;
let _prima_suscrita  = 0;
let _prima_retenida  = 0;
let v_suma_asegurada = 0;
let v_suma_aseg_end  = 0;
let _no_poliza       = null;
let v_cant_coasegur1 = 0;
let v_cant_coasegur2 = 0;
let v_filtros ="";
let _ano_serie_ini = year(today);
let _ano_serie_fin = year(today);
let s_ano_serie_ini = "";
let s_ano_serie_fin = "";
let v_filtros2      = "";
let _existe = 0;

let mes 		 = month(a_periodo);
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

if a_codramo <> "*" then
  	let _tipo = sp_sis04(a_codramo); -- separa los valores del string

	if a_subramo <> "*" then
		let _tipo2 = sp_sis387(a_subramo); -- separa los valores del string
	end if

	if _tipo <> "E" then -- incluir los registros
		foreach
			select a.no_poliza,
				   a.fecha_cancelacion,
				   a.cod_ramo,
				   a.cod_subramo,
				   a.cod_sucursal,
				   a.suma_asegurada,
				   a.cod_tipoprod,
				   b.no_endoso,
				   year(a.vigencia_inic),
				   a.fronting
			  into _no_poliza,
				   v_fecha_cancel,
				   v_codramo,
				   _cod_subramo,
				   v_codsucursal,
				   v_suma_asegurada,
				   v_cod_tipoprod,
				   _no_endoso,
				   _serie,
				   _front
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

			if _front = 1 then
				continue foreach;
			end if

			LET _fecha_emision = null;

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

			if a_subramo <> "*" then
				if _tipo2 <> "E" then -- incluir los registros
					let _existe = 0;
					
					select count(*)
					  into _existe
					  from tmp_codigos2
					 where codigo in (_cod_subramo);  -- not

					if _existe is null then
						let _existe = 0;
					end if
					
					if _existe = 0 then
						continue foreach;
					end if
				else
					let _existe = 0;
					
					select count(*)
					  into _existe
					  from tmp_codigos2
					 where codigo in (_cod_subramo);
					
					if _existe is null then
						let _existe = 0;
					end if
					
					if _existe <> 0 then
						continue foreach;
					end if
				end if
			end if

			let _prima_suscrita   = 0;
			let _prima_retenida   = 0;

			--Sacar suma asegurada de la unidad

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
						values	(_no_poliza,
								_no_unidad,
								_suma_unidad,
								v_codramo,
								_prima_suscrita,
								_prima_retenida,
								_serie,
								1);
					end
				end foreach
			end if


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

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
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
							let _sum_ret = _sum_ret + _suma_aseg_tot;
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

			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  --if _front = 0 then   -- Si encuentran poliza distinta de fronting

				   BEGIN
				      ON EXCEPTION IN(-239,-268)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,					  
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  0
					  );

				   END
				--else
				{	let _sum_fac = 0.00;
			    end if}
			  end if

		END FOREACH

	else

		FOREACH
				SELECT a.no_poliza,
			           a.fecha_cancelacion,
			           a.cod_ramo,
					   a.cod_subramo,
			           a.cod_sucursal,
			           a.suma_asegurada,
			           a.cod_tipoprod,
					   b.no_endoso,
					   year(a.vigencia_inic),
					   a.fronting
			      INTO _no_poliza,
			           v_fecha_cancel,
			           v_codramo,
					   _cod_subramo,
			           v_codsucursal,
			           v_suma_asegurada,
			           v_cod_tipoprod,
					   _no_endoso,
					   _serie,
					   _front
			      FROM emipomae a, endedmae b
			     WHERE a.cod_compania      = a_compania
			       AND (a.vigencia_final   >= a_periodo
			   	    OR a.vigencia_final    IS NULL)
				   AND a.fecha_suscripcion <= a_periodo
				   AND a.actualizado       = 1
  				   AND a.cod_ramo         NOT IN(SELECT codigo FROM tmp_codigos)
				   AND b.no_poliza         = a.no_poliza
				   AND b.periodo           <= periodo1
				   AND b.fecha_emision     <= a_periodo
			   	   AND b.actualizado 	   = 1
			   	   AND a.vigencia_inic     >= _fecha_serie_ini
				   AND a.vigencia_inic     <  _fecha_serie_fin

				if _front = 1 then
					continue foreach;
				end if

			    LET _fecha_emision = null;

			    IF v_fecha_cancel <= a_periodo THEN
				    FOREACH
						SELECT fecha_emision
						  INTO _fecha_emision
						  FROM endedmae
						 WHERE no_poliza     = _no_poliza
						   AND cod_endomov   = '002'
						   AND vigencia_inic = v_fecha_cancel
					END FOREACH

					IF  _fecha_emision <= a_periodo THEN
					    LET _prima_suscrita   = 0;
						LET _prima_retenida   = 0;
						CONTINUE FOREACH;
					END IF
				END IF

				IF a_subramo <> "*" THEN
					IF _tipo2 <> "E" THEN -- Incluir los Registros
						 let _existe = 0;
					  SELECT count(*)
						INTO _existe
						FROM tmp_codigos2
					   WHERE codigo in (_cod_subramo);  -- not
					     if _existe is null then
							let _existe = 0;
						 end if
						if _existe = 0 then
							continue foreach;
						end if
					ELSE
						 let _existe = 0;
					  SELECT count(*)
						INTO _existe
						FROM tmp_codigos2
					   WHERE codigo in (_cod_subramo);
					     if _existe is null then
							let _existe = 0;
						 end if
						if _existe <> 0 then
							continue foreach;
						end if
					END IF
				END IF

			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;

				--Sacar suma asegurada de la unidad

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

					   BEGIN
					      ON EXCEPTION IN(-239)
					      END EXCEPTION

					      INSERT INTO temp_unidad
						  VALUES
						  (
						  _no_poliza,
						  _no_unidad,
						  _suma_unidad,
						  v_codramo,
						  _prima_suscrita,
						  _prima_retenida,
						  _serie,
						  1
						  );
					   END

					end foreach
				end if

		        SELECT prima_suscrita,
				  	   prima_retenida
		          INTO _prima_suscrita,
				  	   _prima_retenida
		          FROM endedmae
		         WHERE no_poliza = _no_poliza
				   AND fecha_emision  <= a_periodo
				   and cod_endomov <> '002'
				   AND no_endoso = _no_endoso;

			    if _prima_suscrita   is NULL then 
			        LET _prima_suscrita   = 0;
				end if
			    if  _prima_retenida    is NULL then 
    				LET _prima_retenida   = 0;
				end if


				let _sum_ret    = 0.00;
				let _sum_cont   = 0.00;
				let _sum_fac    = 0.00;
				let _sum_pcont  = 0.00;
				let _sum_fcont  = 0.00;
				let _sum_rcont  = 0.00;
				let _sum_5      = 0.00;
				let _sum_7      = 0.00;
				let _suma_aseg_tot = 0.00;

			   foreach
				select a.cod_contrato, a.cod_cober_reas, a.porc_partic_prima,
				       sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato, _cod_cober_reas, _porc_prima,
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

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
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

					if _tipo_contrato = 1 then
						if _porc_prima = 100 then
							let _sum_ret  	= 0.00;
							let _sum_cont 	= 0.00;
							let _sum_fac  	= 0.00;
							let _sum_pcont  = 0.00;
							let _sum_fcont  = 0.00;
							let _sum_rcont  = 0.00;
							let _suma_aseg_tot  = 0.00;
							let _prima_suscrita = 0.00;
				  	        let _prima_retenida = 0.00;
						else
							let _sum_ret = _sum_ret + _suma_aseg_tot;
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

		      IF  _sum_cont <= 0 THEN
				CONTINUE FOREACH;
			  END IF


			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  --if _front = 0 then   -- Si encuentran poliza distinta de fronting

				   BEGIN
				      ON EXCEPTION IN(-239)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  0
					  );

				   END
				 { else
					 let _sum_fac = 0;
				  end if }
			  end if

		END FOREACH
	end if

	DROP TABLE tmp_codigos;

else

	FOREACH
		SELECT a.no_poliza,
	           a.fecha_cancelacion,
	           a.cod_ramo,
			   a.cod_subramo,
	           a.cod_sucursal,
	           a.suma_asegurada,
	           a.cod_tipoprod,
			   b.no_endoso,
			   year(a.vigencia_inic),
			   a.fronting
	      INTO _no_poliza,
	           v_fecha_cancel,
	           v_codramo,
			   _cod_subramo,
	           v_codsucursal,
	           v_suma_asegurada,
	           v_cod_tipoprod,
			   _no_endoso,
			   _serie,
			   _front
	      FROM emipomae a, endedmae b
	     WHERE a.cod_compania      = a_compania
	       AND (a.vigencia_final   >= a_periodo
	   	    OR a.vigencia_final    IS NULL)
		   AND a.fecha_suscripcion <= a_periodo
		   AND a.actualizado       = 1
		   AND b.no_poliza         = a.no_poliza
		   AND b.periodo           <= periodo1
		   AND b.fecha_emision     <= a_periodo
	   	   AND b.actualizado 	   = 1
	   	   AND a.vigencia_inic     >= _fecha_serie_ini
		   AND a.vigencia_inic     <  _fecha_serie_fin

        if _front = 1 then
			continue foreach;
		end if

	    LET _fecha_emision = null;

	    IF v_fecha_cancel <= a_periodo THEN
		    FOREACH
				SELECT fecha_emision
				  INTO _fecha_emision
				  FROM endedmae
				 WHERE no_poliza     = _no_poliza
				   AND cod_endomov   = '002'
				   AND vigencia_inic = v_fecha_cancel
			END FOREACH

			IF  _fecha_emision <= a_periodo THEN
			    LET _prima_suscrita   = 0;
				LET _prima_retenida   = 0;
				CONTINUE FOREACH;
			END IF
		END IF

	    LET _prima_suscrita   = 0;
		LET _prima_retenida   = 0;

		--Sacar suma asegurada de la unidad

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

			   BEGIN
			      ON EXCEPTION IN(-239)
			      END EXCEPTION

			      INSERT INTO temp_unidad
				  VALUES
				  (
				  _no_poliza,
				  _no_unidad,
				  _suma_unidad,
				  v_codramo,
				  _prima_suscrita,
				  _prima_retenida,
				  _serie,
				  1
				  );
			   END
			end foreach
		end if

        SELECT prima_suscrita,
		  	   prima_retenida
          INTO _prima_suscrita,
		  	   _prima_retenida
          FROM endedmae
         WHERE no_poliza = _no_poliza
		   AND fecha_emision  <= a_periodo
		   and cod_endomov <> '002'
		   AND no_endoso = _no_endoso;

			    if _prima_suscrita   is NULL then 
			        LET _prima_suscrita   = 0;
				end if
			    if  _prima_retenida    is NULL then 
    				LET _prima_retenida   = 0;
				end if


				let _sum_ret  	= 0.00;
				let _sum_cont 	= 0.00;
				let _sum_fac  	= 0.00;
				let _sum_pcont 	= 0.00;
				let _sum_fcont  = 0.00;
				let _sum_rcont  = 0.00;
				let _sum_5 		= 0.00;
				let _sum_7 		= 0.00;
				let _suma_aseg_tot = 0.00;

			   foreach
				select a.cod_contrato, a.cod_cober_reas, a.porc_partic_prima,
				       sum(a.suma_asegurada),
					   sum(a.prima)
				  into _cod_contrato, _cod_cober_reas, _porc_prima,
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

				select tipo_contrato, fronting
				  into _tipo_contrato, _front
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

					if _tipo_contrato = 1 then
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
							let _sum_ret = _sum_ret + _suma_aseg_tot;
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

		      IF  _sum_cont <= 0 THEN
				CONTINUE FOREACH;
			  END IF


			  if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
			  else
				  --if _front = 0 then   -- Si encuentran poliza distinta de fronting

				   BEGIN
				      ON EXCEPTION IN(-239)
				         UPDATE temp_ubica
				            SET suma_asegurada = suma_asegurada + v_suma_asegurada,
				                prima_suscrita = prima_suscrita + _prima_suscrita,
				                prima_retenida = prima_retenida + _prima_retenida,
								sum_ret        = sum_ret        + _sum_ret,
								sum_cont       = sum_cont       + _sum_cont,
								sum_fac        = sum_fac        + _sum_fac,
								sum_rcont      = sum_rcont      + _sum_rcont,
								sum_pcont      = sum_pcont      + _sum_pcont,
								sum_fcont      = sum_fcont      + _sum_fcont
				          WHERE no_poliza      = _no_poliza;	

				      END EXCEPTION

				      INSERT INTO temp_ubica
					  VALUES
					  (
					  _no_poliza,
					  v_suma_asegurada,
					  _prima_suscrita,
					  _prima_retenida,
					  _sum_ret, 
					  _sum_cont,
					  _sum_fac,
					  _sum_pcont,
					  _sum_fcont,
					  _sum_rcont,
					  _sum_5,
					  _sum_7,
					  _serie,
					  0
					  );

				   END
				 { else
					 let _sum_fac = 0;
				  end if }
			  end if
END FOREACH
end if
--set debug file to "sp_pro2m.trc";
--trace on;

FOREACH
	SELECT Distinct no_poliza,cod_contrato 
	  INTO _no_poliza,_cod_contrato
	  FROM temp_bouquet 
     WHERE bouquet = 1 
       and front   = 0

	UPDATE temp_ubica
	   SET seleccionado = 1
	 WHERE no_poliza    = _no_poliza;

	UPDATE temp_unidad
	   SET seleccionado = 1
	 WHERE no_poliza    = _no_poliza;

END FOREACH

--trace off;
--Agregar limite maximo + suma asegurada

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
	   and seleccionado = 1

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

    BEGIN
	     ON EXCEPTION IN(-239)
	     END EXCEPTION

	      INSERT INTO temp_unidad
		  VALUES(
		  _no_poliza,
		  _no_unidad,
		  _limite_max,
		  '999',
		  _prima_suscrita,
		  _prima_retenida,
		  _serie,
		  1
		  );
	END

end foreach

delete from tmp_sp_pro2i;
LET  tx_dif = 0  ;

FOREACH
  SELECT no_poliza,
         suma_asegurada,
		 prima_suscrita,
		 prima_retenida,
		 sum_ret, 
		 sum_cont,
		 sum_fac,
		 sum_pcont,
		 sum_fcont,
		 sum_rcont,
		 sum_5,
		 sum_7
	INTO _no_poliza,
		 v_suma_asegurada,
		 _prima_suscrita,
		 _prima_retenida,
		 _sum_ret, 
		 _sum_cont,
		 _sum_fac,
		 _sum_pcont,
		 _sum_fcont,
		 _sum_rcont,
		 _sum_5,
		 _sum_7
	FROM temp_ubica
   WHERE seleccionado = 1 


	  SELECT cod_ramo,fronting
		INTO v_codramo,_front
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

      if _front = 1 then
	     continue foreach;
	  end if

     LET _suma_aseg_tot = _sum_rcont + _sum_pcont + _sum_fcont;

	  SELECT emitipro.tipo_produccion
        INTO codigo1
        FROM emitipro,emipomae
       WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
         AND emipomae.no_poliza = _no_poliza;

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

	  SELECT parinfra.rango1, 
		     parinfra.rango2
	  	INTO v_rango_inicial,
	  		 v_rango_final
	  	FROM parinfra
	   WHERE parinfra.cod_ramo = v_codramo
	     AND parinfra.rango1 <= v_suma_asegurada	   
	     AND parinfra.rango2 >= v_suma_asegurada;

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
       END IF;
	  LET _suma_aseg_tot = 0;

	if v_codramo = "018" or v_codramo = "002" or v_codramo = "016" then
	else
			if v_codramo = "008" then
				foreach
				    select distinct cod_contratante
					  into _c_asegurado
					  from emipomae
					 where no_poliza = _no_poliza

				   {	let _existe = 0;

					select count(*) 
					  into _existe
					  from temp_cliente
					 where cod_asegurado  = _c_asegurado;

					if _existe > 0 then
						continue foreach;
					end if}
										 
				   BEGIN
				      ON EXCEPTION IN(-239)
			            UPDATE temp_cliente
               			   SET cantidad      = cantidad + 1
            			 WHERE cod_ramo      = v_codramo
						   AND cod_asegurado = _c_asegurado
			               AND rango_inicial = v_rango_inicial
                		   AND rango_final   = v_rango_final;
			
			          END EXCEPTION

				      INSERT INTO temp_cliente
					  VALUES
					  (
					  v_codramo,
					  _c_asegurado,
					  v_rango_inicial,
					  v_rango_final,
					  1,
					  1
					  );
				   END
				end foreach
			end if

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                SET cant_polizas   = cant_polizas   + 1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2,
					suma_asegurada = suma_asegurada + v_suma_asegurada,
					sum_ret        = sum_ret	    + _sum_ret,
					sum_cont       = sum_cont	    + _sum_cont,
					sum_fac        = sum_fac	    + _sum_fac,
					sum_pcont      = sum_pcont	    + _sum_pcont,
					sum_fcont      = sum_fcont	    + _sum_fcont,
					sum_rcont      = sum_rcont	    + _sum_rcont,
		 			sum_5 		   = sum_5		    + _sum_5,
		 			sum_7 		   = sum_7		    + _sum_7
              WHERE cod_ramo       = v_codramo
                AND rango_inicial  = v_rango_inicial
                AND rango_final    = v_rango_final;

			   LET _suma_aseg_tot = _sum_rcont + _sum_pcont + _sum_fcont;

			   IF _prima_suscrita <> _suma_aseg_tot THEN
				   BEGIN
					     ON EXCEPTION IN(-239)
					     END EXCEPTION
					  LET  x_dif = _prima_suscrita - _suma_aseg_tot;
					   LET  tx_dif = tx_dif + x_dif;
					  LET x_no_poliza =  _no_poliza;

				      INSERT INTO tmp_sp_pro2i
					  VALUES(
					  _no_poliza,
					  _prima_suscrita,
					  _sum_rcont, 
					  _sum_pcont,
					  _sum_fcont
					  );
				  END 
			   END IF

          END EXCEPTION

          INSERT INTO temp_civil
  		  VALUES(
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
		  _sum_pcont, 
		  _sum_fcont, 
		  _sum_rcont, 
		  _sum_5, 
		  _sum_7 
		  );

		   LET _suma_aseg_tot = _sum_rcont + _sum_pcont + _sum_fcont;

		   IF _prima_suscrita <> _suma_aseg_tot THEN
			   BEGIN
				     ON EXCEPTION IN(-239)
				     END EXCEPTION

				  LET x_no_poliza =  _no_poliza;
				  LET  x_dif = _prima_suscrita - _suma_aseg_tot;

			      INSERT INTO tmp_sp_pro2i
				  VALUES(
				  _no_poliza,
				  _prima_suscrita,
				  _sum_rcont, 
				  _sum_pcont,
				  _sum_fcont
				  );
			  END 
		   END IF

       END

	end if

   LET _prima_suscrita   = 0;
   LET _prima_retenida   = 0;

END FOREACH

let _cod_ramo_tmp = "";

FOREACH
  SELECT no_poliza,
         no_unidad,
         suma_asegurada,
		 cod_ramo,
		 prima_suscrita,
		 prima_retenida
	INTO _no_poliza,
	     _no_unidad,
		 v_suma_asegurada,
		 v_codramo,
		 _prima_suscrita,
		 _prima_retenida
	FROM temp_unidad
   where seleccionado = 1
   ORDER BY cod_ramo

   select fronting
     into _front
	 from emipomae
	where no_poliza = _no_poliza;

      if _front = 1 then
	     continue foreach;
	  end if

	  
	if v_codramo = "999" then
		let _cod_ramo_tmp = v_codramo;
		let v_codramo = "002";
	end if

	SELECT parinfra.rango1, 
		   parinfra.rango2
	  INTO v_rango_inicial,
	  	   v_rango_final
	  FROM parinfra
	 WHERE parinfra.cod_ramo = v_codramo
	   AND parinfra.rango1 <= v_suma_asegurada	   
	   AND parinfra.rango2 >= v_suma_asegurada;

	if _cod_ramo_tmp = "999" then
		let v_codramo = _cod_ramo_tmp;
		let _cod_ramo_tmp = "";
	end if

       IF v_rango_inicial IS NULL THEN
          CONTINUE FOREACH;
       END IF;

	  SELECT emitipro.tipo_produccion
        INTO codigo1
        FROM emitipro,emipomae
       WHERE emitipro.cod_tipoprod = emipomae.cod_tipoprod 
         AND emipomae.no_poliza = _no_poliza;

       IF codigo1 = 2 OR codigo1 = 3  THEN
          LET v_cant_coasegur1 = 1;
          LET v_cant_coasegur2 = 0;
       ELSE
          LET v_cant_coasegur1 = 0;
          LET v_cant_coasegur2 = 1;
       END IF;

       BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_civil
                SET suma_asegurada = suma_asegurada + v_suma_asegurada,
					cant_polizas   = cant_polizas   + 1,
                    prima_suscrita = prima_suscrita + _prima_suscrita,
                    prima_retenida = prima_retenida + _prima_retenida,
                    cant_coasegur1 = cant_coasegur1 + v_cant_coasegur1,
                    cant_coasegur2 = cant_coasegur2 + v_cant_coasegur2
              WHERE cod_ramo       = v_codramo
                AND rango_inicial  = v_rango_inicial
                AND rango_final    = v_rango_final;

          END EXCEPTION

          INSERT INTO temp_civil
  		  VALUES(
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
		  0, --_pri_sus_inc,
		  0, --_pri_sus_ter,
		  0, --_pri_ret_inc,
		  0, --_sum_pcont, 
		  0, --_sum_fcont,
		  0, --_sum_rcont,
		  0, -- _sum_5
		  0	 -- _sum_7
          );

       END

       LET _prima_suscrita   = 0;
       LET _prima_retenida   = 0;
	   LET v_suma_asegurada  = 0;

END FOREACH

 -- Procesos v_filtros

  IF a_codramo <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
     LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE temp_civil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_civil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
  END IF

  IF a_codsucursal <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
     LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE temp_civil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_civil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
  END IF

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

  IF a_subramo <> "*" THEN
  	LET v_filtros = TRIM(v_filtros) || " Sub Ramo "||TRIM(a_subramo);
  END IF


FOREACH
	SELECT cod_ramo,
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
		   sum_pcont,
		   sum_fcont,
		   sum_rcont,
		   sum_5,
		   sum_7
	  INTO v_codramo,
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
		   _sum_pcont,
		   _sum_fcont,
		   _sum_rcont,
		   _sum_5,
		   _sum_7
	  FROM temp_civil
	 WHERE seleccionado = 1
  ORDER BY cod_ramo,rango_inicial

  SELECT count(distinct cod_asegurado)
  	into _cantidad
  	from temp_cliente
   WHERE cod_ramo      = v_codramo
     AND rango_inicial = v_rango_inicial
     AND rango_final   = v_rango_final
	 AND seleccionado  = 1;

	SELECT MAX(rango1)
	  INTO rango_max
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

	SELECT MIN(rango1)
	  INTO rango_min
	  FROM parinfra
	 WHERE cod_ramo = v_codramo;

    IF rango_max = v_rango_inicial THEN
	    LET v_rango_final = -1;
    END IF;
    IF rango_min = v_rango_inicial THEN
	    LET v_rango_inicial = -1;
    END IF;
	if v_codramo <> "999" then
	    SELECT nombre
	      INTO v_desc_ramo
	      FROM prdramo
	     WHERE cod_ramo = v_codramo;

	else
		let	v_desc_ramo = "AUTOMOVIL (VALOR VEHICULO + LIMITE MAXIMO)";
	end if

     RETURN v_rango_inicial,
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
			_sum_5,	
			_sum_7,
		    _sum_pcont,
			_cantidad,
		    _sum_fcont,
		    _sum_rcont
            WITH RESUME;

END FOREACH

DROP TABLE temp_civil;
DROP TABLE temp_ubica;
DROP TABLE temp_unidad;
DROP TABLE temp_cliente;
DROP TABLE temp_bouquet;

IF a_subramo <> "*" THEN
	DROP TABLE tmp_codigos2;
END IF

END

END PROCEDURE;
