--Data
--Armando Moreno M.
--execute procedure sp_super28('2025-01','2025-06')

DROP procedure sp_super28;
CREATE procedure sp_super28(a_periodo_desde char(7), a_periodo_hasta char(7))

RETURNING	char(20)		as poliza,
			char(18)		as reclamo, 
			date			as fecha_ocurrencia, 
			date			as fecha_reclamo,
			char(3)		as cod_ramo, 
			char(50)		as ramo, 
			char(3)		as cod_subramo, 
			char(50)		as subramo, 
			char(1)		as nueva_renov, 
			dec(16,2)		as reserva_periodo, 
			dec(16,2)		as estimado, 
			dec(16,2)		as reserva_inicial, 
			char(5)		as cod_cobertura, 
			char(50)		as cobertura, 
			char(5)		as no_unidad, 
			date			as fecha_ult_estatus,
			char(9)		as estatus_reclamo, 
			varchar(30)	as estatus_rec, 
			char(50)		as motivo_declinacion, 
			date			as fecha_cierre,
			dec(16,2)		as monto_pagado;

define _filtro					varchar(255);
define _motivo_declinacion	varchar(50);
define _n_cobertura			varchar(50);
define _n_subramo				varchar(50);
define _n_evento				varchar(50);
define _n_ramo					varchar(50);
define _estatus_rec			varchar(30);
define _no_documento			char(20);
define _numrecla				char(18);
define _no_reclamo			char(10);
define _no_poliza				char(10);
define _estatus_reclamo		char(9);
define _cod_cobertura			char(5);
define _no_unidad				char(5);
define _cod_subramo			char(3);
define _cod_evento			char(3);
define _cod_ramo				char(3);
define _nueva_renov			char(1);
define _estatus_audiencia	smallint;
define _deducible_devuel		dec(16,2);
define _deducible_pagado		dec(16,2);
define _reserva_inicial		dec(16,2);
define _reserva_actual		dec(16,2);
define _reserva_bruta			dec(16,2);
define _monto_pagado			dec(16,2);
define _salvamento			dec(16,2);
define _deducible				dec(16,2);
define _estimado2				dec(16,2);
define _estimado				dec(16,2);
define _recupero				dec(16,2);
define _pagos2					dec(16,2);
define _pagos					dec(16,2);
define _cnt_casco				smallint;
define _cnt_trx				smallint;
define _fecha_ult_status		date;
define _fecha_siniestro		date;
define _fecha_reclamo			date;
define _fecha_cierre			date;
define _fecha_desde			date;
define _fecha_hasta			date;

let _pagos = 0.00;
let _motivo_declinacion = '';

set isolation to dirty read;


/*let _filtro = sp_rec02('001','001','2024-12',"*","*","*","*","*");

select *
  from tmp_sinis
 where reserva_bruto > 0
   and seleccionado = 1
  into temp tmp_sinis202412;
*/
drop table if exists tmp_sinis;
drop table if exists tmp_SinisTrim;

let _filtro = sp_rec02_cob('001','001',a_periodo_hasta,"*","*","*","*","*");

select *
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_SinisTrim;

drop table if exists tmp_sinis;

let _filtro = sp_rec704_cob('001','001',a_periodo_desde,a_periodo_hasta,"*","*","*","*","*","*","*","*");

