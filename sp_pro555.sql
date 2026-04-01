--Procedure que procesa la carga de pólizas de Coaseguro Minoritario
-- 30/03/2016 - Autor: Román Gordón.
-- Modificado: 13/01/2023 - Autor: Amado Perez -- Se agrega el campo factura_lider y se ordena por tipo_factura EMI, MOD y ANU
-- execute procedure sp_pro551('005',1,'DEIVID')

drop procedure sp_pro555;
create procedure "informix".sp_pro555(a_cod_coasegur char(3), a_num_carga integer, a_error smallint)
returning	integer			as Renglon,
			char(20)		as Poliza,
			varchar(30)		as Poliza_Coaseg,
			date			as Vigencia_Inic,
			date			as Vigencia_Final,
			date			as Vigencia_Inic_Fe,
			varchar(30)		as Cedula,
			varchar(100)	as Cliente,
			varchar(30)		as Ramo_Coaseguro,
			varchar(30)		as Ramo,
			char(3)			as Tipo_Factura,
			date			as Fecha_Factura,
			dec(16,2)		as Prima_Total,
			dec(16,2)		as Impuesto,
			dec(16,2)		as Total_a_Pagar,
			dec(7,4)		as Porc_Participacion,
			smallint		as Procesado,
			smallint		as Procesar,
			integer			as Num_Carga,
			char(3)			as Cod_Coasegur,
			char(10)		as No_factura,
            char(20)        as Factura_Lider;

define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _no_poliza_coaseg	varchar(30);
define _nom_ramo			varchar(30);
define _cedula				varchar(30);
define _ramo				varchar(30);
define _no_documento		char(20);
define _no_factura			char(10);
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
define _procesado			smallint;
define _renglon				smallint;
define r_error				smallint;
define _no_modificacion		integer;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic_fe	date;
define _vigencia_final		date;
define _fecha_factura		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _factura_lider       char(20);
define _orden               smallint;

set lock mode to wait;

begin

on exception set _error,_error_isam,_error_desc
	return _error,'','','01/01/1900','01/01/1900','01/01/1900','',_error_desc,'','','','01/01/1900',0.00,0.00,0.00,0.00,0,0,a_num_carga,a_cod_coasegur,'','';
end exception

--set debug file to "sp_pro551.trc"; 
--trace on;

foreach
	select no_poliza_coaseg,
		   no_documento,
		   nom_cliente,
		   cedula,
		   tipo_factura,
		   fecha_factura,
		   vigencia_inic_fe,
		   cod_ramo,
		   ramo_coaseguro,
		   vigencia_inic,
		   vigencia_final,
		   prima,
		   impuesto,
		   total_a_pagar,
		   porc_partic_ancon,
		   no_modificacion,
		   renglon,
		   procesado,
		   no_factura,
           factura_lider,
           (case when tipo_factura = "EMI" then 1 else (case when tipo_factura = "MOD" then 2 else 3 end) end) as orden
	  into _no_poliza_coaseg,
		   _no_documento,
		   _nom_cliente,
		   _cedula,
		   _tipo_factura,
		   _fecha_factura,
		   _vigencia_inic_fe,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_total,
		   _impuesto,
		   _total_a_pagar,
		   _porc_partic_ancon,
		   _no_modificacion,
		   _renglon,
		   _procesado,
		   _no_factura,
           _factura_lider,
           _orden
	  from emicacoami
	 where cod_coasegur = a_cod_coasegur
	   and num_carga = a_num_carga
	   and error = a_error
	 order by orden, renglon

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return	_renglon,
			_no_documento,			
			_no_poliza_coaseg,
			_vigencia_inic,
			_vigencia_final,
			_vigencia_inic_fe,
			_cedula,
			_nom_cliente,
			_ramo,
			_nom_ramo,
			_tipo_factura,
			_fecha_factura,
			_prima_total,
			_impuesto,
			_total_a_pagar,
			_porc_partic_ancon,
			_procesado,
			0,
			a_num_carga,
			a_cod_coasegur,
			_no_factura,
            _factura_lider
			with resume;
end foreach
end
end procedure;