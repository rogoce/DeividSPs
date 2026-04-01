-- Procedimiento que calcula la Prima Devengada proveniente de la tabla Emiletra (montos pagados)
--01/02/2016
--Armando Moreno M.

--drop procedure sp_dev99;
create procedure sp_dev99()
 returning integer,
			char(50);
 
define _no_documento		char(20);
define _no_poliza			char(10);
define _colectivo,_colectiva char(1);

foreach
	select no_documento
	  into _no_documento
	  from deivid_bo:boindancon
	  
		let _no_poliza = sp_sis21(_no_documento);

		select colectiva
		  into _colectiva
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _colectiva = 'I' then
			let _colectivo = 'N';
		else
			let _colectivo = 'S';
		end if
		update deivid_bo:boindancon
		   set colectivo = _colectivo
		 where no_documento = _no_documento;  
		
end foreach

return 0, "Actualizacion Exitosa";

end procedure