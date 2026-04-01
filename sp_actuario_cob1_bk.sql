drop procedure sp_actuario_cob1;
-- copia de sp_actuario
create procedure "informix".sp_actuario_cob1(a_id_mov_tecnico1 integer, a_id_mov_tecnico2 integer,a_id_mov_reas integer, a_id_reas_caract integer)
	returning integer,varchar(250);

BEGIN

define _error_desc			varchar(250);
define _tip_contrato		varchar(1);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _cod_contrato		char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _sum_por_part_reaseg	dec(9,6);
define _sum_por_part_total	dec(9,6);
define _porc_partic_ancon	dec(9,6);
define _porc_cont_partic	dec(9,6);
define _porc_proporcion		dec(9,6);
define _por_part_reaseg		dec(9,6);
define _por_part_total		dec(9,6);
define _diferencia			dec(9,6);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _contrato_xl 		smallint;
define _cnt_existe			smallint;
define _tipo_cont			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relacionado		integer;
define _id_mov_tecnico		integer;
define _id_reas_caract		integer;
define _id_reas_caract2		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _renglon				integer;
define _cnt					integer;
define _error				integer;
define _fec_inivig          date;
define _cod_ramo            char(3);
define _cod_contrato_map    char(5);
define _cod_cober           char(3);

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'Contrato: ' ||  _cod_contrato;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario_cob1.trc";
--trace on;

set isolation to dirty read;

let _id_mov_tecnico = 0;
let _id_mov_reas	= a_id_mov_reas;
let _id_reas_caract = a_id_reas_caract;
let _por_part_total = 0.00;
let _cod_contrato_map = '00620';

--let _id_reas_caract2 = null;

if _id_mov_reas is null then
	let _id_mov_reas = 0;
end if

