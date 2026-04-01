-- Reporte para correo certificado agrupados -- Sacado del reporte de de Aviso de Cancelacion 
-- Creado    : 15/01/2015 - Autor: Amado Perez 
-- SIS v.2.0 - d_cobr_sp_cob748c_dw1 - DEIVID, S.A.  -- x corredor 
-- SIS v.2.0 - d_cobr_sp_cob748h_dw1 - DEIVID, S.A.	 -- x acreedor 

DROP PROCEDURE sp_log013; 
CREATE PROCEDURE "informix".sp_log013(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_agente CHAR(5) DEFAULT '*',a_acreedor CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0, a_referencia varchar(255) default "*") 
RETURNING   VARCHAR(50),       -- Direccion  
            VARCHAR(50), 
            CHAR(20), 		   -- no_documento 	 
		    CHAR(100), 		   -- nombre_cliente     
			CHAR(50),          -- Cobrador   
			INTEGER,		   -- Salto de pagina 
			varchar(10),       -- numero 
			varchar(20),       -- valor de franqueo 
			varchar(20),       -- estado 
			varchar(10),       -- espacio 
			char(15),          -- no_aviso 
			varchar(255);      -- filtro			

DEFINE _compania_nombre 	CHAR(50); 
DEFINE _nombre_cobrador 	CHAR(50); 
define _no_aviso 			CHAR(15); 
define _no_documento 		CHAR(20); 
define _no_poliza 			CHAR(10); 
define _periodo 			CHAR(7); 
define _vigencia_inic 		DATE; 
define _vigencia_final 	    DATE; 
define _cod_ramo 			CHAR(3); 
define _nombre_ramo 		CHAR(50); 
define _nombre_subramo 	    CHAR(50); 
define _cedula 				CHAR(10); 
define _nombre_cliente 	    CHAR(100); 
define _saldo 				DECIMAL(16,2); 
define _por_vencer 			DECIMAL(16,2); 
define _exigible 			DECIMAL(16,2); 
define _corriente 			DECIMAL(16,2); 
define _dias_30 			DECIMAL(16,2); 
define _dias_60 			DECIMAL(16,2); 
define _dias_90 			DECIMAL(16,2); 
define _dias_120 			DECIMAL(16,2); 
define _dias_150 			DECIMAL(16,2); 
define _dias_180 			DECIMAL(16,2); 
define _cod_acreedor 		CHAR(5); 
define _nombre_acreedor 	CHAR(50); 
define _cod_agente 			CHAR(5); 
define _nombre_agente 		CHAR(50); 
define _porcentaje 			DECIMAL(16,2); 
define _telefono 			CHAR(10); 
define _cod_cobrador 		CHAR(3); 
define _cod_vendedor 		CHAR(3); 
define _apartado 			CHAR(20); 
define _fax_cli 			CHAR(10); 
define _tel1_cli 			CHAR(10); 
define _tel2_cli 			CHAR(10); 
define _apart_cli 			CHAR(20); 
define _email_cli 			CHAR(50); 
define _fecha_proc 			DATE;
define _cobra_poliza	 	CHAR(1);
define _estatus_poliza	 	CHAR(1);
DEFINE _cod_formapag    	CHAR(3);
DEFINE _nombre_formapag 	CHAR(50);
DEFINE _no_factura      	CHAR(10);

define _mes_char		   CHAR(2)		;
define _ano_char		   CHAR(4)		;

DEFINE _fecha_actual	   DATE			;
DEFINE _periodo_c		   CHAR(7)		;
DEFINE _saldo_c   		   DECIMAL(16,2);
define _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);

DEFINE _cod_contratante    CHAR(10); 
DEFINE _direccion_1        VARCHAR(50); 
DEFINE _cod_estafeta       CHAR(4); 
DEFINE _estafeta           VARCHAR(50); 
DEFINE _salto_pag          INTEGER; 
DEFINE _cont_filas         INTEGER; 
DEFINE _nombre_estafeta    CHAR(50); 

DEFINE _numero		        varchar(10); 
DEFINE _valor_franqueo		varchar(20); 
DEFINE _estado      		varchar(20); 
DEFINE _espacio		        varchar(10); 


define v_filtros            varchar(255);  
define _tipo	            char(1);  

SET ISOLATION TO DIRTY READ;  
LET v_filtros     = "";	 
		
LET v_filtros = TRIM(v_filtros) ||" No.Avisos: "||TRIM(a_referencia); 
LET _tipo = sp_sis04(a_referencia); -- Separa los valores del String 

IF a_agente = '%'	THEN
	LET a_agente = '*'; 
END IF
IF a_acreedor = '%'	THEN
	LET a_acreedor = '*'; 
END IF
IF a_asegurado = '%'	THEN
	LET a_asegurado = '*'; 
END IF
IF a_cobrador = '%'	THEN
	LET a_cobrador = '*'; 
END IF

-- Nombre de la Compania
LET  _compania_nombre = sp_sis01(a_compania); 

