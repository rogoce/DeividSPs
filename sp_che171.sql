-- Reporte de las Bono de Vida Individual(Nuevas) por Corredor - Detallado
-- Creado    : 08/02/2008 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che170_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che171;

CREATE PROCEDURE sp_che171(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_tipo_pago smallint, a_periodo2 char(7)) 
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
			char(20)  as poliza, 
			dec(16,2) as prima_sus_nva,
			dec(16,2) as monto_bono,
			dec(9,4)  as porc_bono,		
			char(100) as nombre_clte,	    
			char(7)   as periodo,
			CHAR(10)  as no_requis,
			smallint  as retroactivo,
			char(100) as observacion;											

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
define _no_documento    char(20); 
define _prima_sus_nva   dec(16,2);
define _monto_bono		dec(16,2);
define _porc_bono		dec(9,4);
define _nombre_clte	    char(100);
define _periodo			char(7);
DEFINE _no_requis		CHAR(10);
define _periodo_pago    char(7);
define _rezagada        smallint;
define _aplica          smallint;
define _motivo          char(100);
define _flag            smallint;

--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON; 

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  _nombre_cia = sp_sis01(a_compania); 
let _motivo          = '';
SET ISOLATION TO DIRTY READ;

let	_cod_bono = '001';
let	_prima_sus_agt = 0;
let	_bono = 0;                    	
let	_monto_bono = 0;
let	_porc_bono = 0;                    	
let	_retroactivo = 0;   
if a_cod_agente = "*" then

FOREACH
 SELECT	e.periodo,
		e.cod_agente,
		e.pri_sus_act,
		e.cantidad,
		e.bono_queda,
		e.bono_recupero,
		e.n_agente,
		e.cod_ramo,
		e.nombre_ramo,
		e.licencia,
		e.tipo_pago,
		e.bono,
	    d.no_documento,
	    d.prima_sus_nva,
	    d.monto_bono,
	    d.porc_bono,
	    d.nombre_cte,
	    d.no_requis,
	    d.periodo_pago,
		d.rezagada,
  	    d.aplica,
		d.motivo
   INTO	_periodo,
	    _cod_agente,
	    _prima_sus_agt,
	    _cantidad,
	    _bono_queda,
	    _bono_recupero,	   
	    _nombre,
	    _cod_ramo,
	    _nombre_ramo,
	    _licencia,
	    _tipo_pago,
	    _bono,
	    _no_documento,
	    _prima_sus_nva,
	    _monto_bono,
	    _porc_bono,
	    _nombre_clte,
	    _no_requis,
	    _periodo_pago,
	    _rezagada,	   
	    _aplica,
        _motivo		
   FROM	chqbono019e e, chqbono019 d
  WHERE d.cod_agente matches a_cod_agente   
    and e.periodo = d.periodo
	and e.cod_agente = d.cod_agente
	and d.periodo_pago  >= a_periodo
	and d.periodo_pago  <= a_periodo2
	and e.cia = a_compania		
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
		{let _flag = 0;
		 SELECT count(*)	
		   INTO _flag
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente = _cod_agente
			and e.periodo = d.periodo			
			and e.cod_agente = d.cod_agente
			and d.periodo_pago  >= a_periodo
			and d.periodo_pago  <= a_periodo2
			and e.cia = a_compania		
			and d.aplica = 1;	
			
			if _flag is null then 		
					let _flag = 0;			
			end if			
			
			if _flag > 0 then 
			    continue foreach;
			end if}
		
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
		
        if trim(lower(_motivo)) = 'poliza no se pago su primera letra.' and _aplica = 0 then
				let _retroactivo = 5;
		end if
          if trim(lower(_motivo)) = 'poliza pago voluntario con saldo.' and _aplica = 0 then
				let _retroactivo = 6;
		end if
        if trim(lower(_motivo)) = 'poliza no aplica por tipo agente.' and _aplica = 0 then
				let _retroactivo = 7;
		end if
	
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
				_no_documento,
				_prima_sus_nva,
				_monto_bono,
				_porc_bono,
				_nombre_clte,				
				_periodo,
				_no_requis,											
				_retroactivo,
                _motivo				
				WITH RESUME;
						
						
			
	
