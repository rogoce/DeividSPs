-- Validar coberturas de adelanto
-- 
DROP PROCEDURE sp_sis109_end;
create procedure sp_sis109_end(a_no_poliza char(10),a_no_endoso char(5) default "00000")
returning	integer,
			varchar(200);

define _error_desc		varchar(200);
define _desc_cont		char(50);
define _desc_cob		char(50);
define _cuenta_cat		char(25);   
define _no_documento	char(21);   
define _no_factura		char(10);
define _cod_contrato	char(5);
define _cod_traspaso	char(5);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _cod_coasegur	char(3);
define _cod_ramo		char(3);
define _null			char(1);
define _cod_tipoprod    char(3);
define _factor_impuesto	dec(5,2);
define _porc_comis_agt	dec(5,2);
define _pbs_historico,_limite_1	dec(16,2);
define _pbs_endoso,_suma_unidad,_prima_anual		dec(16,2);
define _suma,_suma_uni_rea dec(16,2);
define _tiene_comision	smallint;
define _tipo_contrato	smallint;
define _traspaso		smallint;
define _imp_gob			smallint;
define _serie			smallint;
define _error_isam		integer;
define _error_cod		integer;
define _cantidad,_cnt		integer;
define _contador		integer;
define _porc_coas_ancon dec(7,4);

set isolation to dirty read;

let _no_endoso = '00000';
let _contador = 0.00;
let _porc_coas_ancon = 0.00;
let _prima_anual = 0.00;
let _null     = null;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

--set debug file to "sp_sis109_end.trc";
--trace on;

--Para endosos
if a_no_endoso <> "00000" then	
	--VERFICAR LIMITE DE COBERTURA DE ADELANTO
	--00988 ADELANTO 35%
	--00989 ADELANTO 50%
	select count(*)
	  into _cnt
	  from endedcob
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and cod_cobertura in('00988');

	if _cnt is null then
		let _cnt = 0;
	end if
	let _limite_1 = null;
	if _cnt > 0 then
		select limite_1,
		       prima_anual
		  into _limite_1,
		       _prima_anual
		  from endedcob
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and cod_cobertura = '00988';
		   
		if (_limite_1 = 0 OR _limite_1 is null) OR _prima_anual = 0 then
			let _error_cod  = 1;
			let _error_desc = "NO PUEDE DEJAR SIN VALOR EL LIMITE NI LA PRIMA DE LA COBERTURA DE ADELANTO 35%, Verifique";
			Return _error_cod, _error_desc with resume;					  
		end if
	end if
	--*****************
	select count(*)
	  into _cnt
	  from endedcob
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and cod_cobertura in('00989');
	if _cnt is null then
		let _cnt = 0;
	end if
	let _limite_1 = null;
	if _cnt > 0 then
		select limite_1
		  into _limite_1
		  from endedcob
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and cod_cobertura = '00989';
		   
		if _limite_1 = 0 OR _limite_1 is null then
			let _error_cod  = 1;
			let _error_desc = "NO PUEDE DEJAR SIN VALOR EL LIMITE DE LA COBERTURA DE ADELANTO 50%, Verifique";
			Return _error_cod, _error_desc with resume;					  
		end if
	end if
else	--Para polizas
	--00988 ADELANTO 35%
	--00989 ADELANTO 50%
	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = a_no_poliza
	   and cod_cobertura in('00988');
	if _cnt is null then
		let _cnt = 0;
	end if
	let _limite_1 = null;
	if _cnt > 0 then
		select limite_1,
		       prima_anual
		  into _limite_1,
		       _prima_anual
		  from emipocob
		 where no_poliza = a_no_poliza
		   and cod_cobertura = '00988';
		if (_limite_1 = 0 OR _limite_1 is null) OR _prima_anual = 0 then
			let _error_cod  = 1;
			let _error_desc = "NO PUEDE DEJAR SIN VALOR EL LIMITE NI LA PRIMA DE LA COBERTURA DE ADELANTO 35%, Verifique";
			Return _error_cod, _error_desc with resume;					  
		end if
	end if
	--*****************
	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = a_no_poliza
	   and cod_cobertura in('00989');
	if _cnt is null then
		let _cnt = 0;
	end if
	let _limite_1 = null;
	if _cnt > 0 then
		select limite_1,
		       prima_anual
		  into _limite_1,
		       _prima_anual
		  from emipocob
		 where no_poliza = a_no_poliza
		   and cod_cobertura = '00989';
		if _limite_1 = 0 OR _limite_1 is null then
			let _error_cod  = 1;
			let _error_desc = "NO PUEDE DEJAR SIN VALOR EL LIMITE DE LA COBERTURA DE ADELANTO 50%, Verifique";
			Return _error_cod, _error_desc with resume;					  
		end if
	end if
end if		
end

let _error_cod  = 0;
let _error_desc = "Proceso Completado.";	

return _error_cod, _error_desc;
end procedure 