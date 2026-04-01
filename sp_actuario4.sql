DROP procedure sp_actuario4;

CREATE procedure "informix".sp_actuario4(a_periodo1 char(7), a_periodo2 char(7))
RETURNING integer;
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE SINIESTROS PARA RAMO SALUD
---  Armando Moreno M.
--------------------------------------------

BEGIN

    DEFINE v_suma_asegurada                   DECIMAL(16,2);
    DEFINE v_descripcion                      CHAR(50);
	DEFINE _cod_sucursal					  CHAR(3);
	DEFINE _cod_tipoveh						  CHAR(3);
	DEFINE _sucursal                          CHAR(30);
	DEFINE v_filtros                          CHAR(255);
	DEFINE _no_reclamo                        CHAR(10);
	DEFINE _no_poliza                         CHAR(10);
	DEFINE _pagado_total                      dec(16,2);
	DEFINE _reserva_total                     dec(16,2);
	DEFINE _incurrido_bruto                   dec(16,2);
	DEFINE _fecha_siniestro                   dec(16,2);
	DEFINE _numrecla                          CHAR(18);
	DEFINE _perd_total                        SMALLINT;
	DEFINE _no_tranrec                        CHAR(10);
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cnt								  INTEGER;
	DEFINE _tipo                              CHAR(10);
	DEFINE _tipo_vehiculo                     CHAR(50);
	DEFINE _ld_deduc_anter					  dec(16,2);
	DEFINE _prima_anual                       dec(16,2);
	DEFINE _ld_prima_anter					  dec(16,2);
	DEFINE _monto_medico					  dec(16,2);
	DEFINE _reserva_bruto 					  dec(16,2);
	define _a_nombre_de                       char(100);
	define _cod_tipo_pago                     char(3);
	define _n_tipopago                        char(50);
	define _cod_cpt                           char(10);
	define _no_requis                         char(10);
	define _n_proc                            char(100);
	define _valor,_variacion_bruto            dec(16,2);
	define _cedula    						  char(30);
	define _fecha_ani,_vig_ini,_vig_fin		  date;
	define _fecha_cancelacion				  date;
	define _no_documento					  char(20);
	define _cod_contratante                   char(10);



    SET ISOLATION TO DIRTY READ; 

let v_filtros = sp_rec01("001","001",a_periodo1,a_periodo2,"*","*","018;","*","*","*","*","*");

let _n_proc      = "";
let _n_tipopago  = "";
let _a_nombre_de = "";

delete from sinisal8;

foreach

	 select no_reclamo,
	        no_documento,
			no_poliza
	   into _no_reclamo,
	        _no_documento,
			_no_poliza
	   from recrcmae
	  where periodo       >= a_periodo1
	    and periodo       <= a_periodo2
	    and numrecla[1,2] = '18'
	    and actualizado   = 1

	 select fecha_reclamo,
	        numrecla,
			reserva_actual
	   into _fecha_siniestro,
	        _numrecla,
			_variacion_bruto
	   from recrcmae
	  where no_reclamo = _no_reclamo;

	 select vigencia_inic,
	        vigencia_final,
			cod_contratante,
			fecha_cancelacion
	   into _vig_ini,
	        _vig_fin,
			_cod_contratante,
			_fecha_cancelacion
	   from emipomae
	  where	no_poliza = _no_poliza;

	  let _cedula    = null;
	  let _fecha_ani = null;
	  let _fecha_cancelacion = null;

	  select cedula,
	         fecha_aniversario
	    into _cedula,
	         _fecha_ani
	    from cliclien
	   where cod_cliente = _cod_contratante;

	 --call sp_rec33(_no_reclamo) returning _valor,_valor,_valor,_valor,_pagado_total,_valor,_valor,_valor,_valor,_valor,_valor,_valor,_valor,_incurrido_bruto,_valor;
	 SELECT	incurrido_bruto,
            pagado_total
	   INTO	_incurrido_bruto,
			_pagado_total
	   FROM	tmp_sinis
	  where no_reclamo = _no_reclamo
	    and seleccionado = 1; 

		   INSERT INTO sinisal8(
			fecha_not_sini,      
			no_siniestro,        
			monto_pendiente,     
			monto_pagado,        
			monto_incurrido,     
			poliza,
			ced,
			fecha_aniversario,
			vig_ini,
			vig_fin,
			fecha_can
		   )
		   VALUES(
		   _fecha_siniestro,
		   _numrecla,
		   _variacion_bruto,
		   _pagado_total,
		   _incurrido_bruto,
		   _no_documento,
		   _cedula,
		   _fecha_ani,
		   _vig_ini,
		   _vig_fin,
		   _fecha_cancelacion
		   );
END FOREACH

END
END PROCEDURE;
