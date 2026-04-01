-- Procedimiento que Genera el Cheque para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 19/01/2006 - Autor: Amado Perez 
--             cuando se genere la comision, en el detalle debe aparecer 
--             desde la ultima fecha de comision si esta es menor que la
--             fecha desde se este generando la comision 

-- Modificado: 17/03/2006 - Autor: Demetrio Hurtado Almanza
--             Se separa la creacion de los registros contables y se incluyo en una rutina aparte que es la
--             sp_par205, que es la crea los registros contables de cheques de comisiones
-- 					  
-- Modificado: 25/02/2008 - Autor: Amado Perez
--             Se modifica la 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE ap_chqcomis;

CREATE PROCEDURE ap_chqcomis() RETURNING INTEGER; 

DEFINE _no_requis, _cod_agente		CHAR(10);

define _error			integer;
define _error_desc		char(50);


 --SET DEBUG FILE TO "sp_che06.trc"; 
 --TRACE ON;                                                                

BEGIN WORK;
BEGIN                                         

	ON EXCEPTION SET _error 
	    ROLLBACK WORK;
		RETURN _error;                                          
	END EXCEPTION                             

	-- Encabezado del Cheque

	FOREACH
		SELECT	no_requis,
				cod_agente
		  INTO  _no_requis,
				_cod_agente
		  FROM 	chqchmae
         WHERE 	origen_cheque in ('2','7')
           AND  fecha_captura = '17/10/2018'	
      ORDER BY  no_requis		   

		UPDATE chqcomis
		   SET no_requis   = _no_requis
		 WHERE cod_agente  = _cod_agente
		   AND fecha_desde = '10/10/2018'
 		   AND fecha_hasta = '16/10/2018'
		   AND fecha_genera = '17/10/2018';
 	END FOREACH 
END

COMMIT WORK;

RETURN 0;

END PROCEDURE;