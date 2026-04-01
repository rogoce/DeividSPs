-- Procedimiento que Genera los Cobros por Cobrador	semanal, por cobra poliza. 
-- 
-- Creado    : 18/06/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 23/06/2003 - Autor: Marquelda Valdelamar

DROP PROCEDURE sp_cob183;

CREATE PROCEDURE "informix".sp_cob183(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo  CHAR(7)
) RETURNING CHAR(50),  -- Nombre Compania
			INTEGER,   -- Cantidad	
			DEC(16,2), -- Prima Pagada
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			SMALLINT,  -- cnt. por vencer
			SMALLINT,  -- cnt. exigible
			SMALLINT,  -- cnt. corriente
			SMALLINT,  -- cnt. 30
			SMALLINT,  -- cnt. 60
			SMALLINT,  -- cnt. 90
			CHAR(50),  -- nombre_cobrador
			CHAR(50);  -- nombre_Cobra

DEFINE _doc_poliza       CHAR(20); 
DEFINE _monto_pagado     DEC(16,2);
DEFINE _periodo          CHAR(7);
DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _fecha            DATE;

DEFINE _por_vencer       DEC(16,2);
DEFINE _exigible         DEC(16,2);
DEFINE _corriente        DEC(16,2);
DEFINE _monto_30         DEC(16,2);
DEFINE _monto_60         DEC(16,2);
DEFINE _monto_90         DEC(16,2);
DEFINE _saldo_total      DEC(16,2);
DEFINE _cnt_por_vencer   SMALLINT;
DEFINE _cnt_exigible	 SMALLINT;
DEFINE _cnt_corriente	 SMALLINT;
DEFINE _cnt_monto_30	 SMALLINT;
DEFINE _cnt_monto_60	 SMALLINT;
DEFINE _cnt_monto_90	 SMALLINT;

DEFINE _montoTotal       DEC(16,2);
DEFINE _montoPagado      DEC(16,2);

DEFINE _cod_agente       CHAR(5);  
DEFINE _no_poliza        CHAR(10); 
DEFINE _cobra_poliza     CHAR (1);
DEFINE _evaluado         Smallint;
DEFINE _cod_sucursal     CHAR(3);  
DEFINE _cod_cobrador     CHAR(3);  
DEFINE _cod_cobrador_ant CHAR(3);  

DEFINE _incobrable 		 SMALLINT;
DEFINE _nombre_cobrador  CHAR(50);
DEFINE _cod_pagador      CHAR(10);
DEFINE _nombre_cobra     CHAR(50);

DEFINE v_cantidad		   INTEGER;
DEFINE v_monto_pagado      DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);

define _agencia_lider		char(3);
define _centro_costo		char(3);

Let _evaluado = 0;
Let _nombre_cobrador = "";
Let _nombre_cobra    = "";
Let _cod_agente      = "";
Let _cod_cobrador    = "";


SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

CREATE TEMP TABLE tmp_pagos(
		no_documento    CHAR(18)	NOT NULL,
		monto_pagado    DEC(16,2)	NOT NULL
		) WITH NO LOG;

CREATE TEMP TABLE tmp_moros(
		nombre_cobra    CHAR(50),
		nombre_cobrador CHAR(50),
		monto_pagado    DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL,
		cnt_por_vencer  SMALLINT    DEFAULT 0 NOT NULL,
		cnt_exigible    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_corriente   SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_30    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_60    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_90    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_pagado      SMALLINT    DEFAULT 0 NOT NULL
		) WITH NO LOG;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

select par_agencia_lider
  into _agencia_lider
  from parparam
 where cod_compania = a_compania;

FOREACH
 SELECT doc_remesa, 
        monto,
		fecha
   INTO _doc_poliza,
    	_monto_pagado,
		_fecha
   FROM cobredet
  WHERE actualizado  = 1			              -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')           	  -- Pago de Prima(P)
    AND periodo      = a_periodo
