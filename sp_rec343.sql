-- Reporte de Recuperos - Auditoría Interna

-- Creado    : 08/06/2021 - Autor: Amado Perez M.
-- Modificado: 08/06/2021 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rec343;

CREATE PROCEDURE sp_rec343()
RETURNING CHAR(18) AS reclamo,
		  CHAR(20) AS poliza,
		  DATE AS vigencia_inic,
		  DATE AS vigencia_final,
		  DATE AS fecha_suscripcion,
		  DATE AS fecha_siniestro,
		  DATE AS fecha_reclamo,
		  VARCHAR(100) AS asegurado,
		  varchar(100) AS cobertura,
		  char(5) AS cod_producto,
		  varchar(50) AS producto,
		  DEC(16,2) AS pagado,
		  DEC(16,2) AS deducible,
		  CHAR(10) AS estatus,
		  CHAR(10) AS estatus_poliza,
		  CHAR(10) AS cod_agente,
		  VARCHAR(50) AS agente,
		  DEC(5,2) AS porc_partic_agt,
		  CHAR(15) AS perdida,
		  VARCHAR(50) AS marca,
		  VARCHAR(50) AS modelo,
		  CHAR(10) AS placa,
		  SMALLINT AS ano_auto,
		  CHAR(10) AS tipo_auto,
		  DEC(16,2) AS saldo_reserva,
		  DATE AS fecha_cierre,
		  DATE AS fecha_recupero,
		  DEC(16,2) AS monto_recuperado,
		  CHAR(15) AS estatus_recobro;
		  
define _no_orden			CHAR(10);
define _no_reclamo			CHAR(10);
define _numrecla			CHAR(18);
define _fecha_reclamo       DATE;
define _hora_reclamo		DATETIME HOUR TO SECOND;
define _fecha_siniestro		DATE;
define _hora_siniestro		DATETIME HOUR TO SECOND;
define _fecha_documento   	DATE; 
define _no_documento		CHAR(20);
define _no_unidad			CHAR(5);
define _suma_asegurada		DEC(16,2);
define _cod_asegurado		CHAR(10);
define _ajust_interno		CHAR(3);
define _no_tramite			CHAR(10);
define _no_motor			CHAR(30);
define _perd_total			SMALLINT;
define _cod_taller			CHAR(10);
define _date_in				DATE;
define _hora_in				DATETIME HOUR TO SECOND;
define _date_out			DATE;
define _hora_out			DATETIME HOUR TO SECOND;
define _ins_tipo			SMALLINT;
define _ins_suc				CHAR(3);
define _formato_unico		SMALLINT;
define _tiene_inspeccion	SMALLINT;
define _ins_fecha			DATE;
define _fecha_orden         DATE;
define _taller              VARCHAR(100);
define _asegurado           VARCHAR(100);
define _ajustador  			VARCHAR(50);
define _formato             CHAR(2);
define _tipo_ins            CHAR(10);
define _ins_agengia         VARCHAR(50);
define _cod_ramo            CHAR(3);
define _fecha_notificacion  DATE;
define _no_poliza           CHAR(10);
define _estatus_reclamo     CHAR(1);
define _reserva             DEC(16,2);
define _pagado              DEC(16,2);
define _cod_agente          CHAR(5);
define _porc_partic_agt     DEC(5,2);
define _agente              VARCHAR(50);
define _fecha_suscripcion   DATE;
define _nueva_renov         CHAR(1);
define _estatus, _estatus_p CHAR(10);
define _ramo                VARCHAR(50);
define _cnt                 SMALLINT;
define _cod_cobertura       CHAR(5);
define _deducible           DEC(16,2);
define _perdida             CHAR(15);
define _ano_auto		    smallint;
define _placa    		    char(10);
define _marca			    varchar(50);
define _modelo		        varchar(50);
define _cod_marca           char(5);
define _cod_modelo          char(5);
define _cobertura           varchar(100);
define _uso_auto            char(1);
define _vigencia_inic		DATE;
define _vigencia_final		DATE;
define _cod_producto        CHAR(5);
define _producto            CHAR(50);
define _estatus_poliza      SMALLINT;
define _fecha_cierre        DATE;
define _fecha_recupero      DATE;
define _monto_recuperado    DEC(16,2);
define _estatus_recobro     SMALLINT;

SET ISOLATION TO DIRTY READ;

FOREACH	   
	select a.fecha_reclamo,
	       a.hora_reclamo,
	       a.fecha_siniestro,
		   a.hora_siniestro,
		   a.fecha_documento,
		   a.no_documento,
		   a.no_unidad,
		   a.suma_asegurada,
		   a.cod_asegurado,
		   a.ajust_interno,
		   a.no_tramite,
		   a.no_motor,
		   a.perd_total,
		   a.cod_taller,
		   a.date_in,
		   a.hora_in,
		   a.date_out,
		   a.hora_out, 
		   a.ins_tipo, 
		   a.ins_suc, 
		   a.formato_unico, 
		   a.tiene_inspeccion, 
		   a.ins_fecha,
		   a.fecha_documento,
		   a.no_poliza,
		   a.estatus_reclamo,
		   a.no_reclamo,
		   a.numrecla,
		   b.fecha_recupero,
		   b.monto_recuperado,
		   b.estatus_recobro
	  into _fecha_reclamo,
	       _hora_reclamo,
	       _fecha_siniestro,
		   _hora_siniestro,
		   _fecha_documento,
		   _no_documento,
		   _no_unidad,
		   _suma_asegurada,
		   _cod_asegurado,
		   _ajust_interno,
		   _no_tramite,
		   _no_motor,
		   _perd_total,
		   _cod_taller,
		   _date_in,
		   _hora_in,
		   _date_out,
		   _hora_out, 
		   _ins_tipo, 
		   _ins_suc, 
		   _formato_unico, 
		   _tiene_inspeccion, 
		   _ins_fecha,
		   _fecha_notificacion,
		   _no_poliza,
		   _estatus_reclamo,
		   _no_reclamo,
		   _numrecla,
		   _fecha_recupero,
		   _monto_recuperado,
		   _estatus_recobro
	  from recrcmae a, recrecup b
	 where a.no_reclamo = b.no_reclamo
	   and b.fecha_recupero >= '31/05/2021'
	   and b.fecha_recupero <= '31/05/2022'
	   and a.numrecla[1,2] in ('02','20','23')
	   and a.actualizado = 1
