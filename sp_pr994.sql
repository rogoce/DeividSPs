-- Reporte de Ingresos de Remesa de reaseguro
-- 
-- Creado    : 11/11/2000 - Autor: Henry Giron
-- Modificado: 11/11/2000 - Autor: Henry Giron
-- Modificado: 16/11/2012 - Autor: Roman Gordon	--Se agrego los tipo contrato 07 y 09 en la descripcion del contrato.
--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_prod_sp_pr994_dw1 - DEIVID, S.A.


DROP PROCEDURE sp_pr994;

CREATE PROCEDURE "informix".sp_pr994(a_compania CHAR(3),a_remesa CHAR(10)) 
RETURNING SMALLINT,	    -- Renglon
		  	CHAR(50),	-- Reasegurador
		  	CHAR(2),	-- Tipo Contrato
		  	CHAR(50),	-- Contrato
		  	CHAR(100),  -- Descripcion	
		  	DEC(16,2),  -- debito
		  	DEC(16,2),  -- credito
		  	CHAR(50),   -- Cod ramo
		  	CHAR(50),   -- Descripcion Tipo Remesa	
		  	DATE,		-- Fecha
		  	CHAR(7),	-- Periodo
		  	CHAR(50),	-- Nombre Banco
		  	CHAR(2),	-- Tipo Remesa
		  	SMALLINT,	-- Actualizado
		  	CHAR(50),   -- Nombre Compania    
			CHAR(10);	-- Numero de Remesa


DEFINE v_renglon		 SMALLINT;	
DEFINE _monto            DEC(16,2);
DEFINE _monto_cobros     DEC(16,2);

DEFINE _cod_contrato     CHAR(2);
DEFINE _usuario 		 CHAR(15);
DEFINE _descrip		  	 CHAR(100);
DEFINE _cod_coasegur     CHAR(3);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_nombre_banco    CHAR(50);
DEFINE v_tipo_remesa     CHAR(2);
DEFINE v_actualizado     SMALLINT;
DEFINE v_compania_nombre CHAR(50); 
DEFINE _cod_banco        CHAR(3);
DEFINE n_reasegurador	 CHAR(50);
DEFINE _cod_ramo		 CHAR(3);
DEFINE _debito			 DEC(16,2);
DEFINE _credito			 DEC(16,2);
DEFINE s_tipo_c          CHAR(50);
DEFINE s_tipo_r          CHAR(50);
DEFINE v_desc_ramo       CHAR(50);

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);  

-- Lectura de la Tabla de Remesas

  SELECT fecha,
		 periodo,
		 cod_banco,
		 tipo,
		 actualizado,
		 cod_contrato,
		 usuario,
		 descrip,
		 cod_coasegur
	INTO v_fecha,
	   	 v_periodo,
	     _cod_banco,
	     v_tipo_remesa,
	     v_actualizado,
	     _cod_contrato,
	     _usuario,
	     _descrip,
	     _cod_coasegur		  
    FROM reatrx1  
   WHERE ( cod_compania = a_compania ) AND  
         ( no_remesa = a_remesa );
   	

SELECT nombre
  INTO v_nombre_banco
  FROM chqbanco
 WHERE cod_banco = _cod_banco;
 
IF v_nombre_banco IS NULL THEN
	LET v_nombre_banco = '... Banco No Definido ...';
END IF

SELECT nombre
  INTO n_reasegurador
  FROM emicoase
 WHERE cod_coasegur = _cod_coasegur ;

IF n_reasegurador IS NULL THEN
	LET n_reasegurador = '... No Definido ...' ;
END IF

if _cod_contrato = "01" then 
   LET s_tipo_c =	"Bouquet" ;
end if
if _cod_contrato = "02" then 
   LET s_tipo_c =	"Runoff" ;
end if
if _cod_contrato = "03" then 
   LET s_tipo_c =	"50%Mapfre" ;
end if
if _cod_contrato = '04' then
	let s_tipo_c = 'Facultativo';
end if

if _cod_contrato = '06' then
	let s_tipo_c = 'Facilidad Car';
end if
if _cod_contrato = '08' then
	let s_tipo_c = 'Cuota Parte / Vida y Acc. Pers.';
end if
if _cod_contrato = '09' then
	let s_tipo_c = 'Bouquet - Fianzas';
end if
if _cod_contrato = '10' then
	let s_tipo_c = 'Auto Casco';
end if

if v_tipo_remesa = "01" then 
   LET s_tipo_r =	"Pagos al Reasegurador" ;
end if
if v_tipo_remesa = "02" then 
   LET s_tipo_r =	"Recibo del Reasegurador" ;
end if
if v_tipo_remesa = "03" then 
   LET s_tipo_r =	"Recibo de Siniestros de Contado" ;
end if
if v_tipo_remesa = "04" then 
   LET s_tipo_r =	"Recibo de Siniestros XL" ;
end if
if v_tipo_remesa = "05" then 
   LET s_tipo_r =	"Varios" ;
end if
if v_tipo_remesa = "06" then
	LET s_tipo_r = "Comisión Adicional";
end if
if v_tipo_remesa = "07" then 
   LET s_tipo_r =	"Comisión de Utilidades" ;
end if


-- Recibos por Remesa
FOREACH 
  SELECT renglon,   
         cod_ramo,   
         debito,   
         credito  
	INTO v_renglon,
		 _cod_ramo,
		 _debito,
		 _credito
    FROM reatrx2  
   WHERE (cod_compania = a_compania) AND  
         (no_remesa    = a_remesa) 

 SELECT nombre
   INTO v_desc_ramo
   FROM rearamo
  WHERE ramo_reas = _cod_ramo;
			
	RETURN v_renglon,			
		   n_reasegurador,			 
		   _cod_contrato,        
		   s_tipo_c,      
		   _descrip,     
		   _debito,    
		   _credito,          
		   v_desc_ramo,       
		   s_tipo_r,     
		   v_fecha,          
		   v_periodo,		
		   v_nombre_banco,   
		   v_tipo_remesa,    
		   v_actualizado,    
		   v_compania_nombre,
		   a_remesa
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

