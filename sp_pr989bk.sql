--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       --   YMZM
---  Ref. Power Builder - reemplaza d_sp_pro40 filtro por serie - contrato
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Informe de Participacion prima Suscrita de cuota parte retencion cesion 50% MAPFRE	 - HENRY
-- execute procedure sp_pr989bk('001','001','2013-02','2013-02',"*","*","*","*","001;","*","*","2013,2012,2011,2010,2009,2008;")
--------------------------------------------
drop procedure sp_pr989;
create procedure sp_pr989(
	a_compania    char(03),
	a_agencia     char(03),
	a_periodo1    char(07),
	a_periodo2    char(07),
	a_codsucursal char(255)	default "*",
	a_codgrupo    char(255) default "*",
	a_codagente   char(255) default "*",
	a_codusuario  char(255) default "*",
	a_codramo     char(255) default "*",
	a_reaseguro   char(255) default "*",
	a_contrato    char(255) default "*",
	a_serie       char(255) default "*")
returning	char(3),
			char(3),
			char(5),
			char(3),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(50),
			char(255);
begin
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _cuenta				char(25);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define _cod_contrato_map	char(5);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define v_cobertura			char(3);
define _cod_origen			char(3);
define as_cod_ramo			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define _xnivel				char(3);
define _cod_r				char(3);
define v_clase				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define _porc_cont_partic	dec(16,2);
define _p_50_siniestro		dec(16,2);
define _porc_comis_ase		dec(16,2);
define _porc_impuesto		dec(16,4);
define _porc_comision		dec(16,4);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro50			dec(16,2);
define _siniestro30			dec(16,2);
define _p_c_partic			dec(16,2);
define _monto_reas			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _p_50_prima			dec(16,2);
define _por_pagar			dec(16,2);
define _siniestro			dec(16,2);
define _impuesto			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define _comision			dec(16,2);
define v_prima50			dec(16,2);
define v_prima1				dec(16,2);
define as_monto				dec(16,2);
define v_prima				dec(16,2);
define _porc_impuesto4		dec(16,4);
define _porc_comision4		dec(16,4);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _tiene_comision		smallint;
define _p_c_partic_hay		smallint;
define _seleccionado		smallint;
define _cnt_agrupa			smallint;
define _trim_reas			smallint;
define _tipo_cont			smallint;
define _traspaso			smallint;
define _cantidad			smallint;	
define as_serie				smallint;
define v_existe				smallint;
define _serie2				smallint;
define _serie1				smallint;
define _nivel				smallint;
define _serie				smallint;
define _tipo2				smallint;
define _cnt					smallint;
define nivel				smallint;
define _dt_vig_inic			date;
define _no_factura          char(10);

set isolation to dirty read;

--let a_codramo = "001,003,010,011,012,013,014,022;";   -- solicitud: sr. naranjo 03/09/2010

let _borderaux = "03";	    -- 50% retencion mapfre

select tipo
  into _tipo2 
  from reacontr 
 where cod_contrato = _borderaux;

call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas; 

delete from reacoret 
 where anio = _anio_reas 
   and trimestre = _trim_reas
   and borderaux = _borderaux;   -- elimina borderaux del trimestre
   
delete from temphg1
 where anio = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;     -- elimina borderaux datos

call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

let v_filtros = sp_rec708(
	a_compania,
	a_agencia,
	a_periodo1,
	a_periodo2,
	a_codsucursal,
	'*', 
	a_codramo, --'*',    ---a_ramo,
	'*', 
	'*', 
	'*', 
	'*',
	'*'    ---a_contrato
	);

create temp table temp_produccion
	(cod_ramo         char(3),
	cod_subramo		 char(3),
	cod_origen		 char(3),
	cod_contrato     char(5),
	desc_contrato    char(50),
	cod_cobertura    char(3),
	prima            dec(16,2),
	tipo             smallint default 0,
	comision         dec(16,2),
	impuesto         dec(16,2),
	por_pagar        dec(16,2),
	desc_cob         char(100),
	serie 			 smallint,
	seleccionado     smallint default 1,
	porc_comision 	 dec(16,2), 
	porc_impuesto 	 dec(16,2), 
	porc_cont_partic dec(16,2), 
	cod_coasegur 	 char(3),
	tiene_comision   smallint,
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob)) with no log;

