-- Diferencia en reclamos

drop procedure sp_par260;

create procedure "informix".sp_par260()
returning char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(7),
          char(3),
          smallint,
          smallint;

define _no_tranrec	char(10);
define _transaccion	char(10);
define _monto1		dec(16,2);
define _monto2		dec(16,2);
define _cantidad	smallint;
define _periodo		char(7);
define _variacion	dec(16,2);
define _cod_tipo	char(3);
define _no_reclamo	char(10);
define _cant_coas	smallint;
define _cant_reas	smallint;

foreach
 select no_tranrec,
        transaccion,
        monto,
		periodo,
		variacion,
		cod_tipotran,
		no_reclamo
   into _no_tranrec,
        _transaccion,
        _monto1,
		_periodo,
		_variacion,
		_cod_tipo,
		_no_reclamo
   from rectrmae
  where periodo      >= "2007-07"
    and actualizado  = 1
	and sac_asientos = 2
	and cod_tipotran not in ("012", "013") -- Declinar Reclamos
  order by periodo, cod_tipotran, transaccion

	if _monto1    = 0 and
	   _variacion = 0 then
	   continue foreach;
	end if

	select count(*)
	  into _cant_coas
	  from reccoas
	 where no_reclamo   =  _no_reclamo
	   and cod_coasegur <> "036";
	   
	select count(*)
	  into _cant_reas
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato <> 1;

	select count(*)
	  into _cantidad
	  from recasien
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then

		-- Salvamentos, Recuperos, Deducibles

		if _cod_tipo in ("005", "006", "007") then 
			if _cant_coas = 0 and 
			   _cant_reas = 0 then
			   continue foreach;
			end if
		end if

		-- Aumento de Reserva

		if _cod_tipo in ("002") then 
			if _variacion = 0 then
			   continue foreach;
			end if
		end if

		return _no_tranrec,
		       _monto1,
			   0,
			   0,
			   _periodo,
			   _cod_tipo,
			   _cant_coas,
			   _cant_reas
			   with resume;

	end if	

{
	select sum(debito + credito)
	  into _monto2
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta     like "541%"
	   and tipo_comp  = 2;

	if _monto2 is null then
		let _monto2 = 0;
	end if

	return _transaccion,
	       _monto1,
		   _monto2,
		   (_monto2 - _monto1),
		   _periodo
		   with resume;

}

end foreach

return "",
       0,
	   0,
	   0,
	   "",
	   "",
	   0,
	   0
	   with resume;

end procedure