-- Procedimiento que Genera la Remesa de las Tarjetas de Credito

-- Creado    : 06/09/2007 - Autor: Armando Moreno 
-- Modificado: 28/06/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob50b;

CREATE PROCEDURE "informix".sp_cob50b(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;

DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18); 
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _fec_rec         date;
define _fec_ano         smallint;
define _fec_mes			smallint;
define _cnt             smallint;

--SET DEBUG FILE TO "sp_cob50b.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Gestion de Rechazos de Tarjetas de Credito', '';         
END EXCEPTION           


--**********************************************************
-- Actualizacion de la Gestion para las Tarjetas Rechazadas*
--**********************************************************

LET _fecha_gestion = CURRENT YEAR TO SECOND;	
LET _null       = NULL;
let _fec_rec    = current;
let _fec_ano    = year(_fec_rec);
let _fec_mes    = month(_fec_rec);

FOREACH
 SELECT no_documento,
		motivo_rechazo,
		no_tarjeta
   INTO _no_documento,
		_motivo_rechazo,
		_no_tarjeta
   FROM cobtatra
  WHERE procesar = 0

	LET _no_poliza      = sp_sis21(_no_documento);
	LET _motivo_rechazo = "RECHAZO VISA: " || TRIM(_motivo_rechazo);
	LET _fecha_gestion  = _fecha_gestion + 1 UNITS SECOND;

	SELECT cod_pagador
  	  INTO _cod_pagador
      FROM emipomae
     WHERE no_poliza = _no_poliza;

	update cobtahab
	   set rechazada  = 1
	 where no_tarjeta = _no_tarjeta;

--  este update es para marcar la poliza como rechazada.
	UPDATE cobtacre
	   SET rechazada    = 1
	 WHERE no_tarjeta   = _no_tarjeta
	   AND no_documento = _no_documento;

	INSERT INTO cobgesti(
	no_poliza,
	fecha_gestion,
	desc_gestion,
	user_added,
	no_documento,
	fecha_aviso,
	tipo_aviso,
	cod_pagador
	)
	VALUES(
	_no_poliza,
	_fecha_gestion,
	_motivo_rechazo,
	a_user,
	_no_documento,
	_null,
	0,
	_cod_pagador
	);

	Update emipoliza
	   set motivo_rechazo = _motivo_rechazo
	 where no_documento	  = _no_documento;

	select COUNT(*)
	  into _cnt
	 from cobgesti
	where no_poliza            = _no_poliza
	  and year(fecha_gestion)  = _fec_ano
	  and month(fecha_gestion) = _fec_mes
	  and desc_gestion[1,4]    = 'RECH';

	if _cnt = 9 then
		Update emipoliza
		   set cant_rechazo = cant_rechazo + 1
		 where no_documento	= _no_documento;
	end if

END FOREACH

RETURN 0, 'Actualizacion Exitosa...','';

END 

END PROCEDURE;
