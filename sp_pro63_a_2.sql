-- Modificado 07/09/2001 - Autor: Marquelda Valdelamar(inclusion de filtro d poliza)
---24102022 desglosar por unidad  HGIRON

DROP procedure sp_pro63_a_2;
CREATE procedure sp_pro63_a_2(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_periodo DATE, a_cod_ramo CHAR(255) DEFAULT "*", a_codcliente CHAR(255) DEFAULT "*" ,a_subramo CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
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
--		  CHAR(5),
--		  CHAR(50),
		  CHAR(50),char(5),char(30),CHAR(10),SMALLINT,dec(9,6),dec(9,6),
		  DECIMAL(16,2), 
          DECIMAL(16,2),
		  DECIMAL(16,2), 
          DECIMAL(16,2),
		  DECIMAL(16,2), 
          DECIMAL(16,2),
		  DECIMAL(16,2), 
          DECIMAL(16,2),
		  DECIMAL(16,2), 
          DECIMAL(16,2),
		  DECIMAL(16,3), 
          DECIMAL(16,3),
		  DECIMAL(16,3), 
          DECIMAL(16,3),
		  DECIMAL(16,3), 
          DECIMAL(16,3),
		  DECIMAL(16,3), 
          DECIMAL(16,3),
		  DECIMAL(16,3), 
          DECIMAL(16,3);

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
DEFINE _es_terremoto, _orden,_estatus_poliza    SMALLINT;
define _no_unidad			char(5);
define _porc_partic_prima 	dec(9,6);
define _porc_partic_suma 	dec(9,6);
DEFINE _fecha_emision, _fecha_cancelacion, _fecha_added, _fecha_rehabilito, _fecha_eliminada,_fecha_incluida DATE;
define _cod_grupo			char(5);
define _n_grupo			    char(30);
define _cod_endomov			char(3);
define _suma_retencion     DEC(16,2);
define _suma_excedente     DEC(16,2);
define _suma_facultativos  DEC(16,2);
define _suma_cuota_parte   DEC(16,2);			 
define _suma_ot_contratos  DEC(16,2);			 
define _prima_ot_contratos   DEC(16,2);
define _prima_retencion    DEC(16,2);
define _prima_excedente    DEC(16,2);
define _prima_facultativos DEC(16,2);
define _prima_cuota_parte  DEC(16,2);	
define	_psa_retencion	DEC(16,3);
define	_psa_excedente	DEC(16,3);
define	_psa_facultativos	DEC(16,3);
define	_psa_cuota_parte	DEC(16,3);
define	_psa_ot_contratos	DEC(16,3);
define	_pp_retencion	DEC(16,3);
define	_pp_excedente	DEC(16,3);
define	_pp_facultativos	DEC(16,3);
define	_pp_cuota_parte	DEC(16,3);
define	_pp_ot_contratos	DEC(16,3);

	
SET ISOLATION TO DIRTY READ; 
drop table if exists tmp_codigos;
drop table if exists temp_perfil;
drop table if exists tmp_contratos;
drop table if exists tmp_contratos2;

--set debug file to "sp_pro63.trc";
--trace on;

LET v_descr_cia = sp_sis01(a_cia);
 let _no_unidad = null;
 let _n_grupo = null;
 let _suma_asegurada = 0.00;
 let _suma_all = 0.00;
 let _prima_all = 0.00;

 let _suma_retencion  = 0.00;
 let _suma_excedente  = 0.00;
 let _suma_facultativos = 0.00;
 let _suma_cuota_parte = 0.00;		 
 let _suma_ot_contratos = 0.00;		 
 let _prima_retencion = 0.00;
 let _prima_excedente = 0.00;
 let _prima_facultativos = 0.00;
 let _prima_cuota_parte = 0.00;
 let _prima_ot_contratos = 0.00;
 
let	_psa_retencion	 = 0.00;
let	_psa_excedente	 = 0.00;
let	_psa_facultativos	 = 0.00;
let	_psa_cuota_parte	 = 0.00;
let	_psa_ot_contratos	 = 0.00;
let	_pp_retencion	 = 0.00;
let	_pp_excedente	 = 0.00;
let	_pp_facultativos	 = 0.00;
let	_pp_cuota_parte	 = 0.00;
let	_pp_ot_contratos	 = 0.00;

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
             no_documento	   CHAR(20),
			 porc_partic_prima DEC(16,2),
			 porc_partic_suma  DEC(16,2)				 
             );

