-- Procedimiento que Carga los Totales de Produccion
-- en un Periodo Dado
-- 
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 21/09/2000 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pr26j;

CREATE PROCEDURE "informix".sp_pr26j(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7)
		) RETURNING CHAR(50) as subramo, 
		            CHAR(50) as ramo, 
					SMALLINT as orden, 
					INTEGER as canceladas, 
					DEC(16,2) as prima_canc, 
					INTEGER as anuladas, 
					DEC(16,2) as prima_anul, 
					SMALLINT as sub_orden,
					INTEGER as negativas,
					DEC(16,2) as prima_neg;

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _no_poliza 		 CHAR(10); 
DEFINE _no_endoso 		 CHAR(5);
DEFINE _periodo      	 CHAR(7);
DEFINE _cod_ramo, _cod_subramo    	 CHAR(3); 
DEFINE _cod_grupo  		 CHAR(5); 
DEFINE _user_added  	 CHAR(8);
DEFINE _cod_sucursal     CHAR(3); 
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE _porc_partic_agt  DECIMAL(5,2); 
DEFINE _cod_agente       CHAR(5);

DEFINE _total_prima_sus	 DECIMAL(16,2);
DEFINE _total_prima_nva  DECIMAL(16,2);
DEFINE _total_prima_ren  DECIMAL(16,2);
DEFINE _total_prima_end  DECIMAL(16,2);
DEFINE _total_prima_can  DECIMAL(16,2);
DEFINE _total_prima_rev  DECIMAL(16,2);
DEFINE t_total_prima_sus DECIMAL(16,2);
DEFINE t_total_prima_nva DECIMAL(16,2);
DEFINE t_total_prima_ren DECIMAL(16,2);
DEFINE t_total_prima_end DECIMAL(16,2);
DEFINE t_total_prima_can DECIMAL(16,2);
DEFINE t_total_prima_rev DECIMAL(16,2);
DEFINE t_cnt_prima_sus 	 DECIMAL(16,2);
DEFINE t_cnt_prima_nva 	 DECIMAL(16,2);
DEFINE t_cnt_prima_ren 	 DECIMAL(16,2);
DEFINE t_cnt_prima_end 	 DECIMAL(16,2);
DEFINE t_cnt_prima_can 	 DECIMAL(16,2);
DEFINE t_cnt_prima_rev 	 DECIMAL(16,2);

DEFINE _cnt_prima_sus    INTEGER;
DEFINE _cnt_prima_nva    INTEGER;
DEFINE _cnt_prima_ren    INTEGER;
DEFINE _cnt_prima_end    INTEGER;
DEFINE _cnt_prima_can    INTEGER;
DEFINE _cnt_prima_rev    INTEGER;
DEFINE _cod_endomov      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _tipo_mov		 SMALLINT;
DEFINE v_descripcion   	 CHAR(22);
DEFINE v_desc_ramo,v_desc_grupo,v_desc_suc,v_nombre_prod,v_desc_agt 	 CHAR(50);
DEFINE v_saber		   	 CHAR(2);
DEFINE v_codigo,_cod_producto  	 CHAR(5);

DEFINE _vigencia_inic_pol       DATE;
DEFINE _vigencia_final_end      DATE;
DEFINE _dias_vigencia, _cadena  INTEGER;

DEFINE _cod_tipocan				CHAR(3);
DEFINE _reemplaza_poliza		CHAR(20);

DEFINE _suc_prom                CHAR(3); 
DEFINE _nom_sucursal            VARCHAR(50);
DEFINE _cod_vendedor            CHAR(3);
DEFINE _nombre_vendedor         VARCHAR(50);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2	 		 DATE;
DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;
define _canceladas       SMALLINT;

