-- Informe de Reclamos
-- en un Periodo Dado
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 01/03/2002 - Autor: Armando Moreno M. (Sacar la sucursal de la poliza y no de reclamos)
-- Modificado: 21/06/2002 - Autor: Amado Perez M. (Agregando el filtro de Agentes)
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec303;

CREATE PROCEDURE "informix".sp_rec303(
a_compania	CHAR(3), 
a_periodo1	CHAR(7), 
a_periodo2	CHAR(7)
) RETURNING INT as cantidad,
            DEC(16,2) as incurrido_asegurado,
            DEC(16,2) as incurrido_tercero;
			


{RETURNING CHAR(20) as poliza,
            VARCHAR(30) as cedula,
			VARCHAR(100) as conductor,
			CHAR(30) as chasis,
			SMALLINT AS ano_auto,
			DATE AS fecha_siniestro,
			SMALLINT AS tiene_audiencia,
			DATE AS fecha_audiencia,
			datetime hour to fraction(5) as hora_audiencia,
			VARCHAR(20) as resolucion,
			CHAR(10) AS parte_policivo,
			SMALLINT AS formato_unico,
			SMALLINT AS asis_legal,
			SMALLINT AS cons_legal,
			SMALLINT AS perdida_total,
			INTEGER AS incidente,
			CHAR(10) AS cod_pagador,
			VARCHAR(100) as asegurado,
			CHAR(10) as tramite,
			CHAR(10) as no_reclamo,
			CHAR(20) as numrecla,
			DEC(16,2) as pagado_bruto,
			DEC(16,2) as pagado_neto,
			DEC(16,2) as reserva_bruto,
			DEC(16,2) as reserva_neto,
			DEC(16,2) as incurrido_bruto,
			DEC(16,2) as incurrido_neto,
			SMALLINT as cant_pago,
			SMALLINT as pendiente;
}
DEFINE v_filtros        CHAR(255);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _numrecla        CHAR(20);
DEFINE _pagado_bruto    DEC(16,2);
DEFINE _pagado_neto     DEC(16,2);
DEFINE _reserva_bruto   DEC(16,2);
DEFINE _reserva_neto    DEC(16,2);
DEFINE _incurrido_bruto DEC(16,2);
DEFINE _incurrido_neto  DEC(16,2);
DEFINE _cant_pago       SMALLINT;
DEFINE _pendiente       SMALLINT;
DEFINE _no_documento    CHAR(20);		
DEFINE _cod_pagador     CHAR(10);
DEFINE _asegurado       VARCHAR(100);
DEFINE _cod_conductor   CHAR(10);
DEFINE _no_motor        CHAR(30);
DEFINE _fecha_siniestro DATE;
DEFINE _tiene_audiencia SMALLINT;
DEFINE _fecha_audiencia DATE;
DEFINE _hora_audiencia  datetime hour to fraction(5);
DEFINE _no_resolucion   VARCHAR(20); 
DEFINE _parte_policivo  CHAR(10);
DEFINE _formato_unico   SMALLINT;
DEFINE _asis_legal      SMALLINT;
DEFINE _cons_legal      SMALLINT;
DEFINE _perdida_total   SMALLINT;
DEFINE _incidente       INT;
DEFINE _no_tramite      CHAR(10);
DEFINE _cedula          VARCHAR(30);
DEFINE _conductor       VARCHAR(100);
DEFINE _no_chasis       CHAR(30);
DEFINE _ano_auto        SMALLINT;
define _count           INT;
DEFINE _incurrido_neto_t DEC(16,2);
			
			
SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

--LET  v_compania_nombre = sp_sis01(a_compania);

let v_filtros = sp_rec303b(a_compania, a_periodo1, a_periodo2);

select count(no_reclamo),
       sum(incurrido_neto),
       sum(incurrido_neto_t)	  
  into _count,
       _incurrido_neto,
       _incurrido_neto_t
  from tmp_sinis;
  
return _count,
       _incurrido_neto,
	   _incurrido_neto_t;
   
{FOREACH
	SELECT no_reclamo,
	       no_poliza,
		   numrecla,
		   pagado_bruto,
		   pagado_neto,
		   reserva_bruto,
		   reserva_neto,
		   incurrido_bruto,
		   incurrido_neto,
		   cant_pago,
		   pendiente
	  INTO _no_reclamo,
	       _no_poliza,
		   _numrecla,
		   _pagado_bruto,
		   _pagado_neto,
		   _reserva_bruto,
		   _reserva_neto,
		   _incurrido_bruto,
		   _incurrido_neto,
		   _cant_pago,
		   _pendiente
	  FROM tmp_sinis
	
	-- Informacion de Polizas

	SELECT no_documento,	
		   cod_pagador
	  INTO _no_documento,		
	       _cod_pagador
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	 

	-- Informacion del Cliente

	SELECT nombre
	  INTO _asegurado
	  FROM cliclien 
	 WHERE cod_cliente = _cod_pagador;

    SELECT cod_conductor,
	       no_motor,
		   fecha_siniestro,
		   tiene_audiencia,
		   fecha_audiencia,
		   hora_audiencia,
		   no_resolucion,
		   parte_policivo,
		   formato_unico,
		   asis_legal,
		   cons_legal,
		   perd_total,
		   incidente, 
		   no_tramite
      INTO _cod_conductor,
	       _no_motor,
		   _fecha_siniestro,
		   _tiene_audiencia,
		   _fecha_audiencia,
		   _hora_audiencia,
		   _no_resolucion,
		   _parte_policivo,
		   _formato_unico,
		   _asis_legal,
		   _cons_legal,
		   _perdida_total,
		   _incidente, 
		   _no_tramite
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	 
	 SELECT cedula,
	        nombre
	   INTO _cedula,
	        _conductor
	   FROM cliclien
	  WHERE cod_cliente = _cod_conductor;
	  
	 SELECT no_chasis,
	        ano_auto
	   INTO _no_chasis,
	        _ano_auto
	   FROM emivehic
	  WHERE no_motor = _no_motor;
	  
	  RETURN _no_documento,
	         _cedula,
			 _conductor,
			 _no_chasis,
			 _ano_auto,
			 _fecha_siniestro,
			 _tiene_audiencia,
			 _fecha_audiencia,
			 _hora_audiencia,
			 _no_resolucion,
			 _parte_policivo,
			 _formato_unico,
			 _asis_legal,
			 _cons_legal,
			 _perdida_total,
			 _incidente,
			 _cod_pagador,
			 _asegurado,
			 _no_tramite,
			 _no_reclamo,
			 _numrecla,
			 _pagado_bruto,
			 _pagado_neto,
			 _reserva_bruto,
			 _reserva_neto,
			 _incurrido_bruto,
			 _incurrido_neto,
			 _cant_pago,
			 _pendiente WITH RESUME;
END FOREACH
}

DROP TABLE tmp_sinis;

END PROCEDURE;
