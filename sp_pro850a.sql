-- Renovacion automatica, dw de tabla emideren(detalle de excepciones de la poliza)

-- Creado    : 15/04/2009 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro850a;

CREATE PROCEDURE "informix".sp_pro850a()
returning integer;					   --error

define _cnt,_cnt2	    	integer;
define _tipo_ramo    		char(1);
define _no_poliza           char(10);



SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro850.trc";
--trace on;

   foreach

	   select no_poliza
	     into _no_poliza
	     from emirepo
		where no_documento[1,2] = '02'
		  and estatus = 2

		SELECT count(*)
		  INTO _cnt
		  FROM emideren
		 WHERE no_poliza = _no_poliza
		   AND renglon   = 62;

	  select count(*)
	    into _cnt2
	    from emipocob
	   where no_poliza = _no_poliza
	     and cod_cobertura in("01200");

      if _cnt = 1 and _cnt2 > 0 then

		delete from emideren
		where no_poliza = _no_poliza
		  and renglon = 62;

		update emirepo
		   set user_added = 'AUTOMATI',
		       estatus    = 1
         where no_poliza  = _no_poliza;

	  end if

   end foreach

return 0;

END PROCEDURE
