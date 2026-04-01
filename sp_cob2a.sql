-- Morosidad por Coasegurador - Detalle
-- 
-- Creado    : 04/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/03/2001 - Autor: Marquelda Valdelamar
-- Modificado: 24/04/2002 - Autor: Armando Moreno, reemplazar vig_fin por fecha_cancelacion cuando la poliza esta cancelada
-- SIS v.2.0 - d_cobr_sp_cob02a_dw1 - DEIVID, S.A.
-- Modificado: 07/10/2002 - Autor: Armando Moreno M.(filtro de gestion de cobros)
-- Modificado: 11/05/2007 - Autor: Rub‚n Dar¡o Arn ez (adici¢n del filtro filtro de gestion de grupo)

--''001'',''001'',''29/02/2024'',''*'',''*'',''*'',''*'',''*'',''*'',''*'',1,''*'',''*'' 
DROP PROCEDURE sp_cob02a;
CREATE PROCEDURE sp_cob02a(
a_compania   CHAR(3), 
a_agencia    CHAR(3), 
a_periodo    DATE,
a_sucursal   CHAR(255) DEFAULT '*',
a_coasegur   CHAR(255) DEFAULT '*',
a_ramo		 CHAR(255) DEFAULT '*',
a_formapago	 CHAR(255) DEFAULT '*',
a_acreedor   CHAR(255) DEFAULT '*',
a_agente     CHAR(255) DEFAULT '*',
a_cobrador   CHAR(255) DEFAULT '*',
a_incobrable INT	   DEFAULT 1,
a_gestion    CHAR(255) DEFAULT '*',
a_grupo      CHAR(255) DEFAULT '*' 
) RETURNING CHAR(100) as asegurado, -- Asegurado
			CHAR(20)  as poliza,  -- Poliza	
			CHAR(1)   as estatus,   -- Estatus	
			CHAR(4)   as forma_pago,   -- Forma Pago
			CHAR(30)  as poliza_coaseguro,  -- Poliza Coaseguro
			DATE      as vigencia_inicial,      -- Vigencia Inicial
			DATE      as vigencia_final,      -- Vigencia Final
			DEC(16,2) as prima_ori, -- Prima Original
			DEC(16,2) as saldo, -- Saldo
			DEC(16,2) as por_vencer, -- Por Vencer
			DEC(16,2) as exigible, -- Exigible
			DEC(16,2) as corriente, -- Corriente
			DEC(16,2) as monto_30, -- Dias 30
			DEC(16,2) as monto_60, -- Dias 60
			DEC(16,2) as monto_90, -- Dias 90
			CHAR(50)  as nombre_asegur,  -- Nombre Aseguradora
			CHAR(50)  as nombre_cia,  -- Nombre Compania
			CHAR(255) as filtros, -- Filtros
			CHAR(1)   as gestion,   --gestion
			dec(7,4)  as porc_partic_ancon,  --porc_partic_ancon
			char(5)   as cod_grupo,   --cod_grupo
			char(50)  as nombre_grupo,  --nombre grupo
			char(10)  as estatus_poliza,
			date      as fecha;  --estatus poliza
            
DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE v_estatus,_gestion  CHAR(1); 
DEFINE v_forma_pago        CHAR(4);
DEFINE v_saber,_cod_tipoprod             CHAR(3);
DEFINE v_no_poliza_coas    CHAR(30); 
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;
DEFINE v_fecha_cancelacion DATE;
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nombre_coasegur,v_desc,_n_grupo   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);
DEFINE _no_poliza,v_codigo,_estatus_poliza_c CHAR(10);
define _cod_grupo          CHAR(5);
DEFINE _porc_partic_anc    DEC(7,4);

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Coasegurador

CALL sp_cob02(a_compania,a_agencia,a_periodo);

-- Procesos para Filtros

LET v_filtros = "";

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

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

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

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

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

IF a_incobrable <> 1 THEN

	IF a_incobrable = 2 THEN  -- Sin Incobrables

		LET v_filtros = TRIM(v_filtros) || " Sin Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

	ELSE		        -- Solo Incobrables

		LET v_filtros = TRIM(v_filtros) || " Solo Incobrables ";

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

	END IF

END IF

IF a_gestion <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Gestion:"; -- ||  TRIM(a_gestion);

	LET _tipo = sp_sis04(a_gestion);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion NOT IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT cobgemae.nombre,tmp_codigos.codigo
          INTO v_desc,v_codigo
          FROM cobgemae,tmp_codigos
         WHERE cobgemae.cod_gestion = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc) || " " || TRIM(v_saber);
	 END FOREACH
	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_moros
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
	SELECT nombre_cliente, 
		   doc_poliza,     
		   estatus,        
		   forma_pago,     
		   no_poliza_coas, 
		   vigencia_inic,  
		   vigencia_final, 
		   prima_orig,    
		   saldo,          
		   por_vencer,     
		   exigible,       
		   corriente,     
		   monto_30,       
		   monto_60,       
		   monto_90,
		   nombre_coasegur,
		   no_poliza,
		   gestion
	  INTO v_nombre_cliente, 
		   v_doc_poliza,     
		   v_estatus,        
	   	   v_forma_pago,     
			v_no_poliza_coas, 
			v_vigencia_inic,  
			v_vigencia_final, 
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_nombre_coasegur,
			_no_poliza,
			_gestion
	   FROM	tmp_moros
	  WHERE seleccionado = 1
   ORDER BY nombre_coasegur, nombre_cliente, doc_poliza, vigencia_inic

	SELECT fecha_cancelacion,
	       cod_grupo,
		   cod_tipoprod,
		   decode(estatus_poliza,1,'Vigente',2,'Cancelada',3,'Vencida',4,'Anulada')
	  INTO v_fecha_cancelacion,
	       _cod_grupo,
		   _cod_tipoprod,
		   _estatus_poliza_c
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	select nombre into _n_grupo from cligrupo
	where cod_grupo = _cod_grupo;
	
	let _porc_partic_anc = 0.00;
	
	if _cod_tipoprod = '002' then
	    FOREACH
			select porc_partic_ancon
			  into _porc_partic_anc
			  from emicoami
			where no_poliza = _no_poliza
				exit FOREACH;
		end FOREACH		
	end if
	  
	IF v_estatus = "C" THEN
	  LET v_vigencia_final = v_fecha_cancelacion;
    END IF

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_estatus,        
			v_forma_pago,     
			v_no_poliza_coas, 
			v_vigencia_inic,  
			v_vigencia_final, 
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_nombre_coasegur,
		    v_compania_nombre,
		    v_filtros,
			_gestion,
			_porc_partic_anc,
			_cod_grupo,
			_n_grupo,
			_estatus_poliza_c,
			a_periodo
			WITH RESUME;
END FOREACH
DROP TABLE tmp_moros;
END PROCEDURE;

