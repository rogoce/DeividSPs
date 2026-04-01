-- Cumulos por Ubicacion detalle poliza
-- 
-- Creado    : 22/05/2012 - Autor: Armando Moreno
-- Modificado: 22/05/2012 - Autor: Armando Moreno
-- 
--
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_pro219b;

CREATE PROCEDURE "informix".sp_pro219b(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_fecha2 DATE)
RETURNING   CHAR(50),  -- Ubicacion
            INT,       -- Cnt. poliza
			DEC(16,2), -- Suma Asegurada
			CHAR(20),  -- Poliza
			CHAR(50),  -- Compania
			smallint,  -- TIPO INCENDIO
			char(50),  --contrantante
			char(30),  --subramo
			char(3),   --coaseguro si o no
			char(30),
			decimal(7,4),
			char(50),
			char(50),
			dec(16,2);

DEFINE v_filtros           		CHAR(255);
DEFINE v_ubicacion         		CHAR(50);
DEFINE v_cnt_poliza        		INT; 
DEFINE v_suma_asegurada    		DEC(16,2);
DEFINE v_retencion         		DEC(16,2);
DEFINE v_excedente         		DEC(16,2);
DEFINE v_facultativo       		DEC(16,2);
DEFINE v_prima			   		DEC(16,2);
DEFINE v_compania_nombre   		CHAR(50);
DEFINE v_nodocumento       		CHAR(20);

