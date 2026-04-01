-- sp_pro47g   Genera el resumen de Coberturas -- Simular Emicartasald2 
-- Creado    : 18/07/2016 - Autor: Henry Girón --
-- Modificado: 18/01/2016 - Autor: Henry Girón --
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro47g;
CREATE PROCEDURE "informix".sp_pro47g(a_no_documento CHAR(20) default "",a_periodo CHAR(7) DEFAULT "")
			RETURNING   CHAR(5),			 -- v_cod_producto
						SMALLINT,			 -- _orden
						CHAR(50),			 -- _nom_cobertura
						CHAR(100),			 -- _desc_limite1
						DEC(16,2),			 -- _prima
						CHAR(5),             -- _unidad
						CHAR(10),			-- _poliza
						CHAR(7);			 -- _periodo

DEFINE v_cod_cobertura   CHAR(5);	
DEFINE _orden	         INT;
DEFINE _nom_cobertura    CHAR(50);
DEFINE _desc_limite		 CHAR(100);
DEFINE _prima		     DEC(16,2);
DEFINE v_desc_limite1	 CHAR(50);
DEFINE v_desc_limite2	 CHAR(50);
DEFINE v_cod_producto    CHAR(5);
define a_poliza          CHAR(10) ;
DEFINE v_vigen_ini        DATE;
DEFINE v_unidad          CHAR(5);
DEFINE _cod_cliente	     CHAR(10);
DEFINE v_suma_aseg	     DEC(16,2);
define _restar_imp       	dec(16,2);
define _porc_impuesto       dec(5,2);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     
let _porc_impuesto = 0.00;
let _restar_imp = 0.00; 
FOREACH	
	SELECT cod_producto,prima  --,fecha_aniv
	  INTO v_cod_producto,_prima --,v_vigen_ini
	  FROM emicartasal2
     WHERE periodo = a_periodo
       AND no_documento = a_no_documento	  	   

	
	CALL sp_sis21(a_no_documento) RETURNING a_poliza; 
	
	 -- Restar impuesto	--01/08/2016 Henry, solicitud de MVILLARR
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if
  
	let _restar_imp =  (_prima - ( _prima / (1+(_porc_impuesto / 100))  ) ); 
	let _prima = _prima - _restar_imp ;   	
   --   
	
	FOREACH
	  SELECT no_unidad --,cod_asegurado,suma_asegurada
	    INTO v_unidad --,_cod_cliente,v_suma_aseg
		FROM emipouni
	   WHERE no_poliza = a_poliza	

		FOREACH	
		   SELECT prdcober.cod_cobertura, prdcober.nombre ,    emipocob.orden ,  emipocob.desc_limite1 ,  emipocob.desc_limite2 -- emipocob.prima ,
			 INTO v_cod_cobertura, _nom_cobertura, _orden, v_desc_limite1, v_desc_limite2  -- _prima,
			 FROM prdcober ,  emipocob
			WHERE ( prdcober.cod_cobertura = emipocob.cod_cobertura )
			  AND ( ( emipocob.no_poliza = a_poliza )
			  AND ( emipocob.no_unidad = v_unidad ) )
			ORDER BY emipocob.orden          ASC	  

			IF v_desc_limite1 IS NULL THEN
			   LET v_desc_limite1 = ' ';
			END IF
			IF v_desc_limite2 IS NULL THEN
			   LET v_desc_limite2 = ' ';
			END IF
			
			LET _desc_limite = TRIM(v_desc_limite1) || ' ' || TRIM(v_desc_limite2);	

			RETURN v_cod_producto,
				   _orden,
				   _nom_cobertura,
				   _desc_limite,
				   _prima,
				   v_unidad,
				   a_poliza,
				   a_periodo
				   WITH RESUME; 
				   
				   let _prima = 0.00;
				   
		END FOREACH
	END FOREACH	
END FOREACH

END
END PROCEDURE;