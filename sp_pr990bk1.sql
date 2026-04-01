---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO           
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		50% RETENCION MAPFRE  HENRY
-- 		PRIMA COBRADA
-- execute procedure sp_pr990('001','001','2013-07','2013-09',"*","*","*","*","001,003,010,011,012,013,014,021,022;","*","*","2013,2012,2011,2010,2009,2008;")
-- Modificado para que tome el siniestro aunque no haga pagos de todos los contratos retencion de aseguradora ancon para los periodos solicitados. Henry.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros
-- Modificado por Román Gordón 11/10/2013 ; Proceso de Devolución de Prima
-- 
---------------------------------------------------------------------------------
drop procedure sp_pr990bk1;
create procedure sp_pr990bk1(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*")
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
define v_desc_contrato    	char(50);
define _nombre_coas			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_descr_cia			char(50);
define v_desc_ramo			char(50);
define _error_desc			char(50);
define ls_noex				char(50);
define _cuenta				char(25);
define _no_doc				char(20);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define _periodo1			char(7);
define _cod_contrato_map	char(5);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define as_cod_ramo			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define _xnivel				char(3);
define v_clase				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define v_prima50			dec(16,2);      
define v_prima1				dec(16,2);      
define v_prima				dec(16,2);      
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define _por_pagar			dec(16,2);
define _siniestro			dec(16,2);
define _traspaso			smallint;
define _tiene_comis_rea		smallint;
define _cantidad			smallint;
define _tipo_cont			smallint;
define v_tipo_contrato		smallint;  	
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro50			dec(16,2);
define _siniestro30			dec(16,2);
define _porc_impuesto4		dec(16,4);
define _porc_comision4		dec(16,4);
define _porc_comisiond		dec(16,4);
define _p_50_prima			dec(16,2);
define _p_50_siniestro		dec(16,2);
define _porc_cont_partic	dec(16,2);
define _prima_tot_ret		dec(16,2);
define _porc_comis_ase		dec(16,2);
define _monto_reas			dec(16,2);
define v_prima_suscrita		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_cobrada		dec(16,2);
define _porc_partic_coas	dec(16,4);
define _fecha				date;
define _porc_partic_prima	dec(16,6);
define _p_sus_tot			dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _ano					smallint;
define _tot_comision		dec(16,2);
define _tot_impuesto		dec(16,2);
define _tot_prima_neta		dec(16,2);
define _tiene_comision		smallint;
define _p_c_partic			dec(16,2);
define _p_c_partic_hay		smallint;
define v_existe				smallint;
define _seleccionado		smallint;
define _nivel				smallint;
define nivel				smallint;
define _trim_reas			smallint;
define _no_cambio			smallint;
define v_prima50_7			dec(16,4);
define _comision_7			dec(16,4);
define _impuesto_7			dec(16,4);
define _por_pagar_7			dec(16,4);
define _siniestro50_7		dec(16,4);
define v_prima50_3			dec(16,4);
define _comision_3			dec(16,4);
define _impuesto_3			dec(16,4);
define _por_pagar_3			dec(16,4);
define _siniestro50_3		dec(16,4);
define _serie2				smallint;
define _serie				smallint;
define as_monto				dec(16,2);
define _tipo2				smallint;
define _cnt					smallint;
define _prima_devuelta		dec(16,2);
define _error				integer;
define _no_remesa			char(10);
define _renglon				smallint;
define _porc_proporcion		dec(5,2);
define _dt_vig_inic          date;

--let a_codramo = "001,003,010,011,012,013,014,022;";   -- Solicitud: Sr. Naranjo 03/09/2010

SET ISOLATION TO DIRTY READ;

LET _borderaux = "03";	    -- 50 % RET MAPFRE

select tipo 
  into _tipo2 
 from reacontr 
where cod_contrato = _borderaux;

CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas; 

let v_filtros1 = "";

DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
DELETE FROM temphg where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;     -- Elimina borderaux datos;

if a_codramo = '*' then
	let a_codramo = "001,003,010,011,012,013,014,021,022;";
end if

-- set debug file to "sp_pr990.trc";	  	  	  	
let _ano = a_periodo1[1,4];
let _periodo1 = a_periodo1;
let v_descr_cia = sp_sis01(a_compania);

if a_periodo2 >= '2013-07' then

	if _periodo1 <= '2013-09' then
		let _periodo1 = '2008-01';
	end if

	--Proceso de Devolución de Prima		
	call sp_pr860c1(a_compania,a_agencia,_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
					a_codagente,a_codusuario,a_codramo,a_reaseguro,a_serie,_borderaux)
	returning _error,_error_desc;

	if _error = 1 then
		drop table temp_produccion;
		RETURN	"",
				"",
				"",
				"",
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				0.00, 
				"No Existe Distribucion de Reaseguro",
				"",
				v_descr_cia,
				"";
	end if
	select * 
	  from temp_produccion
	  into temp temp_devpri;

	drop table temp_produccion;
end if

CALL sp_pro307(	a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
				a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;

-- Cargar el Incurrido
LET v_filtros = sp_rec708(
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

create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(cod_coasegur);
create index idx8_temp_produccion on temp_produccion(serie);

create temp table tmp_priret
	   (cod_ramo         char(3),
		prima_sus_tot    dec(16,2),
		prima            dec(16,2),
		prima_sus_t      dec(16,2)) with no log;

let v_prima        = 0;
let _cod_subramo   = "001";
let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot     = 0;
let _p_sus_tot_sum = 0;
let _tipo_cont     = 0;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in (select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

let _cnt = 0;

FOREACH
	select z.no_poliza,
		   z.no_endoso,
		   z.prima_neta,   -- sum(z.prima_neta),
		   z.vigencia_inic, --min(z.vigencia_inic)
		   z.no_documento,
		   z.no_remesa,
		   z.renglon
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_cobrada,
		   _fecha,
		   _no_doc,
		   _no_remesa,
		   _renglon
	  from temp_det z
	 where z.seleccionado = 1

	select count(*)
	  into _cnt
	  from reaexpol
	 where no_documento = _no_doc
	   and activo       = 1;

	if _cnt = 1 then                         --"0110-00406-01" or _no_doc = "0110-00407-01" or _no_doc = "0109-00700-01" then --Estas polizas del Bco Hipotecario no las toman en cuenta.
		continue foreach;
	end if

	select cod_ramo,
		   cod_origen,
		   vigencia_inic
	  into v_cod_ramo,
		   _cod_origen,
		   _dt_vig_inic
	  from emipomae
	 where no_poliza = v_nopoliza;

	 if _dt_vig_inic <= '30/06/2014' then
	 else
	 	continue foreach;	
	 end if

	select porc_partic_coas
	  into _porc_partic_coas 
	  from emicoama
	 where no_poliza    = v_nopoliza
	   and cod_coasegur = "036"; 			

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let v_prima_cobrada = v_prima_cobrada * _porc_partic_coas / 100;

	select count(*)
	  into _cantidad
	  from tmp_priret
	 where cod_ramo = v_cod_ramo;

	if _cantidad = 0 then
		INSERT INTO tmp_priret
		VALUES(v_cod_ramo,v_prima_cobrada,0,0);
	else
		update tmp_priret
		   set prima_sus_tot = prima_sus_tot + v_prima_cobrada
		 where cod_ramo = v_cod_ramo;
	end if

	foreach
		select cod_contrato,
			   porc_partic_prima,
			   porc_proporcion,
			   cod_cober_reas
		  into v_cod_contrato,
			   _porc_partic_prima,
			   _porc_proporcion,
			   v_cobertura
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		  
		select traspaso,
			   tiene_comision
		  into _traspaso,
			   _tiene_comision
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		select cod_traspaso,
			   tipo_contrato,
			   serie
		  into _cod_traspaso,
			   v_tipo_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

		let _tipo_cont = 0;

		if v_tipo_contrato = 3 then
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;

			update tmp_priret
			   set prima = prima + v_prima1
			 where cod_ramo = v_cod_ramo;

			let _tipo_cont = 1;
		end if

		let v_prima1 = v_prima_cobrada * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		let v_prima  = v_prima1;

		select nombre,
			   serie
		  into v_desc_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let _nombre_con = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;
		let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		Select porc_impuesto,
			   porc_comision,
			   tiene_comision
		  Into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  From reacocob
		 Where cod_contrato   = v_cod_contrato
		   And cod_cober_reas = v_cobertura;

		SELECT nombre
		  INTO _nombre_cob
		  FROM reacobre
		 WHERE cod_cober_reas = v_cobertura;

		select count(*)
		  into _cantidad
		  from reacoase
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _porc_comis_ase = 0;
		
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
					INSERT INTO temp_produccion
						 VALUES(v_cod_ramo,
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

						INSERT INTO temp_produccion
							  VALUES(v_cod_ramo,
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
					   
						UPDATE temp_produccion
						   SET prima         = prima + _monto_reas,
							   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
						 WHERE cod_ramo      = v_cod_ramo
						   and cod_subramo   = _cod_subramo
						   and cod_origen    = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura;
					end if
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
			let _porc_cont_partic = 0;
			let v_desc_cobertura = "";
			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

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
				INSERT INTO temp_produccion
					   VALUES(v_cod_ramo,
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
				UPDATE temp_produccion
				   SET prima         = prima     + _monto_reas,
					   comision      = comision  + _comision,
					   impuesto      = impuesto  + _impuesto,
					   por_pagar     = por_pagar + _por_pagar
				 WHERE cod_ramo      = v_cod_ramo
				   and cod_subramo   = _cod_subramo
				   and cod_origen    = _cod_origen
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
			   and cod_cober_reas = v_cobertura;
			   --and no_unidad      = _no_unidad;

			let _porc_cont_partic = 0;
			
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
					INSERT INTO temp_produccion
					VALUES(	v_cod_ramo,
							_cod_subramo,
							_cod_origen,
							v_cod_contrato,
							v_desc_contrato,
							v_cobertura,
							0,
							_tipo_cont,
							0, 
							0, 
							0,
							_nombre_cob,
							_serie,
							1,
							_porc_comision,
							_porc_impuesto,
							_porc_cont_partic,
							_cod_coasegur,
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
					   --and no_unidad      = _no_unidad
						
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
						   set prima         = prima     + _monto_reas,
							   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
						 where cod_ramo      = v_cod_ramo
						   and cod_subramo   = _cod_subramo
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

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

IF a_contrato <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Contrato "||TRIM(a_contrato);
	LET _tipo = sp_sis04(a_contrato); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_contrato NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_contrato IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

-- Filtro por Serie

IF a_serie <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros);
--{
-- Devolucion de Prima
if a_periodo2 >= '2013-07' then
	FOREACH 
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
			   serie,
			   tiene_comision
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
			   _serie,
			   _tiene_comis_rea
		  from temp_devpri
		 where seleccionado = 1
	
		let _monto_reas = _monto_reas * -1;
		let _tipo_cont	= _tipo_cont * -1;
		let _comision	= _comision * -1;
		let _impuesto	= _impuesto * -1; 		  
		let _por_pagar	= _por_pagar  * -1;
		
		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_subramo   = _cod_subramo
		   and cod_origen    = _cod_origen
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = v_desc_cobertura;
		   --and serie         = _serie;

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
			   set prima         = prima     + _monto_reas,
				   comision      = comision  + _comision,
				   impuesto      = impuesto  + _impuesto,
				   por_pagar     = por_pagar + _por_pagar
			 where cod_ramo      = v_cod_ramo
			   and cod_subramo   = _cod_subramo
			   and cod_origen    = _cod_origen
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura;
			   --and serie         = _serie;
		end if
	end foreach
end if
--------------------------------------------
--}

-- Carga Temporal contrato por ramos.
FOREACH 
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
		   cod_coasegur
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
	       _cod_coasegur
	  from temp_produccion
	 WHERE seleccionado = 1
		
		let _p_c_partic     = 0;
		let _p_c_partic_hay = 0;

		select traspaso,tiene_comision
		  into _traspaso,_tiene_comision
		  from reacocob
		 where cod_contrato = v_cod_contrato
	       and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		  Into v_tipo_contrato,_serie
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

		LET _seleccionado = 1;

		if _serie < 2008 then
			LET _seleccionado = 0;
		end if

		if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "012" or v_cod_ramo = "013"  or v_cod_ramo = "014" or v_cod_ramo = "022" or v_cod_ramo = "001"  or v_cod_ramo = "003" or v_cod_ramo = "021") then 
			LET _seleccionado = 1;
		end if
		if v_cobertura = '021' and  v_cod_ramo = '001' then
			LET _seleccionado = 1;
		end if
		if v_cobertura = '022' and  v_cod_ramo = '003' then
			LET _seleccionado = 1;
		end if
		if v_tipo_contrato <> 1 then 
			LET _seleccionado = 0;
		end if

		INSERT INTO temphg
		VALUES (_cod_coasegur,
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
END FOREACH

-- Ingresa el cuadro MAFPFRE 50% RETENCION 
-- CARACTERISTICAS : del 2008 hasta la fecha, reaseguradora ANCON y tipo contrato retencion
-- and cod_cobertura = '001' --and cod_ramo = '001' --and cod_coasegur = '036' 
-- set debug file to "sp_pr989.trc";	
-- trace on;
LET _cod_coasegur     = '063';  
LET _porc_cont_partic = 50;

LET _anio_reas = _anio_reas;
LET _trim_reas = _trim_reas; 

FOREACH
   select serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura,sum(prima)
     into _serie,v_tipo_contrato,_porc_cont_partic,_porc_comision,_porc_impuesto,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima
     from temphg
    Where serie >= 2008 
      and seleccionado = 1
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
    group by serie,tipo_contrato,porc_cont_partic,porc_comision,porc_impuesto,cod_ramo,cod_contrato,cod_cobertura

   if v_tipo_contrato <> 1 then 
   		continue foreach;
   end if
   if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "012" or v_cod_ramo = "013"  or v_cod_ramo = "014" or v_cod_ramo = "022" or v_cod_ramo = "001" or v_cod_ramo = "003" or v_cod_ramo = "021") then
   else
		continue foreach;
   end if

   let _siniestro      = 0;
   let v_clase         = v_cod_ramo;
   LET _p_50_prima     = 50;
   LET _p_50_siniestro = 50;
   LET v_prima50       = (v_prima * _p_50_prima)/100;

	if v_cod_ramo = '001' or v_cod_ramo = '003' then 
		 let v_clase = '002' ;
	end if					

	if v_cod_ramo = '010' or v_cod_ramo = '012' or v_cod_ramo = '011' or v_cod_ramo = '013' or v_cod_ramo = '014' or v_cod_ramo = '022' or v_cod_ramo = '021' then
		 let v_clase = '004' ;
	end if

   --Buscar por medio de la serie, el contrato mapfre que corresponde para luego buscar el % de comision.
   let _serie2 = _serie;

   if _serie >= 2008 then --and _serie < 2012 then
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

	if  v_cod_ramo = '001' or v_cod_ramo = '003' then 
		LET _impuesto = v_prima50 * 0.02;

		let _xnivel = '001';
		if v_cobertura = '021' and v_cod_ramo = '001' then
		
			--let  v_clase = '003'; --let  v_clase = 'INT';
			--let _siniestro = 0  ;
			foreach
				select porc_comision
				  into _porc_comision
				  from reacoase
				 where cod_contrato	 = _cod_contrato_map
				   and cod_cober_reas = '001'

				exit foreach;
			end foreach
			LET _comision = v_prima50 * _porc_comision/100;
		end if
		{if v_cobertura = '001' and v_cod_ramo = '001' then
		   let  v_clase = '002';	--let  v_clase = 'INI';
		end if}
		if v_cobertura = '022' and v_cod_ramo = '003' then
--			let  v_clase = '003'; --let  v_clase = 'INT';
--			let _siniestro = 0  ;
			
			foreach
				select porc_comision
				  into _porc_comision
				  from reacoase
				 where cod_contrato	 = _cod_contrato_map
				   and cod_cober_reas = '003'
			   exit foreach;
			end foreach

			LET _comision = v_prima50 * _porc_comision/100;
		end if
		{if v_cobertura = '003' and v_cod_ramo = '003' then
		   let  v_clase = '002';	--let  v_clase = 'INI';
		end if}

		LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;							
		LET _por_pagar   = v_prima50 - _comision - _impuesto ;

		LET v_prima50_7 = 0 ;
		LET _comision_7 =  0 ; 
		LET _impuesto_7 =  0 ; 
		LET _por_pagar_7 =  0 ;
		LET _siniestro50_7 =  0 ;

		LET v_prima50_3 = 0 ;
		LET _comision_3 =  0 ; 
		LET _impuesto_3 =  0 ; 
		LET _por_pagar_3 =  0;
		LET _siniestro50_3 = 0 ;

		-- 70

		LET v_prima50_7 = v_prima50 * 0.7 ;
		LET _comision_7 =  _comision * 0.7 ; 
		LET _impuesto_7 =  _impuesto * 0.7 ; 
		LET _por_pagar_7 =  _por_pagar * 0.7 ;
		LET _siniestro50_7 =  _siniestro50 ;

		BEGIN
			ON EXCEPTION IN(-239)
				UPDATE reacoest
				   SET prima = prima + v_prima50_7, 
					   comision = comision + _comision_7, 
					   impuesto = impuesto + _impuesto_7, 
					   prima_neta = prima_neta + _por_pagar_7, 
					   siniestro = siniestro + _siniestro50_7 
				 WHERE cod_coasegur	 = _cod_coasegur
				   AND cod_contrato  = _serie
				   AND cod_cobertura = _xnivel
				   AND cod_ramo      = v_cod_ramo
				   and cod_clase     = '002'--v_clase 
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;
			END EXCEPTION 	

			INSERT INTO reacoest
			VALUES (_cod_coasegur,
					v_cod_ramo,
					_serie,
					_xnivel,
					v_prima50_7, 
					_comision_7, 
					_impuesto_7, 
					_por_pagar_7,
					_siniestro50_7,
					0,
					0,
					0,
					'002',--v_clase,
					_anio_reas,
					_trim_reas,
					_borderaux);
		END
	-- 30
		LET v_prima50_3 = v_prima50 * 0.3;

		if  v_cod_ramo = '001' then
			let  v_clase = '003';
			let _siniestro50_3 = 0  ;
			LET _comision_3 = v_prima50_3 * 0.225;
		end if
		if  v_cod_ramo = '003' then
			let  v_clase = '003';
			let _siniestro50_3 = 0  ;
			LET _comision_3 = v_prima50_3 * 0.225;
		end if

		LET _impuesto_3 =  v_prima50_3 * 0.02 ; 
		LET _por_pagar_3 = v_prima50_3 - _comision_3 - _impuesto_3;

		BEGIN
		ON EXCEPTION IN(-239)
			UPDATE reacoest
			   SET prima = prima + v_prima50_3, 
				   comision = comision + _comision_3, 
				   impuesto = impuesto + _impuesto_3, 
				   prima_neta = prima_neta + _por_pagar_3, 
				   siniestro = siniestro + _siniestro50_3 
			 WHERE cod_coasegur	= _cod_coasegur
			   AND cod_contrato = _serie
			   AND cod_cobertura  = _xnivel
			   AND cod_ramo = v_cod_ramo
			   and cod_clase = v_clase 
			   and anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux = _borderaux;

		END EXCEPTION 	

		INSERT INTO reacoest
		VALUES (_cod_coasegur,
				v_cod_ramo,
				_serie,
				_xnivel,
				v_prima50_3, 
				_comision_3, 
				_impuesto_3, 
				_por_pagar_3,
				_siniestro50_3,
				0,
				0,
				0,
				v_clase,
				_anio_reas,
				_trim_reas,
				_borderaux);

		END
	else
		LET _impuesto = v_prima50 * 0.02;
		LET _xnivel = '002';
		LET _siniestro50 =  (_siniestro * _p_50_siniestro)/100;							
		LET _por_pagar = v_prima50 - _comision - _impuesto;
		BEGIN
		ON EXCEPTION IN(-239)
			UPDATE reacoest
			   SET prima = prima + v_prima50, 
				   comision = comision + _comision, 
				   impuesto = impuesto + _impuesto, 
				   prima_neta = prima_neta + _por_pagar, 
				   siniestro = siniestro + _siniestro50 
			 WHERE cod_coasegur	= _cod_coasegur
			   AND cod_contrato = _serie
			   AND cod_cobertura  = _xnivel
			   AND cod_ramo = v_cod_ramo
			   and cod_clase = v_clase 
			   and anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux = _borderaux;

		END EXCEPTION 	

		INSERT INTO reacoest
		VALUES (_cod_coasegur,
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
		END
	end if
END FOREACH		
-- trace on;
-- Ingreso los siniestros aparte
LET as_monto = 0;
FOREACH
       SELECT r.serie,t.cod_ramo,sum(t.pagado_neto)
	     INTO _serie,as_cod_ramo,as_monto
         FROM tmp_sinis t, reacomae r
        where r.cod_contrato = t.cod_contrato
          and t.seleccionado = 1
          and t.tipo_contrato in ('1')
          and r.serie >= 2008  
          and t.cod_ramo in ("010","011","012","013","014","001","003","021","022")
     group by r.serie,t.cod_ramo
     order by r.serie,t.cod_ramo

		if (as_cod_ramo = "010" or as_cod_ramo = "011" or as_cod_ramo = "012" or as_cod_ramo = "013"  or as_cod_ramo = "014" or as_cod_ramo = "022" or as_cod_ramo = "001"  or as_cod_ramo = "003" or as_cod_ramo = "021") then
		else
			continue foreach;
		end if

		let _siniestro50 = 0;
		let v_prima50    = 0;
		let _comision    = 0;
		let _impuesto    = 0;
		let _por_pagar   = 0;

		let _siniestro50 = 50/100 * as_monto;

		if  as_cod_ramo = "001" or as_cod_ramo = "003" then 
			LET _xnivel = "001";
			if as_cod_ramo = "001" then
 				LET v_clase = "002";
			else
 				LET v_clase = "002";
			end if
		else
			LET _xnivel = "002";
			LET v_clase = '004'; --as_cod_ramo;
		end if

		   	BEGIN
			ON EXCEPTION IN(-239)
				UPDATE reacoest
				   SET prima         = prima + v_prima50, 
					   comision      = comision + _comision, 
					   impuesto      = impuesto + _impuesto, 
					   prima_neta    = prima_neta + _por_pagar, 
					   siniestro     = siniestro + _siniestro50 
				 WHERE cod_coasegur	 = _cod_coasegur
				   AND cod_contrato  = _serie
				   AND cod_cobertura = _xnivel
				   AND cod_ramo      = as_cod_ramo
				   and cod_clase     = v_clase 
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;

			END EXCEPTION 	

			INSERT INTO reacoest
			VALUES (_cod_coasegur,
			        as_cod_ramo,
					_serie,
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
		  	END
END FOREACH	

--trace off;

--Traspaso de Cartera serie 2008 hasta 2011 pasa a serie 2012 Omar Wong 09/01/2013.
--{
FOREACH
     SELECT cod_coasegur,
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
       INTO _cod_coasegur,
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
       FROM reacoest	
	  where anio      = _anio_reas
		and trimestre = _trim_reas
		and borderaux = _borderaux
		and cod_contrato < 2013
		and cod_clase in('002','003') --solo para incendio y terremoto
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo
	  order by cod_coasegur,cod_clase,cod_contrato
	
	let _cnt = 0;
	
	select count(*)
	  into _cnt
	  from reacoest
	 WHERE cod_coasegur	 = _cod_coasegur
	   AND cod_contrato  = 2013
	   AND cod_cobertura = v_cobertura
	   AND cod_clase     = v_cod_ramo
	   and cod_ramo      = _cod_ramo
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux
	   and prima         <> 0;
	   
	if _cnt > 0 then
		let  v_prima	= v_prima / _cnt;
		let _comision	= _comision / _cnt;
		let _impuesto	= _impuesto / _cnt;
		let _por_pagar	= _por_pagar / _cnt;
		
		UPDATE reacoest
		   SET prima         = prima      + v_prima, 
			   comision      = comision   + _comision, 
			   impuesto      = impuesto   + _impuesto, 
			   prima_neta    = prima_neta + _por_pagar 
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = 2013
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and cod_ramo      = _cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;
	end if

 	UPDATE reacoest
	   SET prima         = 0,
	       comision      = 0,
	       impuesto      = 0,
	       prima_neta    = 0
	 WHERE cod_coasegur	 = _cod_coasegur
	   AND cod_contrato  = v_cod_contrato
	   AND cod_cobertura = v_cobertura
	   AND cod_clase     = v_cod_ramo
       and cod_ramo      = _cod_ramo
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux;

	delete from reacoest
	 where prima         = 0
	   and comision      = 0
	   and impuesto      = 0
	   and prima_neta    = 0
	   and siniestro     = 0
	   and cod_coasegur	 = _cod_coasegur
	   and cod_contrato  = v_cod_contrato
	   and cod_cobertura = v_cobertura
	   and cod_clase     = v_cod_ramo
       and cod_ramo      = _cod_ramo
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux;

END FOREACH
------------

Update reacoest 
   set participar = prima_neta - siniestro, 
  	   p_partic   = prima * 2, 
       resultado  = siniestro * 2 
 where anio      = _anio_reas 
   and trimestre = _trim_reas 
   and borderaux = _borderaux; 
--}
--trace off;
FOREACH
     SELECT cod_coasegur,
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
       INTO _cod_coasegur,
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
       FROM reacoest
	  where anio      = _anio_reas
	    and trimestre = _trim_reas
	    and borderaux = _borderaux 
	  group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura

			select nombre
			into v_desc_contrato
			from emicoase
			where cod_coasegur = _cod_coasegur;

			if v_prima = 0 then
--				continue foreach;
			end if

				SELECT nombre
				  INTO v_desc_ramo
				  FROM rearamo  
				 WHERE ramo_reas = v_cod_ramo ;

				if v_cod_ramo = '001' then
				   LET v_desc_ramo = 'R.C.G.' ;
				end if

				if v_cod_ramo = '002' then
				   LET v_desc_ramo = 'Incendio' ;
				end if

				if v_cod_ramo = '003' then
				   LET v_desc_ramo = 'Terremoto' ;
				end if

				if v_cod_ramo = '004' then
				   LET v_desc_ramo = 'Ramos Tecnicos' ;
				end if

				if v_cod_ramo = '005' then
				   LET v_desc_ramo = 'Fianzas' ;
				end if

				if v_cod_ramo = '006' then
				   LET v_desc_ramo = 'Acc. Personales' ;
				end if

				if v_cod_ramo = '007' then
				   LET v_desc_ramo = 'Vida Indindividual';
				end if

				if v_cod_ramo = '008' then
				   LET v_desc_ramo = 'Colectivo de Vida' ;
				end if

	         RETURN _cod_coasegur,	  --01
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
	                WITH RESUME;


END FOREACH
--DROP TABLE temp_produccion;
--DROP TABLE temp_det;
DROP TABLE tmp_priret;
DROP TABLE tmp_sinis;
DROP TABLE temp_devpri;

END

END PROCEDURE  



