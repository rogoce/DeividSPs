--execute procedure sp_pr850_t('001','001','2025-01','2025-01','*','*','*','*','002,020,023;','*','*')

drop procedure sp_pr850_t;
create procedure sp_pr850_t(a_compania char(03),a_agencia char(03),a_periodo1 char(07),a_periodo2 char(07),a_codsucursal char(255)	default '*',a_codgrupo char(255) default '*',
                            a_codagente	char(255) default '*',a_codusuario char(255) default '*',a_codramo	char(255) default '*',a_reaseguro char(255)	default '*',a_serie char(255) default '*')
returning	char(3),char(3),char(5),char(3),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),char(50),char(50),char(50),char(255),varchar(100);
begin

define _error_desc			varchar(255);
define v_filtros2			char(255);
define v_filtros1			char(255);
define v_filtros			char(255);
define v_desc_cobertura		char(100);
define v_desc_contrato		char(50);
define _nom_contrato		varchar(100);
define _nombre_coas			char(100);
define _nombre_cob			char(50);
define _nombre_con			char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define _cuenta				char(25);
define _no_reclamo			char(10);
define v_nopoliza			char(10);
define _anio_reas			char(9);
define v_cod_contrato		char(5);
define _cod_traspaso		char(5);
define _no_unidad			char(5);
define v_noendoso			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define _xnivel				char(3);
define v_clase				char(3);
define _borderaux			char(2);
define _tipo				char(1);
define _porc_cont_partic	dec(5,2);
define _porc_cont_terr		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_cont_inc		dec(5,2);
define _p_c_partic			dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_impuesto4		dec(7,4);
define _porc_comision4		dec(7,4);
define _porc_comisiond		dec(7,4);
define _porc_partic_prima	dec(9,6);
define _prima_tot_ret_sum	dec(16,2);
define _prima_tot_sus_sum	dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_cobrada		dec(16,2);
define _tot_prima_neta		dec(16,2);
define _prima_tot_ret		dec(16,2);
define _prima_sus_tot		dec(16,2);
define _porc_impuesto		dec(16,2);
define _porc_comision		dec(16,2);
define _p_sus_tot_sum		dec(16,2);
define _tot_comision		dec(16,2);
define _tot_impuesto		dec(16,2);
define _pagado_neto			dec(16,2);
define _por_pagar70			dec(16,2);
define _por_pagar30			dec(16,2);
define _siniestro70			dec(16,2);
define _siniestro30			dec(16,2);
define _por_pagar10			dec(16,2);
define _siniestro3			dec(16,2);
define _comision10			dec(16,2);
define _impuesto10			dec(16,2);
define _siniestro2			dec(16,2);
define _siniestro4			dec(16,2);
define _comision70			dec(16,2);
define _comision30			dec(16,2);
define _impuesto70			dec(16,2);
define _impuesto30			dec(16,2);
define _monto_reas			dec(16,2);
define _por_pagar			dec(16,2);
define _siniestro			dec(16,2);
define _p_sus_tot			dec(16,2);
define _porc_terr			dec(16,2);
define _porc_inun			dec(16,2);
define _porc_inc			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_prima70			dec(16,2);
define v_prima30			dec(16,2);
define v_prima10			dec(16,2);
define _sini_dif			dec(16,2);
define _sini_inc			dec(16,2);
define _sini_mul			dec(16,2);
define _sini_bk				dec(16,2);
define v_prima1				dec(16,2);
define v_prima2				dec(16,2);
define v_prima				dec(16,2);
define _valor				dec(16,2);
define v_prima_casco		dec(16,2);
define _tiene_comis_rea		smallint;
define v_tipo_contrato		smallint;
define _tiene_comision		smallint;
define _p_c_partic_hay		smallint;
define _contrato_xl			smallint;
define _trim_reas			smallint;
define _tipo_cont			smallint;			
define _no_cambio			smallint;
define _cantidad			smallint;
define _error				smallint;
define _traspaso			smallint;
define v_existe				smallint;
define _bouquet				smallint;
define _serie1				smallint;
define _nivel				smallint;
define _tipo2				smallint;
define _serie				smallint;
define nivel				smallint;
define _flag				smallint;
define _ano2				smallint;
define _cnt3				smallint;
define _cnt2				smallint;
define _cnt					smallint;
define _ano					smallint;
define _dt_vig_inic			date;
define _fecha				date;
define _vig_inic            date;

set isolation to dirty read;

let _borderaux = '01';	    -- bouquet -- prima suscrita
let _nom_contrato = '';
select tipo 
  into _tipo2
  from reacontr
 where cod_contrato = _borderaux;
 
call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas; 

delete from reacoprs where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- elimina borderaux del trimestre
delete from temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- elimina borderaux datos;

let _ano =  a_periodo1[1,4];
let v_descr_cia  = sp_sis01(a_compania);

call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,	--Crea temp_det
			   a_codagente,a_codusuario,a_codramo,a_reaseguro) returning v_filtros;

let v_filtros2 = sp_rec708(
 a_compania,
 a_agencia,
 a_periodo1,
 a_periodo2,
 a_codsucursal,
 '*', 
 a_codramo, --'*'
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
primary key(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob, serie)) with no log;

create index idx11_temp_produccion on temp_produccion(cod_ramo);
create index idx22_temp_produccion on temp_produccion(cod_subramo);
create index idx33_temp_produccion on temp_produccion(cod_origen);
create index idx44_temp_produccion on temp_produccion(cod_contrato);
create index idx55_temp_produccion on temp_produccion(cod_cobertura);
create index idx66_temp_produccion on temp_produccion(desc_cob);
create index idx77_temp_produccion on temp_produccion(cod_coasegur);
create index idx88_temp_produccion on temp_produccion(serie);

