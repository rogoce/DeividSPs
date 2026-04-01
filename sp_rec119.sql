-- Transacciones de pago con requisicion pendientes de imrimir el cheque

-- Creado    : 10/02/2004 - Autor: Armando Moreno

drop procedure sp_rec119;

create procedure "informix".sp_rec119(a_ramo CHAR(255),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_pagado smallint,a_periodo smallint)
RETURNING CHAR(100), 
		  CHAR(18), 
		  DEC(16,2), 
		  DATE, 
		  CHAR(10),
		  CHAR(10),
		  CHAR(255),
		  CHAR(50),
		  smallint,
		  date,
		  integer;

DEFINE _cod_cliente, v_transaccion CHAR(10);
DEFINE v_numrecla	 	CHAR(18);
DEFINE v_monto		 	DEC(16,2);
DEFINE v_fecha		 	DATE;
DEFINE _no_requis    	CHAR(10);
DEFINE v_proveedor   	CHAR(100);
DEFINE v_tipopago    	CHAR(50);
define v_filtros     	CHAR(50);
define _cod_ramo     	CHAR(3);
DEFINE _tipo         	CHAR(1);
define v_ramo_nombre 	char(50);
DEFINE _no_reclamo   	CHAR(10);
DEFINE _no_poliza    	CHAR(10);
define _pagado		 	smallint;
define _fecha_impresion date;
define _anular_nt		CHAR(10);
define _frase			CHAR(15);
define _no_cheque       integer;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_pag(
		nombre_asegurado CHAR(100),
		doc_reclamo	  	 CHAR(18),
		fecha		     DATE,
		cod_ramo         CHAR(3),   
		seleccionado     SMALLINT  DEFAULT 1 NOT NULL,
		transaccion		 char(10),
		no_requis		 char(10),
		monto			 DEC(16,2),
		pagado			 smallint
		) WITH NO LOG;

CREATE INDEX xie01_tmp_pag ON tmp_pag(seleccionado);
CREATE INDEX xie02_tmp_pag ON tmp_pag(cod_ramo);
CREATE INDEX xie03_tmp_pag ON tmp_pag(doc_reclamo);

let _anular_nt = null;
let _no_cheque = 0;

if a_periodo <> 1 and a_pagado <> 2 then	--especificar periodo y pagado o no pagado

FOREACH WITH HOLD

   SELECT cod_cliente,
          numrecla,
		  monto,
		  fecha,
		  transaccion,
		  no_requis,
		  no_reclamo,
		  pagado,
		  anular_nt
	 INTO _cod_cliente,
	      v_numrecla,
		  v_monto,
	   	  v_fecha,
		  v_transaccion,
		  _no_requis,
		  _no_reclamo,
		  _pagado,
		  _anular_nt
	 FROM rectrmae
	WHERE actualizado  = 1
	  AND cod_tipotran = "004"
	  AND pagado  = a_pagado
 	  AND periodo >= a_periodo1
      AND periodo <= a_periodo2
	  and monto > 0

	if _anular_nt is not null or _anular_nt <> "" then
		continue foreach;
	end if

	SELECT nombre
	  INTO v_proveedor
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	INSERT INTO tmp_pag(
	nombre_asegurado,
	doc_reclamo,	  	 
	fecha,
	cod_ramo,
	transaccion,
	no_requis,
	monto,
	pagado
	)
	VALUES(
	v_proveedor,
	v_numrecla,	  	 
	v_fecha,
	_cod_ramo,
	v_transaccion,            
	_no_requis,
	v_monto,
	_pagado
	);
end foreach

elif a_periodo = 1 and a_pagado <> 2 then

FOREACH WITH HOLD

   SELECT cod_cliente,
          numrecla,
		  monto,
		  fecha,
		  transaccion,
		  no_requis,
		  no_reclamo,
		  pagado,
		  anular_nt
	 INTO _cod_cliente,
	      v_numrecla,
		  v_monto,
	   	  v_fecha,
		  v_transaccion,
		  _no_requis,
		  _no_reclamo,
		  _pagado,
		  _anular_nt
	 FROM rectrmae
	WHERE actualizado  = 1
	  AND cod_tipotran = "004"
	  AND pagado  = a_pagado
	  and monto > 0

	if _anular_nt is not null or _anular_nt <> "" then
		continue foreach;
	end if

	SELECT nombre
	  INTO v_proveedor
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	INSERT INTO tmp_pag(
	nombre_asegurado,
	doc_reclamo,	  	 
	fecha,
	cod_ramo,
	transaccion,
	no_requis,
	monto,
	pagado
	)
	VALUES(
	v_proveedor,
	v_numrecla,	  	 
	v_fecha,
	_cod_ramo,
	v_transaccion,            
	_no_requis,
	v_monto,
	_pagado
	);
end foreach

else

FOREACH WITH HOLD

   SELECT cod_cliente,
          numrecla,
		  monto,
		  fecha,
		  transaccion,
		  no_requis,
		  no_reclamo,
		  pagado,
		  anular_nt
	 INTO _cod_cliente,
	      v_numrecla,
		  v_monto,
	   	  v_fecha,
		  v_transaccion,
		  _no_requis,
		  _no_reclamo,
		  _pagado,
		  _anular_nt
	 FROM rectrmae
	WHERE actualizado  = 1
	  AND cod_tipotran = "004"
	  and monto > 0

	if _anular_nt is not null or _anular_nt <> "" then
		continue foreach;
	end if

	SELECT nombre
	  INTO v_proveedor
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	INSERT INTO tmp_pag(
	nombre_asegurado,
	doc_reclamo,	  	 
	fecha,
	cod_ramo,
	transaccion,
	no_requis,
	monto,
	pagado
	)
	VALUES(
	v_proveedor,
	v_numrecla,	  	 
	v_fecha,
	_cod_ramo,
	v_transaccion,            
	_no_requis,
	v_monto,
	_pagado
	);
end foreach
end if

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_pag
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_pag
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

let _fecha_impresion = null;
if a_periodo = 1 then
	let _frase = " PERIODO: TODOS";
else
	let _frase = "";
end if

LET v_filtros = TRIM(v_filtros) || _frase;

FOREACH 
 SELECT doc_reclamo,
		nombre_asegurado,
		fecha,
		cod_ramo,
		no_requis,
		transaccion,
		monto,
		pagado
   INTO	v_numrecla,
		v_proveedor,
		v_fecha,
		_cod_ramo,
		_no_requis,
		v_transaccion,
		v_monto,
		_pagado
   FROM tmp_pag
  WHERE seleccionado = 1
  order by pagado,cod_ramo,doc_reclamo

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	if _pagado = 1 then	--transacciones pagadas

		if _no_requis is not null then
		 
			SELECT fecha_impresion,
				   no_cheque
			  INTO _fecha_impresion,
				   _no_cheque
			  FROM chqchmae
			 WHERE no_requis = _no_requis;
		else
			let _fecha_impresion = "";
			let _no_cheque = 0;
		end if
	end if

	RETURN v_proveedor,
		   v_numrecla,
		   v_monto,
		   v_fecha,
		   v_transaccion,
		   _no_requis,
		   v_filtros,
		   v_ramo_nombre,
		   _pagado,
		   _fecha_impresion,
		   _no_cheque
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pag;
end procedure;
