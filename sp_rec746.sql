-- Listado de Orden de Reparación

-- Creado    : 09/05/2019 - Autor: Amado Perez M.
-- Modificado: 09/05/2019 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rec746;

CREATE PROCEDURE sp_rec746(a_fecha_1 DATE, a_fecha_2 DATE)
RETURNING CHAR(10) AS no_orden,
          CHAR(10) AS cod_taller,
		  VARCHAR(100) AS taller,
		  DATE AS fecha_orden,
          CHAR(10) AS no_tramite,
		  CHAR(18) AS reclamo,
		  DATE AS fecha_reclamo,
		  DATE AS fecha_siniestro,
		  CHAR(20) AS poliza,
		  CHAR(5) AS unidad,
		  DEC(16,2) AS suma_asegurada,
		  CHAR(10) AS cod_asegurado,
		  VARCHAR(100) AS asegurado,
		  VARCHAR(50) AS ajustador,
		  CHAR(30) AS motor,
		  CHAR(2) AS perdida,
		  DEC(16,2) AS monto_orden,
		  VARCHAR(25) AS tipo_orden,
		  INTEGER AS wf_inc_auto,
          VARCHAR(50) AS marca,
		  VARCHAR(50) AS modelo,
		  SMALLINT AS ano_auto,
		  VARCHAR(10) AS placa,
		  VARCHAR(10) AS tipo_reclamante,
		  CHAR(30) AS chasis,
		  DEC(16,2) AS monto_perdida,
		  DEC(16,2) AS ahorro,
		  CHAR(10) AS no_transaccion,
		  CHAR(10) AS requisicion,
		  DATE AS fecha_pagado;
		  

define _no_orden			CHAR(10);
define _no_reclamo			CHAR(10);
define _numrecla			CHAR(18);
define _fecha_reclamo       DATE;
define _fecha_siniestro		DATE;
define _no_documento		CHAR(20);
define _no_unidad			CHAR(5);
define _suma_asegurada		DEC(16,2);
define _cod_asegurado		CHAR(10);
define _ajust_interno		CHAR(3);
define _no_tramite			CHAR(10);
define _no_motor			CHAR(30);
define _perd_total			SMALLINT;
define _cod_taller			CHAR(10);
define _ins_tipo			SMALLINT;
define _ins_suc				CHAR(3);
define _formato_unico		SMALLINT;
define _tiene_inspeccion	SMALLINT;
define _ins_fecha			DATE;
define _fecha_orden         DATE;
define _taller              VARCHAR(100);
define _asegurado           VARCHAR(100);
define _ajustador  			VARCHAR(50);
define _perdida, _formato   CHAR(2);
define _tipo_ins            CHAR(10);
define _ins_agengia         VARCHAR(50);
define _monto               DEC(16,2);
define _tipo_orden          VARCHAR(25);
define _cod_proveedor       CHAR(10);
define _tipo_ord_comp       CHAR(1);
define _no_tranrec          CHAR(10);
define _wf_inc_auto         INTEGER;
define _marca               VARCHAR(50);
define _modelo              VARCHAR(50);
define _ano_auto            SMALLINT;
define _placa               VARCHAR(10);
define _tipo_reclamante     VARCHAR(10);
define _no_chasis           CHAR(30);
define _cont                SMALLINT;
define _transaccion         CHAR(10);
define _perdida_d           DEC(16,2);
define _deducible			DEC(16,2);
define _salvamento			DEC(16,2);
define _prima_pend			DEC(16,2);
define _monto_perdida		DEC(16,2);
define _ahorro          	DEC(16,2);
define _no_requis           CHAR(10);
define _fecha_pagado        DATE;

SET ISOLATION TO DIRTY READ;

FOREACH
	select a.no_orden,
		   a.no_reclamo,
		   a.numrecla,
		   a.fecha_orden,
		   a.monto,
		   a.cod_proveedor,
		   case a.tipo_ord_comp when "C" then "PIEZAS" else "MECANICA O CHAPISTERIA" end, 
		   a.tipo_ord_comp,
		   a.no_tranrec,
		   a.transaccion
	  into _no_orden,
		   _no_reclamo,
		   _numrecla,
		   _fecha_orden,
		   _monto,
		   _cod_proveedor,
		   _tipo_orden,
		   _tipo_ord_comp,
		   _no_tranrec,
		   _transaccion
	  from recordma a, recordde b
	 where a.no_orden = b.no_orden
	   and a.fecha_orden   >= a_fecha_1
	   and a.fecha_orden <= a_fecha_2
	   and a.tipo_ord_comp in ('C','R')
	   and b.no_parte = '606'
	   order by a.no_orden
	   
	select count(*)
      into _cont
      from recperdida
     where no_reclamo = _no_reclamo;

    if _cont = 0 THEN
		continue foreach;
	end if		
	
	let _perdida_d = 0.00;
	let _deducible = 0.00;
	let _salvamento = 0.00;
	let _prima_pend = 0.00;
	let _monto_perdida = 0.00;
	
	select a.fecha_reclamo,
	       a.fecha_siniestro,
		   a.no_documento,
		   a.no_unidad,
		   a.suma_asegurada,
		   a.cod_asegurado,
		   a.ajust_interno,
		   a.no_tramite,
		   a.no_motor,
		   a.perd_total,
		   a.cod_taller,
		   a.ins_tipo, 
		   a.ins_suc, 
		   a.formato_unico, 
		   a.tiene_inspeccion, 
		   a.ins_fecha,
		   b.perdida,
		   b.deducible,
		   b.salvamento,
		   b.prima_pend
	  into _fecha_reclamo,
	       _fecha_siniestro,
		   _no_documento,
		   _no_unidad,
		   _suma_asegurada,
		   _cod_asegurado,
		   _ajust_interno,
		   _no_tramite,
		   _no_motor,
		   _perd_total,
		   _cod_taller,
		   _ins_tipo, 
		   _ins_suc, 
		   _formato_unico, 
		   _tiene_inspeccion, 
		   _ins_fecha,
		   _perdida_d,
		   _deducible,
		   _salvamento,
		   _prima_pend
	  from recrcmae a, recperdida b
	 where a.no_reclamo = b.no_reclamo
	   and a.no_reclamo = _no_reclamo;
	   
	 let _monto_perdida =  _perdida_d - (_deducible + _salvamento + _prima_pend); 
	 
	 let _ahorro = _monto_perdida - _monto;
	 
	 select wf_inc_auto,
	        no_requis,
			fecha_pagado
	   into _wf_inc_auto,
	        _no_requis,
			_fecha_pagado
	   from rectrmae
	  where no_tranrec = _no_tranrec;
	  
	 select no_chasis
       into _no_chasis
       from emivehic
      where no_motor = _no_motor;	   
	 
	 select nombre 
	   into _taller
	   from cliclien
	  where cod_cliente = _cod_taller;

	 select nombre 
	   into _asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	  
	 select nombre
	   into _ajustador
	   from recajust
	  where cod_ajustador = _ajust_interno;
	  
	 if _perd_total = 1 then 
		let _perdida = "Si"; 
	 else 
	    let _perdida = "No";
	 end if
	 
	 if _ins_tipo = 0 then
		let _tipo_ins = 'Pendiente';
	 elif _ins_tipo = 1 then
		let _tipo_ins = 'Compañia';
	 else
		let _tipo_ins = 'Taller';
	 end if
	 
	 select descripcion
	   into _ins_agengia
	   from insagen
	  where codigo_agencia = _ins_suc;

	 if _formato_unico = 1 then 
		let _formato = "Si"; 
	 else 
	    let _formato = "No";
	 end if
	  	 
	RETURN _no_orden,
	       _cod_taller,
		   _taller,
		   _fecha_orden,
		   _no_tramite,
		   _numrecla,
		   _fecha_reclamo,
	       _fecha_siniestro,
		   _no_documento,
		   _no_unidad,
		   _suma_asegurada,
		   _cod_asegurado,
		   _asegurado,
		   _ajustador,
		   _no_motor,
		   _perdida,
		   _monto,
           _tipo_orden,
		   _wf_inc_auto,
		   null,
           null,
           null,
           null,
		   null,
           _no_chasis,
    	   _monto_perdida,
		   _ahorro,
       	   _transaccion,
           _no_requis,
           _fecha_pagado with resume;   

END FOREACH


END PROCEDURE;