-- Procedure que retorna reclamos con re-apertura, despues de haber sido cerrados de forma automatica despues de los 3 meses sin movimiento

drop procedure sp_rec217;

create procedure sp_rec217(a_periodo1 char(7), a_periodo2 char(7))
returning CHAR(18),CHAR(20),date,date,integer,DEC(16,2),date,date,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

DEFINE _no_tranrec 		CHAR(10);
DEFINE _no_reclamo 		CHAR(10);
DEFINE _numrecla   		CHAR(18);
DEFINE _no_documento 	CHAR(20);
DEFINE _cant 		    smallint;
define _periodo		    char(7);
define _monto_total		dec(16,2);
define _monto    	    dec(16,2);
define _fecha_cierre    date;
define _fecha_reabrir   date;
define _fecha_siniestro date;
define _fecha_reclamo   date;
define _incurrido_bruto	dec(16,2);
define _pagado_bruto   	dec(16,2);
define _reserva_bruta  	dec(16,2);
define _incurrido_neto 	dec(16,2);
define _pagado_neto    	dec(16,2);
define _reserva_neta   	dec(16,2);
define _monto_bruto    	dec(16,2);
define _monto_neto   	dec(16,2);
DEFINE _porc_coas    	DECIMAL(16,4);
DEFINE _porc_reas    	DECIMAL(16,6);
define _cod_coasegur    char(3);
define _cant_dias       integer;



create temp table tmp_incurrid(
no_reclamo	    char(10),
reserva_bruta	dec(16,2),
reserva_neta	dec(16,2),
pagado_bruto	dec(16,2),
pagado_neto     dec(16,2)
) with no log;

set isolation to dirty read;

LET _cod_coasegur = sp_sis02('001', '001');

FOREACH
  SELECT no_tranrec,   
         no_reclamo,   
         numrecla,
		 monto,
		 fecha
    INTO _no_tranrec,
    	 _no_reclamo,
    	 _numrecla,
    	 _monto,
    	 _fecha_cierre  
    FROM rectrmae
   WHERE (user_added = 'informix' ) 
     AND (actualizado = 1 ) 
     AND (cod_tipotran = '011')
     AND (periodo >= a_periodo1) 
     AND (periodo <= a_periodo2) 
     AND (numrecla[1,2] in ('02','20','18'))

  LET _cant = 0;

  SELECT COUNT(*)
    INTO _cant
	FROM rectrmae
   WHERE no_reclamo   = _no_reclamo
     AND cod_tipotran = '012'		 --Re-abrir reclamo
	 and fecha >= _fecha_cierre
	 AND actualizado = 1;

  IF _cant > 0 THEN
    SELECT no_documento,
           fecha_siniestro,
           fecha_reclamo
	  INTO _no_documento,
	       _fecha_siniestro,
		   _fecha_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;    

	foreach
	 select	fecha
	   into _fecha_reabrir
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran = '012'		 --Re-abrir reclamo
		and fecha >= _fecha_cierre
	 	and actualizado = 1
	  exit foreach;
	end foreach

	let _cant_dias = 0;
	let _cant_dias = _fecha_reabrir - _fecha_cierre;

	-- Informacion de Coseguro
 
	SELECT porc_partic_coas 
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	-- Variacion de Reserva

	LET _monto_bruto = 0;
	LET _monto_neto  = 0;

	FOREACH 
	 SELECT no_tranrec,		
	        variacion
	   INTO _no_tranrec,	
	        _monto_total
	   FROM rectrmae 
	  WHERE no_reclamo  = _no_reclamo
		AND actualizado = 1
		AND periodo      >= a_periodo1 
		AND periodo      <= a_periodo2
	    AND variacion    <> 0

		-- Informacion de Reaseguro

		LET _porc_reas = NULL;

	   FOREACH
		SELECT porc_partic_prima
		  INTO _porc_reas
		  FROM rectrrea
		 WHERE no_tranrec    = _no_tranrec
		   AND tipo_contrato = 1
			EXIT FOREACH;
	    END FOREACH

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		-- Calculos

		LET _monto_bruto = _monto_total / 100 * _porc_coas;
		LET _monto_neto  = _monto_bruto / 100 * _porc_reas;
 
		insert into tmp_incurrid
		values (_no_reclamo, _monto_bruto, _monto_neto, 0,0);

	END FOREACH

	-- Pagos, Salvamentos, Recuperos y Deducibles

	foreach
	 SELECT no_tranrec,		
	        monto
	   INTO _no_tranrec,		
	        _monto_total
	   FROM rectrmae
	  WHERE no_reclamo   = _no_reclamo
		AND actualizado = 1
		AND periodo      >= a_periodo1 
		AND periodo      <= a_periodo2
		and monto        <> 0
		and cod_tipotran in ("004", "005", "006", "007")

		-- Informacion de Coseguro
	 
		SELECT porc_partic_coas 
		  INTO _porc_coas
	      FROM reccoas
	     WHERE no_reclamo   = _no_reclamo
	       AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		-- Informacion de Reaseguro

		LET _porc_reas = NULL;

	   FOREACH
		SELECT porc_partic_prima
		  INTO _porc_reas
		  FROM rectrrea
		 WHERE no_tranrec    = _no_tranrec
		   AND tipo_contrato = 1
			EXIT FOREACH;
	    END FOREACH

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		-- Calculos

		LET _monto_bruto = _monto_total / 100 * _porc_coas;
		LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

		-- Actualizacion del Movimiento

		insert into tmp_incurrid
		values (_no_reclamo, 0,0,_monto_bruto, _monto_neto);

	end foreach

-- Actualizacion del Incurrido

	 let _incurrido_bruto = 0;
	 let _pagado_bruto    = 0;
	 let _reserva_bruta   = 0;
	 let _incurrido_neto  = 0;
	 let _pagado_neto     = 0;
	 let _reserva_neta    = 0;

	foreach
	 select sum(reserva_bruta),
	 		sum(reserva_neta),
	 		sum(pagado_bruto),
	 		sum(pagado_neto)  
	   into _reserva_bruta,
			_reserva_neta,
			_pagado_bruto,
			_pagado_neto
	   from tmp_incurrid

	 let _incurrido_bruto = _pagado_bruto + _reserva_bruta;
	 let _incurrido_neto  = _pagado_neto  + _reserva_neta;

    end foreach

    delete from tmp_incurrid;

	RETURN _numrecla, _no_documento, _fecha_cierre,_fecha_reabrir,_cant_dias,_monto, _fecha_siniestro, _fecha_reclamo,_pagado_bruto,_pagado_neto,_incurrido_bruto,_incurrido_neto with resume;
	end if
END FOREACH

drop table tmp_incurrid;

end procedure
