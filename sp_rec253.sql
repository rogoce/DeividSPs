-- Cuadre de los cheques anulados

drop procedure sp_rec253;

create procedure sp_rec253(a_periodo char(7))
returning char(10),
           dec(16,2),
		   dec(16,2);
		   
define _no_requis		char(10);
define _monto1			dec(16,2);
define _monto2			dec(16,2);

create temp table tmp_26612(
no_requis			char(10),
monto1				dec(16,2) default 0,
monto2				dec(16,2) default 0
) with no log;

set isolation to dirty read;

-- Cheques Anulados

foreach
 select r.no_requis,
		 r.monto
   into _no_requis,
        _monto1
   from chqchmae m, chqchrec r
  where m.no_requis = r.no_requis 
    and year(m.fecha_anulado)		= a_periodo[1,4]
    and month(m.fecha_anulado)	= a_periodo[6,7]
    and m.pagado					= 1
	and m.anulado      			= 1
	and r.monto					<> 0
		 
		insert into tmp_26612 (no_requis, monto1)
		values (_no_requis, _monto1);
	 
end foreach

foreach
 select no_requis,
         credito
   into _no_requis,
        _monto2
   from chqchcta
  where periodo	= a_periodo
    and tipo 		= 2
    and cuenta 	= "26612"

		insert into tmp_26612 (no_requis, monto2)
		values (_no_requis, _monto2);
	 
end foreach

foreach
 select no_requis,
		 sum(monto1),
     	 sum(monto2)
   into _no_requis,
         _monto1,
		 _monto2
   from tmp_26612
  group by no_requis
  order by no_requis

	if _monto1 <> _monto2 then
	
		return _no_requis,
				_monto1,
				_monto2
				with resume;
				
	end if
			
end foreach

drop table tmp_26612;

return "",
		0,
		0;

end procedure