DEFINE _no_poliza          		CHAR(10);
DEFINE _no_unidad, _no_endoso	CHAR(5);
DEFINE _cod_ubica          		CHAR(3);
DEFINE _suma     		   		DEC(16,2);
DEFINE _prima    		   		DEC(16,2);
DEFINE _suma_retencion     		DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   		DEC(16,2);
DEFINE _suma_excedente     		DEC(16,2);
DEFINE _porc_partic_suma   		DEC(9,6);
DEFINE _porcentaje		   		DEC(9,6);
DEFINE _tipo_contrato      		SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   		CHAR(5);
DEFINE _mes_contable      		CHAR(2);
DEFINE _ano_contable      		CHAR(4);
DEFINE _periodo           		CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;
define _tipo_incendio           smallint;
define _cod_tipoprod			char(3);
define _cod_subramo				char(3);
define _cod_contratante			char(10);
define _n_aseg                  char(50);
define _coas                    char(3);
define _n_subra,_n_ramo         char(30);
define _cod_ramo                char(3);
define _porc_partic_coas        decimal(7,4);
define _n_prov                  char(50);
define _n_dist					char(50);
define _cod_provincia           char(2);
define _cod_distrito            char(3);
define _cod_manzana             char(15);
define _orden                   smallint;
define _prima_cobrada           dec(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  no_poliza        CHAR(10),
		  no_documento	   CHAR(20),
          cantidad         INT,
          suma_asegurada   DEC(16,2),
		  mal_porc         CHAR(5),
		  retencion        DEC(16,2),
		  cant_ret         INT,
          primer_excedente DEC(16,2),
		  cant_exe         INT,
          facultativo      DEC(16,2),
		  cant_fac         INT,
          prima_terremoto  DEC(16,2),
		  tipo_incendio    smallint,
		  orden            smallint,
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;
let _porc_partic_coas = 0;

FOREACH
   SELECT d.no_poliza, e.no_endoso, d.no_documento, d.fecha_cancelacion
     INTO _no_poliza, _no_endoso, v_nodocumento, _fecha_cancelacion
     FROM emipomae d, endedmae e
    WHERE d.cod_compania = a_compania
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha
	   OR d.vigencia_final IS NULL)
      AND d.fecha_suscripcion <= a_fecha
	  AND d.vigencia_inic < a_fecha
      AND d.actualizado = 1
	  AND e.no_poliza = d.no_poliza
	  AND e.periodo <= _periodo
	  AND e.fecha_emision <= a_fecha
	  AND e.actualizado = 1

	LET _fecha_emision = null;

	IF _fecha_cancelacion <= a_fecha THEN
	 FOREACH
		SELECT fecha_emision
		  INTO _fecha_emision
		  FROM endedmae
		 WHERE no_poliza = _no_poliza
		   AND cod_endomov = '002'
		   AND vigencia_inic = _fecha_cancelacion
	 END FOREACH

	 IF  _fecha_emision <= a_fecha THEN
		CONTINUE FOREACH;
	 END IF
	END IF

	let _prima_cobrada = 0;
	
	let _prima_cobrada = sp_sis424(v_nodocumento, a_fecha2, a_fecha); -->buscando la prima cobrada en terremoto

	if  _prima_cobrada <= 0 then
		continue foreach;
	end if
	  
	LET _cant_ret = 0;
	LET _cant_exe = 0;
	LET _cant_fac = 0;
	LET _mal_porc = '';

	FOREACH
		SELECT tipo_incendio
		  INTO _tipo_incendio
		  FROM emipouni
		 WHERE no_poliza = _no_poliza

		exit foreach;
	end foreach

	if _tipo_incendio is null then
		let _tipo_incendio = 0;
	end if

	IF a_terremoto = 1 THEN

	 FOREACH
		 SELECT	cod_ubica, 
		        no_unidad,
				suma_terremoto, 
				prima_terremoto 
		   INTO _cod_ubica,
		        _no_unidad, 
				_suma, 
				_prima 
		   FROM	endcuend
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 0;

		FOREACH
		 SELECT	no_cambio
		   INTO	_no_cambio
		   FROM	emireama
		  WHERE	no_poliza       = _no_poliza
		    AND no_unidad       = _no_unidad
			AND vigencia_inic   <= a_fecha
			AND (vigencia_final >= a_fecha
			OR vigencia_final IS NULL)
		  ORDER BY no_cambio DESC
				EXIT FOREACH;
		END FOREACH


		FOREACH
			SELECT x.porc_partic_suma,
			       y.tipo_contrato,
				   z.es_terremoto
			  INTO _porc_partic_suma,
			       _tipo_contrato,
				   _es_terremoto
			  FROM emireaco x, reacomae y, reacobre z
			 WHERE x.no_poliza = _no_poliza
			   AND x.no_unidad = _no_unidad
			   AND x.no_cambio = _no_cambio
			   AND y.cod_contrato = x.cod_contrato
			   AND z.cod_cober_reas = x.cod_cober_reas
			   AND z.es_terremoto = 1

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
			   LET _mal_porc = '';
			END IF
		END FOREACH


		IF _es_terremoto = 1 THEN
		    let _orden = sp_sis184(_cod_ubica);
			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_ubica			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       mal_porc         = _mal_porc,
					       retencion        = retencion        + _suma_retencion,
						   cant_ret			= _cant_ret,
						   primer_excedente = primer_excedente + _suma_excedente,
						   cant_exe			= _cant_exe,
						   facultativo      = facultativo	   + _suma_facultativo,
						   cant_fac			= _cant_fac
						--   prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza;
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
						  v_nodocumento,
				          1,
				          _suma,  
						  _mal_porc,
						  _suma_retencion,
						  _cant_ret,
						  _suma_excedente,
						  _cant_exe,
						  _suma_facultativo,
						  _cant_fac,
						  _prima_cobrada,
						  _tipo_incendio,
						  _orden);
			END
		END IF 
	 END FOREACH
	ELSE
	 FOREACH
		 SELECT	cod_ubica, 
		        no_unidad,
				suma_incendio, 
				prima_incendio 
		   INTO _cod_ubica,
		        _no_unidad, 
				_suma, 
				_prima 
		   FROM	endcuend
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 1;

		FOREACH
		 SELECT	no_cambio
		   INTO	_no_cambio
		   FROM	emireama
		  WHERE	no_poliza       = _no_poliza
		    AND no_unidad       = _no_unidad
			AND vigencia_inic   <= a_fecha
			AND (vigencia_final >= a_fecha
			OR vigencia_final IS NULL)
		  ORDER BY no_cambio DESC
				EXIT FOREACH;
		END FOREACH


		FOREACH
			SELECT x.porc_partic_suma,
			       y.tipo_contrato,
				   z.es_terremoto
			  INTO _porc_partic_suma,
			       _tipo_contrato,
				   _es_terremoto
			  FROM emireaco x, reacomae y, reacobre z
			 WHERE y.cod_contrato = x.cod_contrato
			   AND x.no_poliza = _no_poliza
			   AND x.no_unidad = _no_unidad
			   AND x.no_cambio = _no_cambio
			   AND z.cod_cober_reas = x.cod_cober_reas
			   AND z.es_terremoto = 0

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
			   LET _mal_porc = '';
			END IF
		END FOREACH

		IF _es_terremoto = 0 THEN
		    let _orden = sp_sis184(_cod_ubica);
			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_ubica			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       mal_porc         = _mal_porc,
					       retencion        = retencion        + _suma_retencion,
						   cant_ret			= _cant_ret,
						   primer_excedente = primer_excedente + _suma_excedente,
						   cant_exe			= _cant_exe,
						   facultativo      = facultativo	   + _suma_facultativo,
						   cant_fac			= _cant_fac
						 --  prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza;
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
						  v_nodocumento,
				          1,
				          _suma,  
						  _mal_porc,
						  _suma_retencion,
						  _cant_ret,
						  _suma_excedente,
						  _cant_exe,
						  _suma_facultativo,
						  _cant_fac,
						  _prima_cobrada,
						  _tipo_incendio,
						  _orden);
			END
		END IF
	 END FOREACH
	END IF 

