-- Reporte de Recibos por Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_auditoria;

CREATE PROCEDURE "informix".sp_auditoria(
a_compania 	CHAR(3), 
a_remesa 	CHAR(10)
) RETURNING CHAR(10),	-- Remesa
			SMALLINT,	-- Renglon
		  	CHAR(10),	-- agente
		  	DEC(16,2),  -- Monto calc
		  	DEC(16,2),  -- Monto Man
			decimal(5,2),
			decimal(5,2),
		  	CHAR(30),	-- Documento
		  	CHAR(100);

DEFINE v_renglon		 SMALLINT;	
DEFINE v_no_recibo		 CHAR(10);
DEFINE v_tipo_mov        CHAR(1);
DEFINE v_doc_remesa      CHAR(30);
DEFINE v_desc_remesa     CHAR(100);
DEFINE v_monto_banco     DEC(16,2);
DEFINE v_prima           DEC(16,2);
DEFINE v_impuesto        DEC(16,2);
DEFINE v_descontada      DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_nombre_banco    CHAR(50);
DEFINE v_tipo_remesa     CHAR(1);
DEFINE v_actualizado     SMALLINT;
DEFINE v_compania_nombre CHAR(50); 

DEFINE _cod_banco        CHAR(3);
DEFINE _monto_calc       DEC(16,2);
DEFINE _monto_man        DEC(16,2);
define _porc_comis       decimal(5,2);
define _porc_partic	 	 decimal(5,2);
define _cod_agente       char(10);

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

FOREACH

 select renglon,
		cod_agente,
		monto_calc,
		monto_man,
		porc_comis_agt,
		porc_partic_agt
   into v_renglon,
        _cod_agente,
		_monto_calc,
		_monto_man,
		_porc_comis,
		_porc_partic
   from cobreagt
  where no_remesa = a_remesa
    and monto_man <> monto_calc
	
	 SELECT doc_remesa,
			desc_remesa
	   INTO	v_doc_remesa,
			v_desc_remesa
	   FROM cobredet
	  WHERE no_remesa = a_remesa
	    AND renglon   = v_renglon;

		
	RETURN a_remesa,
		   v_renglon,
		   _cod_agente,
		   _monto_calc,
		   _monto_man,
		   _porc_comis,
		   _porc_partic,
		   v_doc_remesa,      
		   v_desc_remesa     
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

