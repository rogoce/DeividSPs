-- Reporte
--
-- Creado: 09/09/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_che148;
CREATE PROCEDURE "informix".sp_che148(a_cia CHAR(3),a_desde date, a_hasta date, a_cod_chequera CHAR(3))
    RETURNING  DATE,
			   DATE,
	           DATE,                --Fecha
               CHAR(7),             --Periodo
			   CHAR(10),            --No_remesa
			   CHAR(10),            --No_recibo
			   CHAR(30),            --doc_remesa
			   DECIMAL(16,2),       --monto
			   DECIMAL(16,2),       --Prima
			   DECIMAL(16,2),       --Impuesto
			   VARCHAR(100);        --Desc_remesa
			   

DEFINE _compania          VARCHAR(50);
DEFINE _no_remesa         CHAR(10);
DEFINE _fecha             DATE;
DEFINE _periodo           CHAR(7);
DEFINE _no_reme           CHAR(10);
DEFINE _no_recibo         CHAR(10);
DEFINE _doc_remesa        CHAR(30);
DEFINE _monto             DECIMAL(16,2);
DEFINE _prima_neta        DECIMAL(16,2);
DEFINE _impuesto          DECIMAL(16,2);
DEFINE _desc_remesa       VARCHAR(100);

LET _compania = sp_sis01(a_cia);

FOREACH

  SELECT no_remesa
    INTO _no_remesa
    FROM cobremae
  WHERE cod_chequera = a_cod_chequera
    AND fecha between a_desde and a_hasta
    AND actualizado = 1

  FOREACH
  
      SELECT fecha,
             periodo,
             no_remesa,
             no_recibo,
             doc_remesa,
             monto,
             prima_neta,
             impuesto,
             desc_remesa
        INTO _fecha,
             _periodo,
             _no_reme,
             _no_recibo,
             _doc_remesa,
             _monto,
             _prima_neta,
             _impuesto,
             _desc_remesa
        FROM cobredet
       WHERE no_remesa = _no_remesa
	      AND no_poliza <> ''
		  AND actualizado = 1
          --and tipo_mov <> 'N' 		  
	   order by no_remesa
	   
	   RETURN  a_desde,
			   a_hasta,
	           _fecha,
			   _periodo,
			   _no_reme,
			   _no_recibo,
			   _doc_remesa,
			   _monto,
			   _prima_neta,
			   _impuesto,
			   _desc_remesa WITH RESUME;
	   
  END FOREACH;

END FOREACH;

END PROCEDURE;
