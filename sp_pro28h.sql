-- 2004 hacia atras ponerle motivo 022 para eliminar de emirepol.
-- Creado    : 26/04/2005 - Autor: Armando Moreno
--se incorpora la parte de emirepo (pool) 05/10/2011 Armando Moreno a solicitud de Juan Silva y verificado con Georgina.

DROP PROCEDURE sp_pro28h;

CREATE PROCEDURE "informix".sp_pro28h()
 RETURNING	integer,char(70);

DEFINE _no_poliza       CHAR(10);
define _cant			integer;
define _fecha           date;
define _cod_ramo        char(3);

SET ISOLATION TO DIRTY READ;

let _fecha = today;
let _cant = 0;

foreach

 SELECT no_poliza
   INTO _no_poliza
   FROM emirepol
  WHERE (_fecha - vigencia_final) >= 90

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

   if _cod_ramo = '008' then   --se excluye por instruccion de Gina 17/06/2011 segun correo.
		continue foreach;
   end if

 Update emipomae 
    Set cod_no_renov   = "022",
        fecha_no_renov = Today,
		user_no_renov  = "informix",
		no_renovar     = 1
  Where no_poliza      = _no_poliza;

 delete from emirepol
  where no_poliza = _no_poliza;

 delete from emideren
  where no_poliza = _no_poliza;

 delete from emirepo
  where no_poliza = _no_poliza;

 let _cant = _cant + 1;

end foreach

foreach

 SELECT no_poliza
   INTO _no_poliza
   FROM emirepo
  WHERE (_fecha - vigencia_final) >= 90
    and estatus not in(5,9)

 select cod_ramo
   into _cod_ramo
   from emipomae
  where no_poliza = _no_poliza;

 if _cod_ramo = '008' then   --se excluye por instruccion de Gina 17/06/2011 segun correo.
 	continue foreach;
 end if

 Update emipomae 
    Set cod_no_renov   = "022",
        fecha_no_renov = Today,
		user_no_renov  = "informix",
		no_renovar     = 1
  Where no_poliza      = _no_poliza;

 delete from emirepol
  where no_poliza = _no_poliza;

 delete from emideren
  where no_poliza = _no_poliza;

 delete from emirepo
  where no_poliza = _no_poliza;

end foreach

return 0, _cant || " Polizas marcadas para no Renovar y Borradas de emirepol";

END PROCEDURE
