-- Procedure que Verifica los montos diferentes entre cobmoros y cobredet

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_bo053;

create procedure sp_bo053(a_periodo char(7))
returning char(20),
          char(10),
		  dec(16,2),
		  char(10),
		  dec(16,2);

define _no_documento	char(20);
define _no_poliza1		char(10);
define _monto1			dec(16,2);
define _no_poliza2		char(10);
define _monto2			dec(16,2);

create temp table tmp_cobros(
no_documento	char(20),
no_poliza1		char(10),
monto1			dec(16,2),
no_poliza2		char(10),
monto2			dec(16,2)
) with no log;

foreach
 select doc_remesa,
        no_poliza,
		monto
   into _no_documento,
        _no_poliza1,
		_monto1
   from cobredet
  where cod_compania = "001"
    and actualizado  = 1
	and tipo_mov     in ("P", "N")
	and periodo      = a_periodo

		insert into tmp_cobros
		values (_no_documento, _no_poliza1, _monto1, _no_poliza1, 0.00);

end foreach

foreach
 select no_documento,
        no_poliza,
		cobros_total
   into _no_documento,
        _no_poliza2,
		_monto2
   from deivid_cob:cobmoros
  where periodo = a_periodo

		insert into tmp_cobros
		values (_no_documento, _no_poliza2, 0.00, _no_poliza2, _monto2);

end foreach

foreach
 select no_documento,
		sum(monto1),
		sum(monto2)
   into _no_documento,
		_monto1,
		_monto2
   from tmp_cobros
  group by 1
  order by 1


	if _monto1 <> _monto2 then	 
	
		return _no_documento,
			   "", --_no_poliza1,
			   _monto1,
			   "", --_no_poliza2,
			   _monto2
			   with resume;

	end if

end foreach

return "",
	   "",
	   0.00,
	   "",
	   0.00
	   with resume;

drop table tmp_cobros;

end procedure
