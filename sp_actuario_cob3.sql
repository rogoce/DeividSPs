--drop procedure sp_actuario_cob3;
-- copia de sp_actuario
create procedure "informix".sp_actuario_cob3()
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
define _periodo				char(7);
define _cod_contrato		char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _por_part_total		dec(9,6);
define _porc_proporcion		dec(9,6);
define _por_part_reaseg		dec(9,6);
define _porc_partic_ancon	dec(9,6);
define _porc_cont_partic	dec(9,6);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _tipo_cont			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relacionado		integer;
define _id_mov_reas			integer;
define _id_mov_tecnico		integer;
define _error_isam			integer;
define _error				integer;
define _no_remesa			char(10);
define _renglon,_cnt        integer;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'Contrato: ' ||  _cod_contrato;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario_cob1.trc";
--trace on;

set isolation to dirty read;

let _id_mov_tecnico = 0;
let _id_mov_reas	= 0;
let _por_part_total = 0.00;


foreach


select id_mov_reas,id_mov_tecnico
  into _id_mov_reas,_id_mov_tecnico
  from movim_reaseguro_tt
 where id_mov_tecnico in(344797,344843,347362,355266,369779,371782,386407,391615,392643,409578,412693,415479,423934,439164,439840,456009,459868,461363,463633,
						 481222,482558,497911,507087,508501,525347,529236,626199,650442,654352,654381,674201)


 delete from reas_caract_pri_tt
  where id_mov_reas = _id_mov_reas;


 delete from movim_reaseguro_tt
  where id_mov_tecnico = _id_mov_tecnico;


 call sp_actuario_cob1(_id_mov_tecnico, _id_mov_tecnico) returning _error,_error_desc;

 select id_mov_reas
   into _id_mov_reas
   from movim_reaseguro_tt
  where id_mov_tecnico = _id_mov_tecnico;

 call sp_actuario_cob2(_id_mov_reas, _id_mov_reas) returning _error,_error_desc;


end foreach

return 0,'Inserción Exitosa';	
end			
end procedure;