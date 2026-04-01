--Creado: Román Gordón
--Procedimiento verifica que el numero de póliza de los endosos de las pólizas del grupo de SUNCTRACS correspondan al numero de póliza en emisión

drop procedure sp_sis220a;

create procedure "informix".sp_sis220a()
returning	char(10)	as no_poliza_e,
			char(20)	as PolizaR,
			char(20)	as PolizaE,
			char(5)		as Endoso,
			char(20)	as Factura,
			date		as Fecha_Emision;

define _no_documento_r 		char(20);
define _no_documento 		char(20);
define _no_factura	 		char(20);
define _no_poliza_r			char(10);
define _no_poliza 			char(10);
define _no_endoso 			char(5);
define _error				integer;
define _fecha_emision		date;

BEGIN
ON EXCEPTION SET _error
	return _error,_no_poliza,'','','','01/01/1900';
end exception

--set debug file to "sp_sis118.trc";
--trace on;

foreach
	select no_poliza,
		   no_documento
	  into _no_poliza,
		   _no_documento_r
	  from emipomae 
	 where cod_grupo = '01016' 
	   and actualizado = 1

	foreach
		select no_documento,
			   no_endoso,
			   no_factura,
			   fecha_emision
		  into _no_documento,
			   _no_endoso,
			   _no_factura,
			   _fecha_emision
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1

		if _no_documento <> _no_documento_r then
			return _no_poliza,_no_documento_r,_no_documento,_no_endoso,_no_factura,_fecha_emision with resume;
		end if
	end foreach
end foreach
end
end procedure;