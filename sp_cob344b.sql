-- Procedure que genera el reporte de Movimientos de Prima y Comisión de Ducruet
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob344b;
create procedure sp_cob344b(a_compania char(3), a_fecha_genera date)
returning	date			as Fecha_Desde,					--_fecha_desde
			date			as Fecha_Hasta,					--_fecha_hasta
			char(10)		as Remesa_Ancon,				--_no_remesa
			smallint		as Renglon,						--_renglon
			char(10)		as Remesa_Ducruet,				--_no_remesa_duc,
			char(5)			as Secuencia,					--_secuencia,
			char(20)		as Poliza,						--_no_documento,
			varchar(100)	as Cliente,						--_nom_cliente,
			char(10)		as Recibo,						--_no_recibo,
			dec(16,2)		as Monto,						--_monto_desc
			char(10)		as Remesa_Supenso,				--_no_remesa_susp
			date			as Fecha_Aplicacion_Suspenso,	--_date_posteo
			varchar(50)		as Compania;					--_nombre_cia

define _nom_cliente			varchar(100);
define _desc_remesa			varchar(100);
define _ruc					varchar(100);
define _nombre_cia			varchar(50);
define _error_desc			char(50);
define _no_documento_susp	char(20);
define _no_documento		char(20);
define _no_remesa_susp		char(10);
define _no_recibo_susp		char(10);
define _no_remesa_duc		char(10);
define _no_recibo			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _secuencia			char(5);
define _tipo_mov			char(1);
define _comis_desc_tot		dec(16,2);
define _monto_desc			dec(16,2);
define _cnt_susp			smallint;
define _renglon				smallint;
define _date_posteo			date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return '01/01/1900','01/01/1900',_no_remesa,_error,'','','', _error_desc,'',0.00,'','01/01/1900','';
end exception

--set debug file to "sp_cob344.trc";
--trace on;

let _nombre_cia = trim(sp_sis01(a_compania));

