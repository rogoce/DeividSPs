-- Procedimiento que busca la firma de una requisicion

-- Creado    : 16/10/2018 - Autor: Amado Perez  

drop procedure sp_rwf155;

create procedure sp_rwf155(a_no_requis char(10), a_firma smallint default 1, a_firma_1 char(20) default "") 
returning varchar(20) as usuario;

define _firmante 	char(8);
define _ld_lim_max 	dec(16,2);
define _ld_lim_med 	dec(16,2);
define _ld_min_aut_salud 	dec(16,2);
define _ld_max_aut_salud 	dec(16,2);
define _cod_banco   	char(3);
define _cod_chequera   	char(3);
define _monto      	dec(16,2);
define _tipo_firma  char(1);
define _windows_user varchar(20);
define _firma_1 	char(8);

if a_no_requis = '926042' then
 SET DEBUG FILE TO "sp_rwf155.trc"; 
 trace on;
end if
let _tipo_firma = null;

set isolation to dirty read;
--begin work;
-- Limites especiales de automovil

select valor_parametro    --Limite hasta donde puede ir una firma A y una B
  into _ld_lim_max
  from inspaag
 where codigo_compania  = '001'
	and codigo_agencia   = '001'
	and aplicacion       = 'CHE'
	and version          = '02'
	and codigo_parametro = "lim_max_firma";
	
select valor_parametro
  into _ld_lim_med        --Limite hasta donde puede ir cualquier combinación
  from inspaag
 where codigo_compania  = '001'
	and codigo_agencia   = '001'
	and aplicacion       = 'CHE'
	and version          = '02'
	and codigo_parametro = "lim_med_firma";

--Limites especiales de Salud
			
select valor_parametro
  into _ld_min_aut_salud  --Limite hasta donde puede ir cualquier combinación
  from inspaag
 where codigo_compania  = '001'        
	and codigo_agencia   = '001'
	and aplicacion       = 'CHE'
	and version          = '02'
	and codigo_parametro = "min_aut_salud";

select valor_parametro
  into _ld_max_aut_salud  --Limite hasta donde puede ir una firma A y una B
  from inspaag
 where codigo_compania  = '001'        
	and codigo_agencia   = '001'
	and aplicacion       = 'CHE'
	and version          = '02'
	and codigo_parametro = "max_aut_salud";

select cod_banco,
       cod_chequera,
	   monto
  into _cod_banco,
       _cod_chequera,
	   _monto
  from chqchmae
 where no_requis = a_no_requis;

if a_firma = 1 then 
	if _cod_banco = '001' and _cod_chequera = '001' then
		if _monto > _ld_lim_med then
		--	let _firmante = sp_rec76i('A', 0.00, 0.00);
			let _firmante = sp_yos04('A', 0.00, 0.00);
		else
		--	let _firmante = sp_rec76i('*', _monto, 0.00);
			let _firmante = sp_yos04('*', _monto, 0.00);
		end if
	else
		if _monto > _ld_lim_med then
		--	let _firmante = sp_rec76i('A', 0.00, 0.00);
			let _firmante = sp_yos04('A', 0.00, 0.00);
		elif _monto > _ld_min_aut_salud then
		--	let _firmante = sp_rec76i('*', _monto, 0.00);
			let _firmante = sp_yos04('*', _monto, 0.00);
		else 
		--	let _firmante = sp_rec76i('B', 0.00, _ld_min_aut_salud);	    
			let _firmante = sp_yos04('B', 0.00, _ld_min_aut_salud);	    
		end if
	end if
else

    select tipo_firma
	  into _tipo_firma
	  from wf_firmas
	 where windows_user = a_firma_1;
	 
	if _cod_banco = '001' and _cod_chequera = '001' then
		if _monto > _ld_lim_max then
		--	let _firmante = sp_rec76i('A', 0.00, 0.00, a_firma_1);
			let _firmante = sp_yos04('A', 0.00, 0.00, a_firma_1);
		elif _monto > _ld_lim_med then
			if _tipo_firma = 'B' then
			--	let _firmante = sp_rec76i('A', _monto, 0.00, a_firma_1);
				let _firmante = sp_yos04('A', _monto, 0.00, a_firma_1);
			else
			--	let _firmante = sp_rec76i('*', _monto, 0.00, a_firma_1);
				let _firmante = sp_yos04('*', _monto, 0.00, a_firma_1);
			end if
		else
		--	let _firmante = sp_rec76i('*', _monto, 0.00, a_firma_1);
			let _firmante = sp_yos04('*', _monto, 0.00, a_firma_1);
		end if
	else
		if _monto > _ld_lim_max then
		--	let _firmante = sp_rec76i('A', 0.00, 0.00, a_firma_1);
			let _firmante = sp_yos04('A', 0.00, 0.00, a_firma_1);
		elif _monto > _ld_lim_med then
			if _tipo_firma = 'B' then
			--	let _firmante = sp_rec76i('A', 0.00, 0.00, a_firma_1);
				let _firmante = sp_yos04('A', 0.00, 0.00, a_firma_1);
			else
			--	let _firmante = sp_rec76i('*', 0.00, 0.00, a_firma_1);
				let _firmante = sp_yos04('*', 0.00, 0.00, a_firma_1);
			end if
		elif _monto > _ld_min_aut_salud then
		--	let _firmante = sp_rec76i('*', _monto, 0.00, a_firma_1);
			let _firmante = sp_yos04('*', _monto, 0.00, a_firma_1);
		else 
		--	let _firmante = sp_rec76i('B', 0.00, _ld_min_aut_salud, a_firma_1);	    
			let _firmante = sp_yos04('B', 0.00, _ld_min_aut_salud, a_firma_1);	    
		end if
	end if
end if	

select windows_user
  into _windows_user
  from insuser
 where usuario = _firmante;

--commit work; 
return trim(_windows_user);
--return "JBRITO";


end procedure