-- Obtener fecha mas 30 dias

-- Creado: 21/05/2018 - Autor: Federico Coronado
-- modificado: 14/04/2020 - Autor: Federico Coronado para los años que febrero tiene 29 días
-- SIS - Pagina Web .

drop procedure sp_web48bk;

create procedure "informix".sp_web48bk(a_fecha_hoy date, a_cod_producto char(5) default '')
returning date;

define fecha_final date;

if a_cod_producto = '01499' or a_cod_producto = '05409' or a_cod_producto = '05410' then
	if day(a_fecha_hoy) = 31 then
		let a_fecha_hoy = a_fecha_hoy - 1 units day;
	end if

	if month(a_fecha_hoy) in(1)  then
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
else
	
	
	let fecha_final   = a_fecha_hoy + 1 UNITS YEAR;
end if
return fecha_final;

end procedure