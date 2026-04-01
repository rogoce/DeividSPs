-- Preliminar de la Generacion de los Lotes de las Tarjetas de Credito America Express solamente.

-- Creado    : 23/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob146;

CREATE PROCEDURE "informix".sp_cob146(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha_hasta	date
) RETURNING CHAR(19),
			CHAR(7),
			CHAR(100),
			CHAR(20),
			DATE,
			DATE,
			DEC(16,2),
			DEC(16,2),
			CHAR(3),
			CHAR(50),
			CHAR(50),
			DEC(16,2);

DEFINE _no_tarjeta       CHAR(19); 
DEFINE _monto            DEC(16,2);
DEFINE _fecha_exp        CHAR(7);  
DEFINE _no_documento     CHAR(20); 
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;     
DEFINE _tipo_tarjeta	 CHAR(1);
DEFINE _nueva_renov		 CHAR(1);
DEFINE _rechazada		 SMALLINT;
DEFINE _procesar		 CHAR(3);
DEFINE _nombre           CHAR(100);
DEFINE _cod_cliente      CHAR(10); 

DEFINE _saldo            DEC(16,2);

DEFINE _periodo_visa     CHAR(7);  
DEFINE _periodo_today    CHAR(7);  
DEFINE v_compania_nombre CHAR(50); 
DEFINE _cod_banco		 CHAR(3);
DEFINE _nombre_banco     CHAR(50);
DEFINE _cod_ramo         CHAR(3);
DEFINE _ramo_sis		 SMALLINT;
--DEFINE _tarjeta_errada   SMALLINT;

DEFINE _cod_formapag	 CHAR(3);
DEFINE _tipo_forma       SMALLINT;
DEFINE _cantidad         SMALLINT;
DEFINE _estatus_poliza	 CHAR(1);	
DEFINE _fecha_1_pago	 DATE;				

DEFINE _no_poliza		 CHAR(10);
DEFINE _cod_agente		 CHAR(10);
DEFINE _nombre_agente,_mensaje	 CHAR(50);
DEFINE _excepcion        SMALLINT;
			
DEFINE v_por_vencer      DEC(16,2);
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente       DEC(16,2);
DEFINE v_monto_30        DEC(16,2);
DEFINE v_monto_60        DEC(16,2);
DEFINE v_monto_90        DEC(16,2);
DEFINE v_saldo           DEC(16,2);
DEFINE v_periodo         CHAR(7);
DEFINE v_fecha			 DATE;
DEFINE _rechazada_si	 smallint;
define _rechazada_no	 smallint;
define _rech,_valor		 smallint;
DEFINE _estatus_visa	 CHAR(1);
DEFINE _fecha_hoy		date;
define _periodo2        char(1);
define _periodo         char(1);
DEFINE _fecha_hasta     DATE;
DEFINE _fecha_inicio    DATE;
DEFINE _cargo			DEC(16,2);
define _ult_pago        DEC(16,2);
define a_periodo		char(1); 				

-- Nombre de la Compania
let a_periodo = '1';
LET  v_compania_nombre = sp_sis01(a_compania); 

LET v_fecha = TODAY;
let _fecha_hoy = today;

IF MONTH(v_fecha) < 10 THEN
	LET v_periodo = YEAR(v_fecha) || '-0' || MONTH(v_fecha);
ELSE
	LET v_periodo = YEAR(v_fecha) || '-' || MONTH(v_fecha);
END IF 

let _mensaje = "";

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob47.trc"; 
--TRACE ON;                                                                

CREATE TEMP TABLE tmp_tarjeta(
	no_tarjeta		CHAR(19),
	fecha_exp		CHAR(7), 
	nombre			CHAR(100),
	no_documento	CHAR(20),
	vigencia_inic	DATE,
	vigencia_final	DATE,
	monto			DEC(16,2),
	saldo			DEC(16,2),
	procesar		CHAR(3),
	cod_banco		CHAR(3),
	PRIMARY KEY (no_tarjeta, no_documento)
) WITH NO LOG;

IF MONTH(TODAY) < 10 THEN
	LET _periodo_today = YEAR(TODAY) || '-0' || MONTH(TODAY);
ELSE
	LET _periodo_today = YEAR(TODAY) || '-' || MONTH(TODAY);
END IF

select estatus_visa
  into _estatus_visa
  from parparam
 where cod_compania = a_compania;

if _estatus_visa = "1" then	--proceso normal
	let _rechazada_si = 1;
	let _rechazada_no = 0;
else
	let _rechazada_si = 1;
	let _rechazada_no = 1;
end if

-- Polizas con Forma de Pago Tarjeta y No Tienen Tarjetas Creadas

if _estatus_visa = "1" then

	UPDATE cobtacre
	   SET rechazada = 0
	 WHERE periodo   = a_periodo;