let v_desc_cobertura	= "";
let v_descr_cia			= sp_sis01(a_compania);
let v_filtros1			= "";
let _p_50_siniestro		= 50;
let _porc_comis_ase		= 0;
let _p_50_prima			= 50;
let _tipo_cont			= 0;
let v_prima				= 0;

--set debug file to "sp_pr989.trc";	 																						 
--trace on;

foreach with hold
	select no_poliza,																	 
		   no_endoso																		 
	  into v_nopoliza,
		   v_noendoso
	  from temp_det
	 where seleccionado = 1 --and z.no_documento <> "0109-00700-01"	-- solicitud 26/11/2008 del sr. omar wong 	banco hipotecario nacional.	 no autorizado aun.
	 group by 1, 2


	select cod_ramo,
		   cod_subramo,
		   cod_origen,
		   vigencia_inic
	  into v_cod_ramo,
		   _cod_subramo,
		   _cod_origen,
		   _dt_vig_inic
	  from emipomae
	 where no_poliza = v_nopoliza;

--	  foreach
--		SELECT vigencia_inic
--		  INTO _dt_vig_inic
--		  FROM endedmae 
--		 WHERE no_poliza   = v_nopoliza 
--		   AND no_endoso   = v_noendoso    
--	   AND actualizado = 1
--		 order by vigencia_inic desc
--		  exit foreach;
--	  end foreach

	if _dt_vig_inic <= '30/06/2014' then
	else
		continue foreach;	
	end if

	foreach
		select cod_cober_reas,
			   cod_contrato,
			   prima,
			   no_unidad
		  into v_cobertura,
			   v_cod_contrato,
			   v_prima1,
			   _no_unidad
		  from emifacon
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso
		   and prima <> 0

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select cod_traspaso
		  into _cod_traspaso
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

		select tipo_contrato,
			   serie
		  into v_tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		{foreach
			select serie 
			  into _serie1 
			  from reacomae 
			 where tipo_contrato = v_tipo_contrato 
			   and _dt_vig_inic between vigencia_inic and vigencia_final
			 order by serie desc
			  exit foreach;
		end foreach

		if _serie1 is not null or _serie1 <> 0 then
			let _serie = _serie1;	
		end if}

		if _serie >= 2014 then
			continue foreach;
		end if
		
		let _tipo_cont = 0;			  --otros contratos

		if v_tipo_contrato = 3 then   --facultativos
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let _tipo_cont = 1;
		end if

		let v_prima = v_prima1;
		let _cod_subramo = "001";

		select nombre
		  into v_desc_contrato 
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let v_desc_contrato = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;

		select porc_impuesto,
			   porc_comision,
			   tiene_comision
		  into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select nombre
		  into _nombre_cob
		  from reacobre
		 where cod_cober_reas = v_cobertura;

		select count(*)
		  into _cantidad
		  from reacoase
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		if _tipo_cont = 0 then
			if _cantidad = 0 then
				let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = _nombre_cob;

				if _cantidad = 0 then
					insert into temp_produccion
					values(	v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							v_cod_contrato,
							v_desc_contrato,
							v_cobertura,
							v_prima,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							0,
							0,
							0,
							'999',
							_tiene_comis_rea);
				end if
			else
				foreach
					select porc_cont_partic,
						   porc_comision,
						   cod_coasegur
					  into _porc_cont_partic,
						   _porc_comis_ase,
						   _cod_coasegur
					  from reacoase
					 where cod_contrato   = v_cod_contrato
					   and cod_cober_reas = v_cobertura
						
					if _tipo_cont = 1 then
						let _cod_coasegur = '036'; --ancon
					end if

					select nombre
					  into _nombre_coas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					-- La comision se calcula por reasegurador
					if _tiene_comis_rea = 2 then 
						let _porc_comision = _porc_comis_ase;
					end if

					let v_desc_cobertura = "";
					let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
					let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

					let _monto_reas = v_prima     * _porc_cont_partic / 100;
					let _impuesto   = _monto_reas * _porc_impuesto / 100;
					let _comision   = _monto_reas * _porc_comision / 100;
					let _por_pagar  = _monto_reas - _impuesto - _comision;

					select count(*)
					  into _cantidad
					  from temp_produccion
					 where cod_ramo      = v_cod_ramo
					   and cod_subramo   = _cod_subramo
					   and cod_origen    = _cod_origen
					   and cod_contrato  = v_cod_contrato
					   and cod_cobertura = v_cobertura
					   and desc_cob      = v_desc_cobertura;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
								_cod_subramo,
								_cod_origen,
								v_cod_contrato,
								v_desc_contrato,
								v_cobertura,
								_monto_reas,
								_tipo_cont,
								_comision, 
								_impuesto, 
								_por_pagar,
								v_desc_cobertura,
								_serie,
								1 ,
								_porc_comision,
								_porc_impuesto,
								_porc_cont_partic,
								_cod_coasegur,
								_tiene_comis_rea);
					else					   
						Update temp_produccion
						   set prima       = prima + _monto_reas,
							   comision    = comision  + _comision,
							   impuesto    = impuesto  + _impuesto,
							   por_pagar   = por_pagar + _por_pagar
						 where cod_ramo      = v_cod_ramo
						   and cod_subramo    = _cod_subramo
						   and cod_origen     = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura;

					end if
					--let v_prima1 = 0;
				end foreach
			end if
		elif _tipo_cont = 1 then	  --Retencion

			let _cod_coasegur = '036'; --ancon

			select nombre
			  into _nombre_coas
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			-- La comision se calcula por reasegurador
			if _tiene_comis_rea = 2 then 
				let _porc_comision = _porc_comis_ase;
			end if

			let _porc_impuesto = 0;
			let _porc_comision = 0;
			let v_desc_cobertura = "";
			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;
			let _porc_cont_partic = 100;
			let _monto_reas = v_prima;
			let _impuesto   = _monto_reas * _porc_impuesto / 100;
			let _comision   = _monto_reas * _porc_comision / 100;
			let _por_pagar  = _monto_reas - _impuesto - _comision;

			select count(*)
			  into _cantidad
			  from temp_produccion
			 where cod_ramo      = v_cod_ramo
			   and cod_subramo   = _cod_subramo
			   and cod_origen    = _cod_origen
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura;

			if _cantidad = 0 then
				insert into temp_produccion
				values(	v_cod_ramo,
						_cod_subramo,
						_cod_origen,
						v_cod_contrato,
						v_desc_contrato,
						v_cobertura,
						_monto_reas,
						_tipo_cont,
						_comision, 
						_impuesto, 
						_por_pagar,
						v_desc_cobertura,
						_serie,
						1,
						_porc_comision,
						_porc_impuesto,
						_porc_cont_partic,
						_cod_coasegur,
						_tiene_comis_rea);
			else			   
				update temp_produccion
				   set prima = prima     + _monto_reas,
					   comision = comision  + _comision,
					   impuesto = impuesto  + _impuesto,
					   por_pagar = por_pagar + _por_pagar
				 where cod_ramo      = v_cod_ramo
				   and cod_subramo    	= _cod_subramo
				   and cod_origen        = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = v_desc_cobertura;
			end if
		elif _tipo_cont = 2 then  --facultativos

			select count(*)
			  into _cantidad
			  from emifafac
			 where no_poliza      = v_nopoliza
			   and no_endoso      = v_noendoso
			   and cod_contrato   = v_cod_contrato
			   and cod_cober_reas = v_cobertura
			   and no_unidad = _no_unidad ;

			if _cantidad = 0 then
				let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

				select count(*)
				  into _cantidad
				  from temp_produccion
				 where cod_ramo          = v_cod_ramo
				   and cod_subramo       = _cod_subramo
				   and cod_origen        = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = _nombre_cob	;
