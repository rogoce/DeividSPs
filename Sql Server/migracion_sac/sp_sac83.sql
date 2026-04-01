-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_sac83;

create procedure sp_sac83(
a_notrx 	integer, 
a_cuenta 	char(25), 
a_tipo_comp	smallint
) returning char(10),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2);

define _no_tranrec	char(10);
define _debito1		dec(16,2);
define _credito1	dec(16,2);
define _debito2		dec(16,2);
define _credito2	dec(16,2);

foreach 
 select no_tranrec,
 		debito,
		credito
   into _no_tranrec,
		_debito1,
		_credito1
   from recasien
  where sac_notrx = a_notrx
    and cuenta    = a_cuenta
	and tipo_comp = a_tipo_comp
	
	select sum(debito),
	       sum(credito)
	  into _debito2,
	       _credito2
	  from recasiau
	 where no_tranrec = _no_tranrec
	   and cuenta     = a_cuenta
	   and tipo_comp  = a_tipo_comp;

	if _debito2 is null then
		let _debito2 = 0.00;
	end if

	if _credito2 is null then
		let _credito2 = 0.00;
	end if

	if _debito1 <> _debito2   or 
	   _credito1 <> _credito2 then

		return _no_tranrec,
			   _debito1,
			   _credito1,
			   _debito2,
			   _credito2
			   with resume;

	end if
	   
end foreach

return "", 0, 0, 0, 0;

end procedure 
