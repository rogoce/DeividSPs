-- Procedimiento para el reporte de los clientes bloqueados por la siniestralidad
--
-- creado: 10/08/2009 - Autor: Amado Perez M.

DROP PROCEDURE sp_rec345;
CREATE PROCEDURE sp_rec345(a_cod_cliente CHAR(255) DEFAULT "*")
	RETURNING VARCHAR(30) as ced_ruc,
	          CHAR(10) as cod_cliente, 
	          VARCHAR(100) as nombre, 
			  CHAR(20) as numrecla, 
			  CHAR(20) as no_documento, 
			  CHAR(5) as no_unidad, 
			  DATE as vigencia_inic,
			  DATE as vigencia_fin,
			  VARCHAR(15) as estatus_audiencia,
			  VARCHAR(50) as mala_referencia,
			  CHAR(8) as usuario_marco,
			  char(10)     as placa,
			  dec(16,2)    as incurrido_reclamo,
			  varchar(255) as filtro;

DEFINE _cod_asegurado        CHAR(10);
DEFINE _cod_reclamante       CHAR(10);
DEFINE _cod_conductor        CHAR(10);
DEFINE _no_reclamo,_placa    CHAR(10);
DEFINE _cod_cliente,_no_poliza CHAR(10);
DEFINE _cnt                  SMALLINT;
DEFINE _numrecla             CHAR(20);
DEFINE _no_documento         CHAR(20);
DEFINE _nombre               varchar(100);
DEFINE _no_unidad            CHAR(5);
DEFINE _tipo_persona         CHAR(1);
DEFINE _cod_mala_refe        CHAR(3);
DEFINE _user_mala_refe   	 CHAR(8);
DEFINE _cedula,_no_motor     VARCHAR(30);
DEFINE _mala_referencia      VARCHAR(50);
DEFINE _estatus_audiencia    SMALLINT;
DEFINE _vigencia_inic        DATE;
DEFINE _vigencia_final       DATE;
DEFINE v_filtros             CHAR(255);
DEFINE _tipo                 CHAR(1);
DEFINE _cant_reg             SMALLINT;
define _estimado,_deducible_pagado,_incurrido_reclamo	dec(16,2);
define _deducible,_deducible_devuel						dec(16,2);
define _incurrido_bruto     							dec(16,2);
define _reserva_inicial,_pago_deducible     			dec(16,2);
define _reserva_actual,v_porc_reas      				dec(16,2);
define _recupero,v_porc_coas							dec(16,2);
define _pagos,_salvamento,_incurrido_neto				dec(16,2);

create temp table tmp_reclamos(
no_reclamo      char(10),
cod_cliente		char(10),
seleccionado    smallint default 1,
primary key(no_reclamo, cod_cliente)) with no log;

SET ISOLATION TO DIRTY READ;

LET v_filtros = null;


FOREACH
	SELECT cod_cliente
      INTO _cod_cliente
      FROM cliclien a, climalare b
     WHERE a.cod_mala_refe = b.cod_mala_refe
       AND b.bloqemirenaut = 1	 

	-- Buscando reclamos PERDIDO, FUT-RESPONSABLE
	FOREACH
		 SELECT a.no_reclamo
		   INTO _no_reclamo
		   FROM recrcmae a, emipomae b
		  WHERE a.no_poliza = b.no_poliza
			AND a.fecha_reclamo >= '01/01/2021'
			AND a.estatus_audiencia in (0,8)
			AND a.actualizado = 1
			AND b.cod_ramo in ('002','020')
			AND a.cod_asegurado = _cod_cliente
		 
		 BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION
					
			INSERT INTO tmp_reclamos VALUES(
				_no_reclamo,
				_cod_cliente,
                1);
		 END
	END FOREACH 
 
	FOREACH
		 SELECT a.no_reclamo
		   INTO _no_reclamo
		   FROM recrcmae a, emipomae b
		  WHERE a.no_poliza = b.no_poliza
			AND a.fecha_reclamo >= '01/01/2021'
			AND a.estatus_audiencia in (0,8)
			AND a.actualizado = 1
			AND b.cod_ramo in ('002','020')
			AND a.cod_reclamante = _cod_cliente

		 BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

			INSERT INTO tmp_reclamos  VALUES(
				_no_reclamo,
				_cod_cliente,
                1);
		 END
	END FOREACH
 
	FOREACH
		 SELECT a.no_reclamo
		   INTO _no_reclamo
		   FROM recrcmae a, emipomae b
		  WHERE a.no_poliza = b.no_poliza
			AND a.fecha_reclamo >= '01/01/2021'
			AND a.estatus_audiencia in (0,8)
			AND a.actualizado = 1
			AND b.cod_ramo in ('002','020')
			AND a.cod_conductor = _cod_cliente

		 BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

			INSERT INTO tmp_reclamos  VALUES(
				_no_reclamo,
				_cod_cliente,
                  1);
		 END  	
	END FOREACH
	
	let _cant_reg = 0;
	
	SELECT count(*)
	  INTO _cant_reg
	  FROM tmp_reclamos
	 WHERE cod_cliente = _cod_cliente;
	
    IF _cant_reg is null THEN
		let _cant_reg = 0;
	END IF
	
	IF _cant_reg = 0 THEN
		INSERT INTO tmp_reclamos  VALUES(
			"NOREC",
			_cod_cliente,
			  1);
	end if
	 
