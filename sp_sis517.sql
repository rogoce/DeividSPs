--Determina la vigencia inicial para una poliza de salud
--Creado: 03/04/2025   Armando Moreno M.

DROP PROCEDURE sp_sis517;
CREATE PROCEDURE sp_sis517(a_periodo char(7),a_vig_ini date)
RETURNING DATE;

DEFINE _no_poliza		CHAR(10);
DEFINE _vigencia_ruta	DATE;
DEFINE _vigencia_hasta	DATE;
define _ano_contable,_ano    smallint;

SET ISOLATION TO DIRTY READ;

let _ano_contable = a_periodo[1,4];
let _vigencia_hasta = sp_sis36(a_periodo);
let _vigencia_ruta = MDY(month(a_vig_ini), day(a_vig_ini), _ano_contable);
if _vigencia_ruta <= _vigencia_hasta then	--Si es <= Se usa esa misma.
else
	--Se resta 1 año y se arma la variable de la vigencia.
	let _ano = _ano_contable - 1;
	let _vigencia_ruta = MDY(month(a_vig_ini), day(a_vig_ini), _ano);	
end if

RETURN _vigencia_ruta;

END PROCEDURE 
