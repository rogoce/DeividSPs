-- Listado de Orden de Reparación

-- Creado    : 09/05/2019 - Autor: Amado Perez M.
-- Modificado: 09/05/2019 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rec288;

CREATE PROCEDURE sp_rec288(a_fecha_1 DATE, a_fecha_2 DATE)
RETURNING CHAR(10) AS no_orden,
          CHAR(10) AS cod_taller,
		  VARCHAR(100) AS taller,
		  DATE AS fecha_orden,
          CHAR(10) AS no_tramite,
		  CHAR(18) AS reclamo,
		  DATE AS fecha_reclamo,
		  DATETIME HOUR TO SECOND AS hora_reclamo,
		  DATE AS fecha_siniestro,
		  DATETIME HOUR TO SECOND AS hora_siniestro,
		  DATE AS fecha_documento,
		  CHAR(20) AS poliza,
		  CHAR(5) AS unidad,
		  DEC(16,2) AS suma_asegurada,
		  CHAR(10) AS cod_asegurado,
		  VARCHAR(100) AS asegurado,
		  VARCHAR(50) AS ajustador,
		  CHAR(30) AS motor,
		  CHAR(2) AS perdida,
		  DATE AS fecha_entrada,
		  DATETIME HOUR TO SECOND AS hora_entrada,
		  DATE AS fecha_salida,
		  DATETIME HOUR TO SECOND AS hora_salida,
		  CHAR(10) AS tipo_inspec,
		  VARCHAR(50) AS sucursal_inspec,
		  CHAR(2) AS formato_unico,
		  SMALLINT AS inspeccionado,
		  DATE AS fecha_inspeccion,
		  DEC(16,2) AS monto_orden,
		  VARCHAR(25) AS tipo_orden,
		  INTEGER AS wf_inc_auto,
          VARCHAR(50) AS marca,
		  VARCHAR(50) AS modelo,
		  SMALLINT AS ano_auto,
		  VARCHAR(10) AS placa,
		  VARCHAR(10) AS tipo_reclamante,
		  CHAR(30) AS chasis,
		  CHAR(8) AS user_added;
		  

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
define _monto               DEC(16,2);
define _tipo_orden          VARCHAR(25);
define _cod_proveedor       CHAR(10);
define _tipo_ord_comp       CHAR(1);
define _no_tranrec          CHAR(10);
define _wf_inc_auto         INTEGER;
define _marca               VARCHAR(50);
define _modelo              VARCHAR(50);
define _ano_auto            SMALLINT;
define _placa               VARCHAR(10);
define _tipo_reclamante     VARCHAR(10);
define _no_chasis           CHAR(30);
define _user_added          CHAR(8);

SET ISOLATION TO DIRTY READ;

FOREACH
	select no_orden,
		   no_reclamo,
		   numrecla,
		   fecha_orden,
		   monto,
		   cod_proveedor,
		   case tipo_ord_comp when "C" then "PIEZAS" else "MECANICA O CHAPISTERIA" end, 
		   tipo_ord_comp,
		   no_tranrec,
		   user_added
	  into _no_orden,
		   _no_reclamo,
		   _numrecla,
		   _fecha_orden,
		   _monto,
		   _cod_proveedor,
		   _tipo_orden,
		   _tipo_ord_comp,
		   _no_tranrec,
		   _user_added
	  from recordma
	 where fecha_orden   >= a_fecha_1
	   and fecha_orden <= a_fecha_2
	   and tipo_ord_comp in ('C','R')
--	   and tipo_ord_comp = 'R'
	   order by no_orden
	   
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
		   ins_fecha
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
		   _ins_fecha
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	 select wf_inc_auto
	   into _wf_inc_auto
	   from rectrmae
	  where no_tranrec = _no_tranrec;
	  
	 select no_chasis
       into _no_chasis
       from emivehic
      where no_motor = _no_motor;	   
	 
	 select nombre 
	   into _taller
	   from cliclien
	  where cod_cliente = _cod_taller;

	 select nombre 
	   into _asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	  
	 select nombre
	   into _ajustador
	   from recajust
	  where cod_ajustador = _ajust_interno;
	  
	 if _perd_total = 1 then 
		let _perdida = "Si"; 
	 else 
	    let _perdida = "No";
	 end if
	 
	 if _ins_tipo = 0 then
		let _tipo_ins = 'Pendiente';
	 elif _ins_tipo = 1 then
		let _tipo_ins = 'Compañia';
	 else
		let _tipo_ins = 'Taller';
	 end if
	 
	 select descripcion
	   into _ins_agengia
	   from insagen
	  where codigo_agencia = _ins_suc;

	 if _formato_unico = 1 then 
		let _formato = "Si"; 
	 else 
	    let _formato = "No";
	 end if

--select a.*, b.cod_tipopago, c.cod_cobertura, d.nombre
--from recordma a, rectrmae b, rectrcob c, prdcober d
--where a.no_tranrec = b.no_tranrec
--and b.no_tranrec = c.no_tranrec
--and c.cod_cobertura = d.cod_cobertura
--and a.fecha_orden >= '01-09-2021'
--and c.monto <> 0
	  	 
	RETURN _no_orden,
	       _cod_taller,
		   _taller,
		   _fecha_orden,
		   _no_tramite,
		   _numrecla,
		   _fecha_reclamo,
	       _hora_reclamo,
	       _fecha_siniestro,
		   _hora_siniestro,
		   _fecha_documento,
		   _no_documento,
		   _no_unidad,
		   _suma_asegurada,
		   _cod_asegurado,
		   _asegurado,
		   _ajustador,
		   _no_motor,
		   _perdida,
		   _date_in,
		   _hora_in,
		   _date_out,
		   _hora_out, 
		   _tipo_ins, 
		   _ins_agengia, 
		   _formato, 
		   _tiene_inspeccion, 
		   _ins_fecha,
		   _monto,
           _tipo_orden,
		   _wf_inc_auto,
		   null,
           null,
           null,
           null,
		   null,
           _no_chasis,
           _user_added with resume;   

END FOREACH


END PROCEDURE;