FOREACH                 
 SELECT p.no_documento    
   INTO	_no_documento  
   FROM emipomae p, cobforpa f       
  WHERE	p.actualizado   = 1
    AND p.cod_formapag  = f.cod_formapag
	AND f.tipo_forma    = 2      --tarjeta credito
	AND p.tipo_tarjeta = "4"	 --American Express
  GROUP BY p.no_documento 

	FOREACH
	 SELECT cod_formapag,
			vigencia_inic,
			vigencia_final,
			cod_contratante,
			estatus_poliza
	   INTO	_cod_formapag,
			_vigencia_inic,
			_vigencia_final,
			_cod_cliente,
			_estatus_poliza
	   FROM	emipomae
	  WHERE	no_documento  = _no_documento
	    AND actualizado   = 1
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _tipo_forma <> 2 THEN
		CONTINUE FOREACH;
	END IF

	IF _estatus_poliza = '2' OR
	   _estatus_poliza = '4' THEN
		CONTINUE FOREACH;
	END IF

	LET _monto = NULL;

		CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
			RETURNING   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;
   FOREACH	
	SELECT monto
	  INTO _monto
	  FROM cobtacre
	 WHERE no_documento = _no_documento
		EXIT FOREACH;
   END FOREACH

	IF _monto IS NULL THEN

	 	SELECT nombre                      
		  INTO _nombre                     
	 	  FROM cliclien                    
	 	 WHERE cod_cliente = _cod_cliente; 

		INSERT INTO tmp_tarjeta
		VALUES(
		'',
		'',
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		0.00,
		_saldo,
		'006',
		''
		);
	END IF

END FOREACH

-- Polizas que tienen Tarjetas de Credito y su Forma de Pago 
-- No es con Tarjeta de Credito

FOREACH 
 SELECT c.no_documento,
        h.no_tarjeta,
		h.fecha_exp,
		h.nombre,
		c.monto,
		h.cod_banco
   INTO	_no_documento,
        _no_tarjeta,
		_fecha_exp,
		_nombre,
		_monto,
		_cod_banco
   FROM cobtacre c, cobtahab h
  WHERE	periodo      = a_periodo
    AND c.no_tarjeta = h.no_tarjeta
	AND h.tipo_tarjeta = "4"

	LET _cod_formapag = NULL;
	LET _no_poliza    = sp_sis21(_no_documento);

	SELECT cod_formapag,
		   vigencia_inic,
		   vigencia_final
	  INTO _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_formapag IS NULL THEN
		CONTINUE FOREACH;
	END IF

  	SELECT tipo_forma                
  	  INTO _tipo_forma
  	  FROM cobforpa                       
  	 WHERE cod_formapag = _cod_formapag;  
  	                                      
	IF _tipo_forma <> 2 THEN
		CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
			RETURNING   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;
		BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
			INSERT INTO tmp_tarjeta
			VALUES(
			_no_tarjeta,
			_fecha_exp,
			_nombre,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_monto,
			_saldo,
			'007',
			_cod_banco
			);
		END
	END IF
				  	    
END FOREACH

end if

-- Procesa Todas las Tarjetas de Credito
let _fecha_hasta = null;

FOREACH
 SELECT h.no_tarjeta,
		c.monto,
		c.cargo_especial,
		h.fecha_exp,
		c.no_documento,
		h.nombre,
		h.cod_banco,
		c.excepcion,
		h.tipo_tarjeta,
		h.rechazada,
		c.periodo,
		c.periodo2,
		c.fecha_hasta,
		c.fecha_inicio
   INTO _no_tarjeta,
		_monto,
		_cargo,
		_fecha_exp,
		_no_documento,
		_nombre,
		_cod_banco,
		_excepcion,
		_tipo_tarjeta,
		_rechazada,
		_periodo,
		_periodo2,
		_fecha_hasta,
		_fecha_inicio
   FROM cobtacre c, cobtahab h
  WHERE c.no_tarjeta   = h.no_tarjeta
	AND h.tipo_tarjeta = "4"
	and h.rechazada in (_rechazada_si, _rechazada_no)

