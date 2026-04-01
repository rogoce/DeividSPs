-- Procedimiento para verificar los programas sp_cob05 y sp

drop procedure sp_par88;

create procedure "informix".sp_par88()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _saldo1			dec(16,2);
define _saldo2			dec(16,2);

create temp table tmp_versus(
	no_documento	char(20),
	saldo1			dec(16,2),
	saldo2 			dec(16,2)
	) with no log;

-- Morosidad Total

call sp_cob05("001", "001", "31/08/2003");

foreach
 select doc_poliza,
        sum(saldo)
   into _no_documento,
        _saldo1
   from tmp_moros
  where incobrable = 1
  group by doc_poliza

	insert into tmp_versus
	values(
	_no_documento,
	_saldo1,
	0.00
	);

end foreach

drop table tmp_moros;

-- Morosidad por Corredor

call sp_cob03("001", "001", "31/08/2003");

foreach
 select doc_poliza,
        sum(saldo)
   into _no_documento,
        _saldo2
   from tmp_moros
  where incobrable = 1
  group by doc_poliza

	insert into tmp_versus
	values(
	_no_documento,
	0.00,
	_saldo2
	);

end foreach

drop table tmp_moros;

foreach
 select no_documento,
        sum(saldo1),
		sum(saldo2)
   into _no_documento,
        _saldo1,
		_saldo2
   from tmp_versus
  group by no_documento
	
	if _saldo1 <> _saldo2 then

		return _no_documento,
		       _saldo1,
			   _saldo2
			   with resume;

	end if

end foreach

drop table tmp_versus;

end procedure