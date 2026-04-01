-- Procedimiento que 
-- Creado    : 14/08/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_atc27a;

CREATE PROCEDURE "informix".sp_atc27a(a_compania CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_cod_agente char(255)) 
RETURNING 
		  CHAR(5),         --Cod Agente
		  CHAR(50),        --Nombre Corredor
		  SMALLINT,        --Pagado
		  decimal(16,2),   --Mto. Pagado
          SMALLINT,        --Pendiente
          DECIMAL(16,2),   -- Mto. Pend		  
		  date,            --Fecha desde
		  date;            --Fecha Hasta
		  
DEFINE _no_documento     CHAR(20);     
DEFINE _cod_agente       CHAR(5);
DEFINE _fecha_emision    DATE;
DEFINE _fecha_comision   DATE;
DEFINE _pagada           SMALLINT;
DEFINE _pagad            CHAR(2);
DEFINE _nombre_corredor  CHAR(50);
DEFINE _mto_bono_pag     DECIMAL(16,2);
DEFINE _mto_bono_pend    DECIMAL(16,2);
DEFINE _tipo             char(1);
DEFINE _monto_paga       SMALLINT;
DEFINE _monto_pend       SMALLINT;
DEFINE _mto_bono         DECIMAL(16,2);

LET _pagad  = '';

CREATE TEMP TABLE tmp_salida(
	cod_agente      char(5),
	pagada          char(2),
	monto           DEC(16,2),
    nombre_agt      CHAR(50),
	seleccionado    smallint
	) WITH NO LOG;

FOREACH
	SELECT no_documento,
	       cod_agente, 
		   fecha_comision,
		   pagada
	  INTO _no_documento,
	       _cod_agente,
		   _fecha_comision,
		   _pagada
	  FROM chqcomsa
     WHERE fecha_emision >= a_fecha_desde
	   AND fecha_emision <= a_fecha_hasta
	   
 
	SELECT nombre 
	  INTO _nombre_corredor
	  FROM agtagent 
	 WHERE cod_agente = _cod_agente;
	
	select sum(comision)
	  into _mto_bono
	  from chqcomis
	 where cod_agente   = _cod_agente
       and no_documento = _no_documento
       and fecha_genera = _fecha_comision;
 
    if _mto_bono is null then
		let _mto_bono = 0;
	end if	
	
	
	IF _pagada = '1' THEN
		LET _pagad = 'SI';
	ELSE
		LET _pagad = 'NO';
	END IF
	
	insert into tmp_salida(
	cod_agente, 
	pagada,
	monto,
	nombre_agt,
	seleccionado
	)
	values(
	_cod_agente,
	_pagad,
	_mto_bono,
	_nombre_corredor,
	1
	);
	
END FOREACH;

IF a_cod_agente <> "*" THEN

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_salida
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_salida
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

foreach
	select cod_agente,                        
		   nombre_agt
	  into _cod_agente,
		   _nombre_corredor
	  from tmp_salida
	 where seleccionado = 1
	 group by cod_agente, nombre_agt
	 
	 select count(pagada)               
	  into _monto_paga
	  from tmp_salida
	 where seleccionado = 1
	 and cod_agente = _cod_agente
	 and pagada = 'SI';
	 
	 select count(pagada)               
	  into _monto_pend
	  from tmp_salida
	 where seleccionado = 1
	 and cod_agente = _cod_agente
	 and pagada = 'NO';
	 
	LET _mto_bono_pag  =  _monto_paga * 25;
	LET _mto_bono_pend =  _monto_pend * 25;

	return _cod_agente,_nombre_corredor,_monto_paga,_mto_bono_pag,_monto_pend,_mto_bono_pend,a_fecha_desde,a_fecha_hasta with resume;
	   
end foreach

drop table tmp_salida;
END PROCEDURE;