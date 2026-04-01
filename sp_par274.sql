-- Reporte que trae las de deudas por corredor

-- Creado    : 28/04/2006 - Autor: Armando Moreno

DROP PROCEDURE sp_par274;

CREATE PROCEDURE sp_par274(a_compania char(3), a_fecha1 date, a_fecha2 date, a_agente char(255) default "*")
RETURNING char(5),	 	-- _cod_agente,
		  smallint,  	-- v_renglon,    
		  char(15),  	-- v_tipo,       
		  dec(16,2), 	-- v_monto,      
		  char(30),	 	-- v_no_documento
		  dec(16,2), 	-- v_saldo,      
		  char(5),	 	-- v_cod_auxiliar
		  char(10),    	-- v_quincena,   
		  varchar(50), 	-- v_nombre
		  varchar(50),  -- v_nombre_aux
		  varchar(50),  
		  varchar(255);    		



DEFINE _cod_agente       char(5);
DEFINE v_renglon         smallint;
DEFINE _tipo             smallint;
DEFINE v_monto           decimal(16,2);
DEFINE v_no_documento    char(30);
DEFINE v_saldo           decimal(16,2);
DEFINE v_cod_auxiliar    char(5);
DEFINE _quincena         smallint;
DEFINE v_filtros         varchar(255);
DEFINE v_tipo            char(15);
DEFINE v_quincena        char(10);

DEFINE v_codigo          char(10);
DEFINE v_saber	         char(3);
DEFINE _tipof            char(1);
DEFINE _quin1            smallint;
DEFINE _quin2            smallint;
DEFINE v_nombre          varchar(50);
DEFINE v_nombre_aux    	 varchar(50);
DEFINE v_compania_nombre varchar(50);     

CREATE TEMP TABLE tmp_deuda(
cod_agente      char(5),
renglon      	smallint,
tipo            smallint,
monto           decimal(16,2),
no_documento    char(30),
saldo           decimal(16,2),
cod_auxiliar    char(5),
quincena        smallint,
seleccionado    smallint DEFAULT 1
) WITH NO LOG;
		
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "c:\sp_che47.trc";
--TRACE ON;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 
LET v_filtros = "";

IF DAY(a_fecha1) < 16 THEN	--Se tomara la fecha_hasta para determinar de que quincena y no la fecha_desde
   LET _quin1 = 1;
ELSE	
   LET _quin1 = 2;
END IF

IF DAY(a_fecha2) < 16 THEN	--Se tomara la fecha_hasta para determinar de que quincena y no la fecha_desde
   LET _quin2 = 1;
ELSE	
   LET _quin2 = 2;
END IF

FOREACH
	SELECT cod_agente,  
		   renglon,     
	       tipo,        
	       monto,       
	       no_documento,
	       saldo,       
	       cod_auxiliar,
	       quincena    	  
	  INTO _cod_agente,   
	   	   v_renglon,     
		   _tipo,        
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   _quincena    
	  FROM agtdeuda
	 WHERE quincena = 0

	INSERT INTO tmp_deuda
	VALUES(_cod_agente,
	       v_renglon,     
		   _tipo,        
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   _quincena,
		   1    
		   );

END FOREACH

FOREACH
	SELECT cod_agente,  
		   renglon,     
	       tipo,        
	       monto,       
	       no_documento,
	       saldo,       
	       cod_auxiliar,
	       quincena    	  
	  INTO _cod_agente,   
	   	   v_renglon,     
		   _tipo,        
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   _quincena    
	  FROM agtdeuda
	 WHERE quincena in (_quin1, _quin2)

	INSERT INTO tmp_deuda
	VALUES(_cod_agente,
	       v_renglon,     
		   _tipo,        
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   _quincena,
		   1    
		   );

END FOREACH

-- Filtros para Agente

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: ";-- ||  TRIM(a_agente);

	LET _tipof = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipof <> "E" THEN -- Incluir los Registros

		UPDATE tmp_deuda
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_deuda
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    FOREACH
		SELECT tmp_codigos.codigo
	      INTO v_codigo
	      FROM tmp_codigos
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

FOREACH
	SELECT cod_agente,  
		   renglon,     
	       tipo,        
	       monto,       
	       no_documento,
	       saldo,       
	       cod_auxiliar,
	       quincena    	  
	  INTO _cod_agente,   
	   	   v_renglon,     
		   _tipo,        
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   _quincena    
	  FROM tmp_deuda
	 WHERE seleccionado = 1
  ORDER BY 1, 2 

	LET v_nombre_aux = "";
	If _tipo = 1 Then
       LET v_tipo = "DEUDA";

	   SELECT ter_descripcion
		 INTO v_nombre_aux
		 FROM cglterceros
		WHERE ter_codigo = v_cod_auxiliar;

	Else
       LET v_tipo = "PAGO DE POLIZA";
	End If

	If _quincena = 0 Then
       LET v_quincena = "TODAS";
	Elif _quincena = 1 Then
       LET v_quincena = "PRIMERA";
    Else
       LET v_quincena = "SEGUNDA";
	End If

    SELECT nombre
	  INTO v_nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

{	select cta_nombre
	  into v_nombre
	  from cglcuentas
	 where cta_cuenta = v_cuenta;
 }
	RETURN _cod_agente,
		   v_renglon,     	
		   v_tipo,        	
		   v_monto,       
		   v_no_documento,
		   v_saldo,       
		   v_cod_auxiliar,
		   v_quincena,    
	       v_nombre,
	       v_nombre_aux,
		   v_compania_nombre,
	       v_filtros    		
	       WITH RESUME;
END FOREACH

DROP TABLE tmp_deuda;

END PROCEDURE;