


--DROP PROCEDURE sp_arregla_data2;

CREATE PROCEDURE sp_arregla_data2(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
)
--}
RETURNING SMALLINT,
		    CHAR(100);

DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;
DEFINE _prima_bruta     DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _prima           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _no_fac_orig,nvo_no_pol     CHAR(10);
DEFINE _error			SMALLINT;
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _tiene_impuesto	SMALLINT;
DEFINE _no_endoso       CHAR(5);
DEFINE _user_added		CHAR(8);
DEFINE _cod_formapag    CHAR(3);
DEFINE _tipo_forma	    smallint;
define _return			smallint;

DEFINE _cod_asegurado	char(10);
DEFINE _consignado		varchar(50,0);
DEFINE _tipo_embarque	char(1);
DEFINE _clausulas		varchar(50,0);
DEFINE _contenedor		varchar(50,0);
DEFINE _sello			varchar(50,0);
DEFINE _fecha_viaje		date;
DEFINE _viaje_desde		varchar(50,0);
DEFINE _viaje_hasta		varchar(50,0);
DEFINE _sobre			varchar(250,1);
define _orden			smallint;


SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Actualizar el Endoso ...';         
END EXCEPTION           


LET _mensaje   = "Actualizacion exitosa...";

foreach
	select no_unidad,cod_asegurado
	  into _no_unidad,_cod_asegurado
	  from emipouni
	 where no_poliza = a_no_poliza
	 order by 1

	update endeduni
	   set cod_cliente = _cod_asegurado
	 where no_poliza   = a_no_poliza
	   and no_endoso   = a_no_endoso
	   and no_unidad   = _no_unidad;

end foreach

LET _mensaje = 'Actualizacion Exitosa ...';

RETURN 0, _mensaje;

END

END PROCEDURE;