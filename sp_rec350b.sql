-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento
-- Creado 29-05-2024 -- Amado Perez Mendoza

drop procedure sp_rec350b;

create procedure sp_rec350b(a_no_reclamo char(10))
returning dec(16,2);


define _no_tranrec      	char(10);
define _transaccion     	char(10);
DEFINE _porc_partic_reas	DECIMAL(9,6);  -- % reaseguro
DEFINE _porc_partic_coas	DECIMAL(7,4);  -- % coaseguro
DEFINE _cod_coasegur        CHAR(3); 
DEFINE _monto_tran          DEC(16,2);
DEFINE _variacion           DEC(16,2);
DEFINE _tipo_transaccion    SMALLINT;
DEFINE _sumar_incurrido     DEC(16,2);
DEFINE _incurrido_bruto		DEC(16,2);
DEFINE _incurrido_neto		DEC(16,2);
DEFINE _cod_tipotran		CHAR(3);
DEFINE _variacion_bruta     DEC(16,2);
DEFINE _variacion_neta  	DEC(16,2);

set isolation to dirty read;

--set debug file to "sp_rec350b.trc"; 
--trace on;

LET _incurrido_bruto  = 0.00;
LET _incurrido_neto	  = 0.00;
LET _sumar_incurrido  = 0.00;
LET _variacion_bruta  = 0.00;
LET _variacion_neta  = 0.00;

LET _cod_coasegur     = sp_sis02('001', '001');

-- Porcentaje de Coaseguro
	SELECT porc_partic_coas
	  INTO  _porc_partic_coas
	  FROM  reccoas
	 WHERE  no_reclamo = a_no_reclamo
	   AND  cod_coasegur = _cod_coasegur; 

	IF _porc_partic_coas IS NULL THEN
		LET _porc_partic_coas = 0;
	END IF


-- Incurrido Neto
{FOREACH
 SELECT no_tranrec,
		monto,
		variacion,
		cod_tipotran
   INTO _no_tranrec,
		_monto_tran,
		_variacion,
		_cod_tipotran
   FROM rectrmae
  WHERE no_reclamo  = a_no_reclamo
    AND actualizado = 1

	-- Cambio para que refleje el incurrido neto de acuerdo con el
	-- reaseguro a nivel de transaccion

   SELECT tipo_transaccion
	 INTO _tipo_transaccion
	 FROM rectitra
	WHERE cod_tipotran = _cod_tipotran;

	foreach
		select porc_partic_suma
		  into _porc_partic_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1

		if _porc_partic_reas is null then
			let _porc_partic_reas = 0.00;
		end if	
		EXIT FOREACH;		
	end foreach
	
	if _tipo_transaccion = 4 or
	   _tipo_transaccion = 5 or  
	   _tipo_transaccion = 6 or  
	   _tipo_transaccion = 7 then
		let _sumar_incurrido = _monto_tran;
	else
		let _sumar_incurrido = 0.00;
	end if
	
	let _sumar_incurrido = _sumar_incurrido + _variacion;
	let _incurrido_bruto = _sumar_incurrido * _porc_partic_coas / 100;
	let _incurrido_neto  = _incurrido_neto  + (_incurrido_bruto * _porc_partic_reas / 100);

end foreach	
}
-- Variación Neta
FOREACH
 SELECT no_tranrec,
		monto,
		variacion,
		cod_tipotran
   INTO _no_tranrec,
		_monto_tran,
		_variacion,
		_cod_tipotran
   FROM rectrmae
  WHERE no_reclamo  = a_no_reclamo
    AND actualizado = 1

	-- Cambio para que refleje el incurrido neto de acuerdo con el
	-- reaseguro a nivel de transaccion

   SELECT tipo_transaccion
	 INTO _tipo_transaccion
	 FROM rectitra
	WHERE cod_tipotran = _cod_tipotran;

{	foreach
		select porc_partic_suma
		  into _porc_partic_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1

		if _porc_partic_reas is null then
			let _porc_partic_reas = 0.00;
		end if	
		EXIT FOREACH;		
	end foreach}
	
--	if _tipo_transaccion = 4 or
--	   _tipo_transaccion = 5 or  
--	   _tipo_transaccion = 6 or  
--	   _tipo_transaccion = 7 then
--		let _sumar_incurrido = _monto_tran;
--	else
--		let _sumar_incurrido = 0.00;
--	end if
	
--	let _sumar_incurrido = _sumar_incurrido + _variacion;
--	let _variacion_bruta = _variacion * _porc_partic_coas / 100;
--	let _variacion_neta  = _variacion_neta  + (_variacion_bruta * _porc_partic_reas / 100);

	foreach with hold
		select variacion
		  into _variacion
		  from rectrcob
		 where no_tranrec    = _no_tranrec
		 
		let _variacion_neta  = _variacion_neta  + _variacion;		 

	end foreach




end foreach	

return _variacion_neta;

end procedure