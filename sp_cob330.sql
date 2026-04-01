-- Procedimiento que carga los pagos diarios de un corredor
-- Creado    : 06/05/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_cob330('00035', '01/06/2017')

drop procedure sp_cob330;
create procedure sp_cob330(a_cod_agente char(5), a_fecha date)
returning integer,
	      char(100);

define _nom_cliente			varchar(100);
define _nom_formapag		varchar(100);
define _error_desc			varchar(100);
define _desc_tipo_pago		varchar(50);
define _no_documento	   	char(20);
define _cod_pagador			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_recibo	    	char(10);
define _no_cheque	    	char(6);
define _cod_formapag		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_ramo			char(3);
define _monto				dec(16,2);
define _saldo				dec(16,2);
define _cnt_existe			smallint;
define _secuencia			smallint;
define _cnt_paex			smallint;
define _renglon				smallint;
define _cnt_agt				smallint;
define _cia					smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final 		date;
define _vigencia_inic 		date;
define _fecha_control 		date;
define _fecha_remesa 		date;
define _fecha_reg	 		datetime year to second;

set isolation to dirty read;

--set debug file to "sp_cob330.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
	let _error_desc = _error_desc || trim(_no_remesa);
	return _error,_error_desc;
end exception

let _cia = 7; --código dado por ducruet
let _cod_compania = '001';
let _cod_sucursal = '001';
let _fecha_control = a_fecha;
let _fecha_reg = current;

select nvl(max(secuencia),0)
  into _secuencia
  from deivid_cob:cobpagt
 where fecha_pago = _fecha_control;

let _secuencia = _secuencia + 1;

foreach
	select no_remesa,
		   fecha
	  into _no_remesa,
		   _fecha_remesa
	  from cobremae
	 where date_posteo >= a_fecha
	   and actualizado = 1
	 order by fecha,no_remesa

	select count(*)
	  into _cnt_paex
	  from cobpaex0
	 where no_remesa_ancon = _no_remesa
	   and cod_agente = a_cod_agente;

	if _cnt_paex > 0 then --Excluye los pagos de pagos externos
		continue foreach;
	end if

	--Este control solo va cuando se van a cargar mas de un día a la vez
	{if _fecha_remesa <> _fecha_control then
		let _secuencia = 1;
		let _fecha_control = _fecha_remesa;
	end if}

	foreach
		select d.renglon,
			   d.no_recibo,
			   d.no_poliza,
			   d.monto
		  into _renglon,
			   _no_recibo,
			   _no_poliza,
			   _monto
		  from cobredet d, cobreagt a
		 where d.no_remesa = a.no_remesa
		   and d.renglon = a.renglon
		   and a.cod_agente = a_cod_agente
		   and d.no_remesa = _no_remesa
		   and tipo_mov	 in ('P','N')
		 order by 1

		select nvl(count(*),0)
		  into _cnt_existe
		  from deivid_cob:cobpagt
		 where no_remesa = _no_remesa
		   and renglon = _renglon;

		if _cnt_existe <> 0 then	
			continue foreach;
		end if

		select nvl(count(*),0)
		  into _cnt_agt
		  from emipoagt
		 where no_poliza  = _no_poliza
		   and cod_agente = a_cod_agente;

		if _cnt_agt = 0 then  --solo del agente seleccionado
			continue foreach;
		end if

		select no_documento,
			   vigencia_inic,
			   vigencia_final,
			   cod_ramo,
			   cod_pagador,
			   cod_formapag
		  into _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _cod_pagador,
			   _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		select count(*)  
		  into _cnt_existe 
	      from deivid_cob:duc_cob 
	     where trim(poliza) = trim(_no_documento)
		   and no_remesa = _no_remesa
           --and fecha_procesado = _fecha_remesa  
		   --and procesado = 1
           and pago_a is not null;
		   
		   	if _cnt_existe is null then
		       let _cnt_existe = 0;			   
	       end if
		   
		    if _cnt_existe <> 0 then	
			   continue foreach;
		   end if		   

		select nombre
		  into _desc_tipo_pago
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;

		call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento, '') returning _saldo;

		insert into deivid_cob:cobpagt
				(cod_agente,
				cia,
				secuencia,
				fecha_reg,
				fecha_pago,
				no_documento,
				vigencia_inic,
				vigencia_final,
				cod_cliente,
				nombre_cliente,
				monto_pagado,
				forma_pago,
				no_remesa,
				no_recibo,
				renglon,
				no_poliza,
				saldo)
		values(	a_cod_agente,
				_cia,				
				_secuencia,
				_fecha_reg,
				_fecha_remesa,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_cod_pagador,
				_nom_cliente,
				_monto,
				_desc_tipo_pago,
				_no_remesa,
				_no_recibo,
				_renglon,
				_no_poliza,
				_saldo);

		let _secuencia = _secuencia + 1;
	end foreach	
end foreach

return 0,'Actualización Exitosa';
end 
end procedure;