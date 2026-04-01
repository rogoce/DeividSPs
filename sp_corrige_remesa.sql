-- Armar ruta (AREA)
-- 
-- Creado    : 13/03/2001 - Autor: Armando Moreno M.
-- Modificado: 13/03/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_corrige_remesa;

CREATE PROCEDURE "informix".sp_corrige_remesa(a_no_remesa char(10)) 
       RETURNING	    SMALLINT,  	-- Orden1
						CHAR(5);



DEFINE _impuesto    	 dec(16,2);
DEFINE _prima_neta       dec(16,2);
DEFINE _renglon		  	 integer;

FOREACH
	 -- Lectura de Cobruter	
			SELECT impuesto,
				   prima_neta,
				   renglon
			  INTO _impuesto,
				   _prima_neta,
				   _renglon
			  FROM cobredet
			 WHERE no_remesa = a_no_remesa
			   AND tipo_mov = 'X'


			update cobredet
			   set impuesto   = _prima_neta,
			       prima_neta = _impuesto
			 where no_remesa  = a_no_remesa
			   and renglon    = _renglon;

END FOREACH;
return 0, 'Exito';
END PROCEDURE