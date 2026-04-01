-- Reporte de Recibos por Remesa
-- 
-- Creado    : 21/09/2010 - Autor: Roman Gordon--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob251;

CREATE PROCEDURE "informix".sp_cob251(
a_compania 	CHAR(3), 
a_codagente	CHAR(255) default "*",
a_fecha1	DATE,
a_fecha2	DATE
) RETURNING smallint,  --v_renglon
			char(10),  --v_no_recibo
			dec(16,2), --porc_comision
			dec(16,2), --v_prima
			dec(16,2), --com_ganada
			dec(16,2), --v_descontada
			char(50),  --compania
			char(10),  --v_no_remesa
			char(5),   --cod_agente
			dec(16,2), --porc_partic
			char(50),  --n_agente
			char(10),  --v_no_licencia
			char(50),  --direccion
			char(10),  --telefono
			char(50),  --email
			smallint,  --tipo_pago
			char(10),  --no_poliza
			char(50);  --asegurado
	 	

DEFINE v_renglon		 SMALLINT;	
DEFINE v_no_recibo		 CHAR(10);
DEFINE v_no_remesa       CHAR(10);
DEFINE v_desc_remesa     CHAR(100);
DEFINE v_monto_banco     DEC(16,2);
DEFINE v_prima           DEC(16,2);
DEFINE v_impuesto        DEC(16,2);
DEFINE v_descontada      DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_nombre_banco    CHAR(50);
DEFINE v_tipo_remesa     CHAR(1);
DEFINE v_actualizado     SMALLINT;
DEFINE v_compania_nombre CHAR(50); 

DEFINE _cod_banco        CHAR(3);
DEFINE _monto            DEC(16,2);
DEFINE _monto_cobros     DEC(16,2);
DEFINE _porc_comis_agt   DEC(16,2);
DEFINE v_tipo_pago       smallint;
DEFINE v_tipo_mov		 char(1);
DEFINE _renglon          SMALLINT;
DEFINE _cod_agente       CHAR(5);
DEFINE _com_ganada       DEC(16,2);
DEFINE _porc_partic_agt  DEC(16,2);
define _n_agente         char(50);
define v_prima1          DEC(16,2);
DEFINE v_no_poliza       CHAR(10);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(01);
define _n_agente_2       CHAR(50);
define _direccion_1		 CHAR(50);
define _telefono_1		 CHAR(10);
define _email			 CHAR(50);
define _asegurado		 CHAR(100);
define _tipo_pago		 smallint;
define _no_licencia		 CHAR(10);
define _cod_contratante  char(10);



begin

Create Temp Table tmp_cob(
     cod_agente		  char(5),
	 n_corredor  	  varchar(50),
	 no_licencia 	  char(10),
	 direccion	 	  char(50),
	 telefono	 	  char(10),
	 email		 	  char(50),
     no_recibo 	 	  char(10),
	 no_poliza	 	  char(10),
	 asegurado	 	  char(100),
	 prima		 	  dec(16,2),
	 porc_partic_agt  dec(16,2),
	 porc_comis_agt   dec(16,2),
	 com_ganada       dec(16,2),
	 com_descontada	  dec(16,2),
	 tipo_pago	 	  smallint,
	 renglon	 	  smallint,
	 remesa			  char(10),	
	 seleccionado	  smallint
	  	 
	 ) With No Log;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pro251.trc";	  	  	  	
--trace on;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH 
 -- Lectura de la Tabla de Remesas

 SELECT no_remesa
   INTO v_no_remesa
   FROM cobremae
  WHERE fecha BETWEEN a_fecha1 and a_fecha2
 	and actualizado = 1
