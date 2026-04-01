

--DROP PROCEDURE sp_sis33a;
CREATE PROCEDURE sp_sis33a(a_no_poliza CHAR(10),a_no_endoso char(10),a_no_unidad char(5))
RETURNING smallint;

DEFINE _vigencia_inic,_vigencia_final,_fecha_hoy	DATE;
define _no_cambio          smallint;
define _cod_cober_reas     char(3);

SET ISOLATION TO DIRTY READ;

select max(no_cambio)
  into _no_cambio
  from emireaco
 where no_poliza = a_no_poliza;
 
 select vigencia_inic,
        vigencia_final
   into _vigencia_inic,
        _vigencia_final
   from emipouni
  where no_poliza = a_no_poliza
    and no_unidad = a_no_unidad;  

FOREACH
	SELECT cod_cober_reas
	  INTO _cod_cober_reas
	  FROM emifacon
	 WHERE no_poliza = a_no_poliza
	   AND no_endoso = a_no_endoso
	   and no_unidad = a_no_unidad
	 GROUP BY no_unidad, cod_cober_reas

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
	a_no_unidad,
	_no_cambio,
	_cod_cober_reas,
	_vigencia_inic,
	_vigencia_final
	);
END FOREACH

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
  AND no_endoso = a_no_endoso
  and no_unidad = a_no_unidad;

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
  AND no_endoso = a_no_endoso
  and no_unidad = a_no_unidad;

RETURN 0;
END PROCEDURE;