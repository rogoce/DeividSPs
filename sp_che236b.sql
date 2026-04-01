-- - Procedimiento que Genera el Archivo para las comisiones automaticas de SEMUSA

-- Creado    : 25/09/2008	- Autor: Henry Giron
-- Modificado: 13/03/2013	- Autor: Roman Gordon -- Se modifica el proceso para que tome en cuenta el proceso de adelanto de comision.
-- Modificado: 08/04/2013	- Autor: Roman Gordon -- Se modifica para que tome en cuenta la comision de SEMUSA Chitré (01853).
-- - SIS v.2.0 - sp_che05 - DEIVID, S.A.

drop procedure sp_che236b;

create procedure "informix".sp_che236b(a_no_requis char(10))

define _nombre_cliente		char(100);
define _no_documento		char(20);
define _no_remesa_ancon		char(10);
define _vigen_inic_char		char(10);
define _vigen_fin_char		char(10);
define _no_recibo_a			char(10);
define _no_registro			char(10);
define _no_licencia			char(10);
define _fecha_desde			char(10);
define _fecha_hasta			char(10);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_agente2			char(5);
define _cod_agente			char(5);
define _cod_compania		char(4);
define _ano					char(4);
define _dia					char(2);
define _mes					char(2);
define _lugar_cobro			char(1);
define _porc_comision		dec(8,5);
define _comision_adelanto	dec(16,2);
define _total_comision		dec(16,2);
define _total_descont		dec(16,2);
define _comis_descont		dec(16,2);
define _prima_pagada		dec(16,2);
define _total_prima			dec(16,2);
define _neto_pagado			dec(16,2);
define _comis_monto			dec(16,2);
define _comis_neta			dec(16,2);
define _cnt_remesa			smallint;
define _cnt_existe			smallint;
define _valor				smallint;
define _error				smallint;
define _secuencia			integer;
define _vigen_inic_date		date;
define _vigen_fin_date		date;
define _fecha               date;

--set debug file to "sp_che91.txt";
--trace on;


set isolation to dirty read;

drop table if exists tmp_cod_agentes; 
select cod_agente
  from agtagent 
 where cedula = '58790-16-342684' --Ruc Marsh Semusa
  into temp tmp_cod_agentes;

select che_reg_semusa  
  into _no_registro
  from parparam
 where cod_compania    = "001";
 
let _secuencia = 0;
let _comis_descont = 0.00;
let _lugar_cobro	= "A";


select max(secuencia)
  into _secuencia
  from checomde
 where no_registro = _no_registro;
 
if _secuencia is null then
	let _secuencia = 0;
end if
 
let _total_prima    = 0.00;
let _total_comision = 0.00;
let _total_descont  = 0.00;

