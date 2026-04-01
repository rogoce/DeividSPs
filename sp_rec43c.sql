-- Procedimiento que Determina las Trnsacciones de Pago de Reclamos
-- 
-- Creado    : 22/01/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec43c;

CREATE PROCEDURE "informix".sp_rec43c(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_fecha    date
) 

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);

DEFINE _reserva_total   DECIMAL(16,2);
DEFINE _reserva_bruto   DECIMAL(16,2);
DEFINE _reserva_neto    DECIMAL(16,2);

DEFINE _porc_coas       DECIMAL;      
DEFINE _porc_reas       DECIMAL;      

DEFINE _cod_coasegur    CHAR(3);      

DEFINE _no_reclamo      CHAR(10);     
DEFINE _transaccion     CHAR(10);     
DEFINE _no_poliza       CHAR(10);     
DEFINE _periodo         CHAR(7);      
DEFINE _numrecla        CHAR(18);     
DEFINE _cod_sucursal    CHAR(3);      
DEFINE _cod_ramo        CHAR(3);      
DEFINE _cod_grupo       CHAR(5);      
DEFINE _fecha           DATE;         
DEFINE _fecha_siniestro DATE;         
DEFINE _cod_tipotran    CHAR(3);

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion 

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal 

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10),
		transaccion          CHAR(10),
		fecha                DATE,
		fecha_siniestro      DATE,
		no_poliza            CHAR(10),
		cod_sucursal         CHAR(3),
		cod_ramo             CHAR(3),
		cod_grupo			 CHAR(5),	
		periodo              CHAR(7),
		numrecla             CHAR(18),
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		cod_tipotran         CHAR(3),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, transaccion)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_ramo);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total   = 0;
LET _monto_bruto   = 0;
LET _monto_neto    = 0;

LET _reserva_total = 0;
LET _reserva_bruto = 0;
LET _reserva_neto  = 0;

FOREACH 
 SELECT a.no_reclamo,	   
 		a.transaccion,	   
 		a.fecha,		
 		a.cod_tipotran,		
 		SUM(a.monto),
 		SUM(a.variacion) 
   INTO _no_reclamo,	
   		_transaccion,		
   		_fecha,		
   		_cod_tipotran,		
   		_monto_total,
   		_reserva_total
   FROM rectrmae a, emipomae p, recrcmae r
  WHERE a.cod_compania = a_compania
    AND a.cod_tipotran = "004"
	AND a.actualizado  = 1
    AND a.fecha        = a_fecha
	and cod_tipopago   = "002"
	and r.no_reclamo   = a.no_reclamo
	and p.no_poliza    = r.no_poliza
	and p.cod_ramo     = "002"
  GROUP BY a.no_reclamo, a.transaccion, a.fecha, a.cod_tipotran
 HAVING SUM(a.monto) <> 0                                                                                                                

	-- Lectura de la Tablas de Reclamos

	SELECT no_poliza,	
		   periodo,	
		   numrecla,	
		   fecha_siniestro,
		   cod_sucursal
	  INTO _no_poliza,	
	  	   _periodo,	
	  	   _numrecla,	
	  	   _fecha_siniestro,
		   _cod_sucursal
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	IF _no_poliza IS NULL THEN
		LET _no_poliza    = '1';
		LET _cod_sucursal = '001';
--		LET _periodo      = a_periodo1;
	END IF

	-- Informacion de Polizas

	SELECT cod_ramo,	cod_grupo
	  INTO _cod_ramo,	_cod_grupo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Informacion de Coseguro
                                                                                                                
	SELECT porc_partic_coas 
	  INTO _porc_coas
      FROM reccoas 
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	-- Informacion de Reaseguro

	LET _porc_reas = 0;

    FOREACH
	SELECT recreaco.porc_partic_suma
	  INTO _porc_reas
	  FROM recreaco, reacomae
	 WHERE recreaco.no_reclamo    = _no_reclamo
	   AND recreaco.cod_contrato  = reacomae.cod_contrato
	   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		EXIT FOREACH;

	END FOREACH 

	-- Calculos

	LET _monto_bruto   = _monto_total   / 100 * _porc_coas;
	LET _monto_neto    = _monto_bruto   / 100 * _porc_reas;

	LET _reserva_bruto = _reserva_total / 100 * _porc_coas;
	LET _reserva_neto  = _reserva_bruto / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	INSERT INTO tmp_sinis(
	no_reclamo,			
	transaccion,
	fecha,
	pagado_total,  		
	pagado_bruto,			
	pagado_neto,
	reserva_total,		
	reserva_bruto,			
	reserva_neto,
	incurrido_total,	
	incurrido_bruto,		
	incurrido_neto,
	no_poliza,				
	cod_ramo,
	periodo,			
	numrecla,				
	cod_grupo,
	fecha_siniestro,
	cod_tipotran,
	cod_sucursal
	)
	VALUES(
	_no_reclamo,		
	_transaccion,
	_fecha,
	_monto_total,		
	_monto_bruto,			
	_monto_neto,
	_reserva_total,		
	_reserva_bruto,			
	_reserva_neto,
	0,					
	0,						
	0,
	_no_poliza,				
	_cod_ramo,
	_periodo,			
	_numrecla,				
	_cod_grupo,
	_fecha_siniestro,
	_cod_tipotran,
	_cod_sucursal
	);

END FOREACH

-- Actualizacion del Incurrido 

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;
                                                     
END PROCEDURE;
