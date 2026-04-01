-- Reporte de las Bono de Vida Individual(Nuevas) por Corredor - Detallado
-- Creado    : 08/02/2008 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che170_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che170;

CREATE PROCEDURE sp_che170(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_tipo_pago smallint, a_periodo2 char(7)) 
  RETURNING char(5)   as cod_agente,
			dec(16,2) as prima_sus_agt,
			smallint  as cantidad,
			dec(16,2) as bono_queda,
			dec(16,2) as bono_recupero,	   
			char(100) as nombre,
			char(3)   as cod_ramo,  
			char(50)  as nombre_ramo,
			char(10)  as licencia,
			char(3)   as cod_bono,  
			char(50)  as nombre_cia,
			dec(16,2) as bono,
			char(7)   as periodo,
			smallint  as retroactivo;											
define _retroactivo     smallint;			
DEFINE _tipo            char(1);
define _tipo_pago       smallint;
define _cod_agente   	char(5);
define _prima_sus_agt   dec(16,2);
define _cantidad        smallint;
define _bono_queda      dec(16,2);
define _bono_recupero   dec(16,2);	   
define _bono            dec(16,2);	   
define _nombre          char(100);
define _cod_ramo        char(3);  
define _nombre_ramo     char(50);
define _licencia        char(10);
define _cod_bono        char(3);  
define _nombre_cia      char(50);
define _periodo         char(7);
define _rezagada        smallint;
define _aplica          smallint;

--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON; 

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  _nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_cod_bono  = '001';
let	_prima_sus_agt  = 0;
let	_bono  = 0;                    	
let	_retroactivo = 0;  
if a_cod_agente = "*" then

FOREACH
SELECT	e.cia,
		e.periodo,
		e.cod_agente,						
		e.bono_queda,
		e.bono_recupero,
		e.n_agente,
		e.cod_ramo,
		e.nombre_ramo,
		e.licencia,
		e.tipo_pago,
		d.rezagada,
		d.aplica,
		sum(decode(trim(d.motivo),null,1,'',1,0)), --count(d.no_documento), --e.cantidad,
		sum(d.prima_sus_nva), --e.pri_sus_act,				
		sum(d.monto_bono) --e.bono
   INTO	a_compania,
	   _periodo,
	   _cod_agente,
	   _bono_queda,
	   _bono_recupero,	   
	   _nombre,
	   _cod_ramo,
	   _nombre_ramo,
	   _licencia,
	   _tipo_pago,
	   _rezagada,	   
	   _aplica,
	   _cantidad,	   
	   _prima_sus_agt,
	   _bono
   FROM	chqbono019e e, chqbono019 d 
  WHERE d.cod_agente matches a_cod_agente 
    and e.periodo = d.periodo 
	and e.cod_agente = d.cod_agente 
	and d.periodo_pago  >= a_periodo 
	and d.periodo_pago  <= a_periodo2 
	and e.cia = a_compania 	 
  group by 1,2,3,4,5,6,7,8,9,10,11,12
  having sum(decode(trim(d.motivo),null,1,'',1,0)) > 0
  order by e.periodo
	
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
		
		if _aplica is null then 
			let _aplica = 0;
		end if
		if _rezagada is null then 
			let _rezagada = 0;
		end if
		
		if _aplica = 1 then
			if _rezagada = 1 then
				let _retroactivo = 2;
			else
				let _retroactivo = 3;
			end if	
		else
			let _retroactivo = 4;
		end if				

	 SELECT	bono
	   INTO _bono
	   FROM	chqbono019e 
	  WHERE cod_agente = _cod_agente
		AND periodo  = _periodo;
	
	 RETURN _cod_agente,
			_prima_sus_agt,
			_cantidad,
			_bono_queda,
			_bono_recupero,
			_nombre,
			_cod_ramo,
			_nombre_ramo,
			_licencia,
			_cod_bono,
			_nombre_cia,
            _bono,
            _periodo,
            _retroactivo			
			WITH RESUME;
	
