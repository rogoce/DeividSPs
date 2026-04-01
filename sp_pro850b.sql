-- Renovacion automatica, dw de tabla emideren(detalle de excepciones de la poliza)

-- Creado    : 15/04/2009 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro850b;

CREATE PROCEDURE "informix".sp_pro850b()
returning char(10),char(20);					   

define _cnt,_cnt2	    	integer;
define _tipo_ramo    		char(1);
define _no_poliza           char(10);
define _no_documento        char(20);



SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro850.trc";
--trace on;

   foreach

		select no_poliza,no_documento
		  into _no_poliza,_no_documento
		  from emirepo e
		 where e.user_added = 'JMILLER'
		   and e.estatus = 2

		SELECT count(*)
		  INTO _cnt
		  FROM emideren
		 WHERE no_poliza = _no_poliza
		   AND renglon   = 11;

      if _cnt = 0 then
	    { update emirepo
		    set user_added = 'AUTOMATI',
			    estatus    = 1
		  where no_poliza = _no_poliza;}
	     
		 return _no_poliza,_no_documento with resume;

	  end if

   end foreach


END PROCEDURE
