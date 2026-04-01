
-- Procedimiento para insertar el endoso de pronto pago al momento de recibir remesa
-- RS - 26/08/2009

DROP PROCEDURE sp_pro862a;

CREATE PROCEDURE sp_pro862a(a_no_poliza CHAR(10), a_user CHAR(8), a_prima_bruta_end DEC(16,2)) 
	RETURNING SMALLINT,
				CHAR(100);

DEFINE _no_endoso       	CHAR(5);
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
define  _fecha_hoy          date;
define _vigencia_i          date;
define _fecha_sus           date;
define _dias                integer;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error
 	RETURN _error, 'Error al Actualizar el Endoso ...';
END EXCEPTION

--VERIFICA SI YA SE LE HIZO EL DESCUENTO A LA POLIZA
LET v_existe_end = 0;
let _fecha_hoy = current;
let _dias = 0;


select vigencia_inic,
       fecha_suscripcion
  into _vigencia_i,
       _fecha_sus
  from emipomae
 where no_poliza = a_no_poliza;

if _fecha_sus >	_vigencia_i then
	let _dias = _fecha_hoy - _fecha_sus;
else
	let _dias = _fecha_hoy - _vigencia_i;	
end if

if _dias > 30 then
	RETURN _dias, "Actualización Exitosa...";
end if



	RETURN _dias, "";


END
END PROCEDURE;

