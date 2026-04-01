-- Cheques Pagados a Proveedores de Salud

-- Creado    : 01/02/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 01/02/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che11_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_atc04;

CREATE PROCEDURE sp_atc04(a_compania CHAR(3), a_sucursal CHAR(3), a_ano INT, a_cod_cliente CHAR(255), a_usuario CHAR(10), a_membrete SMALLINT DEFAULT 0) 
RETURNING CHAR(100),	-- Nombre Asegurado
		  CHAR(30),		-- Cedula
		  DEC(16,2),	-- Monto
		  CHAR(10),		-- Ususario
		  INTEGER,
		  VARCHAR(20), 	-- Firma
		  VARCHAR(20), 	-- Cedula firma
		  VARCHAR(30),	-- Nombre firma completo
		  VARCHAR(50);	-- Cargo

DEFINE _nombre           CHAR(100);
DEFINE _cedula           CHAR(30); 
DEFINE _monto            DEC(16,2);
DEFINE v_nombre_cia      CHAR(50); 
DEFINE _fecha_char		 CHAR(100);
DEFINE _cod_cliente      CHAR(10); 
DEFINE _tipo			 CHAR(1);
DEFINE v_firma_cartas	 VARCHAR(20);
DEFINE v_cedula_cartas	 VARCHAR(20);
DEFINE v_nombre_completo VARCHAR(30);
DEFINE v_cargo           VARCHAR(50);
DEFINE _status           char(1);
define _codigo_perfil    char(3);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

--LET v_nombre_cia = sp_sis01(a_compania); 

--let _fecha_char = sp_sis20(today);

-- Separa los valores en una tabla de codigos

IF a_cod_cliente <> "*" THEN

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

	foreach
	 SELECT t.cod_cliente,
	        sum(t.monto)
	   into _cod_cliente,
	        _monto
	   FROM chqchmae c, chqchrec r, rectrmae t
	  WHERE c.no_requis        = r.no_requis
	    and r.transaccion      = t.transaccion
	    and c.pagado           = 1
	    AND c.origen_cheque    = 3
	    AND c.anulado          = 0
	    and t.cod_tipopago     in ("001", "002")
	    AND Year(c.fecha_impresion)  = a_ano
	    and t.cod_cliente      IN (SELECT codigo FROM tmp_codigos)
	  group by t.cod_cliente

		SELECT cedula,
			   nombre	
		  INTO _cedula,
		       _nombre
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente; 		

		-- Buscando Firma y Cedula de la Carta

		SELECT valor_parametro 
		  INTO v_firma_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "firma_cartas"; 

		SELECT valor_parametro 
		  INTO v_cedula_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "cedula_cartas"; 

		SELECT descripcion, status, codigo_perfil
		  INTO v_nombre_completo, _status, _codigo_perfil
		  FROM insuser
		 WHERE usuario = v_firma_cartas;

		 if _status = "A" then
		 else

			SELECT valor_parametro 
			  INTO v_firma_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "firma_carta2"; 
			
			SELECT valor_parametro 
			  INTO v_cedula_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "cedula_carta2";

			SELECT descripcion,
			       status 
			  INTO v_nombre_completo,
			       _status
			  FROM insuser
			 WHERE usuario = v_firma_cartas;

		 end if
		  

		SELECT cargo
		  INTO v_cargo
		  FROM wf_firmas
		 WHERE usuario = trim(v_firma_cartas);
		 
		if v_cargo is null then
			select descripcion
			  into v_cargo
			  from inspefi
			 where codigo_perfil = _codigo_perfil;
			
		end if		 

		RETURN _nombre,
			   _cedula,
			   _monto,
			   a_usuario,
			   a_ano,
			   trim(v_firma_cartas),
			   trim(v_cedula_cartas),
			   trim(v_nombre_completo),
			   trim(v_cargo)
			   WITH RESUME;	

	end foreach

	DROP TABLE tmp_codigos;
ELSE
	foreach
	 SELECT t.cod_cliente,
	        sum(t.monto)
	   into _cod_cliente,
	        _monto
	   FROM chqchmae c, chqchrec r, rectrmae t
	  WHERE c.no_requis        = r.no_requis
	    and r.transaccion      = t.transaccion
	    and c.pagado           = 1
	    AND c.origen_cheque    = 3
	    AND c.anulado          = 0
	    and t.cod_tipopago     in ("001", "002")
	    AND Year(c.fecha_impresion)  = a_ano
	  group by t.cod_cliente

		SELECT cedula,
			   nombre	
		  INTO _cedula,
		       _nombre
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente; 		

		-- Buscando Firma y Cedula de la Carta

		SELECT valor_parametro 
		  INTO v_firma_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "firma_cartas"; 

		SELECT valor_parametro 
		  INTO v_cedula_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "cedula_cartas"; 

		SELECT descripcion,status ,codigo_perfil 
		  INTO v_nombre_completo,_status, _codigo_perfil
		  FROM insuser
		 WHERE usuario = v_firma_cartas;

		 if _status = "A" then
		 else

			SELECT valor_parametro 
			  INTO v_firma_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "firma_carta2"; 
			
			SELECT valor_parametro 
			  INTO v_cedula_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "cedula_carta2";

			SELECT descripcion,
			       status 
			  INTO v_nombre_completo,
			       _status
			  FROM insuser
			 WHERE usuario = v_firma_cartas;

		 end if

		SELECT cargo
		  INTO v_cargo
		  FROM wf_firmas
		 WHERE usuario = trim(v_firma_cartas);
		 
			if v_cargo is null then
				select descripcion
				  into v_cargo
				  from inspefi
				 where codigo_perfil = _codigo_perfil;
				
			end if		 

		RETURN _nombre,
			   _cedula,
			   _monto,
			   a_usuario,
			   a_ano,
			   trim(v_firma_cartas),
			   trim(v_cedula_cartas),
			   trim(v_nombre_completo),
			   trim(v_cargo)
			   WITH RESUME;	

	end foreach
END IF


END PROCEDURE;