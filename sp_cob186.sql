-- Procedimiento que Genera los Cobros por Cobrador	semanal, por cobra poliza. 
-- 
-- Creado    : 18/06/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 16/11/2005 - Autor: Armando Moreno (argumento de periodo2

DROP PROCEDURE sp_cob186;

CREATE PROCEDURE "informix".sp_cob186(a_periodo CHAR(7), a_periodo2 CHAR(7)) 
RETURNING CHAR(20),  -- Nombre Compania
			char(1),   -- Cantidad	
			DEC(16,2), -- Prima Pagada
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
		cnt_monto_90    SMALLINT    DEFAULT 0 NOT NULL
		) WITH NO LOG;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01("001"); 

select par_agencia_lider
  into _agencia_lider
  from parparam
 where cod_compania = "001";

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
    AND periodo      BETWEEN a_periodo AND a_periodo2
	and fecha        = "22/11/2005"

	Let _no_poliza = sp_sis21(_doc_poliza);

	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 4 then	--Reaseguro Asumido
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

let _por_vencer  = 0;       
let _exigible    = 0;         
let _corriente   = 0;        
let _monto_30    = 0;         
let _monto_60    = 0;         
let _monto_90    = 0;
let _saldo_total = 0;         

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
	If _evaluado = 0  then

		If _cobra_poliza = "I" then
		    
		    Let _nombre_cobra = 'Cuentas Especiales';
			Let _evaluado     = 1;

			Select nombre
			  Into _nombre_cobrador
			  From cobcobra
			 Where tipo_cobrador = 6
			   and cod_cobrador  = '001';
			   
		End If

	End If

	------------------------
	-- Coaseguro Minoritario	
	------------------------
	If _evaluado = 0  then

		If _tipo_produccion = 3 then

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
		 where codigo_compania = "001"
		   and codigo_agencia  = _cod_sucursal;
		   
		if _centro_costo <> _agencia_lider then
		    
			select descripcion
			  into _nombre_cobrador
			  from insagen
			 where codigo_compania = "001"
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
					 where codigo_compania = "001"
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
					 where codigo_compania = "001"
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

	if _nombre_cobrador = "Cobros Gerencia" or
	   _nombre_cobrador	= "COLON" THEN

		RETURN _doc_poliza,
		       _cobra_poliza,
			   _monto_pagado,    
			   _nombre_cobrador,
			   _nombre_cobra
	  		   WITH RESUME;

	end if

END FOREACH
					 
DROP TABLE tmp_moros;
DROP TABLE tmp_pagos;

END PROCEDURE;





