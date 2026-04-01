-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE ap_rec_dias;

CREATE PROCEDURE "informix".ap_rec_dias()
returning varchar(50) as Marca,
          varchar(50) as Modelo,
		  char(30) as Motor,
		  char(10) as Placa,
		  smallint as Ano,
		  varchar(50) as Ajustador,
		  char(20) as Reclamo,
		  date as Fecha_Siniestro,
		  char(20) as Poliza,
		  date as Fecha_Suscripcion,
		  date as Vigencia_Inicial,
		  smallint as Dias,
		  datetime hour to second as Hora_Emision,
		  datetime hour to second as Hora_Siniestro,
		  varchar(50) as Corredor;

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
define _vigencia_inic    date;
define _dias             smallint;
define _cod_marca        char(5);
define _cod_modelo       char(5);
define _marca            varchar(50);
define _modelo           varchar(50);
define _ano_auto         smallint;
define _placa            char(10);
define _fecha_suscripcion date;
define _no_factura       char(10);
define _ind_fecha_emi    datetime hour to second;
define _hora_siniestro   datetime hour to second;
define _cod_agente       char(5);
define _agente           varchar(50);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION
	RETURN null, null, null, null, null, null, null, null, _no_documento, null, null, null, null, null, null;
END EXCEPTION

FOREACH
 SELECT	no_reclamo,
 		numrecla,
 		fecha_siniestro,
        no_poliza,
		no_documento,
		no_unidad,
		ajust_interno,
		no_motor,
		hora_siniestro
   INTO	_no_reclamo,
   		v_numrecla,
		_fecha_siniestro,
        _no_poliza,
		_no_documento,
		_no_unidad,
		_ajust_interno,
		v_no_motor,
		_hora_siniestro
   FROM recrcmae
  WHERE actualizado   = 1
    AND periodo >= '2017-01'
	--AND numrecla[1,2] = '20'
	AND numrecla[1,2] in ('02','20','23')

  FOREACH
	  SELECT vigencia_inic,
	         fecha_suscripcion,
			 no_factura,
			 ind_fecha_emi
		INTO _vigencia_inic,
		     _fecha_suscripcion,
			 _no_factura,
			 _ind_fecha_emi
		FROM emipomae
	   WHERE no_documento = _no_documento
		 AND nueva_renov = 'N'
	  ORDER BY no_poliza DESC

	  EXIT FOREACH;
  END FOREACH 
  
  foreach
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
	 
	 EXIT FOREACH;	  
  end foreach
  
   LET _dias = _fecha_siniestro - _vigencia_inic;
 
    IF _dias <= 15 then --AND _no_documento[12,13] = '09' then
    ELSE
		continue foreach;
	END IF
--  IF _dias > 90 THEN
--	CONTINUE FOREACH;
--  END IF
	   
  SELECT nombre
    INTO _ajustador
	FROM recajust
   WHERE cod_ajustador = _ajust_interno;
   
  SELECT nombre
    INTO _agente
	FROM agtagent
   WHERE cod_agente = _cod_agente;
   
  SELECT cod_marca,
         cod_modelo,
		 ano_auto,
		 placa
	INTO _cod_marca,
	     _cod_modelo,
		 _ano_auto,
		 _placa
	FROM emivehic
   WHERE no_motor = v_no_motor;
   
  SELECT nombre
    INTO _marca
	FROM emimarca
   WHERE cod_marca = _cod_marca;
   
  SELECT nombre
    INTO _modelo
	FROM emimodel
   WHERE cod_marca = _cod_marca
     AND cod_modelo = _cod_modelo;
	
   return _marca,
          _modelo,
		  v_no_motor,
		  _placa,
		  _ano_auto,
          _ajustador,
          v_numrecla,
		  _fecha_siniestro,
 		  _no_documento,
		  _fecha_suscripcion,
		  _vigencia_inic,
		  _dias,
          _ind_fecha_emi,
		  _hora_siniestro,
          _agente WITH RESUME;
   
end foreach

END
END PROCEDURE