--				               and no_unidad     = _no_unidad ;
				if _cantidad = 0 then
					INSERT INTO temp_produccion
					VALUES( v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							v_cod_contrato,
							v_desc_contrato,
							v_cobertura,
							v_prima,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							0,
							0,
							0,
							'999',
							_tiene_comis_rea);
				end if
			else
				foreach
					select porc_partic_reas,
						   porc_comis_fac,
						   porc_impuesto,
						   cod_coasegur
					  into _porc_cont_partic,
						   _porc_comis_ase,
						   _porc_impuesto,
						   _cod_coasegur
					  from emifafac
					 where no_poliza      = v_nopoliza
					   and no_endoso      = v_noendoso
					   and cod_contrato   = v_cod_contrato
					   and cod_cober_reas = v_cobertura
					   and no_unidad     = _no_unidad 
					 			
					select nombre
					  into _nombre_coas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
					let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comis_ase;

					let _monto_reas = v_prima     * _porc_cont_partic / 100;
					let _impuesto   = _monto_reas * _porc_impuesto / 100;
					let _comision   = _monto_reas * _porc_comis_ase / 100;
					let _por_pagar  = _monto_reas - _impuesto - _comision;

					select count(*)
					  into _cantidad
					  from temp_produccion
					 where cod_ramo      = v_cod_ramo
					   and cod_subramo   = _cod_subramo
					   and cod_origen    = _cod_origen
					   and cod_contrato  = v_cod_contrato
					   and cod_cobertura = v_cobertura
					   and desc_cob      = v_desc_cobertura;

					if _cantidad = 0 then
						insert into temp_produccion
						values(	v_cod_ramo,
								_cod_subramo,
								_cod_origen,
								v_cod_contrato,
								v_desc_contrato,
								v_cobertura,
								_monto_reas,
								_tipo_cont,
								_comision, 
								_impuesto, 
								_por_pagar,
								v_desc_cobertura,
								_serie,
								1,
								_porc_comision,
								_porc_impuesto,
								_porc_cont_partic,
								_cod_coasegur,
								_tiene_comis_rea);
					else
						update temp_produccion
						   set prima     = prima     + _monto_reas,
							   comision  = comision  + _comision,
							   impuesto  = impuesto  + _impuesto,
							   por_pagar = por_pagar + _por_pagar
						 where cod_ramo  = v_cod_ramo
						   and cod_subramo	= _cod_subramo
						   and cod_origen    = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura;
					end if
				end foreach
			end if	
		end if
	end foreach
