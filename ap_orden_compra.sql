-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE ap_orden_ompra;

CREATE PROCEDURE "informix".ap_orden_ompra()
returning char(20) as Reclamo,
          date as Fecha_Reclamo,
		  date as Fecha_Siniestro,
		  char(20) as Poliza,
		  char(5) as Unidad,
		  varchar(50) as Ajustador,
		  char(10) as Estatus_Reclamo,
		  char(3) as Cod_Evento,
		  varchar(50) as Evento,
		  char(10) as Cod_Reclamante,
		  varchar(100) as Reclamante,
		  char(30) as Motor,
		  char(10) as Estatus_Orden,
		  dec(16,2) as Monto,
		  char(10) as Cod_Proveedor,
		  varchar(100) as Proveedor,
		  char(10) as Tipo_Orden,
		  char(10) as No_Orden,
		  date as Fecha_Orden;

define _no_poliza	char(10);
define _no_unidad   char(5);
define _no_documento char(20);
define _recargo dec(16,2);
define _recargo_dep dec(16,2);
define _error integer;

define _no_reclamo       char(10);
define v_numrecla        char(20);
define _fecha_reclamo    date;
define _fecha_siniestro  date;
define _ajust_interno    char(3);
define _estatus_reclamo  char(1);
define v_no_motor        char(30);
define _cod_evento       char(3);
define _cod_reclamante   char(10);
define _posible_recobro  smallint;
define _perdida          dec(16,2);
define _deducible        dec(16,2);
define _ajustador        varchar(50);
define _estatus          char(10);
define _evento           varchar(50);
define _reclamante       varchar(100);
define _recobro          char(2);
define _cod_cobertura    char(5);
define _no_orden         char(10);
define _monto            dec(16,2);
define _pagado           smallint;
define _cod_proveedor    char(10);
define _tipo_ord_comp    char(1);
define _fecha_orden      date;
define _no_tranrec       char(10);
define _estatus_orden    char(10);
define _proveedor        varchar(100);
define _tipo_orden       char(10);

SET ISOLATION TO DIRTY READ;

let _recargo = 0;
let _recargo_dep = 0;

FOREACH
 SELECT no_orden,
        monto,
		pagado,
		cod_proveedor,
		tipo_ord_comp,
		fecha_orden,
        no_tranrec
   INTO _no_orden,
        _monto,
		_pagado,
		_cod_proveedor,
		_tipo_ord_comp,
		_fecha_orden,
        _no_tranrec
   FROM recordma
  WHERE fecha_orden >= '01/01/2017'
  
 SELECT no_reclamo
   INTO _no_reclamo
   FROM rectrmae
  WHERE no_tranrec = _no_tranrec;
 
 SELECT	no_reclamo,
 		numrecla,
        fecha_reclamo,
		fecha_siniestro,
        no_poliza,
		no_documento,
		no_unidad,
		ajust_interno,
		estatus_reclamo,
		no_motor,
		cod_evento,
		cod_reclamante,
		posible_recobro
   INTO	_no_reclamo,
   		v_numrecla,
        _fecha_reclamo,
		_fecha_siniestro,
        _no_poliza,
		_no_documento,
		_no_unidad,
		_ajust_interno,
		_estatus_reclamo,
		v_no_motor,
		_cod_evento,
		_cod_reclamante,
		_posible_recobro
   FROM recrcmae
  WHERE no_reclamo = _no_reclamo;
     
  SELECT nombre
    INTO _ajustador
	FROM recajust
   WHERE cod_ajustador = _ajust_interno;
   
  IF _estatus_reclamo = 'A' THEN
	LET _estatus = 'Abierto';
  ELIF _estatus_reclamo = 'C' THEN
	LET _estatus = 'Cerrado';
  ELIF _estatus_reclamo = 'D' THEN
	LET _estatus = 'Declinado';
  ELIF _estatus_reclamo = 'N' THEN
	LET _estatus = 'No Aplica';
  END IF   
  
  SELECT nombre
    INTO _evento
	FROM recevent
   WHERE cod_evento = _cod_evento;
  
 SELECT nombre
   INTO _reclamante
   FROM cliclien
  WHERE cod_cliente = _cod_reclamante;
  
 IF _pagado = 1 THEN
	LET _estatus_orden = 'Cerrada';
 ELSE
    LET _estatus_orden = 'Abierta';
 END IF
   
 SELECT nombre
   INTO _proveedor
   FROM cliclien
  WHERE cod_cliente = _cod_proveedor;
  
 IF _tipo_ord_comp = 'C' THEN
	LET _tipo_orden = 'Piezas';
 ELSE
	LET _tipo_orden = 'Taller';
 END IF
 
   return v_numrecla,
          _fecha_reclamo,
		  _fecha_siniestro,
		  _no_documento,
		  _no_unidad,
          _ajustador,
		  _estatus,
		  _cod_evento,
		  _evento,
		  _cod_reclamante,
		  _reclamante,
		  v_no_motor,
		  _estatus_orden,
		  _monto,
		  _cod_proveedor,
		  _proveedor,
		  _tipo_orden,
		  _no_orden,
		  _fecha_orden WITH RESUME;
   
end foreach

END PROCEDURE
