-- Procedimiento que Finiquito Asegurado de Colectivo y Vida Individual--
-- 
-- Creado    : 04/03/2016 - Autor: Amado Perez Mendoza 
-- Modificado: 04/03/2016 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp0_rec263c;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp0_rec263c(a_compania CHAR(3), a_agencia CHAR(3), a_tranrec CHAR(10))
			RETURNING   CHAR(18),
						VARCHAR(100),
						VARCHAR(30),
						DEC(16,2),
						CHAR(20),
						DATE,
						CHAR(50),
						DEC(16,2),
						VARCHAR(50),
						VARCHAR(50),
						VARCHAR(250),
						VARCHAR(100);

DEFINE v_numrecla         CHAR(18);
DEFINE v_asegurado        VARCHAR(100);
DEFINE v_a_nombre         VARCHAR(100);
DEFINE v_cedula           VARCHAR(30);
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

DEFINE _cod_ramo         CHAR(3);
DEFINE _ramo             VARCHAR(50);
DEFINE _cod_concepto     CHAR(3);
DEFINE _concepto         VARCHAR(50);

DEFINE v_monto_letras    VARCHAR(250);
DEFINE _cod_asegurado    CHAR(10);  
define li_cnt_1            smallint;

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);
let li_cnt_1 = 0;
CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10),
		no_reclamo       CHAR(10),
		numrecla         CHAR(18),
		no_documento     CHAR(20),
		cod_cliente	     CHAR(10),
		fecha_siniestro  DATE,
		monto            DEC(16,2),
		prima_aplicar    DEC(16,2),
		cod_concepto     CHAR(3),
		cod_ramo         CHAR(3),
		cod_asegurado    CHAR(10)
		) WITH NO LOG; 


select sum(r.monto)
  into _monto
  from rectrmae t, rectrcon r, recconce c
 where t.no_tranrec    = r.no_tranrec
   and r.cod_concepto  = c.cod_concepto
   and t.no_tranrec    = a_tranrec
   --and c.genera_recibo = 1
   and r.monto         <> 0;

FOREACH
	select r.cod_concepto
	  into _cod_concepto
	  from rectrmae t, rectrcon r, recconce c
	 where t.no_tranrec    = r.no_tranrec
	   and r.cod_concepto  = c.cod_concepto
	   and t.no_tranrec    = a_tranrec
--	   and c.genera_recibo = 1
	   and r.monto         <> 0
	   
	EXIT FOREACH;

END FOREACH   
   
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
	  
	 SELECT cod_asegurado
	   INTO _cod_asegurado
	   FROM rectrfini1
	  WHERE no_tranrec = a_tranrec;

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

	SELECT no_documento, 
	       cod_ramo	  
	  INTO v_no_documento,
	       _cod_ramo
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
	prima_aplicar,
	cod_concepto,
	cod_ramo,
	cod_asegurado
	)
	VALUES(
	_no_poliza,
	_no_reclamo,
	v_numrecla,
	v_no_documento, 
	_cod_cliente,	
	v_fecha_sini,
	v_monto,
	_monto,
	_cod_concepto,
	_cod_ramo,
	_cod_asegurado
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
 		prima_aplicar,
        cod_concepto,
        cod_ramo,
        cod_asegurado		
   INTO _no_poliza,
        _no_reclamo,
        v_numrecla, 
        v_no_documento,
		_cod_cliente,
		v_fecha_sini,
		v_monto,
		_monto,
		_cod_concepto,
		_cod_ramo,
		_cod_asegurado
   FROM tmp_arreglo

	-- Lectura de Cliente

	SELECT nombre,
	       cedula
	  INTO v_a_nombre,
		   v_cedula	
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
{
a.	Transacciones de tipo: -004- PAGO DEL RECLAMO
b.	Tipo de pago: -004- PAGO A TERCERO
c.	Opción de Finiquito Colectivo: Bancos, Principal 
d.	Ramo: -019- Vida Individual
}	 
 	-- Lectura de Transaccion 019
	if _cod_ramo = '019' then
	let li_cnt_1 = 0;
	 SELECT count(*)
	   INTO li_cnt_1
	   FROM rectrmae
	  WHERE no_tranrec = a_tranrec
	    and cod_tipotran = '004'   
		and cod_tipopago = '004'
		and no_reclamo = _no_reclamo;
		if li_cnt_1 is null then
			let li_cnt_1 = 0;
		end if	
	end if  

	 LET _acreedor = sp_rec100(_no_reclamo);

	IF v_a_nombre IS NULL THEN
		LET v_a_nombre = " ";
	ELSE
		IF _acreedor IS NOT NULL AND _acreedor <> "" THEN
			if li_cnt_1 <> 0 then
			    LET v_a_nombre = TRIM(v_a_nombre);
			else
				LET v_a_nombre = TRIM(v_a_nombre) || " Y " || TRIM(_acreedor);	
			end if
		END IF
	END IF 

	let _monto = ABS(_monto);
	
	LET v_monto_letras = sp_sis11(v_monto);
	
	SELECT nombre
	  INTO _ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
	SELECT nombre
	  INTO _concepto
	  FROM recconce
	 WHERE cod_concepto = _cod_concepto;

	SELECT nombre	  
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;
	 
	 
	RETURN v_numrecla,
		   trim(v_asegurado),
		   trim(v_cedula), 
		   v_monto,
		   v_no_documento, 
		   v_fecha_sini, 
		   v_compania_nombre,
		   _monto,
		   trim(_ramo),
		   trim(_concepto),
		   trim(v_monto_letras),
		   trim(v_a_nombre)
		   WITH RESUME; 

END FOREACH

DROP TABLE tmp_arreglo;
END PROCEDURE
