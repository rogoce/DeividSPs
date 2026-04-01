-- Control de Asignaciones. Reclamos de vida y Salud.  en mora
-- Creado    : 28/12/2009 - Autor: Armando Moreno.
DROP PROCEDURE sp_rec138b;
CREATE PROCEDURE "informix".sp_rec138b()
returning integer;

define _cod_asignacion	 char(10);
define _no_documento	 char(20);
define _saldo			 decimal(16,2);
define _cnt              smallint;
define _cantidad         integer;

CREATE TEMP TABLE tmp_s
     (cod_asignacion    CHAR(10),
      no_documento   	CHAR(20),
      saldo             dec(16,2))
      WITH NO LOG;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec138b.trc";
--trace on;

let _cnt  = 0;

SELECT count(*)			--busca si hay pendientes.
  INTO _cantidad
  FROM atcdocde
 WHERE completado         = 0
   AND en_mora            = 1;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   foreach
		SELECT cod_asignacion,
			   no_documento
		  INTO _cod_asignacion,
			   _no_documento
		  FROM atcdocde
		 WHERE completado         = 0
		   AND en_mora            = 1
		 ORDER BY date_added

		select saldo
		  into _saldo
		  from emipoliza
		 where no_documento = _no_documento;

		select count(*)
		  into _cnt
		  from tmp_s
		 where no_documento = _no_documento;

		if _cnt = 0 then
		else
			let _saldo = 0.00;
		end if

		insert into tmp_s(cod_asignacion,no_documento,saldo)
		values(_cod_asignacion,_no_documento,_saldo);

	end foreach
end if

return 0;

END PROCEDURE
