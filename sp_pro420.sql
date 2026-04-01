
-- Procedimiento para insertar el endoso de reverso del descuento apoyo COVID-19
-- Amado Perez M - 29/04/2020
--execute procedure sp_pro418a('2020-04')

drop procedure sp_pro420;
create procedure sp_pro420(a_periodo char(7)) 
returning	smallint as Error_No,
			char(20) as Poliza,
			char(100) as Descripcion;

		   
define _nom_contratante		varchar(50);
define _nom_formapag		varchar(50);
define _nom_sucursal		varchar(50);
define _desc_aplica			varchar(100);
define _nom_perpago			varchar(50);
define _nom_agente			varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _error_desc			char(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso       	char(5);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo            char(3);
define _null            	char(1);
define _suma_asegurada		dec(16,2);
define _letra_sin_imp		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _descuento			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _impuesto			dec(16,2);
define _saldo				dec(16,2);
define _letra				dec(16,2);
define _no_pagos			smallint;
define _aplica				smallint;
define _rango				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _fecha_sus           date;
define _fecha_gestion   	datetime year to second;
define _existe_end, _existe_rev, _cnt smallint;
define _cnt_s               varchar(2);

--set debug file to "sp_sis420.trc";
--trace on;

set isolation to dirty read;

begin

on exception set _error,_error_isam,_error_desc
	if _no_documento is null then
		let _no_documento = '';
	end if

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

 	return	_error,
			_no_documento,
			_error_desc;
end exception

FOREACH WITH HOLD
 SELECT no_documento
   INTO _no_documento
   FROM cobgesti
  WHERE cod_gestion = '073'
    AND tipo_aviso = 20
	AND date(fecha_gestion) = today
  
	let _existe_end = 0;
  
  	select count(*)
	  into _existe_end
	  from endedmae
	 where no_documento   = _no_documento
	   and cod_endomov = "033"
	   and actualizado = 1;	     --endoso de descuento covid 19

	let _existe_rev = 0;
	select count(*)
	  into _existe_rev
	  from endedmae
	 where no_documento   = _no_documento
	   and cod_endomov = '034'		 --endoso de reversion de descuento covid19
	   and actualizado = 1;

	let _fecha_gestion  = current year to second;

	IF _existe_end > 0 AND _existe_rev = 0 THEN 
		FOREACH with hold
			select no_poliza,
				   no_documento,
				   prima_bruta		   
			  into _no_poliza,
				   _no_documento,
				   _descuento
			  from endedmae
			 where no_documento = _no_documento
			   and cod_endomov = '033'
			   and actualizado = 1
			   --and no_documento = '0217-00252-05'

			begin
				on exception in(-535)

				end exception 	
				begin work;
			end

			call sp_pro417b(a_periodo,_no_poliza,_descuento,'034', _fecha_gestion) returning _error,_no_endoso,_error_desc;
			
			if _error <> 0 then
				rollback work;
				return	_error,
						_no_documento,
						_error_desc with resume;
				continue foreach;
			end if
						
			commit work;
			
			let _fecha_gestion  = _fecha_gestion + 1 units second;
			
			return 0,_no_documento,'Endoso: ' || _no_endoso || '. Actualizacion Exitosa' with resume;
		END FOREACH
	END IF	
    IF _existe_end > 0 AND _existe_rev > 0 THEN 
		IF (_existe_end - _existe_rev) = 0 THEN
			return 1,_no_documento,'Ya la poliza tiene los descuentos covid-19 reversados' with resume;
		END IF
		IF (_existe_end - _existe_rev) > 0 THEN
		    let _cnt = _existe_end - _existe_rev;
			let _cnt_s = _cnt;
			return 1,_no_documento,'Ya la poliza tiene ' || trim(_cnt_s) || ' descuentos covid-19 reversados' with resume;
		END IF
    END IF	
	IF _existe_end = 0 THEN
			return 1,_no_documento,'la poliza no tiene endosos de descuentos covid-19' with resume;
	END IF
END FOREACH
return 0,'', "Actualizacion Exitosa...";
end
end procedure 