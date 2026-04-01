-- Fecha en cadena para la carta de avisos 
-- Creado    : 25/06/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_cob774;
CREATE procedure "informix".sp_cob774(a_fecha date)
RETURNING VARCHAR(50);

BEGIN
	
	DEFINE _fecha_letra         VARCHAR(50);
	DEFINE _dia           		CHAR(2);
	DEFINE _ano           		CHAR(4);
    DEFINE _fecha_actual	    DATE;	
	
	SET ISOLATION TO DIRTY READ;
    --let _fecha_actual = sp_sis26();
    let _fecha_actual = a_fecha;
	
	IF MONTH(_fecha_actual) = 1 THEN
	  LET _fecha_letra = 'ENERO';
	ELIF MONTH(_fecha_actual) = 2 THEN
	  LET _fecha_letra = 'FEBRERO';
	ELIF MONTH(_fecha_actual) = 3 THEN
	  LET _fecha_letra = 'MARZO';
	ELIF MONTH(_fecha_actual) = 4 THEN
	  LET _fecha_letra = 'ABRIL';
	ELIF MONTH(_fecha_actual) = 5 THEN
	  LET _fecha_letra = 'MAYO';
	ELIF MONTH(_fecha_actual) = 6 THEN
	  LET _fecha_letra = 'JUNIO';
	ELIF MONTH(_fecha_actual) = 7 THEN
	  LET _fecha_letra = 'JULIO';
	ELIF MONTH(_fecha_actual) = 8 THEN
	  LET _fecha_letra = 'AGOSTO';
	ELIF MONTH(_fecha_actual) = 9 THEN
	  LET _fecha_letra = 'SEPTIEMBRE';
	ELIF MONTH(_fecha_actual) = 10 THEN
	  LET _fecha_letra = 'OCTUBRE';
	ELIF MONTH(_fecha_actual) = 11 THEN
	  LET _fecha_letra = 'NOVIEMBRE';
	ELIF MONTH(_fecha_actual) = 12 THEN
	  LET _fecha_letra = 'DICIEMBRE';
	END IF
	
	LET _dia = DAY(_fecha_actual);
	LET _ano = YEAR(_fecha_actual);
	
	IF _dia < 10 THEN
		LET _dia = '0'|| _dia;	
	END IF
	
	LET _fecha_letra = 'PANAMA, '||TRIM(_dia)||' DE '||TRIM(_fecha_letra)||' DE '||TRIM(_ano);		
	
	return  _fecha_letra ;
END
END PROCEDURE;