DEFINE _cnt_prima_reh    DECIMAL(16,2);
DEFINE _suma_asegurada   DEC(16,2);
DEFINE _total_suma_nva   DEC(16,2);
DEFINE _total_suma_ren   DEC(16,2);
DEFINE _total_suma_end   DEC(16,2);
DEFINE _total_suma_can   DEC(16,2);
DEFINE _total_suma_rev   DEC(16,2);
DEFINE _total_suma       DEC(16,2);
DEFINE _cantidad         INTEGER;

DEFINE v_desc_subramo    CHAR(50);
DEFINE _orden_sub, _orden smallint;
DEFINE _cnt_total INTEGER;
DEFINE _proporcion INTEGER;
DEFINE _cnt_prima_can_h INTEGER;

DEFINE _cnt_prima_neg    INTEGER;
DEFINE _total_prima_neg  DECIMAL(16,2);
DEFINE _no_unidad        char(5);
define _uso_auto         char(1);

-- Tabla Temporal tmp_prod

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod(
		no_poliza            CHAR(10) NOT NULL,
	 	user_added			 CHAR(8)  NOT NULL,	
		cod_ramo             CHAR(3)  NOT NULL,
		cod_subramo          CHAR(3)  NOT NULL,
		cod_grupo			 CHAR(5)  NOT NULL,
		cod_sucursal         CHAR(3)  NOT NULL,
		cod_agente           CHAR(5)  NOT NULL,
		tipo_produccion      CHAR(1),
		total_pri_sus        DECIMAL(16,2),
		total_pri_nva        DECIMAL(16,2),
		total_pri_ren        DECIMAL(16,2),
		total_pri_end        DECIMAL(16,2),
		total_pri_can        DECIMAL(16,2),
		total_pri_rev        DECIMAL(16,2),
		total_pri_neg        DECIMAL(16,2),
		cnt_prima_sus    	 INTEGER,
 		cnt_prima_nva   	 INTEGER,
		cnt_prima_ren   	 INTEGER,
		cnt_prima_end   	 INTEGER,
		cnt_prima_can   	 INTEGER,
		cnt_prima_rev   	 INTEGER,
		cnt_prima_reh        INTEGER,
		cnt_prima_neg        INTEGER,
		seleccionado         SMALLINT DEFAULT 1 NOT NULL,
		cod_producto		 CHAR(5)  NOT NULL,
		cod_vendedor	     CHAR(3),                    -- cod_vendedor
		nombre_vendedor      CHAR(50),                    -- nombre vendedor
		no_endoso            CHAR(5)  NOT NULL,
		total_suma_nva       DECIMAL(16,2),
		total_suma_ren       DECIMAL(16,2),
		total_suma_end       DECIMAL(16,2),
		total_suma_can       DECIMAL(16,2),
		total_suma_rev       DECIMAL(16,2),
		total_suma           DECIMAL(16,2),
		no_unidad            CHAR(5)
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);
CREATE INDEX iend7_tmp_prod ON tmp_prod(cod_vendedor);

--LET _cod_agente = a_agente;
-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _mes1 = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

SET ISOLATION TO DIRTY READ;

UPDATE ramosub_ca
   SET cnt_pol_can_cad = 0, prima_can = 0, cnt_pol_anulada = 0, prima_anulada = 0, cnt_end_neg = 0, prima_negativa = 0;

