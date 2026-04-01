-- Procedimiento que Carga las Comisiones Descontadas por Corredor

-- Creado    : 02/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_atc01b_01068;
CREATE PROCEDURE sp_atc01b_01068(a_compania CHAR(3),a_sucursal CHAR(3),a_ano integer, a_usuario CHAR(10), a_agente VARCHAR(255), a_membrete SMALLINT DEFAULT 0)

RETURNING   VARCHAR(100),
            CHAR(10),
			CHAR(1),
			VARCHAR(30),
			DEC(16,2),
			CHAR(10),
			INTEGER,
		  	VARCHAR(20), 	-- Firma
		  	VARCHAR(20), 	-- Cedula firma
		  	VARCHAR(30),	-- Nombre firma completo
		  	VARCHAR(50);	-- Cargo
			
DEFINE _cod_agente   		CHAR(5);  
DEFINE _no_poliza    		CHAR(10); 
DEFINE _no_remesa    		CHAR(10); 
DEFINE _renglon      		SMALLINT;  
DEFINE _monto        		DEC(16,2);
DEFINE _gen_cheque   		SMALLINT; 
DEFINE _no_recibo    		CHAR(10); 
DEFINE _fecha        		DATE;     
DEFINE _prima        		DEC(16,2);
DEFINE _porc_partic  		DEC(5,2); 
DEFINE _porc_comis   		DEC(5,2); 
DEFINE _comision     		DEC(16,2);
DEFINE _nombre       		CHAR(50); 
DEFINE _no_documento 		CHAR(20); 
DEFINE _no_requis    		CHAR(10); 
DEFINE _cod_tipoprod 		CHAR(3);
DEFINE _tipo_prod    		SMALLINT;
DEFINE _cod_tiporamo 		CHAR(3);
DEFINE _tipo_ramo    		SMALLINT;
DEFINE _cod_ramo     		CHAR(3);
DEFINE _no_licencia  		CHAR(10);

DEFINE v_cuenta		 		CHAR(25);
DEFINE v_debito		 		DEC(16,2);
DEFINE v_credito	 		DEC(16,2);
DEFINE v_no_cheque	 		CHAR(10);
DEFINE v_nombre_ben	 		VARCHAR(100);
DEFINE _anulado		 		SMALLINT;
DEFINE v_fecha_imp	 		DATE;
DEFINE v_monto		 		DEC(16,2);
DEFINE _tipo_persona 		CHAR(1);
DEFINE _comi_ck		 		DEC(16,2);
DEFINE _cinco_seis   		DEC(16,2);
DEFINE _cedula       		VARCHAR(30);
DEFINE _tipo_agente  		CHAR(1);
DEFINE v_firma_cartas	 	VARCHAR(20);
DEFINE v_cedula_cartas	 	VARCHAR(20);
DEFINE v_nombre_completo 	VARCHAR(30);
DEFINE v_cargo           	VARCHAR(50);
DEFINE _tipo                CHAR(1);
DEFINE _cinco_dos     		DEC(16,2);
define _status              char(1);
DEFINE _codigo				CHAR(5);
DEFINE _nombre_filtro		VARCHAR(50);
define _codigo_perfil       char(3);

--DROP TABLE tmp_agente;
drop table if exists tmp_carta;
drop table if exists tmp_carta2;
drop table if exists tmp_carta3;
drop table if exists tmp_agrupa_01068;

