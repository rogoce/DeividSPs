
drop procedure sp_sac245;

create procedure "informix".sp_sac245()
returning char(20),
           dec(16,2),
		   dec(16,2);
		   
define _no_documento	char(20);
define _saldo_deivid	dec(16,2);
define _saldo_bo		dec(16,2);

create temp table tmp_saldos(
no_documento	char(20),
saldo_deivid	dec(16,2)	default 0,
saldo_bo		dec(16,2)	default 0
) with no log;

foreach
 select poliza,
        saldo_act
   into _no_documento,
        _saldo_deivid
   from deivid_tmp:tmp_primas_deivid

	insert into tmp_saldos (no_documento, saldo_deivid)
	values (_no_documento, _saldo_deivid);
	
end foreach   

foreach
 select poliza,
        saldo
   into _no_documento,
        _saldo_bo
   from deivid_tmp:tmp_primas_bo

	insert into tmp_saldos (no_documento, saldo_bo)
	values (_no_documento, _saldo_bo);
	
end foreach   

foreach
 select no_documento,
        sum(saldo_deivid),
        sum(saldo_bo)
   into _no_documento,
        _saldo_deivid, 
		_saldo_bo
  from tmp_saldos		
 group by no_documento
 order by no_documento 

	if _saldo_deivid <> _saldo_bo then
	
		return _no_documento,
		        _saldo_deivid,
				_saldo_bo
				with resume;
				
	end if
  
end foreach

drop table tmp_saldos;

-- tomillopanama@gmail.com
 
return "", 0, 0;

end procedure
 
 
 
 
 
 
 
 
 
 
