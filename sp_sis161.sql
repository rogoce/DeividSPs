-- buscar estatus audiencia

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza

drop procedure sp_sis161;

create procedure "informix".sp_sis161()
returning  smallint,
           VARCHAR(20);	

DEFINE v_estatus_audiencia smallint;
DEFINE v_desc_estatus      VARCHAR(20);

FOR v_estatus_audiencia = 0 TO 8
    IF v_estatus_audiencia = 0 THEN
		LET v_desc_estatus = 'Perdido';
    ELIF v_estatus_audiencia = 1 THEN
		LET v_desc_estatus = 'Ganado';
    ELIF v_estatus_audiencia = 2 THEN
		LET v_desc_estatus = 'Por Definir';
    ELIF v_estatus_audiencia = 3 THEN
		LET v_desc_estatus = 'Proceso Penal';
    ELIF v_estatus_audiencia = 4 THEN
		LET v_desc_estatus = 'Proceso Civil';
    ELIF v_estatus_audiencia = 5 THEN
		LET v_desc_estatus = 'Apelacion';
    ELIF v_estatus_audiencia = 6 THEN
		LET v_desc_estatus = 'Resuelto';
    ELIF v_estatus_audiencia = 7 THEN
		LET v_desc_estatus = 'FUT - Ganado';
    ELIF v_estatus_audiencia = 8 THEN
		LET v_desc_estatus = 'FUT - Responsable';
	END IF

	return v_estatus_audiencia,
	       trim(v_desc_estatus) with resume;

END FOR


end procedure