END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		SELECT	e.cia,
				e.periodo,
				e.cod_agente,						
				e.bono_queda,
				e.bono_recupero,
				e.n_agente,
				e.cod_ramo,
				e.nombre_ramo,
				e.licencia,
				e.tipo_pago,
				d.rezagada,
				d.aplica,
				sum(decode(trim(d.motivo),null,1,'',1,0)), --count(d.no_documento), --e.cantidad,
				sum(d.prima_sus_nva), --e.pri_sus_act,				
				sum(d.monto_bono) --e.bono
		   INTO	a_compania,
			   _periodo,
			   _cod_agente,
			   _bono_queda,
			   _bono_recupero,	   
			   _nombre,
			   _cod_ramo,
			   _nombre_ramo,
			   _licencia,
			   _tipo_pago,
			   _rezagada,	   
			   _aplica,
			   _cantidad,	   
			   _prima_sus_agt,
			   _bono	   
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente IN (SELECT codigo FROM tmp_codigos)
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago >= a_periodo
			and d.periodo_pago <= a_periodo2
			and e.cia = a_compania			
			group by 1,2,3,4,5,6,7,8,9,10,11,12
   having sum(decode(trim(d.motivo),null,1,'',1,0)) > 0
			order by e.periodo

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
			
			if _aplica is null then 
				let _aplica = 0;
			end if
			if _rezagada is null then 
				let _rezagada = 0;
			end if
			
			if _aplica = 1 then
				if _rezagada = 1 then
					let _retroactivo = 2;
				else
					let _retroactivo = 3;
				end if	
			else
				let _retroactivo = 4;
			end if						
			
	        SELECT	bono
	          INTO _bono
	          FROM	chqbono019e 
	         WHERE cod_agente = _cod_agente
		       AND periodo  = _periodo;			
			
			 RETURN _cod_agente,
					_prima_sus_agt,
					_cantidad,
					_bono_queda,
					_bono_recupero,
					_nombre,
					_cod_ramo,
					_nombre_ramo,
					_licencia,
					_cod_bono,
					_nombre_cia,
                    _bono,
					_periodo,
					_retroactivo			
					WITH RESUME;
			
		END FOREACH

	ELSE		        -- Excluir estos Registros

		FOREACH
		SELECT	e.cia,
				e.periodo,
				e.cod_agente,						
				e.bono_queda,
				e.bono_recupero,
				e.n_agente,
				e.cod_ramo,
				e.nombre_ramo,
				e.licencia,
				e.tipo_pago,
				d.rezagada,
				d.aplica,
				sum(decode(trim(d.motivo),null,1,'',1,0)), --count(d.no_documento), --e.cantidad,
				sum(d.prima_sus_nva), --e.pri_sus_act,				
				sum(d.monto_bono) --e.bono
		   INTO	a_compania,
			   _periodo,
			   _cod_agente,
			   _bono_queda,
			   _bono_recupero,	   
			   _nombre,
			   _cod_ramo,
			   _nombre_ramo,
			   _licencia,
			   _tipo_pago,
			   _rezagada,	   
			   _aplica,
			   _cantidad,	   
			   _prima_sus_agt,
			   _bono	   
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente NOT IN (SELECT codigo FROM tmp_codigos) 
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago >= a_periodo
			and d.periodo_pago <= a_periodo2
			and e.cia = a_compania			
		  group by 1,2,3,4,5,6,7,8,9,10,11,12
    having sum(decode(trim(d.motivo),null,1,'',1,0)) > 0
		  order by e.periodo

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
			
			if _aplica is null then 
				let _aplica = 0;
			end if
			if _rezagada is null then 
				let _rezagada = 0;
			end if
			
			if _aplica = 1 then
				if _rezagada = 1 then
					let _retroactivo = 2;
				else
					let _retroactivo = 3;
				end if	
			else
				let _retroactivo = 4;
			end if	
			
	        SELECT	bono
	          INTO _bono
	          FROM	chqbono019e 
	         WHERE cod_agente = _cod_agente
		       AND periodo  = _periodo;														
			
			 RETURN _cod_agente,
					_prima_sus_agt,
					_cantidad,
					_bono_queda,
					_bono_recupero,
					_nombre,
					_cod_ramo,
					_nombre_ramo,
					_licencia,
					_cod_bono,
					_nombre_cia,
                    _bono,
					_periodo,
					_retroactivo			
					WITH RESUME;

			
		END FOREACH

	END IF
	DROP TABLE tmp_codigos;
end if

END PROCEDURE 
                                                                                                                                                                            