CREATE INDEX i_no_poliza1 ON tmp_contratos(cod_contrato);
CREATE INDEX i_no_poliza2 ON tmp_contratos(no_poliza);
CREATE INDEX i_no_poliza3 ON tmp_contratos(no_unidad);


CREATE TEMP TABLE tmp_contratos2
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
             no_documento	   CHAR(20),		
             suma_retencion     DEC(16,2),
             suma_excedente     DEC(16,2),
             suma_facultativos  DEC(16,2),
             suma_cuota_parte   DEC(16,2),			 
             suma_ot_contratos   DEC(16,2),				 
			 prima_retencion     DEC(16,2),
			 prima_excedente     DEC(16,2),
			 prima_facultativos  DEC(16,2),
			 prima_cuota_parte   DEC(16,2),	
			 prima_ot_contratos  DEC(16,2),
			 porc_partic_prima   DEC(16,2),
			 porc_partic_suma    DEC(16,2),
             psa_retencion      DEC(16,3),
             psa_excedente      DEC(16,3),
             psa_facultativos   DEC(16,3),
             psa_cuota_parte    DEC(16,3),			 
             psa_ot_contratos   DEC(16,3),				 
             pp_retencion     DEC(16,3),
             pp_excedente     DEC(16,3),
             pp_facultativos  DEC(16,3),
             pp_cuota_parte   DEC(16,3),	
             pp_ot_contratos  DEC(16,3)		 
             );
			 

CREATE INDEX i2_no_poliza2 ON tmp_contratos2(no_documento);
CREATE INDEX i2_no_poliza3 ON tmp_contratos2(no_unidad);			 

{
	
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 2;

   SELECT c.nombre
     INTO v_desc_ramo
     FROM prdramo c
    WHERE c.cod_ramo = _cod_ramo;}
	
let _fecha_cancelacion = '01/01/1900';
LET v_filtros = ''; -- 'Ramo 001,003,006,010,011,012,013,014,021,022;'; SD#7984 JHIM liberar para que tome los ramos del filtro.
--let a_cod_ramo = '001,003,006,010,011,012,013,014,021,022;';
LET _porc_partic_prima =  0.00;
LET _porc_partic_suma =  0.00;

LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_cod_ramo);
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

