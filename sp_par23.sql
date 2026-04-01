-- Verificacion de la Distribucion de Reseguro en Produccion

DROP PROCEDURE sp_par23;

CREATE PROCEDURE "informix".sp_par23() 

DEFINE _no_poliza		CHAR(10);
DEFINE _no_endoso		CHAR(5);
DEFINE _no_unidad		CHAR(5);
DEFINE _cod_cobertura   CHAR(5);
define _factor          dec(16,6);
DEFINE _vigencia_inic	DATE;
DEFINE _vigencia_final	DATE;
DEFINE _ret_cha			CHAR(30);
DEFINE _ret_sma			SMALLINT;
DEFINE _ret_dec			DEC(16,2);
DEFINE _dias            SMALLINT;

--set debug file to "sp_par23.trc";
--trace on;

--{
foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedcob
  where prima_anual <> 0
	and prima       <> 0
	and prima_neta  = 0
--	and no_poliza   = "32471"
--	and no_endoso   = "00000"
  group by no_poliza, no_endoso
  order by no_poliza, no_endoso

	select vigencia_inic,
	       vigencia_final
	  into _vigencia_inic,
	       _vigencia_final
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	          
	LET _dias = _vigencia_final - _vigencia_inic;

	FOREACH 
	 SELECT no_unidad
	   INTO _no_unidad
	   FROM endeduni
	  WHERE no_poliza = _no_poliza
	    AND no_endoso = _no_endoso

		CALL sp_pro461(_no_poliza, _no_endoso, _no_unidad, _dias) RETURNING _ret_sma, _ret_cha;

	END FOREACH

	CALL sp_pro4611(_no_poliza, _no_endoso) RETURNING _ret_sma, _ret_cha, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec, _ret_dec;

end foreach
--}

END PROCEDURE;
{

	select factor_vigencia
	  into _factor
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedcob
	   set factor_vigencia = _factor
	 where no_poliza       = _no_poliza
	   and no_endoso       = _no_endoso
	   and no_unidad       = _no_unidad
	   and cod_cobertura   = _cod_cobertura;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 0
    and no_factura  is null
    and periodo     <= '2001-06'

	DELETE FROM emifafac WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM emifacon WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endcobde WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedcob WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcuend WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotra WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoaut WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde2 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedacr WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunide WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunire WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endeduni WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedimp WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedrec WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endeddes WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endasien WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedmae WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

end foreach
}