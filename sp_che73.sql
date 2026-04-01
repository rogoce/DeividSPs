-- Procedimiento que Carga las Sobre Comisiones por Corredor
-- Creado    : 07/Junio /2007 - Autor: Rub‚n Dar¡o Arn ez 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che73;

CREATE PROCEDURE sp_che73(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7))

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _gen_cheque      SMALLINT; 
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2); 
DEFINE _comision        DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _fecha_ult_comis DATE;     
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _agente_agrupado CHAR(5);
DEFINE _cod_producto	CHAR(5);
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50);
DEFINE _nombre_clte     CHAR(100); 
DEFINE _cod_cliente     CHAR(10);
DEFINE _tipo           	CHAR(1);
define a_fecha_desde 	DATE;
define a_fecha_hasta 	DATE;
define _nombre_agente   CHAR(50);
define _cod_origen		char(3);
define _vigencia_inic	date;
define _vigencia_final	date;
define _edadpol		  	integer;   

SET ISOLATION TO DIRTY READ;

let a_fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let a_fecha_hasta = sp_sis36(a_periodo);

CREATE TEMP TABLE   tmp_sobrecom(
	cod_agente		CHAR(15),            
	no_poliza		CHAR(10),	         
	no_recibo		CHAR(10),	         
	fecha			DATE,		         
	monto           DEC(16,2),	         
	prima           DEC(16,2),	         
	porc_partic		DEC(5,2),	         
	porc_comis		DEC(5,2),	         
	comision		DEC(16,2),	         
	nombre			CHAR(50),	        
	no_documento    CHAR(20),	        
	monto_vida      DEC(16,2),	        
	monto_danos     DEC(16,2),	        
	monto_fianza    DEC(16,2),	        
	no_licencia     CHAR(10),	        
	nombre_clte    	CHAR(83),			
	seleccionado    SMALLINT DEFAULT 1,
	nombre_agente   CHAR(42),
	agente_agrupado	CHAR(5),
	cod_ramo        CHAR(3),
	cod_subramo     CHAR(3),
	cod_origen		char(3),
	vigencia_inic   date,
	vigencia_final  date,
    edadpol		  	integer, 
	PRIMARY KEY		(cod_agente, no_poliza, no_recibo, fecha)
	) WITH NO LOG;

-- Pagos de Prima y Notas Credito

FOREACH
 SELECT	d.no_poliza,
		d.no_remesa,
		d.renglon,
		d.no_recibo,
		d.fecha,
		d.monto,
		d.prima_neta,
		d.tipo_mov
   INTO	_no_poliza,
		_no_remesa,
		_renglon,
		_no_recibo,
		_fecha,
		_monto,
		_prima,
		_tipo_mov
   FROM	cobredet d, cobremae m
  WHERE	d.cod_compania     = a_compania
    AND d.actualizado      = 1
	AND d.tipo_mov        IN ('P','N')
	AND d.fecha           >= a_fecha_desde
	AND d.fecha           <= a_fecha_hasta
	AND d.no_remesa        = m.no_remesa
	AND m.tipo_remesa      IN ('A', 'M', 'C')

	SELECT no_documento,
		   cod_tipoprod,
		   cod_ramo,
		   cod_subramo,
		   incobrable,
		   cod_origen,
		   vigencia_inic,
		   vigencia_final
	  INTO _no_documento,
		   _cod_tipoprod,
		   _cod_ramo,
		   _cod_subramo,	
		   _incobrable,
		   _cod_origen,
		   _vigencia_inic,
		   _vigencia_final	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

   let _vigencia_final = today;
   let _edadpol = _vigencia_final - _vigencia_inic;

{
    if _edadpol > 366 then
  	   continue foreach;
  	end if
}
     
   	IF _incobrable = 1 THEN
	   CONTINUE FOREACH;
	END IF

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido 

	IF _tipo_prod = 3 OR
	   _tipo_prod = 4 THEN
	   CONTINUE FOREACH;
	END IF
	
	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;

	FOREACH
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon

		SELECT generar_cheque,
			   nombre,
			   no_licencia,
			   fecha_ult_comis,
			   tipo_pago,
			   tipo_agente,
			   agente_agrupado
		  INTO _gen_cheque,
		       _nombre_agente,
			   _no_licencia,
			   _fecha_ult_comis,
			   _tipo_pago,
			   _tipo_agente,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		foreach
		 SELECT cod_producto
		   INTO _cod_producto
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
			exit foreach;	
		end foreach

		SELECT sobrecomision
		  INTO _sobrecomision
		  FROM agtsocom
		 WHERE cod_agente   = _agente_agrupado
		   AND cod_producto = _cod_producto;

		if _sobrecomision is not null then

		    SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

			SELECT nombre
		  INTO _nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

			SELECT no_licencia,
			       nombre
			  INTO _no_licencia2,
			       _nombre2
			  FROM agtagent
			 WHERE cod_agente = _agente_agrupado;

			LET _comision     = _prima * (_sobrecomision / 100);

			BEGIN

				ON EXCEPTION IN(-239)

					UPDATE tmp_sobrecom
					   SET monto        = monto        + _monto,
					       prima        = prima        + _prima,
						   comision     = comision     + _comision
					 WHERE cod_agente   = _agente_agrupado
					   AND no_poliza    = _no_poliza
					   AND no_recibo    = _no_recibo
					   AND fecha        = _fecha;

				END EXCEPTION
			   			  				
				INSERT INTO tmp_sobrecom(
				cod_agente,
				no_poliza,
				no_recibo,
				fecha,
				monto,
				prima,
				porc_partic,
				porc_comis,
				comision,
				nombre,
				no_documento,
				no_licencia,
				nombre_clte,
				nombre_agente,
				agente_agrupado,
				cod_ramo,
				cod_subramo,
				cod_origen,
				vigencia_inic,
				vigencia_final,
				edadpol		
				)
				VALUES(
				_cod_agente,
				_no_poliza,
				_no_recibo,
		      	_fecha,
				_monto,
				_prima,
				100.00,
				_sobrecomision,
				_comision,
				_nombre2,
				_no_documento,
				_no_licencia2,
				_nombre_clte,
				_nombre_agente,
				_agente_agrupado,
				_cod_ramo,
				_cod_subramo,
				_cod_origen,
				_vigencia_inic,
				_vigencia_final,
				_edadpol
	   			);
		   --	   end if	
			END

    	end if
	    
	END FOREACH
	
END FOREACH

END PROCEDURE;