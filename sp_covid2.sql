-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_covid2;
create procedure sp_covid2()
returning	varchar(20),dec(16,2),char(7),date,datetime hour to second;

define _no_documento		char(20);
define _cnt				integer;
define _fecha	date;
define _periodo,_per_cob             char(7);
define _fecha_procesado     date;
define _hora     datetime hour to second;
define _monto               dec(16,2);

set isolation to dirty read;

--set debug file to 'sp_dev06a.trc';
--trace on;

--Query para crear la temporal

begin

foreach
	select no_documento
	  into _no_documento
	  from polcovid
	 where procesado = 1
	group by no_documento 
	order by no_documento
	 
	let _cnt = 0;
	let _monto = 0;

	foreach
		select det.monto,det.periodo,det.fecha,hora_impresion
		  into _monto,_per_cob,_fecha,_hora
		  from cobredet det
		 inner join cobremae mae
		         on mae.no_remesa = det.no_remesa
				and det.actualizado = 1
				and mae.actualizado = 1
				and det.doc_remesa = _no_documento
				and det.tipo_mov in('P','N')
				and det.fecha >= '01/04/2020'
				and monto <> 0
		 order by det.fecha
		   
		if ABS(_monto) > 0 then
			return _no_documento,_monto,_per_cob,_fecha,_hora with resume;
		end if   
	   
	end foreach	
end foreach
end
end procedure;