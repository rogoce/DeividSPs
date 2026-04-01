-- Verifiacion de los Corredores para la Morosidad
-- 
-- Creado    : 20/01/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_para_sp_par69_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par69;

CREATE PROCEDURE "informix".sp_par69(a_compania CHAR(3), a_agencia CHAR(3), a_periodo DATE) 
RETURNING CHAR(20),  -- Poliza	
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			char(100),
			dec(16,2);

DEFINE v_doc_poliza        	CHAR(20); 
--DEFINE v_vigencia_inic     	DATE;     
--DEFINE v_vigencia_final    	DATE;     
define _no_poliza		   	char(10);
define _cantidad			smallint;
define _porcentaje			dec(16,2);
define _contador			smallint;
define _saldo				dec(16,2);
 
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03a.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

--LET  v_compania_nombre = sp_sis01(a_compania); 

-- Procedimiento que carga la Morosidad por Agente

CALL sp_cob05(
a_compania,
a_agencia,
a_periodo
);


let _contador = 0;

FOREACH
 SELECT	doc_poliza,     
		no_poliza,
		saldo 
   INTO	v_doc_poliza,     
		_no_poliza,
		_saldo 
   FROM	tmp_moros
  WHERE seleccionado = 1
  ORDER BY doc_poliza

	let _contador = _contador + 1;

	select count(*)
	  into _cantidad
	  from emipoagt
	 where no_poliza = _no_poliza;

--{

	if _cantidad = 0 then


		RETURN 	v_doc_poliza,     
				"",  
				"",
				"No tiene corredor",
				_saldo
				WITH RESUME;

	else

		select sum(porc_partic_agt)
		  into _porcentaje
		  from emipoagt
		 where no_poliza = _no_poliza;

		if _porcentaje <> 100 then

			RETURN 	v_doc_poliza,     
					"",  
					"",
					"Porcentaje diferente de 100%",
					_saldo
					WITH RESUME;
		
		end if

	end if
--}


END FOREACH
					 
let v_doc_poliza = _contador;

RETURN 	v_doc_poliza,     
		"",  
		"",
		"Registros Procesados",
		0.00
		WITH RESUME;

DROP TABLE tmp_moros;

END PROCEDURE;

