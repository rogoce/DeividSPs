-- Seleccion de las polizas con perdida total (terceros o asegurados)
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 20/09/2002 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob91;

CREATE PROCEDURE "informix".sp_cob91(
a_compania 		CHAR(3),
a_periodo1      CHAR(7),
a_periodo2      CHAR(7)
) RETURNING	CHAR(10),  -- no_poliza
			CHAR(20),  -- No. Documento
			CHAR(50),  -- nombre cliente
			CHAR(50),  -- nombre tercero
			SMALLINT;  -- perd_total

DEFINE _no_poliza        CHAR(10);
DEFINE _no_documento     CHAR(20);
DEFINE _perd_total       SMALLINT;
DEFINE _cod_cliente      CHAR(10);
DEFINE _estatus_poliza   SMALLINT;
DEFINE _no_reclamo       CHAR(18);
DEFINE _nombre_tercero   CHAR(50);
DEFINE _nombre_cliente   CHAR(50);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT no_poliza,
        perd_total,
		no_documento,
		cod_contratante,
		estatus_poliza
   INTO _no_poliza,
        _perd_total,
		_no_documento,
		_cod_cliente,
		_estatus_poliza
   FROM emipomae
  WHERE perd_total   = 1
    AND actualizado  = 1
	AND periodo      >= a_periodo1
	AND periodo      <= a_periodo2

  FOREACH
   SELECT no_reclamo       
     INTO _no_reclamo
	 FROM recrcmae
	WHERE no_poliza = _no_poliza
	  

   SELECT nombre
     INTO _nombre_cliente
	 FROM cliclien
	WHERE cod_cliente = _cod_cliente;

   SELECT nombre_tercero
     INTO _nombre_tercero
	 FROM recrecup
	WHERE no_reclamo = _no_reclamo;

  RETURN _no_poliza,
         _no_documento,
		 _nombre_cliente,
		 _nombre_tercero,
		 _perd_total
	 With Resume;

END FOREACH
END FOREACH

END PROCEDURE;





