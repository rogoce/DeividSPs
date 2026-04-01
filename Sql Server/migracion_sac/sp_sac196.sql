-- Procedure que actualiza el comprobante 12-00311 afectacion al axuliar 26410

-- Creado    : 06/01/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_sac196;

create procedure sp_sac196()
returning integer,
          char(50);
          
define _linea		smallint;
define _auxiliar	char(5);
define _diferencia	dec(16,2);
define _cobros		dec(16,2);
define _debito		dec(16,2);
define _credito		dec(16,2);

define _cod_agente	char(10);
define _cantidad	smallint;

let _linea = 0;

--delete from cgltrx3
-- where trx3_notrx     = 145991
--   and trx3_lineatrx2 = 14;

foreach
 select	tercero,
        cobros,
		diferencia
   into _auxiliar,
        _cobros,
		_diferencia
   from deivid_tmp:tmp_26410

	let _cod_agente = "0" || _auxiliar[2,5];

	select count(*)
	  into _cantidad
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cantidad = 0 then

		return 1, "No Existe Agente " || _cod_agente with resume;

	else

		update agtagent
		   set saldo      = _cobros
	     where cod_agente = _cod_agente;

		return 0, "Agente " || _cod_agente || "Saldo " || _cobros with resume;


	end if

	{
	let _linea = _linea + 1;

	let _debito  = 0;
	let _credito = 0;

	if _diferencia >= 0 then
		let _debito  = _diferencia;
	else
		let _credito = _diferencia * -1;
	end if

	insert into cgltrx3
	values (
	       145991,
	       "01",
	       14,
	       _linea,
	       "26410",
		   _auxiliar,
		   _debito,
		   _credito,
		   0,
		   null
		   );
	}

end foreach

return 0, "Actualizacion Exitosa";

end procedure          
