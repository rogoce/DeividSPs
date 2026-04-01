-- Modificado Armando Moreno	12/10/2004

--Procedimiento para borrar los endosos y polizas no act. mayores de 90 dias.
--Ademas, actualiza los endosos y las polizas no act. con periodo menor al cerrado con el periodo nvo.
--Este procedure es llamado desde el programa cierre de prod.

drop procedure sp_sis61a;
create procedure sp_sis61a(a_periodo_ant char(7), a_periodo_act char(7)
) returning integer,char(10);

define _error			integer;
define _fecha_hoy 		date;
define _no_poliza 		char(10);
define _no_endoso 		char(10);

BEGIN
ON EXCEPTION SET _error
	return _error,_no_poliza;
end exception

let _fecha_hoy = sp_sis26();

--set debug file to "sp_sis61a.trc";
--trace on;
--return 0,"";
foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where (_fecha_hoy - date_added) >= 90
    and actualizado = 0

	if _no_poliza = "503401" or _no_poliza = "600967"  or _no_poliza = "3069695" or _no_poliza = "3119342" then
		continue foreach;
	end if
		

	DELETE FROM endeddes WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedrec WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedimp WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunide WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunire WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde2 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedacr WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoaut WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotrd WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotra WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcuend WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobde WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedcob WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcoama WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	-- Tablas no Tienen Instrucciones Insert
	DELETE FROM endasien WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endbenef WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endeduni WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	DELETE FROM emifafac WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM emifacon WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endedhis WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedmae WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	if _no_endoso = "00000" then

		DELETE FROM emireagf WHERE no_poliza = _no_poliza;
		DELETE FROM emireagc WHERE no_poliza = _no_poliza;
		DELETE FROM emireagm WHERE no_poliza = _no_poliza;

		DELETE FROM emireafa WHERE no_poliza = _no_poliza;
		DELETE FROM emireaco WHERE no_poliza = _no_poliza;
		DELETE FROM emireama WHERE no_poliza = _no_poliza;

	end if

end foreach

foreach
 select no_poliza
   into _no_poliza
   from emipomae
  where (_fecha_hoy - date_added) >= 90
    and actualizado = 0

	if _no_poliza in("503401","3119342") then
		continue foreach;
	end if

	DELETE FROM emiciara WHERE no_poliza = _no_poliza;
	DELETE FROM emicoama WHERE no_poliza = _no_poliza;
	DELETE FROM emicoami WHERE no_poliza = _no_poliza;
	DELETE FROM emidirco WHERE no_poliza = _no_poliza;
	DELETE FROM emipoagt WHERE no_poliza = _no_poliza;
	DELETE FROM emipolde WHERE no_poliza = _no_poliza;
	DELETE FROM emipolim WHERE no_poliza = _no_poliza;
	DELETE FROM emiporec WHERE no_poliza = _no_poliza;
	DELETE FROM emirepol WHERE no_poliza = _no_poliza;
	DELETE FROM emirenoh WHERE no_poliza = _no_poliza;
	DELETE FROM emiprede WHERE no_poliza = _no_poliza;
	DELETE FROM emiderec WHERE no_poliza = _no_poliza;
	DELETE FROM emidepen WHERE no_poliza = _no_poliza;
	DELETE FROM emihcmd  WHERE no_poliza = _no_poliza;
	DELETE FROM emihcmm  WHERE no_poliza = _no_poliza;
	DELETE FROM emipode1 WHERE no_poliza = _no_poliza;
	DELETE FROM emiglofa WHERE no_poliza = _no_poliza;
	DELETE FROM emigloco WHERE no_poliza = _no_poliza;
	DELETE FROM emireagf WHERE no_poliza = _no_poliza;
	DELETE FROM emireagc WHERE no_poliza = _no_poliza;
	DELETE FROM emireagm WHERE no_poliza = _no_poliza;
	DELETE FROM emifafac WHERE no_poliza = _no_poliza;
	DELETE FROM emifacon WHERE no_poliza = _no_poliza;
	DELETE FROM emiavan  WHERE no_poliza = _no_poliza;
	DELETE FROM emifigar WHERE no_poliza = _no_poliza;
	DELETE FROM emifian1  WHERE no_poliza = _no_poliza;
	DELETE FROM emipreas WHERE no_poliza = _no_poliza;
	DELETE FROM emiunide WHERE no_poliza = _no_poliza;
	DELETE FROM emitrand WHERE no_poliza = _no_poliza;
	DELETE FROM emitrans WHERE no_poliza = _no_poliza;
	DELETE FROM emiauto  WHERE no_poliza = _no_poliza;
	DELETE FROM emicupol WHERE no_poliza = _no_poliza;
	DELETE FROM emipoacr WHERE no_poliza = _no_poliza;
	DELETE FROM emibenef WHERE no_poliza = _no_poliza;
	DELETE FROM emiunire WHERE no_poliza = _no_poliza;
	DELETE FROM emipode2 WHERE no_poliza = _no_poliza;
	DELETE FROM emirepod WHERE no_poliza = _no_poliza;
	DELETE FROM emicobre WHERE no_poliza = _no_poliza;
	DELETE FROM emicobde WHERE no_poliza = _no_poliza;
	DELETE FROM emipocob WHERE no_poliza = _no_poliza;
	DELETE FROM recrcmae WHERE no_poliza = _no_poliza;
	DELETE FROM emipouni WHERE no_poliza = _no_poliza;
	DELETE FROM cobcampl WHERE no_poliza = _no_poliza;
	DELETE FROM emipomae WHERE no_poliza = _no_poliza;
end foreach

update emipomae 
   set periodo     =  a_periodo_act
 WHERE periodo     <= a_periodo_ant
   AND actualizado = 0
   and no_poliza <> '3119342';

update endedmae
   set periodo     =  a_periodo_act
 where periodo     <= a_periodo_ant
   and actualizado = 0
   and no_poliza <> '3119342';

end
let _no_poliza = "Exito...";

return 0,_no_poliza;

end procedure