end foreach
--trace off;

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

if a_contrato <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Contrato "||trim(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update temp_produccion
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato not in(select codigo from tmp_codigos);
	else
		update temp_produccion
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

-- Filtro por Serie
if a_serie <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" Serie "||trim(a_serie);
	let _tipo = sp_sis04(a_serie); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_produccion
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in(select codigo from tmp_codigos);
	else
		update temp_produccion
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

let v_filtros = trim(v_filtros1)||" "|| trim(v_filtros);

-- Carga Temporal contrato por ramos.
foreach 
	select cod_ramo,
	    cod_subramo,
		cod_origen,
        cod_contrato,
		desc_contrato,
        cod_cobertura,
		prima,
		tipo,
		comision,
		impuesto,
		por_pagar,
		desc_cob,
		porc_comision, 
		porc_impuesto, 
		porc_cont_partic, 
		cod_coasegur,
		serie
	into v_cod_ramo, 
         _cod_subramo,
		 _cod_origen,
         v_cod_contrato,
		 v_desc_contrato,
         v_cobertura,	  
         _monto_reas,	   
         _tipo_cont,		
         _comision, 		 
         _impuesto, 		  
         _por_pagar,		   
         v_desc_cobertura,		
         _porc_comision,		 
         _porc_impuesto,		  
         _porc_cont_partic,		   
         _cod_coasegur,
         _serie1				
	from temp_produccion

	let _p_c_partic     = 0;
	let _p_c_partic_hay = 0;

	select traspaso,tiene_comision
	  into _traspaso,_tiene_comision
	  from reacocob
	 where cod_contrato   = v_cod_contrato
	   and cod_cober_reas = v_cobertura;

	select tipo_contrato, serie
	  Into v_tipo_contrato,_serie
	  From reacomae
	 Where cod_contrato = v_cod_contrato;

	LET _seleccionado = 1;
	let _serie        = _serie1;

	if _serie < 2008 then
		LET _seleccionado = 0;
	end if

	if v_cod_ramo in ("001","003","010","011","012","013","014","021","022") then 
		let _seleccionado = 1;
	end if
	{if (v_cod_ramo = "021" or v_cod_ramo = "022" or v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "012" or v_cod_ramo = "013"  or v_cod_ramo = "014" or v_cod_ramo = "001"  or v_cod_ramo = "003") then 
		LET _seleccionado = 1;
	end if}
	
	if v_cobertura = '021' and  v_cod_ramo = '001' then
		let _seleccionado = 1;
	end if
	
	if v_cobertura = '022' and  v_cod_ramo = '003' then
		let _seleccionado = 1;
	end if
	
	if v_tipo_contrato <> 1 then 
		let _seleccionado = 0;
	end if

	insert into temphg1
	values(	_cod_coasegur,
			v_cod_ramo,
			v_cod_contrato,
			v_desc_contrato,
			v_cobertura,
			_monto_reas,
			_tipo_cont,
			_comision, 
			_impuesto, 
			_por_pagar,
			v_desc_cobertura,
			_porc_comision,
			_porc_impuesto,
			_porc_cont_partic,
			_serie,
			v_tipo_contrato,
			_tiene_comision,
			_seleccionado,
			_anio_reas,
			_trim_reas,
			_borderaux);
