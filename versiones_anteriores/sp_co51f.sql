-- Encabezado de los Estados de Cuenta por Grupo y Morosidad (solo con saldos)
-- Creado por :     Roman Gordon	11/01/2011
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co51f;

CREATE PROCEDURE "informix".sp_co51f(
a_compania		CHAR(3), 
a_sucursal		CHAR(3), 
a_cod_grupo		CHAR(10),
a_fecha_desde	DATE,
a_fecha_hasta	DATE,
a_cod_ramo		CHAR(100),
a_user			CHAR(8)
) RETURNING	DATE,       -- vigencia_inic
			DATE,       -- vigencia_final
			CHAR(50),   -- nombre_ramo
			CHAR(50),   -- nombre_subramo
			CHAR(50),   -- nombre_agente
			CHAR(50),	-- nombre_cliente
			CHAR(100),	-- direccion1
			CHAR(100),  -- direccion2
			CHAR(20),   -- telefono1
			CHAR(20),	-- telefono2
			CHAR(10),   -- apartado
			CHAR(20),	-- no_documento
			CHAR(10),   -- no_poliza
			CHAR(30),   -- estatus de la poliza
			DATE,       -- fecha de cancelacion
			DEC(16,2),	-- por vencer
		  	DEC(16,2),	-- exigible
		  	DEC(16,2),	-- corriente
		  	DEC(16,2),	-- monto 30
		  	DEC(16,2),  -- monto 60
		  	DEC(16,2), 	-- monto 60
			DEC(16,2),	-- saldo
			CHAR(50),	-- nombre_grupo
			CHAR(7),	-- periodo
			CHAR(50),	-- forma de pago
			CHAR(8),	char(20);   --celular 

		  	
DEFINE _nombre_grupo		CHAR(50);
DEFINE _nombre_cliente		CHAR(50);
DEFINE _direccion1			CHAR(100);
DEFINE _direccion2			CHAR(100);
DEFINE _telefono1			CHAR(20);
DEFINE _telefono2			CHAR(20);
DEFINE _apartado     		CHAR(10);
DEFINE _no_documento     	CHAR(20);
DEFINE _vigencia_inic    	DATE;
DEFINE _vigencia_final   	DATE;
DEFINE _nombre_agente    	CHAR(50);
DEFINE _nombre_ramo      	CHAR(50);
DEFINE _nombre_subramo   	CHAR(50);
DEFINE _cod_agente       	CHAR(5);
DEFINE _cod_ramo         	CHAR(3);
DEFINE _cod_subramo      	CHAR(3);
DEFINE _no_poliza        	CHAR(10);
DEFINE _estatus_poliza   	INTEGER;
DEFINE _estatus         	CHAR(30);
DEFINE _fecha_cancelacion	DATE;
DEFINE _cod_formapag	  	CHAR(3);
DEFINE _nom_formapag	  	CHAR(50);
DEFINE _por_vencer	 	  	DEC(16,2);
DEFINE _exigible	   	  	DEC(16,2);
DEFINE _corriente		  	DEC(16,2);
DEFINE _monto_30	      	DEC(16,2);
DEFINE _monto_60	      	DEC(16,2);
DEFINE _monto_90	      	DEC(16,2);
DEFINE _saldo		      	DEC(16,2);
DEFINE _por_vencer_tot 	  	DEC(16,2);
DEFINE _exigible_tot   	 	DEC(16,2);
DEFINE _corriente_tot     	DEC(16,2);
DEFINE _monto_30_tot      	DEC(16,2);
DEFINE _monto_60_tot      	DEC(16,2);
DEFINE _monto_90_tot      	DEC(16,2);
DEFINE _saldo_tot         	DEC(16,2);
DEFINE _cod_tipoprod      	CHAR(3);
DEFINE _cod_contratante		CHAR(10);
DEFINE _periodo2			CHAR(7);
DEFINE _periodo				CHAR(7);
DEFINE _periodo_vig_fin		CHAR(7);
DEFINE _tipo				CHAR(1);
DEFINE _tmp_codramo		  	CHAR(3);
DEFINE _flag			  	SMALLINT;
define _celular			    char(20);
let _celular		= "";
SET ISOLATION TO DIRTY READ;

--ENCABEZADO DEL ESTADO DE CUENTA

--set debug file to "sp_co51f.trc";
--trace on;

LET _estatus = "";
LET _estatus_poliza = 0; 

LET _por_vencer_tot	= 0.00;
LET _exigible_tot	= 0.00;
LET _corriente_tot	= 0.00;
LET _monto_30_tot	= 0.00;
LET _monto_60_tot	= 0.00;
LET _monto_90_tot	= 0.00;
LET _saldo_tot		= 0.00;
LET _flag			= 0;			

CALL sp_sis39(a_fecha_hasta) Returning _periodo2;
CALL sp_sis39(a_fecha_desde) Returning _periodo;

IF a_cod_ramo <> "*" THEN
	LET _tipo = sp_sis04(a_cod_ramo);  -- Separa los Valores del String en una tabla de codigos
