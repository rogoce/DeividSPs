-- Procedimiento que datos de Ducruet Cobros Electronicos
-- Creado    : 06/05/2013 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_cob402()

drop procedure sp_cob402;
create procedure sp_cob402()
returning	char(20)		as poliza,
			varchar(50)		as forma_pago,
			smallint		as estatus_poliza,
			varchar(100)	as cliente,
			varchar(100)	as ramo,
			date			as vig_data_inic,
			date			as vig_data_final,
			smallint		as cnt_desconto,
			smallint		as cnt_vigencias,
			dec(16,2)		as prima_descuentos,
			dec(16,2)		as monto_desc_sin_aplicar,
			dec(16,2)		as saldo;

define _desc_cliente		varchar(100);
define _error_desc			varchar(100);
define _desc_ramo			varchar(100);
define _nom_formapag		varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_formapag		char(3);
define _desc_sin_aplicar	dec(16,2);
define _acum_desc_pen		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_orig			dec(16,2);
define _acum_prima			dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _cnt_vigencias		smallint;
define _cnt_desconto		smallint;
define _tiene_024			smallint;
define _tiene_025			smallint;
define _error_isam			integer;
define _error				integer;
define _vig_data_final		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _vig_data_inic		date;

set isolation to dirty read;

--set debug file to "sp_cob402.trc";
--trace on;

begin 
on exception set _error,_error_isam,_error_desc	
	return '','',0,'',_error_desc,null,null,_error, _error_isam, 0.00,0.00,0.00;  
end exception 

foreach
	select d.no_documento,
		   d.nom_cliente,
		   desc_ramo,
		   min(d.vigencia_inic),
		   max(d.vigencia_inic) 
	  into _no_documento,
		   _desc_cliente,
		   _desc_ramo,
		   _vig_data_inic,
		   _vig_data_final
	  from deivid_tmp:duc_electronico d
	  left join emipomae e on d.no_documento = e.no_documento and d.vigencia_inic = e.vigencia_inic
	 where e.no_documento = d.no_documento
	   --and d.no_documento = '0215-93175-47' --0215-00238-09'
	 group by 1,2,3
	 order by d.no_documento
 
	let _cnt_vigencias = 0;
	let _acum_desc_pen = 0;
	let _acum_prima = 0;
	let _tiene_024 = 0;
	let _tiene_025 = 0;
   
	call sp_cob174(_no_documento) returning _saldo;
	call sp_sis21(_no_documento) returning _no_poliza;

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _saldo is null then
		let _saldo = 0.00;
	end if

	let _cnt_desconto = 0;
 
	foreach
		select e.no_poliza,
			   f.nombre
		  into _no_poliza,
			   _nom_formapag
		  from emipomae e, cobforpa f
		 where e.cod_formapag = f.cod_formapag
		   and no_documento = _no_documento
		   and vigencia_inic >= _vig_data_inic
		   and vigencia_inic <= _vig_data_final
		   and actualizado  = 1			 
		 
		let _cnt_vigencias = _cnt_vigencias + 1;

		select prima_bruta
		  into _prima_orig
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
  		
		select sum(prima_bruta)
		  into _prima_bruta
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov	in ('024','025')
		   and actualizado  = 1;

		select count(*)
		  into _tiene_024
		  from endedmae
		 where no_poliza	= _no_poliza
		   and cod_endomov	= '024'
		   and actualizado  = 1;

		select count(*)
		  into _tiene_025
		  from endedmae
		 where no_poliza	= _no_poliza					 
		   and cod_endomov	= '025'
		   and actualizado  = 1;			 
		   
		if _prima_bruta is null then
			let _prima_bruta = 0.00;
		end if

		if (_tiene_024 - _tiene_025) = 0 then
			let _acum_desc_pen = _acum_desc_pen + (_prima_orig * .05);
		end if

		let _cnt_desconto = _cnt_desconto + (_tiene_024 - _tiene_025);			 
		let _acum_prima = _acum_prima + _prima_bruta;
	end foreach

	return	_no_documento,
			_nom_formapag,
			_estatus_poliza,
			_desc_cliente,
			_desc_ramo, 
			_vig_data_inic, 
			_vig_data_final,
			_cnt_desconto, 
			_cnt_vigencias, 
			_acum_prima,
			_acum_desc_pen,
			_saldo
			with resume;	
end foreach
--trace off;
end 
end procedure;