select fecha_cancelacion,
       cod_grupo,
	   estatus_poliza
  into _fecha_cancelacion,
       _cod_grupo,
	   _estatus_poliza
  from emipomae
 where no_poliza  = v_nopoliza
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
			c.suma_asegurada, 
			c.prima, 
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
	  
	    if _fecha_cancelacion = '01/01/1900' then	--AMM
		ELSE
			IF _fecha_cancelacion <= a_periodo THEN
				 FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_cancelacion
					  FROM endedmae
					  WHERE no_documento = v_documento 
					   AND cod_endomov = '002'
					   AND fecha_emision <= a_periodo
					   and actualizado = 1				--AMM
				 END FOREACH
				 
				   FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_rehabilito
					  FROM endedmae
					   WHERE no_documento = v_documento 
					   AND cod_endomov = '003'
					   AND fecha_emision <= a_periodo
					   and fecha_emision >=  _fecha_cancelacion
					   and actualizado = 1							--AMM
				 END FOREACH			 

				 IF  _fecha_cancelacion <= a_periodo THEN
					if _fecha_rehabilito <= a_periodo  THEN
						if _estatus_poliza in(2,4) then	--La poliza esta cancelada, no se debe mostrar	AMM
							CONTINUE FOREACH;
						end if
					else
					   CONTINUE FOREACH;
					end if
				 END IF
			 END IF
		end if
		  
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
               AND a.no_documento = v_documento
			   and a.no_poliza = v_nopoliza
				AND a.cod_endomov = '005'		--ELIMINACION DE UNIDADES
				and b.no_unidad = _no_unidad
				AND a.fecha_emision <= a_periodo			   			 			
			  exit foreach;	   
		end foreach
		--AMM
		foreach
            SELECT max(fecha_emision)
			  INTO _fecha_incluida
			  FROM endedmae a, endeduni b 
			 WHERE a.no_poliza = b.no_poliza
			   AND a.no_endoso = b.no_endoso
               AND a.no_documento = v_documento
			   and a.no_poliza = v_nopoliza
				AND a.cod_endomov = '004'		--INCLUSION DE UNIDADES
				and b.no_unidad = _no_unidad
				AND a.fecha_emision <= a_periodo			   			 			
			  exit foreach;	   
		end foreach
		
		if _cod_endomov = '004'  then	--INCLUSION DE UNIDADES
			if _fecha_emision <= a_periodo then
			else
				CONTINUE FOREACH;
			end if	
		end if
		
        if _fecha_eliminada is not null then
			if _fecha_eliminada <= a_periodo then
				if _fecha_incluida is not null then			--AMM
					if _fecha_incluida <= a_periodo then	--AMM
					ELSE
						CONTINUE FOREACH;
					end if
				ELSE
					CONTINUE FOREACH;
				end if
			end if
		end if
		if _cod_endomov in ('002')  then	
			 FOREACH
				SELECT max(fecha_emision)
				  INTO _fecha_cancelacion
				  FROM endedmae
				  WHERE no_documento = v_documento  
				   AND cod_endomov = '002'
				   AND fecha_emision <= a_periodo
			 END FOREACH
		 
			if _fecha_cancelacion <= a_periodo then
			
				FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_rehabilito
					  FROM endedmae
				     WHERE no_documento = v_documento 
					   AND cod_endomov = '003'
					   AND fecha_emision <= a_periodo
					   and fecha_emision >=  _fecha_cancelacion
				END FOREACH
				 
				if _fecha_rehabilito is null THEN 
				   CONTINUE FOREACH;
				 end if						 
			 
				if _fecha_rehabilito <= a_periodo THEN
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
			       and no_unidad = _no_unidad;

			END EXCEPTION
					  
			INSERT INTO tmp_contratos
			VALUES (v_nopoliza, _cod_contrato, v_desc_contrato, _tipo_contrato, _orden, _suma, _prima,_no_unidad,_prima,_suma, v_documento,_porc_partic_prima,_porc_partic_suma);
	    END
		
		LET _suma_retencion     = 0;
		LET _suma_excedente      = 0;
		LET _suma_facultativos  = 0;
		LET _suma_cuota_parte   = 0;
		LET _suma_ot_contratos  = 0;		

		LET _prima_retencion    = 0;		
		LET _prima_excedente     = 0;
		LET _prima_facultativos = 0;
		LET _prima_cuota_parte  = 0;
		LET _prima_ot_contratos = 0;
		
		let	_psa_retencion	 = 0.00;
		let	_psa_excedente	 = 0.00;
		let	_psa_facultativos	 = 0.00;
		let	_psa_cuota_parte	 = 0.00;
		let	_psa_ot_contratos	 = 0.00;
		let	_pp_retencion	 = 0.00;
		let	_pp_excedente	 = 0.00;
		let	_pp_facultativos	 = 0.00;
		let	_pp_cuota_parte	 = 0.00;
		let	_pp_ot_contratos	 = 0.00;	
		
		foreach
			select distinct e.porc_partic_prima,e.porc_partic_suma
			  into _porc_partic_prima,_porc_partic_suma
			  from emireaco e, reacocob c,reacomae r
			 where e.cod_contrato = c.cod_contrato
			   and  e.cod_contrato = r.cod_contrato
			   and  e.cod_cober_reas = c.cod_cober_reas
			   and e.no_poliza = v_nopoliza
			   and e.no_unidad = _no_unidad
			   and r.tipo_contrato = _tipo_contrato
			   and e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = v_nopoliza and no_unidad = _no_unidad)
			   exit foreach;
		 end foreach

			if _tipo_contrato = 1 then
				let v_desc_contrato = 'RETENCION';
				let	_psa_retencion	 = _porc_partic_suma;					
				let	_pp_retencion	 = _porc_partic_prima;					
			elif _tipo_contrato = 3 then
				let v_desc_contrato = 'FACULTATIVO';
				let	_psa_facultativos	 = _porc_partic_suma;				
				let	_pp_facultativos	 = _porc_partic_prima;		
			elif _tipo_contrato = 5 then
				let v_desc_contrato = 'CUOTA PARTE';
				let	_psa_cuota_parte = _porc_partic_suma;				
				let	_pp_cuota_parte	 = _porc_partic_prima;						
			elif _tipo_contrato = 7 then
				let v_desc_contrato = 'EXCEDENTE';
				let	_psa_excedente	 = _porc_partic_suma;					
				let	_pp_excedente	 = _porc_partic_prima;						
			end if
				
			IF   _tipo_contrato = 1 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_retencion    = 0;
				ELSE
					LET _suma_retencion    = _suma;
				END IF
				LET _prima_retencion    = _prima;
			ELIF _tipo_contrato = 3 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_facultativos    = 0;
				ELSE
					LET _suma_facultativos = _suma;
				END IF
				LET _prima_facultativos = _prima;
			ELIF _tipo_contrato = 5 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_cuota_parte    = 0;
				ELSE
					LET _suma_cuota_parte = _suma;
				END IF
				LET _prima_cuota_parte = _prima;
			ELIF _tipo_contrato = 7 THEN
				IF _es_terremoto = 1 THEN
					LET _suma_excedente    = 0;
				ELSE
					LET _suma_excedente = _suma;
				END IF
				LET _prima_excedente = _prima;				
			ELSE
				IF _es_terremoto = 1 THEN
					LET _suma_ot_contratos    = 0;
				ELSE
					LET _suma_ot_contratos    = _suma;
				END IF
				LET _prima_ot_contratos    = _prima;
				let	_psa_ot_contratos	 = _porc_partic_suma;			
				let	_pp_ot_contratos	 = _porc_partic_prima;						
			END IF							
		
		 BEGIN
		    ON EXCEPTION IN(-239)
			   UPDATE tmp_contratos2
				  SET prima_suscrita = prima_suscrita + _prima ,
			 	      suma_asegurada = suma_asegurada + _suma,
					  suma_retencion = suma_retencion + _suma_retencion,
					  suma_excedente = suma_excedente + _suma_excedente,
					  suma_facultativos = suma_facultativos + _suma_facultativos,
					  suma_cuota_parte = suma_cuota_parte + _suma_cuota_parte,
					  suma_ot_contratos = suma_ot_contratos + _suma_ot_contratos,
					  prima_retencion  = prima_retencion + _prima_retencion ,
					  prima_excedente  = prima_excedente + _prima_excedente ,
					  prima_facultativos  = prima_facultativos + _prima_facultativos ,
					  prima_cuota_parte  = prima_cuota_parte + _prima_cuota_parte ,
					  prima_ot_contratos = prima_ot_contratos + _prima_ot_contratos 
			  WHERE no_documento  = v_documento
				AND no_unidad = _no_unidad;
							
			END EXCEPTION
					  
				INSERT INTO tmp_contratos2
				VALUES (v_nopoliza, _cod_contrato, v_desc_contrato, _tipo_contrato, _orden, _suma, _prima,_no_unidad,_prima,_suma, v_documento, _suma_retencion,_suma_excedente,_suma_facultativos,_suma_cuota_parte,_suma_ot_contratos,_prima_retencion,_prima_excedente,_prima_facultativos,_prima_cuota_parte,_prima_ot_contratos,_porc_partic_prima,_porc_partic_suma,_psa_retencion,
						_psa_excedente,
						_psa_facultativos,
						_psa_cuota_parte,
						_psa_ot_contratos,
						_pp_retencion,
						_pp_excedente,
						_pp_facultativos,
						_pp_cuota_parte,
						_pp_ot_contratos);
	    END		
		
	let  v_desc_contrato = '';
	let  _porc_partic_prima = 0;
	let  _porc_partic_suma = 0;		
		   
	END FOREACH

	FOREACH
	 SELECT no_unidad,
	        no_documento,
			max(psa_retencion),
			max(psa_excedente),
			max(psa_facultativos),
			max(psa_cuota_parte),
			max(psa_ot_contratos),
			max(pp_retencion),
			max(pp_excedente),
			max(pp_facultativos),
			max(pp_cuota_parte),
			max(pp_ot_contratos),			
			sum(prima_suscrita),
			sum(suma_asegurada),
	        SUM(suma),
	        SUM(prima),
            SUM(suma_retencion) suma_retencion,
	        SUM(suma_excedente) suma_excedente,
			SUM(suma_facultativos) suma_facultativos,
   			SUM(suma_cuota_parte + suma_ot_contratos) suma_cuota_parte,
            SUM(suma_ot_contratos) suma_ot_contratos,
			SUM(prima_retencion) prima_retencion,
			SUM(prima_excedente) prima_excedente,
			SUM(prima_facultativos) prima_facultativos,
   			SUM(prima_cuota_parte + prima_ot_contratos) prima_cuota_parte,
			SUM(prima_ot_contratos) prima_ot_contratos
	      INTO _no_unidad,
	        v_documento,
			_psa_retencion,
			_psa_excedente,
			_psa_facultativos,
			_psa_cuota_parte,
			_psa_ot_contratos,
			_pp_retencion,
			_pp_excedente,
			_pp_facultativos,
			_pp_cuota_parte,
			_pp_ot_contratos,						
			v_prima_suscrita,
			v_suma_asegurada,
	        _suma,
	        _prima,			
	        _suma_retencion,
	        _suma_excedente,
			_suma_facultativos,
	        _suma_cuota_parte,
		    _suma_ot_contratos,
	        _prima_retencion,
	        _prima_excedente,
			_prima_facultativos,
	        _prima_cuota_parte,
		    _prima_ot_contratos
	   FROM tmp_contratos2
	  WHERE no_poliza = v_nopoliza
	  GROUP BY no_unidad,no_documento 
	  ORDER BY no_documento,no_unidad 
	  

	 { 
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
				
             if _prima_retencion > 0 then
			   let _suma_retencion = _suma ; 	        
			 end if
             if _prima_excedente > 0 then
			   let _suma_excedente = _suma ; 
			 end if	
             if _prima_facultativos > 0 then
			   let _suma_facultativos = _suma ; 
			 end if	
             if _prima_cuota_parte > 0 then
			   let _suma_cuota_parte = _suma ;       
			 end if
             if _prima_ot_contratos > 0 then
			   let _suma_ot_contratos = _suma ; 
               let _suma_cuota_parte = _suma_cuota_parte + _suma_ot_contratos;			   
			 end if				 	       		    												
				
       end if	}

	  

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
--				_cod_contrato,
--				v_desc_contrato,
				v_desc_subramo,
				_no_unidad,
				_n_grupo,
				v_nopoliza,
				_serie, 
				_porc_partic_prima,
				_porc_partic_suma,
				_suma_retencion,
				_suma_excedente,
				_suma_facultativos,
				_suma_cuota_parte,
				_suma_ot_contratos,
				_prima_retencion,
				_prima_excedente,
				_prima_facultativos,
				_prima_cuota_parte,
				_prima_ot_contratos,
				TRUNC(nvl(_psa_retencion,0),4),
				TRUNC(nvl(_psa_excedente,0),4),
				TRUNC(nvl(_psa_facultativos,0),4),
				TRUNC(nvl(_psa_cuota_parte,0),4),
				TRUNC(nvl(_psa_ot_contratos,0),4),
				TRUNC(nvl(_pp_retencion,0),4),
				TRUNC(nvl(_pp_excedente,0),4),
				TRUNC(nvl(_pp_facultativos,0),4),
				TRUNC(nvl(_pp_cuota_parte,0),4),
				TRUNC(nvl(_pp_ot_contratos,0),4)			
              WITH RESUME;
	END FOREACH
END FOREACH



END

END PROCEDURE;
