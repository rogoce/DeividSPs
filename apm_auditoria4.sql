-- Procedure que retorna reclamos del 2011 que han sido cerrados de forma automatica por el proceso despues de los 3 meses sin movimiento.
-- Esto es para Auditoria

drop procedure apm_auditoria4;

create procedure apm_auditoria4()
returning varchar(100),CHAR(18),CHAR(20),date,date,varchar(50),DEC(16,2),DEC(16,2),varchar(50),varchar(50),varchar(50);

DEFINE _no_tranrec CHAR(10);
DEFINE _no_reclamo CHAR(10);
DEFINE _numrecla   CHAR(18);
DEFINE _no_documento CHAR(20);
DEFINE _cant smallint;
DEFINE _variacion DEC(16,2);
define _periodo		char(7);
define _pagos		dec(16,2);
define _incurrido	dec(16,2);
define _monto   	dec(16,2);
define _pago_solo 	dec(16,2);
DEFINE _variacion2  DEC(16,2);
define _pagos2		dec(16,2);
define _incurrido2	dec(16,2);
define _pago_solo2 	dec(16,2);
define _cod_asegurado char(10);
define _cod_evento    char(3);
define v_asegurado    varchar(100);
define v_evento       varchar(50);
define _fecha_reclamo   date;
define _fecha_siniestro date;
define _tipo_transaccion smallint;
define _porc_partic_reas dec(9,6);
define _porc_partic_coas dec(9,6);
define _sumar_incurrido  dec(16,2);
define _cod_tipotran     char(3);
define _cod_coasegur     char(3);
define _wf_apr_j_fh 	 DATETIME year to fraction(5);
define _wf_apr_jt_fh 	 DATETIME year to fraction(5);
define _wf_apr_jt_2_fh	 DATETIME year to fraction(5);
define _wf_apr_g_fh		 DATETIME year to fraction(5);
define _fecha_tran       date;
define _recuperos, _reserva DEC(16,2);
define _ded, _pagado DEC(16,2);
define _transaccion      char(10);
define _no_poliza 		 char(10);
define _cod_producto	 char(5);
define _cod_ramo         char(3);
define _cod_subramo      char(3);
define v_producto        varchar(50);
define v_ramo       	 varchar(50);
define v_subramo         varchar(50);
 

CREATE TEMP TABLE tmp_arreglo(
	   no_tranrec     CHAR(10),
	   transaccion    CHAR(10),
	   fecha	      DATE,
	   monto	      DEC(16,2),
	   variacion      DEC(16,2),
	   cod_tipotran	  CHAR(3),
	   wf_apr_j_fh    DATETIME year to fraction(5), 
	   wf_apr_jt_fh   DATETIME year to fraction(5), 
	   wf_apr_jt_2_fh DATETIME year to fraction(5), 
	   wf_apr_g_fh	  DATETIME year to fraction(5)
		) WITH NO LOG;

set isolation to dirty read;

--SET DEBUG FILE TO "apm_auditoria4.trc";
--TRACE ON;                                                                 
LET _cod_coasegur     = sp_sis02('001', '001');


FOREACH
  SELECT no_reclamo, cod_asegurado, no_documento, cod_evento, fecha_reclamo, fecha_siniestro, numrecla, no_poliza, cod_producto
    INTO _no_reclamo, _cod_asegurado, _no_documento, _cod_evento, _fecha_reclamo, _fecha_siniestro, _numrecla, _no_poliza, _cod_producto 
	FROM recrcmae 
   WHERE periodo >= '2013-01' and periodo <= '2013-07'
     AND numrecla[1,2] in ('02','20')
	 AND actualizado = 1
--  order by numrecla

  SELECT cod_ramo,
         cod_subramo
    INTO _cod_ramo,
		 _cod_subramo
	FROM emipomae
   WHERE no_poliza = _no_poliza;
  
  SELECT nombre
    INTO v_ramo
	FROM prdramo
   WHERE cod_ramo = _cod_ramo;
  
  SELECT nombre 
    INTO v_subramo
	FROM prdsubra
   WHERE cod_ramo = _cod_ramo
	 AND cod_subramo = _cod_subramo;

  SELECT nombre 
    INTO v_producto
	FROM prdprod
   WHERE cod_producto = _cod_producto;

  select nombre 
    into v_asegurado
	from cliclien
   where cod_cliente = _cod_asegurado;

  select nombre 
    into v_evento
	from recevent
   where cod_evento = _cod_evento;

  let _variacion = 0;

-- Porcentaje de Coaseguro
	SELECT porc_partic_coas
	 INTO  _porc_partic_coas
	 FROM  reccoas
	WHERE  no_reclamo = _no_reclamo
	  AND  cod_coasegur = _cod_coasegur; 

	IF _porc_partic_coas IS NULL THEN
		LET _porc_partic_coas = 0;
	END IF

---Variacion

{FOREACH
 SELECT no_tranrec,
        monto,
		variacion,
		cod_tipotran
   INTO _no_tranrec,
        _pagos,
		_variacion,
		_cod_tipotran
   FROM rectrmae
  WHERE no_reclamo  = _no_reclamo
    AND actualizado = 1

	-- Cambio para que refleje el incurrido neto de acuerdo con el
	-- reaseguro a nivel de transaccion

   SELECT tipo_transaccion
	 INTO _tipo_transaccion
	 FROM rectitra
	WHERE cod_tipotran = _cod_tipotran;

	select porc_partic_suma
	  into _porc_partic_reas
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato = 1;

	if _porc_partic_reas is null then
		let _porc_partic_reas = 0.00;
	end if		

	if _tipo_transaccion = 4 or
	   _tipo_transaccion = 5 or  
	   _tipo_transaccion = 6 or  
	   _tipo_transaccion = 7 then
		let _sumar_incurrido = _pagos;
	else
		let _sumar_incurrido = 0.00;
	end if
	
	let _sumar_incurrido = _sumar_incurrido + _variacion;
	let _incurrido       = _sumar_incurrido * _porc_partic_coas / 100;

end foreach

 SELECT sum(variacion)
   INTO _variacion
   FROM rectrmae
  WHERE no_reclamo  = _no_reclamo
    AND actualizado = 1;
}

--TRANSACCIONES
FOREACH
 SELECT no_tranrec,
        transaccion,
		fecha,
		monto,
		variacion,
		cod_tipotran,
		wf_apr_j_fh, 
		wf_apr_jt_fh, 
		wf_apr_jt_2_fh, 
		wf_apr_g_fh
   INTO _no_tranrec,
        _transaccion,
		_fecha_tran,
		_pagos,
		_variacion,
		_cod_tipotran,
		_wf_apr_j_fh, 
		_wf_apr_jt_fh, 
		_wf_apr_jt_2_fh, 
		_wf_apr_g_fh
   FROM rectrmae
  WHERE no_reclamo  = _no_reclamo
    AND actualizado = 1

  IF _wf_apr_j_fh IS NULL THEN
	LET _wf_apr_j_fh = _fecha_tran;
  END IF

  INSERT INTO tmp_arreglo
     values (
	 _no_tranrec,
	 _transaccion,
     _fecha_tran,
	 _pagos,
	 _variacion,
	 _cod_tipotran,
	 _wf_apr_j_fh, 
	 _wf_apr_jt_fh, 
	 _wf_apr_jt_2_fh,
	 _wf_apr_g_fh
	 );

END FOREACH

let _reserva = 0;
LET _recuperos = 0;
LET _ded = 0;
LET _incurrido = 0;
LET _pagado = 0;

FOREACH
 SELECT monto,
		variacion,
		cod_tipotran
   INTO _pagos,
		_variacion,
		_cod_tipotran
   FROM tmp_arreglo
  ORDER BY wf_apr_j_fh, wf_apr_jt_fh, wf_apr_jt_2_fh, wf_apr_g_fh, fecha, transaccion

	SELECT tipo_transaccion
	 INTO  _tipo_transaccion
	FROM   rectitra
	WHERE  cod_tipotran = _cod_tipotran;

	LET _reserva = _variacion + _reserva;

	IF _tipo_transaccion = 4 THEN
		LET _pagado  = _pagado + _pagos;
	END IF

	IF _tipo_transaccion = 5 OR   --salvamento
	   _tipo_transaccion = 6 THEN --recupero
		LET _recuperos = (_pagos  * -1) + _recuperos;
	ELIF _tipo_transaccion = 7 THEN	--ded
		LET _ded = (_pagos  * -1) + _ded;
	END IF

	LET _incurrido = _reserva + _pagado - (_recuperos + _ded);

END FOREACH

 RETURN v_asegurado, _numrecla, _no_documento, _fecha_reclamo, _fecha_siniestro, v_evento, _reserva, _incurrido * _porc_partic_coas / 100, v_ramo, v_subramo, v_producto  with resume;
   
delete from tmp_arreglo;
--    if _numrecla = '02-0713-00036-05' then
--		trace off;
--	end if

END FOREACH

drop table tmp_arreglo;

end procedure
