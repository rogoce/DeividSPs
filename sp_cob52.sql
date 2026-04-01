-- Reportes de las Tarjetas de Credito Rechazadas

-- Creado    : 04/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_sp_cob52_dw1 - DEIVID, S.A.
--Este reporte usa la funcion f_dw_a_xls_rea en powerbuilder, para el ordenamiento al exportase a Excel. AMM  03/10/2025

DROP PROCEDURE sp_cob52;
CREATE PROCEDURE sp_cob52(a_compania CHAR(3), a_sucursal CHAR(3)) 
RETURNING   CHAR(20),
			CHAR(50),
			CHAR(19),
			CHAR(7),
			CHAR(50),
			DEC(16,2),
			DEC(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(50),
			char(10),
			char(10),
			char(50),
			char(50), --ramo
			char(50),
			date,
			date,
			smallint,
			date,
			char(10),
			char(10),
			char(50);
			
DEFINE _no_documento     CHAR(20); 
DEFINE _nombre           CHAR(100);
DEFINE _no_tarjeta       CHAR(19); 
DEFINE _fecha_exp        CHAR(7);  
DEFINE _cod_banco,_cod_vendedor,_cod_vendedor2   CHAR(3);  
DEFINE _monto            DEC(16,2);
DEFINE _saldo            DEC(16,2); 
DEFINE _nombre_banco,_n_ramo     CHAR(50); 
DEFINE _cod_agente       CHAR(5);  
DEFINE _cod_cobrador,_cod_ramo     CHAR(3);  
DEFINE _no_poliza        CHAR(10); 
DEFINE _nombre_cobrador  CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE _motivo_rechazo,_zona_venta   CHAR(50);
DEFINE _tel1,_tel2		 CHAR(10);
DEFINE _cod_pagador		 CHAR(10);
DEFINE _n_corredor       CHAR(50);
define _vig_ini,_vig_fin,_fecha_ult_tran date;
define _dia_cobro        smallint;
define  _celular,_celular2 char(10);
define  _e_mail             char(50);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania); 

FOREACH 
	SELECT no_documento,
	       nombre,
	       no_tarjeta,
		   monto,
		   saldo,
		   motivo_rechazo
	  INTO _no_documento,
		   _nombre,
		   _no_tarjeta,
		   _monto,
		   _saldo,
		   _motivo_rechazo
	  FROM cobtatra
	 WHERE procesar = 0         

    let _no_poliza = sp_sis21(_no_documento);
  
	select dia,
	       fecha_ult_tran
	  into _dia_cobro,
	       _fecha_ult_tran
	  from cobtacre
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;

	SELECT cod_pagador,
	       cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  INTO _cod_pagador,
		   _cod_ramo,
		   _vig_ini,
		   _vig_fin
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	SELECT nombre
	  INTO _n_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
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

	SELECT fecha_exp,
		   cod_banco
	  INTO _fecha_exp,
	  	   _cod_banco
	  FROM cobtahab
	 WHERE no_tarjeta = _no_tarjeta;
	
	SELECT nombre
	  INTO _nombre_banco
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	LET _no_poliza = sp_sis21(_no_documento);

	FOREACH
	 SELECT cod_agente
	   INTO _cod_agente 
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT cod_cobrador,
	       nombre,
		   cod_vendedor,
		   cod_vendedor2
	  INTO _cod_cobrador,
	       _n_corredor,
		   _cod_vendedor,
		   _cod_vendedor2
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
	 
	--zona de ventas de acuerdo al ramo
	let _zona_venta = "";
	if _cod_ramo in('004','018','016','019') then --Personas
		select nombre
		  into _zona_venta
		  from agtvende
         where cod_vendedor	= _cod_vendedor2;
	else
		select nombre
		  into _zona_venta
		  from agtvende
         where cod_vendedor	= _cod_vendedor;
	end if	

	SELECT nombre
	  INTO _nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	RETURN _no_documento,
           _nombre,
		   _no_tarjeta,
		   _fecha_exp,
		   _nombre_banco,
		   _monto,
		   _saldo,
		   _motivo_rechazo,
		   _nombre_cobrador,
		   v_compania_nombre,
		   _tel1,
		   _tel2,
		   _n_corredor,
		   _n_ramo,
		   _zona_venta,
		   _vig_ini,
		   _vig_fin,
		   _dia_cobro,
		   _fecha_ult_tran,
		   _celular,
		   _celular2,
		   _e_mail
		   WITH RESUME;
END FOREACH

END PROCEDURE