
drop procedure sp_sis61;

create procedure "informix".sp_sis61(
a_no_poliza char(10), 
_no_endoso char(10)
) returning integer,
            char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _no_documento	char(20);

BEGIN
ON EXCEPTION SET _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_sis61.trc";
--trace on;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = a_no_poliza;

	DELETE FROM emipoliza WHERE no_documento = _no_documento;

	DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	-- Tablas no Tienen Instrucciones Insert
	DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endedhis WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

	DELETE FROM emireagf WHERE no_poliza = a_no_poliza;
	DELETE FROM emireagc WHERE no_poliza = a_no_poliza;
	DELETE FROM emireagm WHERE no_poliza = a_no_poliza;

	DELETE FROM emireafa WHERE no_poliza = a_no_poliza;
	DELETE FROM emireaco WHERE no_poliza = a_no_poliza;
	DELETE FROM emireama WHERE no_poliza = a_no_poliza;

end

return 0, "Actualizacion Exitosa";

end procedure

