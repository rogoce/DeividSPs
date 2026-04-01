   DROP procedure sp_pro1116;
   CREATE procedure sp_pro1116(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_usuario CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*",a_codsubramo CHAR(255) DEFAULT "*")
	RETURNING 		
		CHAR(150) as Ramo,
		CHAR(150) as Subramo,
		CHAR(20) as no_poliza,
		CHAR(45) as Contratante,
		integer as cant_asegurado,
		DATE as Vig_Inicial,
		DATE as Vig_Final,
		char(10) as Estatus,
		VARCHAR(150) as Direccion_Contratante,
		CHAR(80) as Telefonos,
		DECIMAL(16,2) as Prima_Anual,
		DECIMAL(16,2) as Prima_Cobrada,
		CHAR(5) as 	Cod_Corredor,
		VARCHAR(50) as 	Nombre_Corredor,
		char(80) as Zona_Ventas,
		Char(255) as filtros;


   {
   RETURNING CHAR(3),CHAR(50),CHAR(20),CHAR(45),DATE,DATE,
             CHAR(40),DECIMAL(16,2),DECIMAL(16,2),
             CHAR(255),CHAR(50),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),CHAR(5),
			 CHAR(10),VARCHAR(50),VARCHAR(50),char(3),char(50),char(10);
			 }

--------------------------------------------
---       POLIZAS VIGENTES POR RAMO      ---
---  Amado Perez - Abril 2001 - YMZM
---  Ref. Power Builder - d_sp_pro60
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_sucursal, _cod_coasegur CHAR(3);
    DEFINE v_saber					  CHAR(2);
    DEFINE v_cod_grupo                CHAR(5);
    DEFINE v_contratante,v_codigo     CHAR(10);
    DEFINE v_asegurado                CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente, v_subramo, _n_corredor CHAR(50);
    DEFINE v_desc_grupo               CHAR(40);
    DEFINE no_documento               CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   DATE;
    DEFINE v_cant_polizas             INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada ,_prima_bruta  DECIMAL(16,2);
    DEFINE _tipo              CHAR(1);
    DEFINE v_filtros,v_filtros1,v_filtros2     CHAR(255);
	DEFINE _cod_subramo,_cod_vendedor       CHAR(3);
	DEFINE _cod_agente        CHAR(5);
	DEFINE _no_poliza         CHAR(10);
	DEFINE v_prima_pagada     DEC(16,2);
	DEFINE _periodo           CHAR(7);
	DEFINE _porc_comis_agt, _porcentaje	  DEC(16,2);
	DEFINE v_direccion_1, v_direccion_2,_n_vendedor VARCHAR(50);
	DEFINE _estatus_poliza		SMALLINT;
    define v_telefono1		    char(10);  -- telefono del contratante
    define v_telefono2		    char(10);  -- celular del contrantante	
	define _Ramo		            CHAR(150);
	define _Subramo		        CHAR(150);
	define _Dir_Contratante 	    VARCHAR(150);
	define _Zona_Ventas			char(80);
	define _Telefonos			CHAR(80);
	DEFINE _cant_asegurados    INTEGER;

