-- Consulta de Movimientos de Cuentas Sac x CHEQUES
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac155('121020402','COB12091','18/12/2009')

drop procedure ap_dif_sql2;
create procedure ap_dif_sql2() 
returning	char(10) as cod_agente,		-- 	requisicion
            varchar(50) as agente,    
            char(30) as estatus_licencia, 
			date as fecha_ult_comis,
			char(6) as tipo_pago,
			dec(16,2) as saldo,		-- 	debito
			dec(16,2) as comision;			

DEFINE _cod_agente        CHAR(10);
DEFINE _agente            VARCHAR(50);
DEFINE _fecha_ult_comis   DATE;
DEFINE _fecha_hasta       DATE;
DEFINE _no_requis         CHAR(10);
DEFINE _fecha_anulado     DATE;
DEFINE _estatus_licencia  CHAR(1);
DEFINE _comision          DEC(16,2);
DEFINE _anulado           SMALLINT;
DEFINE _saldo             DEC(16,2);
DEFINE _tipo_pago         SMALLINT;

set isolation to dirty read;

create temp table tmp_asiento(
		cod_agente	char(10),
        comision    dec(16,2)
		) with no log; 	

--  set debug file to "sp_sac155.trc";	
--  trace on;

foreach
	select fecha_hasta
	  into _fecha_hasta
	  from chqpagco
	 where generado = 0
	order by fecha_hasta
	exit foreach;
end foreach

foreach
	select a.cod_agente,
		   a.fecha_ult_comis
	  into _cod_agente,
		   _fecha_ult_comis
	  from agtagent a
	 where a.tipo_agente in ('A','E')
  
	foreach
		select b.comision
		  into _comision
          from chqcomis b
         where b.cod_agente = _cod_agente
           and b.no_requis is null
		   and b.fecha_desde >= _fecha_ult_comis
		   
		insert into tmp_asiento (
		    cod_agente,
			comision) 
		  values (
		    _cod_agente,
			_comision);
	end foreach

	foreach
		select b.comision,
		       b.no_requis
		  into _comision,
		       _no_requis
          from chqcomis b
         where b.cod_agente = _cod_agente
           and b.no_requis is not null
		   
		select anulado,
		       fecha_anulado
		  into _anulado,
		       _fecha_anulado
		  from chqchmae 
         where no_requis = _no_requis;		  
			   
		if _anulado = 0 then
			continue foreach;
		end if
		
		if _fecha_anulado >= _fecha_ult_comis and _fecha_anulado <= _fecha_hasta then
			insert into tmp_asiento (
				cod_agente,
				comision) 
			  values (
				_cod_agente,
				_comision);
		end if
	end foreach
end foreach

foreach	
  select cod_agente,
		 sum(comision)
	into _cod_agente,
	     _comision
    from tmp_asiento
	group by cod_agente

	select a.cod_agente, 
		   a.estatus_licencia, 
		   a.nombre, 
		   a.saldo,
		   a.fecha_ult_comis,
		   a.tipo_pago
	  into _cod_agente,
		   _estatus_licencia,
		   _agente,
		   _saldo,
		   _fecha_ult_comis,
		   _tipo_pago
	  from agtagent a
	 where a.cod_agente = _cod_agente;
	
  if _comision <> _saldo then	

	  return _cod_agente,
		     _agente,
		     (case when _estatus_licencia = "A" then "ACTIVA" else (case when _estatus_licencia = "P" then "SUSPENSION PERMANENTE" else (case when _estatus_licencia = "T" then "SUSPENSION TEMPORAL" else "SUSPENSION SUPERINTENDENCIA" end) end) end),
		     _fecha_ult_comis,
			 (case when _tipo_pago = 1 then "ACH" else "CHEQUE" end),
		     _saldo,
             _comision with resume;
  end if
end foreach;


drop table tmp_asiento;
end procedure					 