-- Procedimiento para bloquear a los clientes por la siniestralidad
--
-- creado: 18/06/2022 - Autor: Amado Perez M.

DROP PROCEDURE sp_rec346;
CREATE PROCEDURE "informix".sp_rec346()
	RETURNING CHAR(10) as cod_cliente, 
	          VARCHAR(100) as nombre, 
			  CHAR(3) as cod_mala_refe,
			  VARCHAR(50) as referencia,
			  SMALLINT as bloq_auto;  --Incurrido bruto

DEFINE _cod_asegurado        CHAR(10);
DEFINE _cod_reclamante       CHAR(10);
DEFINE _cod_conductor        CHAR(10);
DEFINE _no_reclamo           CHAR(10);
DEFINE _cod_cliente          CHAR(10);
DEFINE _cnt                  SMALLINT;
DEFINE _numrecla             CHAR(20);
DEFINE _no_documento         CHAR(20);
DEFINE _nombre               varchar(100);
DEFINE _no_unidad            CHAR(5);
DEFINE _tipo_persona         CHAR(1);
DEFINE _cod_mala_refe        CHAR(3);
DEFINE _referencia           VARCHAR(50);
DEFINE _bloq_auto            SMALLINT;
DEFINE _mala_referencia      SMALLINT;
DEFINE _monto_total          DEC(16,2);
DEFINE _variacion            DEC(16,2);
DEFINE _monto_cobrado        DEC(16,2);
DEFINE _cod_coasegur         CHAR(3);      
DEFINE _porc_coas            DECIMAL;  
DEFINE _porc_partic_coas     DECIMAL;
DEFINE _sini_pagado          DEC(16,2);
DEFINE _reserva              DEC(16,2);
DEFINE _prima_cobrada        DEC(16,2);
DEFINE _no_poliza            CHAR(10);


FOREACH
 SELECT cod_cliente,
        nombre
   INTO _cod_cliente,
        _nombre
   FROM tmp_bloq_cli

  let _cod_mala_refe = NULL;
  let _referencia = NULL;
  let _bloq_auto = 0;

  select tipo_persona,
         cod_mala_refe,
         mala_referencia		 
	into _tipo_persona,
	     _cod_mala_refe,
		 _mala_referencia
	from cliclien
   where cod_cliente = _cod_cliente;

  if _tipo_persona <> 'N' then
	continue foreach;
  end if	

  if _mala_referencia is null then
	let _mala_referencia = 0;
  end if 
	 
  if _mala_referencia = 1 then	   
	continue foreach;
  end if  
   
  select nombre,
	     bloqemirenaut
	into _referencia,
	     _bloq_auto
	from climalare
   where cod_mala_refe = '008';
   
  UPDATE cliclien
    SET cod_mala_refe = '008', -- Alta Siniestralidad - Auto
         mala_referencia = 1,
         user_mala_refe = 'DEIVID' -- Alta Siniestralidad - Auto
   WHERE cod_cliente = _cod_cliente; 

  UPDATE tmp_bloq_cli
     SET procesado = 1
   WHERE cod_cliente = _cod_cliente; 
      
	  RETURN _cod_cliente,
	         _nombre,
			 _cod_mala_refe,
			 _referencia,
			 _bloq_auto with resume;
	 
END FOREACH

END PROCEDURE
