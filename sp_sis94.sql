-- Actualiza el campo subir_bo para las polizas y sus tablas relacionas cuando se actualiza el registro

-- Creado    : 07/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis94;

create procedure sp_sis94(a_no_poliza char(10), a_no_endoso char(5))
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

if a_no_endoso = "00000" then -- Es una Poliza

	update emipomae set subir_bo = 1 where no_poliza = a_no_poliza;
	update emipoagt set subir_bo = 1 where no_poliza = a_no_poliza;
	update emicoami set subir_bo = 1 where no_poliza = a_no_poliza;
	update emicoama set subir_bo = 1 where no_poliza = a_no_poliza;
	update emipouni set subir_bo = 1 where no_poliza = a_no_poliza;
	update emipocob set subir_bo = 1 where no_poliza = a_no_poliza;
	update emiauto  set subir_bo = 1 where no_poliza = a_no_poliza;
	update emiunide set subir_bo = 1 where no_poliza = a_no_poliza;

end if

update endedmae set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update endeduni set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update endedcob set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update endmoaut set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update endunide set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update endcoama set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;

update emifacon set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;
update emifafac set subir_bo = 1 where no_poliza = a_no_poliza and no_endoso = a_no_endoso;

-- Actualizacion del Campo de facultativo

call sp_pro340(a_no_poliza, a_no_endoso) returning _error, _error_desc;

-- Actualizacion del Campo de fronting
call sp_pro343(a_no_poliza, a_no_endoso) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc; 
end if	

end 

return 0, "Actualizacion Exitosa...";

end procedure