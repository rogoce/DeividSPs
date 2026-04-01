-- Procedimiento para buscar si existe la cedula en otro cliente
--
-- Creado    :18/03/2002 - Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec681;

CREATE PROCEDURE "informix".sp_rec681(
a_cedula   CHAR(30), 
a_cliente   CHAR(10))
RETURNING   INTEGER,			 -- _error
			CHAR(100)			 -- ls_motor

DEFINE li_estatus, _error				INTEGER;
DEFINE ls_cliente 						CHAR(10);
DEFINE ls_nombre						CHAR(100);

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_proe23.trc";      
--TRACE ON;                                                                     

LET _error = 0;

FOREACH
   SELECT cod_cliente,
          nombre
     INTO ls_cliente,
          ls_nombre 
     FROM cliclien
    WHERE cedula = a_cedula

   LET _error = 0;

   IF ls_cliente <> a_cliente THEN
	  LET _error = 1;
	  EXIT FOREACH;
   END IF

END FOREACH

RETURN _error, ls_nombre;

END

END PROCEDURE;