foreach --with hold
	select id_mov_tecnico_anc,
		   id_certificado,
		   id_recibo,
		   cod_ramorea_ancon,
		   no_remesa,
		   renglon,
		   fec_inivig
	  into _id_mov_tecnico,
		   _id_certificado,
		   _id_recibo,
		   _cod_ramorea,
		   _no_remesa,
		   _renglon,
		   _fec_inivig
	  from movim_tec_pri_tt
	 where id_mov_tecnico_anc >= a_id_mov_tecnico1
	   and id_mov_tecnico_anc <= a_id_mov_tecnico2
	   and cod_ramorea_ancon <> 100
	
	let _cod_cober_reas = '000';
	
	if _cod_ramorea > 99 then
		let _cod_cober_reas[1,3] = _cod_ramorea;
	elif _cod_ramorea > 9 then
		let _cod_cober_reas[2,3] = _cod_ramorea;
	else
		let _cod_cober_reas[3,3] = _cod_ramorea;
	end if
	
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;
	
	select cod_tipoprod,
	       cod_ramo
	  into _cod_tipoprod,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	
	let _porc_partic_ancon = 100;
	
	if _cod_tipoprod = '001' then
		select porc_partic_coas
		  into _porc_partic_ancon
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036';
		   
		foreach
			select cod_coasegur,
				   porc_partic_coas
			  into _cod_coasegur,
				   _por_part_total 
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur <> "036"
			   
			if _por_part_total is null or _por_part_total = 0 then
				continue foreach;
			end if
			
			let _id_mov_reas    = _id_mov_reas + 1;
			let _id_relacionado = _cod_coasegur;
			
			insert into movim_reaseguro_tt(
					id_mov_reas,    
					tip_contrato,   
					por_part_total, 
					por_part_reaseg,
					id_mov_tecnico, 
					id_relacionado,
					id_mov_tecnico_ancon,
					id_mov_reas_ancon,
					id_relacionado_ancon,
					ind_actualizado
					)
			values	(0,
					'Y',   --Coaseguro
					_por_part_total, 
					0.00,
					0, 
					0,
					_id_mov_tecnico,
					_id_mov_reas,
					_id_relacionado,
					0);

		  	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;
			
			select count(*)
			  into _cnt_existe
			  from reas_caract_pri_tt
			 where id_mov_reas_ancon = _id_mov_reas;
			
			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if
			
			if _cnt_existe = 0 then
				update movim_reaseguro_tt
				   set flag = 3
				 where id_mov_tecnico_anc = _id_mov_tecnico
				   and id_mov_reas_ancon = _id_mov_reas
				   and flag = 0;
			end if
			
			select max(id_reas_caract_ancon)
			  into _id_reas_caract
			  from reas_caract_pri_tt;

		  
			if _error <> 0 then
				let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
				return _error,_error_desc;
			end if
			
			if _error <> 0 then
				--drop table tmp_reas;
				--rollback work;
				let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
				return _error,_error_desc;
			end if
		end foreach
	end if


	foreach
	   {	select cod_contrato,
			   porc_partic_prima
		  into _cod_contrato,
			   _por_part_total
		  from cobreaco
		 where no_remesa      = _no_remesa
		   and renglon        = _renglon
		   and cod_cober_reas = _cod_cober_reas}

	   	select cod_contrato,
			   porc_partic_prima,
			   cod_cober_reas
		  into _cod_contrato,
			   _por_part_total,
			   _cod_cober
		  from tmp_reas
		 where cod_cober_reas = _cod_cober_reas
		
		let _por_part_reaseg = _por_part_total;
		let _porc_proporcion = _por_part_total;
		let _por_part_total  = _por_part_total * (_porc_partic_ancon / 100);
		
		select tipo_contrato
		  into _tipo_cont
		  from reacomae
		 where cod_contrato = _cod_contrato;
		
		if _tipo_cont = 1 then
			if _cod_ramo in('001','003','010','011','012','013','014','021','022') and _fec_inivig <= '30/06/2014' then
				let _por_part_total  = _por_part_total * 0.50;
				let _por_part_reaseg  = _por_part_reaseg * 0.50;

				let _tip_contrato = 'A'; --Retencion
				let _id_mov_reas = _id_mov_reas + 1;
				
				insert into movim_reaseguro_tt(
						id_mov_reas,    
						tip_contrato,   
						por_part_total, 
						por_part_reaseg,
						id_mov_tecnico, 
						id_relacionado,
						cod_contrato,
						id_mov_tecnico_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon,
						ind_actualizado)
				values	(0,    
						_tip_contrato,   
						_por_part_total, 
						_por_part_reaseg,
						0, 
						null,
						_cod_contrato,
						_id_mov_tecnico,
						_id_mov_reas,
						0,
						0);

			   	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;
				
				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from reas_caract_pri_tt;

				if _error <> 0 then
					--drop table tmp_reas;
				   --	rollback work;
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if

				let _tip_contrato = 'B'; --cuota parte 50% Mapfre
				let _id_mov_reas = _id_mov_reas + 1;

				foreach
					select cod_contrato
					  into _cod_contrato_map
	  			      from reacomae
			 		 where ret_mapfre = 1
					   and _fec_inivig between vigencia_inic and vigencia_final

					exit foreach;
				end foreach

				select cod_coasegur
				  into _cod_coasegur
				  from reacoase
				 where cod_contrato   = _cod_contrato_map
				   and cod_cober_reas = _cod_cober
				   and porc_cont_partic <> 0;

				insert into movim_reaseguro_tt(
						id_mov_reas,    
						tip_contrato,   
						por_part_total, 
						por_part_reaseg,
						id_mov_tecnico, 
						id_relacionado,
						cod_contrato,
						id_mov_tecnico_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon,
						ind_actualizado)
				values	(0,    
						_tip_contrato,   
						_por_part_total, 
						_por_part_reaseg,
						0, 
						null,
						_cod_contrato_map,
						_id_mov_tecnico,
						_id_mov_reas,
						_cod_coasegur,
						0);

			   	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;
				
				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from reas_caract_pri_tt;

				if _error <> 0 then
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if

			else			
				let _tip_contrato = 'A'; --Retencion
				let _id_mov_reas = _id_mov_reas + 1;
				
				insert into movim_reaseguro_tt(
						id_mov_reas,    
						tip_contrato,   
						por_part_total, 
						por_part_reaseg,
						id_mov_tecnico, 
						id_relacionado,
						cod_contrato,
						id_mov_tecnico_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon,
						ind_actualizado)
				values	(0,    
						_tip_contrato,   
						_por_part_total, 
						_por_part_reaseg,
						0, 
						null,
						_cod_contrato,
						_id_mov_tecnico,
						_id_mov_reas,
						0,
						0);

			   	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;
				
				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from reas_caract_pri_tt;

				if _error <> 0 then
					--drop table tmp_reas;
				   --	rollback work;
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if
			end if

		elif _tipo_cont = 3 then
			let _tip_contrato = 'Z'; --Facultativo
			foreach
				select distinct cod_coasegur,
				       porc_partic_reas
				  into _cod_coasegur,
					   _porc_cont_partic
				  from cobreafa
				 where no_remesa = _no_remesa
				   and renglon   = _renglon
				
				let _por_part_reaseg = _porc_cont_partic * (_porc_proporcion / 100);
				let _por_part_total  = _porc_proporcion * (_porc_cont_partic / 100) * (_porc_partic_ancon / 100);
				let _id_mov_reas     = _id_mov_reas + 1;
				
				insert into movim_reaseguro_tt(
						id_mov_reas,    
						tip_contrato,   
						por_part_total, 
						por_part_reaseg,
						id_mov_tecnico, 
						id_relacionado,
						cod_contrato,
						id_mov_tecnico_ancon,
					    id_mov_reas_ancon,
					    id_relacionado_ancon,
						ind_actualizado)
				values	(0,    
						_tip_contrato,   
						_por_part_total, 
						_por_part_reaseg,
						0, 
					    0,
						_cod_contrato,
						_id_mov_tecnico,
						_id_mov_reas,
						_cod_coasegur,
						0);

			   	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;
				
				select count(*)
				  into _cnt_existe
				  from reas_caract_pri_tt
				 where id_mov_reas_ancon = _id_mov_reas;
				
				if _cnt_existe is null then
					let _cnt_existe = 0;
				end if
				
				if _cnt_existe = 0 then
					update movim_reaseguro_tt
					   set flag = 3
					 where id_mov_tecnico_anc = _id_mov_tecnico
					   and id_mov_reas_ancon = _id_mov_reas
					   and flag = 0;
				end if
				
				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from reas_caract_pri_tt;

			   {	if _id_reas_caract2 is not null then
					let _id_reas_caract = _id_reas_caract2;
				end if}

				
				if _error <> 0 then
					--drop table tmp_reas;
				   --	rollback work;
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if
			end foreach
		else
			if _tipo_cont = 2 then
				let _tip_contrato = 'F';
			elif _tipo_cont = 4 then
				let _tip_contrato = '';
			elif _tipo_cont = 5 then
				let _tip_contrato = 'B';
			elif _tipo_cont = 6 then
				let _tip_contrato = 'G';
			elif _tipo_cont = 7 then
				let _tip_contrato = 'C';
			end if

			select count(*)
			  into _cnt
			  from reacoase
			 where cod_contrato     = _cod_contrato
			   and cod_cober_reas   = _cod_cober_reas
			   and porc_cont_partic <> 0;

			if _cnt is null or _cnt = 0 then

				let _por_part_total = _porc_proporcion * (_porc_partic_ancon / 100);
				let _id_mov_reas = _id_mov_reas + 1;

				insert into movim_reaseguro_tt(
						id_mov_reas,    
						tip_contrato,   
						por_part_total, 
						por_part_reaseg,
						id_mov_tecnico, 
						id_relacionado,
						cod_contrato,
						id_mov_tecnico_ancon,
					    id_mov_reas_ancon,
					    id_relacionado_ancon,
						ind_actualizado)
				values	(0,    
						_tip_contrato,   
						_por_part_total, 
						_por_part_reaseg,
						0, 
						null,
						_cod_contrato,
						_id_mov_tecnico,
						_id_mov_reas,
						0,
						0);

			   	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;

				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from reas_caract_pri_tt;

