-- Estados de Cuenta por Acreedor.	  (todas las polizas)
-- Creado por:     Marquelda Valdelamar 11/01/2001
-- Modificado por: Marquelda Valdelamar 05/07/2002
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_co53bk;

CREATE PROCEDURE "informix".sp_co53bk(
a_compania		CHAR(3), 
a_sucursal		CHAR(3), 
a_cod_acreedor	CHAR(5),
a_fecha_desde	DATE,
a_fecha_hasta	DATE,
a_user			CHAR(8)     
) RETURNING	CHAR(50),	-- nombre_acreedor	--1
			CHAR(50),	-- nombre_cliente	--2
			CHAR(100),	-- direccion1		--3
			CHAR(100),  -- direccion2		--4
			CHAR(20),   -- telefono1		--5
			CHAR(20),	-- telefono2		--6
			CHAR(20),   -- apartado			--7
			CHAR(20),	-- no_documento		--8
			DATE,       -- vigencia_inic	--9
			DATE,       -- vigencia_final	--10
			CHAR(50),   -- nombre_ramo		--11
			CHAR(50),   -- nombre_subramo	--12
			CHAR(50),   -- nombre_agente	--13
			CHAR(20),   -- estatus_poliza	--14
			DATE,       -- fecha_cancelacion--15
			DEC(16,2),	-- por vencer		--16
		  	DEC(16,2),	-- exigible			--17
		  	DEC(16,2),	-- corriente		--18
		  	DEC(16,2),	-- monto 30			--19
		  	DEC(16,2),  -- monto 60			--20
		  	DEC(16,2), 	-- monto 60			--21
			DEC(16,2),	-- saldo			--22
			CHAR(7),	-- periodo			--23
			CHAR(50),	-- forma de pago	--24
			CHAR(8),
			CHAR(20),
			CHAR(50);

DEFINE _nombre_cliente    CHAR(50);
DEFINE _direccion1        CHAR(100);
DEFINE _direccion2        CHAR(100);
DEFINE _telefono1         CHAR(20);
DEFINE _telefono2         CHAR(20);
DEFINE _apartado          CHAR(20);
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;
DEFINE _nombre_agente     CHAR(50);
DEFINE _nombre_acreedor   CHAR(50);
DEFINE _nombre_ramo       CHAR(50);
DEFINE _nombre_subramo    CHAR(50);
DEFINE _cod_agente        CHAR(5);
DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_cliente       CHAR(10);
DEFINE _no_poliza         CHAR(10);
DEFINE _estatus_poliza    INTEGER;
DEFINE _estatus           CHAR(20);
DEFINE _fecha_cancelacion DATE;
DEFINE _cod_formapag	  CHAR(3);
DEFINE _nom_formapag	  CHAR(50);


DEFINE _por_vencer	 	  DEC(16,2);
DEFINE _exigible	   	  DEC(16,2);
DEFINE _corriente		  DEC(16,2);
DEFINE _monto_30	      DEC(16,2);
DEFINE _monto_60	      DEC(16,2);
DEFINE _monto_90	      DEC(16,2);
DEFINE _saldo		      DEC(16,2);

DEFINE _por_vencer_tot 	  DEC(16,2);
DEFINE _exigible_tot   	  DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _cod_tipoprod      CHAR(3);
DEFINE _periodo2		  CHAR(7);
DEFINE _periodo			  CHAR(7);
DEFINE _periodo_vig_fin	  CHAR(7);
DEFINE _tipo			  CHAR(1);
DEFINE _tmp_codramo		  CHAR(3);
DEFINE _flag			  SMALLINT;
DEFINE _celular			  char(20);
DEFINE _cod_asegurado     char(10);
DEFINE _asegurado         char(50);
DEFINE _cnt               integer;


SET ISOLATION TO DIRTY READ;


--set debug file to "sp_co53bk.trc";
--trace on;
--ENCABEZADO DEL ESTADO DE CUENTA
LET _estatus= "";
LET _estatus_poliza = 0;

