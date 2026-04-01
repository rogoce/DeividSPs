-- Procedimiento: Carta de Contenido de email
-- Creado       : 15/01/2011 - Autor: Henry Giron
DROP PROCEDURE sp_pro4936;
CREATE PROCEDURE "informix".sp_pro4936(a_cod_avican CHAR(10),a_renglon SMALLINT)
RETURNING      CHAR(10),       -- Codigo Cliente
		  	   CHAR(5),        -- Codigo Acreedor
		  	   CHAR(5),        -- Codigo Agente
		  	   CHAR(100),      -- Nombre Cliente
		  	   CHAR(50),       -- Nombre Acreedor
		  	   CHAR(50),       -- Nombre Agente
          	   DECIMAL(16,2),  -- Saldo
		  	   DECIMAL(16,2),  -- Exigible
		  	   DECIMAL(16,2),  -- 90oMas
		  	   DATE,           -- Fecha Vence
		  	   DATE,           -- Vigencia Inicial
		  	   DATE,           -- Vigencia Final
		  	   CHAR(20);	   -- No_documento

DEFINE _c_cliente		CHAR(10)     ;
DEFINE _n_cliente		CHAR(100)    ;
DEFINE _n_acreedor		CHAR(100)    ;
DEFINE _c_acreedor		CHAR(5)      ;
DEFINE _c_agente		CHAR(5)      ;
DEFINE _n_agente		CHAR(50)     ;
DEFINE _saldo   		DECIMAL(16,2);						     
DEFINE _exigible		DECIMAL(16,2); 							     
DEFINE _dias_90			DECIMAL(16,2);
DEFINE _dias_120		DECIMAL(16,2);
DEFINE _dias_150		DECIMAL(16,2);
DEFINE _dias_180		DECIMAL(16,2);
DEFINE _saldo_90M   	DECIMAL(16,2);						     
DEFINE _no_poliza		CHAR(10)   	 ;						     
DEFINE _no_documento	CHAR(20)   	 ;						     
DEFINE _fecha_vence		DATE   		 ;	
DEFINE _vigencia_inic   DATE   		 ;	
DEFINE _vigencia_final  DATE   		 ;	
define _estatus_poliza  CHAR(1)      ;
DEFINE _fecha_ult_gestion		DATE ;	
define _tm_ultima_gestion  integer;
define _tm_fecha_efectiva  integer;
define _fecha_actual	   date;
define _dias			   smallint;
define _ult_gestion     CHAR(1)      ;


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro4936.trc";
--trace on;

BEGIN
let _tm_ultima_gestion = 0; 
let _tm_fecha_efectiva = 0;
let _fecha_actual = sp_sis26();

 SELECT no_poliza,
        no_documento,
        saldo,
		exigible,
		nombre_cliente,
		nombre_agente,
		nombre_acreedor,
		vigencia_inic,
		vigencia_final,
		cod_contratante,
		cod_agente,
		cod_acreedor,
		dias_90,		
		dias_120,	
		dias_150,	
		dias_180,
		fecha_vence,
		estatus,
		ult_gestion,	
		fecha_ult_gestion	
   INTO _no_poliza,
        _no_documento,
        _saldo,
		_exigible,
		_n_cliente,
		_n_agente,
		_n_acreedor,
		_vigencia_inic,
		_vigencia_final,
		_c_cliente,
		_c_agente,
		_c_acreedor,
		_dias_90,		
		_dias_120,	
		_dias_150,	
		_dias_180,
		_fecha_vence,
		_estatus_poliza,
		_ult_gestion,
		_fecha_ult_gestion	
   FROM avisocanc
  WHERE no_aviso  = a_cod_avican
    AND renglon = a_renglon	;

		if _dias_90 is null then
			let	_dias_90 = 0;
       end if
		if _dias_120 is null then
			let	_dias_120 = 0;
       end if
		if _dias_150 is null then
			let	_dias_150 = 0;
       end if
		if _dias_180 is null then
			let	_dias_180 = 0;
       end if

		let _saldo_90M = _dias_90 + _dias_120 + _dias_150 +	 _dias_180 ;		 						 						 	

		if _estatus_poliza in ("X") and _ult_gestion = "1" then
		 select tm_ultima_gestion
		   into _tm_ultima_gestion
		   from avicanpar
		  Where cod_avican = a_cod_avican ;
		   call sp_sis388a(_fecha_ult_gestion,_tm_ultima_gestion) returning _fecha_vence; 				   
	   end if


RETURN 	_c_cliente,
		_c_agente,
		_c_acreedor,
		_n_cliente,
		_n_agente,
		_n_acreedor,
		_saldo,
		_exigible,
		_saldo_90M,
		_fecha_vence,
		_vigencia_inic,
		_vigencia_final,
		_no_documento
		WITH RESUME;	   
	   
	   

END
END PROCEDURE