--SET DEBUG FILE TO "sp_pro1116.trc";
--trace on;


    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET no_documento     = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
	LET _prima_bruta = 0;
    LET _tipo            = NULL;
    let _cant_asegurados = 0;
	LET v_filtros = '' ;
	LET v_filtros1 = ''  ;
	LET v_filtros2 = '' ;
	
	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = a_cia;

    LET v_descr_cia = sp_sis01(a_cia);
  
    CALL sp_pro1116a(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;
  
    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal: "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF
    IF a_codgrupo <> "*" THEN
        LET v_filtros = TRIM(v_filtros) ||"Grupo: "; --||TRIM(a_codgrupo);
        LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

        IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
			LET v_saber = "";
        ELSE
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
		       LET v_saber = " Ex";
        END IF
		SELECT cligrupo.nombre,tmp_codigos.codigo
          INTO v_desc_grupo,v_codigo
          FROM cligrupo,tmp_codigos
         WHERE cligrupo.cod_grupo = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || TRIM(v_saber);
         DROP TABLE tmp_codigos;
    END IF

    IF a_agente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --||TRIM(a_agente);
         LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

        IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
			LET v_saber = "";
        ELSE
            UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_agente IN(SELECT codigo FROM tmp_codigos);
		    LET v_saber = " Ex";
        END IF
		FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
	          INTO v_desc_agente,v_codigo
	          FROM agtagent,tmp_codigos
	         WHERE agtagent.cod_agente = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
		END FOREACH

        DROP TABLE tmp_codigos;
    END IF
    IF a_cod_cliente <> "*" THEN
        LET v_filtros = TRIM(v_filtros) ||"Cliente: "||TRIM(a_cod_cliente);
        LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

        IF _tipo <> "E" THEN -- Incluir los Registros

			UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
        ELSE
           UPDATE temp_perfil
              SET seleccionado = 0
            WHERE seleccionado = 1
              AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
        END IF
        DROP TABLE tmp_codigos;
    END IF

--Filtro de Poliza
	IF a_no_documento <> "*" and a_no_documento <> "" THEN
        LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
        UPDATE temp_perfil
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND no_documento <> a_no_documento;
    END IF
	
IF a_codramo <> "*" THEN
	LET _tipo = sp_sis04(a_codramo);  -- Separa los Valores del String en una tabla de codigos
   	LET v_filtros1 = TRIM(v_filtros1) || " Ramo: " ||  TRIM(a_codramo);
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF


IF a_codsubramo <> "*"  THEN
	LET _tipo = sp_sis04(a_codsubramo);  -- Separa los Valores del String en una tabla de codigos
	LET v_filtros2 = TRIM(v_filtros2) || " Subramo: " ||  TRIM(a_codsubramo);
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   and cod_ramo = trim(a_codramo[1,3]) 
		   AND cod_subramo NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   and cod_ramo = trim(a_codramo[1,3]) 
		   AND cod_subramo IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF
LET v_filtros = TRIM(v_filtros1) || TRIM(v_filtros2)  ;

	SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD

		SELECT y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.cod_subramo,
		       y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.cod_agente,
			   y.no_poliza, y.estatus_poliza,y.cant_asegurados,y.prima_bruta
		  INTO no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,_cod_subramo,
		       v_vigencia_final,v_cod_grupo,v_suma_asegurada,
		       v_prima_suscrita,_cod_agente,_no_poliza, _estatus_poliza, _cant_asegurados,_prima_bruta
		FROM temp_perfil y
	   WHERE y.seleccionado = 1
	   ORDER BY y.cod_ramo,y.cod_subramo,y.no_documento

		SELECT a.nombre
		  INTO v_desc_ramo
		  FROM prdramo a
		 WHERE a.cod_ramo  = v_cod_ramo;

		SELECT nombre 
		  INTO v_subramo
		  FROM prdsubra
		 WHERE cod_ramo = v_cod_ramo
		   AND cod_subramo = _cod_subramo;

		SELECT porc_comis_agt
		  INTO _porc_comis_agt
		  FROM emipoagt
		 WHERE cod_agente = _cod_agente
		   AND no_poliza  = _no_poliza;
		   
		select nombre, cod_vendedor
          into _n_corredor,_cod_vendedor
          from agtagent
         where cod_agente = _cod_agente;
		 
		select nombre
          into _n_vendedor
          from agtvende
         where cod_vendedor = _cod_vendedor;

		SELECT nombre,
			   direccion_1,
		       direccion_2,
			   nvl(telefono1,''),
	           nvl(celular,'')
		  INTO v_asegurado,
		       v_direccion_1,
		       v_direccion_2,
			   v_telefono1,
	           v_telefono2
		  FROM cliclien
		 WHERE cod_cliente = v_contratante;
		 
		 	if v_direccion_1 is null then
				let v_direccion_1 = '';
			end if	
			if v_direccion_2 is null then
				let v_direccion_2 = '';
			end if	
		 	if v_telefono1 is null then
				let v_telefono1 = '';
			end if	
			if v_telefono2 is null then
				let v_telefono2 = '';
			end if				

		SELECT nombre
		  INTO v_desc_grupo
		  FROM cligrupo
		 WHERE cod_grupo = v_cod_grupo;

		SELECT periodo
		  INTO _periodo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		-- Primas Pagadas
		
		LET v_prima_pagada = 0;
		BEGIN
		DEFINE _no_remesa    CHAR(10);     
		DEFINE _prima_pagada DEC(16,2);

		FOREACH
			SELECT no_poliza,
			       monto, --prima_neta,
			       periodo
			  INTO _no_poliza,
			       _prima_pagada,
			       _periodo
			  FROM cobredet
			 WHERE cod_compania = a_cia
			   AND actualizado  = 1
			   AND tipo_mov IN ('P', 'N')
			   AND no_poliza   = _no_poliza
			   AND fecha      <= today 
			   AND renglon    <> 0

			SELECT porc_partic_coas
			  INTO _porcentaje
			  FROM emihcmd
			 WHERE no_poliza    = _no_poliza
			   AND no_cambio    = '000'
			   AND cod_coasegur = _cod_coasegur;

			IF _porcentaje IS NULL THEN
				LET _porcentaje = 100;
			END IF	    

			LET _prima_pagada = _prima_pagada / 100 * _porcentaje;
			LET v_prima_pagada = v_prima_pagada + _prima_pagada;
		END FOREACH
END

		let _Ramo = trim(v_desc_ramo)||' - '||trim(v_cod_ramo);
		let _subramo = trim(v_subramo)||' - '||trim(_cod_subramo);
		let _Dir_Contratante = trim(v_direccion_1)||'  '||trim(v_direccion_2);
		let _telefonos = trim(v_telefono1)||'  '||trim(v_telefono2);
		let _Zona_Ventas = trim(_n_vendedor )||' - '||trim(_cod_vendedor);

			if _cant_asegurados is null then
				let _cant_asegurados = 0;
			end if		
		RETURN  
			_Ramo,
			_subramo,
			no_documento,
			v_asegurado,
			_cant_asegurados,
			v_vigencia_inic,
			v_vigencia_final,
			(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end) ,
			_Dir_Contratante,
			_telefonos,
			_prima_bruta,  --v_prima_suscrita,
			v_prima_pagada,
			_cod_agente,
			_n_corredor,
			_Zona_Ventas,
			v_filtros
			WITH RESUME;

	           

{
RETURN  v_cod_ramo,
		v_desc_ramo,
		no_documento,
		v_asegurado,
		v_vigencia_inic,
		v_vigencia_final,
		v_desc_grupo,
		v_suma_asegurada,
		v_prima_suscrita,
		v_filtros,
		v_descr_cia,
		v_subramo,
		v_prima_pagada,
		_porc_comis_agt,
		_cod_agente, 
		_no_poliza,
		v_direccion_1,
		v_direccion_2,
		_cod_vendedor,
		_n_vendedor,
			(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end)   
			WITH RESUME;
			}
			
    END FOREACH
DROP TABLE temp_perfil;
--execute procedure sp_pro1116('001','001','15-03-2024',"*", "004;", "*", "*", "*",  "*",  "*");
END PROCEDURE;
