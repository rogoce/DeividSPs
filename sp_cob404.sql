-- Cambio de Forma de  Pago de 006 --> 008 de corredores_remesa y viceversa 
-- Creado    : 05/09/2017 - Autor: Henry Girón 
-- SIS v.2.0 - DEIVID, S.A. 
-- execute procedure sp_cob404('DEIVID'); 

drop procedure sp_cob404;
create procedure sp_cob404(a_usuario char(8))
returning	char(5)			as cod_agente,
			char(3)			as zona_cobros,
			varchar(30)		as nom_agente,			
			char(20)		as poliza,						
			dec(16,2)		as saldo,
			char(5)			as formapag_ant,
			char(5)			as cambio_fp,
			smallint        as tipo_rpt,
			char(10)        as no_poliza;						

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
define _nuevo               smallint;
define _realizar            smallint;
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
	return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'',0,_no_poliza;
end exception

--set debug file to "sp_cob404.trc";
--trace on;

begin
	on exception in(-535)
	end exception

	begin work;
end
	
drop table if exists corredores_tmp;

let _fecha_hoy = today;
let _periodo = sp_sis39(_fecha_hoy);
let _no_documento = '';
let _no_poliza = '';
let _cod_agente = '';
let _saldo = 0.00;

-- 1 remesa
select cod_agente,nuevo,cod_cobrador
  from deivid_tmp:corredores_remesa 
 where nuevo = 1
   and actualizado = 0
  into temp corredores_tmp; 

-- 2 consumo
insert into corredores_tmp (cod_agente,nuevo,cod_cobrador)
select cod_agente,2,'217'
  from deivid_tmp:corredores_consumo
 where actualizado = 0;

foreach with hold
	select cod_agente,
		   nuevo,
		   cod_cobrador
	  into _cod_agente,
		   _nuevo,
		   _cod_cobrador
	  from corredores_tmp 
	 group by 1,2,3

	begin
		on exception in(-535)
		end exception

		begin work;
	end

	select trim(nombre)
	  into _desc_agente
	  from agtagent 
	 where cod_agente = _cod_agente;

	foreach 
		select e.no_documento 
		  into _no_documento 
		  from emipomae e, emipoagt a 
		 where e.no_poliza = a.no_poliza 
		   and a.cod_agente = _cod_agente 
		   and e.actualizado = 1 
		   and e.cod_formapag in ('006','008')
		 group by 1 		 

		let _realizar = 0; 
		let _cnt = 0;
		let _no_poliza = sp_sis21(_no_documento); 

		select count(*)
		  into _cnt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente = _cod_agente ;

		if _cnt is null then
			let _cnt = 0;
		end if

		if _cnt = 0 then
			continue foreach;
		end if

		select cod_formapag,			   
			   cod_compania,
			   cod_sucursal
		  into _cod_formapag,			   
			   _cod_compania,
			   _cod_sucursal			   
		  from emipomae 
		 where no_poliza = _no_poliza 
		   and actualizado = 1; 

		if _cod_formapag not in ('006','008') then
			continue foreach; 
		end if					
		
		if _cod_formapag = '006' and _nuevo = 1 then
			let _cambio_fp = '008';
			let _realizar = 1;
		end if			
		if _cod_formapag = '008' and _nuevo = 2 then 
			let _cambio_fp = '006'; 
			let _realizar = 1; 
		end if			 

		{call sp_cob174(_no_documento) returning _saldo; 

		if _saldo is null then
			let _saldo = 0.00;
		end if}

		if _realizar = 1 then
			
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
				return _cod_agente,'',_error_desc,_no_documento,0.00,_error,'',0,_no_poliza;
			end if

			return	_cod_agente,
					_cod_cobrador,
					_desc_agente,
					_no_documento,
					_saldo,
					_cod_formapag,
					_cambio_fp,
					_nuevo,
                    _no_poliza
					with resume;			
		end if
	end foreach

	update agtagent
	   set cod_cobrador = _cod_cobrador
	 where cod_agente = _cod_agente;

	update deivid_tmp:corredores_remesa
	   set actualizado = 1
	 where cod_agente = _cod_agente;

	update deivid_tmp:corredores_consumo
	   set actualizado = 1
	 where cod_agente = _cod_agente;

	commit work;
end foreach
end
end procedure;