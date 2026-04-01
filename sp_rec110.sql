drop procedure sp_rec110;

create procedure "informix".sp_rec110()
returning char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
		  dec(16,2),
		  char(10),
		  dec(16,2);

define _numrecla	char(20);
define _variacion	dec(16,2);
define _variacion2	dec(16,2);
define _variacion3	dec(16,2);
define _variacion4	dec(16,2);
define _transaccion	char(10);
define _monto		dec(16,2);


foreach 
 select reclamo,
        reserva,
		transaccion,
		monto
   into _numrecla,
        _variacion,
		_transaccion,
		_monto
   from respen0512
  --where disminuir = 0

--{
	select sum(variacion)
	  into _variacion4
	  from rectrmae
	 where numrecla    = _numrecla
	   and actualizado = 1
	   and periodo     <= "2005-12";
--}  
	select sum(variacion)
	  into _variacion2
	  from rectrmae
	 where numrecla    = _numrecla
	   and actualizado = 1
	   and periodo     > "2005-12"
	   and transaccion <> _transaccion;

	select sum(variacion)
	  into _variacion3
	  from rectrmae
	 where numrecla    = _numrecla
	   and actualizado = 1;

	if _variacion is null then
		let _variacion = 0;
	end if

	if _variacion2 is null then
		let _variacion2 = 0;
	end if

	if _variacion3 is null then
		let _variacion3 = 0;
	end if

	if _variacion4 is null then
		let _variacion4 = 0;
	end if

{
	update respen0512
	   set reserva = _variacion4
	 where reclamo = _numrecla;
--}
	return _numrecla,
	       _variacion4,
		   _variacion2,
		   _variacion3,
		   _variacion,
		   _transaccion,
		   _monto
		   with resume;

end foreach

end procedure
