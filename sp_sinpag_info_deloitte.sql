-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE sp_sinpag_info_deloitte;
CREATE PROCEDURE "informix".sp_sinpag_info_deloitte(
a_compania	CHAR(3),
a_agencia	CHAR(3),
a_periodo1	CHAR(7),
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_contrato	CHAR(255) DEFAULT "*",
a_ramo		CHAR(255) DEFAULT "*",
a_serie		CHAR(255) DEFAULT "*",
a_cober		CHAR(255) DEFAULT "*",
a_subramo	CHAR(255) DEFAULT "*")
RETURNING	CHAR(50) as Ramo,
            CHAR(20) as Poliza,
			CHAR(100) as Cliente,
			char(1) as Tipo_Persona,
			CHAR(18) as Reclamo,
			char(12) as Estatus_Reclamo,
			DECIMAL(16,2) as Prima_Neta,
			DATE as Fecha_Suscripcion,
			DATE as Vigenica_Inicial,
			DATE as Vigencia_Final,
			DECIMAL(16,2) as Suma_Asegurada,
			DATE as Fecha_Siniestro,
			DATE as Fecha_Reclamo,
			DECIMAL(16,2) as Reserva,
			DECIMAL(16,2) as Pagado,
			DECIMAL(16,2) as Deducible_pagado;
			
DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_transaccion      CHAR(10);     
DEFINE v_pagado_cedido    DECIMAL(16,2);
DEFINE v_reserva_cedido   DECIMAL(16,2);
DEFINE v_incurrido_cedido DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente,_no_tranrec       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;
DEFINE _porc_reas,_porc_coas         DECIMAL;

DEFINE _pagado_bruto      DECIMAL(16,2);
DEFINE _reserva_bruto     DECIMAL(16,2);
DEFINE _pagado_neto       DECIMAL(16,2);
DEFINE _reserva_neto      DECIMAL(16,2);
DEFINE _serie 			  SMALLINT;
DEFINE _serie2 			  SMALLINT;
DEFINE _pag_ret           DECIMAL(16,2);
DEFINE _pag_fac           DECIMAL(16,2);
DEFINE _pag_cont          DECIMAL(16,2);
DEFINE _res_ret           DECIMAL(16,2);
DEFINE _res_fac           DECIMAL(16,2);
DEFINE _res_cont,_reserva_total          DECIMAL(16,2);

DEFINE v_suma_pag         DECIMAL(16,2);
DEFINE v_suma_res         DECIMAL(16,2);

DEFINE _cp_pag            DECIMAL(16,2);
DEFINE _exc_pag           DECIMAL(16,2);
DEFINE _cp_res            DECIMAL(16,2);
DEFINE _exc_res           DECIMAL(16,2);
DEFINE _exc_ret           DECIMAL(16,2);
DEFINE _exc_fac           DECIMAL(16,2);

DEFINE _pag_5,_monto_bruto             DECIMAL(16,2);
DEFINE _pag_7             DECIMAL(16,2);
DEFINE _res_5             DECIMAL(16,2);
DEFINE _res_7             DECIMAL(16,2);
define _fac_car_1 	      dec(16,2);
define _fac_car_2 	      dec(16,2);
define _fac_car_3 	      dec(16,2);
define _cod_cobertura     char(5);
define _n_cober           char(30);

DEFINE _dt_siniestro      DATE;
DEFINE _serie1 			  SMALLINT;
define _si_hay            SMALLINT;
define _suma_as           DECIMAL(16,2);
define _vig_ini			  DATE;
define _vig_fin			  DATE;
define _facilidad_car     smallint;
define _cnt3			  smallint;
define _serie_char        char(15);
define _serie_c           char(4);
define _pag_ret_casco,_monto_total     DECIMAL(16,2);
define _cod_cober_reas    char(3);
define _transaccion       char(10);
define _cnt_existe		  smallint;
define _no_unidad         char(5);
define _cant              integer;
define _vigencia_inic	  date;
define _fecha_reclamo     date;
define _cod_agente        char(5);
define _n_agente          varchar(50);
define _fecha_pagado      date;
define _cod_tipopago      char(3);
define _a_cliente         char(10);
define _nn_aquien  		  char(50);
define _n_tipopago		  char(50);
define _fecha_documento,_fecha_suscripcion   date;
define _estatus_reclamo   char(1);
define _desc_estatus      char(12);
define _estimado 		DECIMAL(16,2);
define _deducible       DECIMAL(16,2);
define _reserva_inicial DECIMAL(16,2);
define _reserva_actual  DECIMAL(16,2);  
define _pagos           DECIMAL(16,2);  
define _recupero		DECIMAL(16,2);  
define _salvamento		DECIMAL(16,2); 
define _prima_neta		DECIMAL(16,2); 
define _deducible_pagado DECIMAL(16,2);
define _deducible_devuel DECIMAL(16,2);
define v_porc_reas       DECIMAL(16,2);
define v_porc_coas       DECIMAL(16,2);
define _ded              DECIMAL(16,2);
define _incurrido_reclamo DECIMAL(16,2);
define _incurrido_bruto DECIMAL(16,2);
define _incurrido_neto DECIMAL(16,2);
define _tipo_persona   char(1);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*',a_subramo); 

