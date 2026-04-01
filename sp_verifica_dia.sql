--- Actualizar el codigo de tipo de tarifa a las nuevas y renovadas
--- Creado 28/07/2014 por Armando Moreno

drop procedure sp_verifica_dia;

create procedure "informix".sp_verifica_dia()
returning integer,integer,char(20);

begin

define _documento	  	char(20);
define _no_poliza       char(10);
define _dia,_dia_poliza integer;


--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;


foreach

	select no_documento,
	       dia
	  into _documento,
	       _dia
	  from cobtacre

	let _no_poliza = sp_sis21(_documento);
	 
	select dia_cobros1
	  into _dia_poliza
	  from emipomae
	 where no_poliza = _no_poliza;


	if _dia <> _dia_poliza then
				
		return _dia,_dia_poliza,_documento with resume;
	end if

end foreach
end 

end procedure;
