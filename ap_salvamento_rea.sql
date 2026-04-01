-- Consulta de Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE ap_salvamento_rea;

CREATE PROCEDURE ap_salvamento_rea()
RETURNING CHAR(15) AS comprobante,
          DATE AS fechatrx,
		  CHAR(50) AS descripcion,
		  CHAR(12) AS cod_cuenta,
		  CHAR(50) AS cuenta_comp,
		  DEC(15,2) AS debito_comp,
		  DEC(15,2) AS credito_comp,
		  CHAR(10) AS transaccion,
		  CHAR(20) AS reclamo,
		  CHAR(25) AS cod_cuenta_rem,
		  CHAR(50) AS cuenta_rem,
		  DEC(16,2) AS debito_rem,
		  DEC(16,2) AS credito_rem,
		  CHAR(20) AS documento,
		  CHAR(50) AS tipo_tr,
		  CHAR(50) AS tipo_pago,
		  DEC(16,2) AS monto_pag;	   

define _res_comprobante CHAR(15); 
define _res_fechatrx    DATE;
define _res_descripcion CHAR(50);
define _res_cuenta      CHAR(12);
define _res_debito      DEC(15,2);
define _res_credito     DEC(15,2);
define _no_registro       CHAR(10);
define _renglon         SMALLINT;
define _cuenta          CHAR(25);
define _debito          DEC(16,2);
define _credito	        DEC(16,2);
define _cta_nombre, _cta_nombre1  CHAR(50);
define _no_recibo       CHAR(10);
define _doc_remesa      CHAR(30);
define _tipo_mov        CHAR(1);
define _monto           DEC(16,2);
define _mov             CHAR(20);
define _res_notrx       INTEGER;

define _no_tranrec      CHAR(10); 
define _no_poliza       CHAR(10);
define _no_documento    CHAR(20);
define _transaccion     CHAR(10);
define _numrecla        CHAR(20);
define _cod_tipotran    CHAR(3);
define _cod_tipopago    CHAR(3);
define _tipo_tr         CHAR(50);
define _tipo_pag        CHAR(50);

SET ISOLATION TO DIRTY READ;

FOREACH
	select a.res_comprobante, 
	       a.res_notrx,
	       a.res_fechatrx, 
	       a.res_descripcion, 
	       a.res_cuenta, 
	       a.res_debito, 
	       a.res_credito, 
	       b.no_registro
	  into _res_comprobante, 
	       _res_notrx,
	       _res_fechatrx, 
	       _res_descripcion, 
	       _res_cuenta, 
	       _res_debito, 
	       _res_credito, 
	       _no_registro
	  from sac:cglresumen a, sac999:reacompasie b
	 where a.res_notrx = b.sac_notrx
	   and a.res_cuenta like '5440%'
	   and a.res_fechatrx >= '01/03/2019'
	   and a.res_fechatrx <= '31/03/2019'
	   and a.res_cuenta = b.cuenta

	    SELECT cta_nombre
		  INTO _cta_nombre1
		  FROM cglcuentas
		 WHERE cta_cuenta = _res_cuenta;

    FOREACH
		SELECT cuenta,
			   debito,
			   credito
		  INTO _cuenta,
			   _debito,
			   _credito	
		  FROM sac999:reacompasie 		  
		 WHERE no_registro = _no_registro
		   AND sac_notrx = _res_notrx
		   
		SELECT no_tranrec,
		       no_poliza,
			   no_documento
		  INTO _no_tranrec,
		       _no_poliza,
			   _no_documento
		  FROM sac999:reacomp
		 WHERE no_registro = _no_registro;
	  
	    SELECT cta_nombre
		  INTO _cta_nombre
		  FROM cglcuentas
		 WHERE cta_cuenta = _cuenta;
		 
		SELECT transaccion,
		       numrecla,
			   monto,
			   cod_tipotran,
			   cod_tipopago
		  INTO _transaccion,
		       _numrecla,
			   _monto,
			   _cod_tipotran,
			   _cod_tipopago
		  FROM rectrmae
		 WHERE no_tranrec = _no_tranrec;
		   
        SELECT nombre 
          INTO _tipo_tr
          FROM rectitra 
         WHERE cod_tipotran = _cod_tipotran;
 
        SELECT nombre 
          INTO _tipo_pag
          FROM rectipag 
         WHERE cod_tipopago = _cod_tipopago;
				
		RETURN _res_comprobante, 
	           _res_fechatrx, 
	           _res_descripcion, 
	           _res_cuenta, 
			   _cta_nombre1,
	           _res_debito, 
	           _res_credito, 
	           _transaccion,
			   _numrecla,
			   _cuenta,
			   _cta_nombre,
			   _debito,
			   _credito,
			   _no_documento,
		       _tipo_tr,
			   _tipo_pag,
			   _monto
	       WITH RESUME;   
	END FOREACH
END FOREACH
END PROCEDURE;