drop procedure sp_rec304a;
create procedure "informix".sp_rec304a(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_sucursal	varchar(255)	default "*",
a_ajustador	varchar(255)	default "*",
a_ramo		varchar(255)	default "*",
a_agente	varchar(255)	default "*")
returning	char(18),
			varchar(100),
			char(20),
			date,
			date,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(255),
			char(3),
			char(50),
			char(1),
			smallint,
			char(20),
			char(3),
			varchar(50),
			dec(16,2),
			char(10),
			date,
			char(1),
			char(5),
			int;	

define v_filtros         varchar(255);
define v_doc_reclamo     char(18);
define v_cliente_nombre  char(100);				 
define v_doc_poliza      char(20);
define v_fecha_siniestro date;
define v_ultima_fecha    date;
define v_pagado_bruto    dec(16,2);
define v_pagado_neto     dec(16,2);
define v_reserva_bruto   dec(16,2);
define v_reserva_neto    dec(16,2);
define v_incurrido_bruto dec(16,2);
define v_incurrido_neto  dec(16,2);
define v_ramo_nombre     char(50);
define v_compania_nombre char(50);
define v_ajustador_int	 char(3);
define v_ajustador_desc	 char(50);

define _nombre_ajust    char(50);
define _ajust_interno   char(50);
define _no_reclamo      char(10);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _cod_cliente     char(10);
define _periodo         char(7);
define _estatus_reclamo	  char(1);
define _estatus_audiencia smallint;
define _cod_abogado		  char(3);
define _estat_aud         char(20);
define _abogado			  varchar(50);
define _variacion_bruta	  dec(16,2);
define _no_tramite        char(10);
define _fecha_reclamo     date;
define _es_perdida		  smallint;
define _no_unidad         char(5);
define _es_perdida_c      char(1);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec304( 
--CALL sp_rec02_reserva( 
a_compania, 
a_agencia, 
a_periodo, 
a_sucursal, 
a_ajustador, 
'*', 
a_ramo, 
a_agente 
) RETURNING v_filtros; 


SET ISOLATION TO DIRTY READ;
FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,		
		periodo,
		numrecla,
		ultima_fecha
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_ultima_fecha
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla

	SELECT cod_reclamante,fecha_siniestro, ajust_interno, estatus_reclamo, estatus_audiencia, cod_abogado,no_tramite,fecha_reclamo,perd_total,no_unidad
	  INTO _cod_cliente, v_fecha_siniestro, v_ajustador_int, _estatus_reclamo, _estatus_audiencia, _cod_abogado,_no_tramite,_fecha_reclamo,_es_perdida,_no_unidad
	  FROM recrcmae
	 WHERE no_reclamo  = _no_reclamo
	   AND actualizado = 1;
	   
	SELECT recajust.nombre
	  INTO v_ajustador_desc
	  FROM recajust  
	 WHERE recajust.cod_ajustador =  v_ajustador_int;
	
	if _es_perdida is null then
		let _es_perdida = 0;
	end if
    if _es_perdida = 0 then
		let _es_perdida_c = '';
	else
		let _es_perdida_c = '*';
	end if

	IF _estatus_audiencia = 0 THEN
	   LET _estat_aud = "Perdido";
	ELIF _estatus_audiencia = 1 THEN
	   LET _estat_aud = "Ganado";
	ELIF _estatus_audiencia = 2 THEN
	   LET _estat_aud = "Por definir";
	ELIF _estatus_audiencia = 3 THEN
	   LET _estat_aud = "Proceso Penal";
	ELIF _estatus_audiencia = 4 THEN
	   LET _estat_aud = "Proceso Civil";
	ELIF _estatus_audiencia = 5 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 6 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 7 THEN
	   LET _estat_aud = "FUT - Ganado";
	ELIF _estatus_audiencia = 8 THEN
	   LET _estat_aud = "FUT - Responsable";
	ELSE
	   LET _estat_aud = NULL;
	END IF

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

    SELECT nombre_abogado
	  INTO _abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;

    SELECT SUM(variacion)
	  INTO _variacion_bruta
	  FROM rectrmae
	 WHERE no_reclamo = _no_reclamo
	   AND actualizado = 1;


	RETURN v_doc_reclamo,
	 	   v_cliente_nombre, 	
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_ultima_fecha,
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros,
		   v_ajustador_int,
		   v_ajustador_desc,
		   _estatus_reclamo,
		   _estatus_audiencia,
		   _estat_aud,
		   _cod_abogado,
		   _abogado,
		   _variacion_bruta,
		   _no_tramite,
		   _fecha_reclamo,
		   _es_perdida_c,
		   _no_unidad,
		   today - _fecha_reclamo
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE                                                        