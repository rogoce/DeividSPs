 

DROP PROCEDURE sp_che238;
CREATE PROCEDURE sp_che238() 
RETURNING CHAR(20),	-- Poliza
			CHAR(100),	-- Asegurado
			CHAR(10),	-- Recibo
			DATE,		-- Fecha
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(5,2),	-- % Partic
			DEC(5,2),	-- % Comis
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50);	-- Compania
		   		   
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_partic  DEC(5,2); 
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _cod_cliente  CHAR(10);
  

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

LET  v_nombre_cia = sp_sis01('001'); 

FOREACH
  SELECT chqcomis.cod_agente,   
         chqcomis.no_poliza,   
         chqcomis.no_recibo,   
         chqcomis.fecha,   
         chqcomis.monto,   
         chqcomis.prima,   
         chqcomis.porc_partic,   
         chqcomis.porc_comis,   
         chqcomis.comision,   
         chqcomis.nombre,   
         chqcomis.no_documento
   INTO	v_cod_agente,
   		v_no_poliza,
		v_no_recibo,
		v_fecha,
		v_monto,
		v_prima,
		v_porc_partic,
		v_porc_comis,
		v_comision,
		v_nombre_agt,
		v_no_documento
    FROM chqchmae,   
         chqcomis 
   WHERE ( chqchmae.no_requis = chqcomis.no_requis ) AND
         ( ( chqchmae.cod_agente in (  '02111','02569' ) ) AND  
         ( year(chqchmae.fecha_impresion) = 2020 ) AND  
         ( chqchmae.pagado = 1 ) AND  
         ( chqcomis.comision <> 0 ) )  
  order by  chqcomis.nombre, chqcomis.fecha, chqcomis.no_recibo, chqcomis.no_documento

	IF v_no_poliza = '00000' THEN -- Comision Descontada

		LET v_nombre_clte = 'COMISION DESCONTADA ...';	

	ELSE

		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		--call sp_che137(v_no_documento) returning _error,_error_desc;

	END IF

	RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
			WITH RESUME;		      
END FOREACH
END PROCEDURE	  