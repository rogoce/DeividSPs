-- Verificar por que los Saldos a Diferentes meses son diferentes

-- Creado    : 19/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/06/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas038;
create procedure sp_cas038(a_compania char(3),a_agencia char(3))
returning	char(20),
            dec(16,2),
		    dec(16,2);

define _nombre_compania	char(50);
define _nombre_cobrador	char(50);
define _doc_poliza		char(20);		  
define _cod_cliente		char(10);
define a_periodo2		char(7);
define a_periodo		char(7);
define _cod_cobrador	char(3);
define _monto_pagado    dec(16,2);
define _por_vencer      dec(16,2);
define _corriente       dec(16,2);
define _exigible        dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define _saldo           dec(16,2);
define _monto           dec(16,2);
define _cant_pagar		smallint;
define _cant_pagos		smallint;
define a_fecha2			date;
define a_fecha			date;

set isolation to dirty read;

create temp table tmp_metcall(
no_documento	char(20),
saldo_junio		dec(16,2),
saldo_julio		dec(16,2)) with no log;

let _nombre_compania = sp_sis01(a_compania);

let a_periodo  = '2003-06';
let a_periodo2 = '2003-07';
let a_fecha    = sp_sis36(a_periodo);
let a_fecha2   = sp_sis36(a_periodo2);

foreach
	select no_documento,
		   cod_cliente
	  into _doc_poliza,
		   _cod_cliente
	  from caspoliza

	call sp_cas035(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo,
		 a_fecha
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;   

	{call sp_cob398(_doc_poliza,a_periodo,a_fecha,1,0)
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;}

	let _monto_90 = _monto_90 + _monto_120 + _monto_150 + _monto_180;

	insert into tmp_metcall
	values(_doc_poliza,_saldo,0.00);

	call sp_cas035(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo2,
		 a_fecha2
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    

	insert into tmp_metcall
	values (_doc_poliza,0.00,_saldo);
end foreach

foreach 
 select no_documento,
        sum(saldo_junio),
		sum(saldo_julio)
   into _doc_poliza,
        _exigible,
		_saldo
   from tmp_metcall
  group by 1
  order by 1

	if _saldo <> _exigible then

		return _doc_poliza,
		       _exigible,
			   _saldo
			   with resume;

	end if

end foreach

drop table tmp_metcall;

end procedure