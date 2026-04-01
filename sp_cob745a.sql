-- Reporte de Diferencia de Comision
-- 
-- Creado    : 02/12/2008 - Autor: Henry Giron
-- Modificado: 02/12/2008 - Autor: Henry Giron
--
-- SIS v.2.0 - d_cobr_sp_cob16_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob745a;

CREATE PROCEDURE sp_cob745a(a_periodo1 char(7), a_periodo2 char(7))
RETURNING   CHAR(7),
			CHAR(5),	
			CHAR(50),	
			CHAR(20),
			CHAR(50),	
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(5,2),
			DEC(16,2),
			CHAR(10),
			SMALLINT;

																			 
DEFINE v_doc_remesa 	char(30);											 
DEFINE v_monto 			dec(16,2);											 
DEFINE v_prima_neta 	dec(16,2);											 
DEFINE v_no_remesa  	char(10);
define _no_poliza       char(10);											 
DEFINE v_renglon 		smallint;											 
DEFINE v_cod_agente 	char(5);											 
DEFINE v_monto_calc 	dec(16,2);											 
DEFINE v_monto_man  	dec(16,2); 											 
DEFINE v_porc_comis		dec(5,2);											 
DEFINE v_porc_partic	dec(5,2);
DEFINE _n_agente        VARCHAR(50);
DEFINE _n_cliente       VARCHAR(50); 
DEFINE _cod_cliente     char(10);
define _periodo         char(7);
DEFINE _dif             DEC(16,2);

-- Nombre de la Compania

LET _n_agente  = '';
LET	_n_cliente = '';

-- Busca la diferencias de comisiones
FOREACH 
  SELECT t.doc_remesa,
         t.monto,
         t.prima_neta,
         t.no_remesa,  
         t.renglon,
         t.periodo, 
         c.cod_agente,
         c.monto_calc,   
         c.monto_man,  
         c.porc_comis_agt,
         c.porc_partic_agt
	INTO v_doc_remesa,
		 v_monto,
		 v_prima_neta,
		 v_no_remesa,
		 v_renglon,
		 _periodo,
		 v_cod_agente,
		 v_monto_calc,
		 v_monto_man,
		 v_porc_comis,
		 v_porc_partic 
    FROM cobreagt c, cobredet t
   WHERE t.no_remesa = c.no_remesa
     and t.renglon   = c.renglon
     and t.periodo   >= a_periodo1
     and t.periodo   <= a_periodo2
     and c.monto_calc <> c.monto_man
   order by t.periodo,t.renglon

    select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = v_cod_agente;

	let _no_poliza = sp_sis21(v_doc_remesa);

	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _dif = 0;

    let _dif = v_monto_calc - v_monto_man;

	RETURN	_periodo,
			v_cod_agente,
			_n_agente,
         	v_doc_remesa,
			_n_cliente,
		    v_prima_neta,
		    v_monto,
		    v_monto_calc,
		    v_monto_man,
		    v_porc_comis,
			_dif,
		    v_no_remesa,
		    v_renglon
		 	WITH RESUME;	 		

END FOREACH


END PROCEDURE;

