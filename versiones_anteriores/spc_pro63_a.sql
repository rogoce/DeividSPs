-- Modificado 07/09/2001 - Autor: Marquelda Valdelamar(inclusion de filtro d poliza)
---24102022 desglosar por unidad  HGIRON

DROP procedure spc_pro63_a;

CREATE procedure "informix".spc_pro63_a(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo DATE, a_cod_ramo CHAR(255) DEFAULT "*", a_codcliente CHAR(255) DEFAULT "*" ,a_subramo CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
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
		  CHAR(50),char(5),char(30),CHAR(10),SMALLINT;

----------------------------------------------------
---  DISTRIBUCION DE REASEGURO POLIZAS VIGENTES  ---
---  Amado Perez mayo 2001 - APM          	 ---
---  Ref. Power Builder - dw_pro63				 ---
----------------------------------------------------
 BEGIN

DEFINE v_nopoliza,v_contratante          		CHAR(10);
DEFINE v_documento                       		CHAR(20);
DEFINE v_codsucursal                     		CHAR(3);
DEFINE v_vigencia_inic,v_vigencia_final  		DATE;
DEFINE v_prima_suscrita,v_suma_asegurada 		DECIMAL(16,2);
DEFINE _suma_asegurada 		                    DECIMAL(16,2);
DEFINE v_desc_cliente                    		CHAR(45);
DEFINE v_descr_cia, v_desc_ramo,v_desc_contrato CHAR(50);
DEFINE v_desc_subramo                           CHAR(50);
DEFINE v_filtros                         		CHAR(100);
DEFINE _tipo                             		CHAR(1);
DEFINE _cod_ramo, _cod_subramo			 		CHAR(3);

DEFINE _cod_contrato					 		CHAR(5);
DEFINE _tipo_contrato,_serie				 		SMALLINT;
DEFINE _suma, _suma_all	, _prima_all	 		DEC(16,2);
DEFINE _prima							 		DEC(16,2);
DEFINE _no_poliza                        		CHAR(10);
DEFINE _cod_cober_reas                          CHAR(3);
DEFINE _es_terremoto, _orden                    SMALLINT;
define _no_unidad			char(5);
define _porc_partic_prima 	dec(9,6);
define _porc_partic_suma 	dec(9,6);
DEFINE _fecha_emision, _fecha_cancelacion, _fecha_added, _fecha_rehabilito, _fecha_eliminada DATE;
define _cod_grupo			char(5);
define _n_grupo			    char(30);
define _cod_endomov			char(3);
	
SET ISOLATION TO DIRTY READ; 
drop table if exists tmp_codigos;
drop table if exists temp_perfil;
drop table if exists tmp_contratos;

--set debug file to "sp_pro63.trc";
--trace on;

LET v_descr_cia = sp_sis01(a_cia);
 let _no_unidad = null;
 let _n_grupo = null;
 let _suma_asegurada = 0.00;
 let _suma_all = 0.00;
 let _prima_all = 0.00;
 
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
             no_documento	   CHAR(20)		 
             );

CREATE INDEX i_no_poliza1 ON tmp_contratos(cod_contrato);
CREATE INDEX i_no_poliza2 ON tmp_contratos(no_poliza);
CREATE INDEX i_no_poliza3 ON tmp_contratos(no_unidad);

{SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 2;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;}

LET v_filtros =  'Ramo 001,003,006,010,011,012,013,014,021,022;';
let a_cod_ramo = '001,003,006,010,011,012,013,014,021,022;';
LET _porc_partic_prima =  0.00;
LET _porc_partic_suma =  0.00;

--LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_cod_ramo);
--trace off;
   --IF a_no_documento = "0617-00025-03"  then
    --  set debug file to "sp_pro63a.trc";
     -- trace on; 
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
		 cod_subramo
    INTO v_nopoliza,
         v_documento,
         v_contratante,
         v_vigencia_inic,
         v_vigencia_final,
		 v_prima_suscrita,
		 _cod_ramo,
		 _cod_subramo
    FROM temp_perfil
   WHERE seleccionado = 1
        AND no_documento in ('0119-00276-01','0121-01472-01','0123-00135-01','2222-00013-03')
 {
   no_documento in (
 '0108-00025-06*',
 '0119-00279-01*',
 '1021-00002-01*',
 '2215-00016-01',
 '2218-00010-01*',
 '2220-00002-01*',
 '0622-00071-01*',
 '0619-00002-12*',
 '0620-00054-01*'
 ) --and seleccionado = 1
 }
     
