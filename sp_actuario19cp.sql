DROP PROCEDURE sp_actuario19cp;

--PRODUCCION
create procedure "informix".sp_actuario19cp()
	returning integer,varchar(250);

BEGIN

define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _no_documento		varchar(25);
define _id_poliza			varchar(25);
define _nueva_renov			varchar(1);
define _indcol				varchar(1);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tip_contrato		char(1);
define _id_relac_productor_ancon	smallint;
define _id_relac_productor			smallint;
define _cod_ramorea_ancon			smallint;
define _cod_ramorea					smallint;
define _id_mov_tecnico_new	integer;
define _id_mov_reas_new		integer;
define _id_mov_tecnico		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _error				integer;

on exception set _error,_error_isam,_error_desc
    rollback work;
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_documento || 'no_endoso: ' ||  _no_factura;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19c.trc";
--trace on;

set isolation to dirty read;

foreach with hold
	select id_mov_tecnico_anc,
		   id_poliza,
		   id_recibo,
		   id_certificado,
		   cod_ramorea_ancon,
		   lpad(id_relac_productor_ancon, 5, 0)
	  into _id_mov_tecnico,
		   _no_documento,
		   _no_factura,
		   _no_unidad,
		   _cod_ramorea_ancon,
		   _id_relac_productor
	  from movim_tec_pri_ttco
	 where cod_ramorea_ancon <> '100'
	   --and id_recibo = '01-1512752'

	begin work;

	select ramo_ttcorp
	  into _cod_ramorea
	  from tmp_ramorea
	 where ramo_ancon = _cod_ramorea_ancon;

	foreach
		select id_mov_reas_ancon,
			   tip_contrato,
			   lpad(id_relacionado_ancon,3,'0')
		  into _id_mov_reas,
			   _tip_contrato,
			   _cod_coasegur
		  from movim_reaseguro_pr
		 where id_mov_tecnico_ancon = _id_mov_tecnico
		   and tip_contrato in ('Y','Z')

		select id_mov_tecnico,
			   id_mov_reas
		  into _id_mov_tecnico_new,
			   _id_mov_reas_new
		  from tmp_reaseguro_prob
		 where id_poliza      = _no_documento
		   and id_recibo      = _no_factura
		   and id_certificado = _no_unidad
		   and tip_contrato   = _tip_contrato
--		   and cod_coasegur   = _cod_coasegur
--		   and cod_ramorea    = _cod_ramorea
		   and id_relac_productor = _id_relac_productor
		   and cod_situacion      = 5;

		update movim_reaseguro_pr
		   set id_mov_tecnico    = _id_mov_tecnico_new,
			   id_mov_reas       = _id_mov_reas_new
		 where id_mov_reas_ancon = _id_mov_reas;

		update reas_caract_pri
		   set id_mov_reas       = _id_mov_reas_new
		 where id_mov_reas_ancon = _id_mov_reas;

	end foreach
	commit work;
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure 
                                                                                                                                                                                                                              
