

create procedure sp_cob213(
a_no_remesa		char(10)
) returning smallint,
            char(50);

define _renglon		smallint;
define _monto_calc	dec(16,2);

foreach
 select renglon
   into _renglon
   from cobredet
  where no_remesa = a_no_remesa

	select sum(monto_man)
	  into _monto_calc
	  from cobreagt
	 where no_remesa = a_no_remesa
	   and renglon   = _renglon;

	if _monto_calc is null then
		let _monto_calc = 0.00;
	end if

	update cobredet
	   set monto_descontado = _monto_calc
	 where no_remesa        = a_no_remesa
	   and renglon          = _renglon;

end foreach


return 0, "Actualizacion Exitosa";

end procedure