--    AND (c.periodo      = a_periodo
--	 OR c.periodo2     is not null)

	if _fecha_inicio is null then
		let _fecha_inicio = _fecha_hoy;
	end if
	if a_periodo = _periodo then

		if _periodo2 is null then 		--Esto es para el cargo adicional.
			let _periodo2 = "0";
		end if
		if _fecha_hasta is not null then

			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then
					if _periodo = _periodo2 then   -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo;
					end if
				end if
			end if
		end if
	else
		--Esto es para el cargo adicional.

		if _periodo2 is null then
			let _periodo2 = "0";
		end if
		if _fecha_hasta is not null then

			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then
					if a_periodo = _periodo2 then   -- se debe sumar el cargo al monto
						if _cargo > 0 then
							let _monto = _cargo;
						else
							continue foreach;
						end if
					else
						continue foreach;
					end if
				else
					continue foreach;
				end if
			else
				continue foreach;	
			end if
		else
			continue foreach;
		end if
	end if

	LET _periodo_visa = _fecha_exp[4,7] || '-' || _fecha_exp[1,2];

	LET _vigencia_inic  = NULL;
	LET _vigencia_final = NULL;
	LET _no_poliza      = sp_sis21(_no_documento);

	SELECT vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza,
		   fecha_primer_pago,
		   nueva_renov
	  INTO _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _fecha_1_pago,
		   _nueva_renov
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET _saldo = NULL;

	CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		RETURNING   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;
	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	--esto se pone hasta que me consigan la validacion de la american
--	let _tarjeta_errada = 0;

--	IF _tarjeta_errada = 1 THEN

	IF _saldo = 0 THEN
		LET _procesar = '030';
	ELIF _rechazada = 1 THEN
		if _estatus_visa = "1" then
			LET _procesar = '003';
			update cobtahab
			   set rechazada = 0
			 where no_tarjeta = _no_tarjeta;
		else
			IF _saldo <= 0 THEN
				IF _estatus_poliza = '2' OR
				   _estatus_poliza = '4' THEN
					LET _procesar = '035';
				ELSE
--					IF _ramo_sis = 5 THEN
--						LET _procesar = '100';
--					ELSE
						LET _procesar = '020';
--					END IF			
				END IF
			ELSE
				LET _procesar = '100';
			END IF
		end if
	ELIF _saldo IS NULL THEN
		LET _procesar = '009';
	ELIF _periodo_today > _periodo_visa THEN
	   if _estatus_poliza = '1' And _saldo > 0 then
			LET _procesar = '100';
	   else
			LET _procesar = '010';
	   end if

	ELIF _excepcion = 1 THEN
		LET _procesar = '040';
	ELIF _fecha_1_pago > today and 
	     _nueva_renov = "N" then
		LET _procesar = '004';
	ELIF _saldo <= 0 THEN
		IF _estatus_poliza = '2' OR
		   _estatus_poliza = '4' THEN
			LET _procesar = '035';
		ELSE
			IF _ramo_sis = 5 THEN
				LET _procesar = '100';
			ELSE
				LET _procesar = '020';
			END IF			
		END IF
	ELIF _monto > _saldo THEN
	   --	IF _ramo_sis = 5 THEN
	   --		LET _procesar = '100';
	   --	ELSE
			LET _procesar = '030';
	   --	END IF			
	ELSE
		LET _procesar = '100';
	END IF

	IF _procesar = '100' THEN

		CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
			RETURNING   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						v_saldo;

		IF _monto < v_exigible THEN
			LET _procesar = '090';
			LET _saldo    = v_exigible;
		END IF

	END IF

	BEGIN
	ON EXCEPTION IN(-239)
	END EXCEPTION
		INSERT INTO tmp_tarjeta
		VALUES(
		_no_tarjeta,
		_fecha_exp,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco
		);
	END   		   	
END FOREACH

FOREACH
 SELECT no_tarjeta,
		fecha_exp,
		nombre,
		no_documento,
		vigencia_inic,
		vigencia_final,
		monto,
		saldo,
		procesar,
		cod_banco
   INTO _no_tarjeta,
		_fecha_exp,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco
   FROM tmp_tarjeta
  ORDER BY procesar, nombre

	SELECT nombre
	  INTO _nombre_banco
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	if _estatus_visa = "2" then	--Modo Rechazadas
		select rechazada
		  into _rech
		  from cobtacre
		 where no_tarjeta   = _no_tarjeta
		   and no_documento	= _no_documento;

		if _rech = 1 then
		else
			let _procesar = '040';
		end if
	end if

	IF _procesar = '100' OR
	   _procesar = '090' THEN
		UPDATE cobtacre
		   SET procesar     = 1
		 WHERE no_tarjeta   = _no_tarjeta
		   AND no_documento = _no_documento; 
	ELSE
		UPDATE cobtacre
		   SET procesar     = 0
		 WHERE no_tarjeta   = _no_tarjeta
		   AND no_documento = _no_documento; 
	END IF

	LET _no_poliza = sp_sis21(_no_documento);

	let _ult_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

	FOREACH
	 SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	RETURN _no_tarjeta,
		   _fecha_exp,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   v_compania_nombre,
		   _nombre_agente,
		   _ult_pago
		   WITH RESUME;
    
END FOREACH

COMMIT WORK;
DROP TABLE tmp_tarjeta;

END PROCEDURE;