CREATE TEMP TABLE tmp_carta(
	cod_agente		CHAR(5),
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	cinco_dos		DEC(16,2),
	no_licencia     CHAR(10),
	cuenta		    CHAR(25),
	tipo_persona    CHAR(1),
	no_cheque       CHAR(10),  
	no_remesa       CHAR(10),
	renglon         SMALLINT,
	cedula          VARCHAR(30),   
	nom_cheq  		CHAR(50)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_carta2(
	cod_agente		CHAR(5),
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	cinco_dos   	DEC(16,2),
	no_licencia     CHAR(10),
	cuenta		    CHAR(25),
	tipo_persona    CHAR(1),
	no_cheque       CHAR(10),  
	no_remesa       CHAR(10),
	renglon         SMALLINT,   
	cedula          VARCHAR(30),
	nom_cheq  		CHAR(50),
	no_requis       CHAR(10),
	PRIMARY KEY (no_requis)) WITH NO LOG;

CREATE TEMP TABLE tmp_carta3(
	nombre			CHAR(50),
	com_desc        DEC(16,2),
	comision        DEC(16,2),
	cinco_seis		DEC(16,2),
	cinco_dos   	DEC(16,2),
	no_licencia     CHAR(10),
	tipo_persona    CHAR(1),
	cedula          VARCHAR(30),   
	nom_cheq  		CHAR(50),
	no_cheque       CHAR(10) DEFAULT NULL,
	cod_agente      CHAR(5),
 	seleccionado	SMALLINT DEFAULT 1
	) WITH NO LOG;
	
create temp table tmp_agrupa_01068(
codigo	char(25) ) with no log;	

SET ISOLATION TO DIRTY READ;

{let a_agente = '01068,01653,01654,01655,01656,01657,01658,01659,01660,01661,01662,01663,01664,01807,01839,02073,02074,02041,02084,02085,02092,02100,02107,02113,02117,02120,02135,02136,02137,02138,02147,02195,02232,02239,02240,02241,02279,02280,02288,02329,02330,02361,02403,02475,02549,02565,02567,02568,02597;';
IF a_agente <> "*" THEN
	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos
END IF
}

let _tipo = ';';
foreach
	SELECT cod_agente
	  into _codigo
	  FROM agtagent
	 WHERE trim(agente_agrupado) = trim(a_agente)
	 
		insert into tmp_agrupa_01068(codigo)
			values(_codigo);
			
end foreach 
									 
FOREACH
	SELECT	no_poliza,
			no_remesa,
			renglon,
			no_recibo,
			fecha,
			monto,
			prima_neta
	  INTO	_no_poliza,
			_no_remesa,
			_renglon,
			_no_recibo,
			_fecha,
			_monto,
			_prima
	  FROM	cobredet
	 WHERE	actualizado      = 1
	   AND tipo_mov         IN ('P','N','C')
	   AND year(fecha)      = a_ano
	   AND monto_descontado <> 0
	 ORDER BY no_remesa, renglon  

	SELECT no_documento,
		   cod_tipoprod,
		   cod_ramo	
	  INTO _no_documento,
		   _cod_tipoprod,
		   _cod_ramo	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

	IF _tipo_prod = 3 OR
	   _tipo_prod = 4 THEN
	   CONTINUE FOREACH;
	END IF
	
	FOREACH
		SELECT	cod_agente,
				monto_man,
				porc_partic_agt,
				porc_comis_agt
		  INTO	_cod_agente,
				_comision,
				_porc_partic,
				_porc_comis
		  FROM	cobreagt
		 WHERE	no_remesa = _no_remesa
		   AND renglon   = _renglon

		SELECT nombre,
			   no_licencia,
			   tipo_persona,
			   cedula,
			   tipo_agente	
		  INTO _nombre,
			   _no_licencia,
			   _tipo_persona,
			   _cedula,
			   _tipo_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		IF _tipo_agente = 'E' THEN
			CONTINUE FOREACH;
		END IF
 
		INSERT INTO tmp_carta(
		cod_agente,		
		nombre,			
		com_desc,     
		comision,        
		cinco_seis,	
		cinco_dos,	
		no_licencia,  
		cuenta,		 
		tipo_persona,
		no_cheque, 
		no_remesa, 
		renglon,
		cedula,
		nom_cheq    
		)
		VALUES(
		_cod_agente,
		trim(_nombre),
		_comision,
		0.00,
		0.00,
		0.00,
		_no_licencia,
		null,
		_tipo_persona,
		null,
		_no_remesa,
		_renglon,
		_cedula,
		_nombre
		);
	END FOREACH
END FOREACH

-- Cheques por cuenta

IF _tipo <> "E" THEN
  FOREACH
	SELECT codigo
	  INTO _codigo
	  FROM tmp_agrupa_01068

    SELECT nombre
	  INTO _nombre_filtro
	  FROM agtagent
	 WHERE cod_agente = _codigo;

	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				REPLACE(TRIM(y.a_nombre_de)," ","%"),
				y.anulado,
				y.fecha_impresion,
				y.monto,
				y.cod_agente,
				y.no_requis
		   INTO	v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp,
				v_monto,
				_cod_agente,
				_no_requis
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND year(y.fecha_impresion) = a_ano 
		    AND y.pagado = 1
	     	AND y.anulado = 0  
			AND (x.cuenta[1,3] in ("564") 			   -->GASTOS POR ADMINISTRACION
			 OR x.cuenta[1,3] in ("521")			   -->HONORARIOS PROFESIONALES-AGENTES Y CORREDORES
			 OR x.cuenta[1,5] in ("26401", "26410"))   -->HONORARIOS POR PAGAR AGENTES Y CORREDORES / HONORARIOS Y COMISIONES POR PAGAR AGENTES AUXILIAR
		    AND (y.cod_agente = _codigo
			 OR REPLACE(TRIM(y.a_nombre_de)," ","%") LIKE _nombre_filtro)
		  ORDER BY y.no_cheque

	   LET _comi_ck	= 0.00;
	   LET _cinco_seis = 0.00;
	   LET _cinco_dos = 0.00;
	   let _nombre = null;

	   IF v_cuenta[1,3] = "264" THEN
		  LET _comi_ck = v_monto;
	   ELIF v_cuenta[1,3] = "564" THEN
	   	  LET _cinco_seis = v_monto;
	   ELSE
	   	  LET _cinco_dos = v_monto;
	   END IF

	   IF _cod_agente IS NOT NULL THEN
			SELECT nombre,
				   no_licencia,
				   tipo_persona,
				   cedula,
				   tipo_agente	
			  INTO _nombre,
				   _no_licencia,
				   _tipo_persona,
				   _cedula,
				   _tipo_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;
		ELSE
		    FOREACH
				SELECT nombre,
					   no_licencia,
					   tipo_persona,
					   cedula,
					   cod_agente,
					   tipo_agente	
				  INTO _nombre,
					   _no_licencia,
					   _tipo_persona,
					   _cedula,
					   _cod_agente,
					   _tipo_agente
				  FROM agtagent
				 WHERE nombre LIKE "%" || TRIM(v_nombre_ben) || "%"
				EXIT FOREACH;
			END FOREACH
		END IF

        IF _nombre IS NULL OR _cod_agente IS NULL OR _tipo_agente = "E" THEN
			CONTINUE FOREACH;
		END IF

        BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

			INSERT INTO tmp_carta2(
			cod_agente,		
			nombre,			
			com_desc,     
			comision,        
			cinco_seis,
			cinco_dos,		
			no_licencia,  
			cuenta,		 
			tipo_persona,
			no_cheque,
			no_remesa,
			renglon,
			cedula,    
			nom_cheq,
			no_requis    
			)
			VALUES(
			_cod_agente,
			trim(_nombre),
			0.00,
			_comi_ck,
			_cinco_seis,
			_cinco_dos,
			_no_licencia,
			v_cuenta,
			_tipo_persona,
			v_no_cheque,
			null,
			null,
			_cedula,
			v_nombre_ben,
			_no_requis
			);
		END
	   
	END FOREACH
  END FOREACH
END IF
--DROP TABLE tmp_agrupa_01068;

FOREACH	WITH HOLD
		SELECT cod_agente,		
			   nombre,			
		       com_desc,     
			   comision,        
			   cinco_seis,		
			   cinco_dos,		
		       no_licencia,  
		       cuenta,		 
		       tipo_persona,
		       no_cheque,
		       no_remesa,
		       renglon,
		       cedula,   
			   nom_cheq    
		 INTO  _cod_agente,
		       v_nombre_ben,
		       _comision,
			   _comi_ck,
			   _cinco_seis,
			   _cinco_dos,		
		       _no_licencia,
		       v_cuenta,
		       _tipo_persona,
			   v_no_cheque,
			   _no_remesa,
			   _renglon,
			   _cedula,
			   _nombre
		 FROM tmp_carta
	 ORDER BY nombre, no_remesa, renglon

		INSERT INTO tmp_carta3(
		nombre,			
		com_desc,     
		comision,      
		cinco_seis,		    
		cinco_dos,		
		no_licencia,  
		tipo_persona,
		cedula,  
   	    nom_cheq,
   	    cod_agente    
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
		_cinco_dos,		
		_no_licencia,
		_tipo_persona,
		_cedula,
		_nombre,
		_cod_agente
		);
END FOREACH
FOREACH	WITH HOLD
		SELECT cod_agente,		
			   nombre,			
		       com_desc,     
			   comision,        
			   cinco_seis,		
			   cinco_dos,		
		       no_licencia,  
		       cuenta,		 
		       tipo_persona,
		       no_cheque,
		       no_remesa,
		       renglon,
			   cedula,
   	           nom_cheq    
		 INTO  _cod_agente,
		       v_nombre_ben,
		       _comision,
			   _comi_ck,
			   _cinco_seis,
			   _cinco_dos,		
		       _no_licencia,
		       v_cuenta,
		       _tipo_persona,
			   v_no_cheque,
			   _no_remesa,
			   _renglon,
			   _cedula,
		       _nombre
		 FROM tmp_carta2
	 ORDER BY nombre, no_cheque

		INSERT INTO tmp_carta3(
		nombre,			
		com_desc,     
		comision,      
		cinco_seis,		    
		cinco_dos,		
		no_licencia,  
		tipo_persona,
		cedula,  
   	    nom_cheq,
   	    no_cheque,
   	    cod_agente    
		)
		VALUES(
		v_nombre_ben,
		_comision,
		_comi_ck,
		_cinco_seis,
	   	_cinco_dos,		
		_no_licencia,
		_tipo_persona,
		_cedula,
		_nombre,
		v_no_cheque,
		_cod_agente
		);
END FOREACH
-- Buscando Firma y Cedula de la Carta

	SELECT valor_parametro 
	  INTO v_firma_cartas
	  FROM inspaag
	 WHERE codigo_parametro = "firma_cartas"; 

	SELECT valor_parametro 
	  INTO v_cedula_cartas
	  FROM inspaag
	 WHERE codigo_parametro = "cedula_cartas"; 

	SELECT descripcion,status,codigo_perfil 
	  INTO v_nombre_completo,_status,_codigo_perfil
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
{
	IF a_agente <> "*" THEN

		LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

		IF _tipo <> "E" THEN -- (I) Incluir los Registros

			UPDATE tmp_carta3
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente NOT IN (SELECT codigo FROM tmp_agrupa_01068);

		ELSE		        -- (E) Excluir estos Registros

			UPDATE tmp_carta3
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente IN (SELECT codigo FROM tmp_agrupa_01068);

		END IF

		DROP TABLE tmp_agrupa_01068;

	END IF
}
UPDATE tmp_carta3
   SET seleccionado = 0
 WHERE trim(cod_agente) not IN (SELECT trim(codigo) FROM tmp_agrupa_01068);
 
UPDATE tmp_carta3
   SET cod_agente = '01068' --,seleccionado = 0
 WHERE trim(cod_agente) IN (SELECT trim(codigo) FROM tmp_agrupa_01068);

FOREACH	WITH HOLD
	SELECT SUM(com_desc),   	
		   SUM(comision),    
		   SUM(cinco_seis),	    
		   SUM(cinco_dos),	    
		   cod_agente	
	 INTO  _comision,
		   _comi_ck,
		   _cinco_seis,
		   _cinco_dos,
		   _cod_agente
	 FROM tmp_carta3
	WHERE seleccionado = 1
 GROUP BY cod_agente
 ORDER BY cod_agente 

   	LET _monto = _comision + _comi_ck + _cinco_seis + _cinco_dos;

	SELECT nombre,
		   no_licencia,
		   tipo_persona,
		   cedula
	  INTO v_nombre_ben,
		   _no_licencia,
		   _tipo_persona,
		   _cedula
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	 RETURN TRIM(v_nombre_ben),
			TRIM(_no_licencia),
			_tipo_persona,
			TRIM(_cedula),
			_monto,
			a_usuario,
			a_ano,
			trim(v_firma_cartas),
			trim(v_cedula_cartas),
			trim(v_nombre_completo),
			trim(v_cargo)
	   WITH RESUME;
END FOREACH


END PROCEDURE;