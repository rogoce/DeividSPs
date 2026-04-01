-- Procedimiento que Reversa la Mayorizacion de una transaccion
-- 
-- Creado    : 25/11/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac75;		

create procedure "informix".sp_sac75(
a_no_tranrec	char(10)
) returning integer,
            char(50);

define _cantidad	smallint;
define _no_trx		integer;
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _sac_asien	smallint;

begin work;

select sac_asientos 
  into _sac_asien
  from rectrmae
 where no_tranrec = a_no_tranrec;

if _sac_asien <> 2 then
	rollback work;
	return 1, "Esta Transaccion No Esta Mayorizada";
end if

foreach
 select sac_notrx,
        cuenta,
		debito,
		credito
   into _no_trx,
        _cuenta,
		_debito,
		_credito
   from recasien
  where no_tranrec = a_no_tranrec

	if _no_trx is null then
		rollback work;
		return 1, "No Existe Numero de Transaccion con SAC";
	end if

	select count(*)
	  into _cantidad
	  from cglresumen
	 where res_notrx  = _no_trx
	   and res_cuenta = _cuenta;
	   
	if _cantidad = 0 then
		rollback work;
		return 1, "No Existen Registros en cglresumen";
	end if

 	update cglresumen
	   set res_debito  = res_debito  - _debito,
	       res_credito = res_credito + _credito
	 where res_notrx   = _no_trx
	   and res_cuenta  = _cuenta;

end foreach

update rectrmae
   set sac_asientos = 0
 where no_tranrec   = a_no_tranrec;

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure