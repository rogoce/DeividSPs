----------------------------------------------------------
--Proceso que hace el cambio de productos en la renovación automática de las pólizas cuya suma asegurada 
--está por debajo del minímo del producto que posee actualmente.
--Creado : 15/03/2016 - Autor: Román Gordón
--SIS v.2.0 - DEIVID, S.A.
----------------------------------------------------------

--execute procedure sp_pro383('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_pro383;
create procedure sp_pro383(
a_reasegurador	char(255)	default '%;',
a_periodo		char(7))
returning	integer,
			varchar(255);

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
define _no_cambio			smallint;
define _ano					smallint;
define _mes					smallint;
define _nuevo				smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _fecha_desde			date;
define _fecha_hasta			date;

--set debug file to "sp_pro383.trc";
--trace on;

foreach	
	
end foreach
end procedure;