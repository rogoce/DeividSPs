-- reportemorosidad normal vs especial
 													   
drop procedure sp_cob190;

create procedure sp_cob190()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _saldo_nor		dec(16,2);
define _saldo_esp		dec(16,2);

foreach
 select no_documento,
        sum(saldo_nor),
        sum(saldo_esp)
   into _no_documento,
        _saldo_nor,
        _saldo_esp
   from pxcr0510
  group by no_documento

	if _saldo_nor <> _saldo_esp then

		return _no_documento,
	           _saldo_nor,
	           _saldo_esp
			   with resume;

	end if

end foreach

end procedure