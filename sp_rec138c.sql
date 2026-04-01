-- Control de Asignaciones. Reclamos de vida y Salud.  en mora
-- Creado    : 28/12/2009 - Autor: Armando Moreno.
DROP PROCEDURE sp_rec138c;
CREATE PROCEDURE "informix".sp_rec138c()
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
		  varchar(255),
		  char(3),
   		  char(50),
   		  char(50),
   		  dec(16,2);

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
define _obs_mora         varchar(255);
define _cod_tipopago     char(3);
define _cobra_poliza     char(1);

define _cod_agente		 char(5);
define _cobrador		 char(3);
define _nom_cobrador	 char(50);
define _nom_corredor     varchar(50);
define _valor            smallint;
define _saldo			 decimal(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec138.trc";
--trace on;

let _cantidad   = 0;
let _nom_corredor = "";
let _saldo = 0;

SELECT count(*)			--busca si hay pendientes.
  INTO _cantidad
  FROM atcdocde
 WHERE completado         = 0
   AND en_mora            = 1;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   let _valor = sp_rec138b();

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
			   monto,
			   obs_mora,
			   cod_tipopago
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
			   _obs_mora,
			   _cod_tipopago
		  FROM atcdocde
		 WHERE completado         = 0
		   AND en_mora            = 1
		 ORDER BY date_added

		let _no_poliza = sp_sis21(_no_documento);

		select cobra_poliza
		  into _cobra_poliza
		  from emipomae
		 where no_poliza = _no_poliza;

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

		SELECT nombre
	      INTO _nom_corredor
		  FROM agtagent
	     WHERE cod_agente = _cod_agente;

		select saldo
		  into _saldo
		  from tmp_s
		 where no_documento   = _no_documento
		   and cod_asignacion = _cod_asignacion;


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
			  _obs_mora,
			  _cod_tipopago,
			  _nom_cobrador,
			  _nom_corredor,
			  _saldo
			  with resume;
	end foreach
	drop table tmp_s;
else
--	return 1,"","","","","","","",0,"","",0;
end if


END PROCEDURE
