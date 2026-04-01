DROP procedure sp_productor;

CREATE procedure "informix".sp_productor()
RETURNING integer;
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO AUTO
---  Armando Moreno M.
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza     CHAR(10);
    DEFINE _no_documento   CHAR(20);
	DEFINE _cod_agente     char(5);
	define _n_corredor	   char(50);
	DEFINE v_prima_cobrada dec(16,2);
	DEFINE _serie          smallint;
	DEFINE _monto_comision dec(16,2);
	DEFINE _fidelidad      dec(16,2);
	DEFINE _cobranza       dec(16,2);
	DEFINE _rentabilidad   dec(16,2);
	DEFINE _saldo		   dec(16,2);
	DEFINE _prima_suscrita dec(16,2);
	DEFINE _valor          smallint;
	DEFINE _cant_pol       integer;
	DEFINE _prima_cob_n	   dec(16,2);
	DEFINE _cnt            integer;
	DEFINE _pp			   dec(16,2);
	DEFINE _cnt_pol        integer;
	DEFINE _pc			   dec(16,2);
	DEFINE _pcn			   dec(16,2);
	define _ct_pol         integer;

CREATE TEMP TABLE tmp_esta(
		no_poliza      CHAR(10)  NOT NULL,
		cod_agente     CHAR(5)   NOT NULL,
		total_pri_sus  DEC(16,2) DEFAULT 0 NOT NULL,
		prima_cobrada  DEC(16,2) DEFAULT 0 NOT NULL,
		poliza_pagada  integer,
		cant_pol       integer,
		prima_cob_neta DEC(16,2) DEFAULT 0 NOT NULL,
		comision       DEC(16,2) DEFAULT 0 NOT NULL,
		fidelidad      DEC(16,2) DEFAULT 0 NOT NULL,
		cobranza       DEC(16,2) DEFAULT 0 NOT NULL,
		rentabilidad   DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE TEMP TABLE tmp_esta2(
		no_documento   CHAR(20)  NOT NULL,
		cod_agente     CHAR(5)   NOT NULL,
		total_pri_sus  DEC(16,2) DEFAULT 0 NOT NULL
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
	let _cnt_pol        = 0;

--COMISION
FOREACH WITH HOLD

	select comision,
	       no_poliza,
		   no_documento,
		   cod_agente
	  into _monto_comision,
	       v_no_poliza,
		   _no_documento,
		   _cod_agente
	  from chqcomis
	 where fecha_genera between '01/01/2009' and '30/06/2009'
	   and (no_documento[1,2] = '02'
		or  no_documento[1,2] = '20')

		if _monto_comision is null then
			let _monto_comision = 0;
		end if

	 select count(*)
	   into _cnt
	   from tmp_esta
	  where no_poliza  = v_no_poliza
	    and cod_agente = _cod_agente;

	if _cnt = 0 then
	    	
		INSERT INTO tmp_esta(
		no_poliza,
		cod_agente,
		comision
		)
		VALUES(
		v_no_poliza,
		_cod_agente,
		_monto_comision
		);

	else

		update tmp_esta
		   set comision   = comision + _monto_comision
		 where no_poliza  = v_no_poliza
		   and cod_agente = _cod_agente;
	end if

end foreach

--FIDELIDAD
let _monto_comision = 0;
--	   and cod_agente = '01090'
FOREACH WITH HOLD

	select comision,
	       no_poliza,
		   no_documento,
		   cod_agente
	  into _monto_comision,
	       v_no_poliza,
		   _no_documento,
		   _cod_agente
	  from chqfidel
	 where periodo between '2009-01' and '2009-06'
	   and cod_ramo in("002","020")

		if _monto_comision is null then
			let _monto_comision = 0;
		end if

	 select count(*)
	   into _cnt
	   from tmp_esta
	  where no_poliza  = v_no_poliza
	    and cod_agente = _cod_agente;

	if _cnt = 0 then
	    	
		INSERT INTO tmp_esta(
		no_poliza,
		cod_agente,
		fidelidad
		)
		VALUES(
		v_no_poliza,
		_cod_agente,
		_monto_comision
		);

	else

		update tmp_esta
		   set fidelidad = fidelidad + _monto_comision
		 where no_poliza  = v_no_poliza
		   and cod_agente = _cod_agente;
	end if

end foreach

--COBRANZA

let _monto_comision = 0;

FOREACH WITH HOLD

	select comision,
	       no_poliza,
		   no_documento,
		   cod_agente
	  into _monto_comision,
	       v_no_poliza,
		   _no_documento,
		   _cod_agente
	  from chqboni
	 where periodo between '2009-01' and '2009-06'
	   and cod_ramo in("002","020")

		if _monto_comision is null then
			let _monto_comision = 0;
		end if

	 select count(*)
	   into _cnt
	   from tmp_esta
	  where no_poliza  = v_no_poliza
	    and cod_agente = _cod_agente;

	if _cnt = 0 then
	    	
		INSERT INTO tmp_esta(
		no_poliza,
		cod_agente,
		cobranza
		)
		VALUES(
		v_no_poliza,
		_cod_agente,
		_monto_comision
		);

	else

		update tmp_esta
		   set cobranza = cobranza + _monto_comision
		 where no_poliza  = v_no_poliza
		   and cod_agente = _cod_agente;
	end if

end foreach

foreach

       SELECT sum(comision),
			  sum(fidelidad),   
			  sum(cobranza),    
			  sum(rentabilidad),
       		  cod_agente
         INTO _monto_comision,
			  _fidelidad,
			  _cobranza,
			  _rentabilidad,
		      _cod_agente
         FROM tmp_esta
		group by cod_agente
		order by cod_agente

		let _pp      = 0;
		let _pcn     = 0;
	    let _valor   = 0;
		let _cnt_pol = 0;
		let _pc      = 0;
		let _ct_pol = 0;

		foreach

			select no_poliza
			  into v_no_poliza
			  from tmp_esta
			 where cod_agente = _cod_agente

			SELECT no_documento
			  INTO _no_documento
			  FROM emipomae
			 WHERE no_poliza = v_no_poliza
			   AND actualizado = 1;

			SELECT e.prima_suscrita
			  INTO _prima_suscrita
			  FROM emipomae e
			 WHERE e.no_poliza = v_no_poliza
			   AND e.actualizado = 1
			   AND e.periodo between '2009-01' and '2009-06';

			if _prima_suscrita is not null then
			  	select count(*)
				  into _ct_pol
				  from tmp_esta2
				 where cod_agente   = _cod_agente
				   and no_documento = _no_documento;

				 if _ct_pol = 0 then

					INSERT INTO tmp_esta2(
					no_documento,
					cod_agente,
					total_pri_sus
					)
					VALUES(
					_no_documento,
					_cod_agente,
					_prima_suscrita
					);

				 end if
			end if

		   --	let _pp = _pp + _prima_suscrita;

			-- Prima cobrada Neta y prima cobrada
			SELECT sum(d.prima_neta),
			       sum(d.monto)
			  INTO _prima_cob_n,
				   v_prima_cobrada
			  FROM cobredet d, cobremae m
			 WHERE d.cod_compania     = '001'
			   AND d.actualizado      = 1
			   AND d.periodo          between "2009-01" and "2009-06"
			   AND d.tipo_mov         IN ('P','N')
			   AND d.monto_descontado = 0
			   AND d.doc_remesa       = _no_documento
			   AND d.no_remesa        = m.no_remesa
			   AND m.tipo_remesa      IN ('A', 'M', 'C');

			if _prima_cob_n is null then
				let _prima_cob_n = 0;
			end if

			let _pcn = _pcn + _prima_cob_n;

			if v_prima_cobrada is null then
				let v_prima_cobrada = 0;
			end if

			if v_prima_cobrada > 0 then --al menos un pago
			   let _valor = _valor + 1;	
			end if

   			let _pc = _pc + v_prima_cobrada;

			let _cnt_pol = _cnt_pol + 1;

		end foreach

	   let _rentabilidad = 0;

	   select sum(comision)
		 into _rentabilidad
		 from chqrenta3
		where cod_ramo in("002","020")
		  and cod_agente = _cod_agente
	    group by cod_agente;

		if _rentabilidad is null then
		 	let _rentabilidad = 0;
		end if

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

        SELECT sum(total_pri_sus)
          INTO _pp
          FROM tmp_esta2
         WHERE cod_agente = _cod_agente;

		if _pp is null then

			let _pp = 0;

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
		_cnt_pol,
		_pp,
		_valor,
		_pc,
		_monto_comision,
		_fidelidad,
		_cobranza,
		_rentabilidad,
		_pcn
		);

END FOREACH

drop table tmp_esta;
drop table tmp_esta2;

END
END PROCEDURE;