SET ISOLATION TO DIRTY READ;

{update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas}

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,	
		cod_ramo,		
		periodo,
		numrecla,
		cod_sucursal,
        cod_subramo,
 		sum(pagado_bruto), 		
	    sum(reserva_bruto), 	
	    sum(incurrido_bruto),	
 		sum(pagado_neto), 		
	    sum(reserva_neto), 	
	    sum(incurrido_neto)
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
		_cod_ramo, 
		_periodo,
		v_doc_reclamo,
		_cod_sucursal,
		_cod_subramo,
   		_pagado_bruto, 		
	    _reserva_bruto,		
	    _incurrido_bruto,	
   		_pagado_neto, 		
	    _reserva_neto,		
	    _incurrido_neto	
   FROM tmp_sinis 
  WHERE seleccionado = 1
  GROUP BY no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
  ORDER BY cod_ramo,numrecla
  

	LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;

   	IF _pagado_bruto is null  then
		LET _pagado_bruto = 0;
	END IF

	IF _pagado_neto is null  then
		LET _pagado_neto = 0;
	END IF

	IF _pagado_neto = 0 and _pagado_bruto = 0 then
		--CONTINUE FOREACH;
	END IF


-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

let _pag_ret_casco = 0;

	 let _cod_contrato = '';
	 let v_contrato_nombre = ''; 

	 --let _pag_ret  = 0;
	 --let _pag_cont = _cp_pag + _exc_pag;


	LET v_transaccion = _no_reclamo ;

	SELECT fecha_siniestro,no_unidad,fecha_reclamo,fecha_documento,estatus_reclamo
	  INTO v_fecha_siniestro,_no_unidad,_fecha_reclamo,_fecha_documento,_estatus_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
    end foreach

	select nombre
	  into _n_cober
	  from prdcober
     where cod_cobertura = _cod_cobertura;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion,
		   cod_ramo,
		   prima_neta
	  INTO v_doc_poliza,
	       _cod_cliente,
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _fecha_suscripcion,
		   _cod_ramo,
		   _prima_neta
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 
	SELECT nombre,tipo_persona
	  INTO v_cliente_nombre,_tipo_persona	
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

    select count(*)
	  into _cant
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	 let v_pagado_cedido = 0;

if _estatus_reclamo = 'A' then
   let _desc_estatus = 'Abierto';
elif _estatus_reclamo = 'C' then
   let _desc_estatus = 'Cerrado';
elif _estatus_reclamo = 'D' then
   let _desc_estatus = 'Declinado';
elif _estatus_reclamo = 'N' then
   let _desc_estatus = 'No Aplica';
else
 let _desc_estatus = '';
end if   
    
	call sp_rec33(_no_reclamo) returning _estimado,_deducible,_reserva_inicial,_reserva_actual,_pagos,_recupero,_salvamento,_deducible_pagado,_deducible_devuel,v_porc_reas,
	   v_porc_coas, _ded, _incurrido_reclamo, _incurrido_bruto, _incurrido_neto;

	RETURN v_ramo_nombre,
		   v_doc_poliza,
		   v_cliente_nombre,
		   _tipo_persona,
	       v_doc_reclamo,
		   _desc_estatus,
		   _prima_neta,
		   _fecha_suscripcion,
		   _vig_ini,
		   _vig_fin,
		   _suma_as,
	 	   v_fecha_siniestro, 	
		   _fecha_reclamo,
		   _reserva_bruto, --_reserva_actual,
		   _pagado_bruto, --_pagos,
		   _deducible_pagado
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;

		  