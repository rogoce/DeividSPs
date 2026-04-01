-- Procedure que Verifica las 541 entre el Mayor y el auxiliar

-- Creado    : 01/07/2011 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rec185;

create procedure sp_rec185() 
returning char(10),
          dec(16,2),
          dec(16,2);

define _transaccion	char(10);
define _no_tranrec	char(10);
define _no_reclamo	char(10);
define _monto		dec(16,2);
define _monto2		dec(16,2);

DEFINE _cod_coasegur    CHAR(3);
DEFINE _porc_coas       DECIMAL;

set isolation to dirty read;

LET _cod_coasegur = sp_sis02("001", "001");

foreach
 select no_tranrec,
        transaccion,
		monto,
		no_reclamo
   into _no_tranrec,
        _transaccion,
		_monto,
		_no_reclamo
   from rectrmae
  where actualizado  = 1
    and periodo      = "2011-05"
	and cod_tipotran = "004"
--	and numrecla     = "02-0111-00170-10"

	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	LET _monto   = _monto   / 100 * _porc_coas;
	
	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta     like "541%";

	if _monto2 is null then
		let _monto2 = 0.00;
	end if

	if _monto <> _monto2 then

		return _transaccion,
		       _monto,
			   _monto2
			   with resume;

	end if

end foreach

return "0", 
       0,
	   0;

end procedure