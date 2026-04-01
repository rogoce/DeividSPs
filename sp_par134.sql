-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par134;

create procedure "informix".sp_par134(a_periodo char(7))
returning char(20),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _saldo			dec(16,2);
define _saldo2			dec(16,2);

--drop table tmp_dif;

create temp table tmp_dif(
no_documento	char(20),
saldo1			dec(16,2),
saldo2			dec(16,2)
) with no log;


foreach 
 select no_documento,
        saldo2
   into _no_documento,
        _saldo
   from cobdifsa

	insert into tmp_dif
	values (_no_documento, _saldo, 0);

end foreach

foreach 
 select no_documento,
        saldo
   into _no_documento,
        _saldo
   from cobmoros
  where periodo = a_periodo

	insert into tmp_dif
	values (_no_documento, 0, _saldo);

end foreach

foreach
 select no_documento,
        sum(saldo1),
		sum(saldo2)
   into _no_documento,
		_saldo,
		_saldo2
   from tmp_dif
  group by no_documento

	if _saldo <> 0.00 then

		return _no_documento,
			   _saldo,
			   _saldo2
			   with resume;

	end if

end foreach

drop table tmp_dif;

end procedure