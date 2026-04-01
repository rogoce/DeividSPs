-- Procedure que verifica que las transacciones anular tengan puesto en anular_nt la transaccion que corresponde

drop procedure sp_rec247;

create procedure sp_rec247()
returning char(10),
          char(10),
		  smallint,
		  char(8),
		  date;
		  
		  
define _transaccion		char(10);
define _anular_nt		char(10);
define _user_anulo		char(8);
define _fecha_anulo		date;

define _transaccion2	char(10);
define _anular_nt2		char(10);
define _pagado			smallint;

define _no_tranrec		char(10);
define _cantidad		smallint;

set isolation to dirty read;

foreach
 select transaccion,
        anular_nt,
		no_tranrec,
		user_anulo,
		fecha_anulo
   into _transaccion,
        _anular_nt,
        _no_tranrec,
		_user_anulo,
		_fecha_anulo
   from rectrmae
  where actualizado = 1
    and anular_nt is not null
--	and transaccion = "01-139218"

	select count(*)
	  into _cantidad
	  from rectrmae
     where transaccion = _anular_nt;	

	if _cantidad > 1 then
	
		return _transaccion,
			   _anular_nt,
			   0,
			   _user_anulo,
			   _fecha_anulo
			   with resume;
		
	elif _cantidad = 0 then

		return _transaccion,
			   _anular_nt,
			   0,
			   _user_anulo,
			   _fecha_anulo
			   with resume;
	
	end if

--	continue foreach;
	
	select transaccion,
	       anular_nt,
		   pagado
	  into _transaccion2,
           _anular_nt2,
		   _pagado	
	  from rectrmae
     where transaccion = _anular_nt;	
	
	if _anular_nt2 is null then

--		if _pagado = 1 then
		
--			if _user_anulo is not null then
		
--				update rectrmae
--				   set anular_nt   = _transaccion,
--				       user_anulo  = _user_anulo,
--					   fecha_anulo = _fecha_anulo
--				 where transaccion = _anular_nt;	   
					   
				return _transaccion,
					   _anular_nt,
					   _pagado,
					   _user_anulo,
					   _fecha_anulo
					   with resume;
				   
--			end if
			
--		end if
		
	end if
	
end foreach

return "",
       "",
	   0,
	   "",
	   null;
		
end procedure