let v_prima        = 0;
let v_descr_cia    = sp_sis01(a_compania);
let _tipo_cont     = 0;
let v_desc_cobertura = '';
let _porc_comis_ase = 0.00;

--set debug file to 'sp_pr850.trc';

foreach with hold
	select z.no_poliza,																	 
		   z.no_endoso																		 
	  into v_nopoliza,
		   v_noendoso
	  from temp_det z
	 where z.seleccionado = 1
	 group by 1, 2

	select cod_ramo,
		   cod_subramo,
		   cod_origen,
		   vigencia_inic
	  into v_cod_ramo,
		   _cod_subramo,
		   _cod_origen,
		   _vig_inic
	  from emipomae
	 where no_poliza = v_nopoliza;

	{if _vig_inic < '01/07/2014' then   --Esto era para lo de la simulacion
	  continue foreach;
	end if}

	drop table if exists tmp_reas;
	call sp_sis122(v_nopoliza, v_noendoso) returning _error,_error_desc;
	
	foreach
		select cod_cober_reas,
    		   cod_contrato,
	    	   prima_rea,
			   no_unidad,
			   porc_partic_prima
          into v_cobertura,
      	   	   v_cod_contrato,
      	   	   v_prima1,
			   _no_unidad,
			   _porc_partic_prima
          from tmp_reas
         where prima_rea <> 0

		{select cod_cober_reas,
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
           and prima <> 0}

		{select count(*)
		  into _cnt
		  from rearucon r, rearumae e
		 where r.cod_ruta = e.cod_ruta
		   and r.cod_contrato = v_cod_contrato
		   and e.activo = 1;

		 if _cnt > 0 then
		 else
			continue foreach;
		 end if	}
		--***ESTO ES NUEVO ARMANDO, SACADO DEL PROCEDURE SP_PR1008A
		let _porc_partic_coas = 100;

		let v_prima2 = 0.00;
		let v_prima_casco = 0.00;

		if v_cobertura in ('002','033') then
			select sum(c.prima_neta) * (_porc_partic_coas/100) 
			  into v_prima2
			  from endedcob c, prdcober p
			 where c.cod_cobertura = p.cod_cobertura
			   and no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			   and no_unidad = _no_unidad
			   and p.cod_cober_reas = v_cobertura
			   and p.causa_siniestro not in (1,7,8);

			if v_prima2 is null then
				let v_prima2 = 0.00;
			end if

			let v_prima2 = v_prima2 * (_porc_partic_prima/100);
			
		end if

		let v_prima1 = v_prima1 - v_prima2 - v_prima_casco;
		--***

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

		let _tipo_cont = 0;			  --otros contratos

        if v_tipo_contrato = 3 then   --facultativos
			let _tipo_cont = 2;
        elif v_tipo_contrato = 1 then --retencion
			let _tipo_cont = 1;
        end if

        let v_prima = v_prima1;
		let _cod_subramo = '001';

        select nombre
          into v_desc_contrato
          from reacomae
         where cod_contrato = v_cod_contrato;

		let v_desc_contrato = trim(v_desc_contrato) || ' (' || v_cod_contrato || ')' || '  A: ' || _serie;

		select porc_impuesto,
		       porc_comision,
			   tiene_comision
		  into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		let _cuenta = sp_sis15('PPRXP', '05', _cod_origen, v_cod_ramo, _cod_subramo);

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
				let v_desc_contrato  = '******* NO EXISTE REGISTRO DE COMPANIAS ' || v_cod_contrato;

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
							_tiene_comis_rea
							,'');	 
			 	end if
			else
				let _porc_comis_ase = 0.00;
				
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

                    if _porc_comis_ase is null then
						let _porc_comis_ase = 0;
					end if
		 				
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

		 			let v_desc_cobertura = '';
		 			let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
		 			let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comision;

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
		               and serie		 = _serie;

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
						update temp_produccion
						   set prima       = prima + _monto_reas,
							   comision    = comision  + _comision,
							   impuesto    = impuesto  + _impuesto,
							   por_pagar   = por_pagar + _por_pagar
						 where cod_ramo      = v_cod_ramo
						   and cod_subramo    = _cod_subramo
						   and cod_origen     = _cod_origen
						   and cod_contrato  = v_cod_contrato
						   and cod_cobertura = v_cobertura
						   and desc_cob      = v_desc_cobertura
						   and serie         = _serie;
		 			end if
		 			--let v_prima1 = 0;
		 		end foreach
			end if
		elif _tipo_cont = 1 then	  --Retencion
			let _cod_coasegur = '036'; --ancon
			let _porc_comis_ase = 0.00;

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
			let v_desc_cobertura = '';
			let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
			let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comision;
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
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie;

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
				   and cod_subramo	 = _cod_subramo
				   and cod_origen	 = _cod_origen
				   and cod_contrato	 = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob		 = v_desc_cobertura
				   and serie         = _serie;
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
				let v_desc_contrato  = '******* NO EXISTE REGISTRO DE COMPANIAS ' || v_cod_contrato;

			 	select count(*)
			 	  into _cantidad
			 	  from temp_produccion
			 	 where cod_ramo          = v_cod_ramo
			 	   and cod_subramo       = _cod_subramo
			 	   and cod_origen        = _cod_origen
				   and cod_contrato  = v_cod_contrato
				   and cod_cobertura = v_cobertura
				   and desc_cob      = _nombre_cob	
				   and serie = _serie ;
