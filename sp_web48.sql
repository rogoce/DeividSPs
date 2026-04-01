-- Obtener fecha mas 30 dias

-- Creado: 21/05/2018 - Autor: Federico Coronado

-- SIS - Pagina Web .

drop procedure sp_web48;

create procedure "informix".sp_web48(a_fecha_hoy date)
returning date;

define fecha_final date;

if day(a_fecha_hoy) = 31 then
	let a_fecha_hoy = a_fecha_hoy - 1 units day;
end if

if month(a_fecha_hoy) = 1 then
	if day(a_fecha_hoy) = 29 then
		let a_fecha_hoy =  a_fecha_hoy - 1 units day;
	end if
	if day(a_fecha_hoy) = 30 then
		let a_fecha_hoy =  a_fecha_hoy - 2 units day;
	end if
	if day(a_fecha_hoy) = 31 then
		let a_fecha_hoy =  a_fecha_hoy - 3 units day;
	end if
end if

let fecha_final   = a_fecha_hoy + 1 units month;

return fecha_final;

end procedure