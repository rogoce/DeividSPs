-- Procedure que verifica el contador de las preautorizaciones
-- Armando Moreno M.  15/01/2024

drop procedure sp_sis246;
create procedure sp_sis246()
returning integer,
          char(50);


define _valor_par,_no_aprobacion		char(15);

let _no_aprobacion = null;

select valor_parametro
  into _valor_par
 from parcont
where cod_parametro = 'par_aprob';

select max(no_aprobacion)
  into _no_aprobacion
 from recprea1
where date(fecha_solicitud) = today;

if _no_aprobacion is null then
	select max(no_aprobacion)
	  into _no_aprobacion
	 from recprea1
	where date(fecha_solicitud) = today - 1;
end if


if _no_aprobacion > _valor_par then

	update parcont
	   set valor_parametro = _no_aprobacion
	 where cod_parametro = 'par_aprob';

	return 0, "Actualizacion Exitosa";

else

	return 1, "Esta Ok";

end if

end procedure