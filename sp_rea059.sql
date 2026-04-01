drop procedure sp_rea059;

create procedure "informix".sp_rea059()
returning char(10),
          smallint,
		  char(10);

define _no_remesa		char(10);
define _renglon			smallint;
define _no_registro		char(10);
define _no_poliza		char(10);
define _no_documento	char(20);

define _cantidad		smallint;
define _sin_asiento		smallint;

foreach
 select no_remesa,
        renglon
   into _no_remesa,
        _renglon
   from deivid_tmp:tmp_cobreaco_colvi
  group by 1, 2
  order by 1, 2

	select count(*)
	  into _cantidad
	  from sac999:reacomp
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cantidad = 0 then

		return _no_remesa,
		       _renglon,
			   null
			   with resume;

	else

		let _sin_asiento = 1;

		foreach
		 select no_registro,
		        no_poliza,
				no_documento
		   into _no_registro,
		        _no_poliza,
				_no_documento
		   from sac999:reacomp
		  where no_remesa = _no_remesa
		    and renglon   = _renglon

			select count(*)
			  into _cantidad
			  from sac999:reacompasie
			 where no_registro = _no_registro;

			if _cantidad <> 0 then
				let _sin_asiento = 0;
			end if

		end foreach

		if _sin_asiento = 1 then

			let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');

			insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
			values(_no_registro, 2, _no_poliza, null, _no_remesa, _renglon, null, _no_documento, 0, "30/09/2013", "2013-09");	

			return _no_remesa,
			       _renglon,
				   _no_registro
				   with resume;

		end if

	end if

end foreach

return "0", 0, null;

end procedure