-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che191;

CREATE PROCEDURE informix.sp_che191() 
  RETURNING CHAR(5) as cod_agente,
			VARCHAR(50) as agente,
			CHAR(1) as estatus_licencia,
			DECIMAL(16,2) as saldo_agente,
			DECIMAL(16,2) as saldo_chqcomis,
			DECIMAL(16,2) as saldo_26410;
				   		

DEFINE _cod_agente char(5);
DEFINE _saldo      dec(16,2);
DEFINE _comision   dec(16,2);
DEFINE _estatus_licencia char(1);
DEFINE _auxiliar   char(5); 
DEFINE _agente     VARCHAR(50);
DEFINE _saldo_26410 dec(16,2);
DEFINE _comision2   dec(16,2);
DEFINE _saldo_ant   dec(16,2);
DEFINE _saldo_act   dec(16,2);
DEFINE _no_requis   char(10);
DEFINE _fecha_ult_comis DATE;

set isolation to dirty read;

FOREACH
	select cod_agente,
	       no_requis,
		   monto
      into _cod_agente,
	       _no_requis,
		   _saldo_26410
	  from chqchmae
	 where origen_cheque in ('2', '7') and fecha_captura = '22/10/2020'

	select a.nombre,
		   a.saldo, 
		   a.estatus_licencia
	  into _agente,
		   _saldo,
		   _estatus_licencia
	  from agtagent a
	 where a.cod_agente = _cod_agente;
	 
	let _comision = 0;

	select sum(a.comision) 
	  into _comision
	  from chqcomis a
	   where a.cod_agente = _cod_agente
	   and a.no_requis is null;
	   
	if _comision is null then
		let _comision = 0;
	end if	   

	let _comision2 = 0;
	
	select sum(a.comision) 
	  into _comision2
	  from chqcomis a, chqchmae b
	 where a.no_requis = b.no_requis
	   and a.cod_agente = _cod_agente
	   and b.anulado = 1
	   and b.fecha_anulado >= '14/10/2020'
	   and b.fecha_anulado <= '20/10/2020';
	   
	if _comision2 is null then
		let _comision2 = 0;
	end if
	
	let _comision = _comision + _comision2;
	
   
	RETURN _cod_agente,		--1
	       _agente,
		   _estatus_licencia,
		   _saldo,
		   _comision,
		   _saldo_26410		--10
		   WITH RESUME;

END FOREACH
END PROCEDURE;