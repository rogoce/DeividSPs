-- Procedure para aumentos de reserva para 2006-12

-- Creado:	06/10/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec136;

create procedure "informix".sp_rec136()
returning char(20),
          dec(16,2),
          dec(16,2);

define _numrecla	char(20);
define _ajuste		dec(16,2);
define _reserva		dec(16,2);
define _reserva_cob	dec(16,2);
define _cod_cober	char(5);
define _monto_cob	dec(16,2);

define _no_base		char(10);

define _no_reclamo	char(10);
define _no_tranrec	char(10);
define _cod_cliente	char(10);
define _transaccion	char(10);

define _fecha		date;
define _periodo		char(7);
 
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin work;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, 0.00, 0.00;
end exception

let _no_base = "321493";

let _fecha   = "31/12/2006";
let _periodo = sp_sis39(_fecha);

foreach
 select reclamo,
        reserva
   into _numrecla,
        _reserva
   from deivid_tmp:varaum0612
  order by reclamo

	select no_reclamo,
	       cod_asegurado
	  into _no_reclamo,
	       _cod_cliente
	  from recrcmae
	 where numrecla = _numrecla;
	 
	select *
	  from rectrmae
	 where no_tranrec = _no_base
	  into temp tmp_transac;

	let _no_tranrec  = sp_sis13("001", "REC", "02", "par_tran_genera");
	let _transaccion = sp_sis12("001", "001", _no_reclamo);

	update tmp_transac
	   set no_tranrec  = _no_tranrec,
	       no_reclamo  = _no_reclamo,
		   cod_cliente = _cod_cliente,
		   numrecla    = _numrecla,
		   transaccion = _transaccion,
		   monto       = _reserva,
		   variacion   = _reserva,
		   fecha       = _fecha,
		   periodo     = _periodo;
	    
	insert into rectrmae
	select *
	  from tmp_transac;

	drop table tmp_transac;
		 
	foreach
	 select cod_cobertura
	   into _cod_cober
	   from recrccob
	  where no_reclamo = _no_reclamo

		select *
		  from rectrcob
		 where no_tranrec = _no_base
		  into temp tmp_transac;

		update tmp_transac
		   set no_tranrec    = _no_tranrec,
		       cod_cobertura = _cod_cober,
			   monto         = _reserva,
			   variacion     = _reserva;

		insert into rectrcob
	    select *
		  from tmp_transac;

		drop table tmp_transac;

		exit foreach;

	end foreach 		

	return _numrecla,
	       _reserva,
		   _reserva
	       with resume;

end foreach

end 

commit work;
--rollback work;

return "0", 0.00, 0.00;

end procedure