FOREACH 
 SELECT e.no_poliza,	
 		e.no_endoso, 	
 		f.prima_suscrita,	 
 		e.cod_endomov,		
 		e.user_added,
		e.vigencia_final,
		e.cod_tipocan,
		f.suma_asegurada,
		f.no_unidad
   INTO _no_poliza, 	
   		_no_endoso, 	
   		_total_prima_sus,	 
   		_cod_endomov, 		
   		_user_added,
		_vigencia_final_end,
		_cod_tipocan,
		_suma_asegurada,
		_no_unidad
   FROM endedmae e, endeduni f
  WHERE e.no_poliza = f.no_poliza
    AND e.no_endoso = f.no_endoso
    AND e.periodo BETWEEN a_periodo1 AND a_periodo2
    AND e.actualizado = 1
	AND e.cod_endomov = '002'
	--AND e.cod_tipocan <> '009'
	--AND e.user_added <> 'GERENCIA'

   FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
   END FOREACH

	LET _total_prima_nva = 0;
	LET _total_prima_ren = 0;
	LET _total_prima_end = 0;
	LET _total_prima_can = 0;
	LET _total_prima_rev = 0;
	LET _total_prima_neg = 0;

    LET _total_suma_nva = 0;
    LET _total_suma_ren = 0;
    LET _total_suma_end = 0;
    LET _total_suma_can = 0;
    LET _total_suma_rev = 0;

	LET _cnt_prima_sus = 1;
	LET _cnt_prima_nva = 0;
	LET _cnt_prima_ren = 0;
	LET _cnt_prima_end = 0;
	LET _cnt_prima_can = 0;
	LET _cnt_prima_rev = 0;
	LET _cnt_prima_neg = 0;
	
    LET v_descripcion  = " "; 
	LET _canceladas = 0;
	
	LET _cnt_prima_reh = 0;
	

	-- Lectura de la Tabla de tipo_mov

	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

	-- Informacion de Poliza

    SELECT sucursal_origen,
    	   cod_tipoprod, 
    	   cod_ramo,	
    	   cod_grupo, 
    	   nueva_renov,
		   vigencia_inic,
		   reemplaza_poliza,
		   cod_subramo
      INTO _cod_sucursal,
      	   _cod_tipoprod, 
      	   _cod_ramo, 
      	   _cod_grupo, 
      	   _nueva_renov,
		   _vigencia_inic_pol,
		   _reemplaza_poliza,
		   _cod_subramo
      FROM emipomae
     WHERE no_poliza = _no_poliza;
  
    SELECT tipo_produccion	
      INTO _tipo_produccion
      FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;
         
	-- Calculos
 --   IF _user_added <> 'GERENCIA' THEN
		IF _tipo_mov = 2 THEN
		
			LET _total_prima_rev = 0;
			LET _cnt_prima_rev   = 0;
			LET _total_prima_can = 0;
			LET _cnt_prima_can   = 0;
			LET _total_suma_can  = 0;
			LET _cnt_prima_neg = 0;
			LET _total_prima_neg = 0;

			if _cod_tipocan = "037" then
				LET _total_prima_rev = _total_prima_sus;		
				LET _cnt_prima_rev   = 1;	
            elif _cod_tipocan = "009" then	
 				LET _total_prima_can = _total_prima_sus;		
				LET _cnt_prima_can   = 1;		
				LET _total_suma_can = 0;		               			
			else
				LET _total_prima_can = _total_prima_sus;		
				LET _cnt_prima_can   = 1;		
				LET _total_suma_can = _suma_asegurada;		
			end if
			{
			select count(*)
			  into _canceladas
			  from tmp_prod
			 where no_poliza = _no_poliza
			   and no_endoso <> _no_endoso;
			   
			if _canceladas > 0 then
				if _cod_tipocan = "037" then
					LET _cnt_prima_rev   = 0;
				else
					LET _cnt_prima_can   = 0;
				end if
			end if
            }

		ELSE		

			LET _total_prima_end = _total_prima_sus;		
			LET _cnt_prima_end   = 1;
			LET _total_suma_end = _suma_asegurada;		

		END IF
