-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure sp_borra_requis;

create procedure "informix".sp_borra_requis(_no_requis char(10))
returning integer,char(80);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

SET LOCK MODE TO WAIT;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--foreach

   {	select no_requis
	  into _no_requis
	  from chqchmae
	 where fecha_impresion = "14/08/2008"
	   and origen_cheque   = 8}


	  {	delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

		delete from chqchdes
		 where no_requis = _no_requis;

		delete from chqchrec
		 where no_requis   = _no_requis;

		delete from recunino
		 where no_requis = _no_requis;

		delete from chqchcta
		 where no_requis = _no_requis;

		delete from chqchmae
		 where no_requis = _no_requis; }

--end foreach
 DELETE FROM endeddes WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedrec WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedimp WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endunide WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endunire WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedde2 WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedacr WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endmoaut WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endmotrd WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endmotra WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endcuend WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endcobre WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endcobde WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedcob WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endcoama WHERE no_poliza =  '546311' AND no_endoso = _no_requis;

 -- Tablas no Tienen Instrucciones Insert
 DELETE FROM endmoage WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endmoase WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endcamco WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedde1 WHERE no_poliza =  '546311' AND no_endoso = _no_requis;

 DELETE FROM endeduni WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedmae WHERE no_poliza =  '546311' AND no_endoso = _no_requis;
 DELETE FROM endedhis WHERE no_poliza =  '546311' AND no_endoso = _no_requis;


return 0,"";

end

end procedure
