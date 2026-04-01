-- Anterior al sp_rec126
-- Control de Asignaciones. Reclamos de vida y Salud.
-- Creado    : 06/08/2006 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec126;

CREATE PROCEDURE "informix".sp_rec126()
returning integer,
		  char(10),
		  char(20),
		  char(10),
		  char(10),
		  char(10),
		  char(100),
		  char(100),
		  dec(16,2),
		  char(10),
		  char(10),
		  smallint,
		  char(50),
		  datetime year to fraction(5);

define _cod_asignacion	 char(10);
define _date_added       datetime year to fraction(5);
define _cod_ajustador    char(3);
define _cantidad	     integer;
define _no_documento	 char(20);
define _cod_asegurado	 char(10);
define _cod_reclamante	 char(10);
define _cod_producto     char(5);
define _asegurado	     char(100);
define _ajustador	     char(50);
define _reclamante	     char(100);
define _producto         char(50);
define _no_poliza		 char(10);
define _suspenso		 smallint;
define _cod_entrada		 char(10);
define _no_unidad		 char(10);
define _monto			 decimal(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec126.trc";
--trace on;

let _cantidad   = 0;

SELECT count(*)			--busca si hay pendientes.
  INTO _cantidad
  FROM atcdocde
 WHERE ajustador_asignado = 1
   AND completado         = 0;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   foreach
		SELECT cod_asignacion,
			   date_added,
			   no_documento,
			   no_unidad,
			   cod_asegurado,
			   cod_reclamante,
			   cod_ajustador,
			   cod_entrada,
			   suspenso,
			   monto
		  INTO _cod_asignacion,
		       _date_added,
			   _no_documento,
			   _no_unidad,
			   _cod_asegurado,
			   _cod_reclamante,
			   _cod_ajustador,
			   _cod_entrada,
			   _suspenso,
			   _monto
		  FROM atcdocde
		 WHERE ajustador_asignado = 1
		   AND completado         = 0
		 ORDER BY date_added

		let _no_poliza = sp_sis21(_no_documento);

		SELECT nombre
		  INTO _asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		SELECT nombre
		  INTO _reclamante
		  FROM cliclien
		 WHERE cod_cliente = _cod_reclamante;

		SELECT nombre
		  INTO _ajustador
		  FROM recajust
		 WHERE cod_ajustador = _cod_ajustador;

		if _suspenso is null then
			let _suspenso = 0;
		end if

		if _monto is null then
			let _monto = 0;
		end if

	   return 0,
	   		  _cod_asignacion,
	   		  _no_documento,
			  _no_unidad,
			  _cod_asegurado,
			  _cod_reclamante,
			  _asegurado,
			  _reclamante,
			  _monto,
			  _no_poliza,
			  _cod_entrada,
			  _suspenso,
			  _ajustador,
			  _date_added
			  with resume;
	end foreach
else
--	return 1,"","","","","","","",0,"","",0;
end if


END PROCEDURE
