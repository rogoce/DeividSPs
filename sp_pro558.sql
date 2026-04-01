-- Reporte de Emisiones para la carga coaseguros minoritarios del estado.
-- Creado: 13/09/2016	- Autor: Román Gordón

drop procedure sp_pro558; 													   
create procedure sp_pro558(a_cod_agente char(5),a_num_carga integer)
returning	varchar(30)		as poliza_coaseg,
			char(20)		as poliza,
			char(10)		as no_factura,
			varchar(50)		as ramo,
			char(5)			as no_endoso,
			date			as vigencia_inic,
			date			as vigencia_final,
			varchar(100)	as cliente,
			varchar(30)		as cedula,
			varchar(50)		as tipo_endoso,
			char(8)			as usuario,
			dec(16,2)		as prima_100,
			dec(16,2)		as impuesto_100,
			dec(16,2)		as prima_bruta_100,
			dec(7,4)		as porc_partic_ancon,
			dec(16,2)		as prima_neta,
			dec(16,2)		as impuesto,
			dec(16,2)		as prima_bruta,
			varchar(50)		as nom_compania,
			varchar(50)		as nom_archivo;

define _nom_archivo			varchar(100);
define _nom_cliente			varchar(100);
define _error_desc			varchar(100);
define _nom_endomov			varchar(50);
define _descr_cia			varchar(50);
define _nom_ramo			varchar(50);
define _no_poliza_coaseg	varchar(30);
define _cedula				varchar(30);
define _no_documento		char(20);
define _no_factura			char(10);
define _user_added			char(8);
define _no_endoso			char(5);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _porc_partic_ancon	dec(7,4);
define _prima_bruta_100		dec(16,2);
define _impuesto_100		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_100			dec(16,2);
define _impuesto			dec(16,2);
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;

--set debug file to "sp_pro558.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	return '','','','','',null,null, _error_desc,'','',_error,'',0.00,0.00,0.00,0.00,0.00,0.00,'','';
end exception

select nom_archivo
  into _nom_archivo
  from prdcacoestm
 where num_carga = a_num_carga;

let _descr_cia = sp_sis01('001');

foreach
	select no_poliza_coaseg,
		   no_endoso,
		   no_factura,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final,
		   nom_cliente,
		   cedula,
		   prima,
		   impuesto,
		   total_a_pagar,
		   porc_partic_ancon
	  into _no_poliza_coaseg,
		   _no_endoso,
		   _no_factura,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_cliente,
		   _cedula,
		   _prima_100,
		   _impuesto_100,
		   _prima_bruta_100,
		   _porc_partic_ancon
	  from emicacoami
	 where cod_coasegur = a_cod_agente
	   and num_carga = a_num_carga
	 order by no_poliza_coaseg

	select no_documento,
		   cod_endomov,
		   prima_neta,
		   impuesto,
		   prima_bruta,
		   user_added
	  into _no_documento,
		   _cod_endomov,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _user_added
	  from endedmae
	 where no_factura = _no_factura;

	select nombre
	  into _nom_endomov
	  from endtimov
	 where cod_endomov = _cod_endomov;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return	_no_poliza_coaseg,
			_no_documento,
			_no_factura,
			_nom_ramo,
			_no_endoso,
			_vigencia_inic,
			_vigencia_final,
			_nom_cliente,
			_cedula,
			_nom_endomov,
			_user_added,
			_prima_100,
			_impuesto_100,
			_prima_bruta_100,
			_porc_partic_ancon,
			_prima_neta,
			_impuesto,
			_prima_bruta,
			_descr_cia,
			_nom_archivo
			with resume;
end foreach
end

end procedure;