--	ELSE
--		LET _total_prima_end = _total_prima_sus;		
--		LET _cnt_prima_end   = 1;
--		LET _total_suma_end = _suma_asegurada;		
--	END IF

	-- Endosos negativos
    IF _total_prima_sus < 0 THEN
		LET _total_prima_neg = _total_prima_sus;
		LET _cnt_prima_neg = 1;
	END IF

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		exit foreach;
	end foreach

	select sucursal_promotoria,trim(descripcion)
	  into _suc_prom,_nom_sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';

   select cod_vendedor
     into _cod_vendedor
     from parpromo
    where cod_agente  = _cod_agente
      and cod_agencia = _suc_prom
      and cod_ramo	  = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;


	  -- Insercion a la tabla temporal tmp_prod
		INSERT INTO tmp_prod(
		no_poliza,
		user_added,
	  	cod_ramo, 
		cod_subramo,
	  	cod_grupo,
	  	cod_sucursal,
	  	tipo_produccion,
		cod_agente,
		total_pri_sus,
		total_pri_nva,
		total_pri_ren,
		total_pri_end,
		total_pri_can,
		total_pri_rev,
		total_pri_neg,
		cnt_prima_sus,
		cnt_prima_nva,
		cnt_prima_ren,
		cnt_prima_end,
		cnt_prima_can,
		cnt_prima_rev,
		cnt_prima_neg,
		cod_producto,
		cod_vendedor,	
		nombre_vendedor,
        no_endoso,		
		total_suma_nva,
		total_suma_ren,
		total_suma_end,
		total_suma_can,
		total_suma_rev,
		total_suma,
		no_unidad
		)
		VALUES(
		_no_poliza,
		_user_added,
		_cod_ramo,
		_cod_subramo,
		_cod_grupo,
	 	_cod_sucursal,
		_tipo_produccion,
		_cod_agente,
		_total_prima_sus,
		_total_prima_nva,
		_total_prima_ren,
		_total_prima_end,
		_total_prima_can,
		_total_prima_rev,
		0,
		_cnt_prima_sus,
		_cnt_prima_nva,	
		_cnt_prima_ren,	   
		_cnt_prima_end,	       
		_cnt_prima_can,
		_cnt_prima_rev,
		0,
		_cod_producto,
		_cod_vendedor,	
		_nombre_vendedor,
        _no_endoso,		
		_total_suma_nva,
		_total_suma_ren,
		_total_suma_end,
		_total_suma_can,
		_total_suma_rev,
		_suma_asegurada,
		_no_unidad
		);

END FOREACH

