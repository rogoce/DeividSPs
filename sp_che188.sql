-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che188;

CREATE PROCEDURE informix.sp_che188() 
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

FOREACH
	select a.cod_agente, 
	       a.nombre,
		   a.saldo, 
		   a.estatus_licencia
	  into _cod_agente,
	       _agente,
		   _saldo,
		   _estatus_licencia
	  from agtagent a
	 where a.tipo_agente <> 'O'
	   and a.saldo <> 0
	group by a.cod_agente, a.nombre, a.saldo, a.estatus_licencia
	order by a.nombre

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
	   and b.anulado = 1;
	   
	if _comision2 is null then
		let _comision2 = 0;
	end if
	
	let _comision = _comision + _comision2;
	
	if _comision = _saldo then
		continue foreach;
	end if

{	let _auxiliar = 'A' || _cod_agente[2,5];

	select sum(res1_debito) - sum(res1_credito) 
	  into _saldo_26410
	  from cglresumen1 
	 where res1_auxiliar = _auxiliar
	   and res1_cuenta   = '26410';	
}
   
	RETURN _cod_agente,		--1
	       _agente,
		   _estatus_licencia,
		   _saldo,
		   _comision,
		   0.00		--10
		   WITH RESUME;

END FOREACH
END PROCEDURE;