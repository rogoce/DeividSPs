-- Control de Asignaciones. Reclamos de vida y Salud.
-- Creado    : 06/08/2006 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec126bk;
CREATE PROCEDURE "informix".sp_rec126bk()
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
		  datetime year to fraction(5),
  		  char(50),
		  char(50),
		  char(2),
		  datetime year to fraction(5);

define _cod_asignacion	 char(10);
define _date_added       datetime year to fraction(5);
define _fecha_bloque	 datetime year to fraction(5);
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
define _cod_agente		 char(5);
define _cobrador		 char(3);
define _nom_cobrador	 char(50);
define _nombre_tipo		 char(50);
define _cobra_poliza     char(1);
define _cod_tipo         char(2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec126.trc";
--trace on;

let _cantidad   = 0;

SELECT count(*)			--busca si hay pendientes.
  INTO _cantidad
  FROM atcdocde
 WHERE completado = 0;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   foreach
		SELECT a.cod_asignacion,
			   a.date_added,
			   a.no_documento,
			   a.no_unidad,
			   a.cod_asegurado,
			   a.cod_reclamante,
			   a.cod_ajustador,
			   a.cod_entrada,
			   a.suspenso,
			   a.monto,
			   a.cod_tipo,
			   b.fecha
		  INTO _cod_asignacion,
		       _date_added,
			   _no_documento,
			   _no_unidad,
			   _cod_asegurado,
			   _cod_reclamante,
			   _cod_ajustador,
			   _cod_entrada,
			   _suspenso,
			   _monto,
			   _cod_tipo,
			   _fecha_bloque
		  FROM atcdocde a, atcdocma b
		 WHERE a.cod_entrada = b.cod_entrada
		   and a.completado        = 0
		   and a.ajustador_asignar = 1
		 ORDER BY b.fecha

		let _no_poliza = sp_sis21(_no_documento);

		select cobra_poliza
		  into _cobra_poliza
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_tipo
		  from recsatip
		 where cod_tipo = _cod_tipo;

	    FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			  EXIT FOREACH;
		END FOREACH

		SELECT cod_cobrador
		  INTO _cobrador
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		SELECT nombre 
		  INTO _nom_cobrador
		  FROM cobcobra
		 WHERE cod_cobrador = _cobrador ;

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

		IF _cobra_poliza = 'E' THEN

		  LET _nom_cobrador     = 'CALL CENTER'; 

		ELIF _cobra_poliza = 'G' THEN            

		  LET _nom_cobrador     = 'GERENCIA'; 

		ELIF _cobra_poliza = 'I' THEN            

		  LET _nom_cobrador     = 'INCOBRABLES'; 

		ELIF _cobra_poliza = 'T' THEN

		  LET _nom_cobrador     = 'TARJETA CREDITO'; 

		ELIF _cobra_poliza = 'H' THEN            

		  LET _nom_cobrador     = 'ACH'; 

		ELIF _cobra_poliza = 'P' THEN            

		  LET _nom_cobrador     = 'POR CANCELAR'; 

		ELIF _cobra_poliza = 'Z' THEN            

		  LET _nom_cobrador     = 'COASEGURO MINORITARIO';

		ELSE

			SELECT nombre 
			  INTO _nom_cobrador
			  FROM cobcobra
			 WHERE cod_cobrador = _cobrador ;

		END IF

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
			  _date_added,
			  _nom_cobrador,
			  _nombre_tipo,
			  _cod_tipo,
			  _fecha_bloque
			  with resume;
	end foreach
else
--	return 1,"","","","","","","",0,"","",0;
end if

END PROCEDURE