{				if _id_reas_caract2 is not null then
					let _id_reas_caract = _id_reas_caract2;
				end if}

				
				if _error <> 0 then
					--drop table tmp_reas;
				   --	rollback work;
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if

			else
				foreach
					select cod_coasegur,
						   porc_cont_partic,
						   contrato_xl
					  into _cod_coasegur,
						   _porc_cont_partic,
						   _contrato_xl
					  from reacoase
					 where cod_contrato     = _cod_contrato
					   and cod_cober_reas   = _cod_cober_reas
					   and porc_cont_partic <> 0
					   
					let _por_part_reaseg = _porc_cont_partic * (_porc_proporcion / 100);
					let _por_part_total  = _porc_proporcion * (_porc_cont_partic / 100) * (_porc_partic_ancon / 100);
					let _id_mov_reas = _id_mov_reas + 1;
					
					if _contrato_xl = 1 then
						let _tip_contrato = 'M'; --Primer Contrato Excedente
					else
						let _cod_coasegur = null;
						
						select count(*)
						  into _cnt
						  from movim_reaseguro_tt
						 where id_mov_tecnico_ancon = _id_mov_tecnico
						   and tip_contrato         = _tip_contrato;

						if _cnt > 0 then

							update movim_reaseguro_tt
							   set por_part_total  = por_part_total  + _por_part_total,
								   por_part_reaseg = por_part_reaseg + _por_part_reaseg 
							 where id_mov_tecnico_ancon = _id_mov_tecnico
							   and tip_contrato         = _tip_contrato;

	                        continue foreach;
						end if
					end if
					
					insert into movim_reaseguro_tt(
							id_mov_reas,    
							tip_contrato,   
							por_part_total, 
							por_part_reaseg,
							id_mov_tecnico, 
							id_relacionado,
							cod_contrato,
							id_mov_tecnico_ancon,
					    	id_mov_reas_ancon,
					    	id_relacionado_ancon,
							ind_actualizado)
					values	(0,    
							_tip_contrato,   
							_por_part_total, 
							_por_part_reaseg,
							0, 
							0,
							_cod_contrato,
							_id_mov_tecnico,
							_id_mov_reas,
							_cod_coasegur,
							0);

				  	call sp_actuario_cob2(_id_mov_reas,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;

					select max(id_reas_caract_ancon)
					  into _id_reas_caract
					  from reas_caract_pri_tt;

{					if _id_reas_caract2 is not null then
						let _id_reas_caract = _id_reas_caract2;
					end if}
					
					if _error <> 0 then
						--drop table tmp_reas;
					 --	rollback work;
						let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
						return _error,_error_desc;
					end if
				end foreach
			end if
		end if			
	end foreach
	
	select sum(por_part_total),
		   sum(por_part_reaseg)
	  into _sum_por_part_total,
		   _sum_por_part_reaseg
	  from movim_reaseguro_tt
	 where id_mov_tecnico_ancon = _id_mov_tecnico;
	 --group by 1 
	--having sum(por_part_total) <> 100;
	
	let _diferencia = 0.00;
	let _diferencia = 100 - _sum_por_part_total;
	
	if abs(_diferencia) > 0.100000 then
		update movim_tec_pri_tt
		   set flag = 2
		 where id_mov_tecnico_anc = _id_mov_tecnico
		   and flag = 0;
	end if
	
	if _diferencia > 0.000000 and _diferencia < 0.100000 then
		update movim_reaseguro_tt
		   set por_part_total = por_part_total - _diferencia
		 where id_mov_tecnico_ancon = _id_mov_tecnico
		   and tip_contrato = 'A';
	elif _diferencia < 0.000000 and _diferencia > -0.100000 then
		update movim_reaseguro_tt
		   set por_part_total = por_part_total + _diferencia
		 where id_mov_tecnico_ancon = _id_mov_tecnico
		   and tip_contrato = 'A';
	end if
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure;