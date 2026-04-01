-- Procedimiento para insertar en la tabla de Atencion al Cliente
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf49;
CREATE PROCEDURE "informix".sp_rwf49(a_incidente integer, a_descripcion CHAR(250), a_tipo_atencion SMALLINT, a_doc_atencion CHAR(10)) 
			RETURNING SMALLINT, CHAR(50);  

DEFINE _no_cheque           INTEGER;
DEFINE _cod_cliente			CHAR(10);
DEFINE _no_atencion			CHAR(10);
DEFINE _cod_compania	    CHAR(3);
DEFINE _no_parte    	    CHAR(3);
DEFINE _nombre 				CHAR(100);
DEFINE _telefono1			CHAR(10);
DEFINE _telefono2			CHAR(10);
DEFINE _no_requis     		CHAR(10);
DEFINE _transaccion    		CHAR(10);
DEFINE _cod_ruta    		CHAR(2);
DEFINE _wf_grupo    		CHAR(25);
DEFINE _member              CHAR(20);
DEFINE _error       		SMALLINT;

--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

SET LOCK MODE TO WAIT;

begin work;

IF a_tipo_atencion = 1 THEN

	LET _no_cheque = a_doc_atencion;

	SELECT no_requis,
	       cod_compania,
		   cod_ruta
	  INTO _no_requis,
		   _cod_compania,
		   _cod_ruta
	  FROM chqchmae
	 WHERE no_cheque = _no_cheque
	   AND pagado = 1
	   AND origen_cheque = "3"
	   AND en_firma = 2;

    FOREACH
		SELECT transaccion
		  INTO _transaccion
		  FROM chqchrec
		 WHERE no_requis = _no_requis

	    EXIT FOREACH;
	END FOREACH

	SELECT wf_grupo
	  INTO _wf_grupo
	  FROM chqruta
	 WHERE cod_ruta = _cod_ruta;

    LET _member = "";

  {  FOREACH
		SELECT REPLACE(member,"ancon.com/", "")
		  INTO _member
		  FROM wf_grupo
		 WHERE wf_grupo = _wf_grupo

	    EXIT FOREACH;
	END FOREACH

    LET _member = TRIM(_member);
	}
    SELECT cod_cliente
	  INTO _cod_cliente
	  FROM rectrmae
	 WHERE transaccion = _transaccion;

END IF

SELECT nombre,
       telefono1,
	   telefono2
  INTO _nombre,
	   _telefono1,
	   _telefono2
  FROM cliclien
 WHERE cod_cliente = _cod_cliente;


LET _no_atencion = sp_sis75(_cod_compania);

IF _no_atencion IS NULL OR _no_atencion = "" OR _no_atencion = "00000" THEN
	RETURN 1, "Error al generar # de atencion, verifique...";
END IF	


BEGIN
	ON EXCEPTION SET _error 
		rollback work;
	 	RETURN _error, "Error al insertar wf_atencion";         
	END EXCEPTION 
	INSERT INTO wf_atencion(
	no_atencion,
	nombre,
	telefono1,
	telefono2,
	user,
	fecha_in,
	descripcion,
	incidente,
	tipo_atencion,
	doc_atencion
	)
	VALUES(
	_no_atencion,
	_nombre,
	_telefono1,
	_telefono2,
	trim(_member),
	current,
	a_descripcion,
	a_incidente,
	a_tipo_atencion,
	a_doc_atencion
	);
END

commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE