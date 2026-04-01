-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis426;
create procedure "informix".sp_sis426(a_no_documento char(20), a_fecha date, a_fecha2 date)
returning dec(16,2);

define v_prima_cobrada		dec(16,2);
define _porcentaje			dec(7,4);
define v_prima_retencion	dec(16,2);
define v_prima_excedente	dec(16,2);
define v_prima_facultativo	dec(16,2);
define _no_remesa           char(10);
define _renglon           	integer;
define v_tipo_contrato      smallint;
define v_cod_contrato       CHAR(5);
define _porc_partic_prima	dec(9,6);
define _porc_proporcion     dec(5,2);
define v_cobertura          CHAR(3);
define _es_terremoto        smallint;  
define _no_poliza           char(10);     
define v_prima_total        dec(16,2);


-- Prima cobrada para terremoto

let v_prima_cobrada = 0;
let v_prima_retencion = 0;
let v_prima_facultativo = 0;
let v_prima_excedente = 0;
let v_prima_total = 0;

FOREACH
	SELECT d.no_remesa,
	       d.renglon,
	       d.monto,
		   d.no_poliza
	 INTO _no_remesa,
	      _renglon,
	      v_prima_cobrada,
		  _no_poliza
	 FROM cobredet d, cobremae m
	WHERE d.cod_compania = '001'
	  AND d.actualizado  = 1
	  AND d.fecha        >= a_fecha
	  AND d.fecha        <= a_fecha2
	  AND d.tipo_mov     IN ('P','N')
	  AND d.doc_remesa   = a_no_documento
	  AND d.no_remesa    = m.no_remesa
	  AND m.tipo_remesa  IN ('A', 'M', 'C')

	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emicoama
	 WHERE no_poliza    = _no_poliza
	   AND cod_coasegur = "036";
	   
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 100;
	END IF	    

	LET v_prima_cobrada = v_prima_cobrada / 100 * _porcentaje;
	LET v_prima_total = v_prima_total + v_prima_cobrada;
	
			

END FOREACH

return v_prima_total;

end procedure;