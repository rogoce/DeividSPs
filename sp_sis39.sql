--drop procedure sp_sis39;

create procedure "informix".sp_sis39(a_fecha date)
returning char(7);

DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

return _periodo;

end procedure