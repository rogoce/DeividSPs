-- Procedimiento que genera los registros contables de cada factura de produccion
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par147;		

CREATE PROCEDURE "informix".sp_par147(a_periodo char(7))
returning char(10),
          char(5),
	      dec(16,2),
	      dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _monto1			dec(16,2);
define _monto2			dec(16,2);
define _reas_por_pagar	dec(16,2);

create temp table tmp_comp(
no_poliza	char(10),
no_endoso	char(5),
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;

call sp_par149(a_periodo);

insert into tmp_comp
select no_poliza,
       no_endoso,
	   reas_por_pagar,
	   0
  from reasxpag;

foreach
 select e.no_poliza,
        e.no_endoso,
		a.debito,
		a.credito
   into	_no_poliza,
        _no_endoso,
		_debito,
		_credito
   from endedmae e, endasien a
  where e.periodo   = "2004-12"
    and e.no_poliza = a.no_poliza
	and e.no_endoso = a.no_endoso
	and a.cuenta    like "231%"

	insert into tmp_comp
	values (_no_poliza, _no_endoso, 0, _debito + _credito);

end foreach

foreach
 select no_poliza,
        no_endoso,
		sum(monto1),
		sum(monto2)
   into	_no_poliza,
        _no_endoso,
		_monto1,
		_monto2
   from tmp_comp
  group by 1, 2

	let _monto2 = _monto2 * -1;

--	if _monto1 <> _monto2 then

		return _no_poliza,
		       _no_endoso,
			   _monto1,
			   _monto2
			   with resume;
--	end if

end foreach

drop table reasxpag;
drop table tmp_comp;

end procedure