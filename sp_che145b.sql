-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che145b;
create procedure sp_che145b(a_cod_agente char(5))
returning	smallint,varchar(50);

define _nom_cliente			varchar(50);
define _nom_agente			varchar(50);
define _no_recibo			varchar(10);
define _no_doc_verif		char(20);
define _no_documento		char(20);
define _no_poliza_aseg		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _tipo_mov			char(1);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_pagada		dec(16,2);
define _comis_devengada		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_suscrita		dec(16,2);
define _comision_saldo		dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_neta_h		dec(16,2);
define _comis_saldo			dec(16,2);
define _prima_neta			dec(16,2);
define _adelanto_comis		smallint;
define _cnt_cobadeco		smallint;
define _max_no_pagos		smallint;
define _flag				smallint;
define _cant_pagos			smallint;
define _fecha_adelanto		date;
define _fecha_inicio		date;
define _fecha_cobro			date;
define _cod_endomov         char(3);
define _desc_p_p            smallint;
define _vigencia_inic       date;
define _vigencia_final      date;

set isolation to dirty read;

--set debug file to "sp_che145b.trc";	 																						 
--trace on;

create temp table tmp_det(
	nom_agente		varchar(50),
	no_pagos		smallint,
	no_documento	char(20),
	prima_neta		dec(16,2),
	prima_neta_h	dec(16,2),
	no_recibo		varchar(10),
	date_added		date,
	prima_bruta		dec(16,2),
	prima_neta_cob	dec(16,2),
	porc_partic_agt	dec(5,2),
	porc_comis_agt	dec(5,2),
	comis_pagada	dec(16,2),
	comis_devengada	dec(16,2),
	tipo_mov		char(1),
	nom_cliente		varchar(50),
	desc_p_p        smallint,
	vigencia_inic   date,
	vigencia_final  date) with no log;
create index idx1_tmp_det on tmp_det(no_documento);
create index idx2_tmp_det on tmp_det(date_added);

select trim(nombre),
	   max_no_pagos
  into _nom_agente,
	   _max_no_pagos
  from agtagent
 where cod_agente = a_cod_agente;

let _no_doc_verif = '';
let _comis_saldo = 0.00;

{select *
  from chqcomis
 where cod_agente = a_cod_agente
  into temp tmp_chqcomis;}