--				       and no_unidad     = _no_unidad ;

			   	if _cantidad = 0 then
			 		insert into temp_produccion
					values( v_cod_ramo,
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

                    if _porc_comis_ase is null then
						let _porc_comis_ase = 0;
					end if
			 			
			 		select nombre
			 		  into _nombre_coas
			 		  from emicoase
			 		 where cod_coasegur = _cod_coasegur;

			 		let v_desc_cobertura = trim(_nombre_cob) || '  ' || trim(_cuenta) || '  ' || trim(_nombre_coas);
			 		let v_desc_contrato  = trim(v_desc_contrato) || '  I:' || _porc_impuesto || '  C:' || _porc_comis_ase;
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
			           and serie  = _serie ;

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
						   and desc_cob      = v_desc_cobertura
						   and serie = _serie;
			 		end if
				end foreach
			end if
		end if
	end foreach
end foreach

-- trace on;
-- Carga Temporal contrato por ramos.
let _ano2 =  a_periodo2[1,4];
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
	       _serie				
	  from temp_produccion
	 where seleccionado = 1

	let  _p_c_partic = 0;
	let  _p_c_partic_hay = 0;

	select traspaso,
		   tiene_comision,
		   bouquet
	  into _traspaso,
		   _tiene_comision,
		   _bouquet
	  from reacocob
	 where cod_contrato   = v_cod_contrato
	   and cod_cober_reas = v_cobertura;

	select tipo_contrato, serie
	  into v_tipo_contrato,_serie
	  from reacomae
	 where cod_contrato = v_cod_contrato;

	--let _serie = _serie1;

	if _bouquet <> 1 then
		continue foreach;
	end if

	let nivel = 1;

	if _porc_cont_partic = 100 then
		let nivel = 2;
	else
		let nivel = 1;
	end if

	if v_tipo_contrato = 1 then 
		continue foreach;
	end if

	insert into temphg1
	values (_cod_coasegur,
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
			 nivel,
			 _anio_reas,
			 _trim_reas,
			 _borderaux);
end foreach

-- trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,013,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]
--    Where serie > 2007 and cod_coasegur in ('050','063','076','042') 	 -- ('050','063','076','042','036','089')

let _siniestro = 0;

foreach
	select serie,cod_ramo,cod_contrato,cod_cobertura,sum(prima) 
	  into _serie,v_cod_ramo,v_cod_contrato,v_cobertura,v_prima2 
	  from temphg1
	 where cod_coasegur in ('036','042','050','063','076','089','128','117','134','136','141','146','147','149','153','034','164') --SD#6343 add 164 27/04/2023-HGIRON --agregué el 153 porque es nuevo APM 12-01-2022   ---SD#4159 CECHAVAR adicion 034-ALLIED 03/08/2022
	   and anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by serie,cod_ramo,cod_contrato,cod_cobertura

	foreach 
		select distinct cod_coasegur,porc_cont_partic,porc_comision,porc_impuesto
		  into  _cod_coasegur,_porc_cont_partic,_porc_comision,_porc_impuesto
		  from temphg1
		 where serie          = _serie
		   and cod_coasegur   in ('050','063','076','042','036','089','128','117','134','136','141','146','147','149','153','034','164') --SD#6343 add 164 27/04/2023-HGIRON --agregué el 153 porque es nuevo APM 12-01-2022   ---SD#4159 CECHAVAR adicion 034-ALLIED 03/08/2022
		   and cod_ramo       = v_cod_ramo  
		   and cod_contrato   = v_cod_contrato
		   and cod_cobertura  = v_cobertura
		   and anio           = _anio_reas
		   and trimestre      = _trim_reas
		   and borderaux      = _borderaux 

		if _siniestro is null then
			let _siniestro = 0;
		end if

		if v_cod_ramo = '006' then 
			let v_clase = '001';
		elif v_cod_ramo in ('001','003') then 
			let v_clase = '002';
		elif v_cod_ramo in ('010','011','012','013','014','021','022') then 
			let v_clase = '004';
		elif v_cod_ramo in ('008','080') then 
			let v_clase = '005';
		elif v_cod_ramo = '004' then 
			let v_clase = '006';
		elif v_cod_ramo = '019' then 
			let v_clase = '007' ;
		elif v_cod_ramo in ('002','023','020') then
			let v_clase = '013';
		elif v_cod_ramo = '016' then
			let v_clase = '012';
		end if

		let v_prima = v_prima2;
		
		--contrato XL
		select contrato_xl
		  into _contrato_xl
		  from reacoase
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura
		   and cod_coasegur   = _cod_coasegur;

		if _contrato_xl = 1 then
		
			if _cod_coasegur in ('036') and v_cod_contrato in ('00705','00706') then
			else
				let _porc_cont_partic = 0;
			end if
			
			if _cod_coasegur in ('117','136') then
				let v_prima = 0.00;
			end if
		end if
		
		{if _borderaux = '01' and _cod_coasegur = '117' and _serie = 2015 then
			let v_prima = 0.00;
		end if}

		if _porc_comision is null or _porc_comision = 0 then
			let _porc_comision4 = 0;
		else
			let _porc_comision4 = _porc_comision/100;
		end if

		if _porc_impuesto is null or _porc_impuesto = 0 then
			let _porc_impuesto4 = 0;
		else
			let _porc_impuesto4 = _porc_impuesto/100;
		end if

		let _comision  = v_prima * _porc_comision4;
		let _impuesto  = v_prima * _porc_impuesto4;	
		let _por_pagar = v_prima - _comision - _impuesto;

		if _porc_cont_partic < 100 then 
			let _xnivel = '1';
		else
			let _xnivel = '2';
		end if

		--let _porc_terr = 0.30;
		let _porc_inun = 0.00;
		
		if v_clase = '002' then
			let _comision70 = 0;
			let _comision30 = 0;
			let _comision10 = 0;
			let v_prima10   = 0;

			if v_cobertura in ('001','003') then
				let v_prima70 = v_prima;
				let v_prima30 = 0.00;
				let _porc_terr = 0.00;
				let _porc_inc = 1;
			else
				let v_prima70 = 0.00;
				let _porc_inc = 0.00;
				let _porc_terr = 1.00;
				let v_prima30 = v_prima;
				
				if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
					let _porc_terr = 0.66666666666666666666666666666667;
					let _porc_inun = 0.33333333333333333333333333333333;
				end if
				
				let v_prima30 =	v_prima * _porc_terr;
				let v_prima10 = v_prima * _porc_inun;
			end if
			--let v_prima70 = v_prima * 0.70;

			let _impuesto70  = _impuesto * _porc_inc;
			let _impuesto30  = _impuesto * _porc_terr;
			let _impuesto10  = _impuesto * _porc_inun;
			let _por_pagar70 = _por_pagar * _porc_inc;
			let _por_pagar30 = _por_pagar * _porc_terr;
			let _por_pagar10 = _por_pagar * _porc_inun;
			let _siniestro70 = _siniestro * 1;
			let _siniestro30 = _siniestro * 0;	 
			let _comision70  = v_prima70 * _porc_comision4 * 1;
			let _comision30  = v_prima30 * _porc_comision4 * 1;
			let _comision10  = v_prima10 * _porc_comision4 * 1;

			if v_cobertura = '021' or v_cobertura = '022' then
				foreach
					select distinct porc_comision
					  into _porc_comision4
					  from reacoase
					 where cod_contrato   = v_cod_contrato
					   and cod_cober_reas in ('001','003')
					   and cod_coasegur   = _cod_coasegur
					exit foreach;
				end foreach

				let _comision70 = v_prima70 * (_porc_comision4/100) * 1 ;
			end if 	  

			if 	_cod_coasegur = '042' then
				let _comision70 = v_prima70 * 0.48 ;
				if 	v_cod_contrato in ('00602') then
					let _comision70 = v_prima70 * 0.40 ;
				end if
			elif _cod_coasegur = '076' then
				let _comision70 = v_prima70 * 0.48 ;
			elif _cod_coasegur = '063' then
				--let _comision70 = v_prima70 * 0.42 ;
			elif _cod_coasegur = '050' then
				let _comision70 = v_prima70 * 0.43 ;
			end if
            --    comentariado a partir del 16oct2018 
			{if 	_cod_coasegur = '063' then
				let _comision30 = v_prima30 * 0.225;
			else
				let _comision30 = v_prima30 * 0.20;
				let _comision10 = v_prima10 * 0.20;
			end if}

			let _por_pagar70 = v_prima70 - _comision70 - _impuesto70 ;
			let _por_pagar30 = v_prima30 - _comision30 - _impuesto30 ;
			let _por_pagar10 = v_prima10 - _comision10 - _impuesto10;

			let _porc_cont_inc = 0;

			foreach
				select distinct porc_cont_partic
				  into _porc_cont_inc
				  from reacoase
				 where ( cod_contrato  = v_cod_contrato )
				   and ( cod_cober_reas in('001','003'))
				   and ( cod_coasegur  = _cod_coasegur)
				 order by 1 desc
				exit foreach;
			end foreach

			if _porc_cont_inc is null or _porc_cont_inc = 0 then
			else
				begin
				on exception in(-239)
					update reacoprs
					   set prima         = prima + v_prima70, 
						   comision      = comision + _comision70, 
						   impuesto      = impuesto + _impuesto70, 
						   prima_neta    = prima_neta + _por_pagar70, 
						   siniestro     = siniestro + _siniestro70 
					 where cod_coasegur	 = _cod_coasegur
					   and cod_contrato  = _serie
					   and cod_cobertura = _xnivel
					   and p_partic      = _porc_cont_inc--_porc_cont_partic,
					   and cod_ramo      = v_cod_ramo 
					   and cod_clase     = '002'
					   and anio          = _anio_reas
					   and trimestre     = _trim_reas
					   and borderaux     = _borderaux;
				end exception 	

				insert into reacoprs
				values (_cod_coasegur,
						v_cod_ramo,
						_serie,
						_xnivel,
						v_prima70, 
						_comision70, 
						_impuesto70, 
						_por_pagar70,
						_siniestro70,
						0,
						0,
						_porc_cont_inc,--_porc_cont_partic,
						'002',
						_anio_reas,
						_trim_reas,
						_borderaux);
				end
			end if

			let _porc_cont_terr = 0;

			foreach
				select distinct porc_cont_partic
				  into _porc_cont_terr
				  from reacoase
				 where cod_contrato = v_cod_contrato
				   and cod_cober_reas in('021','022')
				   and cod_coasegur = _cod_coasegur
				 order by 1 desc
				exit foreach;
			end foreach

			if _porc_cont_terr is null or _porc_cont_terr = 0 then
			else
				begin
				on exception in(-239)
					update reacoprs
					   set prima = prima + v_prima30, 
						   comision = comision + _comision30, 
						   impuesto = impuesto + _impuesto30, 
						   prima_neta = prima_neta + _por_pagar30, 
						   siniestro = siniestro + _siniestro30 
					 where cod_coasegur	= _cod_coasegur
					   and cod_contrato = _serie
					   and cod_cobertura  = _xnivel
					   and p_partic = _porc_cont_terr  --_porc_cont_partic
					   and cod_ramo = v_cod_ramo 
					   and cod_clase = '003' 
					   and anio      = _anio_reas
					   and trimestre = _trim_reas
					   and borderaux = _borderaux;
				end exception 	

				insert into reacoprs
				values (_cod_coasegur,
						v_cod_ramo,
						_serie,
						_xnivel,
						v_prima30, 
						_comision30, 
						_impuesto30, 
						_por_pagar30,
						_siniestro30,
						0,
						0,
						_porc_cont_terr,  --_porc_cont_partic,
						'003',
						_anio_reas,
						_trim_reas,
						_borderaux);
				end
				
				if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
					begin
					on exception in(-239)
						update reacoprs
						   set prima         = prima      + v_prima10, 
							   comision      = comision   + _comision10, 
							   impuesto      = impuesto   + _impuesto10, 
							   prima_neta    = prima_neta + _por_pagar10, 
							   siniestro     = siniestro  + _siniestro30 
						 where cod_coasegur	 = _cod_coasegur
						   and cod_contrato  = _serie
						   and cod_cobertura = _xnivel
						   and p_partic      = _porc_cont_terr --_porc_cont_partic
						   and cod_ramo      = v_cod_ramo 
						   and cod_clase     = '011' 
						   and anio          = _anio_reas
						   and trimestre     = _trim_reas
						   and borderaux     = _borderaux;
					end exception 	

					insert into reacoprs
					values (_cod_coasegur,
							v_cod_ramo,
							_serie,
							_xnivel,
							v_prima10, 
							_comision10, 
							_impuesto10, 
							_por_pagar10,
							_siniestro30,
							0,
							0,
							_porc_cont_terr, --_porc_cont_partic,
							'011',
							_anio_reas,
							_trim_reas,
							_borderaux);
					end
				end if				
			end if
		else
			begin
			on exception in(-239)
				update reacoprs
				   set prima = prima + v_prima, 
					   comision = comision + _comision, 
					   impuesto = impuesto + _impuesto, 
					   prima_neta = prima_neta + _por_pagar, 
					   siniestro = siniestro + _siniestro 
				 where cod_coasegur	= _cod_coasegur
				   and cod_contrato = _serie
				   and cod_cobertura = _xnivel
				   and p_partic  = _porc_cont_partic
				   and cod_ramo  =  v_cod_ramo
				   and cod_clase = v_clase 
				   and anio      = _anio_reas
				   and trimestre = _trim_reas
				   and borderaux = _borderaux;

			end exception 	

			insert into reacoprs
			values (_cod_coasegur,
					v_cod_ramo,
					_serie,
					_xnivel,
					v_prima, 
					_comision, 
					_impuesto, 
					_por_pagar,
					_siniestro,
					0,
					0,
					_porc_cont_partic,
					v_clase,
					_anio_reas,
					_trim_reas,
					_borderaux);
			end
		end if
	end foreach
