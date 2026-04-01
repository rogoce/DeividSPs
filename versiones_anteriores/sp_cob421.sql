-- Procedimiento carga ducruet (sucursal 091)
-- Creado : 07/06/2017 - Autor: Henry Giron  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob421;
create procedure "informix".sp_cob421(a_numero 	char(10))
returning	integer,char(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_recibo_det		integer;
define _no_remesa			char(10);
define _cero                char(1);
define _monto_cobrado_det	dec(16,2);
define _monto_comis_det		dec(16,2);
define _monto_bruto_det		dec(16,2);
define _comis_cobro_det	    dec(16,2);
define _comis_visa_det		dec(16,2);
define _comis_clave_det		dec(16,2);
define _error_isam			integer;
define _secuencia           integer;
define _error				integer;
define _no_remesa_int       integer;

define _valor_parametro		char(15);
define _valor_int			integer;
define _valor_char			char(10);
define _monto_cobrado		dec(16,2);
define _monto_comis			dec(16,2);
define _monto_bruto			dec(16,2);
define _comis_cobro	    	dec(16,2);
define _comis_visa			dec(16,2);
define _comis_clave			dec(16,2);
define _cnt_cadena      	integer;	   		   
define _sucursal            char(2);
define _cod_agente_2        char(5);

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception
set debug file to "sp_cob421.trc";
trace on;
--return 0,'Desactivado';

select valor_parametro
  into _valor_parametro
  from parcont
 where cod_compania  = '001'
   and aplicacion    = 'COB'
   and version       = '02'
   and cod_parametro = 'par_numero';

let _valor_int  = _valor_parametro;
let _valor_int  = _valor_int + 1;
let _valor_char = '00000';
let _sucursal = '';
let _cod_agente_2 = '02656';

IF _valor_int > 9999  THEN
	LET _valor_char       = _valor_int;
ELIF _valor_int > 999 THEN
	LET _valor_char[2,5] = _valor_int;
ELIF _valor_int > 99  THEN
	LET _valor_char[3,5] = _valor_int;
ELIF _valor_int > 9   THEN
	LET _valor_char[4,5] = _valor_int;
ELSE
	LET _valor_char[5,5] = _valor_int;
END IF

-- creaion de remesa de pago externo 00035 y 02656
select *	     
  from cobpaex0
 where numero = a_numero
  into temp tmp_cobpaex0; 
  
 select *	     
  from cobpaex1
 where numero = a_numero
  into temp tmp_cobpaex1;     
  
  update tmp_cobpaex1
  set error = 1;

select sum(monto_bruto),
		sum(monto_cobrado),
		sum(monto_comis),
		sum(comis_cobro),
		sum(comis_visa),
		sum(comis_clave)
	into _monto_bruto_det,
	   _monto_cobrado_det,
	   _monto_comis_det,	
	   _comis_cobro_det,
	   _comis_visa_det,
	   _comis_clave_det		
	from tmp_cobpaex1;

let _cnt_cadena = 0;	
let _cod_agente_2 = '02656';
 
foreach
	select no_documento,length(trim(no_documento))
	  into _no_documento,_cnt_cadena
	  from cobpaex1
	 where numero = a_numero      	 
	 
		IF _cnt_cadena = 13 THEN 
			LET _sucursal = _no_documento[12,13];
		ELSE
			CALL sp_sis115(_no_documento,'-') returning _error_desc;
			
			select trim(dato)
			  into _sucursal
		  	  from tmp_datos
			  where inicio = 3;	
			  
			  drop table if exists tmp_datos;
				if _sucursal is null or _sucursal = '' then
					continue foreach;
				end if 			  			  
		END IF
	 
	 if _sucursal = '01' then
		update tmp_cobpaex1
		   set error = 0
		 where numero = a_numero 
		 and no_documento = _no_documento;
	end if					
end foreach

select sum(monto_bruto),
		sum(monto_cobrado),
		sum(monto_comis),
		sum(comis_cobro),
		sum(comis_visa),
		sum(comis_clave)
	into _monto_bruto,
	   _monto_cobrado,
	   _monto_comis,	
	   _comis_cobro,
	   _comis_visa,
	   _comis_clave		
	from tmp_cobpaex1
   where error = 0;
   
  Insert Into cobpaex0 (numero,
	            fecha_adicion,
				usuario,
				cod_agente,
				no_remesa,
				fecha_remesa,
				monto_total,
				monto_comis,
				monto_comis_cobro,
				monto_comis_visa,
				monto_comis_clave,
				monto_bruto,
				no_cheque,
				periodo_desde,
				periodo_hasta,
				no_recibo_ancon,
				fecha_recibo,
				tipo_formato)
select _valor_char,
	            fecha_adicion,
				usuario,
				_cod_agente_2,
				no_remesa,
				fecha_remesa,
				_monto_cobrado,
				_monto_comis,
				_comis_cobro,
				_comis_visa,
				_comis_clave,
				_monto_bruto,
				no_cheque,
				periodo_desde,
				periodo_hasta,
				no_recibo_ancon,
				fecha_recibo,
				tipo_formato
from tmp_cobpaex0;		
				
   
update cobpaex0
   set monto_bruto = monto_bruto - _monto_bruto,
		monto_total = monto_total - _monto_cobrado,
		monto_comis = monto_comis - _monto_comis,
		monto_comis_cobro = monto_comis_cobro - _comis_cobro,
		monto_comis_visa = monto_comis_visa - _comis_visa,
		monto_comis_clave = monto_comis_clave - _comis_clave
 where numero = a_numero;

update cobpaex0
   set monto_bruto = _monto_bruto,
		monto_total = _monto_cobrado,
		monto_comis = _monto_comis,
		monto_comis_cobro = _comis_cobro,
		monto_comis_visa = _comis_visa,
		monto_comis_clave = _comis_clave
 where numero = _valor_char;   
 
 Insert Into cobpaex1 (numero,
			renglon,
			no_remesa,
			secuencia,
			no_documento,
			cliente,
			monto_cobrado,
			fecha_pago,
			neto_pagado,
			no_recibo,
			porc_comis,
			monto_comis,
			comis_desc,
			comis_cobro,
			comis_visa,
			comis_clave,
			monto_bruto,
			error,
			prima_suspenso)
select _valor_char,
			renglon,
			no_remesa,
			secuencia,
			no_documento,
			cliente,
			monto_cobrado,
			fecha_pago,
			neto_pagado,
			no_recibo,
			porc_comis,
			monto_comis,
			comis_desc,
			comis_cobro,
			comis_visa,
			comis_clave,
			monto_bruto,
			error,
			prima_suspenso
from tmp_cobpaex1				
where error = 0;


delete from cobpaex1 where numero = a_numero and no_documento in (select no_documento from tmp_cobpaex1 where error = 0) ;

call sp_cob303(_valor_char) returning _error,_error_desc;
if _error <> 0 then
	return _error, _error_desc;
end if

return 0,_error_desc;
end
end procedure;
