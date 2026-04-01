----------------------------------------------------------
--Proceso que genera la prima suscrita en un rango de periodos especifico y la prima cobrada de las mismas pólizas de la prima suscrita
--Creado    : 21/08/2015 - Autor: Román Gordón
----------------------------------------------------------

drop procedure sp_sis434;
create procedure sp_sis434()
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _factor_impuesto		dec(20,8);
define _prima_bruta_act		dec(16,2);
define _prima_bruta_ant		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_reas			dec(16,2);
define _saldo_act			dec(16,2);
define _saldo_ant			dec(16,2);
define _saldo				dec(16,2);
define _factor				dec(9,6);
define _proc_partic_coas	dec(7,4);
define _no_documento		char(20);
define _no_poliza_ant		char(10);
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

foreach with hold
	select no_documento,
		   prima_bruta,
		   saldo,
		   no_poliza
	  into _no_documento,
		   _prima_bruta,
		   _saldo,
		   _no_poliza
	  from tmp_venc
	 where prima_calc is null
	   --and no_documento = '1611-00259-09'
	  -- and (saldo > prima_bruta and prima_bruta > 0)
	 --group by 1,2
	 order by no_documento

	begin work;

	--let _no_poliza = sp_sis21(_no_documento);
	let _no_endoso_int = sp_sis90(_no_poliza);
	
	select prima_bruta,
		   cod_tipoprod
	  into _prima_bruta_act,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _prima_bruta_act <> _prima_bruta then
		--let _prima_bruta = _prima_bruta_act;
	end if
	
	if _prima_bruta = 0 then
		update tmp_venc
		   set prima_calc = _prima_bruta,
			   no_poliza = _no_poliza,
			   no_endoso = '00000'
		 where no_documento = _no_documento;

		commit work;
		continue foreach;
	end if

	let _saldo_act = sp_cob174(_no_documento);

	if _saldo_act <> _saldo then
		--let _saldo = _saldo_act;
	end if

	if _saldo = 0 then
		update tmp_venc
		   set prima_calc = _prima_bruta,
			   no_poliza = _no_poliza,
			   saldo = _saldo,
			   no_endoso = '00000'
		 where no_documento = _no_documento;

		commit work;
		continue foreach;
	end if

	{if (_saldo > _prima_bruta) and _prima_bruta > 0 then
		let _no_poliza_ant = sp_sis21a(_no_documento,_no_poliza);
		
		select prima_bruta
		  into _prima_bruta_ant
		  from emipomae
		 where no_poliza = _no_poliza_ant;

		let _saldo_ant = _saldo - _prima_bruta;

		insert into tmp_venc(
				no_documento,
				saldo,
				prima_bruta,
				no_poliza,
				bo_asiento)
		values(	_no_documento,
				_saldo_ant,
				_prima_bruta_ant,
				_no_poliza_ant,
				0);
				
		let _saldo = _saldo - _saldo_ant;
	end if}
	let _saldo = _saldo * -1;

	let _no_endoso = '00000';
	let _no_endoso_int = _no_endoso_int + 1;

	if _no_endoso_int > 99 then
		let _no_endoso[3,5] = _no_endoso_int;
	elif _no_endoso_int > 9 then
		let _no_endoso[4,5] = _no_endoso_int;
	else
		let _no_endoso[5,5] = _no_endoso_int;
	end if

	call sp_sis433a(_no_poliza,_no_endoso,_saldo,_prima_bruta) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		return _error,_error_desc;
	end if

	select sum(prima)
	  into _prima_reas
	  from dep_emifacon
	 where no_poliza = _no_poliza;

	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	let _proc_partic_coas = 0.00;

	if _tipo_produccion = 2 then
		select porc_partic_coas
		  into _proc_partic_coas
		  from emicoama 
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036';

		let _prima_reas = _prima_reas / (_proc_partic_coas / 100);
	end if

	let _factor_impuesto = 0.00;

	select sum(y.factor_impuesto) 
	  into _factor_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = _no_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	if _factor_impuesto is null then
		let _factor_impuesto = 0.00;
	end if

	let _factor_impuesto = (_factor_impuesto/100) + 1;
	let _prima_reas = _prima_reas * (_factor_impuesto);

	update tmp_venc
	   set prima_calc = _prima_reas,
		   --prima_bruta = _prima_bruta,		   
		   no_endoso = _no_endoso
	 where no_documento = _no_documento
	   and no_poliza = _no_poliza; --is null;

	commit work;
end foreach;

return 0,'Generación de registros exitosa.';
end
end procedure;