drop procedure sp_dbg01;

create procedure sp_dbg01()
returning char(30);

define _cod_cliente	char(30);
define _cantidad	smallint;

set isolation to dirty read;

foreach
 select no_motor
   into _cod_cliente
   from recrcmae
  where no_motor is not null
  group by 1

	select count(*)
	  into _cantidad
	  from emivehic
	 where no_motor = _cod_cliente;

	if _cantidad = 0 then

		update recrcmae
		   set no_motor = null
		 where no_motor = _cod_cliente;

		return _cod_cliente
		       with resume;

	end if

end foreach

end procedure