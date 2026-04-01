-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che190;

CREATE PROCEDURE informix.sp_che190() 
  RETURNING CHAR(5) as cod_agente,
			VARCHAR(50) as agente,
			CHAR(1) as estatus_licencia,
			DECIMAL(16,2) as saldo_agente,
			DECIMAL(16,2) as saldo_chqcomis,
			date as fecha_ult_comis,
			integer as afectada,
			smallint as generar_cheque;
				   		

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
define _cnt         integer;
define _generar_cheque smallint;

set isolation to dirty read;

FOREACH
	select a.cod_agente, 
	       a.nombre,
		   a.saldo, 
		   a.estatus_licencia,
		   a.fecha_ult_comis,
		   a.generar_cheque
	  into _cod_agente,
	       _agente,
		   _saldo,
		   _estatus_licencia,
		   _fecha_ult_comis,
		   _generar_cheque
	  from agtagent a
	 where a.tipo_agente <> 'O'
	   and a.estatus_licencia = 'P'
	   and a.saldo <> 0
	order by a.nombre
	 
	let _comision = 0;

	select sum(a.comision) 
	  into _comision
	  from chqcomis a
	   where a.cod_agente = _cod_agente
	   AND a.fecha_desde > _fecha_ult_comis
	 --  AND a.fecha_hasta <= '27/10/2020'
	   AND a.no_requis is null;
	   
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
		and a.no_requis is not null
		AND b.fecha_anulado >= _fecha_ult_comis;
--		AND b.fecha_anulado <= '27/10/2020';
	   
	if _comision2 is null then
		let _comision2 = 0;
	end if
	
	let _comision = _comision + _comision2;
	
--	if _saldo = _comision then
--		continue foreach;
--	end if

    select count(*)
      into _cnt
      from chqcomis
     where fecha_desde >= '20/10/2020'
       and fecha_hasta <= '27/10/2020'
	   and cod_agente = _cod_agente;
	   
   
	RETURN _cod_agente,		--1
	       _agente,
		   _estatus_licencia,
		   _saldo,
		   _comision,
		   _fecha_ult_comis,
           _cnt,		   --10
		   _generar_cheque
		   WITH RESUME;

END FOREACH
END PROCEDURE;