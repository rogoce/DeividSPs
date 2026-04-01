DROP procedure sp_pro73a;

 CREATE procedure "informix".sp_pro73a(a_compania CHAR(3),a_agencia CHAR(3))
   RETURNING CHAR(20),  --POLIZA
   			 CHAR(100),	--ASEGURADO
   			 CHAR(5),	--CERTIFICADO
   			 DEC,		--prima bruta
             CHAR(100),	--CONTRATANTE
             CHAR(30),	--CEDULA
			 char(5),   --cod_producto
			 char(50);  -- desc prod

---------------------------------------------------
---        DETALLE DE UNIDADES (Colectivo de Vida)- 
---  Armando Moreno - Agosto 2001 - AMM -----------
---  Ref. Power Builder - d_sp_pro35    -----------
---------------------------------------------------

BEGIN

DEFINE v_no_poliza                   CHAR(10);
DEFINE v_cod_aseg                    CHAR(10);
DEFINE v_no_documento                CHAR(20);
DEFINE v_contratante         		 CHAR(10);
DEFINE v_cod_ramo      				 CHAR(3);
DEFINE v_descripcion   				 CHAR(50);
DEFINE v_no_unidad                   CHAR(5);
DEFINE v_desc_nombre                 CHAR(100);
DEFINE v_desc_asegurado              CHAR(100);
DEFINE _prima_bruta		             DECIMAL(16,2);
define _cedula						 char(30);
define _cod_producto                 char(5);
define _cant						 integer;
define _desc_producto                varchar(50);
define _fecha                        date;
define v_filtros2					 varchar(255);

SET ISOLATION TO DIRTY READ;

LET _cant = 0;	
let _fecha = current;
CALL sp_pro03(a_compania,a_agencia,_fecha,'018;') RETURNING v_filtros2;

       SET ISOLATION TO DIRTY READ;

FOREACH
	  SELECT no_documento
	    INTO v_no_documento
	    FROM temp_perfil
	   WHERE seleccionado = 1
	   group by 1
	   ORDER BY 1

   let v_no_poliza = sp_sis21(v_no_documento);

   select count(*)
     into _cant
	 from emipouni
	where no_poliza = v_no_poliza;

   if _cant > 1 then

       SELECT cod_contratante
	     INTO v_contratante
    	 FROM emipomae
		where no_poliza = v_no_poliza;

       SELECT nombre
         INTO v_desc_nombre
         FROM cliclien
        WHERE cod_compania = a_compania
          AND cod_cliente  = v_contratante;

   else
	   	continue foreach;
   end if		

	foreach
      SELECT no_unidad,
      		 desc_unidad,
			 cod_asegurado,
			 prima_bruta,
			 cod_producto
        INTO v_no_unidad,
        	 v_descripcion,
			 v_cod_aseg,
			 _prima_bruta,
			 _cod_producto
        FROM emipouni
       WHERE no_poliza = v_no_poliza
	     and activo    = 1
		order by 1

       SELECT nombre,
			  cedula	
         INTO v_desc_asegurado,
			  _cedula
         FROM cliclien
        WHERE cod_compania = a_compania
          AND cod_cliente  = v_cod_aseg;

	   select nombre
	     into _desc_producto
		 from prdprod
		where cod_producto = _cod_producto;


     RETURN v_no_documento,
     		v_desc_asegurado,
	        v_no_unidad,
			_prima_bruta,
            v_desc_nombre,
			_cedula,
			_cod_producto,
			_desc_producto
            WITH RESUME;

    end foreach
end foreach
END
DROP TABLE temp_perfil;
END PROCEDURE;
