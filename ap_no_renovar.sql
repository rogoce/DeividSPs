-- 
-- Genera Información para la poliza 1619-00013-01 
-- Creado    : 07/04/2022 - Autor: Amado Perez

DROP PROCEDURE ap_no_renovar;
CREATE PROCEDURE ap_no_renovar() 
RETURNING 	char(10) as no_poliza, 
			char(20) as no_documento,
	        date as vigencia_inicial,
	        date as vigencia_final,
			char(10) as estatus_poliza,
			smallint as no_renovar,
	        char(3) as cod_no_renovar,
            char(5) as no_unidad,
 		    char(5) as cod_producto,
		    varchar(50) as nonmbre;

	DEFINE _no_poliza 			char(10);
	DEFINE _no_documento        char(20);
 	DEFINE _vigencia_inic       date;
	DEFINE _vigencia_final      date;
	DEFINE _estatus_poliza      smallint;
	DEFINE _no_renovar          smallint;
	DEFINE _cod_no_renov        char(3);
	DEFINE _no_unidad           char(5);
	DEFINE _cod_producto        char(5);
	DEFINE _nombre              varchar(50);
        

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;

FOREACH
  SELECT emipomae.no_documento
    into _no_documento	
    FROM emipomae,   
         emipouni,   
         prdprod  
   WHERE ( emipouni.no_poliza = emipomae.no_poliza ) and  
         ( prdprod.cod_producto = emipouni.cod_producto ) and  
         ( ( emipouni.cod_producto in ('05055','07224','07225','07229','07285','06669') )  and
           ( emipomae.actualizado = 1  ) )
group by no_documento
order by no_documento  

    LET _no_poliza = sp_sis21(_no_documento);

    FOREACH 	
	  SELECT emipomae.no_poliza,   
			 emipomae.no_documento,   
			 emipomae.vigencia_inic,   
			 emipomae.vigencia_final,   
			 emipomae.estatus_poliza,   
			 emipomae.no_renovar,   
			 emipomae.cod_no_renov,   
			 emipouni.no_unidad,   
			 emipouni.cod_producto,   
			 prdprod.nombre
        INTO _no_poliza,
             _no_documento,
             _vigencia_inic,
             _vigencia_final,
             _estatus_poliza,	
             _no_renovar,
             _cod_no_renov,
             _no_unidad,
             _cod_producto,
             _nombre			 
		FROM emipomae,   
			 emipouni,   
			 prdprod  
	   WHERE ( emipouni.no_poliza = emipomae.no_poliza ) and  
			 ( prdprod.cod_producto = emipouni.cod_producto ) and  
             ( emipomae.no_poliza = _no_poliza ) and
			 ( emipouni.cod_producto in ('05055','07224','07225','07229','07285','06669'))
			 
		if _estatus_poliza in (1,3) and _no_renovar = 0 then			 
		
			update emipomae
			   set cod_no_renov = '041',
				   no_renovar = 1
			 where no_poliza = _no_poliza;
		   
			return _no_poliza, 
			       _no_documento, 
				   _vigencia_inic, 
				   _vigencia_final, 
				   (case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end), 
				   _no_renovar, 
				   _cod_no_renov, 
				   _no_unidad, 
				   _cod_producto, 
				   _nombre with resume;
		end if	
	END FOREACH
END FOREACH



--return 0, "actualizacion exitosa";
END PROCEDURE	  