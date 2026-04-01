-- Creacion de la Distribucion de Reaseguro


drop procedure sp_par49;

create procedure sp_par49(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning integer,
            char(50);

DEFINE _no_unidad         CHAR(5);
DEFINE _cod_cober_reas    CHAR(3);
DEFINE _orden             SMALLINT; 
DEFINE _no_cambio         SMALLINT;
DEFINE _cant              SMALLINT;
DEFINE _cod_contrato      CHAR(5);
DEFINE _cod_coasegur      CHAR(3); 
DEFINE _porc_partic_reas  DEC(9,6);
DEFINE _porc_comis_fac	  DEC(5,2);
DEFINE _porc_impuesto	  DEC(5,2);
DEFINE _porc_partic_suma  DEC(9,6);
DEFINE _porc_partic_prima DEC(9,6);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

SELECT x.vigencia_inic, 
       x.vigencia_final 
  INTO _vigencia_inic, 
       _vigencia_final
  FROM endedmae x
 WHERE x.no_poliza = a_no_poliza
   AND x.no_endoso = a_no_endoso;

FOREACH
 SELECT	no_unidad 
   INTO _no_unidad 
   FROM	endeduni
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = a_no_endoso

    SELECT MAX(x.no_cambio) 
      INTO _no_cambio
	  FROM emireama x
	 WHERE x.no_poliza = a_no_poliza
	   AND x.no_unidad = _no_unidad;

	if _no_cambio is null then
	    LET _no_cambio = 0;
	end if		

    LET _no_cambio = _no_cambio + 1;

	FOREACH
	 SELECT	cod_cober_reas,
			orden, 
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
	   INTO _cod_cober_reas,
			_orden, 
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima
	   FROM	emifacon
	  WHERE	no_poliza = a_no_poliza
	    AND no_endoso = a_no_endoso
		AND no_unidad = _no_unidad

	 LET _cant = 0;

     SELECT COUNT(*) 
       INTO _cant
	   FROM emireama x
	  WHERE no_poliza      = a_no_poliza
	    AND no_unidad      = _no_unidad
		AND no_cambio      = _no_cambio
		AND cod_cober_reas = _cod_cober_reas;

	    IF _cant = 0 THEN

	 	   INSERT INTO emireama(
				no_poliza,
				no_unidad,
				no_cambio, 
				cod_cober_reas,
				vigencia_inic, 
				vigencia_final)
		   VALUES(a_no_poliza,
				_no_unidad, 
				_no_cambio,
				_cod_cober_reas, 
				_vigencia_inic,
		   	    _vigencia_final);

		END IF

  		INSERT INTO emireaco(
			no_poliza,
			no_unidad,
			no_cambio, 
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma, 
			porc_partic_prima)
  		VALUES(a_no_poliza,
			_no_unidad,
			_no_cambio,
			_cod_cober_reas, 
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima);

		FOREACH
		 SELECT	cod_coasegur,
				porc_partic_reas,
				porc_comis_fac,
				porc_impuesto
		   INTO _cod_coasegur, 
				_porc_partic_reas,
				_porc_comis_fac,
				_porc_impuesto
		   FROM	emifafac
		  WHERE	no_poliza      = a_no_poliza
		    AND no_endoso      = a_no_endoso
			AND no_unidad      = _no_unidad
			AND cod_cober_reas = _cod_cober_reas
			AND orden          = _orden
			AND cod_contrato   = _cod_contrato
		
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
				 porc_impuesto)
			 VALUES(
			  	 a_no_poliza,
				 _no_unidad,
				 _no_cambio,
				 _cod_cober_reas, 
				 _orden,
				 _cod_contrato,
				 _cod_coasegur, 
				 _porc_partic_reas,
				 _porc_comis_fac,
				 _porc_impuesto);

		END FOREACH

	END FOREACH

END FOREACH

end

return 0, "Actualizacion Exitosa";

end procedure