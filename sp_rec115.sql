drop procedure sp_rec115;

create procedure sp_rec115(a_periodo char(7))
returning char(10),
          char(20),
		  dec(16,2),
		  dec(16,2);

define _no_reclamo	char(10);
define _numrecla	char(20);
define _monto1		dec(16,2);
define _monto2		dec(16,2);
define _filtro      char(255);

set isolation to dirty read;

{
create table rec02table(
	no_reclamo	char(10),
	numrecla	char(20),
	monto1		dec(16,2),
	monto2		dec(16,2)
	);

alter table rec02table lock mode(row);
}

delete from rec02table;
 
let _filtro = sp_rec02_old("001", "001", a_periodo);

insert into rec02table
select no_reclamo,
       numrecla,
	   reserva_neto,
	   0
  from tmp_sinis;

drop table tmp_sinis;

let _filtro = sp_rec02("001", "001", a_periodo);

insert into rec02table
select no_reclamo,
       numrecla,
	   0,
	   reserva_neto
  from tmp_sinis;

drop table tmp_sinis;

foreach
 select no_reclamo,
        numrecla,
   	    sum(monto1),
        sum(monto2)
   into _no_reclamo,
        _numrecla,
	    _monto1,
	    _monto2
   from rec02table
  group by 1, 2

	if _monto1 <> _monto2 then

		return _no_reclamo,
               _numrecla,
	           _monto1,
	           _monto2
			   with resume;

	end if

end foreach

end procedure 






											