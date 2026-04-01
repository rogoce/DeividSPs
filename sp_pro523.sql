-- Insertando 
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro523;

create procedure sp_pro523(
    a_monto      DEC(16,2),
    a_no_tarjeta char(19))

returning smallint,
		  char(25);

define _no_poliza    char(10);
define _no_endoso    char(5);
define _error        integer;
define _cant         integer;
define _tarjeta      char(4);
define _no_documento char(20);
define _no_tarjeta   char(19);
define _monto        dec(16,2);
define _renglon      integer;
define _no_remesa    char(10);

--set debug file to "sp_pro523.trc";
--trace on;

set isolation to dirty read;
								
let _tarjeta = a_no_tarjeta[14,17];
let _cant = 0;

begin
on exception set _error    		
--	if _error = -268 or _error = -239 then 
--	else
 		return _error, "Error al Actualizar";         
--	end if
end exception 


--delete from tmpcobtatra;

select count(*)
  into _cant
  from cobtatra
 where no_tarjeta[16,19] = _tarjeta
   and monto = a_monto;

If _cant > 0 then
foreach
	select no_documento, no_tarjeta, monto
	  into _no_documento, _no_tarjeta, _monto  
	  from cobtatra
	 where no_tarjeta[16,19] = _tarjeta
	   and monto = a_monto

    let _renglon = NULL;

    select no_remesa, renglon
	  into _no_remesa, _renglon
	  from cobredet
	 where no_remesa = "687811"
	   and doc_remesa = _no_documento
	   and monto = _monto;

	set lock mode to wait;

	insert into tmpcobtatra(
			no_documento,
			no_tarjeta,
			monto,
			monto_excel,
			tarj_excel,
			remesa,
			renglon
			)
	values	(
			_no_documento,
			_no_tarjeta,
			_monto,
			a_monto,
			a_no_tarjeta,
			_no_remesa,
			_renglon
			);
end foreach
else
	insert into tmpcobtatra(
			no_documento,
			no_tarjeta,
			monto,
			monto_excel,
			tarj_excel
			)
	values	(
			null,
			null,
			null,
			a_monto,
			a_no_tarjeta
			);
end if
end
return 0, "Actualizacion Exitosa";
end procedure;