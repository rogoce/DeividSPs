-- Informe para Listar las Cartera de P¢liza del Ramo Salud 
-- Creado    : 09-Julio-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.--.

DROP PROCEDURE sp_pro190;

 create procedure sp_pro190(a_ano CHAR(20), a_noendoso char(5))

returning 
		  
		  CHAR(20),  -- 3. Numero de Documento
	      CHAR(100), -- 4. Nombre del Asegurado
		  CHAR(5),	 --10. Unidad
		  CHAR(5);  --11. Numero de P¢liza interno
		 
		  
define _no_poluni         char(10);
define _no_poliza         char(10);
define _actualizado 	  smallint;
define _activo            smallint;
define _cod_cltdepe       char(10);
define _cod_cliente       char(10);
define _nombre_aseg	      char(100);
define _documento		  char(20);
define v_no_unidad	   	  char(5);
define _no_unidad	   	  char(5);
define _cod_asegurado     char(10);
define _no_documento      char(20);
define v_noendoso         char(5);
SET ISOLATION TO DIRTY READ;

LET v_noendoso = a_noendoso;



-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
 select no_poliza,
	    no_documento
  into  _no_poliza,
	    _no_documento
   from emipomae 
  where actualizado     = "1"
    and estatus_poliza  = "1"
--  and colectiva       = "C"
	and no_documento    = a_ano
{
		foreach
		 select no_unidad,
		        cod_asegurado
		   into v_no_unidad,
		        _cod_asegurado
		   from emipouni
		  where no_poliza      = _no_poliza
		    and activo         = 1

        select nombre
		  into _nombre_aseg
	   	  from cliclien 
		 where cod_cliente     = _cod_asegurado;
 }

foreach
		 select no_unidad,
		        cod_cliente,
				no_endoso
		   into v_no_unidad,	
		        _cod_asegurado,
				v_noendoso
		   from endeduni 
		  where no_poliza      = _no_poliza
	   --	    and activo         = 1
	     	   	and no_endoso      = a_noendoso

        select nombre
		  into _nombre_aseg
	   	  from cliclien 
		 where cod_cliente     = _cod_asegurado;
	   	  
		   	return  _no_documento,	   			-- 1. N£mero de Documento
					_nombre_aseg,	   			-- 2. Nombre del Asegurado
	  				v_no_unidad,    			-- 3. Unidad
					v_noendoso					-- 4. Numero de P¢liza Interno


			 with resume;
	   
	  end foreach;
 	end foreach;
end procedure;

		   