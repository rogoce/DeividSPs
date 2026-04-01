-- Actualizacion de los cheques en transito

-- Creado    : 14/06/2006 - Autor: Demetrio Hurtado

drop procedure sp_che68;

create procedure sp_che68()
returning integer,
          integer,
		  char(10);

define _no_cheque	integer;
define _no_requis	char(10);
define _cantidad	integer;

foreach
 select no_cheque,
        no_requis
   into _no_cheque,
        _no_requis
   from chqchmae
  where user_entrego    = "informix"
    and wf_fecha        = "14/06/2006"
    and pagado          = 0

--{
	update chqchmae
	   set wf_nombre    = null,
		   wf_cedula    = null,
		   user_entrego = null,
		   wf_fecha     = null,
		   wf_entregado = 0,
		   wf_hora      = null
	 where no_requis    = _no_requis;
--}
	return 0,
	       _no_cheque,
		   _no_requis
		   with resume;

end foreach

end procedure
