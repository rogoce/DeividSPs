-- Procedimiento que Actualiza el Endoso

-- Creado    : 20/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 03/07/2001 - Autor: Demetrio Hurtado Almanza

-- Modificado: 20/01/2003 - Autor: Amado Perez
	-- Se valida en cambio de corredores
	-- que sumen 100% la participacion

-- Modificado: 06/03/2003 - Autor: Demetrio Hurtado Almanza
	-- Se incluyo una rutina para que las polizas canceladas
  	-- que se encuentran en el set de renovaciones sean elimindas
  	-- de alli y se actualice el estatus de motivos de no renovacion
  	-- en la tabla de polizas

-- SIS v.2.0 - DEIVID, S.A.

{
--DROP PROCEDURE sp_amado;

CREATE PROCEDURE sp_amado(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
)
--}
--{

DROP PROCEDURE sp_arregla_data;

CREATE PROCEDURE sp_arregla_data(
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

DEFINE _cod_nave		char(3);
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

-- Lectura de la Tabla de Endosos

--SET DEBUG FILE TO "sp_pro43.trc";
--trace on;

LET _no_fac_orig = NULL;
LET nvo_no_pol = a_no_poliza;
LET _no_endoso = a_no_endoso;

SELECT cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic,
	   vigencia_final,
	   cod_tipocan,
	   prima_bruta,
	   impuesto,
	   prima_neta,
	   descuento,
	   recargo,
	   prima,
	   prima_suscrita,
	   prima_retenida,
	   tiene_impuesto,
	   no_factura,
	   user_added
  INTO _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,	
	   _cod_tipocan,
	   _prima_bruta,	
	   _impuesto,
	   _prima_neta,
	   _descuento,
	   _recargo,
	   _prima,
	   _prima_suscrita,
	   _prima_retenida,
	   _tiene_impuesto,
	   _no_fac_orig,
	   _user_added
  FROM endedmae
 WHERE no_poliza   = a_no_poliza
   AND no_endoso   = a_no_endoso
   AND actualizado = 1;


--ELIF _tipo_mov = 19 THEN		-- Disminucion de Vigencia

	BEGIN

		DEFINE _cambio  CHAR(3);
		DEFINE _renglon SMALLINT;

		DEFINE _no_unidad      CHAR(5);      
		DEFINE _suma_asegurada DECIMAL(16,2);
		DEFINE _prima          DECIMAL(16,2);
		DEFINE _prima_neta     DECIMAL(16,2);
		DEFINE _descuento      DECIMAL(16,2);
		DEFINE _recargo        DECIMAL(16,2);
		DEFINE _impuesto       DECIMAL(16,2);
		DEFINE _prima_bruta,_prima_anual    DECIMAL(16,2);
		DEFINE _cod_cobertura  CHAR(5);
		DEFINE _limite_1       DECIMAL(16,2);
		DEFINE _limite_2       DECIMAL(16,2);
		DEFINE _deducible      CHAR(50);

        -- Se incluye la actualizacion de emipouni y emipocob ** Amado 07/06/2006
         
		FOREACH 
		 SELECT	no_unidad, 
		 		suma_asegurada, 
		 		prima, 
		 		prima_neta, 
		 		descuento, 
		 		recargo, 
		 		impuesto, 
		 		prima_bruta
		   INTO	_no_unidad, 
		   		_suma_asegurada, 
		   		_prima, 
		   		_prima_neta, 
		   		_descuento, 
		   		_recargo, 
		   		_impuesto, 
		   		_prima_bruta
		   FROM	endeduni
		  WHERE no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

		   {		insert into emipouni(
				no_poliza	   ,
				no_unidad	   ,
				cod_ruta	   ,
				cod_producto   ,
				cod_asegurado  ,
				suma_asegurada ,
				prima		   ,
				descuento	   ,
				recargo		   ,
				prima_neta	   ,
				impuesto	   ,
				prima_bruta	   ,
				reasegurada	   ,
				vigencia_inic  ,
				vigencia_final ,
				beneficio_max  ,
				desc_unidad	   ,
				prima_suscrita ,
				prima_retenida ,
				suma_aseg_adic ,
				tipo_incendio  ,
				gastos		   ,
				subir_bo	   ,
				cod_formapag   ,
				cod_perpago	   ,
				no_pagos	   ,
				fecha_primer_pago,
				tipo_tarjeta	 ,
				no_tarjeta		 ,
				fecha_exp		 , 
				cod_banco		 ,  
				cobra_poliza	 ,
				no_cuenta		 ,
				tipo_cuenta		 ,
				cod_pagador,
				activo,
				facturado,
				fecha_emision		 
				)				 
				select			 
				no_poliza		 ,
				no_unidad		 ,
				cod_ruta		 ,
				cod_producto	 ,
				cod_cliente		 ,
				suma_asegurada	 ,
				prima			 ,
				descuento		 ,
				recargo			 ,
				prima_neta		 ,
				impuesto		 ,
				prima_bruta		 ,
				reasegurada		 ,
				vigencia_inic	 ,
				vigencia_final	 ,
				beneficio_max	 ,
				desc_unidad		 ,
				prima_suscrita	 ,
				prima_retenida	 ,
				suma_aseg_adic	 ,
				tipo_incendio	 ,
				gastos			 ,
				subir_bo		 ,
				cod_formapag	 ,
				cod_perpago		   ,
				no_pagos		   ,
				fecha_primer_pago  ,
				tipo_tarjeta	   ,
				no_tarjeta		   ,
				fecha_exp		   ,
				cod_banco		   ,
				cobra_poliza  	   ,
				no_cuenta  		   ,
				tipo_cuenta		   ,
				cod_pagador,
				0,
				0,
				"31/07/2008"		   
				  from endeduni
		  		 WHERE no_poliza = a_no_poliza
		   		   AND no_endoso = a_no_endoso;


			  	insert into emipocob(
				no_poliza		 ,
				no_unidad		 ,
				cod_cobertura	 ,
				orden			 ,
				tarifa			 ,
				deducible		 ,
				limite_1		 ,
				limite_2		 ,
				prima_anual		 ,
				prima			 ,
				descuento		 ,
				recargo			 ,
				prima_neta		 ,
				date_added		 ,
				date_changed	 ,
				factor_vigencia	 ,
				desc_limite1	 ,
				desc_limite2	 ,
				subir_bo		 
				)				 
				select			 
				no_poliza		 ,
				no_unidad		 ,
				cod_cobertura	 ,
				orden			 ,
				tarifa			 ,
				deducible		 ,
				limite_1		 ,
				limite_2		 ,
				prima_anual		 ,
				prima			 ,
				descuento		 ,
				recargo			 ,
				prima_neta		 ,
				date_added		 ,
				date_changed	 ,
				factor_vigencia	 ,
				desc_limite1	 ,
				desc_limite2	 ,
				subir_bo		 
				  from endedcob	 
				 where no_poliza = a_no_poliza;}

			-- Actualizar Unidades



		  {	UPDATE emipouni
			   SET suma_asegurada = suma_asegurada + _suma_asegurada,
			       prima          = prima          + _prima,
			       prima_neta     = prima_neta     + _prima_neta,
			       descuento      = descuento      + _descuento,
			       recargo        = recargo        + _recargo,
			       impuesto       = impuesto       + _impuesto,
			       prima_bruta    = prima_bruta    + _prima_bruta
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad;	}


		  	UPDATE emipouni
			   SET suma_asegurada =  _suma_asegurada,
			       prima          =  _prima,
			       prima_neta     =  _prima_neta,
			       descuento      =  _descuento,
			       recargo        =  _recargo,
			       impuesto       =  _impuesto,
			       prima_bruta    =  _prima_bruta
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad;

			-- Actualizar Coberturas

		   	FOREACH 
			 SELECT	cod_cobertura,
			 		prima,
			 		prima_neta,
			 		descuento,
			 		recargo,
			 		prima_anual,
					limite_1,
					limite_2,
					deducible
			   INTO _cod_cobertura,
			   		_prima,
			   		_prima_neta,
			   		_descuento,
			   		_recargo,
					_prima_anual,
					_limite_1,
					_limite_2,
					_deducible
			   FROM	endedcob
			  WHERE no_poliza = a_no_poliza
			    AND no_endoso = a_no_endoso
			    AND no_unidad = _no_unidad

			  { UPDATE emipocob
			      SET prima         = prima       + _prima,
			          prima_anual   = prima_anual + _prima_anual,
			          prima_neta    = prima_neta  + _prima_neta,
			          descuento     = descuento   + _descuento,
			          recargo	    = recargo     + _recargo,
			          limite_1	    = limite_1    + _limite_1,
			          limite_2	    = limite_2    + _limite_2,
			          deducible     = _deducible
			    WHERE no_poliza     = a_no_poliza
			      AND no_unidad     = _no_unidad
			      AND cod_cobertura = _cod_cobertura; }

			   UPDATE emipocob
			      SET prima         = _prima,
			          prima_anual   = _prima_anual,
			          prima_neta    = _prima_neta,
			          descuento     = _descuento,
			          recargo	    = _recargo,
			          limite_1	    = _limite_1,
			          limite_2	    = _limite_2,
			          deducible     = _deducible
			    WHERE no_poliza     = a_no_poliza
			      AND no_unidad     = _no_unidad
			      AND cod_cobertura = _cod_cobertura;

			END FOREACH
									
 		END FOREACH

	  { UPDATE emipomae
	      SET prima_bruta    = prima_bruta    + _prima_bruta,
	   	      impuesto       = impuesto       + _impuesto,
			  prima_neta     = prima_neta     + _prima_neta,
	   	      descuento      = descuento      + _descuento,
			  recargo        = recargo        + _recargo,
			  prima          = prima          + _prima,
			  prima_suscrita = prima_suscrita + _prima_suscrita,
			  prima_retenida = prima_retenida + _prima_retenida
	    WHERE no_poliza      = a_no_poliza;}

	   UPDATE emipomae
	      SET prima_bruta    = _prima_bruta,
	   	      impuesto       = _impuesto,
			  prima_neta     = _prima_neta,
	   	      descuento      = _descuento,
			  recargo        = _recargo,
			  prima          = _prima,
			  prima_suscrita = _prima_suscrita,
			  prima_retenida = _prima_retenida
	    WHERE no_poliza      = a_no_poliza;

END 

LET _mensaje = 'Actualizacion Exitosa ...';

RETURN 0, _mensaje;

END

END PROCEDURE;