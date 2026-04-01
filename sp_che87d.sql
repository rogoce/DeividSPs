-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che87d;
CREATE PROCEDURE sp_che87d(a_compania CHAR(3), a_cod_agente CHAR(255) default '*') 
RETURNING CHAR(5), CHAR(50), DEC(16,2), DEC(16,2), char(50),char(7);

DEFINE v_cod_agente   			   CHAR(5);  
DEFINE v_nombre_cia,_n_agente      CHAR(50);
define _prima_falta,_prima_cobrada DEC(16,2);
define _tipo 					   char(1);
define _periodo 				   char(7);


--SET DEBUG FILE TO "\\sp_che87a.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_prima_cobrada = 0;
let	_prima_falta = 0;

select ult_per_boni
  into _periodo
  from parparam;

if a_cod_agente = "*" then

	FOREACH
		SELECT c.cod_agente,
			   c.prima_cobrada,
			   t.nombre,
			   50000 - c.prima_cobrada
		  INTO v_cod_agente,
			   _prima_cobrada,
			   _n_agente,
			   _prima_falta
		  FROM	chqboagt c, agtagent t
		 where c.cod_agente = t.cod_agente 
		 order by t.nombre
		 
		if _prima_cobrada >= 50000 then
			let _prima_falta = 0;
		end if

		RETURN  v_cod_agente, _n_agente, _prima_cobrada, _prima_falta, v_nombre_cia,_periodo WITH RESUME;
			
	END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		 SELECT c.cod_agente,
			   c.prima_cobrada,
			   t.nombre,
			   50000 - c.prima_cobrada
		  INTO v_cod_agente,
			   _prima_cobrada,
			   _n_agente,
			   _prima_falta
		  FROM	chqboagt c, agtagent t
		 where c.cod_agente = t.cod_agente 
		   and c.cod_agente IN (SELECT codigo FROM tmp_codigos)
		 order by t.nombre

		if _prima_cobrada >= 50000 then
			let _prima_falta = 0;
		end if
		RETURN  v_cod_agente, _n_agente, _prima_cobrada, _prima_falta, v_nombre_cia,_periodo WITH RESUME;
		END FOREACH
	ELSE		        -- Excluir estos Registros

		FOREACH
			SELECT c.cod_agente,
				   c.prima_cobrada,
		           t.nombre,
		           50000 - c.prima_cobrada
		      INTO v_cod_agente,
		           _prima_cobrada,
		           _n_agente,
		           _prima_falta
	 	      FROM chqboagt c, agtagent t
		     where c.cod_agente = t.cod_agente 
		       and c.cod_agente NOT IN (SELECT codigo FROM tmp_codigos)
		     order by t.nombre
			
			if _prima_cobrada >= 50000 then
				let _prima_falta = 0;
			end if
			RETURN  v_cod_agente, _n_agente, _prima_cobrada, _prima_falta, v_nombre_cia,_periodo WITH RESUME;
		END FOREACH
	END IF
	DROP TABLE tmp_codigos;
end if
END PROCEDURE;