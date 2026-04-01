-- Procedimiento que Reversa la Mayorizacion de un Endoso
-- 
-- Creado    : 25/11/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac72;		

create procedure "informix".sp_sac72(a_no_poliza char(10), a_no_endoso char(5)) 
returning integer,
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
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _sac_asien <> 2 then
	rollback work;
	return 1, "Esta Factura No Esta Mayorizada";
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
   from endasien
  where no_poliza = a_no_poliza
    and no_endoso = a_no_endoso

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

update endedmae
   set sac_asientos = 0
 where no_poliza    = a_no_poliza
   and no_endoso    = a_no_endoso;

delete from endasien
 where no_poliza    = a_no_poliza
   and no_endoso    = a_no_endoso;

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure