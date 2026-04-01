
DROP PROCEDURE sp_sis166;

CREATE PROCEDURE "informix".sp_sis166(a_no_poliza CHAR(10), a_no_unidad CHAR(5))
--}
RETURNING INTEGER;


DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _no_cambio      SMALLINT;
DEFINE _no_endoso      CHAR(5);
DEFINE _no_unidad      CHAR(5);
DEFINE _cod_cober_reas CHAR(3);
DEFINE _no_cambio_coas CHAR(3);
DEFINE _cnt            SMALLINT;
DEFINE _error     	   SMALLINT; 
DEFINE _cnt2		   SMALLINT;
DEFINE _suma_asegurada DEC(16,2);


SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

--set debug file to "sp_sis166.trc";
--trace on;


BEGIN


LET _no_cambio      = 0;
LET _no_endoso      = '00000';
LET _no_cambio_coas = '000';

{DELETE FROM emireagf WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagc WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagm WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

DELETE FROM emireafa WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireaco WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireama WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;}

SELECT vigencia_inic,
       vigencia_final
  INTO _vigencia_inic,
       _vigencia_final
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

LET	_cnt2 = 0;

SELECT COUNT(*)
  INTO _cnt2
  FROM emifacon
 WHERE no_poliza = a_no_poliza
   AND no_endoso = _no_endoso
   AND no_unidad = a_no_unidad;

if _cnt2 = 0 then
	LET _suma_asegurada = 0.00;

	SELECT suma_asegurada
	  INTO _suma_asegurada
	  FROM emipouni
     WHERE no_poliza = a_no_poliza
       AND no_unidad = a_no_unidad;
    
	LET _error =  sp_proe04(a_no_poliza, a_no_unidad, _suma_asegurada, "001");

    IF _error <> 0 THEN
		RETURN 	_error;
	END IF
end if 

FOREACH
 SELECT	no_unidad,
        cod_cober_reas
   INTO	_no_unidad,
        _cod_cober_reas
   FROM	emifacon
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = _no_endoso
	AND no_unidad = a_no_unidad
  GROUP BY no_unidad, cod_cober_reas

	select count(*)
	  into _cnt
	  from emireama
	 where no_poliza      = a_no_poliza
	   and no_unidad      = a_no_unidad
	   and no_cambio      = _no_cambio
	   and cod_cober_reas = _cod_cober_reas;

	if _cnt = 0 then
		INSERT INTO emireama(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		a_no_poliza, 
		_no_unidad,
		_no_cambio,
		_cod_cober_reas,
		_vigencia_inic,
		_vigencia_final
		);
	end if
END FOREACH

select count(*)
  into _cnt
  from emireaco
 where no_poliza      = a_no_poliza
   and no_unidad      = a_no_unidad;

if _cnt = 0 then

	INSERT INTO emireaco(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	)
	SELECT 
	a_no_poliza, 
	no_unidad,
	_no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	FROM emifacon
	WHERE no_poliza = a_no_poliza
	  AND no_endoso = _no_endoso
	  AND no_unidad = a_no_unidad;
end if

select count(*)
  into _cnt
  from emireafa
 where no_poliza      = a_no_poliza
   and no_unidad      = a_no_unidad;

if _cnt = 0 then

	INSERT INTO emireafa(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	)
	SELECT 
	a_no_poliza, 
	no_unidad,
	_no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	FROM emifafac
	WHERE no_poliza = a_no_poliza
	  AND no_endoso = _no_endoso
	  AND no_unidad = a_no_unidad;
end if

END

RETURN 0;

END

END PROCEDURE;