let _fecha_desde = mdy(1,1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

--set debug file to "sp_super28.trc";
--trace on; 

foreach
	select no_reclamo
	  into _no_reclamo
	  from (select no_reclamo
			   from deivid_bo:recrespe 
			  where periodo = '2024-12'		
			
			union
			
			select no_reclamo
			  from recrcmae
			 where fecha_reclamo >= _fecha_desde
			   and fecha_reclamo <= _fecha_hasta
			   and actualizado = 1			
			) TmpSinisTrim
	 /*where  no_reclamo in ('641023',
'641163',
'641796',
'642918',
'643384',
'643402',
'646468')
*/
	 order by no_reclamo

	select rec.no_documento,
			rec.numrecla,
			rec.no_poliza,
			rec.no_unidad,
			decode(rec.estatus_reclamo,"A","ABIERTO","C","CERRADO","D","DECLINADO","N","NO APLICA"),
			rec.fecha_reclamo,
			rec.fecha_siniestro,
			rec.cod_evento,
			rec.no_reclamo,
			rec.estatus_audiencia,
			emi.cod_ramo,
		    emi.cod_subramo,
			ram.nombre,
			sub.nombre,
			emi.nueva_renov
	   into _no_documento,
			_numrecla,
			_no_poliza,
			_no_unidad,
			_estatus_reclamo,
			_fecha_reclamo,
			_fecha_siniestro,
			_cod_evento,
			_no_reclamo,
			_estatus_audiencia,
			_cod_ramo,
		    _cod_subramo,
			_n_ramo,
			_n_subramo,
			_nueva_renov
       from recrcmae rec
	  inner join emipomae emi on emi.no_poliza = rec.no_poliza and emi.cod_tipoprod != '002'
	  inner join prdramo ram on ram.cod_ramo = emi.cod_ramo 
	  inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo	 
	  where rec.no_reclamo = _no_reclamo;

	/*
	select rec.no_documento,
		   rec.numrecla,
		   rec.no_poliza,
		   rec.no_unidad,
		   decode(rec.estatus_reclamo,"A","ABIERTO","C","CERRADO","D","DECLINADO","N","NO APLICA"),
		   rec.fecha_reclamo,
		   rec.fecha_siniestro,
		   rec.cod_evento,
		   rec.no_reclamo,
		   tmp.reserva_bruto
	  into _no_documento,
	       _numrecla,
		   _no_poliza,
		   _no_unidad,
		   _estatus_reclamo,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _cod_evento,
		   _no_reclamo,
		   _reserva_bruta
      from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo
	 where seleccionado = 1

	let _fecha_ult_status = '01/01/1900';
	let _fecha_cierre = '01/01/1900';

	if _estatus_reclamo = 'CERRADO' then
		select max(fecha)
		  into _fecha_cierre
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and (cod_tipotran = '011' or cerrar_rec = 1)
		   and periodo <= a_periodo_hasta
		   and actualizado = 1;

		if _fecha_cierre is null then
			let _fecha_cierre = '01/01/1900';
		end if
		
		let _fecha_ult_status = _fecha_cierre;
		
		if _fecha_ult_status < _fecha_desde then
			let _fecha_ult_status = '01/01/1900';
		end if
	end if
	
	if _fecha_ult_status = '01/01/1900' then
		let _fecha_ult_status = '01/01/1900';
	end if
	
	if _fecha_ult_status = '01/01/1900' then	
		select max(fecha)
		  into _fecha_ult_status
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1
		   and periodo <= a_periodo_hasta;

		let _estatus_reclamo = 'ABIERTO';
	end if
	
	*/
--trace on; 

	let _cnt_casco = 0;

	if _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_casco
		  from emipocob emi
		 inner join prdcober cob on cob.cod_cobertura = emi.cod_cobertura
		 where emi.no_poliza = _no_poliza
		   and cob.cod_cober_reas in ('031','034');

		if _cnt_casco is null then
			let _cnt_casco = 0;
		end if
		
		if _cnt_casco = 0 then
			let _n_subramo = 'DAÑOS A TERCEROS';
		else
			let _n_subramo = 'COBERTURA COMPLETA';
		end if		
	elif _cod_ramo in ('020') then
		let _n_subramo = 'SOAT';
	end if

	foreach
		select rco.cod_cobertura,
			    cob.nombre,
				rco.estimado
		  into _cod_cobertura,
			   _n_cobertura,
			   _estimado
		  from recrccob rco
		 inner join prdcober cob on rco.cod_cobertura = cob.cod_cobertura
		 where no_reclamo = _no_reclamo

		let _reserva_inicial = 0.00;
		
		foreach
			select tco.monto
			  into _reserva_inicial
			  from  rectrmae trx
			 inner join rectrcob tco on trx.no_tranrec = tco.no_tranrec
			 where trx.no_reclamo = _no_reclamo
			   and tco.cod_cobertura = _cod_cobertura
			   and trx.cod_tipotran in ('002')
			   and tco.monto > 0
			   and trx.actualizado = 1
			 order by trx.fecha,tco.no_tranrec

			exit foreach;			
		end foreach
		
		if _reserva_inicial is null then
			let _reserva_inicial = 0.00;
		end if
		
		if _reserva_inicial = 0.00 then
			foreach
				select tco.monto
				  into _reserva_inicial
				  from  rectrmae trx
				 inner join rectrcob tco on trx.no_tranrec = tco.no_tranrec
				 where trx.no_reclamo = _no_reclamo
				   and tco.cod_cobertura = _cod_cobertura
				   and trx.cod_tipotran in ('004','001','012')
				   and tco.monto > 0
				   and trx.actualizado = 1
				 order by trx.fecha,tco.no_tranrec

				exit foreach;			
			end foreach
		end if
		
		if _reserva_inicial is null then
			let _reserva_inicial = 0.00;
		end if
		
		let _monto_pagado = 0.00;
		let _reserva_actual = 0.00;
		let _fecha_ult_status = '01/01/1900';
		let _fecha_cierre = '01/01/1900';
		 
		select pagado_bruto
		  into _monto_pagado
		  from tmp_sinis
		 where no_reclamo = _no_reclamo
		   and cod_cobertura = _cod_cobertura;

		select reserva_bruto
		  into _reserva_actual
		  from tmp_SinisTrim
		 where no_reclamo = _no_reclamo
		   and cod_cobertura = _cod_cobertura;

		let _estatus_rec = '';
		let _cnt_trx = 0;
		
		if _monto_pagado is null then
			let _monto_pagado = 0.00;
		end if
		
		if _reserva_actual is null then
			let _reserva_actual = 0.00;
		end if
		
		if _fecha_ult_status is null then
			let _fecha_ult_status = '01/01/1900';
		end if
		
		if _fecha_ult_status = '01/01/1900' then	
			select max(fecha)
			  into _fecha_ult_status
			  from rectrmae trx
			 inner join rectrcob tco on tco.no_tranrec = trx.no_tranrec
			 where trx.no_reclamo = _no_reclamo
			   and tco.cod_cobertura = _cod_cobertura
			   and trx.periodo <= a_periodo_hasta
			   and actualizado = 1;
			   --and tco.monto != 0;
		end if
		
		if _fecha_ult_status is null then
			let _fecha_ult_status = '01/01/1900';
		end if
		
		if _fecha_ult_status < _fecha_desde then
			continue foreach;
		end if

		if _estatus_audiencia in (1,7,11) then
			let _estatus_rec = 'DESISTIDO POR ASEGURADO';
		else
			if _estatus_reclamo = 'CERRADO' then
				if _monto_pagado > 0.00 then
					let _estatus_rec = 'PAGADO COMPLETO';
				else
					let _estatus_rec = 'CERRADO';					
				end if
				
				if _fecha_cierre = '01/01/1900' then
					let _fecha_cierre = _fecha_ult_status;
				end if				
			elif _estatus_reclamo = 'DECLINADO' then
				let _estatus_rec = 'DECLINADO';
				
				if _fecha_cierre = '01/01/1900' then
					let _fecha_cierre = _fecha_ult_status;
				end if	
			else
				if _monto_pagado > 0.00 then
					let _estatus_rec = 'PAGADO PARCIAL';
				else				
					select count(*)
					  into _cnt_trx
					  from rectrmae trx
					 inner join rectrcob tco on tco.no_tranrec = trx.no_tranrec
					 where trx.no_reclamo = _no_reclamo
					   and tco.cod_cobertura = _cod_cobertura
					   and trx.actualizado = 1
					   and trx.periodo <= a_periodo_hasta;
					   --and tco.variacion != 0;

					if _cnt_trx is null then
						let _cnt_trx = 0;
					end if
					
					if _cnt_trx > 1 then
						let _estatus_rec = 'APROBADO';
					else
						let _estatus_rec = 'EN TRAMITE';
					end if
				end if			
			end if
		end if
		
		if _fecha_cierre = '01/01/1900' then
			let _fecha_cierre = ''; 
		end if

		return _no_documento,				
				_numrecla,                       
				_fecha_siniestro,               
				_fecha_reclamo,                 
				_cod_ramo,                       
				_n_ramo,                         
				_cod_subramo,                   
				_n_subramo,     
				_nueva_renov,
				_reserva_actual,
				_estimado,
				_reserva_inicial,
				_cod_cobertura,                 
				_n_cobertura,                   
				_no_unidad,                      
				_fecha_ult_status,              
				_estatus_reclamo,
				_estatus_rec,
				_motivo_declinacion,
				_fecha_cierre,                  
				_monto_pagado with resume;
	end foreach
end foreach
END PROCEDURE;
