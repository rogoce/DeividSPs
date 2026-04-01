-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_emireama;

create procedure ap_emireama()
returning smallint,
          char(50);

define _prima_suscrita	dec(16,2);
define _suma_asegurada	dec(16,2);

define _no_cambio		smallint;
define _cod_cober_reas	char(3);
define _orden			smallint;
define _cod_contrato	char(5);
define _porc_partic		dec(16,5);

define _no_unidad       char(5);
define _cnt             smallint;
define _no_endoso       char(5);


FOREACH
	 SELECT no_unidad
	   INTO _no_unidad
	   FROM emipouni
	  WHERE no_poliza = '0001449168'

	FOREACH
	 SELECT	 no_endoso,
	         cod_cober_reas
	   INTO	_no_endoso,
	        _cod_cober_reas
	   FROM	emifacon
	  WHERE	no_poliza = '0001449168'
		AND no_endoso in ('00003','00006')
		AND no_unidad = _no_unidad
	  GROUP BY no_unidad, no_endoso, cod_cober_reas
	  
	  let _cnt = 0;
	  
	  SELECT count(*)
		INTO _cnt
		FROM emireama
	   WHERE no_poliza = '0001449168'
		 AND no_unidad = _no_unidad
		 AND cod_cober_reas = _cod_cober_reas;

	  if _cnt is null then
		let _cnt = 0;
	  end if
	  
	  if _cnt = 0 then 
		INSERT INTO emireama(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		'0001449168', 
		_no_unidad,
		0,
		_cod_cober_reas,
		'02/03/2020',
		'31/12/2020'
		);
		
		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		'0001449168', 
		no_unidad,
		0,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = '0001449168'
		  AND no_endoso = _no_endoso
		  AND no_unidad	= _no_unidad
		  AND cod_cober_reas = _cod_cober_reas;	
	  end if
	END FOREACH

END FOREACH


end procedure
