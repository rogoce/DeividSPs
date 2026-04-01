-- Proced.,imiento que crea los registros para la consolidacion de companias

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo020;

create procedure "informix".sp_bo020()
returning integer,
          char(50);


define _tipo    char(2);
define _cuenta  char(12);
define _ccosto  char(3);
define _ano     char(4);
define _periodo smallint;

define _debito	dec(16,2);
define _credito	dec(16,2);
define _neto	dec(16,2);

define _enlace 	char(10);
define _recibe  char(1);
define _null	char(1);

define _error	integer;
define _cia_con	char(3);

set isolation to dirty read;

let _cia_con = "999"; -- Compania Consolidada

begin 
on exception set _error
	return _error, "Error al Actualizar Registros";
end exception

let _null = null;

foreach 
 select sldet_tipo, 
 		sldet_cuenta, 
 		sldet_ano, 
 		sldet_periodo,
        sum(sldet_debtop),
		sum(sldet_cretop),
		sum(sldet_saldop)
   into _tipo,
        _cuenta,
		_ano,
		_periodo,
		_debito,
		_credito,
		_neto
   from ef_saldodet
  where sldet_ccosto <> _cia_con 
  group by sldet_tipo, sldet_cuenta, sldet_ano, sldet_periodo
  order by sldet_tipo, sldet_cuenta, sldet_ano, sldet_periodo

	insert into ef_saldodet(
	sldet_tipo,
	sldet_cuenta,
	sldet_ccosto,
	sldet_ano,
	sldet_periodo,
	sldet_debtop,
	sldet_cretop,
	sldet_saldop,
	sldet_enlace,
	sldet_recibe
	)
	values(
	_tipo,
	_cuenta,
	_cia_con,
	_ano,
	_periodo,
	_debito,
	_credito,
	_neto,
	_null,
	_null
	);

end foreach

{
-- (SAC) - Aseguradora Ancon, S. A. 

foreach
 select res_tipo_resumen,
		res_cuenta,
		res_ccosto,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into	_tipo,   
		_cuenta, 
		_ccosto, 
		_ano,    
		_periodo,
		_debito,	
		_credito,
		_neto	
   from	sac:cglresumen
  where res_tipcomp = "014"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	update ef_saldodet
	   set sldet_debtop  = sldet_debtop - _debito,
		   sldet_cretop  = sldet_cretop - _credito,
		   sldet_saldop  = sldet_saldop - _neto
	 where sldet_tipo	 = _tipo
	   and sldet_cuenta	 = _cuenta
	   and sldet_ccosto	 = _cia_con
	   and sldet_ano	 = _ano
	   and sldet_periodo = _periodo;

end foreach

-- (SAC001) - Allied 

foreach
 select res_tipo_resumen,
		res_cuenta,
		res_ccosto,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into	_tipo,   
		_cuenta, 
		_ccosto, 
		_ano,    
		_periodo,
		_debito,	
		_credito,
		_neto	
   from	sac001:cglresumen
  where res_tipcomp = "014"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	update ef_saldodet
	   set sldet_debtop  = sldet_debtop - _debito,
		   sldet_cretop  = sldet_cretop - _credito,
		   sldet_saldop  = sldet_saldop - _neto
	 where sldet_tipo	 = _tipo
	   and sldet_cuenta	 = _cuenta
	   and sldet_ccosto	 = _cia_con
	   and sldet_ano	 = _ano
	   and sldet_periodo = _periodo;

end foreach

-- (SAC002) - Ancon Investment Corporation 

foreach
 select res_tipo_resumen,
		res_cuenta,
		res_ccosto,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into	_tipo,   
		_cuenta, 
		_ccosto, 
		_ano,    
		_periodo,
		_debito,	
		_credito,
		_neto	
   from	sac002:cglresumen
  where res_tipcomp = "014"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	update ef_saldodet
	   set sldet_debtop  = sldet_debtop - _debito,
		   sldet_cretop  = sldet_cretop - _credito,
		   sldet_saldop  = sldet_saldop - _neto
	 where sldet_tipo	 = _tipo
	   and sldet_cuenta	 = _cuenta
	   and sldet_ccosto	 = _cia_con
	   and sldet_ano	 = _ano
	   and sldet_periodo = _periodo;

end foreach

-- (SAC003) - United

foreach
 select res_tipo_resumen,
		res_cuenta,
		res_ccosto,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into	_tipo,   
		_cuenta, 
		_ccosto, 
		_ano,    
		_periodo,
		_debito,	
		_credito,
		_neto	
   from	sac003:cglresumen
  where res_tipcomp = "014"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	update ef_saldodet
	   set sldet_debtop  = sldet_debtop - _debito,
		   sldet_cretop  = sldet_cretop - _credito,
		   sldet_saldop  = sldet_saldop - _neto
	 where sldet_tipo	 = _tipo
	   and sldet_cuenta	 = _cuenta
	   and sldet_ccosto	 = _cia_con
	   and sldet_ano	 = _ano
	   and sldet_periodo = _periodo;

end foreach

-- (SAC004) - Derval

foreach
 select res_tipo_resumen,
		res_cuenta,
		res_ccosto,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into	_tipo,   
		_cuenta, 
		_ccosto, 
		_ano,    
		_periodo,
		_debito,	
		_credito,
		_neto	
   from	sac004:cglresumen
  where res_tipcomp = "014"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	update ef_saldodet
	   set sldet_debtop  = sldet_debtop - _debito,
		   sldet_cretop  = sldet_cretop - _credito,
		   sldet_saldop  = sldet_saldop - _neto
	 where sldet_tipo	 = _tipo
	   and sldet_cuenta	 = _cuenta
	   and sldet_ccosto	 = _cia_con
	   and sldet_ano	 = _ano
	   and sldet_periodo = _periodo;

end foreach
}

end

return 0, "Actualizacion Exitosa";

end procedure