foreach
	select no_documento,
		   monto,
		   prima,
		   porc_comis,
		   comision,
		   no_recibo,
		   no_poliza,
		   fecha
	  into _no_documento,
		   _prima_pagada,
		   _neto_pagado,
		   _porc_comision,
		   _comis_monto,
		   _no_recibo,
		   _no_poliza,
		   _fecha
	  from chqcomis
	 where no_requis = a_no_requis
	 order by no_recibo, no_documento

	let _no_remesa_ancon = '';

	select count(*)
	  into _cnt_remesa
	  from cobpaex0
	 where cod_agente in (select cod_agente from tmp_cod_agentes)
	   and no_recibo_ancon = _no_recibo;
	
	if _cnt_remesa is null then
		let _cnt_remesa = 0;
	end if

	if _cnt_remesa > 0 then
		foreach
			select no_remesa
			  into _no_remesa_ancon
			  from cobpaex0
			 where cod_agente in (select cod_agente from tmp_cod_agentes)
			   and no_recibo_ancon = _no_recibo
			exit foreach;
		end foreach
	end if
	
	if _no_remesa_ancon is null then
		let _no_remesa_ancon = "";
	end if

	let _secuencia = _secuencia + 1;

	if _no_poliza = "00000" then		
		let _nombre_cliente  = "COMISION DESCONTADA";
		let _vigen_inic_char = "";
		let _vigen_fin_char  = "";
	else
		select cod_contratante,
		       vigencia_inic,
			   vigencia_final
		  into _cod_cliente,
			   _vigen_inic_date,
			   _vigen_fin_date
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;

		let _vigen_inic_char = sp_sis85(_vigen_inic_date);
		let _vigen_fin_char  = sp_sis85(_vigen_fin_date);
		
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where no_documento = _no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe > 0 then
			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
			  	   _no_recibo_a
			  from cobadeco
			 where cod_agente in (select cod_agente from tmp_cod_agentes)
			   and no_documento = _no_documento;

			if _no_recibo = _no_recibo_a then
				let _comis_monto = _comision_adelanto;
			else
				let _comis_monto = 0.00;
			end if
		else
			let _cnt_existe = 0;
			select count(*)
			  into _cnt_existe
			  from cobadecoh
			 where no_documento = _no_documento 
			   and fecha >= _fecha
			   and poliza_cancelada = 1;
			   
			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if
			   
			if _cnt_existe > 0 then
				if _no_poliza <> '00000' then
					select comision_adelanto,
						   no_recibo
					  into _comision_adelanto,
						   _no_recibo_a
					  from cobadecoh
					 where cod_agente in (select cod_agente from tmp_cod_agentes)
					   and no_documento = _no_documento;
					   
					if _no_recibo = _no_recibo_a then
						let _comis_monto = _comision_adelanto;
					else
						let _comis_monto = 0.00;
					end if
				end if
			end if
		end if
		
		{if _cnt_existe > 0 then

			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
				   _no_recibo_a
			  from cobadeco
			 where cod_agente	= _cod_agente
			   and no_documento = _no_documento;
			   
			if _no_recibo_a = _no_recibo then
				let _comis_monto = _comision_adelanto;
			else			
				let _comis_monto = 0.00;
			end if
		else
			select count(*)
			  into _cnt_existe
			  from cobadecoh
			 where no_documento = _no_documento 
			   and poliza_cancelada = 1;

			if _cnt_existe > 0 then
				select comision_adelanto,
					   no_recibo
				  into _comision_adelanto,
					   _no_recibo_a
				  from cobadecoh
				 where cod_agente	= _cod_agente
				   and no_documento = _no_documento;
				   
				if _no_recibo_a = _no_recibo then
					let _comis_monto = _comision_adelanto;
				else
					let _comis_monto = 0.00;
				end if
			end if
		end if}
	end if

	let _comis_neta     = _comis_monto    - _comis_descont;
	let _total_prima    = _total_prima    + _prima_pagada;
	let _total_comision = _total_comision + _comis_monto;
	let _total_descont  = _total_descont  + _comis_descont;
	let _no_documento	= sp_che36(_no_documento); -- Cambiar Numero de poliza para Ducruet

	insert into checomde(
	no_registro,
	secuencia,
	no_documento,
	cliente,
	lugar_cobro,
	prima_pagada,
	neto_pagado,
	porc_comision,
	comis_monto,
	comis_descontada,
	comis_neta,
	no_recibo,
	no_recibo_aa,
	vigencia_inic,
	vigencia_fin	
	)
	values(
	_no_registro,
	_secuencia,
	_no_documento,
	_nombre_cliente,
	_lugar_cobro,
	_prima_pagada,
	_neto_pagado,
	_porc_comision,
	_comis_monto,
	_comis_descont,
	_comis_neta,
    _no_remesa_ancon,
	_no_recibo,
	_vigen_inic_char,
	_vigen_fin_char
	);
--	_no_recibo, se cambio a _no_remesa_ancon para colocar el numero de remesa de semusa, dato que se requiere.
end foreach

update checomen
   set total_prima		= total_prima + _total_prima,
	   total_comision	= total_comision + _total_comision,
	   total_descontada	= total_descontada + _total_descont,
	   cant_detalle     = _secuencia
 where no_registro      = _no_registro;
 
drop table if exists tmp_cod_agentes; 

end procedure;