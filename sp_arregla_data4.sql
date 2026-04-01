
--DROP PROCEDURE sp_arregla_data4;

CREATE PROCEDURE sp_arregla_data4(a_periodo char(7))
--}
RETURNING CHAR(20),char(10),char(5),char(10),char(3);

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
DEFINE _no_documento    char(20);
define _no_poliza       char(10);
define _cnt				smallint;
define _no_factura      char(10);
define _cod_ramo		char(3);
define _no_factura_n    char(10);

let _prima_suscrita = 0;

SET ISOLATION TO DIRTY READ;

BEGIN

foreach
	select d.no_poliza,
	       d.no_endoso,
		   d.no_documento,
		   d.no_factura,
		   t.cod_ramo
	  into _no_poliza,
	  	   _no_endoso,
		   _no_documento,
		   _no_factura,
		   _cod_ramo
	  from endedmae d, 
			emipomae t
	 where d.actualizado     = 1
	   and d.cod_sucursal    = '001'
	   and d.no_factura[1,2] = '01'
	   --and d.periodo         = a_periodo
	   and d.no_poliza = t.no_poliza
	   and d.no_poliza = "179530"
       and d.no_endoso = "00054"
	    order by t.cod_ramo
/*
		select count(*)
		  into _cnt
		  from endedmae
		 where no_factura = _no_factura;

		if _cnt > 1 then*/

				--if _cod_ramo = "020" then

					let _no_factura_n = "";
					let _no_factura_n = sp_sis14("001", "001", _no_poliza);

					  UPDATE endedmae  
						 SET no_factura = _no_factura_n 
					   WHERE endedmae.no_poliza =  _no_poliza 
						and  no_endoso = _no_endoso;

					  UPDATE endedhis
						 SET no_factura = _no_factura_n
					   WHERE endedhis.no_poliza =  _no_poliza
						and  no_endoso = _no_endoso;

					RETURN _no_documento,
						   _no_poliza,
						   _no_endoso,
						   _no_factura,
						   _cod_ramo
					  WITH RESUME;

				--end if

		--end if

end foreach

END

END PROCEDURE;