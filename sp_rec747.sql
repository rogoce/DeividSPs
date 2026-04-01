-- Procedimiento para buscar clientes con registro en ponderación
--
-- creado: 22/06/2023 - Autor: Amado Perez M.

DROP PROCEDURE sp_rec747;
CREATE PROCEDURE "informix".sp_rec747(a_no_reclamo CHAR(10))
	RETURNING 	  CHAR(10) as transaccion,
                  DATE     as fecha,
                  CHAR(7)  as periodo,
                  VARCHAR(30) as tipo_trans,
				  VARCHAR(30) as tipo_pago,
				  VARCHAR(50) as concepto,
				  DEC(16,2) as monto,
				  DEC(16,2) as variacion,
				  INTEGER as no_cheque,
				  INTEGER as incidente,
				  CHAR(10) as no_requis,
				  CHAR(10) as no_remesa,
				  INTEGER as renglon,
				  SMALLINT as pagado,
				  VARCHAR(100) as pagado_a,
				  CHAR(10) as no_ajuste;  

DEFINE _no_tranrec		CHAR(10);
DEFINE _transaccion		CHAR(10);   
DEFINE _fecha			DATE;   
DEFINE _periodo			CHAR(7);   
DEFINE _cod_tipotran	CHAR(3);   
DEFINE _cod_tipopago	CHAR(3);  
DEFINE _monto			DEC(16,2);
DEFINE _variacion		DEC(16,2);   
DEFINE _pagado			SMALLINT;   
DEFINE _no_requis		CHAR(10);  
DEFINE _no_remesa		CHAR(10);   
DEFINE _renglon			INTEGER;
DEFINE _tipotran		VARCHAR(30);
DEFINE _tipopago		VARCHAR(30);
DEFINE _nombre			VARCHAR(100);
DEFINE _no_cheque		INTEGER;  
DEFINE _incidente		INTEGER;
DEFINE _no_ajus_orden	CHAR(10);
DEFINE _cod_concepto	CHAR(3);
DEFINE _concepto        VARCHAR(50);
DEFINE _cod_cliente     CHAR(10); 
	   
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_par380.trc";
--TRACE ON;

FOREACH
	SELECT no_tranrec,
		   transaccion,   
		   fecha,   
		   periodo,   
		   cod_tipotran,   
		   cod_tipopago,   
		   monto,   
		   variacion,   
		   pagado,   
		   no_requis,   
		   no_remesa,   
		   renglon,
           cod_cliente,
           wf_incidente		   
	  INTO _no_tranrec,
		   _transaccion,   
		   _fecha,   
		   _periodo,   
		   _cod_tipotran,   
		   _cod_tipopago,   
		   _monto,   
		   _variacion,   
		   _pagado,   
		   _no_requis,   
		   _no_remesa,   
		   _renglon,
		   _cod_cliente,
		   _incidente
	  FROM rectrmae  
	 WHERE no_reclamo = a_no_reclamo  
	   AND actualizado = 1    
  ORDER BY fecha, transaccion ASC   
	
    SELECT nombre
      INTO _tipotran
      FROM rectitra
     WHERE cod_tipotran = _cod_tipotran;	  

    SELECT nombre
      INTO _tipopago
      FROM rectipag
     WHERE cod_tipopago = _cod_tipopago;	  

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
    SELECT no_cheque
      INTO _no_cheque	
      FROM chqchmae
     WHERE no_requis = _no_requis;

	SELECT no_ajus_orden
      INTO _no_ajus_orden
      FROM recordam
     WHERE no_requis = _no_requis;
	 
	SELECT FIRST 1 cod_concepto
      INTO _cod_concepto
      FROM rectrcon
     WHERE no_tranrec = _no_tranrec;
	 
	SELECT nombre
      INTO _concepto
      FROM recconce
     WHERE cod_concepto = _cod_concepto;
	
	RETURN _transaccion, 
	       _fecha, 
		   _periodo, 
		   _tipotran,
		   _tipopago,
		   _concepto,
		   _monto,   
		   _variacion,
		   _no_cheque,
		   _incidente,
		   _no_requis,   
		   _no_remesa,   
		   _renglon,
		   _pagado,
		   _nombre,
		   _no_ajus_orden WITH RESUME; 
END FOREACH	 
   	 


END PROCEDURE
