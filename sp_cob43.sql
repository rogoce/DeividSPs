-- Generacion de los Lotes de las Tarjetas de Credito

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob43;

CREATE PROCEDURE "informix".sp_cob43(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _no_lote_char	CHAR(5);

DEFINE _no_tarjeta		CHAR(19);
DEFINE _codigo          CHAR(2);
DEFINE _monto			DEC(16,2);
DEFINE _fecha_exp		CHAR(7);
DEFINE _no_documento	CHAR(20);
DEFINE _nombre			CHAR(100);
--DEFINE _cod_cliente		CHAR(10);

DEFINE _max_por_lote	INTEGER;
DEFINE _max_por_tran	INTEGER;
DEFINE _cant_tran		INTEGER;
DEFINE _cant_lote       INTEGER;

DEFINE _saldo           DEC(16,2);
DEFINE _procesar        SMALLINT;
DEFINE _error_code      SMALLINT;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob43.trc"; 
--TRACE ON;                                                                

LET _max_por_lote = 99;
LET _max_por_tran = 998;
LET _codigo       = '40';

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Lotes';         
END EXCEPTION           

SELECT COUNT(*)
  INTO _cant_tran
  FROM cobtacre
 WHERE periodo = a_periodo;

IF _cant_tran IS NULL THEN
	LET _cant_tran = 0; 
END IF

IF _cant_tran = 0 THEN
	RETURN 1, 'No Existen Tarjetas para Procesar en esta Quincena ... '; 
END IF

IF _cant_tran > (_max_por_lote * _max_por_tran) THEN
	RETURN 1, 'Cantidad de Transacciones Excede el Maximo Permitido por el Banco ...'; 
END IF

DELETE FROM cobtatra;
DELETE FROM cobtalot;

LET _cant_lote = 0;
LET _cant_tran = 0;

LET _cant_lote    = _cant_lote + 1;
LET _no_lote_char = sp_set_codigo(5, _cant_lote);

-- Crea el Lote Inicial

INSERT INTO cobtalot
VALUES(
_no_lote_char,
a_fecha,
0,
0,
a_user,
'',
a_sucursal,
1      
);	

-- Procesa Todas las Tarjetas de Credito

FOREACH
 SELECT h.no_tarjeta,
		(c.monto + c.cargo_especial),
		h.fecha_exp,
		c.no_documento,
		h.nombre
   INTO _no_tarjeta,
		_monto,
		_fecha_exp,
		_no_documento,
		_nombre
   FROM cobtacre c, cobtahab h
  WHERE c.no_tarjeta = h.no_tarjeta
    AND c.periodo    = a_periodo
	AND c.procesar   = 1
	AND h.tipo_tarjeta <> "4"	--No debe tomar en cuanta las American Express.
  ORDER BY h.nombre

 	SELECT SUM(saldo)                   
 	  INTO _saldo                       
 	  FROM emipomae                     
 	 WHERE no_documento = _no_documento 
 	   AND actualizado  = 1;            

	IF _saldo IS NULL THEN
		LET _saldo = 0;
	END IF
{                                       
 	SELECT nombre                       
 	  INTO _nombre                      
 	  FROM cliclien                     
 	 WHERE cod_cliente = _cod_cliente;  
                                       
 	IF _monto > _saldo THEN             
 		LET _procesar = 0;              
 	ELSE                                
 		LET _procesar = 1;              
 	END IF                              
}                                       

	LET _procesar = 1;              
	LET _cant_tran = _cant_tran + 1;

	IF _cant_tran > _max_por_tran THEN

		LET _cant_tran    = 1;
		LET _cant_lote    = _cant_lote + 1;
		LET _no_lote_char = sp_set_codigo(5, _cant_lote);

		INSERT INTO cobtalot
		VALUES(
		_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'               ',
		a_sucursal,
		1      
		);	

	END IF

	INSERT INTO cobtatra
	VALUES(
	_no_lote_char,
	_cant_tran,
	_no_tarjeta,
	_codigo,
	_monto,
	_fecha_exp,
	_no_documento,
	_nombre,
	_saldo,
	_procesar,
	''
	);
   		   	
END FOREACH

FOREACH
 SELECT COUNT(*),
  	    SUM(monto),
	    no_lote
   INTO _cant_tran,
        _monto,
        _no_lote_char
   FROM cobtatra
  GROUP BY no_lote      

	UPDATE cobtalot
	   SET total_transac = _cant_tran,
	       total_monto   = _monto
     WHERE no_lote       = _no_lote_char;
     
END FOREACH
       	   	
RETURN 0, 'Actualizacion Exitosa ...'; 

END 

END PROCEDURE;
