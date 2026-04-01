-- Actualizacion del Monto de lo recuperado en los recuperos para subir a BO
-- 
-- Creado    : 13/06/2007 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_bo040;

CREATE PROCEDURE "informix".sp_bo040() 
returning integer,
          char(50);

define _no_recupero	char(10);
define _no_reclamo	char(10);
define _monto		dec(16,2);

set isolation to dirty read;

foreach
 select no_recupero,
        no_reclamo
   into _no_recupero,
        _no_reclamo
   from recrecup

	select sum(monto)
	  into _monto
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran = "006";

	if _monto is null then
		let _monto = 0.00;
	end if

	let _monto = _monto * -1;

	update recrecup
	   set monto_recuperado = _monto
	 where no_recupero      = _no_recupero;

end foreach

return 0, "Actualizacion Exitosa";

end procedure 