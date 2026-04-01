-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud50a;		

create procedure "informix".sp_aud50a(a_periodo_desde char(7) , a_periodo_hasta char(7)) 
returning integer, varchar(100); 

define _fecha, _fecha_hoy			date;
define _transaccion		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _numrecla		char(20);
define _no_documento	char(20);
define _no_tranrec      char(10);

define _no_reclamo		char(10);
define _fecha_pagado    date;
define _no_unidad		char(5);
define _cod_asegurado	char(10);

define _user_added		  char(8);
define _vigencia_inic	  date;
define _vigencia_final	  date;
define _cod_evento        char(3);
define _causa             varchar(50);
define _fecha_siniestro	  date;
define _fecha_documento	  date;
define _pagado        	  smallint;
define _situacion         char(10);
define _cod_agente		  char(10);
define _no_poliza         char(10);

define _periodo           char(7);

define _ano                 integer;
define _mes                 smallint;
define _ramo				smallint;
define _tipo_sin            char(3);

define _cont_1            	integer;
define _cont_2            	integer;
define _cont_rea			smallint;
define _cont_rea_f			smallint;

define _tipo_contrato       smallint;
define _porc_partic_suma	dec(9,6);
define _orden				smallint;
define _tipo_cont_tt        char(1);
define _cod_coasegur        char(3);
define _porc_partic_reas	dec(9,6);
define _porc_proporcion     decimal(9,6);
define _porc_part_total 	decimal(9,6);
define _porc_partic_coas	decimal(9,6);
define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _serie			    smallint;
define _ramo_sis			smallint;
define _cod_ramo			char(3);
define _cod_area_seguro		smallint;
define _cod_cober_reas		char(3);
define _cod_sucursal		char(3);
define _cod_tipotran	  	char(3);
define _indcol              char(1);
define _cantidad            integer;
define _cod_grupo           char(5);
define _cod_subramo         char(3);
define _cod_cobertura       char(5);
define _error               integer;
define _cod_tipoprod        char(3);
define _cod_contrato        char(5);
define _cnt					integer;
define _contrato_xl			smallint;
define _mnto_concepto       decimal(18,6);
define _id_reas_caract      integer;
define _diferencia			dec(9,6);
define _sum_por_part_reaseg	dec(9,6);
define _sum_por_part_total	dec(9,6);
define _cnt_existe          integer;


set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, trim(_error_desc) || " " || _transaccion;
end exception

--SET DEBUG FILE TO "sp_aud50.trc";
--trace on;


delete from deivid_ttcorp:tmp_det_movim_tecn;
delete from deivid_ttcorp:movim_reaseguro;
delete from deivid_ttcorp:reas_caract_sin;


let _cont_1    = 0; 
let _cont_2    = 0; 
let _fecha_hoy = current;
let _tipo_sin  = "PEN";

select valor_parametro
  into _cont_1
  from parcont
 where cod_parametro = 'ttcorp_id1_sin';

select valor_parametro
  into _cont_2
  from parcont
 where cod_parametro = 'ttcorp_id2_sin';

 select valor_parametro
  into _id_reas_caract
  from parcont
 where cod_parametro = 'ttcorp_id3_sin';

foreach

	SELECT no_reclamo		
	  INTO _no_reclamo	
	  FROM rectrmae 
	 WHERE periodo        >= a_periodo_desde 
	   AND periodo        <= a_periodo_hasta 
	   AND actualizado    = 1
	 GROUP BY no_reclamo
	 HAVING SUM(variacion) > 0 

	foreach 
		select no_reclamo,
		        no_tranrec,
		        periodo,
		        fecha,
		        transaccion,
				cod_cliente,
		  		variacion,
				numrecla,
				pagado,
				fecha_pagado,
				user_added,
				cod_sucursal,
				cod_tipotran
		   into _no_reclamo,
		        _no_tranrec,
		        _periodo,
		        _fecha,
		        _transaccion,
				_cod_cliente,
		  		_monto,
				_numrecla,
				_pagado,
				_fecha_pagado,
				_user_added,
				_cod_sucursal,
				_cod_tipotran
		   from	rectrmae
		  where no_reclamo  = _no_reclamo
		    and periodo     >= a_periodo_desde
			and periodo     <= a_periodo_hasta
			and actualizado = 1
			and variacion   <> 0
		  order by fecha

		if _periodo > a_periodo_hasta then  --a_periodo_hasta = periodo de corte
			continue foreach;
		end if

		let _mes			= _periodo[6,7];
		let _ano			= _periodo[1,4];
		  --let _ramo         = _numrecla[1,2];
		  let _fecha_pagado	= _fecha;

		select no_documento, 
			 no_unidad, 
			 fecha_siniestro, 
			 fecha_documento, 
			 cod_asegurado,
			 no_poliza,
			 cod_evento
		into _no_documento, 
			 _no_unidad, 
			 _fecha_siniestro, 
			 _fecha_documento, 
			 _cod_asegurado,
			 _no_poliza,
			 _cod_evento
		from recrcmae
		where no_reclamo = _no_reclamo;

	      select vigencia_inic,
		         vigencia_final,
				 serie,
				 cod_ramo,
				 cod_grupo,
				 cod_subramo,
				 cod_tipoprod
		    into _vigencia_inic,
				 _vigencia_final,
				 _serie,
				 _cod_ramo,
				 _cod_grupo,
				 _cod_subramo,
				 _cod_tipoprod
		    from emipomae
		   where no_poliza = _no_poliza;
		
		let _ramo = _cod_ramo;
		
		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis = 1 then
			let _cod_area_seguro = 2; --Automovil
		elif _ramo_sis = 3 then
			let _cod_area_seguro = 7; --Fianza
		elif _ramo_sis = 5 then
			let _cod_area_seguro = 1; --Salud
		elif _ramo_sis in (6,7) then
			let _cod_area_seguro = 4; --Personas
		else
			let _cod_area_seguro = 9; --Patrimoniales
		end if


	    if _vigencia_final is null then
			let _vigencia_final = _vigencia_inic + 1 units year;
	    end if 

		foreach
		   select cod_agente
		     into _cod_agente
			 from emipoagt
			where no_poliza = _no_poliza

		   exit foreach;
		end foreach

		foreach

			 select	cod_cobertura,
			        monto
			   into _cod_cobertura,
			        _monto
			   from rectrcob
			  where no_tranrec = _no_tranrec
			    and monto      <> 0

				select cod_cober_reas
				  into _cod_cober_reas
			      from prdcober
		         where cod_cobertura = _cod_cobertura;

			 let _cont_1 = _cont_1 + 1;

			 --Individual/Colectivo
			 select count(*)
			   into _cantidad
			   from emipouni
			  where no_poliza = _no_poliza;

			let _indcol = 'I';

			if _cod_ramo IN('002','020') and _cantidad > 5 then --Es colectivo
			   let _indcol = 'C';
			elif (_cod_ramo = '004' and _cantidad > 10) or (_cod_ramo = '004' and _cod_grupo = '01016') then
			   let _indcol = 'C';
			elif _cod_ramo = '018' and _cod_subramo in('010','012') then
			   let _indcol = 'C';
			end if

			if _cod_grupo in('991','990','00000','1000') then
			   let _indcol = 'C';
			end if

			  insert into deivid_ttcorp:tmp_det_movim_tecn(
				id_mov_tecnico,
				cod_empresa,
				num_ano,
				num_mes,
				num_serie,
				cod_area_seguro,
				cod_producto,
				cod_ramo,
				cod_ramorea,
				cod_moneda,
				por_tasa,
				tip_siniestro,
				id_poliza,
				id_recibo,
				id_siniestro,
				id_certificado,
				fec_ocurre,
				fec_notifica,
				fec_inivig,
				fec_finvig,
				cod_situacion,
				fec_situacion,
				fec_operacion,
				fec_registro,
				cod_usuario,
				mon_suma,
				mon_ajustado,
				mon_pagado,
				mon_reserva,
				id_relac_cliente,
				id_relac_productor,
				cod_causa,
				no_tranrec,
				cod_sucurs,
				co_tipotr,
				cod_subram,
				ind_indcol,
				id_mov_tecnico_anc,
				cod_ramo_ancon,
				cod_ramorea_ancon,
				id_relac_cliente_a,
				id_relac_productor_ancon,
				ind_actualizado,
				flag)
				values(
				0,
				11,
				_ano,
				_mes,
				_serie,
				_cod_area_seguro,
				_ramo,
				0,
				0,
				"USD",
				1,
				_tipo_sin,
				_no_documento,
				_transaccion,
				_numrecla,
				_no_unidad,
				_fecha_siniestro,
				_fecha_documento,
				_vigencia_inic,
				_vigencia_final,
				1,
				_fecha_hoy,
				_fecha_pagado,
				_fecha,
				_user_added,
				0,
				0,
				0,
				_monto,
				0,
				0,
				_cod_evento,
				_no_tranrec,
				_cod_sucursal,
				_cod_tipotran,
				_cod_subramo,
				_indcol,
				_cont_1,
				_ramo,
				_cod_cober_reas,
				_cod_asegurado,
				_cod_agente,
				0,
				0);

		-- Coaseguro

			let _porc_part_total  = 0;
			let _porc_partic_coas = 0;

			let _porc_partic_coas = 100;

			if _cod_tipoprod = '001' then
				select porc_partic_coas
				  into _porc_partic_coas
				  from reccoas
				 where no_reclamo   = _no_reclamo
				   and cod_coasegur = '036';

				foreach
					select cod_coasegur,
						   porc_partic_coas
					  into _cod_coasegur,
						   _porc_partic_reas
					  from reccoas
					 where no_reclamo   = _no_reclamo
					   and cod_coasegur <> '036'

					let _cont_2 = _cont_2 + 1;
					let _tipo_cont_tt = "Y";

					  insert into deivid_ttcorp:movim_reaseguro(
						id_mov_reas,
						tip_contrato,
						por_part_total,
						por_part_reaseg,
						id_mov_tecnico,
						fec_operacion,
						fec_registro,
						cod_usuario,
						id_relacionado,
						no_tranrec,
						id_mov_tecnico_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon
						)
						values (
						null,
						_tipo_cont_tt,
						_porc_partic_reas,
						0.00,
						null,
						_fecha_pagado,
						_fecha,
						_user_added,
						null,
						_no_tranrec,
						_cont_1,
						_cont_2,
						_cod_coasegur);

						let _id_reas_caract = _id_reas_caract + 1;
						let _mnto_concepto  = 0;
						let _mnto_concepto  = _monto * (_porc_partic_reas/100);

						insert into deivid_ttcorp:reas_caract_sin(
								id_reas_caract,    
								tip_contrato,   
								cod_concepto, 
								mto_concepto,
								id_mov_reas,
								fec_operacion,
								fec_registro,
								cod_usuario, 
								id_relacionado,
								id_reas_caract_anc,
								id_mov_reas_ancon,
								id_relacionado_anc,
								ind_actualizado)
						values	(null,    
								_tipo_cont_tt,   
								80, --siniestros Pend
								_mnto_concepto,
								_cont_2, 
								_fecha_pagado,
								_fecha,
								_user_added,
								null,
								_id_reas_caract,
								_cont_2,
								_cod_coasegur,
								0);

						select count(*)
						  into _cnt_existe
						  from deivid_ttcorp:reas_caract_sin
						 where id_mov_reas_ancon = _cont_2;
						
						if _cnt_existe is null then
							let _cnt_existe = 0;
						end if
						
						if _cnt_existe = 0 then
							update deivid_ttcorp:movim_reaseguro
							   set flag = 3
							 where id_mov_tecnico_ancon = _cont_1
							   and id_mov_reas_ancon    = _cont_2
							   and flag                 = 0;
						end if

				end foreach
			end if

		-- Reaseguro

			select count(*)
			  into _cont_rea
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cont_rea is null or _cont_rea = 0 then

				if _cod_ramo = '002' And _periodo <= '2013-06' then

					let _cod_cober_reas = '002';

					update deivid_ttcorp:tmp_det_movim_tecn
					   set cod_ramorea_ancon  = _cod_cober_reas
					 where id_mov_tecnico_anc = _cont_1;

				elif _cod_ramo = '002' And _periodo >= '2013-07' then

					Call sp_sis119e(_no_reclamo) returning _error,_error_desc;
				end if
				let _cont_rea = 1;
			end if

			if _cont_rea > 0 then
				foreach
				      select tipo_contrato,
				      		 porc_partic_suma,
							 orden,
							 cod_contrato
					    into _tipo_contrato,
							 _porc_partic_suma,
							 _orden,
							 _cod_contrato
						from rectrrea
					   where no_tranrec     = _no_tranrec
					     and cod_cober_reas = _cod_cober_reas 

					  let _porc_proporcion = _porc_partic_suma;

			      	  if _tipo_contrato = 1 then	--Retencion
						let _tipo_cont_tt = "A";
					  elif _tipo_contrato = 2 then	--Fronting
						let _tipo_cont_tt = "Z";
					  elif _tipo_contrato = 3 then	--Facultativo
						let _tipo_cont_tt = "Z";
					  elif _tipo_contrato = 4 then	--Normal
						let _tipo_cont_tt = "F";
					  elif _tipo_contrato = 5 then	--Cuota Parte
						let _tipo_cont_tt = "B";
					  elif _tipo_contrato = 6 then	--Exceso de Perdida
						let _tipo_cont_tt = "M";
					  elif _tipo_contrato = 7 then	--Excedente
						let _tipo_cont_tt = "C";
					  end if

					if _tipo_contrato = 3 or _tipo_contrato = 2 then

						select count(*)
						  into _cont_rea_f
						  from rectrref
						 where no_tranrec     = _no_tranrec
						   and orden          = _orden
						   and cod_cober_reas = _cod_cober_reas;

						if _tipo_contrato = 2 And (_cont_rea_f = 0 or _cont_rea_f is null) then
					  		  let _cont_2 = _cont_2 + 1; 
							  let _porc_part_total  = _porc_partic_suma * (_porc_partic_coas / 100);

							  insert into deivid_ttcorp:movim_reaseguro (
								id_mov_reas,
								tip_contrato,
								por_part_total,
								por_part_reaseg,
								id_mov_tecnico,
								fec_operacion,
								fec_registro,
								cod_usuario,
								id_relacionado,
								no_tranrec,
								id_mov_tecnico_ancon,
								id_mov_reas_ancon,
								id_relacionado_ancon
								)
								values (
								null,
								_tipo_cont_tt,
								_porc_part_total,
								_porc_partic_suma,
								null,
								_fecha_pagado,
								_fecha,
								_user_added,
								null,
								_no_tranrec,
								_cont_1,
								_cont_2,
								null
							    );
						end if

						if _cont_rea_f > 0 then
						    foreach
								select cod_coasegur,
								       porc_partic_reas
								  into _cod_coasegur,
									   _porc_partic_reas
								  from rectrref
								 where no_tranrec     = _no_tranrec
								   and orden          = _orden
							       and cod_cober_reas = _cod_cober_reas

					  			let _cont_2 = _cont_2 + 1; 

								let _porc_partic_reas = _porc_partic_reas * (_porc_proporcion / 100);
								let _porc_part_total  = _porc_partic_reas * (_porc_partic_coas / 100);


								  insert into deivid_ttcorp:movim_reaseguro(
									id_mov_reas,
									tip_contrato,
									por_part_total,
									por_part_reaseg,
									id_mov_tecnico,
									fec_operacion,
									fec_registro,
									cod_usuario,
									id_relacionado,
									no_tranrec,
									id_mov_tecnico_ancon,
									id_mov_reas_ancon,
									id_relacionado_ancon
									)
									values (
									null,
									_tipo_cont_tt,
									_porc_part_total,
									_porc_partic_reas,
									null,
									_fecha_pagado,
									_fecha,
									_user_added,
									null,
									_no_tranrec,
									_cont_1,
									_cont_2,
									_cod_coasegur
								    );

									let _id_reas_caract = _id_reas_caract + 1;
									let _mnto_concepto  = 0;
									let _mnto_concepto  = _monto * (_porc_partic_reas/100);

									insert into deivid_ttcorp:reas_caract_sin(
											id_reas_caract,    
											tip_contrato,   
											cod_concepto, 
											mto_concepto,
											id_mov_reas,
											fec_operacion,
											fec_registro,
											cod_usuario, 
											id_relacionado,
											id_reas_caract_anc,
											id_mov_reas_ancon,
											id_relacionado_anc,
											ind_actualizado)
									values	(null,    
											_tipo_cont_tt,   
											80, --siniestros Pagados
											_mnto_concepto,
											_cont_2, 
											_fecha_pagado,
											_fecha,
											_user_added,
											null,
											_id_reas_caract,
											_cont_2,
											_cod_coasegur,
											0);

									select count(*)
									  into _cnt_existe
									  from deivid_ttcorp:reas_caract_sin
									 where id_mov_reas_ancon = _cont_2;
									
									if _cnt_existe is null then
										let _cnt_existe = 0;
									end if
									
									if _cnt_existe = 0 then
										update deivid_ttcorp:movim_reaseguro
										   set flag = 3
										 where id_mov_tecnico_ancon = _cont_1
										   and id_mov_reas_ancon    = _cont_2
										   and flag                 = 0;
									end if


							end foreach
						end if
					else

						if _tipo_contrato = 1 then
							let _porc_part_total  = _porc_partic_suma * (_porc_partic_coas / 100);

								let _cont_2 = _cont_2 + 1; 
								insert into deivid_ttcorp:movim_reaseguro(
								id_mov_reas,
								tip_contrato,
								por_part_total,
								por_part_reaseg,
								id_mov_tecnico,
								fec_operacion,
								fec_registro,
								cod_usuario,
								id_relacionado,
								no_tranrec,
								id_mov_tecnico_ancon,
								id_mov_reas_ancon,
								id_relacionado_ancon
								)
								values (
								null,
								_tipo_cont_tt,
								_porc_part_total,
								_porc_partic_suma,
								null,
								_fecha_pagado,
								_fecha,
								_user_added,
								null,
								_no_tranrec,
								_cont_1,
								_cont_2,
								null
								);
						else
							foreach
								select cod_coasegur,
									   porc_cont_partic,
									   contrato_xl
								  into _cod_coasegur,
									   _porc_partic_reas,
									   _contrato_xl
								  from reacoase
								 where cod_contrato   = _cod_contrato
								   and cod_cober_reas = _cod_cober_reas
								   and porc_cont_partic <> 0

								let _porc_partic_reas = _porc_partic_reas * (_porc_proporcion / 100);
								let _porc_part_total  = _porc_partic_reas * (_porc_partic_coas / 100);


								if _contrato_xl = 1 then
									let _tipo_cont_tt = 'M';
								else
									let _cod_coasegur = null;

									select count(*)
									  into _cnt
									  from deivid_ttcorp:movim_reaseguro
									 where id_mov_tecnico_ancon = _cont_1
									   and tip_contrato         = _tipo_cont_tt;

									if _cnt > 0 then

										update deivid_ttcorp:movim_reaseguro
										   set id_relacionado_ancon    = null,
										       por_part_total  = por_part_total + _porc_part_total,
											   por_part_reaseg = por_part_reaseg + _porc_partic_reas 
										 where id_mov_tecnico_ancon = _cont_1
										   and tip_contrato         = _tipo_cont_tt;

			                            continue foreach;
										       
									end if
								end if

								let _cont_2 = _cont_2 + 1;

								insert into deivid_ttcorp:movim_reaseguro(
								id_mov_reas,
								tip_contrato,
								por_part_total,
								por_part_reaseg,
								id_mov_tecnico,
								fec_operacion,
								fec_registro,
								cod_usuario,
								id_relacionado,
								no_tranrec,
								id_mov_tecnico_ancon,
								id_mov_reas_ancon,
								id_relacionado_ancon
								)
								values (
								null,
								_tipo_cont_tt,
								_porc_part_total,
								_porc_partic_reas,
								null,
								_fecha_pagado,
								_fecha,
								_user_added,
								null,
								_no_tranrec,
								_cont_1,
								_cont_2,
								_cod_coasegur);

							end foreach
						end if
					end if
				end foreach

				select sum(por_part_total),
					   sum(por_part_reaseg)
				  into _sum_por_part_total,
					   _sum_por_part_reaseg
				  from deivid_ttcorp:movim_reaseguro
				 where id_mov_tecnico_ancon = _cont_1;
				
				let _diferencia = 0.00;
				let _diferencia = 100 - _sum_por_part_total;
				
				if abs(_diferencia) > 0.100000 then
					update deivid_ttcorp:tmp_det_movim_tecn
					   set flag = 2
					 where id_mov_tecnico_anc = _cont_1;
				end if
				
				if _diferencia > 0.000000 and _diferencia < 0.100000 then
					update deivid_ttcorp:movim_reaseguro
					   set por_part_total = por_part_total - _diferencia
					 where id_mov_tecnico_ancon = _cont_1
					   and tip_contrato = 'A';
				elif _diferencia < 0.000000 and _diferencia > -0.100000 then
					update deivid_ttcorp:movim_reaseguro
					   set por_part_total = por_part_total + _diferencia
					 where id_mov_tecnico_ancon = _cont_1
					   and tip_contrato = 'A';

				end if
			end if
		end foreach	
	end foreach
end foreach

let _cnt = 0;

select count(*)
  into _cnt
  from deivid_ttcorp:tmp_det_movim_tecn
 where flag in(2);

select count(*)
  into _cnt
  from deivid_ttcorp:movim_reaseguro
 where flag in(3);

return _cnt,'Inserción Exitosa';	

end

end procedure