FOREACH 
 SELECT e.no_poliza,	
 		e.no_endoso, 	
 		f.prima_suscrita,	 
 		e.cod_endomov,		
 		e.user_added,
		e.vigencia_final,
		e.cod_tipocan,
		f.suma_asegurada,
		f.no_unidad
   INTO _no_poliza, 	
   		_no_endoso, 	
   		_total_prima_sus,	 
   		_cod_endomov, 		
   		_user_added,
		_vigencia_final_end,
		_cod_tipocan,
		_suma_asegurada,
		_no_unidad
   FROM endedmae e, endeduni f
  WHERE e.no_poliza = f.no_poliza
    AND e.no_endoso = f.no_endoso
    AND e.periodo BETWEEN a_periodo1 AND a_periodo2
    AND e.actualizado = 1
	--AND e.prima_suscrita < 0

   FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
   END FOREACH
   

	LET _total_prima_nva = 0;
	LET _total_prima_ren = 0;
	LET _total_prima_end = 0;
	LET _total_prima_can = 0;
	LET _total_prima_rev = 0;
	LET _total_prima_neg = 0;

    LET _total_suma_nva = 0;
    LET _total_suma_ren = 0;
    LET _total_suma_end = 0;
    LET _total_suma_can = 0;
    LET _total_suma_rev = 0;

	LET _cnt_prima_sus = 1;
	LET _cnt_prima_nva = 0;
	LET _cnt_prima_ren = 0;
	LET _cnt_prima_end = 0;
	LET _cnt_prima_can = 0;
	LET _cnt_prima_rev = 0;
	LET _cnt_prima_neg = 0;
	
    LET v_descripcion  = " "; 
	LET _canceladas = 0;
	
	LET _cnt_prima_reh = 0;
	

	-- Lectura de la Tabla de tipo_mov

	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

    IF _cod_endomov = '032' THEN
		LET _tipo_mov = 32;
	END IF

	-- Informacion de Poliza

    SELECT sucursal_origen,
    	   cod_tipoprod, 
    	   cod_ramo,	
    	   cod_grupo, 
    	   nueva_renov,
		   vigencia_inic,
		   reemplaza_poliza,
		   cod_subramo
      INTO _cod_sucursal,
      	   _cod_tipoprod, 
      	   _cod_ramo, 
      	   _cod_grupo, 
      	   _nueva_renov,
		   _vigencia_inic_pol,
		   _reemplaza_poliza,
		   _cod_subramo
      FROM emipomae
     WHERE no_poliza = _no_poliza;
  
    SELECT tipo_produccion	
      INTO _tipo_produccion
      FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;
         
	-- Calculos
 	IF _tipo_mov = 2 THEN

		if _cod_tipocan = "009" then
			LET _total_prima_rev = _total_prima_sus;		
			LET _cnt_prima_rev   = 1;		
			
		--	LET _total_prima_neg = _total_prima_sus;
		--	LET _cnt_prima_neg = 1;
		else
			LET _total_prima_can = _total_prima_sus;		
			LET _cnt_prima_can   = 1;		
		end if

	ELIF _tipo_mov = 8 THEN

		LET _total_prima_rev = _total_prima_sus;		
		LET _cnt_prima_rev   = 1;		

		LET _total_prima_neg = _total_prima_sus;
		LET _cnt_prima_neg = 1;
		
	ELIF _tipo_mov = 32 THEN
		LET _total_prima_neg = _total_prima_sus;
		LET _cnt_prima_neg = 1;
	
	ELIF _tipo_mov = 11 THEN

	  IF _nueva_renov = "N" THEN

			LET _total_prima_nva = _total_prima_sus;		
			LET _cnt_prima_nva   = 1;		


	  ELSE

		LET _total_prima_ren = _total_prima_sus;		
		LET _cnt_prima_ren   = 1;		

	  END IF

	ELIF _tipo_mov = 14 THEN -- Facturacion Mensual de Salud

		LET _total_prima_ren = 0.00;		
		LET _total_prima_nva = 0.00;		
		LET _cnt_prima_ren   = 0;		
		LET _dias_vigencia   = _vigencia_final_end -_vigencia_inic_pol;

		IF _dias_vigencia > 366 THEN
			LET _total_prima_ren = _total_prima_sus;		
			LET _cnt_prima_ren   = 1;		
		else
			LET _total_prima_end = _total_prima_sus;		
			--LET _cnt_prima_nva   = 1;		
			LET _cnt_prima_end = 1;
			
			--LET _total_prima_neg = _total_prima_sus;
			--LET _cnt_prima_neg = 1;
		END IF

--		LET _total_prima_ren = _total_prima_sus;		
--		LET _cnt_prima_ren   = 1;		

	ELSE		

		LET _total_prima_end = _total_prima_sus;		
		LET _cnt_prima_end   = 1;		

	--	LET _total_prima_neg = _total_prima_sus;
	--	LET _cnt_prima_neg = 1;
	END IF


	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		exit foreach;
	end foreach

	select sucursal_promotoria,trim(descripcion)
	  into _suc_prom,_nom_sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';

   select cod_vendedor
     into _cod_vendedor
     from parpromo
    where cod_agente  = _cod_agente
      and cod_agencia = _suc_prom
      and cod_ramo	  = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;


	  -- Insercion a la tabla temporal tmp_prod
		INSERT INTO tmp_prod(
		no_poliza,
		user_added,
	  	cod_ramo, 
		cod_subramo,
	  	cod_grupo,
	  	cod_sucursal,
	  	tipo_produccion,
		cod_agente,
		total_pri_sus,
		total_pri_nva,
		total_pri_ren,
		total_pri_end,
		total_pri_can,
		total_pri_rev,
		total_pri_neg,
		cnt_prima_sus,
		cnt_prima_nva,
		cnt_prima_ren,
		cnt_prima_end,
		cnt_prima_can,
		cnt_prima_rev,
		cnt_prima_neg,
		cod_producto,
		cod_vendedor,	
		nombre_vendedor,
        no_endoso,		
		total_suma_nva,
		total_suma_ren,
		total_suma_end,
		total_suma_can,
		total_suma_rev,
		total_suma,
		no_unidad
		)
		VALUES(
		_no_poliza,
		_user_added,
		_cod_ramo,
		_cod_subramo,
		_cod_grupo,
	 	_cod_sucursal,
		_tipo_produccion,
		_cod_agente,
		0,
		0,
		0,
		0,
		0,
		0,
		_total_prima_neg,
		0,
		0,	
		0,	   
		0,	       
		0,
		0,
		_cnt_prima_neg,
		_cod_producto,
		_cod_vendedor,	
		_nombre_vendedor,
        _no_endoso,		
		0,
		0,
		0,
		0,
		0,
		0,
		_no_unidad
		);

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";
LET _cadena = 0;

