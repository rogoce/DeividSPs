-- Procedimiento que Realiza el proceso de Rehabilitación de pólizas en cobros legal .
-- Creado    : 03/02/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis251;
create procedure "informix".sp_sis251(a_usuario char(8))
returning		integer,	--1._error
				char(250),	--2._error_desc
				char(5);	--3._no_endoso

define _error_desc			char(250);
define _comentario			char(250);
define _no_documento	char(20);
define _no_factura_rehab	char(10);
define _no_factura_canc		char(10);
define _no_poliza			char(10);
define _no_endoso_rehab		char(5);
define _no_endoso_canc		char(5);
define _no_endoso2			char(5);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_abogado			char(3);
define _cod_tipocan			char(3);
define _prima_b_rehab		dec(16,2);
define _monto_endoso		dec(16,2);
define _prima_b_canc		dec(16,2);
define _estatus_poliza		smallint;
define _no_endoso_int		smallint;
define _cnt_endoso			smallint;
define _recupero			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_hoy			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error, _error_desc,'00000';
end exception

--set debug file to "sp_cob337.trc";
--trace on;

let _cod_formapag = '082';
let _cod_compania = '001';
let _cod_sucursal = '001';
let _cod_tipocan = '001'; --'004'; Decisión de la Compañia, se cambia a Falta de Pago sol. de cobros impl. 21/01/2015 
let _fecha_hoy = today;


foreach 
	select no_documento,
		   no_poliza
	  into _no_documento,
		   _no_poliza
	  from emipoliza
	 where no_documento in ('0222-50412-01','0222-01950-01','0222-02164-01','0222-02195-01','0222-50331-01','0222-50450-01','0222-50482-01','0222-50384-01','0222-01946-01','0222-50319-01','0222-50478-01',
							'0222-50480-01','0222-50446-01','0222-01857-01','0223-03055-01','0222-50361-01','0922-00617-01','0922-00534-01','0922-00661-01','0922-10131-01','0922-00490-01','0922-00249-01','0922-00251-01',
							'0922-10110-01','0922-10145-01','0922-00128-01','0922-00221-01','0922-00574-01','0922-00131-01','0922-00352-01','0922-10136-01','0922-00181-01','0922-00306-01','0922-00307-01','0922-00308-01',
							'0922-10108-01','0922-00600-01','0922-00118-01','0922-00577-01','0922-10009-01','0922-10066-01','0922-00158-01','0922-00159-01','0922-00160-01','0922-00218-01','0922-00134-01','0922-00653-01','0922-00341-01',
							'0922-00343-01','0922-00350-01','0922-00378-01','0922-00430-01','0922-00656-01','0922-10139-01','0922-10012-01','0922-00195-01','0922-10119-01','0922-10120-01','0922-00543-01','0922-10156-01','0922-00533-01',
							'0922-00252-01','0922-00253-01','0922-00254-01','0922-00219-01','0922-00525-01','0922-00345-01','0922-00346-01','0922-00540-01','0922-10010-01','0922-00532-01','0922-00127-01','0922-10030-01','0922-00571-01',
							'0922-10177-01','0922-00587-01','0922-00588-01','0922-00686-01','0922-00390-01','0922-10196-01','0922-00323-01','0922-00236-01','0922-00237-01','0922-00209-01','0922-00208-01','0922-00478-01','0922-10179-01',
							'0922-10114-01','0922-00512-01','0922-00344-01','0922-00544-01','0922-00594-01','0922-00310-01','0922-00277-01','0922-00498-01','0922-10130-01','0922-00449-01','0922-00194-01','0922-10013-01','0922-00326-01',
							'0922-00334-01','0922-00651-01','0922-00242-01','0922-10060-01','0922-00663-01','0922-00348-01','0922-00331-01','0922-10083-01','0922-00347-01','0922-00109-01','0922-00238-01','0923-00079-01','0922-10046-01',
							'0922-00584-01','0922-00674-01','0922-10051-01','0922-00621-01','0922-00318-01','0922-00319-01','0922-00662-01','0922-00476-01','0922-00144-01','0922-10099-01','0922-10109-01','0922-10152-01','0922-00224-01',
							'0922-00272-01','0922-10031-01','0922-00309-01','0923-00206-01','0922-00267-01','0922-10191-01','0922-00244-01')
	
	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza in (1,3) then
		continue foreach;
	end if
	
	select max(no_endoso)
	  into _no_endoso
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov = '002';

	select prima_bruta * -1
	  into _monto_endoso 
	  from endedmae 
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	
	call sp_par192(_no_poliza,a_usuario,_monto_endoso) returning _error, _error_desc, _no_endoso_rehab;

	if _error <> 0 then
	return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
	end if

	call sp_pro43(_no_poliza, _no_endoso_rehab) returning _error, _error_desc;
	
	if _error = 0 then
		--Insertando cambio de plan de pago ANC.
		call sp_pro519(_no_poliza,a_usuario,_monto_endoso,_cod_compania,_cod_sucursal,'006') returning _error,_error_desc;
	else
		return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
	end if
return 0,'Actualización Exitosa',_no_endoso with resume;
end foreach

end
end procedure 