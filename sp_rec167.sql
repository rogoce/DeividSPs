-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec167;

create procedure sp_rec167()
returning char(20),
          date,
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(50);

define _fecha_inicio	date;
define _fecha_final     date;
define _fecha_reclamo	date;
define _cantidad		smallint;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _monto			dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _perd_total      smallint;
define _perdida         char(1);

define _error			integer;
define _error_desc		char(50);

let _fecha_inicio = MDY(1,1,2009);
let _fecha_final  = MDY(12,31,2009);

set isolation to dirty read;

let _error = 0;

foreach
 select	fecha_reclamo,
        no_reclamo,
		numrecla,
		no_poliza,
		perd_total
   into	_fecha_reclamo,
        _no_reclamo,
		_numrecla,
		_no_poliza,
		_perd_total
   from recrcmae
  where fecha_reclamo  >= _fecha_inicio
    and fecha_reclamo  <= _fecha_final
	and actualizado    = 1
 --	and today - fecha_reclamo > 90

    if _perd_total is null then
		let _perd_total = 0;
	end if

    if _perd_total = 1 then
	   	continue foreach;
		let _perdida = "S";
	else
		let _perdida = "";
	end if

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

--	if _cod_ramo <> "018" then
--		continue foreach;
--	end if

	if _cod_ramo not in ("002", "020") then
		continue foreach;
	end if

	-- Ramos Patrimoniales

 {	if _cod_ramo in ("006", "009", "015") then
		continue foreach;
	end if

	if _cod_ramo    = "015" and
	   _cod_subramo = "008" then
		continue foreach;
	end if

--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
-- 	Modificado por Demtrio Hurtado

--	if _cod_ramo in ("002", "020") then
--		continue foreach;
--	end if
 }
 	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran in ("001","002")
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if

	if _reserva = 0.00 then
   --		continue foreach;
	end if
 
	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran <> "001"
	   and fecha - _fecha_reclamo <= 90;

	if _cantidad = 0 then
			
		let _monto = 0;

		select sum(monto)
		  into _monto
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1
		   and cod_tipotran = "004"
		   and fecha - _fecha_reclamo > 90;

        if _monto is null then
			let _monto = 0;
		end if

     	if _monto = 0 then
			continue foreach;
		end if

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		return _numrecla,
		       _fecha_reclamo,
			   _monto,
			   _reserva,
			   _perdida,
			   _nombre_ramo
			   with resume;
	end if

end foreach

{return "",
       "",
	   0,
	   0,
	   0.00,
	   ""
	   with resume;}

end procedure