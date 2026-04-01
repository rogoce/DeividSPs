--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--------------------------------------------
drop procedure sp_pr999e;
create procedure sp_pr999e(
			a_compania		char(03),
			a_agencia		char(03),
			a_periodo1		char(07),
			a_periodo2		char(07),
			a_codsucursal	char(255) default "*",
			a_codgrupo		char(255) default "*",
			a_codagente		char(255) default "*",
			a_codusuario	char(255) default "*",
			a_codramo		char(255) default "*",
			a_reaseguro		char(255) default "*",
			a_contrato		char(255) default "*",
			a_serie			char(255) default "*",
			a_subramo		char(255) default "*"
			)
returning	char(20),	   
			char(3),	   
			char(50),	   
			decimal(16,2), 
			decimal(16,2), 
			smallint,	   
			dec(16,2),	   
			dec(16,2),	   
			dec(16,2),	   
			dec(16,2),	   
			dec(16,2),	   
			char(255),	   
			char(50),	   
			dec(16,2);	   

begin

define v_filtros1			char(255);
define v_filtros			char(255);
define v_filtros2			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nombre_coas			char(50);
define v_desc_ramo			char(50);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_descr_cia			char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define v_nopoliza			char(10);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define v_cod_ramo			char(3);
define v_cobertura			char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cod_tipo			char(3);
define _t_ramo				char(1);
define _tipo				char(1);
define _fecha				date;
define v_prima_cobrada		decimal(16,2);
define _prima_tot_ret		decimal(16,2);
define _prima_sus_tot		decimal(16,2);
define _prima_tot_ret_sum	decimal(16,2);
define _prima_tot_sus_sum	decimal(16,2);
define _p_sus_tot			decimal(16,2);
define _p_sus_tot_sum		decimal(16,2);
define v_prima_tipo			decimal(16,2);
define v_prima_1			decimal(16,2);
define v_prima_3			decimal(16,2);
define v_prima_bq			decimal(16,2);
define v_prima_ot			decimal(16,2);
define v_rango_inicial		decimal(16,2);
define v_rango_final		decimal(16,2);
define v_suma_asegurada		decimal(16,2);
define _sum_fac_car			decimal(16,2);
define v_prima				decimal(16,2);
define v_prima1				decimal(16,2);
define _porc_impuesto		decimal(16,2);
define _porc_comision		decimal(16,2);
define _impuesto			decimal(16,2);
define _comision			decimal(16,2);
define _por_pagar			decimal(16,2);
define _monto_reas			decimal(16,2);
define v_prima_suscrita		decimal(16,2);
define _porc_partic_prima	decimal(9,6);
define _porc_partic_coas	decimal(7,4);
define _porc_cont_partic	decimal(5,2);
define _porc_comis_ase		decimal(5,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define v_porcentaje			smallint;
define _tipo_cont			smallint;
define _no_cambio			smallint;
define _traspaso			smallint;
define _cantidad			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _flag				smallint;
define _cnt					smallint;

	  	  	  	
set isolation to dirty read;

let v_descr_cia  = sp_sis01(a_compania);

call sp_pro307(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
               a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

    { CALL sp_pro314(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
                   a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING v_filtros;}

create temp table tmp_ramos(
							cod_ramo		char(3),
							cod_sub_tipo	char(3),
							porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;
		    							    

create temp table temp_produccion(
								  cod_ramo		char(3),
								  cod_subramo	char(3),
								  cod_origen	char(3),
								  cod_contrato	char(5),
								  desc_contrato	char(50),
								  cod_cobertura	char(3),
								  prima			decimal(16,2),
								  tipo			smallint default 0,
								  comision		decimal(16,2),
								  impuesto		decimal(16,2),
								  por_pagar		decimal(16,2),
								  desc_cob		char(100),
								  serie			smallint,
								  seleccionado	smallint default 1,
								  no_poliza		char(10),
								  cod_coasegur	char(3),
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, no_poliza)) with no log;

create index idx1_temp_produccion on temp_produccion(cod_ramo);
create index idx2_temp_produccion on temp_produccion(cod_subramo);
create index idx3_temp_produccion on temp_produccion(cod_origen);
create index idx4_temp_produccion on temp_produccion(cod_contrato);
create index idx5_temp_produccion on temp_produccion(cod_cobertura);
create index idx6_temp_produccion on temp_produccion(desc_cob);
create index idx7_temp_produccion on temp_produccion(no_poliza);
create index idx8_temp_produccion on temp_produccion(serie);
create index idx9_temp_produccion on temp_produccion(cod_coasegur);


create temp table tmp_tabla(
							no_documento	char(20),
							cod_ramo		char(3),
							desc_ramo		char(50),
							rango_inicial	decimal(16,2),
							rango_final		decimal(16,2),
							cant_polizas	smallint,
							p_cobrada		decimal(16,2),
							p_retenida		decimal(16,2),
							p_bouquet		decimal(16,2),
							p_facultativo	decimal(16,2),
							p_otros			decimal(16,2),
							p_fac_car		decimal(16,2),
primary key (no_documento,cod_ramo,rango_inicial)) with no log;

create temp table temp_fact(
							no_poliza		char(10),
							no_endoso		char(5),
							no_factura		char(10),
							seleccionado	smallint  default 1,
							suma_asegurada	decimal(16,2),
							sum_ret			decimal(16,2) default 0,
							sum_cont		decimal(16,2) default 0,
							sum_fac			decimal(16,2) default 0,
							sum_fac_car		decimal(16,2) default 0,
primary key (no_poliza,no_endoso,no_factura)) with no log;

let _prima_tot_ret = 0;
let _prima_sus_tot = 0;
let _p_sus_tot_sum = 0;
let _sum_fac_car   = 0;
let _tipo_cont     = 0;
let _p_sus_tot     = 0;
let v_prima        = 0;
let v_filtros1     = "";
let v_filtros2     = "";
let _cod_subramo   = "001";

if a_subramo <> "*" then
	let v_filtros2 = trim(v_filtros2) ||" Sub Ramo "||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

foreach
	select no_poliza,
		   no_endoso,
		   prima_neta,   -- sum(z.prima_neta),
		   vigencia_inic -- min(z.vigencia_inic)
	  into v_nopoliza,
	  	   v_noendoso,
	  	   v_prima_cobrada,
	  	   _fecha
	  from temp_det
	 where seleccionado = 1

	select cod_ramo,
		   cod_origen
	  into v_cod_ramo,
	  	   _cod_origen
	  from emipomae
	 where no_poliza = v_nopoliza;

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
	  from emireama	
	 where no_poliza      = v_nopoliza
	   and vigencia_inic  <= _fecha
	   and vigencia_final >= _fecha;

	if _cantidad = 0 then
		select count(*)
		  into _cantidad
		  from emireama	
		 where no_poliza = v_nopoliza;

		if _cantidad = 0 then
			return "",
				   "",  
				   "Error de Data",  
				   0, 
				   0,  
				   0,  
				   0,  
				   0,  
				   0,  
				   0,  
				   0, 
				   v_filtros, 
				   v_descr_cia,
				   0 	          
				   WITH RESUME;
		else
			select max(no_cambio)
			  into _no_cambio
			  from emireama	
			 where no_poliza = v_nopoliza;
		end if			   

	else
		select max(no_cambio)
		  into _no_cambio
		  from emireama	
		 where no_poliza      = v_nopoliza
		   and vigencia_inic  <= _fecha
		   and vigencia_final >= _fecha;

	end if

	select min(no_unidad)
	  into _no_unidad
	  from emireama
	 where no_poliza = v_nopoliza
	   and no_cambio = _no_cambio; 			    	

	select min(cod_cober_reas)
	  into v_cobertura
	  from emireama
	 where no_poliza = v_nopoliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;

	foreach
		select cod_contrato,
		   	   porc_partic_prima
		  into v_cod_contrato,
	       	   _porc_partic_prima
		  from emireaco
		 where no_poliza      = v_nopoliza
		   and no_unidad      = _no_unidad
		   and no_cambio      = _no_cambio
		   and cod_cober_reas = v_cobertura

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select cod_traspaso,
			   tipo_contrato,
			   serie
		  Into _cod_traspaso,
			   v_tipo_contrato,
			   _serie
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

		let _tipo_cont = 0;
		
		if v_tipo_contrato = 3 then
			let _tipo_cont = 2;
		elif v_tipo_contrato = 1 then --retencion
			let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
			let _tipo_cont = 1;
	   	end if

		let v_prima1 = v_prima_cobrada * _porc_partic_prima / 100;
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

		select porc_impuesto,
		       porc_comision,
			   tiene_comision
		  into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

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
				     and desc_cob      = _nombre_cob
				     and no_poliza     = v_nopoliza;

				if _cantidad = 0 then
				 		insert into temp_produccion
				             values(v_cod_ramo,
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
				                    v_nopoliza,
				                    '999');
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
					   and desc_cob      = v_desc_cobertura
					   and no_poliza     = v_nopoliza;

					if _cantidad = 0 then
						insert into temp_produccion
						values(v_cod_ramo,
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
			                   v_nopoliza,
			                   _cod_coasegur);
					else				   
			            update temp_produccion
			               set prima         = prima + _monto_reas,
			               	   comision      = comision  + _comision,
							   impuesto      = impuesto  + _impuesto,
							   por_pagar     = por_pagar + _por_pagar
			             where cod_ramo      = v_cod_ramo
						   and cod_subramo   = _cod_subramo
						   and cod_origen    = _cod_origen
			               and cod_contrato  = v_cod_contrato
			               and cod_cobertura = v_cobertura
			               and desc_cob      = v_desc_cobertura
			               and no_poliza     = v_nopoliza;
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
	           and desc_cob      = v_desc_cobertura
		       and no_poliza     = v_nopoliza;


	 		if _cantidad = 0 then
	 			insert into temp_produccion
	            values(v_cod_ramo,
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
		               v_nopoliza,
		               _cod_coasegur);
	 		else	 		   
	        	update temp_produccion
				   set prima			= prima     + _monto_reas,
	                   comision			= comision  + _comision,
	 				   impuesto			= impuesto  + _impuesto,
	 				   por_pagar		= por_pagar + _por_pagar
	             where cod_ramo     	= v_cod_ramo
	 			   and cod_subramo		= _cod_subramo
	 			   and cod_origen		= _cod_origen
	               and cod_contrato		= v_cod_contrato
	               and cod_cobertura	= v_cobertura
	               and desc_cob			= v_desc_cobertura
		           and no_poliza		= v_nopoliza;

	 		end if

		elif _tipo_cont = 2 then  --facultativos

			select count(*)
			  into _cantidad
			  from emifafac
			 where no_poliza      = v_nopoliza
			   and no_endoso      = v_noendoso
			   and cod_contrato   = v_cod_contrato
			   and cod_cober_reas = v_cobertura
			   and no_unidad      = _no_unidad;

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
				   and desc_cob      = _nombre_cob
				   and no_poliza     = v_nopoliza;

				if _cantidad = 0 then

			 		insert into temp_produccion
			        values(v_cod_ramo,
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
						   v_nopoliza,
						   '999'
						  );
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
			 	       and no_unidad      = _no_unidad
							 			
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
			           and desc_cob      = v_desc_cobertura
				       and no_poliza     = v_nopoliza;

			 		if _cantidad = 0 then

			 		   	insert into temp_produccion
			                  values(v_cod_ramo,
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
				                      v_nopoliza,
				                      _cod_coasegur);
			 		else

			               UPDATE temp_produccion
			                  SET prima			= prima     + _monto_reas,
				 			      comision		= comision  + _comision,
				 				  impuesto		= impuesto  + _impuesto,
				 				  por_pagar		= por_pagar + _por_pagar
			                WHERE cod_ramo		= v_cod_ramo
				 			  and cod_subramo	= _cod_subramo
				 			  and cod_origen	= _cod_origen
			                  and cod_contrato	= v_cod_contrato
			                  and cod_cobertura	= v_cobertura
			                  and desc_cob		= v_desc_cobertura
						      and no_poliza		= v_nopoliza;

			 		end if 
				end foreach
			end if
		end if
	end foreach
end foreach

let _prima_tot_ret_sum = 0;
let _prima_tot_sus_sum = 0;
let _p_sus_tot_sum     = 0;

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

if a_contrato <> "*" then
	let v_filtros1 = trim(v_filtros1) ||" contrato "||trim(a_contrato);
	let _tipo = sp_sis04(a_contrato); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
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
	let v_filtros1 = trim(v_filtros1) ||" serie "||trim(a_serie);
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

--- tabla de ramos:

foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from temp_produccion
	 where seleccionado = 1

	if v_cod_ramo in ("001", "003") then
		if v_cod_ramo in ("001") then
			let _t_ramo = "1";
		end if
		if v_cod_ramo in ("003") then
			let _t_ramo = "3";
		end if

		begin
			on exception in(-239)
			end exception

		    let v_cod_tipo = "IN"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,70);

		    let v_cod_tipo = "TE"||_t_ramo;

			insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,30);
		end
	else
		insert into tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
		values (v_cod_ramo,v_cod_ramo,100);
	end if	   	
end foreach

let v_filtros = trim(v_filtros)||" "|| trim(v_filtros2);

foreach
	select cod_ramo,		  --se busca por polizas
		   no_poliza,
	       sum(prima)
	  into v_cod_ramo,
		   v_nopoliza,
           v_prima
      from temp_produccion
	 where seleccionado = 1
     group by cod_ramo, no_poliza
     order by cod_ramo, no_poliza

	select suma_asegurada,
		   no_documento	
	  into v_suma_asegurada,
		   _no_documento	
	  from emipomae
	 where no_poliza    = v_nopoliza
	   and cod_compania = "001"
	   and actualizado  = 1;

	let v_prima_tipo = 0;
	let v_prima_1  = 0;
	let v_prima_3  = 0;
	let v_prima_bq = 0;
	let v_prima_ot = 0;

	foreach					 -- se desglosa por tipo, buscar primero si es bouquet
		select cod_contrato,
			   cod_cobertura,
			   tipo,
			   cod_coasegur,
			   serie,
			   sum(prima)
		  into v_cod_contrato,
		       v_cobertura,
			   _tipo_cont,
			   _cod_coasegur,
			   _serie,
			   v_prima_tipo
		  from temp_produccion
		 where cod_ramo = v_cod_ramo
		   and no_poliza = v_nopoliza 
		   and seleccionado = 1
		 group by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie 
		 order by cod_contrato,cod_cobertura,tipo,cod_coasegur,serie  

		let _flag = 0;
		let _cnt = 0;
		let _sum_fac_car = 0;

	   	select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		if _bouquet = 1 and _serie >= 2008 and _cod_coasegur in ('050','063','076','042','036','089') THEN	   -- Condiciones del Borderaux Bouquet
			select count(*) 
		      into _cnt
		      from reacomae  
		     where upper(nombre) like ('%FACILIDA%')  -- Condicion Ramos tecnicos
		       and cod_contrato  = v_cod_contrato;

			if _cnt = 0 then
				let _flag = 1;
			end if
		end if

		if _flag = 1 then
			if v_cod_contrato = "00574" or v_cod_contrato = "00584" or v_cod_contrato = "00594" or v_cod_contrato = "00604" then
				let _sum_fac_car = _sum_fac_car + v_prima_tipo;
			else
		   	   	let v_prima_bq = v_prima_bq + v_prima_tipo ;
			end if
		else
			if _tipo_cont = 2 or _tipo_cont = 1 then
				if _tipo_cont = 1 then		--	retencion
					let v_prima_1 = v_prima_1 + v_prima_tipo ;					   
				end if
				if _tipo_cont = 2 then		--  facultativos
					let v_prima_3 = v_prima_3 + v_prima_tipo ;					   
				end if
			else
				if v_cod_contrato = "00574" or v_cod_contrato = "00584" or v_cod_contrato = "00594" or v_cod_contrato = "00604" then
					let _sum_fac_car = _sum_fac_car + v_prima_tipo;
				else
		   	       	let v_prima_ot = v_prima_ot + v_prima_tipo;
				end if			   
			end if
		end if
		let v_prima_tipo = 0;

	end foreach

	select parinfra.rango1, 
	       parinfra.rango2
	  into v_rango_inicial,
    	   v_rango_final
	  from parinfra
	 where parinfra.cod_ramo = v_cod_ramo
       and parinfra.rango1 <= v_suma_asegurada	   -- prima   -- se quito el argumento de prima cobrada, solicitud inicial.
	   and parinfra.rango2 >= v_suma_asegurada;

    if v_rango_inicial is null then
	      let v_rango_inicial = 0;	
	   select rango2
		 into v_rango_final
		 from parinfra
		where cod_ramo = v_cod_ramo
		  and parinfra.rango1 = v_rango_inicial;
	end if;

	foreach
		select cod_sub_tipo, porcentaje
		  into v_cod_tipo, v_porcentaje
		  from tmp_ramos
		 where cod_ramo = v_cod_ramo					

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		if v_cod_tipo[1,2] = "in" then
			let v_desc_ramo = trim(v_desc_ramo)||"-incendio";
		elif v_cod_tipo[1,2] = "te" then
			let v_desc_ramo = trim(v_desc_ramo)||"-terremoto";
		end if

		begin
			on exception in(-239)
		    	update tmp_tabla
				   set cant_polizas   = cant_polizas   + 1,
			 		   p_cobrada      = p_cobrada      + v_prima * v_porcentaje/100,   		
					   p_retenida     = p_retenida     + v_prima_1 * v_porcentaje/100,	
					   p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
					   p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
					   p_otros		  = p_otros        + v_prima_ot * v_porcentaje/100,
					   p_fac_car	  = p_fac_car      + _sum_fac_car * v_porcentaje/100
				 where no_documento	  = _no_documento
				   and cod_ramo       = v_cod_tipo
				   and rango_inicial  = v_rango_inicial
				   and rango_final    = v_rango_final;  
			end exception

			insert into tmp_tabla(
								  no_documento,
								  cod_ramo,
								  desc_ramo,
								  rango_inicial,
								  rango_final,
								  cant_polizas,
								  p_cobrada,
								  p_retenida,
								  p_bouquet,
								  p_facultativo,
								  p_otros,
								  p_fac_car
								 )
						   values(_no_documento,
						   		  v_cod_tipo, 
								  v_desc_ramo, 
								  v_rango_inicial, 
								  v_rango_final, 
								  1, 
								  v_prima * v_porcentaje/100, 
								  v_prima_1 * v_porcentaje/100, 
								  v_prima_bq * v_porcentaje/100, 
								  v_prima_3 * v_porcentaje/100, 
								  v_prima_ot * v_porcentaje/100,
								  _sum_fac_car * v_porcentaje/100 							  
								 );				 
		end
	end foreach
	let v_prima   = 0; 
end foreach

foreach
	select no_documento,
		   cod_ramo,		
		   desc_ramo,		
		   rango_inicial,
		   rango_final,  
		   cant_polizas, 
		   p_cobrada,    
		   p_retenida,   
		   p_bouquet,    
		   p_facultativo,
		   p_otros,
		   p_fac_car	
	  into _no_documento,
	  	   v_cod_ramo, 
		   v_desc_ramo, 
		   v_rango_inicial,
		   v_rango_final, 
		   _cantidad, 
		   v_prima, 
		   v_prima_1, 
		   v_prima_bq, 
		   v_prima_3, 
		   v_prima_ot,
		   _sum_fac_car 
	  from tmp_tabla 
	 order by cod_ramo,rango_inicial

     return _no_documento,
     		v_cod_ramo,  
			v_desc_ramo,  
			v_rango_inicial, 
			v_rango_final,  
     		_cantidad,  
     		v_prima,  
     		v_prima_1,  
     		v_prima_bq,  
     		v_prima_3,  
     		v_prima_ot, 
     		v_filtros, 
     		v_descr_cia,
     		_sum_fac_car 	          
       with resume;
end foreach
drop table temp_produccion;
drop table temp_det;
{drop table temp_det1;
drop table tmp_priret;}
drop table tmp_tabla;
drop table tmp_ramos;
drop table temp_fact;
end

end procedure

