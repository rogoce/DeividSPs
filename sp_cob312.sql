-- Simulacion del Pago Adelantado de Comision - Reclamos
-- 
-- Creado     : 16/10/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob312;

create procedure "informix".sp_cob312()
returning char(20),
          char(7),
          dec(16,2);

define _no_documento		char(20);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _monto				dec(16,2);
define _fecha				date;
define _pagado          	smallint;
define _periodo				char(7);

set isolation to dirty read;

create temp table tmp_poliza(
no_documento	char(20),
periodo			char(7),
monto			dec(16,2)
) with no log;

foreach
 select no_documento
   into _no_documento
   from tmp_cobadeflu
  group by no_documento 
  order by no_documento 

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where no_documento = _no_documento
	    and actualizado  = 1

		foreach
		 select no_requis,
		        monto
		   into	_no_requis,
		        _monto
		   from rectrmae
		  where no_reclamo   = _no_reclamo
		    and cod_tipotran = "004"
			and actualizado  = 1

			select fecha_impresion,
			       pagado
			  into _fecha,
			       _pagado
			  from chqchmae
			 where no_requis = _no_requis;

			if _pagado is null then
				let _pagado = 0;
			end if

			if _pagado = 0 then
				continue foreach;
			end if

			let _periodo = 	sp_sis39(_fecha);

			if _periodo < "2011-09" then
				continue foreach;
			end if

			let _no_documento = "";

			insert into tmp_poliza
			values (_no_documento, _periodo, _monto);

		end foreach

	end foreach

end foreach

foreach
 select no_documento,
        periodo,
		sum(monto)
   into _no_documento,
        _periodo,
		_monto
   from tmp_poliza
  group by 1, 2
  order by 1, 2

	return _no_documento,
           _periodo,
		   _monto
		   with resume;

end foreach

drop table tmp_poliza;
			
return "",
	   "",
	   0
	   with resume;

end procedure
