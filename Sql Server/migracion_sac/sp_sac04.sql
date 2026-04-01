-- Depuracion de Cuentas en el Modulo de Mayor General

-- Creado    : 20/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac04;

create procedure sp_sac04() 
returning smallint,
          char(50);

define _cuenta_ant	char(30);
define _cuenta_nue	char(30);
define _mov 		char(30);

define _error		smallint;

begin work;

begin
on exception set _error
	rollback work;
	return _error, "Error de Base de Datos";
end exception

foreach
 select cta_ant,
		cta_nue,
		mov
   into _cuenta_ant,
		_cuenta_nue,
		_mov
   from tmp_sac

--{
	if trim(_mov) = "MOV. NO" then

		update cgltrx2
		   set trx2_cuenta = _cuenta_nue
		 where trx2_cuenta = _cuenta_ant;

	end if

	if trim(_mov) = "ELIMINAR" then

		update cgltrx2
		   set trx2_cuenta = _cuenta_nue
		 where trx2_cuenta = _cuenta_ant;

		delete from cglcuentas
		 where cta_cuenta = _cuenta_ant;

	end if
--}

end foreach

end

commit work;

--rollback work;

return 0, "Actualizacion Exitosa";

end procedure