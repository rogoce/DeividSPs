
--DROP PROCEDURE sp_prueba2;

CREATE PROCEDURE sp_prueba2 () 
	RETURNING SMALLINT;


DEFINE _no_endoso       	CHAR(5);
define a_no_poliza          char(10);
DEFINE _no_endoso_ext		CHAR(5);
DEFINE _no_endoso_ent		INTEGER;
DEFINE _cod_endomov     	CHAR(3);
DEFINE _prima_neta			DEC(16,2);
DEFINE _null            	CHAR(1);

DEFINE v_unidad          	CHAR(5);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_fecha_actual		DATE;
DEFINE v_factor 			DEC(9,6);
DEFINE v_cobertura       	CHAR(5);
DEFINE v_periodo			CHAR(7);

DEFINE _error     	    	SMALLINT;
DEFINE _error_desc			CHAR(30);

DEFINE	v_prima_suscrita	DEC(16,2);
DEFINE 	v_prima_retenida	DEC(16,2);
DEFINE	v_prima				DEC(16,2);
DEFINE	v_total_descto		DEC(16,2);
DEFINE 	v_porc_recargo		DEC(16,2);
DEFINE	v_prima_neta		DEC(16,2);
DEFINE	v_impuesto			DEC(16,2);
DEFINE	v_prima_br			DEC(16,2);
DEFINE  v_suma_asegurada   	DEC(16,2);
DEFINE  v_gastos			DEC(16,2);
DEFINE	v_existe_end		SMALLINT;
DEFINE	v_mes_actual		SMALLINT;
DEFINE	v_mes_string		CHAR(2);

SET ISOLATION TO DIRTY READ;

BEGIN

foreach

select no_poliza,
       no_endoso
  into a_no_poliza,
       _no_endoso
 from endedmae
where actualizado = 0 and cod_endomov = '002' and cod_tipocan = '008' and cod_tipocalc = '005' and date_added = '16/09/2009'

DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Tablas no Tienen Instrucciones Insert
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedhis WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

end foreach


RETURN 0;

END
END PROCEDURE;