foreach
	select distinct no_documento
	  into _no_documento
	  from chqcomis
	 where cod_agente = a_cod_agente
	   --and no_documento in ('0214-00486-01','0213-02927-01')
	   and anticipo_comis = 1

	let _cnt_cobadeco = 0;
    let _desc_p_p = 0;
  
	select count(*)
	  into _cnt_cobadeco
	  from cobadeco
	 where no_documento = _no_documento;

	if _cnt_cobadeco is null then
		let _cnt_cobadeco = 0;
	end if

	let _prima_neta = 0.00;
	let _prima_neta_h = 0.00;
	
	if _cnt_cobadeco <> 0 then
		--continue foreach;
		select prima_neta
		  into _prima_neta
		  from cobadeco
		 where no_documento = _no_documento;
		
		select sum(prima_neta)
		  into _prima_neta_h
		  from cobadecoh
		 where no_documento = _no_documento;
		
		if _prima_neta_h is null then
			let _prima_neta_h = 0.00;
		end if
	else
		select count(*)
		  into _cnt_cobadeco
		  from cobadecoh
		 where no_documento = _no_documento;
		
		if _cnt_cobadeco is null then
			let _cnt_cobadeco = 0;
		end if
		
		if _cnt_cobadeco <> 0 then
			select sum(prima_neta)
			  into _prima_neta
			  from cobadecoh
			 where no_documento = _no_documento;
		else	 
			select count(*)
			  into _cnt_cobadeco
			  from cobadeco_2019
			 where no_documento = _no_documento;
			
			if _cnt_cobadeco is null then
				let _cnt_cobadeco = 0;
			end if
			
			if _cnt_cobadeco <> 0 then
				select sum(prima_neta)
				  into _prima_neta
				  from cobadeco_2019
				 where no_documento = _no_documento;
			else
				select count(*)
				  into _cnt_cobadeco
				  from cobadeco_2020
				 where no_documento = _no_documento;
				
				if _cnt_cobadeco is null then
					let _cnt_cobadeco = 0;
				end if
				
				if _cnt_cobadeco <> 0 then
					select sum(prima_neta)
					  into _prima_neta
					  from cobadeco_2020
					 where no_documento = _no_documento;
				end if	 			
			end if	 
		end if
	end if

	if _prima_neta is null then
		let _prima_neta = 0.00;
	end if

	select min(fecha)
	  into _fecha_adelanto
	  from chqcomis
	 where cod_agente = a_cod_agente
	   and no_documento = _no_documento
	   and anticipo_comis = 1;

	let _adelanto_comis = 0;
	
	call sp_sis21(_no_documento) returning _no_poliza_aseg;
	
	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza_aseg;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	
	foreach
		select no_poliza,
			   fecha,
			   comision,
			   monto_danos + monto_vida,
			   monto,
			   prima,
			   porc_comis,
			   porc_partic,
			   anticipo_comis,
			   no_recibo
		  into _no_poliza,
			   _fecha_cobro,
			   _comision_pagada,
			   _comis_devengada,
			   _monto_cobrado,
			   _prima_neta_cob,
			   _porc_comis_agt,
			   _porc_partic_agt,
			   _adelanto_comis,
			   _no_recibo
		  from chqcomis
		 where cod_agente = a_cod_agente
		   and no_documento = _no_documento
		   and fecha >= _fecha_adelanto
		 order by fecha
		
		
		if a_cod_agente = '00226' and _no_recibo = 'ContAdeco' then
			continue foreach;
		end if
		
		if _adelanto_comis = 0 and _no_poliza <> '00000' then
			continue foreach;
		end if
		
		let _desc_p_p = 0;	
    
		if _no_poliza = '00000' and _no_recibo <> 'ContAdeco' then
			select cod_endomov,
			       no_poliza
			  into _cod_endomov,
			       _no_poliza
			  from endedmae
			 where no_factura = _no_recibo;
			 
			let _comis_devengada = 0.00;
			 
			 --if _cod_endomov not in ('024','025') then
			--	let _desc_p_p = 0;
			-- else
				let _desc_p_p = 1;
			-- end if
		end if
		
		select vigencia_inic,
		       vigencia_final
		  into _vigencia_inic,
		       _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;
		   
		insert into tmp_det
		values(	_nom_agente,
				_max_no_pagos,
				_no_documento,
				_prima_neta,
				_prima_neta_h,
				_no_recibo,
				_fecha_cobro,
				_monto_cobrado,
				_prima_neta_cob,
				_porc_partic_agt,
				_porc_comis_agt,
				_comision_pagada,
				_comis_devengada,
				'C',
				_nom_cliente,
				_desc_p_p,
				_vigencia_inic,
				_vigencia_final);
	end foreach

	let _comision_pagada = 0.00;
	
	if a_cod_agente = '00226' then
		foreach
			select no_poliza,
				   no_recibo,
				   fecha,
				   monto,
				   prima_neta
			  into _no_poliza,
				   _no_recibo,
				   _fecha_cobro,
				   _monto_cobrado,
				   _prima_neta_cob
			  from cobredet
			 where no_remesa = '855696'
			   and doc_remesa = _no_documento
			   and tipo_mov = 'C'
			   and no_recibo = 'ContAdeco'
			
			call sp_sis21(_no_documento) returning _no_poliza;
			
			select porc_partic_agt,
				   porc_comis_agt
			  into _porc_partic_agt,
				   _porc_comis_agt
			  from emipoagt
			 where no_poliza = _no_poliza
			   and cod_agente = a_cod_agente;
			
			let _comis_devengada = _monto_cobrado;
			let _comision_pagada = _comis_devengada;
			let _comis_devengada = 0.00;
			--let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;

			select vigencia_inic,
				   vigencia_final
			  into _vigencia_inic,
				   _vigencia_final
			  from emipomae
			 where no_poliza = _no_poliza;
			
			insert into tmp_det
			values(	_nom_agente,
					_max_no_pagos,
					_no_documento,
					_prima_neta,
					_prima_neta_h,
					_no_recibo,
					_fecha_cobro,
					_monto_cobrado,
					_prima_neta_cob,
					_porc_partic_agt,
					_porc_comis_agt,
					_comision_pagada,
					_comis_devengada,
					'C',
					_nom_cliente,
					_desc_p_p,
					_vigencia_inic,
					_vigencia_final);
		end foreach
	else	
	{	foreach
			select no_poliza,
				   no_endoso,
				   no_factura,
				   date_added,
				   prima_neta,
				   prima_bruta
			  into _no_poliza,
				   _no_endoso,
				   _no_recibo,
				   _fecha_cobro,
				   _prima_neta_cob,
				   _monto_cobrado
			  from endedmae
			 where no_documento = _no_documento
			   and cod_endomov in ('024','025')
			   and date_added >= _fecha_adelanto
			   and actualizado = 1

			select porc_partic_agt,
				   porc_comis_agt
			  into _porc_partic_agt,
				   _porc_comis_agt
			  from endmoage
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and cod_agente = a_cod_agente;

			if _porc_partic_agt is null or _porc_comis_agt is null then
				select porc_partic_agt,
					   porc_comis_agt
				  into _porc_partic_agt,
					   _porc_comis_agt
				  from emipoagt
				 where no_poliza = _no_poliza
				   and cod_agente = a_cod_agente;
			end if

			let _comis_devengada = _prima_neta_cob * (_porc_partic_agt/100) * (_porc_comis_agt/100);
			let _comision_pagada = _comis_devengada;
			let _comis_devengada = 0.00;
			--let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;
			
			insert into tmp_det
			values(	_nom_agente,
					_max_no_pagos,
					_no_documento,
					_prima_neta,
					_prima_neta_h,
					_no_recibo,
					_fecha_cobro,
					_monto_cobrado,
					_prima_neta_cob,
					_porc_partic_agt,
					_porc_comis_agt,
					_comision_pagada,
					_comis_devengada,
					'P',
					_nom_cliente);
		end foreach}
	end if
end foreach

return 0,'Carga Exitosa';
end procedure;