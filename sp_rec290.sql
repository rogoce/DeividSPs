-- Listado de Orden de Reparación

-- Creado    : 09/05/2019 - Autor: Amado Perez M.
-- Modificado: 09/05/2019 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rec290;

CREATE PROCEDURE sp_rec290()
RETURNING VARCHAR(50) AS ramo,
		  CHAR(18) AS reclamo,
		  CHAR(10) AS estatus,
		  DATE AS fecha_siniestro,
		  DATE AS fecha_notificacion,
		  VARCHAR(100) AS asegurado,
		  CHAR(10) AS cod_agente,
		  VARCHAR(50) AS agente,
		  DEC(5,2) AS porc_partic_agt,
		  DEC(16,2) AS pagado,
		  DEC(16,2) AS reserva,
		  CHAR(20) AS poliza,
		  DATE AS fecha_suscripcion,
		  CHAR(1) AS nueva_renov;
		  
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
define _perdida, _formato   CHAR(2);
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
define _estatus             CHAR(10);
define _ramo                VARCHAR(50);

SET ISOLATION TO DIRTY READ;

FOREACH	   
	select fecha_reclamo,
	       hora_reclamo,
	       fecha_siniestro,
		   hora_siniestro,
		   fecha_documento,
		   no_documento,
		   no_unidad,
		   suma_asegurada,
		   cod_asegurado,
		   ajust_interno,
		   no_tramite,
		   no_motor,
		   perd_total,
		   cod_taller,
		   date_in,
		   hora_in,
		   date_out,
		   hora_out, 
		   ins_tipo, 
		   ins_suc, 
		   formato_unico, 
		   tiene_inspeccion, 
		   ins_fecha,
		   fecha_documento,
		   no_poliza,
		   estatus_reclamo,
		   no_reclamo,
		   numrecla
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
		   _numrecla
	  from recrcmae
	 where fecha_reclamo >= '01/01/2019'
	   and numrecla[1,2] in ('02','20','23')
	   and actualizado = 1
--	 where no_reclamo = _no_reclamo

     select sum(reserva_actual),
	        sum(pagos)
	   into _reserva,
	        _pagado
	   from recrccob
	  where no_reclamo = _no_reclamo;
	  
	 select cod_ramo,
	        fecha_suscripcion,
			nueva_renov
	   into _cod_ramo,
	        _fecha_suscripcion,
			_nueva_renov
	   from emipomae
	  where no_poliza = _no_poliza;
	  
	 select nombre
	   into _ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;
	 
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
  	  	 
		RETURN _ramo,
		       _numrecla,
			   _estatus,
			   _fecha_siniestro,
			   _fecha_notificacion,
			   _asegurado,
			   _cod_agente,
			   _agente,
			   _porc_partic_agt,
			   _pagado,
			   _reserva,
			   _no_documento,
			   _fecha_suscripcion,
			   _nueva_renov with resume;   
	END FOREACH

END FOREACH


END PROCEDURE;