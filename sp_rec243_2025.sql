-- Procedure que Depura las TRansacciones de Pago de la cuenta 26612
-- Inctrucciones Leyri Moreno, Correo del 11/06/2015

drop procedure sp_rec243_2025;

create procedure sp_rec243_2025()
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
define _cnt_trx	smallint;

define _compania   	char(3); 
define _sucursal   	char(3); 
define _no_reclamo 	char(10);
define _valor_nvo	char(10);
define _user		char(10);

define _error		integer;

let _user     = "DEIVID";
let _error    = 0;
let _cant_sec = 0;

--set debug file to "sp_rec243_2024.trc";
--trace on;

set isolation to dirty read;

begin work;

--update deivid_tmp:tmp_depurar26612
--   set procesado         = 0,
--	   pagado            = 0,
--	   transaccion_anula = null;  

foreach
 select transaccion
   into _transaccion
   from deivid_tmp:carga_anula_trx
  where procesado    = 0
	--and transaccion  not in ("10-128475", "01-979339", "01-976012", "01-975998")
--	and transaccion  = "01-1032996"
    and monto        > 0
--    and reclamo[1,2] not in ("02")
  order by anio,mes,transaccion

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

	-- Proceso de Actualizacion Inicial antes de la reversion
	
	let _cnt_trx = 0;
	
	select count(*)
	  into _cnt_trx
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and fecha = today;
	
	if _cnt_trx is null then
		let _cnt_trx = 0;
	end if

	if _cnt_trx > 1 then
		update deivid_tmp:carga_anula_trx
		   set procesado = 1,
			   pagado = 6,
			   fecha_trx = today
		 where transaccion = _transaccion;
		
		continue foreach;
	end if
	
	if _pagado = 1 then

		if _anular_nt is not null then

			update deivid_tmp:carga_anula_trx
			   set procesado         = 1,
				   pagado            = 2,
				   transaccion_anula = _anular_nt,
				   fecha_trx = today
			 where transaccion = _transaccion;
			 
			continue foreach; 
		
		else
		
			select count(*)
			  into _cantidad
			  from chqchrec
			 where no_requis   = _no_requis
			   and transaccion = _transaccion;
			   
			if _cantidad is null then
				let _cantidad = 0;
			end if
			
			if _cantidad <> 0 then

				update deivid_tmp:carga_anula_trx
				   set procesado         = 1,
					   pagado            = 1,
				       transaccion_anula = _no_requis,
					   fecha_trx = today
				 where transaccion = _transaccion;

				continue foreach; 
				 
			end if
			
		end if
		
	else
	
		if _no_requis is not null then

			select count(*)
			  into _cantidad
			  from chqchrec
			 where no_requis   = _no_requis
               and transaccion = _transaccion;
			   
			if _cantidad is null then
				let _cantidad = 0;
			end if
			
			if _cantidad = 0 then
		
				update rectrmae
				   set no_requis  = null
				 where no_tranrec = _no_tranrec;   
		  
			else
			
				update deivid_tmp:carga_anula_trx
				   set procesado         = 1,
					   pagado            = 3,
				       transaccion_anula = _no_requis,
					   fecha_trx = today
				 where transaccion = _transaccion;

			end if

			continue foreach; 
		
		elif _anular_nt is not null then
		
			update deivid_tmp:carga_anula_trx
			   set procesado         = 1,
				   pagado            = 2,
				   transaccion_anula = _anular_nt,
				   fecha_trx = today
			 where transaccion = _transaccion;  
			 
			return _transaccion,
				   _error,
				   _anular_nt,
				   _numrecla
			  with resume;
		
			continue foreach; 

		end if
				 
	end if

--	continue foreach; 

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
			   "",
			   _numrecla
		  with resume;
		  
	else

		 select count(*)
		   into _cantidad
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato <> 1;

		-- Solo tiene contrato de retencion
		
		if _cantidad = 0 then

			--{
			let _valor_nvo = sp_sis13(_compania, "REC", "02", "par_tran_genera");

			call sp_rec127(_compania, _sucursal, _no_reclamo, _no_tranrec, _valor_nvo, _user) returning _error, _anular_nt;

			if _error <> 0 then
			
				rollback work;
				
				return _transaccion,
					   _error,
					   _anular_nt,
					   _numrecla;
					   
			end if
				
			update deivid_tmp:carga_anula_trx
			   set procesado         = 1,
				   pagado            = 4,
				   transaccion_anula = _anular_nt,
				   fecha_trx = today
			 where transaccion = _transaccion;
			--}
			
			return _transaccion,
				   _error,
				   _anular_nt,
				   _numrecla
			  with resume;
			  
		else

			let _valor_nvo = sp_sis13(_compania, "REC", "02", "par_tran_genera");

			call sp_rec127(_compania, _sucursal, _no_reclamo, _no_tranrec, _valor_nvo, _user) returning _error, _anular_nt;

			if _error <> 0 then
			
				rollback work;
				
				return _transaccion,
					   _error,
					   _anular_nt,
					   _numrecla;
					   
			end if
				
			update deivid_tmp:carga_anula_trx
			   set procesado         = 1,
				   pagado            = 5,
				   transaccion_anula = _anular_nt,
				   fecha_trx = today
			 where transaccion = _transaccion;  

			select no_tranrec 
			  into _no_tranrec2
			  from rectrmae
			 where transaccion = _anular_nt;
			 
			return _transaccion,
		    _cantidad,
		    _anular_nt,
		    _numrecla
			with resume;

		end if
		
	end if
	
	if _cant_sec >= 25 then
		exit foreach;
	end if
	
end foreach
 
--rollback work;
commit work;
 
return "", "", "", "";
 
end procedure