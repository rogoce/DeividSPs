-- Procedimiento carga ducruet (sucursal 091)
-- Creado : 07/06/2019 - Autor: Henry Giron  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob421b;
create procedure "informix".sp_cob421b(a_numero char(10),a_cod_agente char(5), a_cia char(2))
returning	integer,char(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _monto_cobrado_det	dec(16,2);
define _monto_comis_det		dec(16,2);
define _monto_bruto_det		dec(16,2);
define _comis_cobro_det	    dec(16,2);
define _comis_visa_det		dec(16,2);
define _comis_clave_det		dec(16,2);
define _error_isam			integer;
define _error				integer;
define _monto_cobrado		dec(16,2);
define _monto_comis			dec(16,2);
define _monto_bruto			dec(16,2);
define _comis_cobro	    	dec(16,2);
define _comis_visa			dec(16,2);
define _comis_clave			dec(16,2);
define _cnt_cadena      	integer;	   		   
define _sucursal            char(2);
define _agente			    integer;
define _renglon             smallint;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception
--set debug file to "sp_cob421.trc";
--trace on;
--return 0,'Desactivado';
drop table if exists tmp_cobpaex0;
drop table if exists tmp_cobpaex1;
let _sucursal = '';
let _agente = 0;

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
	 
	 if _sucursal = a_cia then
		update tmp_cobpaex1
		   set error = 0
		 where numero = a_numero 
		 and no_documento = _no_documento;
	end if					
end foreach

if a_cod_agente = '00035' then
	let _agente = 0;
else
	let _agente = 1;
end if

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
   where error = _agente;   					
   
update cobpaex0
   set monto_bruto = monto_bruto - _monto_bruto,
		monto_total = monto_total - _monto_cobrado,
		monto_comis = monto_comis - _monto_comis,
		monto_comis_cobro = monto_comis_cobro - _comis_cobro,
		monto_comis_visa = monto_comis_visa - _comis_visa,
		monto_comis_clave = monto_comis_clave - _comis_clave,
		cod_agente = a_cod_agente
 where numero = a_numero; 
 
foreach
     select renglon 
	   into _renglon
	   from tmp_cobpaex1 
	  where error = _agente

 delete from cobpaex1 where numero = a_numero and renglon = _renglon;
 end foreach


return 0,_error_desc;
end
end procedure;