END FOREACH

IF a_cod_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cliente: " ||  TRIM(a_cod_cliente);

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_reclamos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT cod_cliente, 
        no_reclamo
   INTO _cod_cliente,
        _no_reclamo
   FROM tmp_reclamos
  WHERE seleccionado = 1
 order by cod_cliente
 
  let _cod_mala_refe = NULL;
  let _estatus_audiencia = NULL;
  let _no_documento = NULL;
  let _vigencia_inic = NULL;
  let _vigencia_final = NULL;

  select tipo_persona,
         cod_mala_refe,
         user_mala_refe,
         cedula,
         nombre		 
	into _tipo_persona,
	     _cod_mala_refe,
		 _user_mala_refe,
		 _cedula,
		 _nombre
	from cliclien
   where cod_cliente = _cod_cliente;

  select nombre
	into _mala_referencia
	from climalare
   where cod_mala_refe = _cod_mala_refe;
   
 if _no_reclamo = "NOREC" then
     foreach
		 select no_documento,
				vigencia_inic,
				vigencia_final
		   into _no_documento,
				_vigencia_inic,
				_vigencia_final
		   from emipomae
		  where cod_contratante = _cod_cliente
			and actualizado = 1
		  order by no_poliza desc
		  exit foreach;
	  end foreach

	  RETURN _cedula,
			 _cod_cliente,
			 _nombre,
			 null,
			 _no_documento,
			 null,
			 _vigencia_inic,
			 _vigencia_final,
			 null,
			 _mala_referencia,
			 _user_mala_refe,
			 "",0,v_filtros	 with resume;
	  
 else
	 select a.numrecla,
			a.no_documento,
			a.no_unidad,
			a.estatus_audiencia,
			a.no_poliza,
			b.vigencia_inic,
			b.vigencia_final			
	   into _numrecla,
			_no_documento,
			_no_unidad,
			_estatus_audiencia,
			_no_poliza,
			_vigencia_inic,
			_vigencia_final
	   from recrcmae a, emipomae b
	  where a.no_poliza = b.no_poliza
		and a.no_reclamo = _no_reclamo;
		
	let _incurrido_reclamo = 0;
	
	call sp_rec33(_no_reclamo) returning 
	   _estimado,   
	   _deducible,  
	   _reserva_inicial,  
	   _reserva_actual,  
	   _pagos,      
	   _recupero,
	   _salvamento, 
	   _deducible_pagado,
	   _deducible_devuel,
	   v_porc_reas,
	   v_porc_coas,
	   _pago_deducible,
	   _incurrido_reclamo,
	   _incurrido_bruto,
	   _incurrido_neto;		
	select no_motor
      into _no_motor
      from emiauto
     where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	   
	select placa
      into _placa
	  from emivehic
	 where no_motor = _no_motor;
		
	  RETURN _cedula,
			 _cod_cliente,
			 _nombre,
			 _numrecla,
			 _no_documento,
			 _no_unidad,
			 _vigencia_inic,
			 _vigencia_final,
			 (case when _estatus_audiencia = 0 then "PERDIDO" else "FUT-RESPONSABLE" end),
			 _mala_referencia,
			 _user_mala_refe,
             _placa,
             _incurrido_reclamo,v_filtros	with resume;
 end if
END FOREACH
DROP TABLE tmp_reclamos;
END PROCEDURE
