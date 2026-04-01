-- Procedimiento para sacar el pago para una transaccion
--
-- 26/09/2025 - Autor: Armando Moreno M.

DROP PROCEDURE sp_sis70a;
CREATE PROCEDURE sp_sis70a(a_no_tranrec CHAR(10))
RETURNING smallint;

DEFINE _mes,_ano   smallint;
DEFINE _mes_char   char(2);
DEFINE _fecha  	   date;
define _periodo    char(7);

SET ISOLATION TO DIRTY READ;


let _fecha = current;
let _mes = month(_fecha);
let _ano = year(_fecha);

if _mes < 10 THEN
	let _mes_char = '0'||_mes;
ELSE
	let _mes_char = _mes;
end if
let _periodo = _ano||'-'||_mes_char;

update rectrmae
   set periodo = _periodo,
       fecha   = _fecha
 where no_tranrec = a_no_tranrec;
 
RETURN 0;

END PROCEDURE
