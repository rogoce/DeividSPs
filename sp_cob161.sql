-- Procedimiento que trae los detalles para el cte. seleccionado.

-- Creado    : 7/04/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob161;

create procedure sp_cob161(a_numero char(10))
returning char(10),  --numero
		  smallint,	 --renglon
		  char(10),	 --noremesa
		  char(4),	 --sec
		  char(20),	 --poliza
	      char(80),	 --cte
		  DEC(16,2), --montocobrado
	      date,		 --fechadepago
		  DEC(16,2), --netopagado
	      char(6),	 --no_recibo
		  DEC(9,2),  --porc_comis
		  DEC(16,2), --montocomis
		  DEC(16,2), --comis_desc
		  DEC(16,2), --comis_cobro
		  DEC(16,2), --comis_visa
		  DEC(16,2), --comis_clave
		  DEC(16,2), --bruto por remesar
		  char(5),
		  dec(16,2);

define _cliente		    	char(80);
define _nombre_agente		char(50);
define _subramo_nom			char(50);
define _ramo_nom			char(50);
define _no_documento	   	char(20);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _usuario		    	char(10);
define _numero		    	char(10);
define _periodo				char(7);
define _peri				char(7);
define _no_recibo	    	char(6);
define _no_cheque	    	char(6);
define _cod_agente			char(5);
define _error_desc			char(5);
define _secuencia	    	char(4);
define _ano_char			char(4);
define _cod_subramo	    	char(3);
define _mes_char        	char(2);
define _gestion				char(1);
define _char1				char(1);
define _monto_cobrado		dec(16,2);
define _neto_pagado			dec(16,2);
define _monto_total			dec(16,2);
define _monto_comis			dec(16,2);
define _comis_desc			dec(16,2);
define _monto_comis_cobro	dec(16,2);
define _monto_comis_visa	dec(16,2);
define _monto_comis_clave	dec(16,2);
define _monto_bruto			dec(16,2);
define _gasto_manejo		dec(16,2);
define _porc_comis			dec(9,2);
define _len_no_documento	smallint;
define _estatus_poliza  	smallint;
define _error_poliza		smallint;
define _ramo_sis			smallint;
define _renglon				smallint;
define _tipo_formato		smallint;
define _fecha_adicion 		date;
define _periodo_desde 		date;
define _periodo_hasta 		date;
define _fecha_remesa 		date;
define _fecha_pago   		date;


set isolation to dirty read;

--set debug file to "sp_cob161.trc";
--trace on;


select tipo_formato,
	   cod_agente
  into _tipo_formato,
	   _cod_agente
  from cobpaex0
 where numero = a_numero;

foreach

 select renglon,
		no_remesa,
		secuencia,
		no_documento,
		cliente,
		monto_cobrado,
		fecha_pago,
		neto_pagado,
		no_recibo,
		porc_comis,
		monto_comis,
		comis_desc,
		comis_cobro,
		comis_visa,
		comis_clave,
		monto_bruto,
		error,
		gasto_manejo
   into	_renglon,
		_no_remesa,
		_secuencia,
		_no_documento,
		_cliente,
		_monto_cobrado,
		_fecha_pago,
		_neto_pagado,
		_no_recibo,
		_porc_comis,
		_monto_comis,
		_comis_desc,
		_monto_comis_cobro,
		_monto_comis_visa,
		_monto_comis_clave,
		_monto_bruto,
		_error_poliza,
		_gasto_manejo
   from cobpaex1
  where numero = a_numero  

	if _error_poliza = 1 then
		let _error_desc = "SUSP";

		if _tipo_formato = 3 then
			call sp_sis160(_no_documento) returning _no_documento;
			call sp_sis21(_no_documento) returning _no_poliza;
			if _no_poliza is not null then
				let _error_desc = "";
			end if
		end if
	else
		let _error_desc = "";
	end if

	return a_numero,
	       _renglon,
		   _no_remesa,
		   _secuencia,
		   _no_documento,
		   _cliente,
		   _monto_cobrado,
		   _fecha_pago,
		   _neto_pagado,
		   _no_recibo,
		   _porc_comis,
		   _monto_comis,
		   _comis_desc,
		   _monto_comis_cobro,
		   _monto_comis_visa,
		   _monto_comis_clave,
		   _monto_bruto,
		   _error_desc,
		   _gasto_manejo
		   with resume;

end foreach

end procedure