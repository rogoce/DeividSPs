-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_sis234;
create procedure sp_sis234()
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			char(5)			as endoso;

define _mensaje				varchar(100);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_pagos_emi		smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

set isolation to dirty read;

--set debug file to "sp_sis232.trc";
--trace on;

--Query para crear la temporal
select e.no_documento,e.no_poliza,e.no_endoso,e.no_pagos as pagos_endoso,p.no_pagos as pagos_emision,t.nombre as tipo_endoso,p.cod_ramo,e.prima_neta,z.saldo
  from endedmae e, emipomae p, emipoliza z, endtimov t
 where e.no_poliza = p.no_poliza
   and p.no_documento = z.no_documento
   and t.cod_endomov = e.cod_endomov
   --and p.no_poliza not in (select distinct no_poliza from cobcampl)
   and e.no_pagos <> p.no_pagos
   and (estatus_poliza = 1 or (estatus_poliza in (2,3) and z.saldo <> 0))
   and e.actualizado = 1
   and p.actualizado = 1
   and e.prima_neta <> 0
   --and e.no_pagos <> 1
 into temp tmp_ajust_pagos;

begin
on exception set _error,_error_isam,_mensaje
	begin
		on exception in(-535)

		end exception 	
		rollback work;
	end
	
 	return _error, _mensaje,'';
end exception

foreach with hold
	select no_poliza,
		   no_endoso,
		   pagos_emision
	  into _no_poliza,
		   _no_endoso,
		   _no_pagos_emi
	  from tmp_ajust_pagos

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	update endedmae
	   set no_pagos = _no_pagos_emi
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	return 0,_no_poliza,_no_endoso with resume;
	commit work;
end foreach

end
end procedure;