END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		 SELECT	e.periodo,
				e.cod_agente,
				e.pri_sus_act,
				e.cantidad,
				e.bono_queda,
				e.bono_recupero,
				e.n_agente,
				e.cod_ramo,
				e.nombre_ramo,
				e.licencia,
				e.tipo_pago,
				e.bono,
				d.no_documento,
				d.prima_sus_nva,
				d.monto_bono,
				d.porc_bono,
				d.nombre_cte,
				d.no_requis,
				d.periodo_pago,
				d.rezagada,
				d.aplica,
	 	        d.motivo
		   INTO	_periodo,
				_cod_agente,
				_prima_sus_agt,
				_cantidad,
				_bono_queda,
				_bono_recupero,	   
				_nombre,
				_cod_ramo,
				_nombre_ramo,
				_licencia,
				_tipo_pago,
				_bono,
				_no_documento,
				_prima_sus_nva,
				_monto_bono,
				_porc_bono,
				_nombre_clte,
				_no_requis,
				_periodo_pago,
				_rezagada,	   
				_aplica,
		        _motivo	
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente IN (SELECT codigo FROM tmp_codigos)
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago  >= a_periodo
			and d.periodo_pago  <= a_periodo2
			and e.cia = a_compania			
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
			
		{let _flag = 0;
		 SELECT count(*)	
		   INTO _flag
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente = _cod_agente 
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago  >= a_periodo
			and d.periodo_pago  <= a_periodo2
			and e.cia = a_compania		
			and d.aplica = 1;	
			
			if _flag is null then 		
					let _flag = 0;			
			end if			
			
			if _flag > 0 then 
			    continue foreach;
			end if}
			
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
			
			if trim(lower(_motivo)) = 'poliza no se pago su primera letra.' and _aplica = 0 then
					let _retroactivo = 5;
			end if
           if trim(lower(_motivo)) = 'poliza pago voluntario con saldo.' and _aplica = 0 then
				let _retroactivo = 6;
		end if
        if trim(lower(_motivo)) = 'poliza no aplica por tipo agente.' and _aplica = 0 then
				let _retroactivo = 7;
		end if
			
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
					_no_documento,
					_prima_sus_nva,
					_monto_bono,
					_porc_bono,
					_nombre_clte,
					_periodo,
					_no_requis,											
					_retroactivo,
                    _motivo					
					WITH RESUME;

		END FOREACH			
			
		

	ELSE		        -- Excluir estos Registros

		FOREACH
		 SELECT	e.periodo,
				e.cod_agente,
				e.pri_sus_act,
				e.cantidad,
				e.bono_queda,
				e.bono_recupero,
				e.n_agente,
				e.cod_ramo,
				e.nombre_ramo,
				e.licencia,
				e.tipo_pago,
				e.bono,
				d.no_documento,
				d.prima_sus_nva,
				d.monto_bono,
				d.porc_bono,
				d.nombre_cte,
				d.no_requis,
				d.periodo_pago,
				d.rezagada,
				d.aplica,
		        d.motivo
		   INTO	_periodo,
				_cod_agente,
				_prima_sus_agt,
				_cantidad,
				_bono_queda,
				_bono_recupero,	   
				_nombre,
				_cod_ramo,
				_nombre_ramo,
				_licencia,
				_tipo_pago,
				_bono,
				_no_documento,
				_prima_sus_nva,
				_monto_bono,
				_porc_bono,
				_nombre_clte,
				_no_requis,
				_periodo_pago,
				_rezagada,	   
				_aplica,
                _motivo				
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente NOT IN (SELECT codigo FROM tmp_codigos) 
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago  >= a_periodo
			and d.periodo_pago  <= a_periodo2
			and e.cia = a_compania			
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
		{let _flag = 0;
		 SELECT count(*)	
		   INTO _flag
		   FROM	chqbono019e e, chqbono019 d
		  WHERE d.cod_agente = _cod_agente 
			and e.periodo = d.periodo
			and e.cod_agente = d.cod_agente
			and d.periodo_pago  >= a_periodo
			and d.periodo_pago  <= a_periodo2
			and e.cia = a_compania		
			and d.aplica = 1;	
			
			if _flag is null then 		
					let _flag = 0;			
			end if			
			
			if _flag > 0 then 
			    continue foreach;
			end if}
			
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
			
			if trim(lower(_motivo)) = 'poliza no se pago su primera letra.' and _aplica = 0 then
					let _retroactivo = 5;
			end if
           if trim(lower(_motivo)) = 'poliza pago voluntario con saldo.' and _aplica = 0 then
				let _retroactivo = 6;
		end if
        if trim(lower(_motivo)) = 'poliza no aplica por tipo agente.' and _aplica = 0 then
				let _retroactivo = 7;
		end if
			
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
					_no_documento,
					_prima_sus_nva,
					_monto_bono,
					_porc_bono,
					_nombre_clte,
					_periodo,
					_no_requis,											
					_retroactivo,
                    _motivo					
					WITH RESUME;
		
			
		END FOREACH

	END IF
	DROP TABLE tmp_codigos;
end if

END PROCEDURE 
                                                                                                         
