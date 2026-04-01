--drop procedure sp_v_c;
create procedure sp_v_c(a_periodo_desde char(7), a_periodo_hasta char(7))
	returning integer,varchar(250);

BEGIN
define v_filtros            varchar(255);
define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_remesa_o			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_sucursal        char(3);
define _cod_subramo			char(3);
define _cod_origen          char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _indcol              char(1);
define _mto_comision		dec(18,2);
define _mto_prima_ok      	dec(18,2);
define _mto_prima_ac		dec(18,2);
define _mto_reserva			dec(18,2);
define _mto_prima			dec(18,2);
define _mto_suma			dec(18,2);
define _comision_descontada dec(16,2);        
define _monto_descontado    dec(16,2);
define _impuesto     		dec(16,2);
define _porc_partic_prima   dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_p				dec(9,6);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _id_mov_tecnico		integer;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _num_serie			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relac_productor	integer;
define _id_relac_cliente	integer;
define _id_reas_caract		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _renglon_o			integer;
define _cantidad            integer;
define _renglon				integer;
--define _error				integer;
define _cnt					integer;
define _fec_situacion		date;
define _fec_operacion		date;
define _fec_registro		date;
define _fec_emision			date;
define _fec_inivig			date;
define _fec_finvig			date;
define _fecha_recibo        date;
define _cnt_existe          integer;
define _mensaje				char(50);
define _cnt_cobreagt        smallint;

set isolation to dirty read;


call sp_pro307('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','*','*') returning v_filtros; --crea temp_det
let _error_desc = '';
									
foreach with hold
	select no_poliza,
		   no_endoso,
		   no_documento,
		   prima_neta,
		   vigencia_inic,
		   no_factura,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _no_endoso,
		   _id_poliza,
		   _mto_prima,
		   _fec_emision,
		   _id_recibo,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	
	if trim(_no_remesa) = '' then
	    let _error_desc = trim(_error_desc) || 'Remesa en blanco. no_poliza: ' ||_no_poliza;
		return 1,_error_desc;
	end if

	select user_added,
		   periodo,
		   date_added
	  into _cod_usuario,
		   _periodo,
		   _fec_situacion
	  from cobremae
	 where no_remesa = _no_remesa;

	select count(*)
	  into _cnt_cobreagt
	  from cobreagt
	 where no_remesa = _no_remesa
	   and renglon	 = _renglon;
	
	if _cnt_cobreagt is null then
		let _cnt_cobreagt = 0;
	end if

	if _cnt_cobreagt = 0 then
		let _error_desc = 'No existe Cobreagt,no_remesa: ' || _no_remesa || 'renglon: ' || cast(_renglon as char(5));
		return 1,_error_desc;
	end if

end foreach

drop table temp_det;
 
return 0,"";	

end			
end procedure;