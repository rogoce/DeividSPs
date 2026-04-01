-- Procedimiento para crea los datos iniciales para el prespuesto de zonas de cobros
--
-- Creado    : 12/10/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob291;

create procedure "informix".sp_cob291(a_cod_division char(1))
returning integer,
	      char(50);

define _cantidad	smallint;
define _ano			smallint;
define _mes			smallint;
define _periodo		char(7);

let _ano = year(today);

select count(*)
  into _cantidad
  from cobpredi
 where cod_division = a_cod_division
   and periodo[1,4]	= _ano;

if _cantidad = 0 then

	for _mes = 1 to 12

		if _mes < 10 then
			let _periodo = _ano || "-0" || _mes;
		else
			let _periodo = _ano || "-" || _mes;
		end if		

		insert into cobpredi
		values (a_cod_division, _periodo, 0.00);

	end for

end if

return 0, "Actualizacion Exitoza";

end procedure