--    and doc_remesa   = "0205-01175-01" 
--	and no_remesa    = "195612"

	Let _no_poliza = sp_sis21(_doc_poliza);

	SELECT cod_tipoprod,
	       sucursal_origen
	  INTO _cod_tipoprod,
	       _cod_sucursal
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_compania = a_compania
	   and codigo_agencia  = _cod_sucursal;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 4 then	--Reaseguro Asumido
		continue foreach;
	End if

	If _centro_costo <> "002" then	--Reaseguro Asumido
		continue foreach;
	End if

	INSERT INTO tmp_pagos(
	no_documento,
	monto_pagado
	)
	VALUES(
	_doc_poliza,
	_monto_pagado
	);

END FOREACH

FOREACH 
 SELECT no_documento,
		SUM(monto_pagado)
   INTO	_doc_poliza,     
		_monto_pagado
   FROM tmp_pagos
  GROUP BY no_documento

	Let _no_poliza = sp_sis21(_doc_poliza);

	 SELECT	sucursal_origen,
			cod_tipoprod,
			incobrable,
			cobra_poliza,
			cod_pagador
	  INTO	_cod_sucursal,
			_cod_tipoprod,
			_incobrable,
			_cobra_poliza,
			_cod_pagador
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo,
		 _fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo_total;         

	-- Calcula a que Morosidad Afectan los Montos Pagados

	LET _montoTotal  = _corriente + _monto_30 + _monto_60 + _monto_90 + _por_vencer;
	LET _montoPagado = _monto_pagado;

	IF _montoTotal > 0 THEN

		IF _monto_90 <> 0 THEN

			IF _monto_90 >= _montoPagado THEN

				LET _monto_90    = _montoPagado;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_90;

			END IF	

		END IF

		IF _monto_60 <> 0 THEN

			IF _monto_60 >= _montoPagado THEN

				LET _monto_60    = _montoPagado;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_60;

			END IF	

		END IF

		IF _monto_30 <> 0 THEN

			IF _monto_30 >= _montoPagado THEN

				LET _monto_30    = _montoPagado;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_30;

			END IF	

		END IF
		
		IF _corriente <> 0 THEN

			IF _corriente >= _montoPagado THEN

				LET _corriente   = _montoPagado;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _corriente;

			END IF	

		END IF

		IF _por_vencer <> 0 THEN

			LET _por_vencer  = _montoPagado;
			LET _montoPagado = 0;

		END IF

		IF _montoPagado <> 0 THEN
			LET _corriente = _corriente + _montoPagado;
		END IF			

	ELSE

		LET _monto_90   = 0;
		LET _monto_60   = 0;
		LET _monto_30   = 0;
		LET _corriente  = _montoPagado;
		LET _por_vencer = 0;

	END IF

	LET _exigible = _corriente + _monto_30 + _monto_60 + _monto_90;

--------------
-- Gerencia
--------------
Let _evaluado = 0;

If _cobra_poliza = "G" then
    
    Let _nombre_cobra    = 'Gerencia';
	Let _evaluado        = 1;
	Let _nombre_cobrador =	'Cobros Gerencia';
	
End If

--------------
-- Incobrables
--------------
Let _evaluado = 0;

If _cobra_poliza = "I" then
    
    Let _nombre_cobra = 'Cuentas Especiales';
	Let _evaluado     = 1;

	Select nombre
	  Into _nombre_cobrador
	  From cobcobra
	 Where tipo_cobrador = 6
	   and cod_cobrador  = '001';
	   
End If

------------------------
-- Coaseguro Minoritario	
------------------------
If _evaluado = 0  then

	If _cod_tipoprod = "002" then

	    Let _evaluado     = 1;
		Let _nombre_cobra =	'Coaseguro Minoritario';

	  	{Select nombre
		  Into _nombre_cobrador
		  From cobcobra
		 Where tipo_cobrador = 10
		  And  activo = 1; }

	  	Select nombre
		  Into _nombre_cobrador
		  From cobcobra
		 Where cod_cobrador = "008"
		  And  activo = 1; 

	  
	End if

End If

--------------
-- Sucursales
--------------
If _evaluado = 0  then

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_compania = a_compania
	   and codigo_agencia  = _cod_sucursal;

	if _centro_costo <> _agencia_lider then
	    
		select descripcion
		  into _nombre_cobrador
		  from insagen
		 where codigo_compania = a_compania
		   and codigo_agencia  = _centro_costo;

		Let _nombre_cobra = 'Sucursales';
	    Let _evaluado     = 1;

	End If

End If

-------------
--Electronico
-------------
If _evaluado = 0  then

	If _cobra_poliza = 'H' Then  
	    Let _evaluado        = 1;
	    Let _nombre_cobra    = 'Electronico';
		Let _nombre_cobrador = 'ACH';
	End If

	If _cobra_poliza ='T' Then
	    Let _evaluado        = 1;
	    Let _nombre_cobra    = 'Electronico';
		Let _nombre_cobrador = 'TARJETA DE CREDITO';
	End If

End If

----------
--Gestores
----------
If _evaluado = 0  then

	If _cobra_poliza = 'E' Then 
		
	    Let _evaluado     = 1;
		Let _nombre_cobra = 'Gestores';

	     Select cod_cliente
		   Into _cod_pagador
		   From	caspoliza
		  Where no_documento = _doc_poliza;

		if _cod_pagador is null then

			let _nombre_cobrador = "POR DEFINIR";

		else

			 Select cod_cobrador,
			        cod_cobrador_ant
			   Into _cod_cobrador,
			        _cod_cobrador_ant
			   From cascliente
			  Where cod_cliente = _cod_pagador;

--			if _cod_cobrador_ant is not null then
--				let _cod_cobrador = _cod_cobrador_ant;
--			end if

			select cod_sucursal
			  into _cod_sucursal
			  from cobcobra
			 where cod_cobrador = _cod_cobrador;

			if _cod_sucursal <> _agencia_lider then

				Let _nombre_cobra = 'Sucursales';

				select descripcion
				  into _nombre_cobrador
				  from insagen
				 where codigo_compania = a_compania
				   and codigo_agencia  = _cod_sucursal;

			else

				 Select nombre
				   Into _nombre_cobrador
				   From cobcobra
				  Where cod_cobrador = _cod_cobrador;
		  		    		    
			end if

		End If

	End If
	
End If

-------------
-- Corredores
-------------
If _evaluado = 0  then

 	 If _cobra_poliza = 'C' then 

	    Let _evaluado     = 1;
		Let _nombre_cobra = "Corredores";

		FOREACH 
		 SELECT	cod_agente
		   INTO	_cod_agente
		   FROM emipoagt
		  WHERE	no_poliza = _no_poliza

			SELECT cod_cobrador
			  INTO _cod_cobrador			   
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;     

			select cod_sucursal
			  into _cod_sucursal
			  from cobcobra
			 where cod_cobrador = _cod_cobrador;

			if _cod_sucursal <> _agencia_lider then

				Let _nombre_cobra = 'Sucursales';

				select descripcion
				  into _nombre_cobrador
				  from insagen
				 where codigo_compania = a_compania
				   and codigo_agencia  = _cod_sucursal;

			else

				SELECT nombre
				  INTO _nombre_cobrador
				  FROM cobcobra
				 Where cod_cobrador = _cod_cobrador;

			end if

			exit foreach;
					
	    END FOREACH

	 End If

End If

IF _por_vencer <> 0 THEN
	LET _cnt_por_vencer = 1;
ELSE
	LET _cnt_por_vencer = 0;
END IF
IF _exigible <> 0 THEN
	LET _cnt_exigible = 1;
ELSE
	LET _cnt_exigible = 0;
END IF
IF _corriente <> 0 THEN
	LET _cnt_corriente = 1;
ELSE
	LET _cnt_corriente = 0;
END IF
IF _monto_30 <> 0 THEN
	LET _cnt_monto_30 = 1;
ELSE
	LET _cnt_monto_30 = 0;
END IF
IF _monto_60 <> 0 THEN
	LET _cnt_monto_60 = 1;
ELSE
	LET _cnt_monto_60 = 0;
END IF
IF _monto_90 <> 0 THEN
	LET _cnt_monto_90 = 1;
ELSE
	LET _cnt_monto_90 = 0;
END IF

--If _nombre_cobrador is null then
	Let _nombre_cobrador = _doc_poliza;
--End if

INSERT INTO tmp_moros(
nombre_cobra,
nombre_cobrador,
monto_pagado,
por_vencer,
exigible,
corriente,
monto_30,
monto_60,
monto_90,
cnt_por_vencer,
cnt_exigible,
cnt_corriente,
cnt_monto_30,
cnt_monto_60,
cnt_monto_90,
cnt_pagado
)
VALUES(
_nombre_cobra,
_nombre_cobrador,
_monto_pagado,
_por_vencer,
_exigible,
_corriente,
_monto_30,
_monto_60,
_monto_90,
_cnt_por_vencer,
_cnt_exigible,
_cnt_corriente,
_cnt_monto_30,
_cnt_monto_60,
_cnt_monto_90,
1
);
    
END FOREACH

-- Pendientes de Aplicar

{
LET _cnt_por_vencer = 1;
LET _cnt_exigible   = 0;
LET _cnt_corriente  = 0;
LET _cnt_monto_30   = 0;
LET _cnt_monto_60   = 0;
LET _cnt_monto_90   = 0;
LET _exigible		= 0.00;
LET _corriente		= 0.00;
LET _monto_30		= 0.00;
LET _monto_60		= 0.00;
LET _monto_90		= 0.00;

foreach	
 Select cod_sucursal,
        monto          
   Into _centro_costo,
		_monto_pagado
   From cobsuspe
  Where cod_compania = a_compania
    and year(fecha)  = a_periodo[1,4]
    and month(fecha) = a_periodo[6,7]

	Let _nombre_cobra   = 'Primas por Aplicar';
	LET	_por_vencer		= _monto_pagado;

	select centro_costo
	  into _centro_costo
	  from insagen
	 where codigo_compania = a_compania
	   and codigo_agencia  = _cod_sucursal;
	   
	select descripcion
	  into _nombre_cobrador
	  from insagen
	 where codigo_compania = a_compania
	   and codigo_agencia  = _centro_costo;
	
	INSERT INTO tmp_moros(
	nombre_cobra,
	nombre_cobrador,
	monto_pagado,
	por_vencer,
	exigible,
	corriente,
	monto_30,
	monto_60,
	monto_90,
	cnt_por_vencer,
	cnt_exigible,
	cnt_corriente,
	cnt_monto_30,
	cnt_monto_60,
	cnt_monto_90 )
	VALUES(
	_nombre_cobra,
	_nombre_cobrador,
	_monto_pagado,
	_por_vencer,
	_exigible,
	_corriente,
	_monto_30,
	_monto_60,
	_monto_90,
	_cnt_por_vencer,
	_cnt_exigible,
	_cnt_corriente,
	_cnt_monto_30,
	_cnt_monto_60,
	_cnt_monto_90
	);

end foreach
}

FOREACH
 SELECT	nombre_cobrador,
		sum(cnt_pagado),
		SUM(monto_pagado),    
		SUM(por_vencer),     
		SUM(exigible),       
		SUM(corriente),     
		SUM(monto_30),       
		SUM(monto_60),       
		SUM(monto_90),
		SUM(cnt_por_vencer),
		SUM(cnt_exigible),
		SUM(cnt_corriente),
		SUM(cnt_monto_30),
		SUM(cnt_monto_60),
		SUM(cnt_monto_90),
		nombre_cobra
   INTO	_nombre_cobrador,
		v_cantidad,
   		v_monto_pagado,    
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		_cnt_por_vencer,
		_cnt_exigible,
		_cnt_corriente,
		_cnt_monto_30,
		_cnt_monto_60,
		_cnt_monto_90,
	   	_nombre_cobra
   FROM	tmp_moros
 GROUP BY nombre_cobra , nombre_cobrador
 ORDER BY nombre_cobra , nombre_cobrador  

--	 LET _cnt_exigible = _cnt_corriente + _cnt_monto_30 + _cnt_monto_60 + _cnt_monto_90; 

	RETURN 	v_compania_nombre,
			v_cantidad,
			v_monto_pagado,    
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			_cnt_por_vencer,
			_cnt_exigible,
			_cnt_corriente,
			_cnt_monto_30,
			_cnt_monto_60,
			_cnt_monto_90,
			_nombre_cobrador,
			_nombre_cobra
  		WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_moros;
DROP TABLE tmp_pagos;

END PROCEDURE;





