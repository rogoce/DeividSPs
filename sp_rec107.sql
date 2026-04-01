--DROP procedure sp_rec107;

CREATE PROCEDURE "informix".sp_rec107(a_no_documento VARCHAR(20) , a_cod_reclamante VARCHAR(10)) 
			RETURNING 	VARCHAR(20),
			VARCHAR(10),
			DATE,
			DATE,
			VARCHAR(10),
			VARCHAR(10),
			INTEGER,
			INTEGER,
		 	VARCHAR(255),
			VARCHAR(100),
		 	INTEGER,
		 	VARCHAR(50),
			VARCHAR(10),
			VARCHAR(10),
			DECIMAL(16),
			DECIMAL(16),
			DECIMAL(16),
			DECIMAL(16),
			DECIMAL(16),
			DECIMAL(16),
			DECIMAL(16),
			SMALLINT;


DEFINE  v_numrecla			VARCHAR(20);
DEFINE	v_no_reclamo		VARCHAR(10);
DEFINE	v_fecha_factura 	DATE;
DEFINE	v_fecha				DATE;
DEFINE	v_no_tranrec		VARCHAR(10);
DEFINE	v_transaccion		VARCHAR(10);
DEFINE	v_actualizado_1		INTEGER;
DEFINE	v_actualizado_2 	INTEGER;
DEFINE	v_nombre_icd 		VARCHAR(255);
DEFINE	v_nombre_cliente	VARCHAR(100);
DEFINE	v_no_cheque 		INTEGER;
DEFINE 	v_nombre_tipotran	VARCHAR(50);
DEFINE 	v_no_factura		VARCHAR(10);
DEFINE	v_anular_nt			VARCHAR(10);
DEFINE 	v_facturado			DECIMAL(16);   
DEFINE 	v_monto				DECIMAL(16);
DEFINE 	v_a_deducible		DECIMAL(16);
DEFINE 	v_coaseguro			DECIMAL(16);
DEFINE 	v_ahorro			DECIMAL(16);   
DEFINE	v_monto_no_cubierto DECIMAL(16);   
DEFINE 	v_co_pago			DECIMAL(16);
DEFINE  v_anulada           SMALLINT;

DEFINE 	_cod_icd			CHAR(10);
DEFINE 	_no_requis			CHAR(10);
DEFINE	_cod_cliente		CHAR(10);
DEFINE	_cod_tipotran		CHAR(3);


FOREACH WITH HOLD
	SELECT  numrecla,        
			no_reclamo,
			actualizado,
			cod_icd
	INTO 	v_numrecla,
			v_no_reclamo,
			v_actualizado_1,
	        _cod_icd
	FROM  	recrcmae
	WHERE  	no_documento = a_no_documento
	AND  	cod_reclamante = a_cod_reclamante

 	FOREACH
		SELECT no_tranrec,
				transaccion,
		        fecha,
				fecha_factura,
				actualizado,
				no_factura,
				anular_nt,
				no_requis,
				cod_cliente,
				cod_tipotran
		INTO 	v_no_tranrec,
				v_transaccion,
				v_fecha,
				v_fecha_factura,
				v_actualizado_2,
				v_no_factura,
				v_anular_nt,
				_no_requis,
				_cod_cliente,
				_cod_tipotran
		FROM 	rectrmae
		WHERE 	no_reclamo = v_no_reclamo
		AND   	cod_tipotran <> '001'


		SELECT SUM(rectrcob.facturado),   
				SUM(rectrcob.monto),   
		        SUM(rectrcob.a_deducible),   
		        SUM(rectrcob.coaseguro),   
		        SUM(rectrcob.ahorro),   
		        SUM(rectrcob.monto_no_cubierto),   
		        SUM(rectrcob.co_pago)
		INTO 	v_facturado,   
		     	v_monto,   
		     	v_a_deducible,   
		     	v_coaseguro,   
		     	v_ahorro,   
		     	v_monto_no_cubierto,   
		     	v_co_pago
		FROM 	rectrcob
		WHERE 	no_tranrec = v_no_tranrec;


		SELECT  recicd.nombre
		INTO 	v_nombre_icd
		FROM 	recicd
		WHERE 	recicd.cod_icd = _cod_icd;  


		SELECT	chqchmae.no_cheque
		INTO 	v_no_cheque
		FROM 	chqchmae
		WHERE 	chqchmae.no_requis = _no_requis;

		         
		SELECT  cliclien.nombre
		INTO 	v_nombre_cliente
		FROM	cliclien
		WHERE	cliclien.cod_cliente = _cod_cliente;

		SELECT	rectitra.nombre
		INTO 	v_nombre_tipotran
		FROM	rectitra
		WHERE	rectitra.cod_tipotran = _cod_tipotran; 


		SELECT 	COUNT(*) 
		INTO	v_anulada
		FROM	rectrmae 
		WHERE	anular_nt = v_transaccion;

		IF v_anulada >= 1 THEN
			LET	v_anulada = 1;
		ELSE
			LET	v_anulada = 0;
		END IF

		RETURN  v_numrecla,
			v_no_reclamo,
			v_fecha_factura,
			v_fecha,
			v_no_tranrec,
			v_transaccion,
			v_actualizado_1,
			v_actualizado_2,
			v_nombre_icd,
			v_nombre_cliente,
			v_no_cheque,
			v_nombre_tipotran,
			v_no_factura,
			v_anular_nt,
			v_facturado,
			v_monto,
			v_a_deducible,
			v_coaseguro,
			v_ahorro,
			v_monto_no_cubierto,
			v_co_pago,
			v_anulada
		WITH RESUME;

	END FOREACH

END FOREACH

 END PROCEDURE