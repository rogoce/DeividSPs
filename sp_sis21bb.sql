--Procedimiento para hacer pruebas con cadenas

DROP PROCEDURE sp_sis21bb;
CREATE PROCEDURE "informix".sp_sis21bb(a_periodo date,a_periodo2 date)
RETURNING char(80);

DEFINE _periodo_char   CHAR(80);
DEFINE _periodo1     DATETIME YEAR TO MONTH;
DEFINE _periodo2     DATETIME YEAR TO MONTH;

SET ISOLATION TO DIRTY READ;

let _periodo1 = a_periodo;
let _periodo2 = a_periodo2;

let _periodo_char = _periodo2 - _periodo1;
LET _anos         = _periodo_char[1,5];

RETURN _periodo_char;

END PROCEDURE;