ORDER BY vigencia_final
{
--Leer las pólizas vigentes al fecha xx, considerando la suma asegurada y prima actualizada a esa fecha xx, 
--     es decir si la póliza o unidad ha tenido endosos de aumento de suma con prima adicional o 
--     por el contrario disminución de suma con devolución de prima, 
--     el reporte debe mostrar el resultado neto o final de esos movimientos, 
--     siempre y cuando estén antes de la fecha corte indicada para generarlo.
--Si la póliza fue cancelada y rehabilitada antes de esa fecha xx, si la debe incluir el reporte y traer la información de suma y prima. 
--     Pero, si por ejemplo la rehabilitación fue después de la fecha corte a la que se pidió el reporte, 
--     entonces no debería incluirla porque estaría aun cancelada.
--Si una unidad fue eliminada de la póliza antes de la fecha de corte no debería incluirla el reporte, 
---    pero si la unidad fue eliminada posterior a esa fecha xx, entonces si la debe incluir. 
--Si una unidad es incluida en la póliza antes de la fecha de corte si debería incluirla el reporte, 
--     pero si la unidad fue incluida posterior a esa fecha xx, entonces no la debe incluir. 
}
{
•	Si se canceló antes del 30/06 no se muestra.
•	Si la Póliza se cancelo y se rehabilitó antes del 30/06 se debe mostrar.
•	Si la Póliza se canceló antes del 30/06 y se rehabilitó después del 30/06 NO se Muestra.

}

    select fecha_cancelacion, cod_grupo
	  into _fecha_cancelacion, _cod_grupo
	  from emipomae
	 where no_poliza  = v_nopoliza
	   --and (vigencia_final >= a_periodo or vigencia_final is null)
	   --and fecha_suscripcion <= a_periodo
	   and vigencia_inic <= a_periodo
	   and actualizado = 1;  
	   
	    if _fecha_cancelacion is null then 

			SELECT max(fecha_emision)
			  INTO _fecha_cancelacion
			  FROM endedmae
			 WHERE no_documento = v_documento   --no_poliza = v_nopoliza
			   AND cod_endomov = '002'
			   AND fecha_emision <= a_periodo;	
		end if					   

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
			e.fecha_emision,
			e.cod_endomov
	   INTO	_cod_contrato,
			_suma,
			_prima,
			_cod_cober_reas,
			_orden,
			_no_unidad,
			_porc_partic_prima,
			_porc_partic_suma,
			_fecha_emision,
			_cod_endomov
	   FROM emifacon c, endedmae e
	  WHERE	e.no_documento = v_documento  
   	    and c.no_poliza   = v_nopoliza
	    AND c.no_poliza   = e.no_poliza
		AND c.no_endoso   = e.no_endoso
		AND e.actualizado = 1
		AND (c.prima <> 0 OR c.suma_asegurada <> 0)	
		and e.fecha_emision <= a_periodo
	  order by c.cod_contrato,c.no_unidad
	  
