-- poner monto_pagado en cero para cuando no hay disponible y actaulizar las requis desautorizadas
--drop procedure sp_rec76d;

create procedure sp_rec76d(a_user char(8))
returning integer;

define _no_requis		char(10);
define _transaccion     char(10);
define _nombre			char(100);
define _monto_chqchrec  dec(16,2);
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _user_added      char(8);


SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

update chqchequ
   set monto_disponible = 0,
       correo_aviso     = 0,
	   fecha_libdisp    = current,
	   user_libdisp		= a_user
 where cod_banco    = _cod_banco
   and cod_chequera = _cod_chequera;

foreach
 select	no_requis,
		user_added
   into	_no_requis,
		_user_added
   from	chqchmae
  where pagado        = 0
	and anulado       = 0
	and origen_cheque = "3"
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma	  = 0
    and autorizado    = 0

	 foreach
		select monto,
		       transaccion
		  into _monto_chqchrec,
		       _transaccion
		  from chqchrec
		 where no_requis          = _no_requis
		   and aumenta_disponible = 1

		update chqchequ
		   set monto_disponible = monto_disponible + _monto_chqchrec
		 where cod_banco 	= _cod_banco
		   and cod_chequera = _cod_chequera;

	 end foreach

	update chqchmae
	   set autorizado     = 1,
		   autorizado_por = _user_added
	 where no_requis 	  = _no_requis;

end foreach

return 0;
end procedure
