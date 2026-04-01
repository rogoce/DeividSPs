DROP procedure sp_productor;

CREATE procedure "informix".sp_productor()
RETURNING integer;
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO AUTO
---  Armando Moreno M.
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza                CHAR(10);
    DEFINE _no_documento              CHAR(20);
	DEFINE _cod_agente                char(5);
	define _n_corredor				  char(50);
	DEFINE v_prima_cobrada            dec(16,2);
	DEFINE _serie                     smallint;
	DEFINE _monto_comision			  dec(16,2);
	DEFINE _fidelidad                 dec(16,2);
	DEFINE _cobranza                  dec(16,2);
	DEFINE _rentabilidad			  dec(16,2);
	DEFINE _saldo					  dec(16,2);
	DEFINE _prima_suscrita			  dec(16,2);
	DEFINE _valor                     smallint;
	DEFINE _cant_pol                  integer;
	DEFINE _prima_cob_n				  dec(16,2);

CREATE TEMP TABLE tmp_esta(
		no_documento   CHAR(20)  NOT NULL,
		cod_agente     CHAR(5)   NOT NULL,
		total_pri_sus  DEC(16,2) NOT NULL,
		prima_cobrada  DEC(16,2) NOT NULL,
		poliza_pagada  integer,
		cant_pol       integer,
		prima_cob_neta DEC(16,2) NOT NULL
		) WITH NO LOG;

    SET ISOLATION TO DIRTY READ;
    
    let _saldo          = 0;
	let _valor          = 0;
	let _monto_comision = 0;
	let _fidelidad      = 0;
	let _cobranza       = 0;
	let _rentabilidad   = 0;
	let v_prima_cobrada = 0;
	let _cant_pol       = 0;
	let _prima_cob_n    = 0;
	let _prima_suscrita = 0;

FOREACH WITH HOLD

	 SELECT sum(e.prima_suscrita),
			e.no_documento
	   INTO _prima_suscrita,	 
			_no_documento
	   FROM endedmae e, emipomae r
	  WHERE e.no_poliza = r.no_poliza
	    AND e.periodo >= "2009-01"
	    and e.periodo <= "2009-06"
	    AND e.actualizado = 1
	    AND r.actualizado = 1
		AND r.cod_ramo in("002","020")
      GROUP BY e.no_documento
	  ORDER BY e.no_documento

	 LET v_no_poliza = sp_sis21(_no_documento);

	 foreach

	       SELECT cod_agente
	         INTO _cod_agente
	         FROM emipoagt
	        WHERE no_poliza = v_no_poliza

		  exit foreach;

	 end foreach

	 if _cod_agente = '01090' then
	 else
		continue foreach;
	 end if
	 
	-- Prima cobrada
	SELECT sum(d.monto)
	  INTO v_prima_cobrada
	  FROM cobredet d, cobremae m
	 WHERE d.cod_compania = '001'
	   AND d.actualizado  = 1
	   AND d.periodo      between "2009-01" and "2009-06"
	   AND d.tipo_mov     IN ('P','N')
	   AND d.doc_remesa   = _no_documento
	   AND d.no_remesa    = m.no_remesa
	   AND m.tipo_remesa  IN ('A', 'M', 'C');

	   let _saldo = sp_cob115b("","",_no_documento,"");

	   let _valor = 0;	
	   if _saldo <= 0 then --fue pagada
		   let _valor = 1;	
	   else
		   let _valor = 0;
	   end if

	   if v_prima_cobrada is null then
	   	  let v_prima_cobrada = 0;
	   end if

	-- Prima cobrada Neta
	SELECT sum(d.prima_neta)
	  INTO _prima_cob_n
	  FROM cobredet d, cobremae m
	 WHERE d.cod_compania = '001'
	   AND d.actualizado  = 1
	   AND d.periodo      between "2009-01" and "2009-06"
	   AND d.tipo_mov     IN ('P','N')
	   AND d.doc_remesa   = _no_documento
	   AND d.no_remesa    = m.no_remesa
	   AND m.tipo_remesa  IN ('A', 'M', 'C');

	   if _prima_cob_n is null then
	   	  let _prima_cob_n = 0;
	   end if


	INSERT INTO tmp_esta(
	no_documento,
	cod_agente,
	total_pri_sus,
	prima_cobrada,
	poliza_pagada,
    cant_pol,
	prima_cob_neta
	)
	VALUES(
	_no_documento,
	_cod_agente,
	_prima_suscrita,
	v_prima_cobrada,
	_valor,
	1,
	_prima_cob_n
	);

end foreach

foreach

       SELECT sum(prima_cobrada),
       		  sum(total_pri_sus),
			  sum(cant_pol),
			  sum(poliza_pagada),
			  sum(prima_cob_neta),
       		  cod_agente
         INTO v_prima_cobrada,
			  _prima_suscrita,
			  _cant_pol,
			  _valor,
			  _prima_cob_n,
		      _cod_agente
         FROM tmp_esta
		group by cod_agente
		order by cod_agente

        SELECT nombre
          INTO _n_corredor
          FROM agtagent
         WHERE cod_agente = _cod_agente;

		if v_prima_cobrada is null then
			let v_prima_cobrada = 0;
		end if

		if _prima_cob_n is null then
			let _prima_cob_n = 0;
		end if

		--comision
	   {select sum(t.monto)
		  into _monto_comision
		  from chqchmae c, chqchagt t
		 where c.no_requis     = t.no_requis
		   and c.origen_cheque = '2'
		   and c.cod_agente    = _cod_agente
		   and c.anulado       = 0
		   and c.pagado        = 1
		   and t.cod_ramo in("002","020")
		   and c.fecha_impresion between '01/01/2009' and '30/06/2009';	}

		select sum(comision)
		  into _monto_comision
		  from chqcomis
		 where cod_agente = _cod_agente
		   and fecha_genera between '01/01/2009' and '30/06/2009'
		   and (no_documento[1,2] = '02'
			or  no_documento[1,2] = '20');

		if _monto_comision is null then
			let _monto_comision = 0;
		end if

		--boni fidelidad
		select sum(comision)
		  into _fidelidad
		  from chqfidel
		 where cod_agente = _cod_agente
		   and periodo between '2009-01' and '2009-06'
		   and cod_ramo in("002","020");

		if _fidelidad is null then
			let _fidelidad = 0;
		end if

		--boni cobranza
		select sum(comision)
		  into _cobranza
		  from chqboni
		 where cod_agente    = _cod_agente
		   and periodo between '2009-01' and '2009-06'
		   and cod_ramo in("002","020");

		if _cobranza is null then
			let _cobranza = 0;
		end if

		--boni rentabilidad	  2008
		select sum(comision)
		  into _rentabilidad
		  from chqrenta3
         where cod_agente  = _cod_agente
           and nombre_ramo in("AUTOMOVIL","SODA");

		if _rentabilidad is null then
			let _rentabilidad = 0;
		end if

		INSERT INTO producto(
		corredor,
		cant_polizas,
		prima_suscrita,
		polizas_pagadas,
		prima_cobrada,
		comision_pag,
		b_fidelidad,
		b_cobranza,
		b_rentabilidad,
		prima_cob_neta
		 )
		VALUES(
		_n_corredor,
		_cant_pol,
		_prima_suscrita,
		_valor,
		v_prima_cobrada,
		_monto_comision,
		_fidelidad,
		_cobranza,
		_rentabilidad,
		_prima_cob_n
		);

END FOREACH

drop table tmp_esta;

END
END PROCEDURE;
