-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che117('2',0)

DROP PROCEDURE sp_che117;
CREATE PROCEDURE sp_che117(a_origen char(1), a_pagado  smallint) 
RETURNING  char(5),					--cod_agente		
		   decimal(16,2),			--monto			
		   char(30),				--cedula			
		   char(1),					--tipo_cuenta		
		   char(18),				--cod_cuenta		
		   integer,					--ruta_numero		
		   char(10),				--no_requis		
		   integer,					--pagado			
		   integer,					--no_cheque		
		   char(7),					--periodo			
		   date,					--fecha_impresion
		   char(50),				--e_mail 			
		   char(100),				--a_nombre_de		
		   smallint,				--cnt			
		   smallint,				--ver			
		   decimal(16,2);			--monto_cta	

DEFINE 	_cod_agente		    char(5);
DEFINE 	_monto			    decimal(16,2);
DEFINE 	_cedula			    char(30);
DEFINE 	_tipo_cuenta		char(1);
DEFINE 	_cod_cuenta		    char(18);
DEFINE 	_ruta_numero		integer;
DEFINE 	_no_requis		    char(10);
DEFINE 	_pagado			    integer;
DEFINE 	_no_cheque		    integer;
DEFINE 	_periodo			char(7);
DEFINE 	_fecha_impresion	date;
DEFINE 	_e_mail 			char(50);
DEFINE 	_a_nombre_de		char(100);
DEFINE 	_cnt				smallint;
DEFINE 	_ver				smallint;
DEFINE 	_monto_cta		    decimal(16,2);
DEFINE  _agente_agrupado    char(5);
DEFINE  _cadena             CHAR(30);
DEFINE  _contador           smallint;
DEFINE 	_caracter           char(1);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

CREATE TEMP TABLE tmp_cta(
	cod_cuenta	    char(18),
	agente_agrupado char(5) 	
	) WITH NO LOG;

CREATE TEMP TABLE tmp_ruc_ced(
	cedula	        char(30),
	agente_agrupado char(5) 	
	) WITH NO LOG;

FOREACH
	SELECT chqchmae.cod_agente,
	       chqchmae.monto,
	       agtagent.cedula,
	       agtagent.tipo_cuenta,
	       agtagent.cod_cuenta,
	       chqbanco.ruta_numero,
	       chqchmae.no_requis,
	       chqchmae.pagado,
	       chqchmae.no_cheque,
	       chqchmae.periodo,
	       chqchmae.fecha_impresion,
	       agtagent.e_mail,
	       chqchmae.a_nombre_de,
	       agtagent.agente_agrupado
	  INTO _cod_agente,
	       _monto,
		   _cedula,
		   _tipo_cuenta,
		   _cod_cuenta,
		   _ruta_numero,
		   _no_requis,
		   _pagado,
		   _no_cheque,
		   _periodo,
		   _fecha_impresion,
		   _e_mail,
		   _a_nombre_de,
		   _agente_agrupado
	  FROM chqchmae, agtagent, chqbanco
	 WHERE ( agtagent.cod_agente = chqchmae.cod_agente ) and
		   ( chqbanco.cod_banco = agtagent.cod_banco ) and
		   ( ( chqchmae.origen_cheque = a_origen ) AND
		   ( chqchmae.tipo_requis = 'A' ) AND
		   ( chqchmae.pagado = a_pagado ) AND
		   ( chqchmae.autorizado = 1 ) )
  order by	5,2 Desc

	let _cnt = 0;
	let _ver = 0;
	let _monto_cta = 0;

	select count(*)
	  into _cnt
	  from tmp_cta
	 where cod_cuenta = _cod_cuenta
	   and agente_agrupado = _agente_agrupado;

    if _cnt = 0 then

	  SELECT sum(chqchmae.monto)
		INTO _monto_cta
		FROM chqchmae, agtagent, chqbanco
	   WHERE ( agtagent.cod_agente = chqchmae.cod_agente ) and
			 ( chqbanco.cod_banco = agtagent.cod_banco ) and
			 ( ( chqchmae.origen_cheque = a_origen ) AND
			 ( chqchmae.tipo_requis = 'A' ) AND
			 ( chqchmae.pagado = a_pagado ) AND
			 ( chqchmae.autorizado = 1 ) ) AND
			 ( agtagent.cod_cuenta = _cod_cuenta ) AND
			 ( agtagent.agente_agrupado = _agente_agrupado);
			 
		if a_origen = '8' and _cod_agente = '02825' then	--Bonificacion de cobranza, caso especial Lizsenell Bernal correo de Nadhyaly 21/11/2023, se debe pagar a esta cuenta. AMM.
			let _tipo_cuenta = 'S';
			let _cod_cuenta  = '0401013707834';
			let _ruta_numero = 71;
			let _cedula      = '8-314-920';
			let _a_nombre_de = 'LIZSENELL BERNAL';
	    end if	 

		INSERT INTO tmp_cta( cod_cuenta, agente_agrupado)
		VALUES ( _cod_cuenta, _agente_agrupado);

		INSERT INTO tmp_ruc_ced( cedula, agente_agrupado)
		VALUES ( _cedula, _agente_agrupado);

		let _ver = 1;
    end if

	select count(*)
	  into _cnt
	  from tmp_cta
	 where cod_cuenta = _cod_cuenta;

	if _cnt > 1 then
		let _ver = -1;
	end if

	select count(*)
	  into _cnt
	  from tmp_ruc_ced
	 where cedula = _cedula;

	if _cnt > 1 then
		let _ver = -1;
	end if
	
	let _cedula = replace(trim(_cedula),'.','');
	let _cedula = replace(trim(_cedula),'*','');
	let _cedula = replace(trim(_cedula),'$','');
	let _cedula = replace(trim(_cedula),'/','');
	let _cedula = replace(trim(_cedula),'--','');
	
	for _contador = 30 to 1 step -1
		let _caracter = SUBSTR(_cedula, _contador,1);
		if _caracter in ('1','2','3','4','5','6','7','8','9','0') then
			exit for;
		else
			let _cadena = SUBSTR(_cedula, 1, _contador - 1);
		end if
	end for
	
	let _cedula = trim(_cadena);	

  RETURN  _cod_agente,
		  _monto,
		  _cedula,
		  _tipo_cuenta,
		  _cod_cuenta,
		  _ruta_numero,
		  _no_requis,
		  _pagado,
		  _no_cheque,
		  _periodo,
		  _fecha_impresion,
		  _e_mail,
		  _a_nombre_de,
		  _cnt,
		  _ver,
		  _monto_cta
		  WITH RESUME;
		      
END FOREACH;

DROP TABLE tmp_cta;
DROP TABLE tmp_ruc_ced;
END PROCEDURE 