end foreach

-- Ingresa el cuadro MAFPFRE 50% RETENCION 
-- CARACTERISTICAS : del 2008 hasta la fecha, reaseguradora ANCON y tipo contrato retencion
-- and cod_cobertura = '001' --and cod_ramo = '001' --and cod_coasegur = '036' 
--set debug file to "sp_pr989.trc";	
--trace on;
let _cod_coasegur = '063' ;  
let _porc_cont_partic = 50;

let _anio_reas = _anio_reas;
let _trim_reas = _trim_reas; 

FOREACH
	select serie,
		   tipo_contrato,
		   porc_cont_partic,
		   porc_comision,
		   porc_impuesto,
		   cod_ramo,
		   cod_contrato,
		   cod_cobertura,
		   sum(prima)
	  into _serie,
		   v_tipo_contrato,
		   _porc_cont_partic,
		   _porc_comision,
		   _porc_impuesto,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   v_prima
	  from temphg1
     Where serie >= 2008
	   and seleccionado = 1
	   and anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura

	if v_cod_ramo in ("021","022","010","011","012","013","014","001","003") then 
	else
		continue foreach;
	end if

	if v_tipo_contrato <> 1 then 
		continue foreach;
	end if
	
	let _siniestro = 0;
	let v_clase = v_cod_ramo;					 
	let _p_50_prima     = 50;
	let _p_50_siniestro = 50;
	let v_prima50 = (v_prima * _p_50_prima)/100;

   --Buscar por medio de la serie, el contrato mapfre que corresponde para luego buscar el % de comision.
	let _serie2 = _serie;

	if _serie >= 2008 then --and _serie < 2012
		let _serie = 2012;
	end if

	let _cod_contrato_map = null;
	
	foreach
		select cod_contrato
		  into _cod_contrato_map
		  from reacomae
		 where ret_mapfre = 1
		   and serie      = _serie
		exit foreach;
	end foreach

	let _serie = _serie2;
	
	if _cod_contrato_map is not null then
		foreach
			select porc_comision
			  into _porc_comision
			  from reacoase
			 where cod_contrato	 = _cod_contrato_map
			   and cod_cober_reas = v_cobertura
			exit foreach;
		end foreach
	end if

	LET _comision = v_prima50 * _porc_comision/100 ;
	LET _impuesto = v_prima50 * 0.02 ;

	if  v_cod_ramo = '001' or v_cod_ramo = '003' then
		let _xnivel = '001';
		if v_cobertura = '021' and v_cod_ramo = '001' then
			let  v_clase   = 'INT';
			let _siniestro = 0  ;
			LET _comision  = v_prima50 * 0.225;
		end if
		if v_cobertura = '001' and v_cod_ramo = '001' then
			let  v_clase = 'INI';
		end if
		if v_cobertura = '022' and v_cod_ramo = '003' then
			let  v_clase   = 'MUT';
			let _siniestro = 0;
			LET _comision  = v_prima50 * 0.225;
		end if
		if v_cobertura = '003' and v_cod_ramo = '003' then
			let  v_clase = 'MUI';
		end if
	else
		let _xnivel = '002';
	end if

	let _siniestro50 = (_siniestro * _p_50_siniestro)/100;
	let _por_pagar   = v_prima50 - _comision - _impuesto;

	begin
	on exception in(-239)
		update reacoret
		   set prima        = prima + v_prima50, 
			   comision     = comision + _comision, 
			   impuesto     = impuesto + _impuesto, 
			   prima_neta   = prima_neta + _por_pagar, 
			   siniestro    = siniestro + _siniestro50 
		 where cod_coasegur	= _cod_coasegur
		   and cod_contrato = _serie
		   and cod_cobertura  = _xnivel
-- 				   and p_partic = _porc_cont_partic
		   and cod_ramo = v_cod_ramo
		   and cod_clase = v_clase 
		   and anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = _borderaux;
	end exception 	

	insert into reacoret
	values (_cod_coasegur,
			v_cod_ramo,
			_serie,
			_xnivel,
			v_prima50, 
			_comision, 
			_impuesto, 
			_por_pagar,
			_siniestro50,
			0,
			0,
			0,
			v_clase,
			_anio_reas,
			_trim_reas,
			_borderaux);
	end
