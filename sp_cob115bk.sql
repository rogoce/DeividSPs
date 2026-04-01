-- Procedimiento que Genera los Recibos Automaticos para una o varias polizas. 	

-- Creado    : 27/06/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 14/07/2003 - Autor: Marquelda Valdelamar

--DROP PROCEDURE sp_cob115bk;

CREATE PROCEDURE "informix".sp_cob115bk(
)RETURNING DATE,DEC(16,2);       -- fecha cubierta


DEFINE _fecha_cubierta    DATE; 
DEFINE _vigencia_final    DATE;

DEFINE _prima_bruta       DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _calculo           DEC(16,2);

DEFINE _ramo_sis		  SMALLINT;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob144.trc";

let _calculo        = 0;
let _saldo          = 46.20;
let _prima_bruta    = 29.40;
let _vigencia_final = '24/06/2006';
let _ramo_sis = 5;
  	 
--Calculo de la Fecha Cubierta
  IF _prima_bruta is not null and _prima_bruta <> 0 THEN
  	If _ramo_sis = 5 Then
  		Let _calculo = (_saldo * 30) / _prima_bruta;
	Else
  		Let _calculo = (_saldo * 365) / _prima_bruta;
	End If
    Let _fecha_cubierta = _vigencia_final - _calculo;
  ELSE
	Let _fecha_cubierta = NULL;
  END IF


Return _fecha_cubierta,_calculo;

END PROCEDURE
