drop procedure sp_actuario19a2;
-- copia de sp_actuario
create procedure "informix".sp_actuario19a2()
	returning integer,varchar(250);

BEGIN
define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _no_remesa			char(10);
define _mto_comision		dec(18,2);
define _mto_reserva			dec(18,2);
define _mto_prima			dec(18,2);
define _mto_suma			dec(18,2);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _renglon				integer;
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
define _id_mov_reas			integer;
define _error_isam			integer;
define _error				integer;
define _fec_situacion		date;
define _fec_operacion		date;
define _fec_registro		date;
define _fec_emision			date;
define _fec_inivig			date;
define _fec_finvig			date;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _id_poliza;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19.trc";
--trace on;

set isolation to dirty read;

let _fec_operacion	= today;
let _fec_registro	= today;
let _mto_reserva	= 0.00;
let _id_mov_tecnico = 0;
let _cod_situacion	= 5;	--13 para prima cobrada
let _cod_empresa	= 11;
let _por_tasa		= 1;
let _cod_moneda		= 'USD';

foreach with hold
	select id_mov_tecnico,                        
		   no_remesa,
		   renglon
	  into _id_mov_tecnico,                        
		   _no_remesa,
		   _renglon
	  from movim_tec_pri_tt
	 where tip_poliza = 2
	   --and id_mov_tecnico <> 152213
	
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon = _renglon;
	   
	select cod_grupo
	  into _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	if  _cod_grupo in ('00000','1000') then
		update movim_tec_pri_tt
		   set tip_poliza = 5
		 where id_mov_tecnico = _id_mov_tecnico;
	end if

	foreach
		select id_mov_reas
		  into _id_mov_reas
		  from movim_reaseguro_tt
		 where id_mov_tecnico = _id_mov_tecnico

		delete from reas_caract_pri_tt
		 where id_mov_reas = _id_mov_reas;
	end foreach
	
	delete from movim_reaseguro_tt
	 where id_mov_tecnico = _id_mov_tecnico;
	 
	call sp_actuario_cob1(_id_mov_tecnico,_id_mov_tecnico) returning _error,_error_desc;
	
	foreach
		select id_mov_reas
		  into _id_mov_reas
		  from movim_reaseguro_tt
		 where id_mov_tecnico = _id_mov_tecnico
		
		call sp_actuario_cob2(_id_mov_reas,_id_mov_reas) returning _error,_error_desc;
	end foreach
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure;