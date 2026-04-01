-- Proceso diario, para actualizar emipomae.montovisa y cobtacre.monto de Tarjetas de Credito
-- emipomae.montovisa y cobtatas.monto de Ach
--
-- Creado    : 24/09/2007 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro702;

CREATE PROCEDURE "informix".sp_pro702()
RETURNING char(20),char(10),smallint,date;


DEFINE _no_documento  CHAR(20);
DEFINE _no_poliza	  CHAR(10);
DEFINE _vigencia_inic DATE;
DEFINE _prima_bruta	  DECIMAL(16,2);
DEFINE _monto_visa    DEC(16,2);
DEFINE _no_pagos      SMALLINT;
DEFINE _no_tarjeta    CHAR(19);
DEFINE _fecha_hoy     DATE;
DEFINE _mes_char	  CHAR(2);
DEFINE _ano_char	  CHAR(4);
DEFINE _periodo       CHAR(7);
DEFINE _mes_vig		  CHAR(2);
DEFINE _ano_vig       CHAR(4);
DEFINE _periodo_vig   CHAR(7);
DEFINE _visa_ren      SMALLINT;
DEFINE _tipo_forma    SMALLINT;
DEFINE _no_cuenta     CHAR(17);

SET ISOLATION TO DIRTY READ;

let _fecha_hoy = today;

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;
let _visa_ren = 0;

--SET DEBUG FILE TO "\\sp_pro702;
--trace on;

FOREACH WITH HOLD

	SELECT e.no_documento
	  INTO _no_documento
	  FROM emipomae e
	 WHERE e.cod_formapag in ("003","005")
	   AND e.actualizado = 1
	   AND e.renovada    = 1
	   AND e.nueva_renov = 'R'
	   AND e.no_renovar  = 0
       AND e.incobrable  = 0
	   AND e.estatus_poliza = 1
	   AND e.cod_ramo <> "019"
	 GROUP BY 1
	 ORDER BY 1

   let _no_poliza = sp_sis21(_no_documento);

   foreach
		SELECT e.no_poliza,
			   e.no_tarjeta, 
			   e.no_documento, 
			   e.vigencia_inic,
			   e.prima_bruta,
			   e.no_pagos,
			   e.monto_visa,
			   e.visa_ren,
			   e.no_cuenta,
			   c.tipo_forma
		  INTO _no_poliza,
			   _no_tarjeta,
			   _no_documento, 
			   _vigencia_inic,
			   _prima_bruta,
			   _no_pagos,
			   _monto_visa,
			   _visa_ren,
			   _no_cuenta,
			   _tipo_forma
		  FROM emipomae e, cobforpa c
		 WHERE e.cod_formapag   = c.cod_formapag
		   AND c.tipo_forma     in(2,4)
		   AND e.no_poliza      = _no_poliza
		   AND e.actualizado    = 1
		   AND e.renovada       = 0
		   AND e.nueva_renov    = 'R'
		   AND e.no_renovar     = 0
	       AND e.incobrable     = 0
		   AND e.estatus_poliza = 1

		IF  MONTH(_vigencia_inic) < 10 THEN
			LET _mes_vig = '0'|| MONTH(_vigencia_inic);
		ELSE
			LET _mes_vig = MONTH(_vigencia_inic);
		END IF

		LET _ano_vig     = YEAR(_vigencia_inic);
		LET _periodo_vig = _ano_vig || "-" || _mes_vig;

		if _periodo_vig = _periodo then

	    	LET _monto_visa = _prima_bruta / _no_pagos;

			if _tipo_forma = 2 then -- Tarjetas de Credito

		   		if _no_tarjeta is not null THEN

					if _monto_visa >= 0 and _visa_ren <> 1 then

					    UPDATE emipomae
					       SET monto_visa = _monto_visa,
				    		   visa_ren   = 1
					     WHERE no_poliza  = _no_poliza;

					    UPDATE cobtacre
					       SET monto        = _monto_visa
					     WHERE no_tarjeta   = _no_tarjeta
						   and no_documento = _no_documento;

					   return _no_documento,_no_poliza,0,_vigencia_inic with resume;

				    end if
				end if

			elif _tipo_forma = 4 then --Ach

				if _no_cuenta is not null THEN

					if _monto_visa >= 0 and _visa_ren <> 1 then

					    UPDATE emipomae
					       SET monto_visa = _monto_visa,
				    		   visa_ren   = 1
					     WHERE no_poliza  = _no_poliza;

					    UPDATE cobcutas
					       SET monto        = _monto_visa
					     WHERE no_cuenta    = _no_cuenta
						   and no_documento = _no_documento;

					   return _no_documento,_no_poliza,0,_vigencia_inic with resume;

				    end if
				end if
			end if

		end if

   end foreach

END FOREACH  

END PROCEDURE;
