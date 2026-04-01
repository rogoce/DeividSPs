-- Procedimiento para bloquear a los clientes por la siniestralidad
--
-- creado: 18/06/2022 - Autor: Amado Perez M.

DROP PROCEDURE sp_rec344;
CREATE PROCEDURE sp_rec344()
	RETURNING CHAR(10) as cod_cliente, 
	          VARCHAR(100) as nombre, 
			  CHAR(20) as numrecla, 
			  CHAR(20) as no_documento, 
			  CHAR(5) as no_unidad, 
			  SMALLINT as cnt_siniestro,
			  CHAR(3) as cod_mala_refe,
			  VARCHAR(50) as referencia,
			  SMALLINT as bloq_auto,
			  DEC(16,2) as prima_cobrada,
			  DEC(16,2) as reserva,
			  DEC(16,2) as siniestro_pagado;  --Incurrido bruto

DEFINE _cod_asegurado        CHAR(10);
DEFINE _cod_reclamante       CHAR(10);
DEFINE _cod_conductor        CHAR(10);
DEFINE _no_reclamo           CHAR(10);
DEFINE _cod_cliente          CHAR(10);
DEFINE _cnt                  SMALLINT;
DEFINE _numrecla             CHAR(20);
DEFINE _no_documento         CHAR(20);
DEFINE _nombre               varchar(100);
DEFINE _no_unidad            CHAR(5);
DEFINE _tipo_persona         CHAR(1);
DEFINE _cod_mala_refe        CHAR(3);
DEFINE _referencia           VARCHAR(50);
DEFINE _bloq_auto            SMALLINT;
DEFINE _mala_referencia      SMALLINT;
DEFINE _monto_total          DEC(16,2);
DEFINE _variacion            DEC(16,2);
DEFINE _monto_cobrado        DEC(16,2);
DEFINE _cod_coasegur         CHAR(3);      
DEFINE _porc_coas            DECIMAL;  
DEFINE _porc_partic_coas     DECIMAL;
DEFINE _sini_pagado          DEC(16,2);
DEFINE _reserva              DEC(16,2);
DEFINE _prima_cobrada        DEC(16,2);
DEFINE _no_poliza            CHAR(10);

create temp table tmp_reclamos(
no_reclamo      char(10),
cod_cliente		char(10),
primary key(no_reclamo, cod_cliente)) with no log;

create temp table tmp_excepcion(
cod_grupo      char(5),
primary key(cod_grupo)) with no log;

SET ISOLATION TO DIRTY READ;

LET _cod_coasegur = sp_sis02('001', '001');

-- Busqueda de los grupos que se van a exceptuar en el proceso

--cod_grupo	nombre	
--1122		GRUPO DUCRUET - BANISI	
--00115		GRUPO PTG	
--1090		COLECTIVO SCOTIABANK -PETROAUTOS	
--124		LIZSENELL BERNAL - BANISI	
--77850		TRASPASO ASSA GENERALI BANISI	
--162		GRUPO INSTACREDIT	

INSERT INTO tmp_excepcion
SELECT cod_grupo 
  FROM cligrupo
 WHERE cod_grupo in ('1122','00115','1090','124','77850','162','78020');

-- Buscando reclamos PERDIDO, FUT-RESPONSABLE
FOREACH
 SELECT a.no_reclamo,
        a.cod_asegurado,
		a.cod_reclamante,
		a.cod_conductor
   INTO _no_reclamo,
        _cod_asegurado,
		_cod_reclamante,
		_cod_conductor
   FROM recrcmae a, emipomae b
  WHERE a.no_poliza = b.no_poliza
    AND a.fecha_reclamo >= '01/01/2021'
    AND a.estatus_audiencia in (0,8)
	AND a.actualizado = 1
	AND b.estatus_poliza = 1
	AND b.cod_ramo in ('002','020')
	AND b.cod_grupo not in (SELECT cod_grupo FROM tmp_excepcion)
 
 BEGIN
	ON EXCEPTION IN(-239)
	END EXCEPTION
			
	INSERT INTO tmp_reclamos VALUES(
		_no_reclamo,
        _cod_asegurado);
 END
 BEGIN
	ON EXCEPTION IN(-239)
	END EXCEPTION

	INSERT INTO tmp_reclamos  VALUES(
		_no_reclamo,
        _cod_reclamante);
 END
 BEGIN
	ON EXCEPTION IN(-239)
	END EXCEPTION

    if _cod_conductor is not null then   
		INSERT INTO tmp_reclamos  VALUES(
			_no_reclamo,
			_cod_conductor);
	end if	
 END  	
