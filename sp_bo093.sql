-- Procedure que determina la diferencia en cobmoros vs la data de belisario

drop procedure sp_bo093;

create procedure "informix".sp_bo093()
returning char(20),
           dec(16,2),
		   dec(16,2);
		   
define _no_documento	char(20);
define _pxc_bel		dec(16,2);
define _pxc_bo			dec(16,2);

create temp table tmp_cobmoros(
no_documento		char(20),
pxc_bel			dec(16,2)	default 0,
pxc_bo				dec(16,2)	default 0
) with no log;

foreach
 select poliza,
        sum(pxc)
   into _no_documento,
        _pxc_bel  
   from deivid_tmp:tmp_pxc201509orig
--   from deivid_tmp:tmp_pxc201504
  group by poliza

	insert into tmp_cobmoros (no_documento, pxc_bel)
	values (_no_documento, _pxc_bel);
	
end foreach

foreach
 select poliza,
         sum(pxc)
   into _no_documento,
         _pxc_bo  
   from deivid_tmp:tmp_pxc201509bo
--   from deivid_tmp:tmp_pxc201504bo
  group by poliza

	insert into tmp_cobmoros (no_documento, pxc_bo)
	values (_no_documento, _pxc_bo);
	
end foreach

foreach
 select no_documento,
         sum(pxc_bel),
         sum(pxc_bo)
  into _no_documento,
        _pxc_bel,
        _pxc_bo  
  from tmp_cobmoros
 group by no_documento

		if _pxc_bel <> _pxc_bo then
		
			return _no_documento,
					_pxc_bel,
					_pxc_bo  
					with resume;
		end if
		
end foreach

drop table tmp_cobmoros;

return "", 0, 0;

end procedure
