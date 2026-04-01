-- Procedimiento que 
-- Creado    : 14/08/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_atc27;

CREATE PROCEDURE "informix".sp_atc27(a_compania CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_cod_agente char(255)) 
RETURNING CHAR(20),        --No documento
		  CHAR(5),          --Cod Agente
		  CHAR(50),        --Nombre Corredor
		  DATE,            --Fecha emision
		  DATE,            --Fecha de comision
		  CHAR(10),        --Estado 
		  CHAR(2),         --Pagado
		  CHAR(10),        --No Factura
		  decimal(16,2),   --Mto. Bono
		  date,            --Fecha desde
		  date;            --Fecha Hasta
		  

DEFINE _no_documento     CHAR(20);      
DEFINE _cod_agente       CHAR(5);
DEFINE _fecha_emision    DATE;
DEFINE _fecha_comision   DATE;
DEFINE _status           CHAR(1);
DEFINE _pagada           SMALLINT;
DEFINE _no_factura       CHAR(10);
DEFINE _estat            CHAR(10);
DEFINE _pagad            CHAR(2);
DEFINE _nombre_corredor  CHAR(50);
DEFINE _mto_bono         DEC(16,2);
DEFINE _tipo             char(1);

LET _estat = '';
LET _pagad  = '';
let _mto_bono = 0;

CREATE TEMP TABLE tmp_salida(
	no_documento	CHAR(20),
	no_recibo		CHAR(10),
	cod_agente      char(5),
	fecha_emision   DATE,
	fecha_comision  DATE,
	estatus         char(10),
	pagada          char(2),
	monto           DEC(16,2),
    nombre_agt      CHAR(50),
	seleccionado    smallint
	) WITH NO LOG;

FOREACH
	SELECT no_documento,
	       cod_agente, 
		   fecha_emision,
		   fecha_comision,
		   estatus,
		   pagada
	  INTO _no_documento,
	       _cod_agente,
		   _fecha_emision,
		   _fecha_comision,
		   _status,
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
	   and bono_salud   = 1
       and fecha_genera = _fecha_comision;
 
    if _mto_bono is null then
		let _mto_bono = 0;
	end if	

	SELECT no_factura
	  INTO _no_factura
	  FROM emipomae
	 WHERE no_documento = _no_documento;
	 
	IF _status = '1' THEN
		LET _estat = 'VIGENTE';
	ELSE
		LET _estat = 'CANCELADA';
    END IF	
	
	IF _pagada = '1' THEN
		LET _pagad = 'SI';
	ELSE
		LET _pagad = 'NO';
	END IF
	
	insert into tmp_salida(
	no_documento,
	no_recibo,	
	cod_agente,  
	fecha_emision,
	fecha_comision,
	estatus,
	pagada,
	monto,
	nombre_agt,
	seleccionado
	)
	values(
	_no_documento,
	_no_factura,
	_cod_agente,
	_fecha_emision,
	_fecha_comision,
	_estat,
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
	select no_documento,
		   no_recibo,		
		   cod_agente,      
		   fecha_emision,   
		   fecha_comision,  
		   estatus,         
		   pagada,          
		   monto,
		   nombre_agt
	  into _no_documento,
		   _no_factura,
		   _cod_agente,
		   _fecha_emision,
		   _fecha_comision,
		   _estat,
		   _pagad,
		   _mto_bono,
		   _nombre_corredor
	  from tmp_salida
	 where seleccionado = 1

	return _no_documento,_cod_agente,_nombre_corredor,_fecha_emision,_fecha_comision,_estat,_pagad,_no_factura,_mto_bono,a_fecha_desde,a_fecha_hasta with resume;
	   
end foreach

drop table tmp_salida;
END PROCEDURE;