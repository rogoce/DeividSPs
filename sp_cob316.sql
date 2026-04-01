-- Reporte de Cobros Legales
-- 
-- Creado    : 18/01/2013 - Autor: Amado Perez M. 
-- Modificado: 18/01/2013 - Autor: Amado Perez M.
--
-- SIS v.2.0 - d_cobr_sp_cob316_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob316;

CREATE PROCEDURE "informix".sp_cob316(a_compania char(3))
 RETURNING  char(20),		-- _no_documento,
		  	varchar(100),	-- _asegurado,
		  	varchar(50),	-- _agente,
		  	date,			-- _vigencia_inic,
		  	date,  			-- _vigencia_final,
		  	date,  			-- _fecha,
		  	DEC(16,2),  	-- _prima_neta, 
		  	DEC(16,2),  	-- _impuesto, 
		  	DEC(16,2),  	-- _prima_bruta,
		  	DEC(16,2),		-- _prima_bruta_p,
		  	DEC(16,2),		-- _prima,
		  	varchar(50),	-- _abogado, 
		  	date,			-- _fecha_in,
		  	DEC(16,2),		-- _pagos,
		  	DEC(16,2),   	-- _gasto_legal,
			date,			-- _fecha_out, 
			varchar(255),	--_comentario
			varchar(50);

DEFINE v_compania_nombre    varchar(50); 

DEFINE _no_documento		char(20);
DEFINE _fecha       		date;
DEFINE _no_factura  		char(10);
DEFINE _no_poliza   		char(10);
DEFINE _prima       		decimal(16,2);
DEFINE _pagos       		decimal(16,2);
DEFINE _saldo       		decimal(16,2);
DEFINE _cod_abogado 		char(3);
DEFINE _fecha_in    		date;
DEFINE _fecha_out   		date;
DEFINE _gasto_legal 		decimal(16,2);
DEFINE _comentario  		varchar(255);
DEFINE _cod_contratante		char(10);
DEFINE _vigencia_inic 		date;
DEFINE _vigencia_final		date;
DEFINE _cod_agente          char(5);
DEFINE _prima_neta			decimal(16,2);
DEFINE _impuesto			decimal(16,2);
DEFINE _prima_bruta			decimal(16,2);
DEFINE _prima_bruta_p		decimal(16,2);
DEFINE _asegurado           varchar(100);
DEFINE _agente              varchar(50);  
DEFINE _abogado  			varchar(50);

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH 
 SELECT no_documento,
		fecha,       
		no_factura,  
		no_poliza,   
 		prima,       
 		pagos,       
		saldo,       
		cod_abogado, 
		fecha_in,    
		fecha_out,   
		gasto_legal, 
		comentario  
   INTO	_no_documento,
		_fecha,       
		_no_factura,  
		_no_poliza,   
		_prima,       
		_pagos,       
		_saldo,       
		_cod_abogado, 
		_fecha_in,    
		_fecha_out,   
		_gasto_legal, 
		_comentario  
   FROM coboutleg
  ORDER BY no_documento

 SELECT cod_contratante,
        vigencia_inic,
		vigencia_final
   INTO _cod_contratante,
        _vigencia_inic,
		_vigencia_final
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 FOREACH
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
    EXIT FOREACH;
 END FOREACH
       
 SELECT prima_neta,
        impuesto,
		prima_bruta
   INTO _prima_neta,
		_impuesto,
		_prima_bruta
   FROM endedmae
  WHERE no_poliza = _no_poliza
    AND no_endoso = "00000";

 FOREACH
	 SELECT prima_bruta
	   INTO _prima_bruta_p
	   FROM endedmae
	  WHERE no_poliza = _no_poliza
	    AND cod_endomov = "002"
	    AND cod_tipocalc = "001"
	 EXIT FOREACH;
 END FOREACH
			
 SELECT nombre
   INTO _asegurado
   FROM cliclien
  WHERE cod_cliente = _cod_contratante;

 SELECT nombre 
   INTO _agente
   FROM agtagent
  WHERE cod_agente = _cod_agente;

 SELECT nombre_abogado
   INTO _abogado
   FROM recaboga
  WHERE cod_abogado = _cod_abogado;
 
	RETURN _no_documento,
	       trim(_asegurado),
		   trim(_agente),
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha,
		   _prima_neta, 
		   _impuesto, 
		   _prima_bruta,
		   _prima_bruta_p,
		   _prima,
		   trim(_abogado), 
		   _fecha_in,
		   _pagos,
		   _gasto_legal,
		   _fecha_out, 
		   trim(_comentario),
		   trim(v_compania_nombre)
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

