-- Verificar cuales polizas del grupo shahani son coaseguro mayoritario
-- 
-- Creado    : 28/11/2006 - Autor: Demetrio Hurtado Almanza
-- modificado: 28/11/2006 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob200;

CREATE PROCEDURE "informix".sp_cob200()
RETURNING CHAR(20),
          char(3),
		  char(50),
		  dec(16,2),
		  char(5),
		  char(50),
		  char(1),
		  dec(5,2),
		  dec(5,2);

DEFINE _error_code      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_cliente   	CHAR(10);
DEFINE _cod_agente   	CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _tipo_remesa     CHAR(1);
DEFINE a_no_remesa 		CHAR(10);
define _ano_char		char(4);
define _null			char(1);

define _dia				char(2);
define _mes				char(2);
define _ano				char(4);
define _estoy           char(50);

define _cod_tipoprod	char(3);
define _nombre_tipoprod	char(50);

define _porc_comis_agt   	dec(5,2);
define _porc_partic_agt	 	dec(5,2);
define _tipo_agente			char(1);

--set debug file to "sp_cob125.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT poliza,
        saldo
   INTO _no_documento,
        _saldo
   FROM deivid_tmp:shahani

	-- Poliza en Credito

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_tipoprod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	foreach
	 Select	porc_comis_agt,
			porc_partic_agt,
			cod_agente
	   Into	_porc_comis_agt,
			_porc_partic_agt,
			_cod_agente
	   From emipoagt
	  Where	no_poliza = _no_poliza

		select tipo_agente,
		       nombre
		  into _tipo_agente,
		       _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		return _no_documento,
		       _cod_tipoprod,
		       _nombre_tipoprod,
		       _saldo,
			   _cod_agente,
			   _nombre_agente,
			   _tipo_agente,
			   _porc_partic_agt,
			   _porc_comis_agt
		       with resume;

	end foreach

	       	  
END FOREACH
 
END PROCEDURE;