end foreach		

--evento inundacion para tomar la participacion de la swiss re

let _cnt2       = 0;
let _siniestro3 = 0;
let _siniestro4 = 0;
let _sini_inc   = 0;
let _sini_mul   = 0;

foreach
	select t.no_reclamo,t.pagado_neto,t.cod_ramo
	  into _no_reclamo,_pagado_neto,_cod_ramo
	  from tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie >= 2012
	   and t.cod_ramo in('001','003')

	{select count(*)
	  into _cnt3
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in('00010','00013','00036','00057','00058',
	                        '00059','00068','00089','00097','00125',
	                        '00160','00179','00182','00725','00726',
	                        '00732','00742','00743','00748','00754',
	                        '00781','00785','00790','00793','00855',
	                        '00878','00024');}
	select count(*)
	  into _cnt3 
	  from recrccob r, prdcober p
	 where r.cod_cobertura = p.cod_cobertura
   	   and r.no_reclamo    = _no_reclamo
	   and p.relac_inundacion = 1;


	if _cod_ramo = '001' then
	   let _sini_inc = _sini_inc + _pagado_neto;
	else
	   let _sini_mul = _sini_mul + _pagado_neto;
	end if

	if _cnt3 > 0 then
		let _cnt2 = 1;
		if _cod_ramo = '001' then
			let _siniestro3 = _siniestro3 + _pagado_neto;
		else
			let _siniestro4 = _siniestro4 + _pagado_neto;
		end if
	end if
end foreach

if _siniestro3 > 0 then
	let _siniestro3	= abs(_sini_inc - _siniestro3);
end if
if _siniestro4 > 0 then
	let _siniestro4	= abs(_sini_mul - _siniestro4);
end if

let _siniestro2 = 0;
let _sini_bk    = 0;
let _cnt3       = 0;
let _pagado_neto = 0;

--evento inundacion para tomar la participacion de la swiss re en terremoto
foreach
	select t.no_reclamo, t.pagado_neto
	  into _no_reclamo,_pagado_neto
	  from tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie = 2011
	   and t.cod_ramo in('001','003')

	{select count(*)
	  into _cnt3
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in('00010','00013','00036','00057','00058',
	                        '00059','00068','00089','00097','00125',
	                        '00160','00179','00182','00725','00726',
	                        '00732','00742','00743','00748','00754',
	                        '00781','00785','00790','00793','00855',
	                        '00878','00024');}

	select count(*)
	  into _cnt3 
	  from recrccob r, prdcober p
	 where r.cod_cobertura = p.cod_cobertura
   	   and r.no_reclamo    = _no_reclamo
	   and p.relac_inundacion = 1;

	if _cnt3 > 0 then
		let _siniestro2 = _siniestro2 + _pagado_neto;
	end if
