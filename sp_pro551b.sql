--Procedure que procesa la carga de pólizas de Coaseguro Minoritario
-- 30/03/2016 - Autor: Román Gordón.
-- execute procedure sp_pro551('005',1,'DEIVID')

drop procedure sp_pro551b;
create procedure "informix".sp_pro551b()
returning integer, varchar(100);

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _no_poliza_coaseg	varchar(30);
define _cedula				varchar(30);
define _ramo				varchar(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _tipo_factura		char(3);
define _cod_sucursal		char(3);
define _cod_tipocan			char(3);
define _cod_ramo			char(3);
define _porc_partic_ancon	dec(7,4);
define _total_a_pagar		dec(16,2);
define _gastos_manejo		dec(16,2);
define _prima_ancon			dec(16,2);
define _prima_total			dec(16,2);
define _impuesto			dec(16,2);
define _comision			dec(16,2);
define v_saldo				dec(16,2);
define _cnt_existe			smallint;
define _renglon				smallint;
define r_error				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic_fe	date;
define _vigencia_final		date;
define _fecha_factura		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set lock mode to wait;

begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_pro551.trc"; 
--trace on;

let _fecha_hoy = today;

foreach with hold
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where cod_grupo = '1000'
	   and date_added = today
	   and actualizado = 0
	 order by prima desc

	begin work;

	call sp_sis61b(_no_poliza) returning _error, _error_desc;
	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;