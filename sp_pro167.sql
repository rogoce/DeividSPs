-- Modificando poliza de transporte por certificado
-- 
-- Creado    : 22/05/2006 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_pro167;
CREATE PROCEDURE "informix".sp_pro167(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5))

DEFINE _cod_nave		char(3);
DEFINE _consignado		varchar(50,0);
DEFINE _tipo_embarque	char(1);
DEFINE _clausulas		varchar(50,0);
DEFINE _contenedor		varchar(50,0);
DEFINE _sello			varchar(50,0);
DEFINE _fecha_viaje		date;
DEFINE _viaje_desde		varchar(50,0);
DEFINE _viaje_hasta		varchar(50,0);
DEFINE _sobre			varchar(250,1);

--set debug file to "sp_cwf1.trc";
--trace on;
SET ISOLATION TO DIRTY READ;

-- Actualiza emitrans Transporte Maritimo
SELECT cod_nave,
	   consignado,
	   tipo_embarque,
	   clausulas,
	   contenedor,
	   sello,
	   fecha_viaje,
	   viaje_desde,
	   viaje_hasta,
	   sobre
  INTO _cod_nave,
	   _consignado,
	   _tipo_embarque,
	   _clausulas,
	   _contenedor,
	   _sello,
	   _fecha_viaje,
	   _viaje_desde,
	   _viaje_hasta,
	   _sobre
  FROM endmotra
 WHERE no_poliza = a_no_poliza
   AND no_endoso = a_no_endoso
   AND no_unidad = a_no_unidad;

UPDATE emitrans
   SET cod_nave		 = _cod_nave,
	   consignado	 = _consignado,
	   tipo_embarque = _tipo_embarque,
	   clausulas	 = _clausulas,
	   contenedor	 = _contenedor,
	   sello 		 = _sello,
	   fecha_viaje	 = _fecha_viaje,
	   viaje_desde	 = _viaje_desde,
	   viaje_hasta	 = _viaje_hasta,
	   sobre		 = _sobre
 WHERE no_poliza = a_no_poliza
   AND no_unidad = a_no_unidad;

UPDATE endmotra
   SET cod_nave		 = _cod_nave,
	   consignado	 = _consignado,
	   tipo_embarque = _tipo_embarque,
	   clausulas	 = _clausulas,
	   contenedor	 = _contenedor,
	   sello 		 = _sello,
	   fecha_viaje	 = _fecha_viaje,
	   viaje_desde	 = _viaje_desde,
	   viaje_hasta	 = _viaje_hasta,
	   sobre		 = _sobre
 WHERE no_poliza = a_no_poliza
   AND no_endoso = "00000"
   AND no_unidad = a_no_unidad;


end procedure