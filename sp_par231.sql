-- Verificacion de Reservas para la actualizacion de reservas por maternidad
-- 
-- Creado    : 15/11/2006 - Autor: Demetrio Hurtado Almanza 
--

drop procedure sp_par231;

create procedure "informix".sp_par231()
returning char(10),
          date,
		  char(1),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(20),
		  char(8),
		  char(50);

define _numrecla	char(20);
define _no_reclamo	char(10);
define _monto		dec(16,2);
define _variacion	dec(16,2);
define _reserva		dec(16,2);
define _transaccion	char(10);
define _cerrar_rec	smallint;
define _fecha		date;
define _cerrar		char(1);
define _user_added	char(8);
define _user_ger	char(8);
define _error_cer	char(1);
define _cod_tipotran char(3);
define _nombre_tipo	char(50);

create temp table tmp_numrecla (
numrecla	char(20)
) with no log;

foreach
 select numrecla
   into _numrecla
   from deivid_tmp:varoslr0609
  where no_tranrec is not null

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	let _user_ger  = "";

	foreach 
	  select cerrar_rec,
			 user_added
	    into _cerrar_rec,
			 _user_added
		from rectrmae
	   where no_reclamo  = _no_reclamo
	     and actualizado = 1
	   order by fecha, transaccion

		if _user_added = "GERENCIA" then
			let _user_ger = _user_added;
		end if

		if _user_ger = "GERENCIA" then
			if _cerrar_rec = 1 then
				insert into tmp_numrecla
				values (_numrecla);
			end if
		end if

	end foreach

end foreach

foreach
 select numrecla
   into _numrecla
   from tmp_numrecla

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	let _reserva   = 0.00;
	let _user_ger  = "";
	let _error_cer = "";

	foreach 
	  select monto,
	         variacion,
			 transaccion,
			 cerrar_rec,
			 fecha,
			 user_added,
			 cod_tipotran
	    into _monto,
		     _variacion,
			 _transaccion,
			 _cerrar_rec,
			 _fecha,
			 _user_added,
			 _cod_tipotran
		from rectrmae
	   where no_reclamo  = _no_reclamo
	     and actualizado = 1
	   order by fecha, transaccion

		select nombre
		  into _nombre_tipo
		  from rectitra
		 where cod_tipotran = _cod_tipotran;

		let _reserva = _reserva + _variacion;
		let _cerrar = "";
		
		if _user_added = "GERENCIA" then
			let _user_ger = _user_added;
		end if

		if _user_ger = "GERENCIA" then
			if _cerrar_rec = 1 then
				let _error_cer = "*";
			end if
		end if

		if _cerrar_rec = 1 then
			let _cerrar = "C";
		end if

		return _transaccion,
		       _fecha,
			   _cerrar,
			   _monto,
			   _variacion,
			   _reserva,
			   _error_cer,
			   _numrecla,
			   _user_added,
			   _nombre_tipo
			   with resume;

	end foreach

end foreach

drop table tmp_numrecla;

end procedure