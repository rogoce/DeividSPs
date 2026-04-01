drop procedure sp_sis59;

create procedure "informix".sp_sis59(a_no_reclamo char(10))
returning integer,
          char(50);

define _no_tranrec	char(10);
define _error		integer;
define _mensaje		char(50);

let _no_tranrec = "00000";

foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where no_reclamo   = a_no_reclamo
    and cod_tipotran = "001"
  order by no_tranrec
	exit foreach;
end foreach

if _no_tranrec <> "00000" then

	call sp_sis58(_no_tranrec) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if


end procedure