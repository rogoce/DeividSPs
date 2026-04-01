-- Informe de Estatus del Reclamo. Encabezado y Detalle de Transacciones
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Mod.      : 26/11/2001 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec241;

CREATE PROCEDURE "informix".sp_rec241(
a_compania     CHAR(3),
a_agencia      CHAR(3),   
a_no_reclamo   CHAR(10)
)
RETURNING CHAR(18),	     
		  DATE,          
		  DATE, 	     
		  DEC(16,2),
		  VARCHAR(50);     
      			  		         
DEFINE _cod_coasegur        CHAR(3);      
DEFINE _ajust_interno       CHAR(3);
DEFINE _ajust_externo	    CHAR(3);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_contrato	    CHAR(5);
DEFINE _cod_grupo		    CHAR(5);
DEFINE _no_recupero 	    CHAR(5);
DEFINE _numrecla	        CHAR(18);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _no_reclamo 		    CHAR(10);
DEFINE _transaccion         CHAR(10);
DEFINE _no_tranrec          CHAR(10);
DEFINE _no_documento        CHAR(20);
DEFINE _nombre_interno	    CHAR(50);
DEFINE _nombre_externo	    CHAR(50);
DEFINE _nombre_asegurado    CHAR(50);
DEFINE _nombre_cliente      CHAR(50);
DEFINE _nombre_tran         CHAR(50);
DEFINE v_compania_nombre    CHAR(50);
DEFINE estatus              CHAR(50);
DEFINE _estatus_reclamo     CHAR(50);
DEFINE _grupo               CHAR(50);

DEFINE _tipo_contrato       INT;
DEFINE _tipo_transaccion    INT;

DEFINE _fecha_reclamo       DATE;
DEFINE _fecha_siniestro     DATE;
DEFINE _fecha_tran          DATE;

DEFINE _porc_partic_suma	DECIMAL(9,6);  -- % reaseguro
DEFINE _porc_partic_reas	DECIMAL(9,6);  -- % reaseguro
DEFINE _porc_partic_coas	DECIMAL(7,4);  -- % coaseguro
DEFINE _monto_tran          DECIMAL(16,2);
DEFINE _variacion           DECIMAL(16,2);
DEFINE _reserva     		DECIMAL(16,2);
DEFINE _pagado              DECIMAL(16,2);
DEFINE _recuperos           DECIMAL(16,2);
DEFINE _incurrido   		DECIMAL(16,2);
DEFINE _deducible   		DECIMAL(16,2);
DEFINE _estimado    		DECIMAL(16,2);
DEFINE _pagado_tot    		DECIMAL(16,2);
DEFINE _pagado_recup   		DECIMAL(16,2);
DEFINE _pagado_salida		DECIMAL(16,2);
DEFINE _recuperos_salida  	DECIMAL(16,2);
DEFINE _ded				  	DECIMAL(16,2);
DEFINE _cerrar_rec			SMALLINT;
DEFINE _wf_apr_j_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_jt_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_jt_2_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_g_fh			DATETIME year to fraction(5);
DEFINE _cod_evento          char(3);
DEFINE _n_evento            varchar(50);


define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define _sumar_incurrido		dec(16,2);

LET _reserva   		  = 0.00;
LET _pagado    		  = 0.00;
LET _recuperos 	 	  = 0.00;
LET _ded     	 	  = 0.00;
LET _incurrido 		  = 0.00;
LET _pagado_tot 	  = 0.00;
LET _pagado_recup 	  = 0.00;
LET _pagado_salida 	  = 0.00;
LET _recuperos_salida = 0.00;
LET _no_recupero      = Null;
let _n_evento         = "";
		
---SET DEBUG FILE TO "sp_re40.trc ";
--TRACE ON;

SET ISOLATION TO DIRTY READ;


select no_documento
  into _no_documento
  from recrcmae
 where no_reclamo = a_no_reclamo; 

Foreach
	SELECT estatus_reclamo,
	   	   fecha_reclamo,
		   fecha_siniestro,
		   ajust_interno,
		   ajust_externo,
		   numrecla,
		   cod_asegurado,
		   no_reclamo,
		   cod_evento
      INTO _estatus_reclamo,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   _ajust_interno,
		   _ajust_externo,
		   _numrecla,
		   _cod_asegurado,
		   _no_reclamo,
		   _cod_evento
   	  FROM recrcmae
     WHERE no_documento = _no_documento
       AND actualizado  = 1
	 order by fecha_reclamo


	SELECT SUM(r.monto)
	  INTO _pagado_tot
	  FROM rectrmae r, rectitra t
	 WHERE r.no_reclamo       = _no_reclamo
	   AND r.cod_tipotran     = t.cod_tipotran
	   AND t.tipo_transaccion = 4
	   AND r.actualizado = 1;

	IF _pagado_tot IS NULL THEN
		LET _pagado_tot = 0.00;
	END IF
	
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;
	 
	RETURN  _numrecla,
			_fecha_reclamo,
			_fecha_siniestro,
			_pagado_tot,
			_n_evento
        WITH RESUME;

end foreach

END PROCEDURE;