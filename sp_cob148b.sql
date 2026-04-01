-- Morosidad por Agente - Totales carta corriente
-- 
-- Creado    : 08/10/2000 - Autor: Armando Moreno
-- Modificado: 08/10/2000 - Autor: Armando moreno
-- se hizo mod. para que de las polizas sin pago a 90, se evaluara la vigencia ini de la poliza con respecto
-- a la fecha de generacion, si es >= a 90 debe salir en el reporte. 29/03/2004 Armando.

DROP PROCEDURE sp_cob148b;

CREATE PROCEDURE "informix".sp_cob148b(a_compania CHAR(3),a_agencia CHAR(3),a_periodo DATE,a_sucursal   CHAR(255),a_coasegur   CHAR(255) DEFAULT '*',a_ramo CHAR(255) DEFAULT '*',a_formapago CHAR(255) DEFAULT '*',a_acreedor   CHAR(255) DEFAULT '*',a_agente     CHAR(255) DEFAULT '*',a_cobrador   CHAR(255) DEFAULT '*',a_tipo_moros CHAR(255) DEFAULT '1',a_incobrable INT DEFAULT 1,a_producto	 CHAR(255) DEFAULT '*',a_gestion  CHAR(255) DEFAULT '*',a_firma	 CHAR(255) DEFAULT '*',a_cargo	 CHAR(255) DEFAULT '*',a_monto  INT	DEFAULT 0)
 RETURNING  CHAR(50),  -- Nombre Agente
			INTEGER,   -- Cantidad de Polizas	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Compania
			CHAR(100), -- nota
			CHAR(255), -- Filtros
			integer,   -- cant polizas vig
		    DEC(16,2), -- moro Dias 90 de las polizas vig.
			CHAR(5),   -- cod_agente
			CHAR(10),  -- telefono ejecutivo
			CHAR(30);  -- email ejecutivo

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_codigo			   CHAR(10);
DEFINE v_cantidad          INTEGER;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE _por_vencer_c       DEC(16,2);
DEFINE _exigible_c         DEC(16,2);
DEFINE _corriente_c        DEC(16,2);
DEFINE _monto_30_c         DEC(16,2);
DEFINE _monto_60_c         DEC(16,2);
DEFINE _monto_90_c         DEC(16,2);
DEFINE _monto_corriente    DEC(16,2);
DEFINE v_nota              CHAR(100);
DEFINE v_compania_nombre,v_nombre_prod   CHAR(50);
DEFINE v_desc              CHAR(50);
DEFINE _cod_agente         CHAR(5);
DEFINE v_saber             CHAR(3);
DEFINE _cod_cobrador       CHAR(3);
DEFINE _cobra_poliza       CHAR(1);
DEFINE _e_mail             CHAR(30);
DEFINE _usuario            CHAR(10);
DEFINE _tele     		   CHAR(10);
DEFINE _cant_polizas	   INTEGER;
DEFINE _vigencia_inic	   date;
DEFINE _monto_90_vig       DEC(16,2);

set isolation to dirty read;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03b.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob148a(
a_compania,
a_agencia,
a_periodo,
a_tipo_moros,
a_monto,
a_agente
);

-- Procesos para Filtros

LET v_filtros = "";
LET v_nota    = "";
let _monto_90_vig = 0;

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_coasegur <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_coasegur);

	LET _tipo = sp_sis04(a_coasegur);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo : " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_formapago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formapago);

	LET _tipo = sp_sis04(a_formapago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formapago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_acreedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Acreedor: " ||  TRIM(a_acreedor);

	LET _tipo = sp_sis04(a_acreedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_acreedor IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_cartadet
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

		UPDATE tmp_cartadet
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cobrador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_producto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Producto: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_producto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
		   LET v_nota = " Nota: Se considera un solo producto para la poliza." ;
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
		   LET v_nota = " Nota: Se considera un solo producto para la poliza.";
	END IF
		SELECT prdprod.nombre,tmp_codigos.codigo
          INTO v_nombre_prod,v_codigo
          FROM prdprod,tmp_codigos
         WHERE prdprod.cod_producto = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_prod) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF
IF a_incobrable <> 1 THEN

	IF a_incobrable = 2 THEN  -- Sin Incobrables

		LET v_filtros = TRIM(v_filtros) || " Sin Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

		UPDATE tmp_cartadet
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

	ELSE		        -- Solo Incobrables

		LET v_filtros = TRIM(v_filtros) || " Solo Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

		UPDATE tmp_cartadet
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

	END IF

END IF

FOREACH
 SELECT	cod_agente,
		COUNT(*),
 		SUM(prima_orig),
		SUM(por_vencer),
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90)
   INTO	_cod_agente,
		v_cantidad,
   		v_prima_bruta,    
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90
   FROM	tmp_moros
  WHERE seleccionado = 1
  GROUP BY cod_agente
  ORDER BY cod_agente

	let _cant_polizas    = 0;
	let	_monto_corriente = 0;

	foreach
		 SELECT	por_vencer,
		 		exigible,
				corriente,
				monto_30,
				monto_60,
				monto_90,
				cod_cobrador,
				cobra_poliza
		   INTO	_por_vencer_c,
				_exigible_c,
				_corriente_c,
				_monto_30_c,
				_monto_60_c,
				_monto_90_c,
				_cod_cobrador,
				_cobra_poliza
		   FROM	tmp_moros
		  WHERE seleccionado = 1
			AND cod_agente = _cod_agente

		if _cobra_poliza <> "C" then
			continue foreach;
		end if

		--Solo evaluaremos polizas que esten corrientes
	 	IF _corriente_c  > 0 and 
	 	   _monto_30_c   = 0 and 
	 	   _monto_60_c   = 0 and
	 	   _monto_90_c   = 0 then
		   let _cant_polizas    = _cant_polizas + 1;
		   let _monto_corriente = _monto_corriente + _corriente_c;
		ELSE
			CONTINUE FOREACH;			
		END IF

	end foreach

  foreach
    select nombre_agente,
		   cod_cobrador
	  into v_nombre_agente,
		   _cod_cobrador
	  from tmp_moros
	 where cod_agente = _cod_agente

	select telefono,
		   usuario
	  into _tele,
		   _usuario
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	if _cod_cobrador is null then
		let _tele = "210-8797";
	end if

	select e_mail
	  into _e_mail
	  from insuser
	 where usuario = _usuario;

	if _e_mail is null then
		let _e_mail = "dayra@asegurancon.com";
	end if

     exit foreach;
  end foreach

	RETURN 	v_nombre_agente,
			v_cantidad,
			v_prima_bruta,    
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
		    v_compania_nombre,
			v_nota,
		    v_filtros,
			_cant_polizas,
			_monto_corriente,
			_cod_agente,
			_tele,
			_e_mail
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;

END PROCEDURE;