foreach
	select fecha_desde,
		   fecha_hasta,
		   no_documento,
		   sum(comision)
	  into _fecha_desde,
		   _fecha_hasta,
		   _ruc,
		   _comis_desc_tot
	  from chqcomis
	 where cod_agente = '00035'
	   and fecha_genera = a_fecha_genera
	   and no_poliza = '00000'
	   and comision <> 0
	 group by 1,2,3
	 order by 1

	foreach
		select d.no_remesa,
			   d.renglon,
			   d.monto,
			   doc_remesa,
			   tipo_mov,
			   desc_remesa
		  into _no_remesa,
			   _renglon,
			   _monto_desc,
			   _no_documento_susp,
			   _tipo_mov,
			   _desc_remesa
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.doc_remesa = _ruc
		   and m.fecha between _fecha_desde and _fecha_hasta
		   and m.actualizado = 1

		if _monto_desc = 0.00 then
			continue foreach;
		end if

		{select doc_remesa,
			   tipo_mov,
			   desc_remesa
		  into _no_documento_susp,
			   _tipo_mov,
			   _desc_remesa
		  from cobredet
		 where no_remesa = _no_remesa ;
		   --and renglon = _renglon - 1;}
		
		let _no_remesa_susp = '';
		let _no_remesa_duc = '';
		let _no_documento = '';
		let _nom_cliente = '';
		let _date_posteo = '01/01/1900';
		let _no_recibo = '';
		let _secuencia = '';
		
		if _tipo_mov = 'E' then
			let _no_poliza = '';

			call sp_sis21(_no_documento_susp) returning _no_poliza;
			
			if _no_poliza is null or _no_poliza = '' then
				foreach
					select m.no_remesa,
						   d.secuencia,
						   d.no_documento,
						   d.cliente,
						   d.no_recibo
					  into _no_remesa_duc,
						   _secuencia,
						   _no_documento,
						   _nom_cliente,
						   _no_recibo
					  from cobpaex0 m, cobpaex1 d
					 where m.numero = d.numero
					   and m.no_remesa_ancon = _no_remesa
					   and d.monto_comis = _monto_desc * -1
					   and _desc_remesa like '%' || d.cliente || '%'
					   and error = 1
					exit foreach;
				end foreach
			else
				let _no_documento = _no_documento_susp;
				let _nom_cliente = _desc_remesa;

				foreach
					select m.no_remesa,
						   d.secuencia,
						   d.no_documento,
						   d.cliente,
						   d.no_recibo
					  into _no_remesa_duc,
						   _secuencia,
						   _no_documento,
						   _nom_cliente,
						   _no_recibo
					  from cobpaex0 m, cobpaex1 d
					 where m.numero = d.numero
					   and m.no_remesa_ancon = _no_remesa
					   and d.no_documento = _no_documento_susp
					   and _desc_remesa like '%' || d.cliente || '%'
					   and error = 1
					exit foreach;
				end foreach					
			end if

			let _no_recibo_susp = '';

			foreach
				select m.no_remesa,
					   d.no_recibo,
					   m.fecha
				  into _no_remesa_susp,
					   _no_recibo_susp,
					   _date_posteo					   
				  from cobremae m, cobredet d
				 where m.no_remesa = d.no_remesa
				   and d.doc_remesa = _no_documento_susp
				   and d.tipo_mov = 'A'
				   and m.actualizado = 1

				select count(*)
				  into _cnt_susp
				  from cobredet
				 where no_remesa = _no_remesa_susp
				   and no_recibo = _no_recibo_susp
				   and doc_remesa = _no_documento
				   and tipo_mov = 'P';
				
				if _cnt_susp is not null and _cnt_susp > 0 then
					exit foreach;
				end if
			end foreach
       else 
		   if _tipo_mov = 'C' then
					let _no_poliza = '';

					call sp_sis21(_no_documento_susp) returning _no_poliza;
					
					if _no_poliza is null or _no_poliza = '' then
						foreach
							select m.no_remesa,
								   d.secuencia,
								   d.no_documento,
								   d.cliente,
								   d.no_recibo
							  into _no_remesa_duc,
								   _secuencia,
								   _no_documento,
								   _nom_cliente,
								   _no_recibo
							  from cobpaex0 m, cobpaex1 d
							 where m.numero = d.numero
							   and  m.no_remesa_ancon = _no_remesa
							   and d.neto_pagado = _monto_desc * 1
							   --and _desc_remesa like '%' || d.cliente || '%'
							   --and error = 1
							exit foreach;
						end foreach
					else
						let _no_documento = _no_documento_susp;
						let _nom_cliente = _desc_remesa;

						foreach
							select m.no_remesa,
								   d.secuencia,
								   d.no_documento,
								   d.cliente,
								   d.no_recibo
							  into _no_remesa_duc,
								   _secuencia,
								   _no_documento,
								   _nom_cliente,
								   _no_recibo
							  from cobpaex0 m, cobpaex1 d
							 where m.numero = d.numero
							   and m.no_remesa_ancon = _no_remesa
							   --and d.no_documento = _no_documento_susp
							    and d.neto_pagado = _monto_desc * 1							   
							   --and _desc_remesa like '%' || d.cliente || '%'
							   --and error = 1
							exit foreach;
						end foreach					
					end if

					let _no_recibo_susp = '';

					foreach
						select m.no_remesa,
							   d.no_recibo,
							   m.fecha
						  into _no_remesa_susp,
							   _no_recibo_susp,
							   _date_posteo					   
						  from cobremae m, cobredet d
						 where m.no_remesa = d.no_remesa
						   and d.doc_remesa = _no_documento_susp
						   and d.tipo_mov = 'A'
						   and m.actualizado = 1

						select count(*)
						  into _cnt_susp
						  from cobredet
						 where no_remesa = _no_remesa_susp
						   and no_recibo = _no_recibo_susp
						   and doc_remesa = _no_documento
						   and tipo_mov = 'P';
						
						if _cnt_susp is not null and _cnt_susp > 0 then
							exit foreach;
						end if
					end foreach		   
		   
		   end if
			
		end if
		
		return	_fecha_desde,
				_fecha_hasta,
				_no_remesa,
				_renglon,
				_no_remesa_duc,
				_secuencia,
				_no_documento,
				_nom_cliente,
				_no_recibo,
				_monto_desc,
				_no_remesa_susp,
				_date_posteo,
				_nombre_cia		with resume;
	end foreach
end foreach

end
end procedure;