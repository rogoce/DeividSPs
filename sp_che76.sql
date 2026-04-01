drop procedure sp_che76;

create procedure sp_che76()
returning smallint,
          smallint,
		  char(50),
		  dec(16,2);

define _ano			smallint;
define _mes			smallint;
define _ramo		char(50);
define _monto		dec(16,2);
define _no_requis	char(10);
define _transaccion	char(10);
define _no_reclamo	char(10);
define _no_poliza	char(10);
define _cod_ramo	char(3);
define _nombre		char(50);
define _numrecla	char(20);

define _error		integer;
define _cantidad	integer;

create temp table tmp_cheque(
ano		smallint,
mes		smallint,
ramo	char(50),
monto	dec(16,2)
) with no log;

begin 
on exception set _error
	return _error, 0, _transaccion || "-" || _no_requis, 0;
end exception


foreach
 select year(fecha_impresion), 
        month(fecha_impresion),
		no_requis
   into	_ano,
        _mes,
		_no_requis
   from chqchmae
  where pagado           = 1
    and anulado          = 0
    and fecha_impresion >= "01/07/2006"
    and fecha_impresion < "01/09/2007"

	foreach
	 select transaccion,
	        monto,
			numrecla
	   into	_transaccion,
	        _monto,
			_numrecla
	   from chqchrec
	  where	no_requis = _no_requis

		select count(*)
		  into _cantidad
		  from rectrmae
		 where transaccion = _transaccion;

		if _cantidad > 1 then

			select no_reclamo
			  into _no_reclamo
			  from rectrmae
			 where transaccion = _transaccion
			   and no_requis   = _no_requis
			   and numrecla    = _numrecla;

		else

			select no_reclamo
			  into _no_reclamo
			  from rectrmae
			 where transaccion = _transaccion;

		end if

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre
		  from prdramo
		 where cod_ramo = _cod_ramo;
		

		insert into tmp_cheque
		values (_ano, _mes, _nombre, _monto);

	end foreach

end foreach

foreach
 select ano,
        mes,
		ramo,
		sum(monto)
   into _ano,
        _mes,
		_ramo,
		_monto
   from tmp_cheque
  group by 1, 2, 3
  order by 1, 2, 3

	return _ano,
	       _mes,
		   _ramo,
		   _monto
		   with resume;

end foreach

end

drop table tmp_cheque;
 
end procedure