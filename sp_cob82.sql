-- Reportes de los ACH Rechazados

-- Creado: 23/01/2002 - Autor: Armando Moreno M.
--Este reporte usa la funcion f_dw_a_xls_rea en powerbuilder, para el ordenamiento al exportase a Excel. AMM  03/10/2025

DROP PROCEDURE sp_cob82;
CREATE PROCEDURE sp_cob82(a_compania CHAR(3), a_sucursal CHAR(3)) 
RETURNING   CHAR(20),	--poliza
			CHAR(100),	--pagador
			CHAR(17),	--cuenta
			CHAR(50),	--banco
			DEC(16,2),	--monto
			DEC(16,2),	--cargo especial
			CHAR(100),	--motivo
			CHAR(50),	--cia
			INTEGER,	--tran
			integer,
			char(50),
			VARCHAR(50),
			char(50),
			date,
			date,
			smallint,
			date,
			char(10),
			char(10),
			char(10),
			char(10),
			char(50);

DEFINE _no_documento     CHAR(20); 
DEFINE _nombre_pagador   CHAR(100);
DEFINE _no_cuenta        CHAR(17); 
DEFINE _cod_banco,_cod_ramo   CHAR(3);  
DEFINE _monto,_cargo     DEC(16,2);
DEFINE _nombre_banco,_n_ramo     CHAR(50); 
DEFINE _cod_agente       CHAR(5);  
DEFINE _cod_cobrador     CHAR(3);
DEFINE _periodo		     CHAR(1);
DEFINE _no_poliza        CHAR(10); 
DEFINE _cod_pagador      CHAR(10);
DEFINE v_compania_nombre CHAR(50); 
DEFINE _motivo_rechazo   CHAR(100);
DEFINE _no_tran		     INTEGER;
define _tipo,_cnt        integer;
define _n_corredor       char(50);
DEFINE _cod_vendedor,_cod_vendedor2     char(3);
DEFINE _zona_ventas      VARCHAR(50);
define _vig_ini,_vig_fin,_fecha_cobroach date;
define _dia_cobro        smallint;
define _tel1,_tel2,_celular,_celular2 char(10);
define _e_mail           char(50);


SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania); 
let _tipo = 0;

FOREACH 
	SELECT no_cuenta,
	       cod_pagador,
		   motivo,
		   nombre_pagador,
		   periodo,
		   monto,
		   cargo,
		   no_tran,
		   no_documento
	  INTO _no_cuenta,
		   _cod_pagador,
		   _motivo_rechazo,
		   _nombre_pagador,
		   _periodo,
		   _monto,
		   _cargo,
		   _no_tran,
		   _no_documento
	  FROM cobcutmp
	 WHERE rechazado = 1

	let _tipo = 0;

	SELECT telefono1,
	       telefono2,
		   celular,
		   fax,
		   e_mail
	  INTO _tel1,
		   _tel2,
		   _celular,
		   _celular2,
		   _e_mail
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;
	 
	SELECT count(*)
	  INTO _cnt
	  FROM cobcuhab
	 WHERE trim(no_cuenta) = trim(_no_cuenta);

    if _cnt = 0 then
		let _tipo = 1;
	end if
	   
	SELECT cod_banco
	  INTO _cod_banco
	  FROM cobcuhab
	 WHERE trim(no_cuenta) = trim(_no_cuenta);
	
	select dia,
	       fecha_ult_tran
	  into _dia_cobro,
	       _fecha_cobroach
	  from cobcutas
	 where no_cuenta   = _no_cuenta
       and no_documento	= _no_documento;

	SELECT nombre
	  INTO _nombre_banco
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	let _no_poliza = sp_sis21(_no_documento);
	
	SELECT cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  INTO _cod_ramo,
		   _vig_ini,
		   _vig_fin
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	SELECT nombre
	  INTO _n_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	FOREACH
	 SELECT cod_agente
	   INTO _cod_agente	   
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT nombre,
		   cod_vendedor,
		   cod_vendedor2
	  INTO _n_corredor,
           _cod_vendedor,
		   _cod_vendedor2
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
	
	--zona de ventas de acuerdo al ramo
	let _zona_ventas = "";
	if _cod_ramo in('004','018','016','019') then --Personas
		select nombre
		  into _zona_ventas
		  from agtvende
         where cod_vendedor	= _cod_vendedor2;
	else
		select nombre
		  into _zona_ventas
		  from agtvende
         where cod_vendedor	= _cod_vendedor;
	end if

	RETURN _no_documento,
		   _nombre_pagador,
		   _no_cuenta,
		   _nombre_banco,
		   _monto,
		   _cargo,
		   _motivo_rechazo,
		   v_compania_nombre,
		   _no_tran,
		   _tipo,
		   _n_corredor,
		   _zona_ventas,
		   _n_ramo,
		   _vig_ini,
		   _vig_fin,
		   _dia_cobro,
		   _fecha_cobroach,
		   _tel1,
		   _tel2,
		   _celular,
		   _celular2,
		   _e_mail
		   WITH RESUME;

END FOREACH
END PROCEDURE