--	 where no_reclamo = _no_reclamo

     if _perd_total = 1 then
		let _perdida = "PERDIDA TOTAL";
	 else
		let _perdida = "PERDIDA PARCIAL";
	 end if
	 
	 let _uso_auto = null;
	 
	 select uso_auto
	   into _uso_auto
	   from emiauto
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad;
		
     if _uso_auto is null or trim(_uso_auto) = "" then
		foreach
			 select uso_auto
			   into _uso_auto
			   from endmoaut
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad
			 exit foreach;
		end foreach
	 end if
	 
     select cod_marca,
	        cod_modelo,
	        placa,
	        ano_auto
	   into _cod_marca,
	        _cod_modelo,
			_placa,
			_ano_auto
	   from emivehic
	  where no_motor = _no_motor;
	 
	let _marca = null;
	let _modelo = null;

	if _cod_marca is null then
		let _cod_marca = "";
	else
		select nombre
		  into _marca
		  from emimarca
		 where cod_marca = _cod_marca;
	end if

	if _cod_modelo is null then
		let _cod_modelo = "";
	else
		select nombre
		  into _modelo
		  from emimodel
		 where cod_marca  = _cod_marca
		   and cod_modelo = _cod_modelo;
	end if

	 select fecha_suscripcion,
			nueva_renov,
			vigencia_inic,
			vigencia_final,
			estatus_poliza
	   into _fecha_suscripcion,
			_nueva_renov,
			_vigencia_inic,
			_vigencia_final,
			_estatus_poliza
	   from emipomae
	  where no_poliza = _no_poliza;
			 
	 select nombre 
	   into _asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;

	if _estatus_reclamo = 'A' then
		let _estatus = 'ABIERTO';
	elif _estatus_reclamo = 'C' then
		let _estatus = 'CERRADO';
	elif _estatus_reclamo = 'D' then
		let _estatus = 'DECLINADO';
	else
		let _estatus = 'NO APLICA';
	end if
	
	let _fecha_cierre = null;
	
	if _estatus_reclamo = 'C' then
		FOREACH 
			select fecha
			  into _fecha_cierre
			  from rectrmae
			 where no_reclamo = _no_reclamo
			   and actualizado = 1
			   and (cod_tipotran = '011' and cerrar_rec = 1)
			order by no_tranrec desc
			
			exit foreach;
		END FOREACH
	end if
	
	let _cod_producto = null;
	
	select cod_producto
	  into _cod_producto
	  from emipouni
     where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

     if _cod_producto is null or trim(_cod_producto) = "" then
		foreach
			 select cod_producto
			   into _cod_producto
			   from endeduni
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad
			 exit foreach;
		end foreach
	 end if
	   
	 select nombre
       into _producto
       from prdprod
      where cod_producto = _cod_producto;	   
	   
     FOREACH
		 select cod_cobertura,
		        deducible,
		        sum(reserva_actual),
				sum(pagos)
		   into _cod_cobertura,
		        _deducible,
		        _reserva,
				_pagado
		   from recrccob
		  where no_reclamo = _no_reclamo 
--			and pagos <> 0
	   group by cod_cobertura, deducible
	   
	     select nombre
		   into _cobertura
		   from prdcober
		  where cod_cobertura = _cod_cobertura;
		  		  		 
		FOREACH 
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente,
				   _porc_partic_agt
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			select nombre 
			  into _agente
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			RETURN _numrecla,
				   _no_documento,
				   _vigencia_inic,
				   _vigencia_final,	
				   _fecha_suscripcion,
				   _fecha_siniestro,
				   _fecha_reclamo,
				   _asegurado,
				   _cobertura,
				   _cod_producto, 
				   _producto,
				   _pagado,
				   _deducible,
			       _estatus,
				   (case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end),
				   _cod_agente,
				   _agente,
				   _porc_partic_agt,
				   _perdida,
				   _marca,
				   _modelo,
				   _placa,
				   _ano_auto,
				   (case when _uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end),
				   _reserva,
				   _fecha_cierre,
				   _fecha_recupero,
				   _monto_recuperado,
				   (case when _estatus_recobro = 1 then "TRAMITE" else (case when _estatus_recobro = 2 then "INVESTIGACION" else (case when _estatus_recobro = 3 then "SUBROGACION" else (case when _estatus_recobro = 4 then "ABOGADO" else (case when _estatus_recobro = 5 then "ARREGLO DE PAGO" else (case when _estatus_recobro = 6 then "INFRUCTUOSO" else "RECUPERADO" end)end)end)end)end)end)
				   with resume;   
		END FOREACH
	END FOREACH
END FOREACH


END PROCEDURE;