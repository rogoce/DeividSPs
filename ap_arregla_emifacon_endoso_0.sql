-- Creado:     11/03/2025 - Autor Amado P.

drop procedure ap_arregla_emifacon_endoso_0;
create procedure ap_arregla_emifacon_endoso_0()
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad, _no_endoso           char(5);
define _cantidad,_renglon,_cant_ruta            smallint;
define _porc_suma,_porcentaje  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic,_fecha_actual date;
define _mensaje 			varchar(250);
define _suma_asegurada,_prima_suscrita, _prima_retenida      dec(16,2);

--set debug file to "sp_arregla_emifacon_salud";
--trace on;

begin work;
begin
on exception set _error,_error_isam,_error_desc 
    rollback work;
 	return _error;
end exception

set isolation to dirty read;

let _error = 0;

foreach
	select a.no_poliza
     into  _no_poliza		   
	 from emipomae a
	where no_factura in (
	'09-513998',
	'09-514134',
	'11-63894',
	'09-514193',
	'47-49793',
	'09-514218',
	'01-2894671',
	'01-2897469',
	'01-2897608',
	'01-2897611',
	'05-80336',
	'09-513864',
	'01-2894547',
	'03-225141',
	'01-2893709',
	'10-78406',
	'01-2893742',
	'01-2893743',
	'05-80097',
	'05-80098',
	'09-512713',
	'01-2893778',
	'07-86695',
	'01-2893791',
	'01-2893800',
	'01-2893817',
	'01-2893825',
	'01-2893831',
	'01-2893836',
	'01-2893837',
	'01-2893859',
	'07-86703',
	'11-63779',
	'01-2893964',
	'11-63791',
	'10-78486',
	'01-2894023',
	'10-78508',
	'01-2894048',
	'01-2894079',
	'01-2894082',
	'01-2894128',
	'09-512906',
	'09-512909',
	'09-512915',
	'09-512918',
	'09-512924',
	'09-512955',
	'01-2894190',
	'09-512959',
	'09-512962',
	'10-78516',
	'09-512967',
	'09-512969',
	'09-512971',
	'07-86733',
	'09-512973',
	'09-512975',
	'09-512976',
	'09-513058',
	'11-63806',
	'09-513176',
	'01-2894224',
	'10-78536',
	'01-2894254',
	'03-224919',
	'03-224928',
	'03-224931',
	'03-224941',
	'03-224953',
	'09-513379',
	'03-225025',
	'09-513436',
	'05-80204',
	'01-2894385',
	'06-116770',
	'11-63847',
	'03-225082',
	'07-86796',
	'09-513663',
	'01-2894481',
	'09-513695',
	'03-225122')

	  
	foreach
		select a.no_unidad,
		       a.suma_asegurada
		 into  _no_unidad,
               _suma_asegurada		 
		 from endeduni a
		where a.no_poliza = _no_poliza
		  and a.no_endoso = '00000'
		
		let _error = ap_proe04_endoso_0(_no_poliza, _no_unidad, _suma_asegurada, '001');
		
		if _error <> 0 then
			rollback work;
			return _error;
		end if

	 end foreach
 
 
end foreach
commit work;
return 0;
end
end procedure;