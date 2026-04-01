-- Procedure que elimina las reservas de maternidad a septiembre 2006

-- Creado:	06/10/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec131;

create procedure "informix".sp_rec131()
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

let _no_base = "292156";

let _fecha   = today;
let _periodo = sp_sis39(_fecha);

foreach
 select reclamo
   into _numrecla
   from deivid_tmp:varoslr0612
  order by reclamo

	select no_reclamo,
	       cod_asegurado
	  into _no_reclamo,
	       _cod_cliente
	  from recrcmae
	 where numrecla = _numrecla;
	 
	select sum(reserva_actual)
	  into _reserva
	  from recrccob
	 where no_reclamo = _no_reclamo; 	  	

	let _ajuste = _reserva;

	if _reserva >= _ajuste then

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
			   monto       = _ajuste,
			   variacion   = _ajuste * -1,
			   fecha       = _fecha,
			   periodo     = _periodo;
		    
		insert into rectrmae
		select *
		  from tmp_transac;

		update deivid_tmp:varoslr0612
		   set no_tranrec = _no_tranrec
		 where reclamo    = _numrecla;

		drop table tmp_transac;
		 
		foreach
		 select reserva_actual,
		        cod_cobertura
		   into _reserva_cob,
		        _cod_cober
		   from recrccob
		  where no_reclamo     = _no_reclamo
		    and reserva_actual > 0.00
		  order by reserva_actual desc

			select *
			  from rectrcob
			 where no_tranrec    = _no_base
			   and cod_cobertura = "00552"
			  into temp tmp_transac;

			if _ajuste > _reserva_cob then

				let _monto_cob = _reserva_cob;
				let _ajuste    = _ajuste - _reserva_cob;

			else

				let _monto_cob = _ajuste;
				let _ajuste    = 0.00;

			end if 		  
		  
			if _monto_cob > 0.00 then

				update tmp_transac
				   set no_tranrec    = _no_tranrec,
				       cod_cobertura = _cod_cober,
					   monto         = _monto_cob,
					   variacion     = _monto_cob * -1;

				insert into rectrcob
			    select *
				  from tmp_transac;

   			end if 		  

			drop table tmp_transac;

			if _ajuste = 0 then
				exit foreach;
			end if

		end foreach 		

		return _numrecla,
		       _ajuste,
			   _reserva
		       with resume;

	end if

end foreach

end 

commit work;
--rollback work;

return "0", 0.00, 0.00;

end procedure