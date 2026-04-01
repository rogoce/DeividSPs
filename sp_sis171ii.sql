-- Procedimiento que actualiza el codigo de contrato para las transacciones de reclamos de las polizas en camrea
-- 
-- Creado    : 07/09/2016 - Autor: Armando Moreno M.



--drop procedure sp_sis171ii;
create procedure "informix".sp_sis171ii()
returning integer, char(250);

define _mensaje			char(250);
define _error		    integer;

define _no_reclamo      char(10);
define _no_poliza       char(10);
define _periodo         char(7);
define _no_unidad       char(5);
define _renglon         smallint;
define _error_isam		integer;
define _periodo_tr      char(7);
define _no_tranrec      char(10);


set isolation to dirty read;

--set debug file to "sp_sis171g.trc";
--trace on;

let _periodo = '2016-07';

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar el Reclamo: ' || trim(_no_reclamo);
	rollback work;
 	return _error,_mensaje;
end exception

foreach with hold
	select no_poliza,
		   no_unidad
	  into _no_poliza,
		   _no_unidad
	  from camrea
	group by no_poliza,no_unidad
	order by no_poliza,no_unidad

	begin work;

	let _no_reclamo = null;

	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where periodo     >= _periodo
		   and no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and actualizado = 1
		   
		insert into camrecreaco(
		no_poliza,
		no_unidad,
		no_reclamo,
		no_tranrec)
		values(
		_no_poliza,
		_no_unidad,
		_no_reclamo,null);
		
		update recreaco
		   set cod_contrato = '00659'
		 where no_reclamo   = _no_reclamo
		   and cod_contrato = '00656';
		   
		update recreaco
		   set cod_contrato = '00660'
		 where no_reclamo   = _no_reclamo
		   and cod_contrato = '00657';
		   
		--Procedure para crear los reaseguro por transaccion
		foreach
			select no_tranrec,
				   periodo
			  into _no_tranrec,
				   _periodo_tr
			  from rectrmae
			 where no_reclamo  = _no_reclamo
			   and actualizado = 1
			   and periodo     >= _periodo
			 order by no_tranrec

			update rectrrea
			   set cod_contrato = '00659'
		     where no_tranrec   = _no_tranrec
		       and cod_contrato = '00656';

			update rectrrea
			   set cod_contrato = '00660'
			 where no_tranrec   = _no_tranrec
			   and cod_contrato = '00657';
			   
			if _periodo_tr >= '2016-09' then
				update rectrmae
				   set sac_asientos = 0
				 where no_tranrec = _no_tranrec;

				update sac999:reacomp
				   set sac_asientos  = 0
				 where no_tranrec    = _no_tranrec
				   and tipo_registro = 3;
			end if   

			insert into camrecreaco(
				no_poliza,
				no_unidad,
				no_reclamo,
				no_tranrec)
			values(_no_poliza,
				   _no_unidad,
				   _no_reclamo,
				   _no_tranrec);
		end foreach
		   
	end foreach

	commit work;
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end

end procedure;