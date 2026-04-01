-- Reporte de los Pagos a los Medicos de las Polizas de Salud del Plan Dental

-- Creado    : 14/09/2005 - Autor: Amado Perez Mendoza
-- Modificado: 14/09/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - d_cheq_sp_che29_crit - DEIVID, S.A.

DROP PROCEDURE sp_che30;

CREATE PROCEDURE sp_che30(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7), a_usuario CHAR(8)) 
RETURNING CHAR(50),
          CHAR(10),
          VARCHAR(100),
          CHAR(20),
          DATE,
          DATE,
          VARCHAR(100),
          SMALLINT,
          DEC(16,2),
          DEC(16,2);

DEFINE _doc_poliza          CHAR(20); 
DEFINE _monto_pagado        DEC(16,2);
DEFINE _fecha            	DATE;
DEFINE _no_poliza           CHAR(10);
DEFINE _no_unidad           CHAR(5); 
DEFINE _cod_tipoprod        CHAR(3);  
DEFINE _tipo_produccion     SMALLINT; 
DEFINE _cod_ramo	        CHAR(3);  
DEFINE _cod_subramo	        CHAR(3);  
DEFINE _cod_doctor          CHAR(10); 
DEFINE _comision 			DEC(16,2);
DEFINE _nombre_doctor  		VARCHAR(100);
DEFINE _nombre_asegurado	VARCHAR(100);
DEFINE _cantidad		    SMALLINT; 
DEFINE _cant_depend			SMALLINT;
DEFINE _cod_asegurado		CHAR(10);
DEFINE _vigencia_inic      	DATE;
DEFINE _vigencia_final     	DATE;
DEFINE _nombre_compania     CHAR(50);

CREATE TEMP TABLE tmp_pagos(
		no_documento    CHAR(18)	NOT NULL,
		cod_asegurado   CHAR(10)	NOT NULL,
		monto_pagado    DEC(16,2)	NOT NULL,
		no_poliza       CHAR(10)    NOT NULL,
		vigencia_inic	DATE,
		vigencia_final  DATE,
		cod_doctor      CHAR(10)    NOT NULL,
		cantidad        INT,
		pago    		DEC(16,2)	NOT NULL
		) WITH NO LOG;

--SET DEBUG FILE TO "sp_pro30.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET _nombre_compania = sp_sis01(a_compania); 

FOREACH
 SELECT doc_remesa, 
        monto,
		fecha,
		no_poliza
   INTO _doc_poliza,
    	_monto_pagado,
		_fecha,
		_no_poliza
   FROM cobredet
  WHERE actualizado  = 1			              -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')           	  -- Pago de Prima(P)
    AND periodo      = a_periodo 

--	Let _no_poliza = sp_sis21(_doc_poliza);

	SELECT cod_tipoprod,
	       cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  INTO _cod_tipoprod,
	       _cod_ramo,
		   _cod_subramo,
		   _cod_asegurado,
		   _vigencia_inic,
		   _vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 4 Or _cod_ramo <> "018" Or (_cod_ramo = "018" And _cod_subramo <> "015") then	--Reaseguro Asumido
		continue foreach;
	End if

	LET _cantidad = 0;

    FOREACH
		SELECT cod_doctor,
		       no_unidad
		  INTO _cod_doctor,
		       _no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		   AND activo = 1

           LET _cantidad = _cantidad + 1;

           LET _cant_depend = 0; 

		SELECT COUNT(*)
		  INTO _cant_depend
		  FROM emidepen
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1;

		   LET _cantidad = _cantidad + _cant_depend; 
	END FOREACH

	INSERT INTO tmp_pagos(
	no_documento,
	cod_asegurado,
	monto_pagado,
	no_poliza, 
	vigencia_inic,
	vigencia_final,
	cod_doctor,
	cantidad,
	pago  
	)
	VALUES(
	_doc_poliza,
	_cod_asegurado,
	_monto_pagado,
	_no_poliza,
	_vigencia_inic,
	_vigencia_final,
	_cod_doctor,
	_cantidad,
	_monto_pagado * 0.5
	);

END FOREACH

FOREACH
	SELECT no_documento,
	       cod_asegurado,
		   monto_pagado,
		   no_poliza, 
		   vigencia_inic,
		   vigencia_final,
		   cod_doctor,
		   cantidad,
		   pago  
      INTO _doc_poliza,
	       _cod_asegurado,
		   _monto_pagado,
		   _no_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_doctor,
		   _cantidad,
		   _comision
	  FROM tmp_pagos
  ORDER BY cod_doctor, no_documento

	SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	SELECT nombre
	  INTO _nombre_doctor
	  FROM cliclien
	 WHERE cod_cliente = _cod_doctor;

  RETURN _nombre_compania,
         _cod_doctor,
		 _nombre_doctor,
		 _doc_poliza, 
		 _vigencia_inic,
		 _vigencia_final,
		 _nombre_asegurado, 
		 _cantidad,
		 _monto_pagado,  
		 _comision
    	 WITH RESUME;

END FOREACH

DROP TABLE tmp_pagos;
END PROCEDURE;
