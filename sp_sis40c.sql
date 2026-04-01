-- Fianzas de cumplimiento promoci√≥n comercial   
-- 
-- Creado    : 25/11/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_sis40c;
CREATE procedure "informix".sp_sis40c(a_fecha date, a_cod_subramo char(3) default '*', a_tipo integer default 0)
RETURNING varchar(50);

BEGIN
	
	DEFINE v_fecha_letra        VARCHAR(50);
	DEFINE v_dia           		CHAR(2);
	DEFINE v_ano           		CHAR(4);
	
	
	SET ISOLATION TO DIRTY READ;

	IF MONTH(a_fecha) = 1 THEN
	  LET v_fecha_letra = 'Enero';
	ELIF MONTH(a_fecha) = 2 THEN
	  LET v_fecha_letra = 'Febrero';
	ELIF MONTH(a_fecha) = 3 THEN
	  LET v_fecha_letra = 'Marzo';
	ELIF MONTH(a_fecha) = 4 THEN
	  LET v_fecha_letra = 'Abril';
	ELIF MONTH(a_fecha) = 5 THEN
	  LET v_fecha_letra = 'Mayo';
	ELIF MONTH(a_fecha) = 6 THEN
	  LET v_fecha_letra = 'Junio';
	ELIF MONTH(a_fecha) = 7 THEN
	  LET v_fecha_letra = 'Julio';
	ELIF MONTH(a_fecha) = 8 THEN
	  LET v_fecha_letra = 'Agosto';
	ELIF MONTH(a_fecha) = 9 THEN
	  LET v_fecha_letra = 'Septiembre';
	ELIF MONTH(a_fecha) = 10 THEN
	  LET v_fecha_letra = 'Octubre';
	ELIF MONTH(a_fecha) = 11 THEN
	  LET v_fecha_letra = 'Noviembre';
	ELIF MONTH(a_fecha) = 12 THEN
	  LET v_fecha_letra = 'Diciembre';
	END IF

	LET v_dia = DAY(a_fecha);
	LET v_ano = YEAR(a_fecha);
	if v_dia < 10 then
		let v_dia = "0"||v_dia;
	end if
	if a_cod_subramo in('005','023','016') then
		if a_tipo = 5 then
			LET v_fecha_letra = TRIM(v_dia)||' dÌas del mes de '||TRIM(v_fecha_letra)||' de '||TRIM(v_ano);
		else
			LET v_fecha_letra = TRIM(v_dia)||' de '||TRIM(v_fecha_letra)||' de '||TRIM(v_ano);
		end if
	else
		LET v_fecha_letra = TRIM(v_dia)||' de '||TRIM(v_fecha_letra)||' de '||TRIM(v_ano);
	end if
		
	
	return  v_fecha_letra;
END
END PROCEDURE;