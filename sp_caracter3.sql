-- Procedimiento para corregir los caracteres especiales a motor, chasis y vin
-- 
-- Creado    : 09/05/2011 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_caracter3;

create procedure "informix".sp_caracter3()
returning char(20),
          char(5),
		  char(30),
          char(30),
		  char(20),
		  char(5),
		  char(7);
		  	
define _no_poliza    char(10); 
define _no_endoso	 char(5);
define _no_factura   char(30);
define _resultado    char(30);
define _no_documento char(20);
define _no_unidad    char(5);

define _error_cod	integer;
define _error_isam	integer;
define _no_doc_ya	char(20);
define _no_motor    char(30);
define _cnt,_cnt2   integer;
define _no_unidad_ya char(5);
define _estatus_char char(7);
define _estatus      smallint;


create temp table tmp_co(
no_documento		char(20),
no_unidad			char(5),
no_motor			char(30),
no_motor_cor		char(30),
no_doc_ya           char(20),
no_unidad_ya        char(5),
estatus             char(7)
) with no log;

set isolation to dirty read;

--BEGIN WORK;

begin 

--SET DEBUG FILE TO "sp_caracter.trc"; 
--trace on;

let _resultado = "";

foreach

 select no_documento,
		no_unidad,
		no_motor,
		corregido
   into _no_documento,
	    _no_unidad,
		_no_motor,
		_resultado
   from attt

 let _resultado = trim(_resultado);
   	  	
 select count(*)
   into _cnt
   from emivehic
  where no_motor = _resultado;										
 																		
 if _cnt > 0 then														
																	
   foreach
		select no_poliza,
		       no_unidad
		  into _no_poliza,
		       _no_unidad_ya
		  from emiauto
		 where no_motor = _resultado

		select count(*)
		  into _cnt2
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad_ya;

		if _cnt2 = 0 then
			continue foreach;
		end if

	    select no_documento,
		       estatus_poliza
		  into _no_doc_ya,
		       _estatus
		  from emipomae
		 where no_poliza = _no_poliza;

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		elif _estatus = 2 then
			let _estatus_char = 'CANC';
		elif _estatus = 3 then			
			let _estatus_char = 'VENCIDA';
		end if

		select count(*)
		  into _cnt2
		  from tmp_co
		 where no_doc_ya    = _no_doc_ya
		   and no_unidad_ya	= _no_unidad_ya;

		if _cnt2 = 0 then
			insert into tmp_co(no_documento,no_unidad,no_motor,no_motor_cor,no_doc_ya,no_unidad_ya,estatus)
			values            (_no_documento,_no_unidad,_no_motor,_resultado,_no_doc_ya,_no_unidad_ya,_estatus_char);

			return _no_documento,_no_unidad,_no_motor,_resultado,_no_doc_ya,_no_unidad_ya,_estatus_char with resume;

		end if

   end foreach

 end if

end foreach;

end

end procedure;
