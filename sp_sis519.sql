--Procedimiento para saber si la póliza aplica o no para el pago por:
--Cancelada o Anulada
--Vigente y Motivo de No Renovación -039 Cese de Coberturas(Ley 12)
--Creado por: AMM 03/06/2025


DROP PROCEDURE sp_sis519;
CREATE PROCEDURE sp_sis519(a_no_documento CHAR(20), a_opc smallint default 0)
RETURNING CHAR(10);

define _cod_no_renov    char(3);
define _no_poliza       char(10);
define _estatus_poliza  smallint;

SET ISOLATION TO DIRTY READ;

select no_poliza
  into _no_poliza
  from emipoliza
 where no_documento = a_no_documento;

select estatus_poliza,
	   cod_no_renov
  into _estatus_poliza,
	   _cod_no_renov
  from emipomae
 where no_poliza = _no_poliza;

if a_opc = 0 then --Verifica todas las condiciones
	if _estatus_poliza in(2,4) OR (_estatus_poliza = 1 AND _cod_no_renov = '039') then
		return 1;
	end if
elif a_opc = 1 then
	if (_estatus_poliza = 1 AND _cod_no_renov = '039') then
		return 1;
	end if
elif a_opc = 2 then
	if _estatus_poliza in(2,4) then
		return 1;
	end if
end if
RETURN 0;

END PROCEDURE
                                                                                                                                                                                    