----------------------------------------------------------
--Proceso que genera la prima suscrita en un rango de periodos especifico y la prima cobrada de las mismas pólizas de la prima suscrita
--Creado    : 21/08/2015 - Autor: Román Gordón
-- execute procedure sp_pro34e('001','001','2015-11','2015-11','*','*',2,'sac')
----------------------------------------------------------

drop procedure sp_sis434a;
create procedure sp_sis434a()
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _factor_impuesto		dec(20,8);
define _prima_bruta_act		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_reas			dec(16,2);
define _saldo_act			dec(16,2);
define _saldo				dec(16,2);
define _factor				dec(9,6);
define _proc_partic_coas	dec(7,4);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _tipo_produccion		smallint;
define _no_endoso_int		smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	rollback work;
	let _error_desc = _error_desc || 'Póliza: ' || trim(_no_documento);
	return _error,_error_desc;
end exception

--set debug file to "sp_sis434.trc";
--trace on;

drop table if exists tmp_endasien;
drop table if exists tmp_endasiau;

select *
  from endasien
 where 1=2
  into temp tmp_endasien;

select *
  from endasiau
 where 1=2
  into temp tmp_endasiau;

foreach with hold
	select distinct no_documento,
		   prima_bruta,
		   no_poliza,
		   no_endoso,
		   saldo
	  into _no_documento,
		   _prima_bruta,
		   _no_poliza,
		   _no_endoso,
		   _saldo
	  from tmp_venc
	 where prima_calc is not null
	   and abs(saldo + prima_calc) < 1
	   and bo_asiento = 0
	   and no_endoso <> '00000'
	   --and no_documento[1,2] = '02'
	 order by no_documento

	begin work;

	let _saldo = _saldo * -1;
	call sp_par59a(_no_poliza,_saldo) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		
		let _error_desc = trim(_error_desc) || ' no_poliza: ' || trim(_no_poliza);
		return _error, _error_desc;
	end if

	call sp_par296_dep(_no_poliza,_no_endoso) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		
		let _error_desc = trim(_error_desc) || ' no_poliza: ' || trim(_no_poliza);
		return _error, _error_desc;
	end if
	
	update tmp_venc
	   set bo_asiento = 1
	 where no_poliza = _no_poliza;

	commit work;
end foreach;

return 0,'Generación de registros existosa.';
end
end procedure;