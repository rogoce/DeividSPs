-- Procedure para auditoria interna - Archivo de Reclamo - SINIESTROS PAGADOS
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud44b;		

create procedure "informix".sp_aud44b()
returning	integer,
			varchar(100); 

define _error_desc			varchar(50);
define _causa				varchar(50);
define _no_documento		char(20);
define _numrecla			char(20);
define _cod_asegurado		char(10);
define _transaccion			char(10);
define _cod_cliente			char(10);
define _no_tranrec      	char(10);
define _no_reclamo			char(10);
define _cod_agente			char(10);
define _situacion			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_grupo			char(5);
define _cod_cober_reas		char(3);
define _cod_sucursal		char(3);
define _cod_tipotran		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_evento			char(3);
define _cod_ramo			char(3);
define _tipo_sin			char(3);
define _tipo_cont_tt		char(1);
define _indcol				char(1);
define _porc_partic_suma	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _porc_partic_coas	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_part_total		dec(9,6);
define _monto				dec(16,2);
define _por_par_total       dec(16,2);
define _cod_area_seguro		smallint;
define _tipo_contrato		smallint;
define _contrato_xl			smallint;
define _cont_rea_f			smallint;
define _cont_rea			smallint;
define _ramo_sis			smallint;
define _pagado				smallint;
define _serie				smallint;
define _orden				smallint;
define _ramo				smallint;
define _mes					smallint;
define _cnt					smallint;
define _cod_tipotran_int	integer;
define _cod_subramo_int		integer;
define _no_tranrec_int		integer;
define _cod_suc_int			integer;
define _error_isam			integer;
define _error_cod			integer;
define _cantidad			integer;
define _cont_1				integer;
define _cont_2				integer;
define _error				integer;
define _ano					integer;
define _fecha_siniestro		date;
define _fecha_documento		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_pagado    	date;
define _fecha_trab			date;
define _fecha_hoy			date;
define _fecha				date;
define _fecha_op			date;
define _fecha_reg			date;
define _id_reas_caract      integer;
define _mnto_concepto       decimal(18,6);
define _diferencia			dec(9,6);
define _sum_por_part_reaseg	dec(9,6);
define _sum_por_part_total	dec(9,6);
define _cnt_existe          integer;
define _id_mov_tecnico		integer;
define _id_mov_rea			integer;
define _id_relacionado		integer;

set isolation to dirty read;

begin

let _id_reas_caract = 0;

delete from det_reaseguro_cara_ppr;

-- SINIESTROS PAGADOS
foreach 
	SELECT id_mov_tecnico,
		   id_mov_reas,
		   tip_contrato,
		   por_part_total,
	       por_part_reaseg,
		   fec_operacion,
		   fec_registro,
		   cod_usuario,
		   id_relacionado
	  INTO _id_mov_tecnico,
	       _id_mov_rea,
		   _tipo_cont_tt,
		   _por_par_total,
	       _porc_partic_reas,
		   _fecha_op,
		   _fecha_reg,
		   _user_added,
		   _id_relacionado
	  FROM det_movim_reasegur_ppr
	 WHERE tip_contrato in('Y','Z')
	
	 
	 SELECT mto_prima
	   INTO _monto
	   FROM det_movim_tecnico_ppr
	  WHERE id_mov_tecnico = _id_mov_tecnico;
	 
	  let _id_reas_caract = _id_reas_caract + 1;
	  let _mnto_concepto  = 0;
	  
	  IF _tipo_cont_tt = 'Z' THEN
		let _mnto_concepto  = _monto * (_porc_partic_reas/100); 
	  ELSE
		let _mnto_concepto  = _monto * (_por_par_total/100); 
	  END IF
	  
INSERT INTO det_reaseguro_cara_ppr(
			id_reas_caract,
			tip_contrato, 
			cod_concepto, 
			mto_concepto, 
			id_mov_reas, 
			fec_operacion, 
			fec_registro, 
			cod_usuario, 
			id_relacionado, 
			porc_concepto) 
	VALUES(_id_reas_caract,
		   _tipo_cont_tt, 
		   1, 
		   _mnto_concepto,
		   _id_mov_rea ,
		   _fecha_op, 
		   _fecha_reg,
		   _user_added , 
		   _id_relacionado, 
		   0);

end foreach

return 0,'Inserción Exitosa';	

end
end procedure

