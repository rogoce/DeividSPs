DROP procedure sp_rec01o;
CREATE PROCEDURE "informix".sp_rec01o(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*",
a_tipoprod  CHAR(255) DEFAULT "*"	
) RETURNING CHAR(18), 
  		    CHAR(100), 
  		    CHAR(20),
  		    DATE,
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    DECIMAL(16,2),
  		    CHAR(50),
  		    CHAR(50),
  		    CHAR(255),
  		    CHAR(7),
  		    CHAR(15),
  		    DECIMAL(16,2),
  		    CHAR(10),
  		    VARCHAR(50);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE _tipo             CHAR(1);
DEFINE v_cliente_nombre  CHAR(100);    
DEFINE v_doc_poliza      CHAR(20);     
DEFINE v_fecha_siniestro DATE;         
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre,v_agente_nombre     CHAR(50);     
DEFINE v_compania_nombre CHAR(50);     
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo,v_codigo       CHAR(10);
DEFINE v_saber		     CHAR(3);
DEFINE _no_poliza        CHAR(10);     
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cliente      CHAR(10);     
DEFINE _periodo          CHAR(7);
define _no_registro		 char(10);
define _sac_notrx        integer;
define _res_comprobante	 char(15);
define _parti_reas		 dec(16,2);
define _cnt              integer;
define _no_tranrec       char(10);
define _valor     		 dec(16,2);
define _transaccion      char(10);
define _incurrido_bruto  dec(16,2);
define _incurrido_neto	 dec(16,2);
DEFINE _n_contrato       varchar(50);

CREATE TEMP TABLE tmp_agente(
		cod_agente			CHAR(5),
		doc_reclamo			CHAR(18),
		doc_poliza			CHAR(20),		
		pagado_bruto		DEC(16,2),		
		pagado_neto			DEC(16,2),	 	
		reserva_bruto		DEC(16,2),  	
		reserva_neto		DEC(16,2),
		incurrido_bruto		DEC(16,2),	
		incurrido_neto		DEC(16,2),	
		cod_ramo			CHAR(3),
		periodo				CHAR(7),
		no_reclamo			CHAR(10),
		seleccionado        SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec01z(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2,
a_sucursal, 
'*', 
a_ramo, 
'*', 
a_ajustador, 
'*', 
'*',
a_tipoprod
); 

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
		numrecla
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
		v_doc_reclamo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla
--  ORDER BY cod_ramo, periodo, numrecla

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH 
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
	END FOREACH

		INSERT INTO tmp_agente(
		cod_agente,			
		doc_reclamo,			
		doc_poliza,			
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		cod_ramo,			
		periodo,
		no_reclamo
		)
		VALUES(
		_cod_agente,			
		v_doc_reclamo,			
		v_doc_poliza,			
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		v_incurrido_bruto,		
		v_incurrido_neto,		
		_cod_ramo,			
		_periodo,
		_no_reclamo
		);
END FOREACH

-- Filtros para Agente

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: ";

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF

    FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
	      INTO v_agente_nombre,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.cod_agente = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_agente_nombre) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT doc_reclamo,			
		doc_poliza,			
		pagado_bruto,		
		pagado_neto,			
		reserva_bruto,		
		reserva_neto,		
		incurrido_bruto,		
		incurrido_neto,		
		cod_ramo,			
		periodo,
		no_reclamo
   INTO	v_doc_reclamo,			
		v_doc_poliza,			
		v_pagado_bruto,		
		v_pagado_neto,			
		v_reserva_bruto,		
		v_reserva_neto,		
		_incurrido_bruto,		
		_incurrido_neto,		
		_cod_ramo,			
		_periodo,
		_no_reclamo
   FROM tmp_agente
  WHERE seleccionado = 1

	SELECT cod_reclamante,
		   fecha_siniestro
	  INTO _cod_cliente,
	  	   v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	let _n_contrato = null;

	FOREACH

		   SELECT transaccion,
		          sum(pagado_bruto),
			      sum(pagado_neto),
			      sum(reserva_bruto),
			      sum(reserva_neto)
		     INTO _transaccion,
		     	  v_pagado_bruto,
				  v_pagado_neto,
				  v_reserva_bruto,
				  v_reserva_neto
		     FROM tmp_incurrido
		    WHERE no_reclamo = _no_reclamo
			GROUP BY transaccion

			let v_incurrido_bruto = 0;
			let v_incurrido_neto  = 0;

			let v_incurrido_bruto = v_pagado_bruto + v_reserva_bruto;
			let v_incurrido_neto  = v_pagado_neto  + v_reserva_neto;

			foreach
				select no_tranrec
				  into _no_tranrec
				  from rectrmae
				 where transaccion = _transaccion

				exit foreach;
			end foreach

  	       let _no_registro = null;

		   foreach
		   		select no_registro
				  into _no_registro
				  from sac999:reacomp
				 where no_tranrec = _no_tranrec

			  exit foreach;
		   end foreach

		   if _no_registro is not null then

		   		select count(*)
				  into _cnt
				  from sac999:reacompasie
				 where no_registro = _no_registro;

				if _cnt > 0 then

				   foreach
				   		select sac_notrx
						  into _sac_notrx
						  from sac999:reacompasie
						 where no_registro = _no_registro

					  exit foreach;
				   end foreach

				   if _sac_notrx is not null then
					  foreach

				   	   select res_comprobante
					     into _res_comprobante
					     from cglresumen
					    where res_notrx = _sac_notrx

					   exit foreach;
					  end foreach
				   end if
				else

				   let _res_comprobante = '';

				end if

		   end if

		   let _valor      = 0;
		   let _parti_reas = 0;

		   if v_incurrido_neto <> 0 then
			   let _valor = v_incurrido_bruto - v_incurrido_neto;
			   if  _valor <> 0 then
				    let _parti_reas = (_valor / v_incurrido_bruto) * 100;
			   end if
		   elif v_pagado_neto <> 0 then
			   let _valor = v_pagado_bruto - v_pagado_neto;
			   if  _valor <> 0 then
				    let _parti_reas = (_valor / v_pagado_bruto) * 100;
			   end if
		   elif v_reserva_neto <> 0 then
			   let _valor = v_reserva_bruto - v_reserva_neto;
			   if  _valor <> 0 then
				    let _parti_reas = (_valor / v_reserva_bruto) * 100;
			   end if
		   else
			   let _parti_reas = 0;
		   end if

	   foreach
		select e.nombre
		  into _n_contrato
	   	  from rectrrea r, reacomae e
	     where r.cod_contrato = e.cod_contrato
           and r.no_tranrec   = _no_tranrec
	       and r.tipo_contrato <> 1

		 exit foreach;
	   end foreach

		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   v_fecha_siniestro, 
			   v_pagado_bruto,		
			   v_pagado_neto,	 	
			   v_reserva_bruto,  	
			   v_reserva_neto,
			   v_incurrido_bruto,	
			   v_incurrido_neto,	
			   v_ramo_nombre,
			   v_compania_nombre,
			   v_filtros,
			   _periodo,
			   _res_comprobante,
			   _parti_reas,
			   _transaccion,
			   _n_contrato
			   WITH RESUME;

  END FOREACH

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_agente;
DROP TABLE tmp_incurrido;
END PROCEDURE                                                                                                                       
