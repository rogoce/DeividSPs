-- Actualizacion de los cheques en transito

-- Creado    : 14/06/2006 - Autor: Demetrio Hurtado

drop procedure sp_che53;

create procedure sp_che53()
returning integer,
          integer,
		  char(10);

define _no_cheque	integer;
define _no_requis	char(10);
define _cantidad	integer;
define _contador	integer;

let _contador = 0;

foreach
 select no_cheque,
        no_requis
   into _no_cheque,
        _no_requis
   from chqchmae
  where pagado       = 1
    and anulado      = 0 
    and wf_entregado = 0
    and tipo_requis  = "C"
--	and no_cheque    = 229525

	let _contador = _contador + 1;

	select count(*)
	  into _cantidad
	  from deivid_tmp:tmp_ckspend31082012
	 where cheque = _no_cheque;

	if _cantidad = 0 then

		update chqchmae
		   set wf_nombre    = "Actualizacion del 31/08/2012", 	-- Nombre de la persona que busca el cheque.
			   wf_cedula    = "0-000-0000", 		   			-- Cedula de la persona que busca el cheque.
			   user_entrego = "informix", 			   			-- Usuario de Deivid que hizo la entrega (esto tiene poco tiempo de haberlo incluido).
			   wf_fecha     = today,				   			-- Fecha del día que se uso el programa
			   wf_entregado = 1,
			   wf_hora      = current				   			-- Hora del día que se uso el programa.
		 where no_requis    = _no_requis;

		return 0,
		       _no_cheque,
			   _no_requis
			   with resume;
	else

		return 1,
		       _no_cheque,
			   _no_requis
			   with resume;

	end if
	
	if _contador >= 1000 then
		exit foreach;
	end if

end foreach

end procedure
