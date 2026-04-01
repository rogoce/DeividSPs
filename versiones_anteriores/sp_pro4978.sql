-- Reporte de contratantes de pólizas, del tipo de producción Coaseguro Minoritario, grupo Pólizas del Estado, Coaseguradora líder = 005ASSA
-- Creado :15/02/2024 - Henry Girón
-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.
{
No. Póliza
Cod Contratante
Contratante
Ramo
Vig Inicial
Vig Final
Coaseguradora Lider (005-Assa)
Porc. Partici. (Porcentaje de Participacion)
Nivel Riesgo (En caso de no tener, mostrra vacio)
}
DROP procedure sp_pro4978;
CREATE PROCEDURE sp_pro4978(a_cia CHAR(3), a_agencia   CHAR(3), a_periodo1  DATE, a_codramo CHAR(255) DEFAULT "*", a_subramo CHAR(255) DEFAULT "*")
RETURNING   CHAR(20) as Poliza,
			CHAR(10) as Contratante,
			VARCHAR(100) as Nombre_Contratante,		
			VARCHAR(50) as Ramo,	
            DATE AS vigencia_inicial,
		    DATE AS vigencia_final,			
            VARCHAR(50) AS cia_aseguradora,			
		    DEC(7,4) AS coas_asumido,
			varchar(30) as nivel_riesgo;			

 BEGIN

    DEFINE v_nopoliza,v_contratante,_cod_asegurado   CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente, _no_endoso          CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo                            CHAR(01);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
	DEFINE _dependientes,_edad INTEGER;
	DEFINE _cant_ase integer;
	DEFINE v_desc_contratante               VARCHAR(100);
	DEFINE _edadcal                         SMALLINT;
	DEFINE _edadcal_tot                     INTEGER;
	define _estatus_char					char(7);
	define _estatus_poliza                  smallint;
	
	DEFINE _cod_coasegur      CHAR(3);
	DEFINE _porc_partic_ancon DEC(7,4);
	DEFINE _cod_agente        CHAR(5); 
	DEFINE _porc_partic_agt   DEC(5,2);
	DEFINE _porc_comis_agt    DEC(5,2);
	DEFINE _cia_aseguradora   VARCHAR(50);
	DEFINE _coaseguro_asumido DEC(7,4);
	DEFINE _coaseguro_cedido  DEC(7,4);	
	define n_riesgo           varchar(30);	
    DEFINE _cod_riesgo         INTEGER;
	DEFINE _desc_ramo,_desc_subramo  VARCHAR(50);
	
	LET _fecha_hoy = TODAY;
    LET v_prima_suscrita = 0;
    LET _dependientes    = 0;
    LET _edad		     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);
   -- CALL sp_pro03(a_cia,a_agencia,a_periodo1,a_codramo)  RETURNING v_filtros;
  --  CALL sp_pro03h(a_cia,a_agencia,a_periodo1,"018;")  RETURNING v_filtros;

    SET ISOLATION TO DIRTY READ;

    -- Filtro de Subramo
      IF a_subramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
         LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

    FOREACH
       SELECT distinct y.no_poliza,
       		  y.no_documento,
       		  y.cod_ramo,
       		  y.cod_subramo,
              y.cod_contratante,
              y.fecha_suscripcion,
              y.vigencia_inic,
              y.vigencia_final,
              y.prima_suscrita	 --,y.cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_fecha_suscripc,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita    --,v_codagente
         FROM temp_perfil y
        WHERE cod_grupo = '1000' and cod_tipoprod = '002' and no_poliza in (
		'2322356',
'2322357',
'2322359',
'2322360',
'2322361',
'2322366',
'2322367',
'2322368',
'2322369',
'2322372',
'2322375',
'2322376',
'2322379',
'2322380',
'2322381',
'2322385',
'2322409',
'2322410',
'2322411',
'2322413',
'2322414',
'2322415',
'2322416',
'2322418',
'2322466',
'2322467',
'2322468',
'2322469',
'2322470',
'2322495',
'2322496',
'2322497',
'2322498',
'2322499',
'2322500',
'2322501',
'2322502',
'2322503',
'2322504',
'2322505',
'2322531',
'2322532',
'2322533',
'2322534',
'2322535',
'2322536',
'2322556',
'2322557',
'2322558',
'2322559',
'2322560',
'2322562',
'2322581',
'2322582',
'2322583',
'2322584',
'2322585',
'2322586',
'2322587',
'2322588',
'2322589',
'2322590',
'2322591',
'2322608',
'2322609',
'2322610',
'2322611',
'2322612',
'2322613',
'2322614',
'2322615',
'2322616',
'2322617',
'2322640',
'2322641',
'2322643',
'2322644',
'2322645',
'2322647',
'2322672',
'2322673',
'2322674',
'2322675',
'2322676',
'2322677',
'2322678',
'2322696',
'2322697',
'2322698',
'2322699',
'2322725',
'2322726',
'2322727',
'2322729',
'2322730',
'2322821',
'2322822',
'2322823',
'2322825',
'2322826',
'2384025',
'2384027',
'2384028',
'2384029'
		)
	--	and seleccionado = 1
		--  and no_documento = '1899-00076-01'
           
       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;
		  
		LET  _cod_coasegur = NULL;  
		LET  _porc_partic_ancon = 0.00;  
		LET  _cia_aseguradora = NULL;  
		   
		SELECT cod_coasegur,
			   porc_partic_ancon
		  INTO _cod_coasegur,
			   _porc_partic_ancon
		  FROM emicoami
		 WHERE no_poliza = v_nopoliza;
		 
		IF _cod_coasegur IS NOT NULL THEN
			SELECT nombre
			  INTO _cia_aseguradora
			  FROM emicoase
			 WHERE cod_coasegur = _cod_coasegur;
			 
			LET _coaseguro_asumido = _porc_partic_ancon;
			LET _coaseguro_cedido = 100 - _porc_partic_ancon;
		ELSE
			LET _coaseguro_asumido = 100;
			LET _coaseguro_cedido = 0;
		END IF
	

       let _cant_ase = 1;

       SELECT count(*)
         INTO _cant_ase
         FROM emipouni
        WHERE no_poliza     = v_nopoliza
          AND vigencia_inic <= a_periodo1
          AND activo        = 1;

       if _cant_ase = 0 then
			let _cant_ase = 1;
	   end if

	   SELECT COUNT(*)
         INTO _dependientes
         FROM emidepen
        WHERE no_poliza = v_nopoliza
          AND activo = 1
          AND fecha_efectiva <= a_periodo1;

	   SELECT nombre
	     INTO v_desc_contratante
		 FROM cliclien
		WHERE cod_cliente = v_contratante;

	   IF _dependientes IS NULL THEN
			LET _dependientes = 0;
	   END IF

       let _edadcal_tot = 0;

       FOREACH
		SELECT cod_asegurado
		  INTO _cod_asegurado
          FROM emipouni
         WHERE no_poliza     = v_nopoliza
           AND vigencia_inic <= a_periodo1
           AND activo        = 1

        SELECT fecha_aniversario
		  INTO _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

         LET _edadcal = sp_sis78(_fecha_aniversario);
         let _edadcal_tot  = _edadcal_tot + _edadcal;

	   END FOREACH

	   select estatus_poliza into _estatus_poliza from emipomae where no_poliza = v_nopoliza;

	   let _estatus_char = null;

       if _estatus_poliza = 1 then
		let _estatus_char = 'VIGENTE';
	   elif _estatus_poliza = 3 then
 		let _estatus_char = 'VENCIDA';
	   end if
	   
		select cod_riesgo 
		into _cod_riesgo 
		from ponderacion
        where cod_cliente = v_contratante;
        		
		select nombre 
		into n_riesgo 
		from cliriesgo
		where cod_riesgo = _cod_riesgo;	  

	   SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;		

		
	     let _desc_ramo = trim(v_desc_ramo)||' - '||trim(v_codramo);
 --      RETURN   v_codsubramo,v_desc_subr,v_documento,a_periodo1,_cant_ase,_dependientes, v_desc_contratante, v_vigencia_inic, _edadcal_tot/_cant_ase,_estatus_char WITH RESUME;
		  RETURN    v_documento,	
					v_contratante, 	
					v_desc_contratante, 
                    _desc_ramo,
	                v_vigencia_inic,
                    v_vigencia_final,	
                    _cia_aseguradora,					
                    _coaseguro_asumido,	
                    n_riesgo  WITH RESUME;		
    END FOREACH
--    DROP TABLE temp_perfil;
END
END PROCEDURE;
