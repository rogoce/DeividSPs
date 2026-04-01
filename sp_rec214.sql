-- Procedimiento que Realiza la anulacion masiva de transaccion de pago de reclamos

-- Creado    : 19/07/2013 - Autor: Armando Moreno M.

drop procedure sp_rec214;

create procedure "informix".sp_rec214()
returning integer,
          char(50);

define _id				integer;
define _transaccion		char(10);
define _no_requis		char(10);
define _no_tranrec		char(10);
define _no_tranrec_new	char(10);

define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _no_reclamo		char(10);

define _cantidad		smallint;
define _ciclo			smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

let _ciclo = 0;

--set debug file to "sp_rec214.trc";
--trace on;

begin work;

foreach
 select transaccion,
        id
   into _transaccion,
        _id
   from deivid_tmp:tmp_rec2013auto
  where cancelada = 0
--    and id = 7
  order by id

	let _ciclo = _ciclo + 1;

	if _transaccion is null then

		let _cantidad = 0;

	else

		select count(*)
		  into _cantidad
		  from rectrmae
		 where transaccion = _transaccion;

	end if

	if _cantidad = 0 then

			update deivid_tmp:tmp_rec2013auto
			   set tipo      = "00000",
			       cancelada = 2 
			 where id        = _id;

	else

		call sp_rec76c(_transaccion) returning _no_requis, _error;

		if _error <> 0 then

			update deivid_tmp:tmp_rec2013auto
			   set tipo      = _no_requis, 
			       cancelada = 3 
			 where id        = _id;

		else

			call sp_rec95(_transaccion) returning _error, _error_desc;

			if _error <> 0 then

				update deivid_tmp:tmp_rec2013auto
				   set tipo  = "00000",
			       cancelada = 4 
				 where id    = _id;

			else

				select no_tranrec,
				       no_reclamo,
					   cod_compania,
					   cod_sucursal
				  into _no_tranrec,
				       _no_reclamo,
					   _cod_compania,
					   _cod_sucursal
				  from rectrmae
				 where transaccion = _transaccion;

				let _no_tranrec_new = sp_sis13(_cod_compania,"REC","02","par_tran_genera");

				call sp_rec127(_cod_compania, _cod_sucursal, _no_reclamo, _no_tranrec, _no_tranrec_new, "GERENCIA") returning _error, _error_desc; 				

				if _error <> 0 then

					update deivid_tmp:tmp_rec2013auto
					   set tipo      = _error_desc,
					       cancelada = 5
					 where id        = _id;

				else

					update deivid_tmp:tmp_rec2013auto
					   set tipo      = _error_desc,
					       cancelada = 1
					 where id        = _id;

				end if
			
			end if

		end if

	end if

	if _ciclo >= 25 then
		exit foreach;
	end if

end foreach

commit work;

return 0, "Actualizacion Exitosa " || _ciclo || " Transacciones";

end procedure