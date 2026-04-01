-- Reporte Bono de Persistencia
-- Creado    : 02/03/2023 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che250_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che250a;

CREATE PROCEDURE sp_che250a(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_tipo_pago smallint) 
  RETURNING  CHAR(15),	 --cod_agente
			 CHAR(50),	 --n_corredor
			 SMALLINT,	 --tot_pol_ap
			 SMALLINT,	 --tot_pol_ren_aa
			 SMALLINT,	 --persis
			 DECIMAL(16,2),	 --monto_bono
			 CHAR(3),	 --cod_vendedor
			 CHAR(50),	 --n_vendedor
			 CHAR(50);    --CIA

DEFINE _cod_agente      CHAR(5);

define _cant_pol         integer;
define _no_pol_ren_aa_per		integer;
define _bono, _persis            smallint;
define _n_corredor,_n_zona , v_nombre_cia varchar(50);
define _cod_vendedor char(3);
DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5); 
define _tipo_pago     smallint; 

let _cant_pol = 0;
let _bono     = 0;
let _tipo_pago = 0;

--SET DEBUG FILE TO "\\sp_che250.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 
if a_cod_agente = "*" then

FOREACH
  SELECT cod_agente,
		n_corredor,
		tot_pol_ap,
		tot_pol_ren_aa,
		persis,
		monto_bono,
		cod_vendedor,
		n_vendedor		
   INTO	v_cod_agente,
		_n_corredor, 
		_cant_pol, 
		_no_pol_ren_aa_per, 
		_persis, 
		_bono,
		_cod_vendedor,
		_n_zona 
   FROM	chqbopersis
  WHERE cod_agente matches a_cod_agente
	and periodo  = a_periodo	

    SELECT tipo_pago
      INTO _tipo_pago
      FROM agtagent
     WHERE cod_agente = v_cod_agente;

	if a_tipo_pago = 0 then
	elif a_tipo_pago = 1 then
		if _tipo_pago <> 1 then
			continue foreach;
		end if
	else
		if _tipo_pago <> 2 then
			continue foreach;
		end if
	end if

	return v_cod_agente,	
			_n_corredor, 
			_cant_pol,
			_no_pol_ren_aa_per, 
			_persis, 
			_bono,
			_cod_vendedor,
			_n_zona,
            v_nombre_cia			
	with resume;

	
END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		  SELECT cod_agente,
				n_corredor,
				tot_pol_ap,
				tot_pol_ren_aa,
				persis,
				monto_bono,
				cod_vendedor,
				n_vendedor		
		   INTO	v_cod_agente,
				_n_corredor, 
				_cant_pol, 
				_no_pol_ren_aa_per, 
				_persis, 
				_bono,
				_cod_vendedor,
				_n_zona 
		   FROM	chqbopersis
		  WHERE cod_agente IN (SELECT codigo FROM tmp_codigos)
			and periodo  = a_periodo

		    SELECT tipo_pago
		      INTO _tipo_pago
		      FROM agtagent
		     WHERE cod_agente = v_cod_agente;

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if

			return v_cod_agente,	
					_n_corredor, 
					_cant_pol,
					_no_pol_ren_aa_per, 
					_persis, 
					_bono,
					_cod_vendedor,
					_n_zona,
					v_nombre_cia			
			with resume;
			
		END FOREACH

	ELSE		        -- Excluir estos Registros

		FOREACH
		  SELECT cod_agente,
				n_corredor,
				tot_pol_ap,
				tot_pol_ren_aa,
				persis,
				monto_bono,
				cod_vendedor,
				n_vendedor		
		   INTO	v_cod_agente,
				_n_corredor, 
				_cant_pol, 
				_no_pol_ren_aa_per, 
				_persis, 
				_bono,
				_cod_vendedor,
				_n_zona 
		   FROM	chqbopersis
		  WHERE cod_agente NOT IN (SELECT codigo FROM tmp_codigos)
			and periodo  = a_periodo

		    SELECT tipo_pago
		      INTO _tipo_pago
		      FROM agtagent
		     WHERE cod_agente = v_cod_agente;

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if

			return v_cod_agente,	
					_n_corredor, 
					_cant_pol,
					_no_pol_ren_aa_per, 
					_persis, 
					_bono,
					_cod_vendedor,
					_n_zona,
					v_nombre_cia			
			with resume;

			
		END FOREACH

	END IF

	DROP TABLE tmp_codigos;

end if

END PROCEDURE;