END FOREACH


FOREACH
 SELECT cod_cliente, 
        count(no_reclamo)
   INTO _cod_cliente,
        _cnt
   FROM tmp_reclamos
 group by cod_cliente
 having count(no_reclamo) > 1

  let _cod_mala_refe = NULL;
  let _referencia = NULL;
  let _bloq_auto = 0;

  select tipo_persona,
         cod_mala_refe,
         mala_referencia		 
	into _tipo_persona,
	     _cod_mala_refe,
		 _mala_referencia
	from cliclien
   where cod_cliente = _cod_cliente;

  if _tipo_persona <> 'N' then
	continue foreach;
  end if	

  if _mala_referencia is null then
	let _mala_referencia = 0;
  end if 
	 
  if _mala_referencia = 1 then	   
	continue foreach;
  end if  
   
  select nombre,
	     bloqemirenaut
	into _referencia,
	     _bloq_auto
	from climalare
   where cod_mala_refe = '008';
   
  UPDATE cliclien
    SET cod_mala_refe = '008', -- Alta Siniestralidad - Auto
         mala_referencia = 1,
         user_mala_refe = 'DEIVID' -- Alta Siniestralidad - Auto
   WHERE cod_cliente = _cod_cliente; 

	foreach
	 select a.numrecla,
            a.no_documento,
            a.no_unidad,
            a.no_reclamo,
			a.no_poliza
	   into _numrecla,
	        _no_documento,
			_no_unidad,
			_no_reclamo,
			_no_poliza
	   from recrcmae a, emipomae b
	  where a.no_poliza = b.no_poliza
	    AND a.fecha_reclamo >= '01/01/2021'
		AND a.estatus_audiencia in (0,8)
		AND a.actualizado = 1
	    AND (a.cod_asegurado = _cod_cliente
		OR  a.cod_reclamante = _cod_cliente
		OR  a.cod_conductor = _cod_cliente)
		AND b.cod_ramo in ('002','020')
		
	  select nombre	  
        into _nombre
        from cliclien
       where cod_cliente = _cod_cliente;
	   
	  let _variacion = 0; 
	   
	  select sum(variacion)
        into _variacion	  
		from rectrmae
	   where no_reclamo = _no_reclamo
	     and actualizado = 1;
		 
	 if _variacion is null then
		let _variacion = 0; 
	 end if

     let _monto_total = 0;
	 
	 SELECT sum(monto)
	   INTO _monto_total
	   FROM rectrmae
	  WHERE actualizado  = 1
		AND cod_tipotran IN ('004','005','006','007')
		AND no_reclamo   = _no_reclamo 
		AND monto        <> 0;

	 if _monto_total is null then
		let _monto_total = 0; 
	 end if
	
    let _monto_cobrado = 0;
	 
	select sum(prima_neta)
	  into _monto_cobrado
	  from cobredet
	 where doc_remesa = _no_documento
	   and actualizado = 1
	   and tipo_mov in ('P','N','X');
	 --  and fecha <= a_fecha_calculo;

	if _monto_cobrado is null then
		let _monto_cobrado = 0.00;
	end if      	  	 
	
	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	select porc_partic_coas
	  into _porc_partic_coas 
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = "036"; 			

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if
	
	LET _sini_pagado = _monto_total / 100 * _porc_coas;
	LET _reserva = _variacion / 100 * _porc_coas;
	LET _prima_cobrada = _monto_cobrado * _porc_partic_coas / 100;	
      
	  RETURN _cod_cliente,
	         _nombre,
	         _numrecla,
			 _no_documento,
			 _no_unidad,
			 _cnt,
			 _cod_mala_refe,
			 _referencia,
			 _bloq_auto,
			 _prima_cobrada,
			 _reserva,
			 _sini_pagado with resume;
	end foreach		 
END FOREACH
DROP TABLE tmp_reclamos;
DROP TABLE tmp_excepcion;
END PROCEDURE
