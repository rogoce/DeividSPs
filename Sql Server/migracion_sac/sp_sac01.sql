-- Reporte de Saldos para Mayor General

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac01;

create procedure "informix".sp_sac01(
a_ano 	char(4), 
a_mes 	smallint,
a_nivel	smallint,
a_db    char(18)
) returning char(2),
            char(12),
		    char(50),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
            char(3),
            char(50),
            char(20);

define _tipo		char(2);
define _cuenta_may	char(3);
define _cuenta		char(12);
define _nombre		char(50);
define _referencia	char(20);

define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);
define _compania	char(50);

set isolation to dirty read;

let a_db = trim(a_db);

select cia_nom
  into _compania
  from sigman02
 where cia_bda_codigo = a_db;

create temp table tmp_saldos(
cuenta		char(12),
nombre		char(50),
debito		dec(16,2),
credito		dec(16,2),
saldo		dec(16,2),
saldo_ant	dec(16,2),
saldo_act	dec(16,2),
referencia	char(20)
) with no log;

execute procedure sp_sac42(a_ano, a_mes, a_nivel, a_db);

foreach
 select	cuenta,
		nombre,		
		debito,		
		credito,	
		saldo,		
		saldo_ant,
		saldo_act,
		referencia
   into	_cuenta,
		_nombre,		
		_debito,		
		_credito,	
		_saldo,		
		_saldo_ant,
		_saldo_act,
		_referencia
   from tmp_saldos
  order by 1

	let _tipo       = _cuenta[1,1];
	let _cuenta_may = _cuenta[1,3];

	return _tipo,
	       _cuenta,
		   _nombre,
		   _debito,
		   _credito,
		   _saldo,
		   _saldo_ant,
		   _saldo_act,
		   _cuenta_may,
		   _compania,
		   _referencia
		   with resume;

end foreach

drop table tmp_saldos;

end procedure