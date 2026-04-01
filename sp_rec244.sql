-- Procedure que Depura las TRansacciones de Pago de la cuenta 26612
-- Inctrucciones Leyri Moreno, Correo del 11/06/2015

drop procedure sp_rec244;

create procedure sp_rec244()
returning char(10),
          char(10),
		  char(10),
		  char(20);


define _transaccion	char(10);
define _pagado		smallint;
define _no_requis	char(10);
define _anular_nt	char(10);
define _numrecla	char(20);

define _id			integer;
define _no_tranrec	char(10);
define _no_tranrec2	char(10);
define _cantidad	integer;
define _cant_sec	integer;

define _compania   	char(3); 
define _sucursal   	char(3); 
define _no_reclamo 	char(10);
define _valor_nvo	char(10);
define _user		char(10);

define _error		integer;

let _user     = "GERENCIA";
let _error    = 0;
let _cant_sec = 0;

--set debug file to "sp_rec244.trc";
--trace on;

set isolation to dirty read;

--begin work;

foreach
 select transaccion_anula,
        id
   into _transaccion,
        _id
   from deivid_tmp:tmp_depurar26612
  where pagado    in (4, 5)
--    and transaccion_anula = "10-242680"
  order by reclamo

	select pagado,
	       no_requis,
		   anular_nt,
		   numrecla,
		   no_tranrec,
		   no_reclamo,
		   cod_compania,
		   cod_sucursal
	  into _pagado,
	       _no_requis,
		   _anular_nt,
		   _numrecla,
		   _no_tranrec,
		   _no_reclamo,
		   _compania,
		   _sucursal
	  from rectrmae
	 where transaccion = _transaccion;

	let _cant_sec = _cant_sec + 1;

	-- Proceso de Reversion
	
	 select count(*)
	   into _cantidad
	   from rectrrea
	  where no_tranrec = _no_tranrec;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	-- No tiene contratos de reaseguros (Error)
	
	if _cantidad = 0 then

		return _transaccion,
			   "0",
			   _no_tranrec,
			   _numrecla
		  with resume;
		  
	else

		 select count(*)
		   into _cantidad
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato <> 1;

		-- Solo tiene contrato de retencion
		
		if _cantidad <> 0 then

			{
			delete from rectrrea
			 where no_tranrec    = _no_tranrec
			   and tipo_contrato <> 1;
			   
			update rectrrea
               set porc_partic_suma  = 100,
                   porc_partic_prima = 100
			 where no_tranrec        = _no_tranrec;
			 
			update sac999:reacomp
			   set sac_asientos = 0
			 where no_tranrec   = _no_tranrec;   
			}
			
			return _transaccion,
		           _cantidad,
		           _no_tranrec,
		           _numrecla
			       with resume;

		end if
		
	end if
	
	if _cant_sec >= 25 then
--		exit foreach;
	end if
	
end foreach
 
--rollback work;
--commit work;
 
return "", "", "", "";
 
end procedure