end foreach

--set debug file to 'sp_pr850.trc';
--trace on;

foreach
	select r.serie,t.cod_ramo,t.cod_contrato,sum(t.pagado_neto) 
	  into _serie,v_cod_ramo,v_cod_contrato,_siniestro 
	  from tmp_sinis t, reacomae r 
	 where r.cod_contrato = t.cod_contrato 
	   and t.seleccionado = 1 
	   and t.tipo_contrato not in ('3','1') 
	   and r.serie >= 2008 
	   and t.cod_ramo in ('021','022','001','003','006','010','011','012','013','014','008','080','004','019','016','002','023','020')
	 group by r.serie,t.cod_ramo,t.cod_contrato
	 order by r.serie,t.cod_ramo,t.cod_contrato

	select count(*)
	  into _cnt
	  from temphg1 
	 where cod_ramo     = v_cod_ramo
	   and cod_contrato = v_cod_contrato
	   and serie        = _serie;

	if _cnt > 0 then
		foreach
			select distinct cod_cobertura
			  into v_cobertura
			  from temphg1 
			 where cod_ramo     = v_cod_ramo
			   and cod_contrato = v_cod_contrato
			   and serie        = _serie
		  exit foreach;
		end foreach
	else
		foreach
			select distinct cod_cober_reas
			  into v_cobertura
			  from reacobre
			 where cod_ramo = v_cod_ramo
			exit foreach;
	   end foreach
	end if
	
	let _sini_bk = _siniestro;
	foreach
		select distinct cod_cober_reas,
			   cod_coasegur,
			   porc_cont_partic
		  into v_cobertura,
			   _cod_coasegur,
			   _porc_cont_partic
		  from reacoase -- reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura

		let _siniestro = _sini_bk;
		
		if v_cod_ramo in ('006') then 
			let v_clase = '001';
		elif v_cod_ramo in ('001','003') then 
			let v_clase = '002';
		elif v_cod_ramo in ('010','012','011','013','014','021','022') then 
			let v_clase = '004';
		elif v_cod_ramo in ('008','080') then 
			let v_clase = '005';
		elif v_cod_ramo in ('004') then 
			let v_clase = '006';
		elif v_cod_ramo in ('019') then
			let v_clase = '007';
		elif v_cod_ramo in ('016') then
			let v_clase = '012';
		elif v_cod_ramo in ('002','023','020') then
			let v_clase = '013';
		end if
		
		if _borderaux = '01' and _cod_coasegur in ('117','136') and _serie >= 2015 then
			let _siniestro = 0;
		end if

		if _borderaux = '01' and _cod_coasegur = '042' and _serie >= 2012 then
			if ((v_cod_ramo = '001' or v_cod_ramo = '003') and _cnt2 > 0) then 
				let v_clase = '011';
				
				if v_cod_ramo = '001' then
					if _siniestro3 = 0 then
						let _siniestro = 0;
					end if
					let _siniestro = abs(_siniestro - _siniestro3);
				else
					if _siniestro4 = 0 then
						let _siniestro = 0;
					end if
					let _siniestro = abs(_siniestro - _siniestro4);
				end if
			end if					
		end if
		
		if _porc_cont_partic < 100 then 
		   let _xnivel = '1';
		else
		   let _xnivel = '2';
		end if		

		if _borderaux = '01' and _cod_coasegur = '042' and _serie = 2011 then
			if v_cod_ramo = '001' and _siniestro2 <> 0 then
				let _sini_dif = 0;
				let _sini_dif = _siniestro - _siniestro2;
				let _sini_dif = abs(_sini_dif);

				update reacoprs 
				   set siniestro     = siniestro + _sini_dif 
				 where cod_coasegur	 = _cod_coasegur 
				   and cod_contrato  = _serie 
				   and cod_cobertura = _xnivel 
				   and p_partic      = _porc_cont_partic 
				   and cod_ramo      = v_cod_ramo 
				   and cod_clase     = v_clase 
				   and anio          = _anio_reas 
				   and trimestre     = _trim_reas 
				   and borderaux     = _borderaux; 

				let v_clase     = '003';
				let v_cobertura = '021';

				select porc_cont_partic
				  into _porc_cont_partic
				  from reacoase
				 where cod_contrato   = v_cod_contrato
				   and cod_cober_reas = v_cobertura
				   and cod_coasegur   = _cod_coasegur;

				let _siniestro = _siniestro2;
			end if
		end if
		
		begin
		on exception in(-239) 
			update reacoprs 
			   set siniestro = siniestro + _siniestro 
			 where cod_coasegur	= _cod_coasegur 
			   and cod_contrato = _serie 
			   and cod_cobertura  = _xnivel 
			   and p_partic = _porc_cont_partic 
			   and cod_ramo =  v_cod_ramo 
			   and cod_clase = v_clase 
			   and anio      = _anio_reas 
			   and trimestre = _trim_reas 
			   and borderaux = _borderaux; 

		end exception 	

		insert into reacoprs
		values (_cod_coasegur,
				v_cod_ramo,
				_serie,
				_xnivel,
				0, 
				0, 
				0, 
				0,
				_siniestro,
				0,
				0,
				_porc_cont_partic,
				v_clase,
				_anio_reas,
				_trim_reas,
				_borderaux);

		end
	end foreach	
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
	  from reacoprs	
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux in(_borderaux)
	   and cod_contrato < 2010
	   and cod_clase in('001','002','003') --solo para incendio, resp. civil y terremoto
	 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic,cod_ramo
	 order by cod_coasegur,cod_clase,cod_contrato


	insert into reacoprs
	values (_cod_coasegur,
			_cod_ramo,
			2010,
			v_cobertura,
			v_prima, 
			_comision, 
			_impuesto,
			_por_pagar,
			_siniestro,
			0,
			0,
			_porc_cont_partic,
			v_cod_ramo,
			_anio_reas,
			_trim_reas,
			_borderaux);

	update reacoprs
	   set prima         = 0,
		   comision      = 0,
		   impuesto      = 0,
		   prima_neta    = 0,
		   siniestro     = 0
	 where cod_coasegur	 = _cod_coasegur
	   and cod_contrato  = v_cod_contrato
	   and cod_cobertura = v_cobertura
	   and cod_clase     = v_cod_ramo
	   and cod_ramo      = _cod_ramo
	   and anio          = _anio_reas
	   and trimestre     = _trim_reas
	   and borderaux     = _borderaux;
