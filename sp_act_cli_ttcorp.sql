drop procedure sp_act_cli_ttcorp;
-- copia de sp_actuario
create procedure "informix".sp_act_cli_ttcorp()
	returning integer,varchar(250);

BEGIN
define _error_desc					varchar(250);
define _cod_usuario					varchar(30);
define _id_certificado				varchar(25);
define _id_recibo					varchar(25);
define _id_poliza					varchar(25);
define _cod_moneda					varchar(3);
define _tipo_poliza					varchar(3);
define _cod_cliente				char(10);
define _no_poliza					char(10);
define _periodo						char(7);
define _cod_agente					char(5);
define _cod_grupo					char(5);
define _no_endoso					char(5);
define _cod_cober_reas				char(3);
define _cod_tipoprod				char(3);
define _cod_sucursal        		char(3);
define _cod_subramo         		char(3);
define _cod_ramo					char(3);
define _nueva_renov					char(1);
define _indcol              		char(1);
define _tipo_produccion     		smallint;
define _tiene_impuesto      		smallint;
define _prima_neta_end				dec(16,2);
define _impuesto					dec(16,2);
define _mto_comision				dec(18,2);
define _mto_prima_ac				dec(18,2);
define _mto_reserva					dec(18,2);
define _mto_prima					dec(18,2);
define _mto_suma					dec(18,2);
define _porc_partic_ancon			dec(7,4);
define _por_tasa					dec(7,3);
define _porc_partic_agt				dec(5,2);
define _porc_comis_agt				dec(5,2);
define _cod_producto_ttcorp			smallint;
define _cod_ramorea_ancon			smallint;
define _cod_ramo_ancon				smallint;
define _ind_actualizado				smallint;
define _cod_area_seguro				smallint;
define _cod_ramo_ttcorp				smallint;
define _cod_situacion				smallint;
define _cod_producto				smallint;
define _cod_ramorea					smallint;
define _cod_empresa					smallint;
define _num_serie					smallint;
define _ramo_sis					smallint;
define _num_ano						smallint;
define _num_mes						smallint;
define _id_relac_productor			integer;
define _id_mov_tecnico_anc			integer;
define _id_relac_cliente			integer;
define _id_mov_tecnico				integer;
define _cnt_endedcob				integer;
define _error_isam					integer;
define _cantidad            		integer;
define _error						integer;
define _fec_situacion				date;
define _fec_operacion				date;
define _fec_registro				date;
define _fec_emision					date;
define _fec_inivig					date;
define _fec_finvig					date;

on exception set _error,_error_isam,_error_desc
	rollback work;
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19.trc";
--trace on;

set isolation to dirty read;


foreach with hold
	select cod_cliente
	  into _cod_cliente
	  from cliclien
	 where ttcorp_act = 0

--	 where cod_cliente <= '325043'
--	   and date_added <= '14/05/2014'

	begin work;

    update cliclien
	   set ttcorp_act = 1
	 where cod_cliente = _cod_cliente;
 
	commit work;

end foreach

return 0,'Actualizacion Exitosa';	
end			
end procedure;