ELSE
	let a_cod_ramo = ';';
	foreach
		Select cod_ramo
		  into _tmp_codramo
		  from prdramo

		if _flag = 0 then
			let a_cod_ramo = _tmp_codramo || a_cod_ramo;
			let _flag = 1;
		else
			let a_cod_ramo = _tmp_codramo || ',' || a_cod_ramo;
		end if
	end foreach
	LET _tipo = sp_sis04(a_cod_ramo);  -- Separa los Valores del String en una tabla de codigos	   
END IF


-- Seleccion del tipo de produccion
	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emitipro
	 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

-- Datos del Cliente
SELECT nombre
  INTO _nombre_grupo
  FROM cligrupo					 
 WHERE cod_grupo = a_cod_grupo;

-- Polizas del Grupo
	FOREACH
		SELECT no_documento
		  INTO _no_documento
		  FROM emipomae
	     WHERE cod_grupo = a_cod_grupo
		   AND actualizado  = 1
		   AND saldo        > 0.00
		   AND cod_ramo in (Select codigo from tmp_codigos)
		   --AND periodo      <= a_periodo
		   AND cod_tipoprod <> _cod_tipoprod -- Reaseguro Asumido
	   	 GROUP BY no_documento

		LET	 _no_poliza = sp_sis21(_no_documento);
		
		SELECT cod_contratante
		  INTO _cod_contratante
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT nombre,
		       direccion_1,
			   direccion_2,
			   telefono1,
			   telefono2,
			   apartado,       celular
		 INTO  _nombre_cliente,
		       _direccion1,
			   _direccion2,
			   _telefono1,
			   _telefono2,
			   _apartado,       _celular
		 FROM  cliclien					 
		WHERE cod_cliente = _cod_contratante;

-- Datos de la Poliza del Grupo
	   FOREACH	
		SELECT vigencia_inic,
		 	   vigencia_final,
			   cod_ramo,
			   cod_subramo,
			   estatus_poliza,
			   fecha_cancelacion,
			   cod_formapag
		  INTO _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _cod_subramo,
			   _estatus_poliza,
			   _fecha_cancelacion,
			   _cod_formapag
		  FROM emipomae
		 WHERE no_documento = _no_documento
	     ORDER BY vigencia_inic DESC
		EXIT FOREACH;
	   END FOREACH

		CALL sp_sis39(_vigencia_final) Returning _periodo_vig_fin;

		if a_fecha_desde = a_fecha_hasta then
			CALL sp_sis39(_vigencia_inic) Returning _periodo;
		end if
		
		if _periodo_vig_fin < _periodo then
			continue foreach;
		end if

		IF _estatus_poliza = 1 then
			LET _estatus = 'Vigente';
		ELIF _estatus_poliza = 2 then
		    LET _estatus = 'Cancelada';
		ELIF _estatus_poliza = 3 then
		    LET _estatus = 'Vencida';
		ELSE
		    LET _estatus = 'Anulada';
		END IF

	-- Ramo y Subramo
		SELECT nombre
		INTO   _nombre_ramo
		FROM  prdramo
		WHERE cod_ramo = _cod_ramo;	

		SELECT nombre
		INTO   _nombre_subramo
		FROM  prdsubra
		WHERE cod_ramo = _cod_ramo
		AND   cod_subramo = _cod_subramo;
	    
		SELECT nombre
	  	  INTO _nom_formapag
	  	  FROM cobforpa
	 	 WHERE cod_formapag = _cod_formapag;
		
	-- Agente de la Poliza
		FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

		  	SELECT nombre
			  INTO _nombre_agente
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;
		EXIT FOREACH;
	   END FOREACH

	--Sumatoria de la Morosidad Total
	   CALL sp_cob33d(a_compania,a_sucursal,_no_documento,_periodo2,a_fecha_hasta) 
	   RETURNING  _por_vencer,
	   			  _exigible,
				  _corriente,
				  _monto_30,
				  _monto_60,
				  _monto_90,
				  _saldo;

		LET _por_vencer_tot= _por_vencer_tot + _por_vencer;
		LET _exigible_tot  = _exigible_tot   + _exigible;
		LET _corriente_tot = _corriente_tot  + _corriente;
		LET _monto_30_tot  = _monto_30_tot   + _monto_30;
		LET _monto_60_tot  = _monto_60_tot   + _monto_60;
		LET _monto_90_tot  = _monto_90_tot   + _monto_90;
		LET _saldo_tot     = _saldo_tot      + _saldo;


RETURN
   	_vigencia_inic,
	_vigencia_final,
	_nombre_ramo,
	_nombre_subramo,
	_nombre_agente,
	_nombre_cliente,
	_direccion1,
	_direccion2,
	_telefono1,
	_telefono2,
	_apartado,
	_no_documento,
	_no_poliza,
	_estatus,
	_fecha_cancelacion,
	_por_vencer_tot,
	_exigible_tot,
	_corriente_tot,
	_monto_30_tot,
	_monto_60_tot,
	_monto_90_tot,
	_saldo_tot,
	_nombre_grupo,
	_periodo,
	_nom_formapag,
	a_user,       _celular
   	WITH RESUME;

END FOREACH
drop table tmp_codigos;
END PROCEDURE;