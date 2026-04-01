-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec03aa;

CREATE PROCEDURE "informix".sp_rec03aa(a_compania CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal  CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*",a_ajustador CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*")
RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,DATE,DATE,CHAR(50),CHAR(50),CHAR(50),CHAR(10),CHAR(255),DEC(16,2),integer,dec(16,2);

DEFINE v_filtros         		CHAR(255);
DEFINE v_numrecla        		CHAR(18);
DEFINE v_no_poliza       		CHAR(20);
DEFINE v_asegurado       		CHAR(100);
DEFINE v_fecha_siniestro 		DATE;     
DEFINE v_fecha_reclamo   		DATE; 
DEFINE v_fecha_documento        DATE;    
DEFINE v_ramo_nombre     		CHAR(50);
DEFINE v_compania_nombre 		CHAR(50);
DEFINE v_ajustador				CHAR(50);
DEFINE v_status                 CHAR(10);
define _reserva_inicial         dec(16,2);
DEFINE _periodo          		CHAR(7);
DEFINE _cod_ramo,_ajust_interno CHAR(3);
DEFINE _estatus_reclamo			CHAR(1);
define _no_cheque               integer;
define _cnt						integer;
define _no_requis               char(10);
define _monto_total             dec(16,2);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec03(
a_compania, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
a_ramo,
a_ajustador,
a_agente
);

let _reserva_inicial = 0;
let _cnt             = 0;
let _no_cheque       = 0;
let _no_requis = null;
let _monto_total = 0;

FOREACH 
 SELECT numrecla,        
		no_poliza,       
		asegurado,       
		fecha_siniestro, 
		fecha_reclamo, 
		fecha_documento,  
		cod_ramo,        
		periodo
   INTO v_numrecla,        
		v_no_poliza,       
		v_asegurado,       
		v_fecha_siniestro, 
		v_fecha_reclamo,
		v_fecha_documento,
		_cod_ramo,
		_periodo
   FROM tmp_sinis
  WHERE seleccionado = 1
--    AND fecha_siniestro between '01/12/2007' and '31/12/2007'
  ORDER BY	cod_ramo, periodo, numrecla

	let _no_cheque = 0;

SELECT  sum(monto)
   INTO _monto_total
   FROM rectrmae
  WHERE cod_compania = a_compania
	AND actualizado  = 1
    AND cod_tipotran IN ("004","005","006","007") 
	AND numrecla = v_numrecla;

--    AND periodo      BETWEEN a_periodo1 AND a_periodo2
		   
	SELECT ajust_interno,
	       estatus_reclamo,
		   reserva_inicial
	  INTO _ajust_interno,
	       _estatus_reclamo,
		   _reserva_inicial
	  FROM recrcmae
	 WHERE numrecla = v_numrecla
	   AND actualizado = 1;

	let _no_requis = null;

	foreach
		select no_requis
		  into _no_requis
		  from chqchrec
		 where numrecla = v_numrecla
		 exit foreach;
	end foreach

	if _no_requis is null then
		let _no_cheque = 0;
	else
		select count(*)
		  into _cnt
		  from chqchmae
		 where no_requis = _no_requis
		   and anulado = 0
		   and pagado  = 1;

		if _cnt > 0 then
			select no_cheque
			  into _no_cheque
			  from chqchmae
			 where no_requis = _no_requis;
		else
			let _no_cheque = 0;
		end if
	end if

    SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo 
	 WHERE cod_ramo = _cod_ramo;

	IF _estatus_reclamo = 'A' THEN
		LET v_status =	'ABIERTO';
	ELIF _estatus_reclamo = 'C' THEN
		LET v_status =	'CERRADO';
	ELIF _estatus_reclamo = 'R' THEN
		LET v_status =	'RE-ABIERTO';
	ELIF _estatus_reclamo = 'T' THEN
		LET v_status =	'EN TRAMITE';
	ELIF _estatus_reclamo = 'D' THEN
		LET v_status =	'DECLINADO';
	ELIF _estatus_reclamo = 'N' THEN
		LET v_status =	'NO APLICA';
	END IF

	RETURN v_numrecla,        
		   v_no_poliza,       
		   v_asegurado,       
		   v_fecha_siniestro, 
		   v_fecha_reclamo,   
		   v_fecha_documento,
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_ajustador,
		   v_status,
		   v_filtros,
           _reserva_inicial,
		   _no_cheque,
		   _monto_total
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
                                                     
END PROCEDURE;