--		   and prima         <> 0;

   {	else

		UPDATE reacoprs
		   SET prima         = prima      + v_prima, 
		       comision      = comision   + _comision, 
		       impuesto      = impuesto   + _impuesto, 
		       prima_neta    = prima_neta + _por_pagar 
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = 2010
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;

		UPDATE reacoprs
		   SET prima         = 0,
		       comision      = 0,
		       impuesto      = 0,
		       prima_neta    = 0
		 WHERE cod_coasegur	 = _cod_coasegur
		   AND cod_contrato  = v_cod_contrato
		   AND cod_cobertura = v_cobertura
		   AND cod_clase     = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux
		   and prima         <> 0;
  	end if}
end foreach
------------	 
update reacoprs
   set resultado = prima_neta - siniestro, 
       participar = (prima_neta - siniestro) * (p_partic/100) 
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;

--trace off;
-- Filtro por Serie
IF a_serie <> '*' THEN
	LET v_filtros = TRIM(v_filtros) ||' Serie '||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

END IF
if a_serie = '*' then

foreach
	select cod_coasegur,
		   cod_clase,
		   cod_contrato,
		   cod_cobertura,
		   p_partic,
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
		   v_prima,
		   _comision,
		   _impuesto,
		   _por_pagar,
		   _siniestro,
		   _prima_tot_ret,
		   _prima_sus_tot			
	  from reacoprs	
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = _borderaux 
	 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

	select rearamo.nombre
	  into v_desc_ramo
	  from rearamo  
	 where rearamo.ramo_reas = v_cod_ramo;

	if v_cod_ramo = '001' then
		let v_desc_ramo = 'R.C.G.' ;
		let _nom_contrato = 'CUOTA PARTE';
	elif v_cod_ramo = '002' then
		let v_desc_ramo = 'Incendio' ;
		let _nom_contrato = 'EXCEDENTE';
	elif v_cod_ramo = '003' then
		let v_desc_ramo = 'Terremoto' ;
		let _nom_contrato = 'EXCEDENTE';
	elif v_cod_ramo = '004' then
		let v_desc_ramo = 'Ramos Tecnicos' ;
		let _nom_contrato = 'EXCEDENTE';
	elif v_cod_ramo = '005' then
		let v_desc_ramo = 'Fianzas' ;
		let _nom_contrato = 'CUOTA PARTE';
	elif v_cod_ramo = '006' then
		let v_desc_ramo = 'Acc. Personales' ;
		let _nom_contrato = 'CUOTA PARTE';
	elif v_cod_ramo = '007' then
		let v_desc_ramo = 'Vida Indindividual';
		let _nom_contrato = 'CUOTA PARTE';
	elif v_cod_ramo = '011' then 
	   let v_desc_ramo = 'Inundación';
	   let _nom_contrato = 'EXCEDENTE';
	elif v_cod_ramo = '012' then
		let v_desc_ramo = 'Colectivo de Vida';
		let _nom_contrato = 'CUOTA PARTE';
	end if
	
	if v_cod_ramo = '013' then
	   LET v_desc_ramo = 'Automovil';
	   let _nom_contrato = 'CUOTA PARTE';
	end if	
		
	if _porc_cont_partic = 100 and v_cod_ramo not in ('006','007','008','012') then 
		let v_cobertura = '3';
	end if

	select nombre
	  into v_desc_contrato
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	let _valor = 0;
	let _valor = v_prima + _comision + _impuesto + _por_pagar + _siniestro;


	if _valor = 0 then
		continue foreach;
	end if

	if _cod_coasegur = '036' and _porc_cont_partic = 0 then
		continue foreach;
	end if

	return _cod_coasegur,	  --01
		   v_cod_ramo,		  --02
		   v_cod_contrato,	  --03
		   v_cobertura,	      --04
		   v_prima, 		  --05
		   _comision, 		  --06
		   _impuesto, 		  --07
		   _por_pagar,		  --08
		   _siniestro,		  --09
		   _prima_tot_ret,	  --10
		   _prima_sus_tot,	  --11
		   _porc_cont_partic, --12
		   v_desc_ramo,	      --13
		   v_desc_contrato,   --14
		   v_descr_cia,		  --15
		   v_filtros,          --16 filtros
		   _nom_contrato		  --15
		   with resume;
end foreach

