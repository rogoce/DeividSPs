----------------------------------------------------------
--Proceso de Pre-Renovaciones
--Creado    : 02/02/2016 - Autor: Román Gordón
----------------------------------------------------------

--execute procedure sp_pro381('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_pro381b;
create procedure sp_pro381b(
a_compania			char(3),
a_agencia			char(3),
a_periodo1			char(7),
a_tipo_ren		    smallint	default 0)
returning	char(10) as no_poliza,
            dec(16,2) as saldo,
			dec(16,2) as diezporc,
			dec(5,2) as incremento,
			dec(5,2) as descuento,
            integer as error_r,
			varchar(255) as desc_error;

define _error_desc			varchar(255);
define _porc_desc_modelo	dec(16,2);
define _prima_bruta_ant		dec(16,2);
define _monto_descuento		dec(16,2);
define _porc_desc_flota		dec(16,2);
define _porc_desc_tabla		dec(16,2);
define _porc_desc_sinis		dec(16,2);
define _monto_impuesto		dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_aseg_ant		dec(16,2);
define _porc_desc_rc		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_total			dec(16,2);
define _prima_neta			dec(16,2);
define _valor_auto			dec(16,2);
define _porc_desc			dec(16,2);
define _factor_impuesto		dec(5,2);
define _porc_descuento		dec(5,2); 
define _porc_impuesto		dec(5,2); 
define _no_chasis			char(30);
define _no_motor			char(30);
define _vin					char(30);
define _no_documento		char(20);
define _no_poliza_maestro	char(10);
define _cod_contratante		char(10);
define _cod_asegurado		char(10);
define _no_poliza_e			char(10);
define _placa_taxi			char(10);
define _no_poliza			char(10);
define _placa				char(10);
define _usuario				char(8);
define _periodo				char(7);
define _cod_producto		char(5);
define _cod_acreedor		char(5);
define _cod_agente			char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_impuesto		char(3);
define _cod_tipoveh			char(3);
define _cod_descuen			char(3);
define _cod_subramo			char(3);
define _cod_color			char(3);
define _cod_ramo			char(3);
define _uso_auto			char(1);
define _null				char(1);
define _cnt_existe			smallint;
define _ano_tarifa			smallint;
define _ano_auto			smallint;
define _nuevo				smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _saldo               dec(16,2);
define _diezporc     		dec(16,2);
define _incremento			dec(5,2);
define _descuento   		dec(5,2);
define _nueva_prima_neta	dec(16,2);
define _opcion              char(1);
define _cod_grupo           char(5);
define _climalare           varchar(50);
define _desc_mala_ref       varchar(250);
define _cod_mala_refe       char(3);
define _nota_poliza         varchar(255);
define _nota_poliza_sal     varchar(255);
define _cod_producto_ant	char(5);
define _error_eli			integer;


set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	begin
		on exception in(-255)
		end exception
	    --rollback work; --Amado 23-09-2024
	end 
	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_poliza) || _error_desc;
	return '',0,0,0,0,_error,_error_desc;
end exception


--let _no_poliza_maestro = sp_sis13(a_compania, 'PRO', '02', 'par_no_poliza');
--let _fecha_desde = sp_sis36b(a_periodo1);
--let _fecha_hasta = sp_sis36(a_periodo2);
let _usuario = 'DEIVID';
let _null = null;

call sp_sis470(a_periodo1, a_tipo_ren) returning _error,_error_isam,_error_desc;

--set debug file to "sp_pro381.trc";
--trace on;

if _error <> 0 then
	let _error_desc = 'Excepción de DB. Póliza: ' || trim(_no_poliza) || _error_desc;
	return '',0,0,0,0, _error,_error_desc;
end if

let _incremento = 0.00;
let _descuento = 0.00;
let _nueva_prima_neta = 0.00;

foreach with hold
	select distinct b.no_poliza,
		   b.saldo,
		   b.diezporc,
		   b.incremento,
		   b.descuento	
	  into _no_poliza,
		   _saldo,
		   _diezporc,
		   _incremento,
		   _descuento	  
	  from tmp_sim_auto b
	-- where no_poliza not in ('2633807','2634348','2634916','2672115') --polizas con cese particular
	--   and no_poliza <> '0002711120' --comercial
	--   and no_poliza <> '2702528' --banisi

	return _no_poliza,
	       _saldo,
		   _diezporc,
		   _incremento,
		   _descuento, 
		   0, 
		   "Exito" with resume;
end foreach

drop table tmp_sim_auto;


end
end procedure;