-- Recibos por Remesa
 
 foreach
	 SELECT renglon,
			no_recibo,
			tipo_mov,
			monto,			    
			prima_neta,		    
			impuesto,			
			monto_descontado,
			no_poliza	
	   INTO	v_renglon,
			v_no_recibo,
			v_tipo_mov,
			v_monto_banco,
			v_prima,
			v_impuesto,
			v_descontada,
			v_no_poliza	 		
	   FROM cobredet
	  WHERE no_remesa = v_no_remesa
		AND renglon   <> 0
		--AND tipo_mov in ("P")
	  ORDER BY no_remesa, renglon

	  select cod_contratante
	    into _cod_contratante
		from emipomae
	   where no_poliza = v_no_poliza;

	  SELECT nombre
	    INTO _asegurado
	    FROM cliclien
	   WHERE cod_cliente = _cod_contratante;	

		-- Obtiene el Monto del Banco

		IF v_tipo_mov   = 'M' AND
		   v_descontada <> 0  THEN
			LET _monto = 0;
		ELSE
			LET _monto = v_monto_banco;
		END IF

		LET v_monto_banco = _monto - v_descontada;

		let _com_ganada = 0.00;
		let v_prima1 = v_prima;

		foreach
			select renglon,
				   cod_agente,
				   porc_comis_agt,
				   porc_partic_agt
			  into _renglon,
			       _cod_agente,
				   _porc_comis_agt,
				   _porc_partic_agt
			  from cobreagt
			 where no_remesa = v_no_remesa
			   and renglon = v_renglon
			
			select nombre,
		           no_licencia,
		           tipo_pago,
			       direccion_1,
			       telefono1,
			       e_mail,
				   tipo_pago
			  into _n_agente,
				   _no_licencia,
				   _tipo_pago,
				   _direccion_1,
				   _telefono_1,
				   _email,
				   v_tipo_pago
			  from agtagent
			 where cod_agente = _cod_agente;

			let _com_ganada = (v_prima * (_porc_partic_agt / 100)) * _porc_comis_agt / 100 ;

			INSERT INTO tmp_cob(
				cod_agente,		  
			 	n_corredor,  	  
			 	no_licencia, 	  
			 	direccion,	 	  
			 	telefono,	 	  
			 	email,		 	  
		     	no_recibo, 	 	  
			 	no_poliza,	 	  
			 	asegurado,	 	  
			 	prima,		 	  
			 	porc_partic_agt,  
			 	porc_comis_agt,   
			 	com_ganada,       
			 	com_descontada,	 
			 	tipo_pago,	 	 
			 	renglon,
			 	remesa,	 	  
			 	seleccionado  
			 	)	
			VALUES (
				_cod_agente,			
				_n_agente,			 
				_no_licencia,        
				_direccion_1,      
				_telefono_1,     
				_email,    
				v_no_recibo,
				v_no_poliza,
				_asegurado,
				v_prima1,
				_porc_partic_agt,
				_porc_comis_agt,
				_com_ganada,       
				v_descontada,     
				v_tipo_pago,
				v_renglon,
				v_no_remesa,
				1
				);		   
			let v_prima1 = 0;

		end foreach
  end foreach
END FOREACH

{FOREACH 
 SELECT renglon,
		no_recibo,
		tipo_mov,
		doc_remesa,
		desc_remesa,
		monto * -1,		    
		prima_neta,		    
		impuesto,			
		monto_descontado	
   INTO	v_renglon,
		v_no_recibo,
		v_tipo_mov,
		v_doc_remesa,
		v_desc_remesa,
		v_monto_banco,
		v_prima,
		v_impuesto,
		v_descontada	 		
   FROM cobredet
  WHERE no_remesa = a_remesa
	AND renglon   <> 0
	AND tipo_mov in ("C")
  ORDER BY no_recibo, renglon

 RETURN v_renglon,			
 		v_no_recibo,			 
 		v_tipo_mov,        
 		v_doc_remesa,      
 		0,     
 		0,    
 		0,
 		0,       
 		v_monto_banco,     
 		v_fecha,          
 		v_periodo,		
 		v_nombre_banco,   
 		v_tipo_remesa,
 		v_actualizado,    
 		v_compania_nombre,
 		a_remesa,
 		'',
 		0,
 		''
 		WITH RESUME;
END FOREACH	}

IF a_codagente <> "*" THEN

	LET v_filtros = "Corredor: " ||  TRIM(a_codagente);

	LET _tipo = sp_sis04(a_codagente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_cob
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_cob
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
	SELECT cod_agente,		  
	 	   n_corredor,  	  
	 	   no_licencia, 	  
	 	   direccion,	 	  
	   	   telefono,	 	  
	 	   email,		 	  
     	   no_recibo, 	 	  
	 	   no_poliza,	 	  
	 	   asegurado,	 	  
	 	   prima,		 	  
	 	   porc_partic_agt,  
	 	   porc_comis_agt,   
	 	   com_ganada,       
	 	   com_descontada,	 
	 	   tipo_pago,	 	 
	 	   renglon,
	 	   remesa
	  INTO _cod_agente,			
		   _n_agente,			 
		   _no_licencia,        
		   _direccion_1,      
		   _telefono_1,     
		   _email,    
		   v_no_recibo,
		   v_no_poliza,
		   _asegurado,
		   v_prima1,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _com_ganada,       
		   v_descontada,     
		   v_tipo_pago,
		   v_renglon,
		   v_no_remesa
	  FROM tmp_cob
	 WHERE seleccionado = 1
	 
	RETURN v_renglon,	      --v_renglon
		   v_no_recibo,       --v_no_recibo
		   _porc_comis_agt,   --porc_comision
		   v_prima1,	      --v_prima
		   _com_ganada,       --com_ganada
		   v_descontada,      --v_descontada
		   v_compania_nombre, --compania
		   v_no_remesa,        --v_no_remesa
		   _cod_agente,        --cod_agente
		   _porc_partic_agt,   --porc_partic
		   _n_agente,          --n_agente
		   _no_licencia,      --v_no_poliza
		   _direccion_1,       --direccion
		   _telefono_1,        --telefono
		   _email,             --email
		   v_tipo_pago,        --tipo_pago
		   v_no_poliza,        --no_poliza
    	   _asegurado          --asegurado
   		   WITH resume;  
END FOREACH
drop table tmp_cob;
end

END PROCEDURE;
				  