{foreach with hold
	SELECT cod_ramo,
		   cod_subramo,
		   sum(cnt_prima_can),
		   sum(total_pri_can),
		   sum(cnt_prima_rev),
		   sum(total_pri_rev)
	  INTO _cod_ramo,
		   _cod_subramo,
		   _cnt_prima_can,
		   _total_prima_can,
		   _cnt_prima_rev,
		   _total_prima_rev
	  FROM tmp_prod
	-- order by cod_ramo, cod_subramo 
	 group by cod_ramo, cod_subramo
	-- 

	 RETURN _cod_ramo,
			_cod_subramo,
			_cnt_prima_can,
			_total_prima_can,
			_cnt_prima_rev,
			_total_prima_rev with resume;
END FOREACH
}

foreach with hold
	SELECT cod_ramo,
		   cod_subramo,
		   cnt_prima_can,
		   total_pri_can,
		   cnt_prima_rev,
		   total_pri_rev, 
		   cnt_prima_neg,
		   total_pri_neg,
		   no_poliza, 
		   no_endoso,
		   no_unidad
	  INTO _cod_ramo,
		   _cod_subramo,
		   _cnt_prima_can,
		   _total_prima_can,
		   _cnt_prima_rev,
		   _total_prima_rev, 
		   _cnt_prima_neg,
		   _total_prima_neg,
		   _no_poliza, 
		   _no_endoso,
		   _no_unidad
	  FROM tmp_prod

  IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
	LET _cod_ramo = '002';
  END IF

  IF _cod_ramo = '021' THEN
	LET _cod_ramo = '001';
  END IF

	-- Informacion de Poliza
   SELECT nueva_renov
     INTO _nueva_renov
     FROM emipomae
    WHERE no_poliza = _no_poliza;

   IF _cod_ramo = "019" and _nueva_renov = "N" THEN --AND _vig_fin_vida > _vig_ini_end --Amado 02/06/2017
     UPDATE ramosub_ca
        SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
		    prima_can  = prima_can + _total_prima_can,
			cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
			prima_anulada = prima_anulada + _total_prima_rev,
			cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
			prima_negativa = prima_negativa + _total_prima_neg
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "001";
   END IF	

  IF _cod_ramo = "019" AND _nueva_renov = "R" THEN
      UPDATE ramosub_ca
        SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
		    prima_can  = prima_can + _total_prima_can,
			cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
			prima_anulada = prima_anulada + _total_prima_rev,
			cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
			prima_negativa = prima_negativa + _total_prima_neg
      WHERE cod_ramo     = _cod_ramo
        AND cod_subramo  = "002";
 END IF
 
    IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		IF _cantidad > 1 then
		  UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
		  WHERE cod_ramo     = _cod_ramo
			AND cod_subramo  = "002";
		ELSE
		  UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
		  WHERE cod_ramo     = _cod_ramo
			AND cod_subramo  = "001";
		END IF
	END IF

