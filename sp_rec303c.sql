-- Informe de Reclamos
-- en un Periodo Dado
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 01/03/2002 - Autor: Armando Moreno M. (Sacar la sucursal de la poliza y no de reclamos)
-- Modificado: 21/06/2002 - Autor: Amado Perez M. (Agregando el filtro de Agentes)
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec303c;

CREATE PROCEDURE "informix".sp_rec303c(
a_compania	CHAR(3), 
a_periodo1	CHAR(7), 
a_periodo2	CHAR(7)
) RETURNING CHAR(10) as tramite,
            CHAR(20) as reclamo,
			CHAR(10) as tipo,			
			VARCHAR(100) as nombre,
		    VARCHAR(50) AS marca,
		    VARCHAR(50) AS modelo,
		    SMALLINT AS ano_auto,
			VARCHAR(50) AS agente,
			DATE AS fecha_siniestro,
			DATE AS fecha_reclamo,
			VARCHAR(50) AS evento,			
		    CHAR(10) AS tipo_auto;
			
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

DEFINE _cod_agente      CHAR(10);	
DEFINE _agente          VARCHAR(50);
DEFINE _cod_asegurado   CHAR(10);	
DEFINE _fecha_reclamo   DATE;	
DEFINE _no_unidad       CHAR(5);
DEFINE _cod_evento      CHAR(3);
DEFINE _evento          VARCHAR(50);
define _marca			    varchar(50);
define _modelo		        varchar(50);
define _cod_marca           char(5);
define _cod_modelo          char(5);
define _uso_auto            char(1);
DEFINE _cod_tercero    char(10);
			
SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

--LET  v_compania_nombre = sp_sis01(a_compania);

let v_filtros = sp_rec303b(a_compania, a_periodo1, a_periodo2);
   
FOREACH with hold
	SELECT no_reclamo,
		   numrecla,
		   no_poliza
	  INTO _no_reclamo,
		   _numrecla,
		   _no_poliza
	  FROM tmp_sinis

    FOREACH
     SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
	END FOREACH
	
	SELECT nombre
	  INTO _agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
	
    SELECT cod_asegurado,
	       no_motor,
		   fecha_siniestro,
		   fecha_reclamo,
		   no_tramite,
		   no_unidad,
		   cod_evento
      INTO _cod_asegurado,
	       _no_motor,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _no_tramite,
		   _no_unidad,
		   _cod_evento
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	 
	 SELECT nombre
	   INTO _asegurado
	   FROM cliclien
	  WHERE cod_cliente = _cod_asegurado;

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
	        ano_auto
	   into _cod_marca,
	        _cod_modelo,
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
	
	select nombre 
	  into _evento
	  from recevent
	 where cod_evento = _cod_evento;
  
	  RETURN _no_tramite,
	         _numrecla,
			 "Asegurado",
			 _asegurado,
			 _marca,
			 _modelo,
			 _ano_auto,
			 _agente,
			 _fecha_siniestro,
			 _fecha_reclamo,
			 _evento,
		    (case when _uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end)
			 WITH RESUME;
			 
 FOREACH with hold
	SELECT cod_tercero,
	       no_motor,
		   cod_marca,
		   cod_modelo,
		   ano_auto
	  INTO _cod_tercero,
	       _no_motor,
            _cod_marca,
	        _cod_modelo,
			_ano_auto
	  FROM recterce
	 WHERE no_reclamo = _no_reclamo
	 
	 SELECT nombre
	   INTO _asegurado
	   FROM cliclien
	  WHERE cod_cliente = _cod_tercero;

{	 
    select cod_marca,
	        cod_modelo,
	        ano_auto
	   into _cod_marca,
	        _cod_modelo,
			_ano_auto
	   from emivehic
	  where no_motor = _no_motor;
}	 
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

	  RETURN _no_tramite,
	         _numrecla,
			 "Tercero",
			 _asegurado,
			 _marca,
			 _modelo,
			 _ano_auto,
			 null,
			 null,
			 null,
			 null,
		    (case when _uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end) WITH RESUME;
 
 END FOREACH
END FOREACH


DROP TABLE tmp_sinis;

END PROCEDURE;
