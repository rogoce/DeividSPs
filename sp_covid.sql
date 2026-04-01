-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_covid;
create procedure sp_covid()
returning	char(7),varchar(20),dec(16,2),char(7);

define _no_documento		char(20);
define _cnt				integer;
define _fecha_suspension	date;
define _periodo,_per_cob             char(7);
define _fecha_procesado     date;
define _monto               dec(16,2);

set isolation to dirty read;

--set debug file to 'sp_dev06a.trc';
--trace on;

--Query para crear la temporal

begin

foreach
	select no_documento,
	       periodo,
		   fecha_procesado
	  into _no_documento,
           _periodo,
		   _fecha_procesado
	  from polcovid
	 where procesado = 1
	 order by periodo
	 
	let _cnt = 0;
	let _monto = 0;

	foreach
		select sum(monto),periodo
		  into _monto,_per_cob
		  from cobredet
		 where actualizado = 1
		   and doc_remesa = _no_documento
		   and tipo_mov in('P','N')
		   and fecha >= _fecha_procesado
		  group by periodo 
		 order by periodo
		   
		if ABS(_monto) > 0 then
			return _periodo,_no_documento,_monto,_per_cob with resume;
		end if   
	   
	end foreach	
end foreach
end
end procedure;