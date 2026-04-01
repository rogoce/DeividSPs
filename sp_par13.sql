DROP PROCEDURE sp_par13;

CREATE PROCEDURE "informix".sp_par13(
a_poliza   CHAR(10), 
a_endoso   CHAR(5),
a_insertar SMALLINT DEFAULT 0
)
RETURNING CHAR(10),
		  CHAR(5),
		  CHAR(5),
          DEC(16,2),
		  DEC(16,2),
		  CHAR(5);

DEFINE _no_unidad     CHAR(5);      
DEFINE _prima         DEC(16,2);    
DEFINE _prima_cob     DEC(16,2);    
DEFINE _prima_reas    DEC(16,2);    
DEFINE _no_endoso     CHAR(5);      
DEFINE ld_porc_coaseg DECIMAL(16,4);
DEFINE ls_ase_lider   CHAR(3);

BEGIN

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_verif(
no_unidad	CHAR(5),
prima_reas	DEC(16,2),
prima_cob	DEC(16,2)
) WITH NO LOG;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par12.trc";      
--TRACE ON;                                                                     

Select par_ase_lider 
  Into ls_ase_lider
  From parparam
 Where cod_compania = '001';

SELECT porc_partic_coas 
  Into ld_porc_coaseg
  FROM endcoama  
 WHERE no_poliza    = a_poliza
   AND no_endoso    = a_endoso
   AND cod_coasegur = ls_ase_lider;

IF ld_porc_coaseg IS NULL THEN
	LET ld_porc_coaseg = 100;
END IF

LET ld_porc_coaseg = ld_porc_coaseg / 100;

FOREACH
 select no_unidad, 
        sum(prima)
   into _no_unidad,
        _prima
   from emifacon
  WHERE no_poliza = a_poliza
    AND no_endoso = a_endoso
  GROUP BY no_unidad

	INSERT INTO tmp_verif
	VALUES (_no_unidad, _prima, 0);

END FOREACH

FOREACH
 select no_unidad, 
        sum(prima_neta)
   into _no_unidad,
        _prima
   from endedcob 
  WHERE no_poliza = a_poliza
    AND no_endoso = a_endoso
  GROUP BY no_unidad

	LET _prima = _prima * ld_porc_coaseg;

	INSERT INTO tmp_verif
	VALUES (_no_unidad, 0, _prima);

END FOREACH

FOREACH
 select no_unidad, 
        SUM(prima_cob),
		SUM(prima_reas)
   into _no_unidad,
        _prima_cob,
		_prima_reas
   from tmp_verif
  GROUP BY no_unidad
  ORDER BY no_unidad

	IF ABS(_prima_cob - _prima_reas) >= 0.00 THEN

{		UPDATE emifacon
		   SET prima     = _prima_cob
		 where no_poliza = a_poliza
		   and no_endoso = a_endoso
		   and no_unidad = _no_unidad;
}
		LET _no_endoso = NULL;

	   FOREACH 	
		SELECT UNIQUE no_endoso
		  INTO _no_endoso
		  FROM emifacon
	     WHERE no_poliza = a_poliza
		   AND no_unidad = _no_unidad
		   AND no_endoso <> a_endoso
			EXIT FOREACH;
		END FOREACH

		IF _no_endoso IS NOT NULL AND
		   a_insertar = 1         THEN

			BEGIN 
			ON EXCEPTION IN(-268)
			END EXCEPTION

				insert into emifacon
				select no_poliza, 
					   a_endoso, 
					   no_unidad, 
					   cod_cober_reas, 
					   orden, 
					   cod_contrato, 
					   cod_ruta,
					   porc_partic_suma, 
					   porc_partic_prima, 
					   suma_asegurada, 
					   prima
				  from emifacon
				 where no_poliza = a_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;

			END 

		END IF

		RETURN a_poliza,
		       a_endoso,
			   _no_unidad,
		       _prima_cob,
		       _prima_reas,
			   _no_endoso
		       WITH RESUME;

	END IF

END FOREACH

DROP TABLE tmp_verif;

END

END PROCEDURE;