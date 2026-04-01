-- Renovacion automatica, dw de tabla emideren(detalle de excepciones de la poliza)

-- Creado    : 15/04/2009 - Autor: Armando Moreno.

DROP PROCEDURE ap_act_endedcob;

CREATE PROCEDURE "informix".ap_act_endedcob()
returning smallint, char(20);		   

define _no_documento	    char(20);
define _no_poliza		    char(10);
define _no_endoso		    char(5);
define _no_unidad		    char(5);
define _cod_cober		    char(5);
define _desc_limite1        varchar(50,0);
define _desc_limite2	    varchar(50,0);
define _orden_n             smallint;
define _ded_nn              dec(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro850.trc";
--trace on;

   foreach 
		SELECT no_documento
		  INTO _no_documento
		  FROM emicartasal5
		 WHERE periodo = '2023-03'
		 
		SELECT no_poliza,
		       no_endoso
		  INTO _no_poliza,
               _no_endoso
          FROM endedmae
         WHERE no_documento = _no_documento
           AND cod_endomov = '014'
           AND periodo = '2023-03';		   
	
        SELECT no_unidad
          INTO _no_unidad
          FROM endeduni
         WHERE no_poliza = _no_poliza
           AND no_endoso = _no_endoso;

        foreach
			select cod_cobertura,
				   desc_limite1,
				   desc_limite2,
				   orden,
				   deducible
			  into _cod_cober,
				   _desc_limite1,
				   _desc_limite2,
				   _orden_n,
				   _ded_nn
			  from emipocob
			 where no_poliza  = _no_poliza
			   and no_unidad  = _no_unidad
			 order by orden
		 
			UPDATE endedcob
			   SET desc_limite1 = _desc_limite1,
			       desc_limite2 = _desc_limite2,
				   deducible = _ded_nn
			WHERE no_poliza = _no_poliza
              AND no_endoso = _no_endoso 
			  AND no_unidad = _no_unidad
			  AND cod_cobertura = _cod_cober;
		end foreach 
		return 0, _no_documento with resume;
   end foreach
 END PROCEDURE
