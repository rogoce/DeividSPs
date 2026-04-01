
drop procedure sp_cob350;

create procedure "informix".sp_cob350()
returning char(10),
	      smallint,
	      char(1),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2);

define _no_remesa	char(10);
define _renglon		smallint;
define _tipo_mov	char(1);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _monto		dec(16,2);
define _periodo		char(7);

foreach
 select no_remesa, 
        renglon,
		debito, 
		credito
   into _no_remesa,
        _renglon,
		_debito,
		_credito
   from	cobasien
  where periodo = "2014-12" 
    and cuenta  = "25301"

	select tipo_mov,
	       monto,
		   periodo
	  into _tipo_mov,
	       _monto,
		   _periodo
	  from cobredet
	 where no_remesa = _no_remesa
       and renglon   = _renglon;	 

	if _periodo <> "2014-12" then
	   
	return _no_remesa,
	       _renglon,
		   _tipo_mov,
		   _monto,
		   _debito,
		   _credito
		   with resume;
	end if
	
end foreach

end procedure

  