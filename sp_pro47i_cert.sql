-- Procedimiento cobertura certificado salud subramo 002
-- Creado:	04/07/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro47i_cert('0001775769','00001')

drop procedure sp_pro47i_cert; 
create procedure sp_pro47i_cert(a_poliza CHAR(10),a_unidad CHAR(255) DEFAULT '*')
returning varchar(100) as Nombre,
			 dec(16,2) as Prima,
			  smallint as orden,
			varchar(250) as desc_limite1,	
			varchar(250) as desc_limite2, 	
			smallint as orden_imp,
			smallint as num_ver,
			smallint as cober_ver,
			Lvarchar(505) as descripcion,
			varchar(5) as orden_imp_s,
			char(10) as no_poliza,
			char(5) as no_unidad;
		  

define _nombre              varchar(100);
define _prima 		        dec(16,2);
define _orden		        smallint;				 
define _desc_limite1	    varchar(250);	
define _desc_limite2 		varchar(250);
define _orden_imp		    smallint;				 
define _num_ver		        smallint;				 
define _cober_ver		    smallint;				 	
define _descripcion         Lvarchar(500);				 
define _orden_imp_s         varchar(5);
define _no_poliza           CHAR(10);
define _no_unidad           char(5);
DEFINE v_cod_producto       CHAR(5);      
define _prima_cero	        dec(16,2);
DEFINE _tipo             CHAR(1);
--set debug file to "sp_pro47i_c.trc";
--trace on;
let _prima_cero = 0;
let _prima = 0;
drop table if exists tmp_emipouni;
set isolation to dirty read;
let a_unidad = trim(a_unidad)||';';

IF a_unidad <> "*" THEN

	LET _tipo = sp_sis04(a_unidad);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	
	SELECT distinct cod_producto,no_unidad
	  FROM emipouni
	 WHERE no_poliza = a_poliza	  
	  and no_unidad IN (SELECT codigo FROM tmp_codigos) 
	GROUP BY cod_producto,no_unidad
	 into temp tmp_emipouni;


ELSE		        -- (E) Excluir estos Registros
	
	SELECT distinct cod_producto,no_unidad
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	   and no_unidad NOT IN (SELECT codigo FROM tmp_codigos)
	GROUP BY cod_producto,no_unidad
	 into temp tmp_emipouni;

	END IF

	DROP TABLE tmp_codigos;

END IF
	 
	 
	
FOREACH		
	SELECT distinct cod_producto,no_unidad
 	  INTO v_cod_producto, _no_unidad
	  FROM tmp_emipouni	 
	ORDER BY cod_producto,no_unidad	
	

	foreach
		  SELECT prdcober.nombre,   
				 emipocob.prima,   
				 prdcobpd.orden, --emipocob.orden,   
				 prdcobpd.desc_limite1, --emipocob.desc_limite1,
				 prdcobpd.desc_limite2,				 
				 --emipocob.desc_limite1,   
				 --emipocob.desc_limite2,   
				 prdcobpd.orden,prdcobpd.ver_no_cobertura ,prdcobpd.ver_no_cobertura --				 prdcober.orden_imp,prdcober.num_ver,prdcober.cober_ver				 		 			 		 
			into _nombre,
				 _prima_cero,
				 _orden,
				 _desc_limite1,	
				 _desc_limite2, 	
				 _orden_imp,
				 _num_ver,
				 _cober_ver
			FROM prdcober,   
				 emipocob, 
				 prdcobpd   
		   WHERE prdcober.cod_cobertura = emipocob.cod_cobertura  and  
				 prdcober.cod_cobertura = prdcobpd.cod_cobertura  and  prdcobpd.cod_producto =  v_cod_producto and
				 emipocob.no_poliza = a_poliza  AND  
				 emipocob.no_unidad = _no_unidad  --AND                  prdcobpd.orden	not in ( 0 )	--and prdcobpd.ver_no_cobertura	= 1	 --and prdcober.cober_ver	= 0							 
        ORDER BY emipocob.no_unidad asc,prdcobpd.orden ASC	,prdcobpd.ver_no_cobertura desc			 
				 --prdcober.cober_ver	= 1							 
		--ORDER BY prdcober.orden_imp ASC   
		
			  IF _desc_limite1 IS NULL THEN	
				  let _desc_limite1 = '';
			 END IF
			 
			  IF _desc_limite2 IS NULL THEN	
				  let _desc_limite2 = '';
			 END IF			 
					
		     let  _descripcion = _desc_limite1|| ' ' ||_desc_limite2;			 
			 
			 if _num_ver = '0' then
				let _orden_imp_s = '';
			else
			    let _orden_imp_s = _orden_imp;
			 end if			 
			 let _no_poliza = a_poliza;
			 let _no_unidad = _no_unidad;
			
			 if _orden = 1 then
			     let _prima = _prima;
			else
			     let _prima = _prima_cero;
			 end if

		  return _nombre,
				 _prima,
				 _orden,
				 _desc_limite1,	
				 _desc_limite2, 	
				 _orden_imp,
				 _num_ver,
				 _cober_ver,
				 _descripcion,
                 _orden_imp_s,
				 _no_poliza,
				 _no_unidad				 
		   WITH RESUME;
		   
	end foreach;
END FOREACH	
end procedure