-- Procedure que verifica que todos los reclamos tengan su transaccion inicial

-- Creado    : 08/11/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par118;

create procedure sp_par118() 
returning char(20),
          char(7),
          char(10),
          smallint;

define _no_reclamo	char(10);
define _cantidad	smallint;
define _numrecla	char(20);
define _periodo		char(7);

define _no_tranrec	char(10);
define _cant		smallint;
define _transaccion	char(10);

--set debug file to "sp_par118.trc";
--trace on;

foreach
 select no_reclamo,
        numrecla,
		periodo
   into _no_reclamo,
        _numrecla,
		_periodo
   from recrcmae
  where actualizado   = 1
	and numrecla[1,2] = "02"
--	and numrecla      = "02-0504-00675-01"

	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "001"
	   and actualizado  = 1;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad <> 1 then

{
		if _cantidad > 1 then
			
			let _cant = 0;

			foreach
			 select no_tranrec,
					transaccion
			   into _no_tranrec,
			        _transaccion
			   from rectrmae
			  where no_reclamo   = _no_reclamo
			    and cod_tipotran = "001"
				and actualizado  = 1
			  order by transaccion

				let _cant = _cant + 1;

				if _cant > 1 then

					update rectrmae
					   set cod_tipotran = "002"
					 where no_tranrec   = _no_tranrec;

				end if

			end foreach
			   
		end if
--}
		
		return _numrecla,
		       _periodo,
			   _no_reclamo,
			   _cantidad
			   with resume;

	end if

end foreach

return "0",
       "",
	   "",
	   0
	   with resume;

end procedure