--	END FOREACH

END FOREACH

--SET DEBUG FILE TO "sp_pro77.trc";
--TRACE ON;


  FOREACH WITH HOLD

	  SELECT cod_ubica,
	  		 tipo_incendio,
			 cantidad,        
			 suma_asegurada,
			 no_documento,
			 no_poliza,
			 prima_terremoto,
			 orden
		INTO _cod_ubica,
			 _tipo_incendio,
			 v_cnt_poliza,     
			 v_suma_asegurada, 
			 v_nodocumento,
			 _no_poliza,
			 _prima_cobrada,
			 _orden
	   FROM temp_ubica
	  order by orden,_tipo_incendio

	  SELECT nombre
		INTO v_ubicacion
		FROM emiubica
	   WHERE cod_ubica = _cod_ubica;

	  SELECT cod_tipoprod,
	         cod_subramo,
			 cod_contratante,
			 cod_ramo
		INTO _cod_tipoprod,
		     _cod_subramo,
			 _cod_contratante,
			 _cod_ramo
		FROM emipomae
	   WHERE no_poliza = _no_poliza;

	 select nombre
	   into _n_aseg
	   from cliclien
	  where cod_cliente = _cod_contratante;

	 select nombre
	   into _n_ramo
	   from prdramo
	  where cod_ramo    = _cod_ramo;

	 select nombre
	   into _n_subra
	   from prdsubra
	  where cod_ramo    = _cod_ramo
	    and cod_subramo = _cod_subramo;

	 if _cod_tipoprod = '001' or _cod_tipoprod = '002' then
		if _cod_tipoprod = '001' then --Mayoritario
			let _coas = 'MAY';
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = '036';
		else --Minoritario

			let _coas = 'MIN';
   			select porc_partic_ancon
			  into _porc_partic_coas
			  from emicoami
			 where no_poliza = _no_poliza;

            if _porc_partic_coas is null then
			    let _porc_partic_coas = 0.00;
			end if

		end if
	 else
		let _coas = 'NO';
		let _porc_partic_coas = 0.00;
	 end if

   foreach

	   SELECT cod_manzana
	     INTO _cod_manzana
		 FROM emipouni
		WHERE no_poliza = _no_poliza

	   exit foreach;
   end foreach

  if _cod_manzana is null then
     let _n_prov = "";
	 let _n_dist = "";
  else
   SELECT cod_provincia,
          cod_distrito
     INTO _cod_provincia,
	      _cod_distrito
     FROM emiman05
    WHERE cod_manzana = _cod_manzana;

    SELECT nombre
      INTO _n_prov
      FROM emiman01
     WHERE cod_provincia = _cod_provincia;

    SELECT nombre
      INTO _n_dist
      FROM emiman02
     WHERE cod_provincia = _cod_provincia
       AND cod_distrito  = _cod_distrito;

  end if

	RETURN v_ubicacion,
		   v_cnt_poliza,    	
		   v_suma_asegurada,
		   v_nodocumento,
		   v_compania_nombre,
		   _tipo_incendio,
		   _n_aseg,
		   _n_subra,
		   _coas,
		   _n_ramo,
		   _porc_partic_coas,
		   _n_prov,
		   _n_dist,
		   _prima_cobrada
		   WITH RESUME;

END FOREACH

					 
DROP TABLE temp_ubica;

END PROCEDURE;
