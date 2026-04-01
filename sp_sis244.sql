-- Cartera Activa Insurance Solutions
-- Creado por: Amado Pérez Mendoza
-- Fecha 	 : 17/07/2012

drop procedure sp_sis244;

create procedure sp_sis244() returning
            char(20) as poliza,
			varchar(100) as asegurado,
			varchar(100) as contratante,
			varchar(100) as conductor,
            varchar(50) as ramo,
			varchar(50) as plan,
			date as vigencia_inicial,
			date as vigencia_final,
			dec(16,2) as prima_con_iva,
			dec(16,2) as prima_sin_iva,
			varchar(50) as forma_pago,
			varchar(50) as frecuencia_pago,
			smallint as no_cuotas,
			dec(5,2) as comision,
			date as fecha_emision,
			char(10) as cod_agente;


define v_filtros   	    char(255);
define _no_poliza       char(10);   
define _no_documento    char(20); 
define _cod_ramo        char(3);
define _vigencia_inic   date;  
define _vigencia_final  date; 
define _cod_contratante	char(10);
define _ramo			varchar(50);
define _prima_bruta		dec(16,2);
define _prima_neta 		dec(16,2);
define _cod_formapag	char(3);
define _cod_perpago     char(3);
define _no_pagos        smallint;
define _fecha_suscripcion date;
define _cod_agente      char(5);
define _porc_comis_agt  dec(5,2);
define _forma_pago      varchar(50);
define _periodo_pago    varchar(50);
define _plan            varchar(50);
define _cod_asegurado   char(10);
define _asegurado       varchar(100);
define _contratante     varchar(100);
define _cod_producto    char(5);
define _cod_subramo     char(3);

--SET DEBUG FILE TO "sp_che133.trc";
--tRACE ON;

SET ISOLATION TO DIRTY READ;

let	_plan	= null;

CALL sp_sis244b(
'001',
'001',
'31/08/2019',
'*',
'4;Ex') RETURNING v_filtros;

FOREACH
	SELECT no_poliza,   
           no_documento,   
		   cod_ramo,
		   cod_subramo,
           vigencia_inic,   
           vigencia_final,  
           cod_contratante		 
	  INTO _no_poliza,   
           _no_documento,   
		   _cod_ramo,
		   _cod_subramo,
           _vigencia_inic,   
           _vigencia_final,  
           _cod_contratante
      FROM temp_perfil 
    ORDER BY no_documento	  

    SELECT nombre
	  INTO _ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
  --  SELECT nombre
  --  INTO _plan
--	  FROM prdsubra
--	 WHERE cod_ramo = _cod_ramo
--	   AND cod_subramo = _cod_subramo;
	 
	SELECT prima_bruta,
	       prima_neta,
		   cod_formapag,
		   cod_perpago,
		   no_pagos,
		--   cod_pagador,
		   fecha_suscripcion
      INTO _prima_bruta,
	       _prima_neta,
		   _cod_formapag,
		   _cod_perpago,
		   _no_pagos,
		--   _cod_contratante,
		   _fecha_suscripcion
	  FROM emipomae
     WHERE no_poliza = _no_poliza;	 
	 
	FOREACH 
		SELECT cod_asegurado,
			   cod_producto
		  INTO _cod_asegurado,
			   _cod_producto
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		ORDER BY no_unidad
		 
		 EXIT FOREACH;
    END FOREACH

    SELECT cod_agente,
	       porc_comis_agt
      INTO _cod_agente,
	       _porc_comis_agt
      FROM emipoagt
     WHERE no_poliza = _no_poliza;	

    SELECT nombre
      INTO _forma_pago
      FROM cobforpa	 
     WHERE cod_formapag = _cod_formapag;

    SELECT nombre
      INTO _periodo_pago
      FROM cobperpa
     WHERE cod_perpago = _cod_perpago;
	 
	SELECT nombre
	  INTO _asegurado
	  FROM cliclien 
	 WHERE cod_cliente = _cod_asegurado;
	
	SELECT nombre
	  INTO _contratante
	  FROM cliclien 
	 WHERE cod_cliente = _cod_contratante;
	 
	SELECT nombre
	  INTO _plan
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;

	RETURN _no_documento,
	       _asegurado,
		   _contratante,
		   null,
	       _ramo,
           _plan,
           _vigencia_inic,
           _vigencia_final,
		   _prima_bruta,
		   _prima_neta,
		   _forma_pago,
		   _periodo_pago,
		   _no_pagos,
	       _porc_comis_agt,
		   _fecha_suscripcion,
		   _cod_agente
		   with resume;
END FOREACH
	
DROP TABLE temp_perfil;

end procedure
