-- Procedimiento que Carga las Sobre Comisiones por Corredor
-- Creado    : 07/Junio /2007 - Autor: Rub‚n Dar¡o Arn ez 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_test;
CREATE PROCEDURE sp_test(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7), a_cod_agente CHAR(255))

--  CREATE PROCEDURE sp_che72(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_cod_agente     CHAR(255))
returning CHAR(15),  -- Codigo de de Agente 			
		  CHAR(10),	 -- N£mero de P¢liza				
		  CHAR(10),	 -- N£mero de Recibo  				
		  DATE,      -- Fecha							
		  DEC(16,2), -- Monto 							
		  DEC(16,2), -- Prima     						
		  DEC(5,2),	 -- Porcentaje de Participaci¢n  	
		  DEC(5,2),  -- Porcentaje de Comisi¢n   		
		  DEC(16,2), -- Comisi¢n 						
		  CHAR(50),  -- Nombre 							
		  CHAR(20),  -- Numero de Documento 			
	 	  CHAR(10),  -- Nombre del Subramo				
		  CHAR(100), -- Asegurado
		  CHAR(5),	 -- Agente Agrupador
		  CHAR(50);  -- Nombre del Agente Agrupador					

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _gen_cheque      SMALLINT; 
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2); 
DEFINE _comision        DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _fecha_ult_comis DATE;     
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _agente_agrupado CHAR(5);
DEFINE _cod_producto	CHAR(5);
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50);
DEFINE _nombre_clte     CHAR(100); 
DEFINE _cod_cliente     CHAR(10);
DEFINE _tipo           	CHAR(1);
DEFINE _nombre_agente   CHAR(50); 
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che02.trc";
--TRACE ON;


-- llamar al 73
call sp_testrda("001","001", a_periodo);
-- call sp_che73("001","001", a_fecha_desde, a_fecha_hasta);


IF a_cod_agente <> "*" THEN

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_testrda
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_testrda
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

-- foreach de tmp_testrda

foreach
 select cod_agente,	 
		no_poliza,	 
		no_recibo,	 
		fecha,		 
		monto,       
		prima, 
		porc_partic,		 
		porc_comis,	 
		comision,	 
		nombre,		 
		no_documento,
		no_licencia,    						
		nombre_clte,
		agente_agrupado,
		nombre_agente    
   into	_cod_agente, 
		_no_poliza,	 
		_no_recibo,	 
		_fecha,		 
		_monto,      
		_prima, 	 
		_porc_partic,
		_sobrecomision,	
		_comision,	 
		_nombre2,	 	
		_no_documento,
		_no_licencia2,    
		_nombre_clte,
		_agente_agrupado,
		_nombre_agente     
   from tmp_testrda	
 --  end foreach;		   

  return _cod_agente,  
         _no_poliza,   
		 _no_recibo,   
		 _fecha,	   
		 _monto,	   
		 _prima,	   
		 100.00,	   
		 _sobrecomision,   
		 _comision,	   
		 _nombre2,	    
		 _no_documento, 
		 _no_licencia2,
	     _nombre_clte,
	     _agente_agrupado,
	     _nombre_agente  
     with resume;	   
   end foreach	
drop table tmp_testrda;

END PROCEDURE;