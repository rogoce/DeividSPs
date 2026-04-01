--drop procedure sp_sis39;

create procedure "informix".sp_sis190()
returning char(7);

DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _contador          SMALLINT;

DEFINE a_fecha            date;

let a_fecha = current;

FOR _contador = 1 TO 5
	LET _ano_contable = YEAR(a_fecha);

	IF MONTH(a_fecha) < 10 THEN
		LET _mes_contable = '0' || MONTH(a_fecha);
	ELSE
		LET _mes_contable = MONTH(a_fecha);
	END IF

	LET _periodo = _ano_contable || '-' || _mes_contable;

	return _periodo with resume;

    let a_fecha = a_fecha + 1 UNITS MONTH;

END FOR

end procedure