end foreach		

-- Ingreso los siniestros aparte
let as_monto = 0;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --tabla para excluir polizas

foreach
	select r.serie,
		   t.cod_ramo,
		   sum(t.pagado_neto)
	  into as_serie,as_cod_ramo,as_monto
	  from tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato in ('1')
	   and r.serie >= 2008  
	   and t.cod_ramo in ("010","011","012","013","014","001","003","021","022")
     group by r.serie,t.cod_ramo
     order by r.serie,t.cod_ramo

	if as_cod_ramo in ("021","022","010","011","012","013" ,"014","001" ,"003") then 
	else
		continue foreach;
	end if
	{if (as_cod_ramo = "021" or as_cod_ramo = "022" or as_cod_ramo = "010" or as_cod_ramo = "011" or as_cod_ramo = "012" or as_cod_ramo = "013"  or as_cod_ramo = "014" or as_cod_ramo = "001"  or as_cod_ramo = "003") then 
	else
		continue foreach;
	end if}

	let _siniestro50 = 0;
	let v_prima50    = 0;
	let _comision    = 0;
	let _impuesto    = 0;
	let _por_pagar   = 0;

	let _siniestro50 = 50/100 * as_monto;

	if  as_cod_ramo = "001" or as_cod_ramo = "003" then 
		let _xnivel = "001";
		if as_cod_ramo = "001" then
			let v_clase = "INI";
		else
			let v_clase = "MUI";
		end if
	else
		let _xnivel = "002";
		let v_clase = as_cod_ramo;
	end if

	begin
		on exception in(-239)
			update reacoret
			   set prima         = prima      + v_prima50, 
				   comision      = comision   + _comision, 
				   impuesto      = impuesto   + _impuesto, 
				   prima_neta    = prima_neta + _por_pagar, 
				   siniestro     = siniestro  + _siniestro50 
			 where cod_coasegur	 = _cod_coasegur
			   and cod_contrato  = as_serie
			   and cod_cobertura = _xnivel
			   and cod_ramo      = as_cod_ramo
			   and cod_clase     = v_clase 
			   and anio          = _anio_reas
			   and trimestre     = _trim_reas
			   and borderaux     = _borderaux;
		end exception 	

		insert into reacoret
		values (_cod_coasegur,
				as_cod_ramo,
				as_serie,
				_xnivel,
				0,  				--v_prima50, 
				0,  				--_comision, 
				0,  				--_impuesto, 
				0,  				--_por_pagar,
				_siniestro50,
				0,
				0,
				0,
				v_clase,
				_anio_reas,
				_trim_reas,
				_borderaux);
	end
end foreach	

--Traspaso de Cartera
foreach
	select cod_coasegur,
		   cod_clase,
		   cod_contrato,
		   cod_cobertura,
		   p_partic,
		   cod_ramo,
		   sum(prima),
		   sum(comision),
		   sum(impuesto),
		   sum(prima_neta),
		   sum(siniestro),
		   sum(resultado),
		   sum(participar)			
	  into _cod_coasegur,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   _porc_cont_partic,
		   _cod_ramo,
		   v_prima, 
		   _comision, 
		   _impuesto, 
		   _por_pagar,
		   _siniestro,
		   _prima_tot_ret,
		   _prima_sus_tot			
	  from reacoret	
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux
	   and cod_contrato < 2012
	   and cod_clase in('INI','MUI','INT','MUT') --solo para incendio y terremoto
	 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo
	 order by cod_coasegur,cod_clase,cod_contrato

	select count(*)
	  into _cnt_agrupa
	  from reacoret
	 where anio			= _anio_reas
	   and trimestre	= _trim_reas
	   and borderaux	= _borderaux
	   and cod_contrato	= 2012
	   and cod_clase	= v_cod_ramo
	   and cod_ramo    = _cod_ramo