LET _por_vencer_tot= 0.00;
LET _exigible_tot  = 0.00;
LET _corriente_tot = 0.00;
LET _monto_30_tot  = 0.00;
LET _monto_60_tot  = 0.00;
LET _monto_90_tot  = 0.00;
LET _saldo_tot     = 0.00;
LET _flag			= 0;
LET _cnt = 0;


CALL sp_sis39(a_fecha_hasta) Returning _periodo2;
CALL sp_sis39(a_fecha_desde) Returning _periodo;



-- Seleccion del tipo de produccion
SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

FOREACH
 SELECT b.no_documento       
   INTO _no_documento
   FROM emipoacr a, emipomae b
  WHERE a.cod_acreedor = a_cod_acreedor
    AND a.no_poliza  = b.no_poliza
	AND b.actualizado = 1
	AND cod_tipoprod <> _cod_tipoprod -- Reaseguro Asumido
    GROUP BY b.no_documento
    ORDER BY b.no_documento 
    
   FOREACH
   	SELECT vigencia_inic,
   	       vigencia_final,
           no_poliza,
   	       cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   estatus_poliza,
		   fecha_cancelacion,
		   cod_formapag   
   	  INTO _vigencia_inic,
	       _vigencia_final,
		   _no_poliza,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_cliente,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _cod_formapag
	  FROM emipomae
   	 WHERE no_documento = _no_documento
	   AND actualizado = 1
	   --AND periodo <= a_periodo
   	 ORDER BY vigencia_inic DESC      	  
	 EXIT FOREACH;
   END FOREACH
   
   if a_fecha_desde = a_fecha_hasta then
	CALL sp_sis39(_vigencia_inic) Returning _periodo;
   end if

   CALL sp_sis39(_vigencia_final) Returning _periodo_vig_fin;
   
   if _periodo_vig_fin < _periodo then
   	continue foreach;
   end if 	


--Morosidad Total
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

	IF _estatus_poliza = 1 then
		LET _estatus = 'Vigente';
	ELIF _estatus_poliza = 2 then
	    LET _estatus = 'Cancelada';
	ELIF _estatus_poliza = 3 then
	    LET _estatus = 'Vencida';
	ELSE
	    LET _estatus = 'Anulada';
	END IF

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

-- Datos del Cliente
	SELECT nombre,
	       direccion_1,
		   direccion_2,
		   telefono1,
		   telefono2,
		   apartado,
		   celular
	 INTO  _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _telefono1,
		   _telefono2,
		   _apartado,
		   _celular
	FROM  cliclien					 
	WHERE cod_cliente = _cod_cliente;

	SELECT nombre
	  INTO _nombre_acreedor
	  FROM emiacre
	 WHERE cod_acreedor = a_cod_acreedor;

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

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	if _cnt > 1 then
		let _asegurado = 'Ver Detalle de Unidades';
	elif _cnt = 1 then
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
	else	
		let _asegurado = _nombre_cliente;
	end if

RETURN
	_nombre_acreedor,	 --1
	_nombre_cliente,	 --2
	_direccion1,		 --3
	_direccion2,		 --4
	_telefono1,			 --5
	_telefono2,			 --6
	_apartado,			 --7
	_no_documento,		 --8
	_vigencia_inic,		 --9
	_vigencia_final,	 --10
	_nombre_ramo,		 --11
	_nombre_subramo,	 --12
	_nombre_agente,		 --13
	_estatus,			 --14
	_fecha_cancelacion,	 --15
	_por_vencer_tot,	 --16
	_exigible_tot,		 --17
	_corriente_tot,		 --18
	_monto_30_tot,		 --19
	_monto_60_tot,		 --20
	_monto_90_tot,		 --21
	_saldo_tot,			 --22
	_periodo2,			 --23
	_nom_formapag,		 --24
	a_user,
	_celular,
	_asegurado
	WITH RESUME;

END FOREACH
END PROCEDURE;

