-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE sp_rea41;

CREATE PROCEDURE "informix".sp_rea41(a_documento CHAR(20), a_asegurador CHAR(3))
returning char(10) as no_poliza,
          char(10) as no_factura,
          date as fecha_emision,
		  date as vigencia_inic,
		  date as vigencia_final,
		  char(7) as periodo,
		  dec(16,2) as prima,
		  dec(16,2) as prima_neta,
		  dec(16,2) as saldo,
		  varchar(50) as tipo_endoso;

define _no_poliza	    char(10);
define _no_endoso       char(5);
define _fecha_emision   date;
define _no_factura      char(10);
define _periodo         char(7);
define _cod_endomov     char(3);
define _vigencia_inic   date;
define _vigencia_final  date;
define _endomov         varchar(50);
define ld_comision      dec(16,2);  
define ld_impuesto      dec(16,2); 
define _prima           dec(16,2);
define _monto_comision  dec(16,2);
define _monto_impuesto  dec(16,2);
define _debito          dec(16,2);
define _credito         dec(16,2);
define _prima_neta      dec(16,2);
define _saldo           dec(16,2);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION
	RETURN _no_poliza, _no_factura, null, null, null, null, null, null, null, null;
END EXCEPTION

FOREACH
 SELECT	no_poliza,
 		no_endoso,
		fecha_emision,
		no_factura,
		periodo,
		cod_endomov
   INTO	_no_poliza,
 		_no_endoso,
		_fecha_emision,
		_no_factura,
		_periodo,
		_cod_endomov
   FROM endedmae
  WHERE no_documento = a_documento
    AND actualizado = 1
ORDER BY fecha_emision DESC
	
 SELECT vigencia_inic,
        vigencia_final
   INTO _vigencia_inic,
        _vigencia_final
   FROM emipomae
  WHERE no_poliza = _no_poliza;
  
 SELECT nombre
   INTO _endomov
   FROM endtimov
  WHERE cod_endomov = _cod_endomov;
  
  SELECT (porc_comis_fac * Sum(prima)/100),
		 (porc_impuesto * Sum(prima)/100),
		 sum(prima),
		 sum(monto_comision),
		 sum(monto_impuesto)
	INTO ld_comision, 
		 ld_impuesto, 
		 _prima,
		 _monto_comision,
		 _monto_impuesto
	FROM emifafac
   WHERE no_poliza = _no_poliza
	 AND no_endoso = _no_endoso
	 AND cod_coasegur = a_asegurador
GROUP BY porc_comis_fac, porc_impuesto;
      
--	 if _prima = 0 or _prima is null then
--		CONTINUE FOREACH;
--	 end if
		 
	 If ld_comision Is Null Then
		Let ld_comision = 0.00;
	 End If
		
	 If ld_impuesto Is Null Then
		Let ld_impuesto = 0.00;
	 End If		 
		 
	 SELECT sum(b.debito),
	        sum(b.credito)
	   INTO _debito,
	        _credito
	   FROM reatrx3 a, reatrx2 b, reatrx1 c
	  WHERE a.no_remesa = b.no_remesa
	    AND a.renglon = b.renglon
		AND b.no_remesa = c.no_remesa
		AND a.no_factura = _no_factura
		AND c.tipo in ('01','02','03','04')
		AND c.actualizado = 1;

	 If _debito Is Null Then
		Let _debito = 0.00;
	 End If
		
	 If _credito Is Null Then
		Let _credito = 0.00;
	 End If		 
		
	if _prima = 0 then
		LET _prima_neta = _prima - _monto_comision - _monto_impuesto;
	else
		LET _prima_neta = _prima - ld_comision - ld_impuesto;
	end if
			 
	LET _saldo = _prima_neta + _debito - _credito;
	
	if _saldo = 0 or _saldo is null then
		continue foreach;
	end if
	
   return _no_poliza,
          _no_factura,
          _fecha_emision,
		  _vigencia_inic,
          _vigencia_final,
          _periodo,
 		  _prima,
		  _prima_neta,
		  _saldo,
          _endomov  WITH RESUME;
end foreach

END
END PROCEDURE
