-- Reporte de cuentas de Cheques por Requisicion
-- Creado    : 26/01/2010 Henry Giron
-- SIS v.2.0 - d_cheq_sp_che205_dw1 - DEIVID, S.A.

DROP PROCEDURE ap_che205;
CREATE PROCEDURE ap_che205(a_compania CHAR(3), a_requis CHAR(10))
RETURNING CHAR(25),	-- Cuenta
		  CHAR(50),	-- Descripcion
		  DEC(16,2),-- Debito
		  DEC(16,2),-- Credito
		  CHAR(50), -- Compania
		  smallint,
		  DEC(16,2),
		  DEC(16,2);

DEFINE v_cuenta		  	CHAR(25);  
DEFINE v_descripcion	CHAR(50); 
DEFINE v_debito       	DEC(16,2);
DEFINE v_credito      	DEC(16,2);
DEFINE v_nombre_cia   	CHAR(50);

DEFINE _renglon       	SMALLINT;
define _fecha_impresion	date;
define _fecha_anulado	date;
define _periodo1		char(7);
define _periodo2		char(7);

define _cod_auxiliar	 char(5);
define _nombre_auxiliar	 char(50);
define _debito_aux       DEC(16,2);
define _credito_aux      DEC(16,2);
define _cta_auxiliar	 char(1);

		
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
	cuenta		    CHAR(25),
	debito          DEC(16,2),
	credito         DEC(16,2),
	renglon         smallint
	) WITH NO LOG;


CREATE TEMP TABLE tmp_aux(
	cuenta		    CHAR(25),
	cod_auxiliar    CHAR(5),
	debito          DEC(16,2),
	credito         DEC(16,2)
	) WITH NO LOG;

-- Cheques Pagados

FOREACH
 SELECT	x.cuenta,
 		x.debito,
		x.credito,
		x.renglon,
		x.no_requis
   INTO	v_cuenta,
   		v_debito,
		v_credito,
		_renglon,
		a_requis
   FROM	chqchcta x, chqchmae y
  WHERE x.no_requis        = y.no_requis 
	AND y.pagado           = 1
    and y.no_cheque		   = 2474
	and y.fecha_captura    = '30/09/2020'
	and x.tipo             = 1

  INSERT INTO tmp_tabla(
  cuenta,
  debito,
  credito,
  renglon
  )
  VALUES(
  v_cuenta,
  v_debito,
  v_credito,
  1
  );
  
SELECT cta_auxiliar
  INTO _cta_auxiliar
  FROM cglcuentas
 WHERE cta_cuenta = v_cuenta;

if _cta_auxiliar = "S" then
	foreach
	 select cod_auxiliar,
			debito,
			credito
	   into _cod_auxiliar,
			_debito_aux,
			_credito_aux
	   from chqctaux
	  where no_requis = a_requis
		and renglon   = _renglon
		and cuenta    = v_cuenta
	  order by cod_auxiliar 

	 INSERT INTO tmp_aux(
	  cuenta,
	  cod_auxiliar,
	  debito,
	  credito
	  )
	  VALUES(
	  v_cuenta,
	  _cod_auxiliar,
	  v_debito,
	  v_credito
	  );
	end foreach
 end if    	  
  

END FOREACH

-- Cheques Anulados

FOREACH
 SELECT	x.cuenta,
 		x.debito,
		x.credito,
		x.renglon,
		x.no_requis,
		y.fecha_impresion,
		y.fecha_anulado
   INTO	v_cuenta,
   		v_debito,
		v_credito,
		_renglon,
		a_requis,
		_fecha_impresion,
		_fecha_anulado
   FROM	chqchcta x, chqchmae y
  WHERE x.no_requis      = y.no_requis
	AND y.pagado         = 1
    and y.no_cheque		   = 2474
	and y.fecha_captura    = '30/09/2020'
	AND y.anulado        = 1
	and x.tipo           = 2	

{
	let _periodo1 = sp_sis39(_fecha_impresion);
	let _periodo2 = sp_sis39(_fecha_anulado);

	if _periodo1 = _periodo2 then
		continue foreach;
	end if
}

	INSERT INTO tmp_tabla(
	cuenta,
	debito,
	credito,
	renglon
	)
	VALUES(
	v_cuenta,
	v_debito,
	v_credito,
	2
	);
	
	SELECT cta_auxiliar
	  INTO _cta_auxiliar
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	if _cta_auxiliar = "S" then
		foreach
		 select cod_auxiliar,
				debito,
				credito
		   into _cod_auxiliar,
				_debito_aux,
				_credito_aux
		   from chqctaux
		  where no_requis = a_requis
			and renglon   = _renglon
			and cuenta    = v_cuenta
		  order by cod_auxiliar 

		 INSERT INTO tmp_aux(
		  cuenta,
		  cod_auxiliar,
		  debito,
		  credito
		  )
		  VALUES(
		  v_cuenta,
		  _cod_auxiliar,
		  v_debito,
		  v_credito
		  );
		end foreach
	 end if    	  
	

END FOREACH

FOREACH
 SELECT cuenta,
  	    sum(debito),
	    sum(credito),
	    renglon
   INTO v_cuenta,
	    v_debito,
	    v_credito,
	    _renglon
   FROM tmp_tabla
  group by renglon,cuenta 
  order by renglon, cuenta

	SELECT cta_nombre,
	       cta_auxiliar
	  INTO v_descripcion,
	       _cta_auxiliar
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;
			
	RETURN  v_cuenta,		 
			v_descripcion,
			v_debito,     
			v_credito,    
			v_nombre_cia,
			_renglon,
			null,
			null 
			WITH RESUME;

	if _cta_auxiliar = "S" then
		foreach
		 select cod_auxiliar,
		        sum(debito),
			    sum(credito)
		   into _cod_auxiliar,
		        _debito_aux,
			    _credito_aux
		   from tmp_aux
		  where cuenta    = v_cuenta
		  group by cod_auxiliar 	
		  order by cod_auxiliar 	

			select ter_descripcion
			  into _nombre_auxiliar
			  from cglterceros
			 where ter_codigo = _cod_auxiliar;
		
			RETURN _cod_auxiliar,			
				   _nombre_auxiliar,  
				   null,         
				   null,        
				   v_nombre_cia,
				   _renglon,
				   _debito_aux,
				   _credito_aux
				   WITH RESUME;	 		
	
		end foreach
	end if
	
END FOREACH

DROP TABLE tmp_tabla;
DROP TABLE tmp_aux;

END PROCEDURE;