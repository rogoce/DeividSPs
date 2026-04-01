drop procedure sp_actuario21;
-- copia de sp_actuario
create procedure sp_actuario21(a_id_mov_reas1 integer, a_id_mov_reas2 integer, a_id_reas_caract integer)
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
define _periodo				char(7);
define _cod_contrato		char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(4);
define _cod_coasegur		char(4);
define _cod_tipoprod		char(3);
define _por_part_total		dec(9,6);
define _porc_comision		dec(9,6);
define _por_part_reaseg		dec(9,6);
define _porc_impuesto		dec(9,6);
define _porc_cont_partic	dec(9,6);
define _por_tasa			dec(7,3);
define _mnto_concepto		dec(18,6);
define _mto_prima			dec(18,6); 
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_concepto		smallint;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _tipo_cont			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relacionado		integer;
define _id_mov_tecnico		integer;
define _id_reas_caract		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _error,_cnt			integer;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	--rollback work;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario21.trc";
--trace on;

set isolation to dirty read;

let _id_mov_tecnico = 0;
let _id_reas_caract	= 0;
let _id_mov_reas	= 0;
let _por_part_total = 0.00;
let _cod_empresa = 11;

{select max(id_reas_caract_ancon)
  into _id_reas_caract
  from deivid_ttcorp:reas_caract_pri;}

--let _id_reas_caract = a_id_reas_caract;

{if _id_reas_caract is null then
	let _id_reas_caract = 0;
end if}

select count(*)
  into _cnt
  from deivid_ttcorp:reas_caract_pri;

if _cnt = 0 then

	select valor_parametro
	  into _id_reas_caract
	  from parcont
	 where cod_parametro = 'ttcorp_id3_pri';
else

	select max(id_reas_caract_ancon)
	  into _id_reas_caract
	  from deivid_ttcorp:reas_caract_pri;

end if


