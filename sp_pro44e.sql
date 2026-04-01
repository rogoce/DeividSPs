-- ENDOSO DE COASEGURO
--
-- Creado    : 20/10/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 09/07/2001 - Autor: Amado Perez Mendoza
-- Modificado: 09/09/2002 - Autor: Armando Moreno impresion del no_motor,no_chasis del endoso actual
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44e;

CREATE PROCEDURE "informix".sp_pro44e(a_poliza CHAR(10), a_endoso CHAR(5))
			RETURNING   CHAR(100),			 --	v_contratante,
						CHAR(20),			 --	v_poliza,
						CHAR(10),
						CHAR(10);

DEFINE v_contratante   CHAR(100);
DEFINE v_asegurado     CHAR(100);
DEFINE v_direccion	   CHAR(50);
DEFINE v_dir_cobro     CHAR(50);
DEFINE v_dir_postal    CHAR(20);
DEFINE v_telefono1     CHAR(10);
DEFINE v_telefono2	   CHAR(10);
DEFINE v_fax		   CHAR(10);
DEFINE v_email         CHAR(50);
DEFINE v_ramo		   CHAR(50);
DEFINE v_subramo	   CHAR(50);
DEFINE v_suscripcion   DATE;
DEFINE v_vigen_ini     DATE;
DEFINE v_vigen_fin	   DATE;
DEFINE v_suma_aseg	   DEC(16,2);
DEFINE v_unidad		   CHAR(5);
DEFINE v_poliza		   CHAR(20);
DEFINE v_factura	   CHAR(10);
DEFINE v_prima		   DEC(16,2);
DEFINE v_descuento	   DEC(16,2);
DEFINE v_recargo	   DEC(16,2);
DEFINE v_prima_neta    DEC(16,2);
DEFINE v_impuesto	   DEC(16,2);
DEFINE v_prima_bruta   DEC(16,2);
DEFINE v_motor         CHAR(30);
DEFINE v_chasis        CHAR(30);
DEFINE v_ano_auto      INT;
DEFINE v_marca		   CHAR(50);
DEFINE v_modelo        CHAR(50);
DEFINE v_placa         CHAR(10);
DEFINE v_tipo          CHAR(50);
DEFINE v_vig_ini_pol   DATE;
DEFINE v_vig_fin_pol   DATE;
DEFINE v_tipo_factura  CHAR(10);
DEFINE v_desc_factura  CHAR(50);
DEFINE v_fecha_letra   CHAR(30);
DEFINE v_dia           CHAR(2);
DEFINE v_ano           CHAR(4);
DEFINE v_cedula        CHAR(30);
DEFINE v_vig_i_end     DATE;
DEFINE v_vig_f_end	   DATE;
DEFINE v_nuevo         SMALLINT;

DEFINE _tipo_mov         INT;
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_modelo       CHAR(5);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_tipoauto     CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _cod_endomov      CHAR(3);
DEFINE _dia              CHAR(2);
DEFINE _ano              CHAR(4);

SET ISOLATION TO DIRTY READ;

	-- Lectura de Endedmae

	SELECT no_factura,
	       no_documento
	  INTO v_factura,
		   v_poliza
	  FROM endedmae
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso;

	-- Lectura del contratante

	SELECT cod_pagador
	  INTO _cod_contratante
	  FROM emipomae
	 WHERE no_poliza = a_poliza;

	SELECT nombre
	  INTO v_contratante
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	RETURN v_contratante,
		   v_poliza,	
		   v_factura,
		   a_poliza
		   WITH RESUME; 

END PROCEDURE