--LET _fecha_emision = null;
	
		  IF _fecha_cancelacion <= a_periodo THEN
			 FOREACH
				SELECT max(fecha_emision)
				  INTO _fecha_cancelacion
				  FROM endedmae
				  WHERE no_documento = v_documento   --- no_poliza = v_nopoliza
				   AND cod_endomov = '002'
				   AND fecha_emision <= a_periodo
			 END FOREACH
			 
		       FOREACH
				SELECT max(fecha_emision)
				  INTO _fecha_rehabilito
				  FROM endedmae
				   WHERE no_documento = v_documento ---no_poliza = v_nopoliza
				   AND cod_endomov = '003'
				   AND fecha_emision <= a_periodo
				   and fecha_emision >=  _fecha_cancelacion
			 END FOREACH			 

			 IF  _fecha_cancelacion <= a_periodo THEN
			    if _fecha_rehabilito <= a_periodo  THEN  --and _fecha_rehabilito >= _fecha_emision
				else
				   CONTINUE FOREACH;
				 end if
			 END IF
		  END IF
		  
			if _cod_endomov in ('001','019')  then	
				if _fecha_emision <= a_periodo then
				else
					CONTINUE FOREACH;
				end if	
			end if			  
			
			foreach
            SELECT max(fecha_emision)
			  INTO _fecha_eliminada
			  FROM endedmae a, endeduni b 
			 WHERE a.no_poliza = b.no_poliza
			   AND a.no_endoso = b.no_endoso
               AND a.no_documento = v_documento ---no_poliza = v_nopoliza
				AND a.cod_endomov = '005'
				and b.no_unidad = _no_unidad
				AND a.fecha_emision <= a_periodo			   			 			
			  exit foreach;	   
			   end foreach	
			   
				if _fecha_eliminada <= a_periodo then
				   CONTINUE FOREACH;								
				end if	
			
			if _cod_endomov = '004'  then
				if _fecha_emision <= a_periodo then
				else
					CONTINUE FOREACH;
				end if	
			end if			  
		  
			if _cod_endomov in ('002')  then	
				 FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_cancelacion
					  FROM endedmae
					  WHERE no_documento = v_documento   --- no_poliza = v_nopoliza
					   AND cod_endomov = '002'
					   AND fecha_emision <= a_periodo
				 END FOREACH
			 
				if _fecha_cancelacion <= a_periodo then
				
					   FOREACH
						SELECT max(fecha_emision)
						  INTO _fecha_rehabilito
						  FROM endedmae
						   WHERE no_documento = v_documento ---no_poliza = v_nopoliza
						   AND cod_endomov = '003'
						   AND fecha_emision <= a_periodo
						   and fecha_emision >=  _fecha_cancelacion
					 END FOREACH
					 
						if _fecha_rehabilito is null THEN  --and _fecha_rehabilito >= _fecha_emision
						   CONTINUE FOREACH;
						 end if						 
					 
						if _fecha_rehabilito <= a_periodo   THEN  --and _fecha_rehabilito >= _fecha_emision
						else
						   CONTINUE FOREACH;
						 end if					 					 

				end if	
			end if																	  

		SELECT tipo_contrato,
		       nombre,
			   serie
		  INTO _tipo_contrato,
		       v_desc_contrato,
			   _serie
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
			--let _prima = 0;
		END IF

	    LET v_prima_suscrita = v_prima_suscrita + _prima;
		
		let _prima = _prima;
		let _suma = _suma;
		
	
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
				VALUES (v_nopoliza, _cod_contrato, v_desc_contrato, _tipo_contrato, _orden, _suma, _prima,_no_unidad,_prima,_suma, v_documento);
	       END
		   
	END FOREACH
	
	FOREACH
	 SELECT no_unidad,
	        no_documento,
	        nombre,
			sum(prima_suscrita),
			sum(suma_asegurada),
	        SUM(suma),
	        SUM(prima)
	   INTO _no_unidad,
	        v_documento,
	        v_desc_contrato,
			v_prima_suscrita,
			v_suma_asegurada,
	        _suma,
	        _prima
	   FROM tmp_contratos
	  WHERE no_poliza = v_nopoliza
	  GROUP BY no_unidad,no_documento,nombre 
	  ORDER BY no_unidad,no_documento,nombre
	  
	  if _suma = 0 and _prima <> 0 then
		 SELECT sum( c.suma_asegurada ), sum( c.prima )   
		   into _suma_all, _prima_all
		   FROM emifacon c, endedmae e
		  WHERE e.no_documento = v_documento
			and c.no_unidad = _no_unidad
			AND c.no_poliza   = e.no_poliza
			AND c.no_endoso   = e.no_endoso
			AND e.actualizado = 1
			AND (c.prima <> 0 OR c.suma_asegurada <> 0)
			and e.fecha_emision  <= a_periodo;	  
			
				if _suma_all is null then
					let _suma_all = 0;
				end if

				if _prima_all is null then
					let _prima_all = 0;
				end if
				
				let _suma = _suma_all;
				let v_suma_asegurada = _suma_all;
				
       end if			
	  

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
			  v_nopoliza,
			  _serie
              WITH RESUME;
	END FOREACH
END FOREACH



END

END PROCEDURE;
