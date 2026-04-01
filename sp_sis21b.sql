--Procedimiento para hacer pruebas con cadenas

DROP PROCEDURE sp_sis21b;
CREATE PROCEDURE "informix".sp_sis21b(a_periodo CHAR(10))
RETURNING smallint;

DEFINE _placa      CHAR(10);
define _largo,i    integer;
define _saber      char(1);


SET ISOLATION TO DIRTY READ;


let a_periodo = trim(a_periodo);
let _largo = length(a_periodo);

if _largo >= 6 then
else
	RETURN 1;
end if

let _placa = a_periodo;

for i = 1 to _largo
    let _saber = a_periodo[1,1];
    IF _saber in('A','B','C','D','E','F','G','H','I','J','K','L','M','N','Ñ','O','P','Q','R','S','T','U','V','W','X','Y','Z') OR _saber in('0','1','2','3','4','5','6','7','8','9') then
		let a_periodo = trim(a_periodo[2,10]);
	ELSE
		RETURN 1;
	END IF
end for

RETURN 0;

END PROCEDURE;