------------
	IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "001";
	END IF
	IF _cod_ramo = "010" THEN --equio electronico
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 		 WHERE cod_ramo        = '010'
		   AND cod_subramo     = "002";
	END IF
	IF _cod_ramo = "012" THEN	--calderas
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "003";
	END IF
	IF _cod_ramo = "011" THEN	--rotura de maquinaria
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "004";
	END IF
	IF _cod_ramo = "022" THEN	--equipo pesado
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "005";
	END IF
	IF _cod_ramo = "007" THEN	--vidrios
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 	     WHERE cod_ramo        = '010'
		   AND cod_subramo     = "006";
	END IF
	IF _cod_ramo = "008" THEN
      IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
		   UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
      ELIF _cod_subramo = "003" THEN
		   UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
      ELIF _cod_subramo = "012" THEN
		   UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
      ELIF _cod_subramo = "009" THEN
		   UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "005";
	  else
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	  end if
	END IF  
	if _cod_ramo = '009' and _cod_subramo in('001','002','006','009') then -- Se agregó el subramo 009 12-09-2022 ID de la solicitud	# 4243
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
	end if
	if _cod_ramo = '009' and _cod_subramo = '003' then	
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
 			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
	end if
	if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
	end if
--------		 

	if _cod_ramo = '003' and _cod_subramo = '001' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
	end if
	
	if _cod_ramo = '003' and _cod_subramo <> '001' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
	end if

	if _cod_ramo = '001' and _cod_subramo = '001' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
	end if

	if _cod_ramo = '001' and _cod_subramo = '002' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
	end if

	if _cod_ramo = '001' and _cod_subramo in ("003","004","006","007") then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";	
	end if

	if _cod_ramo = '017' and _cod_subramo = '001' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
	end if

	if _cod_ramo = '017' and _cod_subramo = '002' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
	end if

	if _cod_ramo = '005' and _cod_subramo = '001' then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
	end if
	
	if _cod_ramo = '016' then
		if _cod_subramo <> '007' then
			 UPDATE ramosub_ca
				SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
					prima_can  = prima_can + _total_prima_can,
					cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
					prima_anulada = prima_anulada + _total_prima_rev,
					cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
					prima_negativa = prima_negativa + _total_prima_neg
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "001";	
		else
			 UPDATE ramosub_ca
				SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
					prima_can  = prima_can + _total_prima_can,
					cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
					prima_anulada = prima_anulada + _total_prima_rev,
					cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
					prima_negativa = prima_negativa + _total_prima_neg
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "002";	
		end if	
	end if
	
	if _cod_ramo in ('006','015','026','027') then
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
	end if

	if _cod_ramo in ('002','020','023') then
 		SELECT uso_auto
		  INTO _uso_auto
		  FROM emiauto
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;         
		 
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN  -- Pólizas sin info en Emiauto 
			FOREACH
				  SELECT uso_auto
					INTO _uso_auto						
					FROM endmoaut 
				   WHERE no_poliza = _no_poliza
					 AND no_unidad = _no_unidad         
				exit FOREACH;
			end FOREACH			 
          END IF 
		  
		  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
		   LET _uso_auto = 'P';
		  END IF 
		  
		IF _uso_auto = 'P' THEN
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";	
		ELSE
		 UPDATE ramosub_ca
			SET cnt_pol_can_cad  = cnt_pol_can_cad + _cnt_prima_can, 
				prima_can  = prima_can + _total_prima_can,
				cnt_pol_anulada = cnt_pol_anulada + _cnt_prima_rev,
				prima_anulada = prima_anulada + _total_prima_rev,
				cnt_end_neg = cnt_end_neg + _cnt_prima_neg,
				prima_negativa = prima_negativa + _total_prima_neg
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";	
		END IF
	end if

END FOREACH


LET _cnt_total = 0;

