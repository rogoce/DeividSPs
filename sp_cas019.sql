drop procedure sp_cas019;

create procedure sp_cas019()
returning date,
          smallint;

define _fecha_ult_pro date;
define _dia			  int;

select fecha_ult_pro
  into _fecha_ult_pro
  from cobcobra
 where cod_cobrador = "009";

	let _dia = day(_fecha_ult_pro + 1);

return _fecha_ult_pro,
       _dia;

end procedure



