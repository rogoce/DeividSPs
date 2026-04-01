
drop procedure sp_actuario19e;
create procedure "informix".sp_actuario19e()
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
define _no_remesa			char(10);
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
define _renglon				integer;
define _error				integer;


--set debug file to "sp_actuario19c.trc";
--trace on;

set isolation to dirty read;

foreach with hold
	select id_mov_reas,
		   id_poliza,
		   id_recibo,
		   no_remesa,
		   renglon
	  into _id_mov_reas_new,
		   _no_documento,
		   _no_factura,
		   _no_remesa,
		   _renglon
	 from deivid_ttcorp:tmp_reaseguro_prob
	foreach
		select id_mov_tecnico_anc
		  into _id_mov_tecnico 
	      from movim_tec_pri_tt 
		 where no_remesa = _no_remesa
		   and renglon = _renglon
		   and id_recibo = id_recibo
		   and id_poliza = _no_documento
		   and cod_ramorea_ancon <> 100
	
			foreach
				select id_mov_reas_ancon
				  into _id_mov_reas 
				  from movim_reaseguro_tt 
				 where id_mov_tecnico_ancon = _id_mov_tecnico
				   and tip_contrato in('Y', 'Z') 
				   
				update reas_caract_pri_tt
				   set id_mov_reas = _id_mov_reas_new
				 where id_mov_reas_ancon = _id_mov_reas;
				
			end foreach
	end foreach
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure 