FOREACH
	select cod_ramo,
	       cod_subramo,
		   orden,
		   cnt_pol_can_cad,
		   prima_can,
		   cnt_pol_anulada,
		   prima_anulada,
		   cnt_end_neg,
		   prima_negativa
	  into _cod_ramo,
           _cod_subramo,
		   _orden,
           _cnt_prima_can,
           _total_prima_can,
           _cnt_prima_rev,
           _total_prima_rev,
		   _cnt_prima_neg,
		   _total_prima_neg
      from ramosub_ca
	  ORDER BY orden,cod_ramo,cod_subramo
	  
	  select sum(cnt_pol_can_cad)
		into _cnt_prima_can_h
		from ramosubrh
	   where cod_ramo = _cod_ramo
		 and cod_subramo = _cod_subramo
		 and periodo = a_periodo1;
	  
	  let _cnt_total = _cnt_prima_can + _cnt_prima_rev;
	  
	  if _cnt_total = 0 and _cnt_prima_can_h > 0 then
		let _cnt_prima_can = _cnt_prima_can_h;
	  elif _cnt_total > 0 and _cnt_prima_can_h > 0 then
		let _proporcion = (_cnt_prima_can / _cnt_total) * 100; 
		let _cnt_prima_can = _cnt_prima_can_h * _proporcion / 100;
		let _cnt_prima_rev = _cnt_prima_can_h - _cnt_prima_can;
	  elif _cnt_total > 0 and _cnt_prima_can_h = 0 then
	    let _cnt_prima_can = 0;
		let _cnt_prima_rev = 0;
	  end if

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;

	LET _orden_sub = 1;
		  
    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  END IF
		  --LET v_desc_subramo = "";		  
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
		  IF  _cod_subramo = '002' THEN
		  	LET v_desc_subramo = "TERRESTRE";
		  END IF
 		  IF _cod_subramo = '002' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  ELIF _cod_subramo = '004' THEN
			LET _orden_sub = 2;
		  END IF
   ELIF _cod_ramo = "004" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "018" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "016" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "COLECTIVO DE VIDA";
		  ELSE
		  	LET v_desc_subramo = "COLECTIVO DE DEUDA";
		  END IF
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "PARTICULAR";
		  ELSE
		  	LET v_desc_subramo = "COMERCIAL";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo in ("006","026","027") THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  IF _cod_subramo = '001' THEN
			let v_desc_subramo = 'OFERTA';
			  LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			let v_desc_subramo = 'OTRAS';
			  LET _orden_sub = 5;
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CUMPLIMIENTO";
			  LET _orden_sub = 2;
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "CREDITO";
			  LET _orden_sub = 3;
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "FIDELIDAD";
			  LET _orden_sub = 4;
		  END IF
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
		  IF _cod_subramo = "001"	THEN
			  LET v_desc_subramo = "TRC / TRM";
			  LET _orden_sub = 1;
		  ELIF _cod_subramo = "002" THEN
			  LET v_desc_subramo = "EQUIPO ELECTRONICO";
			  LET _orden_sub = 2;
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CALDERA Y MAQUINARIA";
			  LET _orden_sub = 3;
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "ROTURA DE MAQUINARIA";
			  LET _orden_sub = 4;
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "EQUIPO PESADO";
			  LET _orden_sub = 5;
		  ELSE
			  LET v_desc_subramo = "VIDRIOS";
			  LET _orden_sub = 6;
		  END IF
    ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "012" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "013" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "014" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "022" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "015" THEN
		  LET v_desc_ramo = "OTROS";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "RIESGOS VARIOS";
		  END IF
    ELIF _cod_ramo IN ("003", "017", "019") THEN
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    END IF

       RETURN  v_desc_subramo, v_desc_ramo, _orden, _cnt_prima_can, _total_prima_can, _cnt_prima_rev, _total_prima_rev, _orden_sub, _cnt_prima_neg, _total_prima_neg WITH RESUME;
	  
END FOREACH

DROP TABLE tmp_prod;

--RETURN v_filtros;

END PROCEDURE;
