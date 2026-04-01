drop procedure sp_sac143;

create procedure sp_sac143()
returning integer,
          char(50);

define _auxiliar	char(5);
define _ajuste		dec(16,2);

define _debito		dec(16,2);
define _credito		dec(16,2);

define _linea		smallint;

let _linea = 0;

delete from sac:cgltrx3 where trx3_notrx = 53208;

foreach
 select auxiliar,
        ajuste
   into _auxiliar,
        _ajuste
   from deivid_tmp:ajusteagente

	let _linea = _linea + 1;

	let _debito  = 0;
	let _credito = 0;	


	if _ajuste > 0 then
		let _credito = _ajuste;
	else
		let _debito = _ajuste * -1;
	end if

	insert into sac:cgltrx3
	values (53208, "01", 1, _linea, "26410", _auxiliar, _debito, _credito, 0);	

end foreach

return 0, "Actualizacion Existosa " || _linea;

end procedure