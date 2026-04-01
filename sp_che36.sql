-- Procedimiento que Convierte de un Numero de Polizas de Ancon en uno de Ducruet

-- Creado    : 31/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_che05 - DEIVID, S.A.

drop procedure sp_che36;

create procedure "informix".sp_che36(a_no_documento char(20))
returning char(20);

define _no_documento char(20);

{
if a_no_documento[12,13] in ("51", "56") then

	if a_no_documento[3,4] >= "05" then

		if a_no_documento[6,7] = "20" then
			let _no_documento = a_no_documento[1,4] || "-0" || a_no_documento[6,6] || "-" || a_no_documento[7,20];
		else
			let _no_documento = a_no_documento;
		end if

	else
		let _no_documento = a_no_documento[1,7] || "-0" || a_no_documento[8,20];
	end if

else
	let _no_documento = a_no_documento;
end if
}

let _no_documento = a_no_documento;

return _no_documento;
 
end procedure