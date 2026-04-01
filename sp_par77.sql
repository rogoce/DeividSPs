-- Procedimiento que determina las polizas que tienen
-- movimiento errado en el saldo comparando el periodo
-- anterior mas los movimientos del mes y comparando
-- con en periodo actual

drop procedure sp_par77;

create procedure sp_par77(a_compania CHAR(3), a_agencia CHAR(3), a_periodo CHAR(7))
returning char(10),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2);

-- Definicion de Variables

define _periodo_ant		char(7);
define _ano				smallint;
define _mes				smallint;
define _fecha			date;
define _fecha_ant		date;
define _no_poliza		char(10);
define _saldo			dec(16,2);
define _saldo_act		dec(16,2);
define _saldo_ant		dec(16,2);
define _diferencia		dec(16,2);
define _no_documento	char(20);
define _facturas		dec(16,2);
define _cheques			dec(16,2);
define _cobros			dec(16,2);
define _vigencia_final	date;

define _cod_tipoprod4   char(3);
define _cod_tipo_pol	char(3);	

define _saldo_tot       dec(16,2);
define _por_vencer_tot  dec(16,2);
define _exigible_tot    dec(16,2);
define _corriente_tot   dec(16,2);
define _monto_30_tot    dec(16,2);
define _monto_60_tot    dec(16,2);
define _monto_90_tot    dec(16,2);

SET ISOLATION TO DIRTY READ;

SELECT cod_tipoprod
  INTO _cod_tipoprod4
  FROM emitipro
 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

-- Creacion de Tabla Temporal

create temp table tmp_comp(
	no_poliza       CHAR(10),
	saldo_ant       DEC(16,2),
	movi_mes        DEC(16,2),
	saldo_act       DEC(16,2),
	facturas        DEC(16,2) default 0.00,
	cheques         DEC(16,2) default 0.00,
	cobros          DEC(16,2) default 0.00
	) WITH NO LOG;

-- Determinar Periodo Anterior

let _mes = a_periodo[6,7];
let _ano = a_periodo[1,4];

if _mes = 1 then
	let _ano = _ano - 1;
	let _mes = 12;
else
	let _mes = _mes - 1;
end if

if _mes < 10 then
	let _periodo_ant = _ano || "-0" || _mes;
else
	let _periodo_ant = _ano || "-" || _mes;
end if

let _fecha     = sp_sis36(a_periodo);
let _fecha_ant = sp_sis36(_periodo_ant);

FOREACH 
 SELECT no_documento
   INTO	_no_documento
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
GROUP BY no_documento		

	-- Determina la Ultima Vigencia del Documento

	FOREACH
	 SELECT	no_poliza,
		    vigencia_final,
		    cod_tipoprod
	   INTO	_no_poliza,
		   _vigencia_final,
		   _cod_tipo_pol
	   FROM	emipomae
	  WHERE cod_compania       = a_compania		-- Seleccion por Compania
	    AND no_documento       = _no_documento	-- Numero de Poliza
		AND actualizado        = 1			   	-- Poliza este actualizada
	  ORDER BY vigencia_final DESC, no_poliza DESC
		EXIT FOREACH;
	END FOREACH

	-- Si la Ultima Vigencia es Reaseguro Asumido no Evalua el Registro
	IF _cod_tipo_pol = _cod_tipoprod4 THEN
    	CONTINUE FOREACH;
  	END IF

	CALL sp_par78C(
		 a_compania,
		 a_agencia,	
		 _no_documento,
		 _periodo_ant,
		 _fecha_ant
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         

	if _saldo_tot <> 0.00 then

		insert into tmp_comp(
		no_poliza,
		saldo_ant,
		movi_mes,
		saldo_act
		)
		values(
		_no_poliza,
		_saldo_tot,
		0.00,
		0.00
		);

	end if

	CALL sp_par78C(
		 a_compania,
		 a_agencia,	
		 _no_documento,
		 a_periodo,
		 _fecha
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         

	if _saldo_tot <> 0.00 then

		insert into tmp_comp(
		no_poliza,
		saldo_ant,
		movi_mes,
		saldo_act
		)
		values(
		_no_poliza,
		0.00,
		0.00,
		_saldo_tot
		);

	end if

END FOREACH

-- Movimiento del Mes

call sp_cob98(a_compania, a_periodo, a_periodo);  

foreach
 select no_poliza,
        sum(facturas + cheques - cobros),
        sum(facturas),
        sum(cheques),
        sum(cobros)
   into _no_poliza,
        _saldo,
        _facturas,
        _cheques,
        _cobros
   from tmp_comparacion
  group by no_poliza

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	FOREACH 
	 SELECT no_poliza,
	        vigencia_final
	   INTO	_no_poliza,
	        _vigencia_final     
	   FROM emipomae 
	  WHERE cod_compania       = a_compania	  
	    AND actualizado        = 1			  
		AND no_documento       = _no_documento
	  ORDER BY vigencia_final DESC, no_poliza DESC
		EXIT FOREACH;
	END FOREACH

	insert into tmp_comp(
	no_poliza,
	saldo_ant,
	movi_mes,
	saldo_act,
    facturas,
    cheques,
    cobros
	)
	values(
	_no_poliza,
	0.00,
	_saldo,
	0.00,
    _facturas,
    _cheques,
    _cobros
	);

end foreach

drop table tmp_comparacion;

foreach
 select no_poliza,
        sum(saldo_ant + movi_mes),
		sum(saldo_act),
        sum(facturas),
        sum(cheques),
        sum(cobros),
		sum(saldo_ant)
   into _no_poliza,
        _saldo,
		_saldo_act,
	    _facturas,
    	_cheques,
    	_cobros,
		_saldo_ant
   from tmp_comp
  group by no_poliza
  
	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	let _diferencia = _saldo - _saldo_act;

--	if _diferencia <> 0.00 then

		return _no_poliza,
		       _saldo,
			   _saldo_act,
			   _diferencia,
			   _no_documento,
			   _facturas,
		       _cheques,
		       _cobros,
			   _saldo_ant
			   with resume;
--	end if

end foreach
 				
drop table tmp_comp;

end procedure;