--	   and prima		<> 0
	 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo;

	if _cnt_agrupa is null or _cnt_agrupa = 0 then
	    insert into reacoret
		values (_cod_coasegur,
		        _cod_ramo,
				2012,
				v_cobertura,
				v_prima, 
				_comision, 
				_impuesto,
				_por_pagar,
				0,--_siniestro, --
				0,
				0,
				_porc_cont_partic,
		        v_cod_ramo,
				_anio_reas,
				_trim_reas,
				_borderaux);
	else
		let v_prima	   = v_prima/_cnt_agrupa;	 
		let	_comision  = _comision/_cnt_agrupa;
		let	_impuesto  = _impuesto /_cnt_agrupa;
		let	_por_pagar = _por_pagar /_cnt_agrupa;

		update reacoret
		   set prima         = prima      + v_prima, 
		       comision      = comision   + _comision, 
		       impuesto      = impuesto   + _impuesto, 
		       prima_neta    = prima_neta + _por_pagar 
		 where cod_coasegur	 = _cod_coasegur
		   and cod_contrato  = 2012
		   and cod_cobertura = v_cobertura
		   and cod_clase     = v_cod_ramo
		   and cod_ramo      = _cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux;
	   	   --and prima         <> 0;
	end if

	update reacoret
	   set prima         = 0,
	       comision      = 0,
	       impuesto      = 0,
	       prima_neta    = 0
	 where cod_coasegur	 = _cod_coasegur
	   and cod_contrato  = v_cod_contrato
	   and cod_cobertura = v_cobertura
	   and cod_clase     = v_cod_ramo
       and cod_ramo      = _cod_ramo
	   and p_partic      = _porc_cont_partic
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux;

	delete from reacoret
	 where prima         = 0
	   and comision      = 0
	   and impuesto      = 0
	   and prima_neta    = 0
	   and siniestro     = 0
	   and cod_coasegur	 = _cod_coasegur
	   and cod_contrato  = v_cod_contrato
	   and cod_cobertura = v_cobertura
	   and cod_clase     = v_cod_ramo
	   and p_partic      = _porc_cont_partic
       and cod_ramo      = _cod_ramo
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux;
end foreach
------------
update reacoret
   set participar = prima_neta - siniestro,
  	   p_partic   = prima * 2,
       resultado  = siniestro * 2 
 where anio       = _anio_reas
   and trimestre  = _trim_reas
   and borderaux  = _borderaux;

--trace off;
foreach
	select cod_coasegur,
		   cod_clase,
		   cod_contrato,
		   cod_cobertura,
		   sum(p_partic),
		   sum(prima),
		   sum(comision),
		   sum(impuesto),
		   sum(prima_neta),
		   sum(resultado),
		   sum(siniestro),
		   sum(participar)
	  into _cod_coasegur,
		   v_cod_ramo,
		   v_cod_contrato,
		   v_cobertura,
		   _porc_cont_partic,
		   v_prima, 
		   _comision, 
		   _impuesto, 
		   _por_pagar,
		   _siniestro,
		   _prima_sus_tot,
		   _prima_tot_ret	
	  from reacoret
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura

	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;

	if v_cod_ramo = '001' then
	   let v_desc_ramo = 'INCENDIO';
	end if
	if v_cod_ramo = '003' then
	   let v_desc_ramo = 'TERREMOTO';
	end if

	if v_cod_ramo = 'INI' then
	   let v_desc_ramo = 'INCENDIO-INCENDIO';
	end if
	if v_cod_ramo = 'INT' then
	   let v_desc_ramo = 'INCENDIO-TERREMOTO';
	end if
	if v_cod_ramo = 'MUI' then
	   let v_desc_ramo = 'MULTIRIESGO-INCENDIO';
	end if
	if v_cod_ramo = 'MUT' then
	   let v_desc_ramo = 'MULTIRIESGO-TERREMOTO';
	end if

	if v_cod_ramo = '003' then
	   let v_desc_ramo = 'TERREMOTO';
	end if

	select nombre
	  into v_desc_contrato
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	return	_cod_coasegur,	  --01
			v_cod_ramo,		  --02
			v_cod_contrato,	  --03
			v_cobertura,	  --04
			v_prima, 		  --05
			_comision, 		  --06
			_impuesto, 		  --07
			_por_pagar,		  --08
			_siniestro,		  --09
			_prima_tot_ret,	  --10
			_prima_sus_tot,	  --11
			_porc_cont_partic,--12
			v_desc_ramo,	  --13
			v_desc_contrato,  --14
			v_descr_cia,	  --15
			v_filtros		  --16
			with resume;
end foreach

drop table temp_produccion;
drop table temp_det;
drop table tmp_sinis;

end
end procedure  