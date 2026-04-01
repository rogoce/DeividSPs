-- Modificado 07/09/2001 - Autor: Marquelda Valdelamar(inclusion de filtro d poliza)
---24102022 desglosar por unidad  HGIRON

DROP procedure sp_pro63a_si;

CREATE procedure "informix".sp_pro63a_si(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo DATE, a_cod_ramo CHAR(255) DEFAULT "*", a_codcliente CHAR(255) DEFAULT "*" ,a_subramo CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(50), 	 --cia
		  CHAR(03),		 --cod_ramo
		  CHAR(50),		 --descr. ramo
		  CHAR(50),		 --descr. cliente
          CHAR(20),		 --poliza
          DATE,			 --vig ini
          DATE,			 --vig fin
          DECIMAL(16,2), --prima suscrita
          DATE,			 --fecha
          DECIMAL(16,2), --suma asegurada
          CHAR(255),	 --v_filtros
          DECIMAL(16,2), --suma asegurada
          DECIMAL(16,2), --prima
		  CHAR(5),
		  CHAR(50),
		  CHAR(50),char(5),char(30),
		  DECIMAL(16,2), --_total_pri_sus,
DECIMAL(16,2), --_suma_asegurada,
CHAR(1), --_tipo_persona,
SMALLINT, --_tiene_acreedor,
DECIMAL(16,2), --_prima_devuelta,
DECIMAL(16,2), --_prima_cedida,
SMALLINT, --_fronting,
CHAR(10), --_no_poliza
dec(9,6),dec(9,6);

----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS VIGENTES  ---
---  Amado Perez mayo 2001 - APM          	 ---
---  Ref. Power Builder - dw_pro63				 ---
----------------------------------------------------
 BEGIN

DEFINE v_nopoliza,v_contratante ,_cod_contratante        		CHAR(10);
DEFINE v_documento                       		CHAR(20);
DEFINE v_codsucursal                     		CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final  		DATE;
DEFINE v_prima_suscrita,v_suma_asegurada,_total_pri_sus,_suma_asegurada, _prima_devuelta, _prima_cedida 		DECIMAL(16,2);
DEFINE v_desc_cliente                    		CHAR(45);
DEFINE v_descr_cia, v_desc_ramo,v_desc_contrato CHAR(50);
DEFINE v_desc_subramo                           CHAR(50);
DEFINE v_filtros                         		CHAR(100);
DEFINE _tipo                             		CHAR(1);
DEFINE _cod_ramo, _cod_subramo			 		CHAR(3);
define _tipo_persona        CHAR(1);
DEFINE _cod_contrato					 		CHAR(5);
DEFINE _tipo_contrato, _fronting					 		SMALLINT;
DEFINE _suma							 		DEC(16,2);
DEFINE _prima							 		DEC(16,2);
DEFINE _no_poliza                        		CHAR(10);
DEFINE _cod_cober_reas                          CHAR(3);
DEFINE _es_terremoto, _orden                    SMALLINT;
define _no_unidad			char(5);
define _porc_partic_prima 	dec(9,6);
define _porc_partic_suma 	dec(9,6);
DEFINE _fecha_emision, _fecha_cancelacion, _fecha_added DATE;
define _cod_grupo			char(5);
define _n_grupo			    char(30);
DEFINE _no_documento             CHAR(20);
	define _tiene_acreedor      SMALLINT;	
	define a_periodo1, a_periodo2 CHAR(7);
	
SET ISOLATION TO DIRTY READ; 
drop table if exists temp_perfil;

drop table if exists tmp_contratos;

--set debug file to "sp_pro63.trc";
--trace on;

LET v_descr_cia = sp_sis01(a_cia);
 let _no_unidad = null;
 let _n_grupo = null;
 let a_periodo2 = '2022-12';
 let a_periodo1 = '2022-07';
 
CREATE TEMP TABLE tmp_contratos
            (no_poliza         CHAR(10),
			 cod_contrato      CHAR(5),
			 nombre            CHAR(50),
			 tipo_contrato     SMALLINT,
			 orden             SMALLINT,
             suma              DEC(16,2),
             prima             DEC(16,2),
             no_unidad         CHAR(5),
             prima_suscrita    DEC(16,2),
             suma_asegurada    DEC(16,2),
             no_documento      CHAR(20),
			 porc_partic_prima DEC(16,2),
			 porc_partic_suma  DEC(16,2)	
             );

CREATE INDEX i_no_poliza1 ON tmp_contratos(cod_contrato);
CREATE INDEX i_no_poliza2 ON tmp_contratos(no_poliza);
CREATE INDEX i_no_poliza3 ON tmp_contratos(no_unidad);

DROP TABLE  if exists tmp_poliza;



    CREATE TEMP TABLE tmp_poliza(
			  no_documento       CHAR(20),
              cod_ramo           CHAR(3),                            
			  cod_subramo        CHAR(3),                            
			  prima_suscrita     DECIMAL(16,2),
			  sa_poliza          DECIMAL(16,2),
			  tipo_persona       CHAR(1),
			  cod_contratante    CHAR(10),
			  tiene_acreedor     SMALLINT,
			  prima_devuelta 	 DECIMAL(16,2),
			  prima_cedida 	     DECIMAL(16,2),
			  fronting           smallint,
			  no_poliza          CHAR(10),
              PRIMARY KEY(no_documento,cod_ramo)) WITH NO LOG;
	CREATE INDEX iii_tmp_poliza1 ON tmp_poliza(cod_ramo);
	CREATE INDEX iii_tmp_poliza2 ON tmp_poliza(no_documento);

{SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 2;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;}

LET v_filtros =  'Ramo 001,003,006,010,011,012,013,014,021,022;';
LET _porc_partic_prima =  0.00;
LET _porc_partic_suma =  0.00;

--LET v_filtros = sp_pro03j(a_cia,a_agencia,a_periodo,a_cod_ramo);
CALL sp_pro95a(a_cia,a_agencia,a_periodo,'006;','4;Ex','%') RETURNING v_filtros;

--trace off;
   --IF a_no_documento = "0617-00025-03"  then
   --   set debug file to "sp_pro63a.trc";
    --  trace on; 
  -- end if
-- Filtro de Sucursal

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

-- Filtro de Asegurado

IF a_codcliente <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Asegurado: "||TRIM(a_codcliente);
 LET _tipo = sp_sis04(a_codcliente); -- Separa los valores del String

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

-- Filtro de Subramo

IF a_subramo <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Subramo: "||TRIM(a_subramo);
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

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
	  --



FOREACH
 SELECT  no_poliza,
         no_documento,
         cod_contratante,
         vigencia_inic,
         vigencia_final,
		 prima_suscrita,
		 cod_ramo,
		 cod_subramo,
		 prima_suscrita,
		 cod_contratante,
		 suma_asegurada
    INTO v_nopoliza,
         v_documento,
         v_contratante,
         v_vigencia_inic,
         v_vigencia_final,
		 v_prima_suscrita,
		 _cod_ramo,
		 _cod_subramo,
		 _total_pri_sus,
		 _cod_contratante,
		 _suma_asegurada
    FROM temp_perfil
   WHERE seleccionado = 1
ORDER BY vigencia_final

    select fecha_cancelacion, cod_grupo
	  into _fecha_cancelacion, _cod_grupo
	  from emipomae
	 where no_poliza  = v_nopoliza
	   and actualizado = 1;

   SELECT b.nombre
     INTO v_desc_cliente
     FROM cliclien b
    WHERE b.cod_cliente = v_contratante;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;

   SELECT c.nombre
     INTO v_desc_subramo
     FROM prdsubra c
    WHERE c.cod_ramo = _cod_ramo
      AND c.cod_subramo = _cod_subramo;
	  
   select nombre
	 into _n_grupo
	 from cligrupo
	where cod_grupo = _cod_grupo;


	
	let _no_documento = v_documento;
	let _no_poliza = v_nopoliza;
	
	foreach
	select max(fecha_emision)
	  into _fecha_emision
	  from endedmae
	 where no_poliza = v_nopoliza
	   and cod_endomov = '002'
	   and actualizado = 1
		  and vigencia_inic = _fecha_cancelacion
	end foreach		
			 
	IF _suma_asegurada IS NULL THEN
		LET _suma_asegurada = 0;
	END IF 			 	
	  
  	SELECT tipo_persona
	  INTO _tipo_persona
	  FROM cliclien 
	 WHERE cod_cliente = _cod_contratante;

	SELECT fronting
	  INTO _fronting
	  FROM emipomae 
	 WHERE no_poliza = _no_poliza;
	 
	if _fronting is null then
		let _fronting = 0;
	end if	
  
	IF _total_pri_sus IS NULL THEN
		LET _total_pri_sus = 0;
	END IF  	  	     	  

	select count(cod_acreedor)
	  into _tiene_acreedor
	  from emipoacr
	 where no_poliza = _no_poliza;
	 
	  IF _tiene_acreedor IS NULL THEN
		LET _tiene_acreedor = 0;
	  END IF 
	
	select sum(d.monto)
	  into _prima_devuelta
	  from chqchpol d, chqchmae c
	 where d.no_documento = _no_documento
       and d.no_requis = c.no_requis
	   and c.origen_cheque = '6'
	   and c.pagado     = 1
	   and c.autorizado = 1
	   and c.anulado    = 0		   
	   and c.periodo     >= a_periodo1
	   and c.periodo     <= a_periodo2;			   
	   
	IF _prima_devuelta IS NULL THEN
	  LET _prima_devuelta = 0;
	END IF  		   	  
	  
	if _cod_ramo = '006' then 	  
	 SELECT	sum( c.prima)
	   INTO	_prima_cedida
	   FROM emifacon c, endedmae e, reacomae x
	  WHERE	c.no_poliza  = _no_poliza
		AND c.cod_contrato = x.cod_contrato
		AND c.no_poliza   = e.no_poliza
		AND c.no_endoso   = e.no_endoso
		and x.tipo_contrato <> '1'
		AND e.actualizado = 1
		AND (c.prima <> 0 OR c.suma_asegurada <> 0)
		AND e.periodo     >= a_periodo1
		AND e.periodo     <= a_periodo2;
	end if
		
	IF _prima_cedida IS NULL THEN
		LET _prima_cedida = 0;
	END IF  		
  
	   BEGIN
		  ON EXCEPTION IN(-239)
			 UPDATE tmp_poliza
				SET prima_suscrita = prima_suscrita + _total_pri_sus				    
			   WHERE cod_ramo      = _cod_ramo
				 and no_documento  = _no_documento ;
				 

		  END EXCEPTION
		  INSERT INTO tmp_poliza
			  VALUES(_no_documento,
					 _cod_ramo,
					 _cod_subramo,
					 _total_pri_sus,
					 _suma_asegurada,
					 _tipo_persona,
					 _cod_contratante,
					 _tiene_acreedor,
					 _prima_devuelta,
					 _prima_cedida,
					 _fronting,
					 _no_poliza
					 );
	   END	     	
	   
	LET v_suma_asegurada = 0;
	LET v_prima_suscrita = 0;
	LET _porc_partic_prima =  0.00;
	LET _porc_partic_suma =  0.00;		   
	

	FOREACH
	 SELECT	c.cod_contrato,
			c.suma_asegurada, -- * (c.porc_partic_suma/100),
			c.prima, -- * (c.porc_partic_prima/100),
			c.cod_cober_reas,
			c.orden,
			c.no_unidad,
			c.porc_partic_prima,
			c.porc_partic_suma,
			e.fecha_emision
	   INTO	_cod_contrato,
			_suma,
			_prima,
			_cod_cober_reas,
			_orden,
			_no_unidad,
			_porc_partic_prima,
			_porc_partic_suma,
			_fecha_added
	   FROM emifacon c, endedmae e , reacomae x
	  WHERE	c.no_poliza   = v_nopoliza
	    AND c.no_poliza   = e.no_poliza
		AND c.no_endoso   = e.no_endoso
		and x.tipo_contrato <> '1'
		AND c.cod_contrato = x.cod_contrato
		AND e.actualizado = 1
		AND (c.prima <> 0 OR c.suma_asegurada <> 0)	
		--and e.fecha_emision < _fecha_emision
		--and e.fecha_emision <= a_periodo
		AND e.periodo     >= a_periodo1
		AND e.periodo     <= a_periodo2
	  order by c.cod_contrato,c.no_unidad
	  
		LET _fecha_emision = null;

		SELECT tipo_contrato,
		       nombre
		  INTO _tipo_contrato,
		       v_desc_contrato
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

        SELECT es_terremoto
		  INTO _es_terremoto
		  FROM reacobre
		 WHERE cod_cober_reas = _cod_cober_reas;

		IF _es_terremoto <> 1 THEN
	  	    LET v_suma_asegurada = v_suma_asegurada + _suma;
		ELSE
		    LET _suma = 0;
		END IF

	    LET v_prima_suscrita = v_prima_suscrita + _prima;
		
	
		 BEGIN
					  ON EXCEPTION IN(-239)
						 UPDATE tmp_contratos
							SET prima_suscrita = prima_suscrita + _prima ,
							suma_asegurada = suma_asegurada + _suma
						  WHERE cod_contrato = _cod_contrato
						    and no_poliza  = v_nopoliza
							AND no_unidad = _no_unidad;

			END EXCEPTION
					  
				INSERT INTO tmp_contratos
				VALUES (v_nopoliza, _cod_contrato, v_desc_contrato, _tipo_contrato, _orden, _suma, _prima,_no_unidad,_prima,_suma,_no_documento,_porc_partic_prima,_porc_partic_suma);
	       END
		   
	END FOREACH
	
	FOREACH
	 SELECT no_unidad,
	        nombre,
			porc_partic_prima,
			porc_partic_suma,			
			sum(prima_suscrita),
			sum(suma_asegurada),
	        SUM(suma),
	        SUM(prima)
	   INTO _no_unidad,
	        v_desc_contrato,
			_porc_partic_prima,
			_porc_partic_suma,			
			v_prima_suscrita,
			v_suma_asegurada,
	        _suma,
	        _prima
	   FROM tmp_contratos
	  WHERE no_poliza = v_nopoliza and tipo_contrato <> '1'
	  GROUP BY no_unidad,nombre,porc_partic_prima,porc_partic_suma 
	  ORDER BY no_unidad,nombre,porc_partic_prima,porc_partic_suma 


	 SELECT prima_suscrita,
			sa_poliza,
			tipo_persona,
			tiene_acreedor,
			prima_devuelta,
			prima_cedida,
			fronting,
			no_poliza
	   INTO _total_pri_sus,
			_suma_asegurada,
			_tipo_persona,
			_tiene_acreedor,
			_prima_devuelta,
			_prima_cedida,
			_fronting,
			_no_poliza
		 FROM tmp_poliza
		WHERE no_poliza = v_nopoliza; 	  

       RETURN v_descr_cia,
       		  _cod_ramo,
              v_desc_ramo,
              v_desc_cliente,
              v_documento,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
              a_periodo,
			  v_suma_asegurada,
              v_filtros,
              _suma,
              _prima,
			  _cod_contrato,
			  v_desc_contrato,
			  v_desc_subramo,
			  _no_unidad,
			  _n_grupo,
              _total_pri_sus,
			_suma_asegurada,
			_tipo_persona,
			_tiene_acreedor,
			_prima_devuelta,
			_prima, --_prima_cedida,
			_fronting,
			_no_poliza,
			_porc_partic_prima,
			_porc_partic_suma 
              WITH RESUME;
			  
			  
			  
	END FOREACH
END FOREACH



END

END PROCEDURE;
