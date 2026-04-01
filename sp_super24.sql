-- Morosidad por Asegurado

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_super24;

--CREATE PROCEDURE sp_rwf10(a_cod_cliente CHAR(10))
CREATE PROCEDURE sp_super24()
RETURNING char(20) as poliza,
          varchar(100) as dueno,
          varchar(100) as asegurado,
          varchar(100) as pagador,
		  char(30) as cedula,
		  varchar(50) as pais,
		  date as vinculacion,
		  date as vigencia_inicial,
		  date as vigencia_final,
		  varchar(50) as ramo,
		  char(1) as nivel_riesgo,
		  char(2) as pep,
		  dec(16,2) as suma_asegurada,
		  dec(16,2) as prima_suscrita,
		  varchar(50) as frecuencia_pago,
		  varchar(50) as agente;


define _no_poliza         CHAR(10);
define _no_documento      char(20);
define _vigencia_inic     date;
define _vigencia_final    date;
define _fecha_suscripcion date;
define _cod_ramo          char(3);
define _prima_suscrita    dec(16,2);
define _suma_asegurada    dec(16,2);
define _cod_agente        char(5);
define _cod_contratante  CHAR(10);
define _cod_pagador       CHAR(10);
define _cod_perpago       char(3);
define _asegurado         varchar(100);
define _cedula            varchar(30);
define _code_pais         char(3);
define _cliente_pep       smallint;
define _date_added	      date;
define _pagador		      varchar(100);
define _perpago           varchar(50);
define _pais              varchar(50);
define _pep               char(2);
define _ramo              varchar(50);
define _agente            varchar(50);
		   
define v_filtros        char(255);

SET ISOLATION TO DIRTY READ;

LET _cliente_pep = 0;
--trae cant. de polizas vig. temp_perfil
CALL sp_pro03(
'001',
'001',
'31/05/2019',
'*') RETURNING v_filtros;

foreach
	SELECT no_poliza,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion,
		   cod_ramo,
		   prima_suscrita,
		   suma_asegurada,
		   cod_agente
	  INTO _no_poliza,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_suscripcion,
		   _cod_ramo,
		   _prima_suscrita,
		   _suma_asegurada,
		   _cod_agente
	  FROM temp_perfil

    SELECT cod_contratante,
	       cod_pagador,
		   cod_perpago
	  INTO _cod_contratante,
	       _cod_pagador,
		   _cod_perpago
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	SELECT nombre,
	       cedula,
		   code_pais,
		   cliente_pep,
		   date_added
	  INTO _asegurado,
	       _cedula,
		   _code_pais,
		   _cliente_pep,
		   _date_added
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;
	 
	SELECT nombre
	  INTO _pagador
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;
	 
	SELECT nombre
	  INTO _ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
	SELECT nombre
	  INTO _perpago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;
	 
	SELECT nombre
	  INTO _pais
	  FROM genpais
	 WHERE code_pais = _code_pais;
	 
	 IF _cliente_pep IS NULL THEN
		LET _cliente_pep = 0;
	 END IF
	 
	 IF _cliente_pep = 1 THEN
		LET _pep = "SI";
	 ELSE
		LET _pep = "NO";
	 END IF

    SELECT nombre
	  INTO _agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
	 
	LET _asegurado = REPLACE(_asegurado,"Á","A");
	LET _asegurado = REPLACE(_asegurado,"É","E");
	LET _asegurado = REPLACE(_asegurado,"Í","I");
	LET _asegurado = REPLACE(_asegurado,"Ó","O");
	LET _asegurado = REPLACE(_asegurado,"Ú","U");
	LET _asegurado = REPLACE(_asegurado,"Ñ","N");
	 
	LET _pagador = REPLACE(_pagador,"Á","A");
	LET _pagador = REPLACE(_pagador,"É","E");
	LET _pagador = REPLACE(_pagador,"Í","I");
	LET _pagador = REPLACE(_pagador,"Ó","O");
	LET _pagador = REPLACE(_pagador,"Ú","U");
	LET _pagador = REPLACE(_pagador,"Ñ","N");

	LET _agente = REPLACE(_agente,"Á","A");
	LET _agente = REPLACE(_agente,"É","E");
	LET _agente = REPLACE(_agente,"Í","I");
	LET _agente = REPLACE(_agente,"Ó","O");
	LET _agente = REPLACE(_agente,"Ú","U");
	LET _agente = REPLACE(_agente,"Ñ","N");
	
	RETURN _no_documento, 
		   _asegurado,  
   		   _asegurado,  
		   _pagador,
		   _cedula,
		   _pais,
		   _date_added,
		   _vigencia_inic,
		   _vigencia_final,
		   _ramo,
		   null,
		   _pep,
		   _suma_asegurada,
		   _prima_suscrita,
		   _perpago,
		   _agente
		   WITH RESUME;
end foreach

drop table temp_perfil;

END PROCEDURE;