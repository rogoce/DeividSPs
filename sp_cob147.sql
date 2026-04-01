-- Reporte de Vencimiento de todos los tipos de tarjeta de credito.

-- Creado    : 07/06/2004 - Autor: Armando Moreno
-- Modificado: 07/06/2004 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob147;

CREATE PROCEDURE "informix".sp_cob147(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_periodo		CHAR(7)
) RETURNING CHAR(19),	 --_no_tarjeta,
			CHAR(7),	 --_fecha_exp,
			CHAR(100),	 --_nombre,
			CHAR(50),	 --v_compania_nombre,
			CHAR(50),	 --_nombre_agente,
			CHAR(50),	 --_direccion1,
			CHAR(50),	 --_direccion2,
			CHAR(100),	 --_direccion_cob,
			CHAR(10),	 --_telefono1,
			CHAR(10),	 --_telefono2,
			CHAR(10),	 --_celular,
			CHAR(10),	 --_fax,
			CHAR(50),	 --_e_mail,
			CHAR(10),	 --_telefono3,
			CHAR(20),	 --_apartado
			CHAR(30),	 --cedula
			CHAR(50),	 --banco
			CHAR(20),    -- no_documento
			DATE,        -- vigencia inicial
			DATE;        -- vigencia final

DEFINE _no_tarjeta       CHAR(19); 
DEFINE _fecha_exp        CHAR(7);  
DEFINE _no_documento     CHAR(20); 
DEFINE _tipo_tarjeta	 CHAR(1);
DEFINE _nombre           CHAR(100);
DEFINE _cod_cliente      CHAR(10); 

DEFINE _periodo_today    CHAR(7);
DEFINE v_periodo		 CHAR(7);
DEFINE v_compania_nombre CHAR(50); 
DEFINE _cod_banco		 CHAR(3);
DEFINE _nombre_banco     CHAR(50);

DEFINE _cod_formapag	 CHAR(3);
DEFINE _tipo_forma       SMALLINT;
DEFINE _cantidad         SMALLINT;
DEFINE _estatus_poliza	 CHAR(1);	
DEFINE _fecha_1_pago	 DATE;				

DEFINE _no_poliza		 CHAR(10);
DEFINE _cod_agente		 CHAR(10);
DEFINE _nombre_agente	 CHAR(50);
			
DEFINE v_fecha			 DATE;

define _direccion_cob	char(100);
define _direccion1	    char(50);
define _direccion2	    char(50);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);
define _vigencia_ini    date;
define _vigencia_final  date;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

LET v_fecha = TODAY;

IF MONTH(v_fecha) < 10 THEN
	LET v_periodo = YEAR(v_fecha) || '-0' || MONTH(v_fecha);
ELSE
	LET v_periodo = YEAR(v_fecha) || '-' || MONTH(v_fecha);
END IF 

SET ISOLATION TO DIRTY READ;

IF MONTH(TODAY) < 10 THEN
	LET _periodo_today = YEAR(TODAY) || '-0' || MONTH(TODAY);
ELSE
	LET _periodo_today = YEAR(TODAY) || '-' || MONTH(TODAY);
END IF

-- Procesa Todas las Tarjetas de Credito

FOREACH
 SELECT no_tarjeta,
		fecha_exp,
		nombre,
		cod_banco,
		tipo_tarjeta
   INTO _no_tarjeta,
		_fecha_exp,
		_nombre,
		_cod_banco,
		_tipo_tarjeta
   FROM cobtahab
  WHERE fecha_exp = a_periodo

 SELECT nombre
   INTO _nombre_banco
   FROM chqbanco
  WHERE cod_banco = _cod_banco;

    FOREACH
		 SELECT no_documento
		   INTO _no_documento
		   FROM cobtacre
		  WHERE no_tarjeta  = _no_tarjeta
			--exit foreach; Se elimina JAC

		LET _no_poliza = sp_sis21(_no_documento);
		
		 SELECT cod_contratante, 
				estatus_poliza,
				vigencia_inic,
				vigencia_final
		   INTO	_cod_cliente, 
				_estatus_poliza,
				_vigencia_ini,
				_vigencia_final
		   FROM	emipomae
		  WHERE	no_poliza = _no_poliza
			AND actualizado  = 1;
			
		IF _estatus_poliza <> "1" THEN -- Solo polizas vigentes
			CONTINUE FOREACH;
		END IF

		FOREACH
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
			EXIT FOREACH;
		END FOREACH

		SELECT nombre
		  INTO _nombre_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		call sp_cas012a(_cod_cliente)
				 returning _direccion1,
						   _direccion2,
						   _direccion_cob,
						   _telefono1,
						   _telefono2,
						   _celular,
						   _fax,
						   _e_mail,
						   _telefono3,
						   _apartado,
						   _cedula;
	 
		RETURN _no_tarjeta,
			   _fecha_exp,
			   _nombre,
			   v_compania_nombre,
			   _nombre_agente,
			   _direccion1,
			   _direccion2,
			   _direccion_cob,
			   _telefono1,
			   _telefono2,
			   _celular,
			   _fax,
			   _e_mail,
			   _telefono3,
			   _apartado,
			   _cedula,
			   _nombre_banco,
			   _no_documento,
			   _vigencia_ini,
			   _vigencia_final
			   WITH RESUME;
    END FOREACH
END FOREACH    
END PROCEDURE;
