-- Procedimiento que Genera la Remesa para Aplicar recibo Automatico para una poliza SODA

-- Creado    : 04/05/2007 - Autor: Armando Moreno M.
-- Modificado: 04/05/2007 - Autor:  Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co50a;

CREATE PROCEDURE "informix".sp_co50a(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_no_recibo     CHAR(10),
a_no_documento  CHAR(20)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10);
DEFINE _cod_contratante	CHAR(10);
DEFINE _doc_remesa    	CHAR(30);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE _cant	      	INTEGER;  

{SET DEBUG FILE TO "sp_cob50a.trc"; 
TRACE ON;}

SET ISOLATION TO DIRTY READ;

begin work;

BEGIN

ON EXCEPTION SET _error_code
	rollback work;	
 	RETURN _error_code, 'Error al Actualizar la Remesa', '';         
END EXCEPTION           

LET _null       = NULL;
LET a_no_remesa = '1';  
LET a_no_recibo = trim(a_no_recibo);
Let _doc_remesa = _null;

--LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

let a_no_remesa = '151367';

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	

LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

-- Insertar el Maestro de Remesas

INSERT INTO cobremae
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
'017',
_null,
_null,
'C',
_fecha,
0,
2,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha
);

SELECT doc_remesa
  INTO _doc_remesa
  FROM cobredet
 WHERE no_recibo = a_no_recibo
   and tipo_mov  = "E";

if _doc_remesa is not null then
	
	let _doc_remesa = trim(_doc_remesa);

	SELECT count(*)
	  INTO _cant
	  FROM cobsuspe
	 WHERE doc_suspenso = _doc_remesa;

	if _cant = 0 then
		rollback work;
		RETURN 1, 'No se encontro la prima en suspenso, No se Aplico el pago...', '';
	else

		SELECT actualizado,
		       monto
		  INTO _cant,
		       _monto
		  FROM cobsuspe
		 WHERE doc_suspenso = _doc_remesa;

		if _cant = 1 then

			let _monto = _monto * -1;

			--***APLICACION DE PRIMA EN SUSPENSO***

			INSERT INTO cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado
			)
			VALUES(
		    a_no_remesa,
		    1,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    _doc_remesa,
		    'A',
		    _monto,
		    0,
		    0,
		    0,
		    0,
		    '',
		    0,
		    _periodo,
		    _fecha,
		    0
			);

			--***PAGO DE PRIMA***

			let _monto = _monto * -1;

			-- Impuestos de la Poliza

			LET _no_poliza = sp_sis21(a_no_documento);

			SELECT SUM(saldo)
			  INTO _saldo
			  FROM emipomae
			 WHERE no_documento = a_no_documento
			   AND actualizado  = 1;

			IF _saldo IS NULL THEN
				LET _saldo = 0;
			END IF

			SELECT SUM(i.factor_impuesto)
			  INTO _factor
			  FROM prdimpue i, emipolim p
			 WHERE i.cod_impuesto = p.cod_impuesto
			   AND p.no_poliza    = _no_poliza;

			IF _factor IS NULL THEN
				LET _factor = 0;
			END IF

			LET _factor   = 1 + _factor / 100;
			LET _prima    = _monto / _factor;
			LET _impuesto = _monto - _prima;

			-- Descripcion de la Remesa
			
			LET _nombre_agente = "";

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

			select cod_contratante
			  into _cod_contratante
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into _nombre_cliente
			  from cliclien
			 where cod_cliente = _cod_contratante;			

			LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);

			INSERT INTO cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			no_poliza
			)
			VALUES(
		    a_no_remesa,
		    2,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    a_no_documento,
		    "P",
		    _monto,
		    _prima,
		    _impuesto,
		    0,
		    0,
		    _descripcion,
		    _saldo,
		    _periodo,
		    _fecha,
		    0,
			_no_poliza
			);

			FOREACH
				 SELECT	cod_agente,
						porc_partic_agt,
						porc_comis_agt
				   INTO	_cod_agente,
						_porc_partic,
						_porc_comis
				   FROM	emipoagt
				  WHERE no_poliza = _no_poliza

					INSERT INTO cobreagt
					VALUES(
					a_no_remesa,
					2,
					_cod_agente,
					0,
					0,
					_porc_comis,
					_porc_partic
					);
			END FOREACH

			SELECT SUM(monto)
			  INTO _saldo
			  FROM cobredet
			 WHERE no_remesa = a_no_remesa;

			UPDATE cobremae
			   SET monto_chequeo = _saldo
			 WHERE no_remesa     = a_no_remesa;

		else
			rollback work;
			RETURN 1, 'La Remesa que creo la prima en suspenso no esta actualizada, No se puede Aplicar el pago...', '';
		end if
    end if
else
	rollback work;
	RETURN 1, 'No se encontro el el No. de Recibo, No se puede Aplicar el pago... ', '';
end if

--Actualizacion de Remesa

{call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

if _error_code <> 0 then
	return _error_code, _mensaje, a_no_remesa;
end if}
commit work;

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;