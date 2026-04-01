-- Consulta de Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE ap_salvamento;

CREATE PROCEDURE ap_salvamento()
RETURNING CHAR(15) AS comprobante,
          DATE AS fechatrx,
		  CHAR(50) AS descripcion,
		  CHAR(12) AS cod_cuenta,
		  CHAR(50) AS cuenta_comp,
		  DEC(15,2) AS debito_comp,
		  DEC(15,2) AS credito_comp,
		  CHAR(10) AS no_remesa,
		  SMALLINT AS renglon,
		  CHAR(25) AS cod_cuenta_rem,
		  CHAR(50) AS cuenta_rem,
		  DEC(16,2) AS debito_rem,
		  DEC(16,2) AS credito_rem,
		  CHAR(10) AS recibo,
		  CHAR(30) AS documento,
		  CHAR(20) AS movimiento,
		  DEC(16,2) AS monto_pag;	   

define _res_comprobante CHAR(15); 
define _res_fechatrx    DATE;
define _res_descripcion CHAR(50);
define _res_cuenta      CHAR(12);
define _res_debito      DEC(15,2);
define _res_credito     DEC(15,2);
define _no_remesa       CHAR(10);
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

SET ISOLATION TO DIRTY READ;

FOREACH
	select a.res_comprobante, 
	       a.res_notrx,
	       a.res_fechatrx, 
	       a.res_descripcion, 
	       a.res_cuenta, 
	       a.res_debito, 
	       a.res_credito, 
	       b.no_remesa
	  into _res_comprobante, 
	       _res_notrx,
	       _res_fechatrx, 
	       _res_descripcion, 
	       _res_cuenta, 
	       _res_debito, 
	       _res_credito, 
	       _no_remesa
	  from sac:cglresumen a, sac999:cobasien b
	 where a.res_notrx = b.sac_notrx
	   and a.res_cuenta like '4190%'
	   and a.res_fechatrx >= '01/03/2019'
	   and a.res_fechatrx <= '31/03/2019'
	   and a.res_cuenta = b.cuenta

	    SELECT cta_nombre
		  INTO _cta_nombre1
		  FROM cglcuentas
		 WHERE cta_cuenta = _res_cuenta;

    FOREACH
		SELECT renglon,
			   cuenta,
			   debito,
			   credito
		  INTO _renglon,
			   _cuenta,
			   _debito,
			   _credito	
		  FROM sac999:cobasien 		  
		 WHERE no_remesa = _no_remesa
		   AND sac_notrx = _res_notrx
	  
	    SELECT cta_nombre
		  INTO _cta_nombre
		  FROM cglcuentas
		 WHERE cta_cuenta = _cuenta;
		 
		SELECT no_recibo,
		       doc_remesa,
			   tipo_mov,
			   monto
		  INTO _no_recibo,
		       _doc_remesa,
			   _tipo_mov,
			   _monto
		  FROM cobredet
		 WHERE no_remesa = _no_remesa
		   AND renglon = _renglon;
		   
		 IF _tipo_mov = 'R' THEN
		  LET _mov = 'Pago de Recupero';
		 ELIF _tipo_mov = 'S' THEN
		  LET _mov = 'Pago de Salvamento';
		 ELIF _tipo_mov = 'M' THEN
		  LET _mov = 'Afectacion Catalogo';
		 ELIF _tipo_mov = 'D' THEN
		  LET _mov = 'Pago de Deducible';
		 ELSE
		  LET _mov = _tipo_mov;
		 END IF
		 	    	
		RETURN _res_comprobante, 
	           _res_fechatrx, 
	           _res_descripcion, 
	           _res_cuenta, 
			   _cta_nombre1,
	           _res_debito, 
	           _res_credito, 
	           _no_remesa,
			   _renglon,
			   _cuenta,
			   _cta_nombre,
			   _debito,
			   _credito,
			   _no_recibo,
		       _doc_remesa,
			   _mov,
			   _monto
	       WITH RESUME;   
	END FOREACH
END FOREACH
END PROCEDURE;