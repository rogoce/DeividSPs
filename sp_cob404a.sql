-- Cambio de Forma de  Pago de 006 --> 008 de corredores_remesa y viceversa 
-- Creado    : 05/09/2017 - Autor: Henry Girón 
-- SIS v.2.0 - DEIVID, S.A. 
-- execute procedure sp_cob404a('DEIVID'); 

drop procedure sp_cob404a;
create procedure sp_cob404a(a_usuario char(8))
returning	char(5)			as cod_agente,
			char(3)			as zona_cobros,
			varchar(30)		as nom_agente,			
			char(20)		as poliza,						
			dec(16,2)		as saldo,
			char(5)			as formapag_ant,
			char(5)			as cambio_fp;						

define _desc_agente			varchar(30);
define _error_desc			varchar(30);
define _no_documento		char(20);
define _no_poliza2		    char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_compania        char(3);
define _cod_cobrador        char(3);
define _cambio_fp    		char(3);
define _cod_sucursal        char(3);
define _fecha_hoy			date;
define _error_isam		    integer;
define _error				integer;
define _actualizado			smallint;
define _nuevo               smallint;
define _cnt                 smallint;
define _saldo               dec(16,2);
define _por_vencer          dec(16,2);
define _exigible            dec(16,2);  
define _corriente           dec(16,2);
define _monto_30            dec(16,2);
define _monto_60            dec(16,2);  
define _monto_90            dec(16,2);
define _monto_120           dec(16,2);
define _monto_150           dec(16,2);
define _monto_180           dec(16,2);

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	rollback work;
	return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'';
end exception

--set debug file to "sp_cob404.trc";
--trace on;

begin
	on exception in(-535)
	end exception

	begin work;
end

let _fecha_hoy = today;
let _cod_compania = '001';
let _cod_sucursal = '001';
let _no_documento = '';
let _no_poliza = '';
let _cod_agente = '';
let _cod_cobrador = '';
let _desc_agente = '';
let _saldo = 0.00;

foreach with hold
	select e.no_poliza,
		   e.no_documento,
		   e.actualizado,
		   e.cod_formapag,
		   '008'
	  into _no_poliza,
		   _no_documento,
		   _actualizado,
		   _cod_formapag,
		   _cambio_fp
      from emipomae e, emipoagt p, agtagent a
	 where e.no_poliza = p.no_poliza
	   and p.cod_agente = a.cod_agente
	   and a.cod_cobrador <> '217'
	   and e.cod_formapag = '006'
	   and e.vigencia_final >= '01/01/2018'
	 group by 1,2,3,4
	 having sum(p.porc_partic_agt) >= 50

	begin
		on exception in(-535)
		end exception

		begin work;
	end

	if _actualizado = 1 then
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
			return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'';
		end if
	else
		update emipomae
		   set cod_formapag = _cambio_fp
		 where no_poliza = _no_poliza;
	end if

	return	_cod_agente,
			_cod_cobrador,
			_desc_agente,
			_no_documento,
			_saldo,
			_cod_formapag,
			_cambio_fp
			with resume;			
	commit work;
end foreach
end
end procedure;