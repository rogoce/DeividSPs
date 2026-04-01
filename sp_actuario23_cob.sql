drop procedure sp_actuario23_cob;
-- copia de sp_actuario
create procedure "informix".sp_actuario23_cob()
returning integer,varchar(250);

BEGIN

define _error_desc			varchar(250);
define _tip_contrato		varchar(1);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _no_factura			char(20);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_agente			char(5);
define _cod_cober_reas		char(4);
define _cod_coasegur		char(4);
define _cod_tipoprod		char(3);
define _por_part_total		dec(9,6);
define _porc_comision		dec(9,6);
define _por_part_reaseg		dec(9,6);
define _porc_impuesto		dec(9,6);
define _porc_cont_partic	dec(9,6);
define _por_tasa			dec(7,3);
define _mnto_concepto		dec(18,6);
define _mto_prima			dec(18,6); 
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_concepto		smallint;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea_ancon			smallint;
define _cod_ramorea			smallint;
define _id_relac_productor_ancon		smallint;
define _tipo_cont			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relacionado		integer;
define _id_mov_tecnico		integer;
define _id_mov_tecnico_new		integer;
define _id_reas_caract		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _error				integer;

on exception set _error,_error_isam,_error_desc
	rollback work;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario21.trc";
--trace on;

set isolation to dirty read;
foreach with hold
	select id_mov_tecnico_anc,
		   id_recibo,
		   id_certificado,
		   cod_ramorea_ancon,
		   id_relac_productor_ancon
	  into _id_mov_tecnico,
		   _no_factura,
		   _no_unidad,
		   _cod_ramorea_ancon,
		   _id_relac_productor_ancon
	  from deivid:movim_tec_pri_tt
	
	begin work;
	
	select ramo_ttcorp
	  into _cod_ramorea
	  from tmp_ramorea
	 where ramo_ancon = _cod_ramorea_ancon;
	
	let _cod_agente = '00000';
	
	if _id_relac_productor_ancon < 10 then
		let _cod_agente[5,5] = _id_relac_productor_ancon;
	elif _id_relac_productor_ancon < 100 then
		let _cod_agente[4,5] = _id_relac_productor_ancon;
	elif _id_relac_productor_ancon < 1000 then
		let _cod_agente[3,5] = _id_relac_productor_ancon;
	elif _id_relac_productor_ancon < 10000 then
		let _cod_agente[2,5] = _id_relac_productor_ancon;
	else
		let _cod_agente = _id_relac_productor_ancon;
	end if
	
	
	select id_mov_tecnico
	  into _id_mov_tecnico_new		   
	  from tmp_cobr_mala_distr
	 where id_recibo = _no_factura
	   --and id_certificado = _no_unidad
	   and cod_ramorea = _cod_ramorea
	   and id_relac_filial[4,8] = _id_relac_productor_ancon;
	 
	update deivid:movim_reaseguro_tt
	   set id_mov_tecnico_new = _id_mov_tecnico_new
	 where id_mov_tecnico_ancon = _id_mov_tecnico;
	
	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure 