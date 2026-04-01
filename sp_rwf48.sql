-- Consulta de Audiencia de un reclamo

-- Creado    : 28/04/2005 - Autor: Amado Perez M.
-- Modificado: 28/04/2005 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf48;

CREATE PROCEDURE sp_rwf48(a_no_reclamo CHAR(10))
RETURNING varchar(20);

define _estatus_audiencia	smallint;
define v_nombre		        varchar(20);

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;

LET _estatus_audiencia = 2;

FOREACH
 SELECT	estatus_audiencia
   INTO _estatus_audiencia
   FROM	recrcmae 
  WHERE no_reclamo = a_no_reclamo

IF _estatus_audiencia = 0 THEN
	LET v_nombre = "PERDIDO";
ELIF _estatus_audiencia = 1 THEN
	LET v_nombre = "GANADO";
ELIF _estatus_audiencia = 2 THEN
	LET v_nombre = "POR DEFINIR";
ELIF _estatus_audiencia = 3 THEN
	LET v_nombre = "PROCESO PENAL";
ELIF _estatus_audiencia = 4 THEN
	LET v_nombre = "PROCESO CIVIL";
ELIF _estatus_audiencia = 5 THEN
	LET v_nombre = "APELACION";
ELIF _estatus_audiencia = 6 THEN
	LET v_nombre = "RESUELTO";
ELIF _estatus_audiencia = 7 THEN
	LET v_nombre = "FUT - GANADO";
ELIF _estatus_audiencia = 8 THEN
	LET v_nombre = "FUT - RESPONSABLE";
END IF

RETURN  TRIM(v_nombre)
		WITH RESUME;

END FOREACH

END PROCEDURE;