foreach --with hold
	select id_mov_tecnico_ancon,
		   id_mov_reas_ancon,
		   id_relacionado_ancon,
		   tip_contrato,
		   por_part_total,
		   cod_contrato
	  into _id_mov_tecnico,
		   _id_mov_reas,
		   _id_relacionado,
		   _tip_contrato,
		   _por_part_total,
		   _cod_contrato
	  from deivid_ttcorp:movim_reaseguro_pr
	 where id_mov_reas_ancon >= a_id_mov_reas1
	   and id_mov_reas_ancon <= a_id_mov_reas2
	   and tip_contrato in ('Y','Z')
	   
	--begin work;
	
	select id_certificado,
		   id_recibo,
		   cod_ramorea_ancon,
		   mto_prima,
		   id_poliza,
		   no_poliza,
		   no_endoso
	  into _id_certificado,
		   _id_recibo,
		   _cod_ramorea,
		   _mto_prima,
		   _id_poliza,
		   _no_poliza,
		   _no_endoso
	  from deivid_ttcorp:movim_tec_pri_ttco
	 where id_mov_tecnico = _id_mov_tecnico;
	
	let _cod_coasegur = '000';
	--if _id_relacionado is not null and _id_relacionado <> '' then
		
	if _id_relacionado > 99 then
		let _cod_coasegur = _id_relacionado;
	elif _id_relacionado > 9 then
		let _cod_coasegur = '0' || _id_relacionado;
	else
		let _cod_coasegur = '00' || _id_relacionado;
	end if
	--send if
	
	if _cod_ramorea > 99 then
		let _cod_cober_reas = _cod_ramorea;
	elif _cod_ramorea > 9 then
		let _cod_cober_reas = '0' || _cod_ramorea;
	else
		let _cod_cober_reas = '00' || _cod_ramorea;
	end if
	
	let _cod_cober_reas = trim(_cod_cober_reas);
	let _cod_coasegur = trim(_cod_coasegur);

	let _mnto_concepto = 0.00;
	
	let _cod_concepto = 1;--Prima
	let _id_reas_caract = _id_reas_caract + 1;
	let _mnto_concepto = _mto_prima * (_por_part_total/100);
	
	insert into deivid_ttcorp:reas_caract_pri(
			id_reas_caract,    
			tip_contrato,   
			cod_concepto, 
			mto_concepto,
			id_mov_reas, 
			id_relacionado,
			id_reas_caract_ancon,
			id_mov_reas_ancon,
			id_relacionado_ancon,
			ind_actualizado)
	values	(null,    
			_tip_contrato,   
			_cod_concepto, 
			_mnto_concepto,
			null, 
			null,
			_id_reas_caract,
			_id_mov_reas,
			_id_relacionado,
			0);
	
	let _mnto_concepto = 0.00;
	
	let _cod_concepto = 50;--Comision
	
	if _tip_contrato = 'A' then
		let _cod_concepto = 55;--Impuesto
		
		select porc_impuesto
		  into _porc_impuesto
		  from reacocob
		 where cod_contrato = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;
		 
		let _mnto_concepto = _mto_prima * (_por_part_total / 100) * (_porc_impuesto / 100);
		
		if _mnto_concepto is not null and _mnto_concepto <> 0 then
			let _id_reas_caract = _id_reas_caract + 1;
			insert into deivid_ttcorp:reas_caract_pri(
					id_reas_caract,    
					tip_contrato,   
					cod_concepto, 
					mto_concepto,
					id_mov_reas, 
					id_relacionado,
					id_reas_caract_ancon,
					id_mov_reas_ancon,
					id_relacionado_ancon,
					ind_actualizado)
			values	(null,    
					_tip_contrato,   
					_cod_concepto, 
					_mnto_concepto,
					null, 
					null,
					_id_reas_caract,
					_id_mov_reas,
					_id_relacionado,
					0);
		end if
	elif _tip_contrato = 'Z' then
		let _porc_comision = 0.00;
		foreach
			select porc_comis_fac,
				   porc_impuesto
			  into _porc_comision,
				   _porc_impuesto
			  from emifafac
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato   = _cod_contrato
			   and no_unidad      = _id_certificado
			   and cod_coasegur		= _cod_coasegur
			
			let _mnto_concepto = _mto_prima * (_por_part_total / 100) * (_porc_comision / 100);			
			
			if _mnto_concepto is not null and _mnto_concepto <> 0 then
				let _id_reas_caract = _id_reas_caract + 1;
				
				insert into deivid_ttcorp:reas_caract_pri(
						id_reas_caract,    
						tip_contrato,   
						cod_concepto, 
						mto_concepto,
						id_mov_reas, 
						id_relacionado,
						id_reas_caract_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon,
						ind_actualizado)
				values	(null,    
						_tip_contrato,   
						_cod_concepto, 
						_mnto_concepto,
						null, 
						null,
						_id_reas_caract,
						_id_mov_reas,
						_id_relacionado,
						0);
			end if
			
			let _mnto_concepto = 0.00;
			
			let _cod_concepto = 55;--Impuesto
			let _mnto_concepto = _mto_prima * (_por_part_total / 100) * (_porc_impuesto / 100);
			
			if _mnto_concepto is not null and _mnto_concepto <> 0 then
				let _id_reas_caract = _id_reas_caract + 1;
				
				insert into deivid_ttcorp:reas_caract_pri(
						id_reas_caract,    
						tip_contrato,   
						cod_concepto, 
						mto_concepto,
						id_mov_reas, 
						id_relacionado,
						id_reas_caract_ancon,
						id_mov_reas_ancon,
						id_relacionado_ancon,
						ind_actualizado)
				values	(null,    
						_tip_contrato,   
						_cod_concepto, 
						_mnto_concepto,
						null, 
						null,
						_id_reas_caract,
						_id_mov_reas,
						_id_relacionado,
						0);
			end if
		end foreach
	elif _tip_contrato = 'Y' then
	else
		let _porc_comision = 0.00;
		select porc_comision
		  into _porc_comision
		  from reacoase
		 where cod_contrato		= _cod_contrato
		   and cod_cober_reas	= _cod_cober_reas
		   and cod_coasegur		= _cod_coasegur;
		   
		let _mnto_concepto = _mto_prima * (_por_part_total / 100) * (_porc_comision / 100);
		
		if _mnto_concepto is not null and _mnto_concepto <> 0 then
			let _id_reas_caract = _id_reas_caract + 1;
			
			insert into deivid_ttcorp:reas_caract_pri(
					id_reas_caract,    
					tip_contrato,   
					cod_concepto, 
					mto_concepto,
					id_mov_reas, 
					id_relacionado,
					id_reas_caract_ancon,
					id_mov_reas_ancon,
					id_relacionado_ancon,
					ind_actualizado)
			values	(null,    
					_tip_contrato,   
					_cod_concepto, 
					_mnto_concepto,
					null, 
					null,
					_id_reas_caract,
					_id_mov_reas,
					_id_relacionado,
					0);
		end if
		
		let _cod_concepto = 55;--Impuesto
		
		select porc_impuesto
		  into _porc_impuesto
		  from reacocob
		 where cod_contrato = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;
		   
		let _mnto_concepto = _mto_prima * (_por_part_total / 100) * (_porc_impuesto / 100);
		
		if _mnto_concepto is not null and _mnto_concepto <> 0 then
			let _id_reas_caract = _id_reas_caract + 1;
			insert into deivid_ttcorp:reas_caract_pri(
					id_reas_caract,    
					tip_contrato,   
					cod_concepto, 
					mto_concepto,
					id_mov_reas, 
					id_relacionado,
					id_reas_caract_ancon,
					id_mov_reas_ancon,
					id_relacionado_ancon,
					ind_actualizado)
			values	(null,    
					_tip_contrato,   
					_cod_concepto, 
					_mnto_concepto,
					null, 
					null,
					_id_reas_caract,
					_id_mov_reas,
					_id_relacionado,
					0);
		end if
	end if
	
	--commit work;
	--end foreach
	
	let _porc_comision = 0.00;
	let _porc_impuesto = 0.00;	
	let _mnto_concepto = 0.00;
	
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure;