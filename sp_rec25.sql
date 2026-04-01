-- Procedimiento que Finiquito Asegurado--
-- 
-- Creado    : 06/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 06/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec25;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE sp_rec25(a_compania CHAR(3), a_agencia CHAR(3), a_tranrec CHAR(10))
			RETURNING   CHAR(18),
						CHAR(100),
						CHAR(30),
						DEC(16,2),
						CHAR(20),
						DATE,
						CHAR(50),
						DEC(16,2);

DEFINE v_numrecla         CHAR(18);
DEFINE v_asegurado        VARCHAR(100);
DEFINE v_cedula           CHAR(30);
DEFINE v_monto			  DEC(16,2);
DEFINE v_no_documento     CHAR(20);
DEFINE v_fecha_sini       DATE;
DEFINE v_compania_nombre  CHAR(50);

DEFINE _acreedor 		 VARCHAR(100);
DEFINE _no_reclamo       CHAR(10);
DEFINE _no_tranrec       CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _monto            DEC(16,2);
DEFINE _agrega_acreedor  SMALLINT;

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),
		no_reclamo       CHAR(10),
		numrecla         CHAR(18),
		no_documento     CHAR(20),
		cod_cliente	     CHAR(10),
		fecha_siniestro  DATE,
		monto            DEC(16,2),
		prima_aplicar    DEC(16,2)
		) WITH NO LOG; 


select sum(r.monto)
  into _monto
  from rectrmae t, rectrcon r, recconce c
 where t.no_tranrec    = r.no_tranrec
   and r.cod_concepto  = c.cod_concepto
   and t.no_tranrec    = a_tranrec
   and c.genera_recibo = 1
   and r.monto         <> 0;

if _monto >= 0 or _monto is null then
	let _monto = 0;
end if

FOREACH	

 	-- Lectura de Transaccion
	 SELECT no_reclamo,
	        monto,
			cod_cliente
	   INTO _no_reclamo,
	        v_monto,
			_cod_cliente
	   FROM rectrmae
	  WHERE no_tranrec = a_tranrec
	    AND cod_tipopago = '003'

   	-- Lectura de Reclamos

 	SELECT no_poliza,
		   numrecla,
		   fecha_siniestro
   	  INTO _no_poliza,
	       v_numrecla,
		   v_fecha_sini
      FROM recrcmae
     WHERE no_reclamo   = _no_reclamo
       AND cod_compania = a_compania
	   AND actualizado  = 1;

	-- Lectura de Polizas

   {	SELECT no_documento,
	       cod_contratante
	  INTO v_no_documento,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza; }

	SELECT no_documento	  
	  INTO v_no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
 
	INSERT INTO tmp_arreglo(
	no_poliza,
	no_reclamo, 
	numrecla, 
	no_documento, 
	cod_cliente,
	fecha_siniestro,
	monto,
	prima_aplicar 
	)
	VALUES(
	_no_poliza,
	_no_reclamo,
	v_numrecla,
	v_no_documento, 
	_cod_cliente,	
	v_fecha_sini,
	v_monto,
	_monto
	);
END FOREACH;

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_poliza,
        no_reclamo,
        numrecla,
		no_documento,
 		cod_cliente,
 		fecha_siniestro,
 		monto,
 		prima_aplicar 
   INTO _no_poliza,
        _no_reclamo,
        v_numrecla, 
        v_no_documento,
		_cod_cliente,
		v_fecha_sini,
		v_monto,
		_monto
   FROM tmp_arreglo

	-- Lectura de Cliente

	SELECT nombre,
	       cedula
	  INTO v_asegurado,
		   v_cedula	
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	LET _acreedor = sp_rec100(_no_reclamo);

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	ELSE
		IF _acreedor IS NOT NULL AND _acreedor <> "" THEN
			LET _agrega_acreedor = sp_rec198(a_tranrec);
			if _agrega_acreedor <> 0 then
				LET v_asegurado = TRIM(v_asegurado) || " Y " || TRIM(_acreedor);	
			end if
		END IF
	END IF 

	let _monto = ABS(_monto);

	RETURN v_numrecla,
		   v_asegurado,
		   v_cedula, 
		   v_monto,
		   v_no_documento, 
		   v_fecha_sini, 
		   v_compania_nombre,
		   _monto
		   WITH RESUME; 

END FOREACH

DROP TABLE tmp_arreglo;
END PROCEDURE
