-- Procedimiento que actualiza el monto al renglon de afectacion a catalogo
-- de la remesa de ajustes de centavos.
-- 
-- Creado    : 25/05/2010 - Autor: Armando Moreno
-- modificado: 26/05/2010 - Autor: Armando Moreno
-- 
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob42c;

CREATE PROCEDURE sp_cob42c(a_no_remesa CHAR(10))
RETURNING INTEGER,
		  CHAR(50);

DEFINE _error_code      INTEGER;

DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18); 
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _prima_neta		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_cliente   	CHAR(10);
DEFINE _cod_agente   	CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _tipo_remesa     CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE _cod_lider       CHAR(3);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _porc_partic_coas decimal(7,4);
DEFINE _monto            decimal(16,2);  

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Ajustes de Centavos';         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

LET _fecha = current;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

let _cod_compania = "001";
let _cod_sucursal = "001";

LET a_no_recibo = 'CONT';

IF DAY(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || DAY(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || DAY(_fecha);
END IF

IF MONTH(_fecha) < 10 THEN
	LET a_no_recibo = TRIM(a_no_recibo) || '0' || MONTH(_fecha);
ELSE
	LET a_no_recibo = TRIM(a_no_recibo) || MONTH(_fecha);
END IF

LET _ano_char   = YEAR(_fecha);
LET a_no_recibo = TRIM(a_no_recibo) || _ano_char[3,4];

let _no_documento = sp_sis15('INGVAR'); --7000204
let _no_documento = trim(_no_documento);

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

LET _renglon = _renglon + 1;

SELECT par_ase_lider
  INTO _cod_lider
  FROM parparam
 WHERE cod_compania = "001";

let _saldo = 0.00;

FOREACH

	 SELECT	no_poliza,
			prima_neta
	   INTO	_no_poliza,
	        _prima_neta
	   FROM	cobredet
	  WHERE	no_remesa = a_no_remesa

 	 SELECT cod_tipoprod
	   INTO _cod_tipoprod
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	 SELECT tipo_produccion
	   INTO _tipo_produccion
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

	 if _tipo_produccion = 2 then --coas may

			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
		
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _prima_neta = ROUND(_prima_neta * _porc_partic_coas / 100,2);

	 end if

	 let _saldo = _saldo + _prima_neta;

END FOREACH

SELECT SUM(monto)
  INTO _monto
  FROM cobredet
 WHERE no_remesa = a_no_remesa;

let _monto = _monto * -1;
let _saldo = _saldo * -1;

update cobredet
   set monto      = _monto,
       prima_neta = _saldo
 where no_remesa  = a_no_remesa
   and tipo_mov   = "M";

RETURN 0, "Actualizacion Exitosa... Remesa: " || a_no_remesa;

END

END PROCEDURE;