else

  	if _tipo = 'E' then --Excluir serie
		foreach
			select cod_coasegur,
				   cod_clase,
				   cod_contrato,
				   cod_cobertura,
				   p_partic,
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
				   v_prima,
				   _comision,
				   _impuesto,
				   _por_pagar,
				   _siniestro,
				   _prima_tot_ret,
				   _prima_sus_tot			
			  from reacoprs	
			 where anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux = _borderaux
	  		   and cod_contrato not in (select codigo from tmp_codigos)  
			 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

			select rearamo.nombre
			  into v_desc_ramo
			  from rearamo  
			 where ramo_reas = v_cod_ramo;

			if v_cod_ramo = '001' then
				let v_desc_ramo = 'R.C.G.' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '002' then
				let v_desc_ramo = 'Incendio' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '003' then
				let v_desc_ramo = 'Terremoto' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '004' then
				let v_desc_ramo = 'Ramos Tecnicos' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '005' then
				let v_desc_ramo = 'Fianzas' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '006' then
				let v_desc_ramo = 'Acc. Personales' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '007' then
				let v_desc_ramo = 'Vida Indindividual';
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '011' then 
			   let v_desc_ramo = 'Inundación';
			   let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '012' then
				let v_desc_ramo = 'Colectivo de Vida';
				let _nom_contrato = 'CUOTA PARTE';
			end if
			
			if v_cod_ramo = '013' then
			   LET v_desc_ramo = 'Automovil';
			   let _nom_contrato = 'CUOTA PARTE';
			end if				
				
			if _porc_cont_partic = 100 and v_cod_ramo not in ('006','007','008','012') then 
				let v_cobertura = '3';
			end if

			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;
			
			let _valor = 0;
			let _valor = v_prima + _comision + _impuesto + _por_pagar + _siniestro;


			if _valor = 0 then
				continue foreach;
			end if

			--	if _cod_coasegur = '036' then
			if _cod_coasegur = '036' and _porc_cont_partic = 0 then
				continue foreach;
			end if

			return _cod_coasegur,	  --01
				   v_cod_ramo,		  --02
				   v_cod_contrato,	  --03
				   v_cobertura,	      --04
				   v_prima, 		  --05
				   _comision, 		  --06
				   _impuesto, 		  --07
				   _por_pagar,		  --08
				   _siniestro,		  --09
				   _prima_tot_ret,	  --10
				   _prima_sus_tot,	  --11
				   _porc_cont_partic, --12
				   v_desc_ramo,	      --13
				   v_desc_contrato,   --14
				   v_descr_cia,		  --15
				   v_filtros,          --16 filtros
				   _nom_contrato		  --15
				   with resume;
		  end foreach

	else
		foreach
			select cod_coasegur,
				   cod_clase,
				   cod_contrato,
				   cod_cobertura,
				   p_partic,
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
				   v_prima,
				   _comision,
				   _impuesto,
				   _por_pagar,
				   _siniestro,
				   _prima_tot_ret,
				   _prima_sus_tot			
			  from reacoprs	
			 where anio      = _anio_reas
			   and trimestre = _trim_reas
			   and borderaux = _borderaux
	  		   and cod_contrato in (select codigo from tmp_codigos)  
			 group by cod_coasegur,cod_clase,cod_contrato,cod_cobertura,p_partic

			select rearamo.nombre
			  into v_desc_ramo
			  from rearamo  
			 where rearamo.ramo_reas = v_cod_ramo;

			if v_cod_ramo = '001' then
				let v_desc_ramo = 'R.C.G.' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '002' then
				let v_desc_ramo = 'Incendio' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '003' then
				let v_desc_ramo = 'Terremoto' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '004' then
				let v_desc_ramo = 'Ramos Tecnicos' ;
				let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '005' then
				let v_desc_ramo = 'Fianzas' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '006' then
				let v_desc_ramo = 'Acc. Personales' ;
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '007' then
				let v_desc_ramo = 'Vida Indindividual';
				let _nom_contrato = 'CUOTA PARTE';
			elif v_cod_ramo = '011' then 
			   let v_desc_ramo = 'Inundación';
			   let _nom_contrato = 'EXCEDENTE';
			elif v_cod_ramo = '012' then
				let v_desc_ramo = 'Colectivo de Vida';
				let _nom_contrato = 'CUOTA PARTE';
			end if
			
			if v_cod_ramo = '013' then
			   LET v_desc_ramo = 'Automovil';
			   let _nom_contrato = 'CUOTA PARTE';
			end if				
				
			if _porc_cont_partic = 100 and v_cod_ramo not in ('006','007','008','012') then 
				let v_cobertura = '3';
			end if

			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			let _valor = 0;
			let _valor = v_prima + _comision + _impuesto + _por_pagar + _siniestro;


			if _valor = 0 then
				continue foreach;
			end if

			--if _cod_coasegur = '036' then
			if _cod_coasegur = '036' and _porc_cont_partic = 0 then
				continue foreach;
			end if

			return _cod_coasegur,	  --01
				   v_cod_ramo,		  --02
				   v_cod_contrato,	  --03
				   v_cobertura,	      --04
				   v_prima, 		  --05
				   _comision, 		  --06
				   _impuesto, 		  --07
				   _por_pagar,		  --08
				   _siniestro,		  --09
				   _prima_tot_ret,	  --10
				   _prima_sus_tot,	  --11
				   _porc_cont_partic, --12
				   v_desc_ramo,	      --13
				   v_desc_contrato,   --14
				   v_descr_cia,		  --15
				   v_filtros,          --16 filtros
				   _nom_contrato
				   with resume;
		end foreach
	end if
end if
drop table if exists temp_produccion;
drop table if exists temp_det;
drop table if exists tmp_sinis;
drop table if exists tmp_codigos;

end
end procedure 
                               
