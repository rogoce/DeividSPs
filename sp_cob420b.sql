-- Cambio de Forma de  Pago de 006 ANC --> 008 de corredores_remesa  SD#4406 USUARIO:GISELA
-- Creado    : 31/08/20122 - Autor: Henry Girón 
-- SIS v.2.0 - DEIVID, S.A. 
-- execute procedure sp_cob420b('GISELA'); 

drop procedure sp_cob420b;
create procedure sp_cob420b(a_usuario char(8))
returning	char(5)			as cod_agente,
			char(3)			as zona_cobros,
			varchar(30)		as nom_agente,			
			char(20)		as poliza,						
			dec(16,2)		as saldo,
			char(5)			as formapag_ant,
			char(5)			as cambio_fp,
			char(10)        as no_poliza;			

define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_compania        char(3);
define _cod_cobrador        char(3);
define _cambio_fp    		char(3);
define _cod_sucursal        char(3);
define _saldo               dec(16,2);
define _error				integer;
define _error_isam		    integer;
define _desc_agente			varchar(30);
define _error_desc			varchar(30);

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	rollback work;
	return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'',_no_poliza;
end exception

--set debug file to "sp_cob420b.trc";
--trace on;

begin
	on exception in(-535)
	end exception

	begin work;
end

let _cod_compania = '001';
let _cod_sucursal = '001';
let _no_documento = '';
let _no_poliza = '';
let _cod_agente = '';
let _cod_cobrador = '';
let _desc_agente = '';
let _saldo = 0.00;
let _cambio_fp    = '008'; -- COR
let _cod_formapag = '006'; -- ANC

foreach with hold
	select e.no_documento,e.no_poliza,a.cod_agente		   
	  into _no_documento,_no_poliza,_cod_agente		   
      from emipomae e, emipoagt a
	 where e.no_poliza = a.no_poliza	   
	   and e.cod_formapag = _cod_formapag
	   and e.estatus_poliza = 1	   
	   and e.actualizado = 1
	   and a.cod_agente in ('01589','02901') -- PLATINUM INSURANCE CORPORATION 
	 group by 1,2,3


	begin
		on exception in(-535)
		end exception

		begin work;
	end
	--let _no_poliza = sp_sis21(_no_documento);     
	
	call sp_pro531(
		_no_poliza,
		a_usuario,
		_saldo, 
		_cod_compania, 
		_cod_sucursal,
		_cambio_fp)
	returning	_error,
				_error_desc;

	if _error <> 0 then
		rollback work;
		return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'',_no_poliza;
	end if
	
	
	select upper(trim(nombre)),
	       cod_cobrador
	  into _desc_agente,
	       _cod_cobrador
	  from agtagent 
	 where cod_agente = _cod_agente;	

	return	_cod_agente,
			_cod_cobrador,
			_desc_agente,
			_no_documento,
			_saldo,
			_cod_formapag,
			_cambio_fp,
			_no_poliza
			with resume;			
	commit work;
end foreach
end
end procedure;