if a_callcenter = 0 then
	let _cobra_poliza = "C";
else
	let _cobra_poliza = "E";
end if

--
let _fecha_actual = today;
let _periodo_c	        = ' ';
let _numero	            = ' ';
let _valor_franqueo	    = ' ';
let _estado	            = 'EN TRAMITE';
let _espacio	        = ' ';
		   

IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

let _salto_pag = 0;
let _cont_filas = 0;

-- Reporte de las Cartas a Imprimir
FOREACH
  SELECT no_aviso,   
         no_documento,   
         no_poliza,   
         periodo,   
         vigencia_inic,   
         vigencia_final,   
         cod_ramo,   
         nombre_ramo,   
         nombre_subramo,   
         cedula,   
         nombre_cliente,   
         saldo,   
         por_vencer,   
         exigible,   
         corriente,   
         dias_30,   
         dias_60,   
         dias_90,   
         dias_120,   
         dias_150,   
         dias_180,   
         cod_acreedor,   
         nombre_acreedor,   
         cod_agente,   
         nombre_agente,   
         porcentaje,   
         telefono,   
         cod_cobrador,   
         cod_vendedor,   
         apartado,   
         fax_cli,   
         tel1_cli,   
         tel2_cli,   
         apart_cli,   
         email_cli,   
         fecha_proceso,  
		 cod_formapag,   
		 nombre_formapag,
		 cobra_poliza,
		 estatus_poliza,
		 no_factura,
         cod_contratante		 
  into  _no_aviso,   
         _no_documento,   
         _no_poliza,   
         _periodo,   
         _vigencia_inic,   
         _vigencia_final,   
         _cod_ramo,   
         _nombre_ramo,   
         _nombre_subramo,   
         _cedula,   
         _nombre_cliente,   
         _saldo,   
         _por_vencer,   
         _exigible,   
         _corriente,   
         _dias_30,   
         _dias_60,   
         _dias_90,   
         _dias_120,   
         _dias_150,   
         _dias_180,   
         _cod_acreedor,   
         _nombre_acreedor,   
         _cod_agente,   
         _nombre_agente,   
         _porcentaje,   
         _telefono,   
         _cod_cobrador,   
         _cod_vendedor,   
         _apartado,   
         _fax_cli,   
         _tel1_cli,   
         _tel2_cli,   
         _apart_cli,   
         _email_cli,   
         _fecha_proc,
		 _cod_formapag,   
		 _nombre_formapag,
		 _cobra_poliza,
		 _estatus_poliza,
		 _no_factura,
		 _cod_contratante		 
    FROM avisocanc  
   WHERE no_aviso    IN (SELECT codigo FROM tmp_codigos ) 
	 AND cod_agente   MATCHES a_agente
	 AND cod_acreedor MATCHES a_acreedor
	 AND cedula  	  MATCHES a_asegurado
	 AND cod_cobrador MATCHES a_cobrador
--	 AND desmarca = 1 
	 and estatus <> 'Y'
   ORDER BY nombre_cliente, no_documento	          

   	CALL sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
		 		   	 RETURNING _por_vencer_c,
							   _exigible_c,
							   _corriente_c,
							   _dias_30_c,
							   _dias_60_c,
							   _dias_90_c,
							   _dias_120_c,
							   _dias_150_c,
							   _dias_180_c,
							   _saldo_c;
	  IF _saldo_c = 0 then
		 continue foreach;
	  end if

  -- Usuario que generó la campaña
  SELECT user_added
    INTO _nombre_cobrador
    FROM avicanpar
   WHERE cod_avican = a_referencia;
  
  -- Direccion del cliente y estafeta  
  SELECT direccion_1, cod_estafeta
    INTO _direccion_1, _cod_estafeta
    FROM cliclien
   WHERE cod_cliente = _cod_contratante;
   
  LET _estafeta = NULL;   
   
  IF _cod_estafeta IS NOT NULL AND TRIM(_cod_estafeta) <> "" THEN
  
	SELECT nombre
	  INTO _nombre_estafeta
	  FROM cobestafeta
	 WHERE cod_estafeta = _cod_estafeta;
	 
	LET _estafeta = "ENTREGA GENERAL " || _cod_estafeta || " " || _nombre_estafeta;	
	
  END IF	
   
  LET _cont_filas = _cont_filas + 1;
  
  IF _cont_filas = 31 THEN
	LET _cont_filas = 1;
	LET _salto_pag = _salto_pag + 1;
  END IF

	RETURN _direccion_1,
	       _estafeta,
		   _no_documento,   	-- no_documento 	
		   _nombre_cliente, 	-- n_cliente 
		   _nombre_cobrador,    -- n_cobrador
		   _salto_pag,
           _numero,		   
           _valor_franqueo,
           _estado,
           _espacio,
           _no_aviso,
     	   v_filtros		   
		   WITH RESUME;	 		

END FOREACH
DROP TABLE tmp_codigos;
END PROCEDURE;

