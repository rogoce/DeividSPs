-- Reporte que analiza todo el registro contable y genera solo los errores.
-- 
-- Creado    : 14/09/2009 - Autor: Armando Moreno
--                        - Verificacion de reaseguro x unidad
--
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_sis109;
create procedure sp_sis109(a_no_poliza char(10))
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
define _pbs_endoso,_suma_unidad		dec(16,2);
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
let _null     = null;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

--set debug file to "sp_sis109.trc";
--trace on;

foreach
	select prima_suscrita,
	       cod_tipoprod,
		   cod_ramo,
		   no_documento
	  into _pbs_endoso,
	       _cod_tipoprod,
		   _cod_ramo,
		   _no_documento
	  from emipomae
	 where no_poliza   = a_no_poliza
	   and actualizado = 0

	if _no_documento in ('0224-05256-01') then
		return 0,"Proceso Completado.";
	end if
	
	if _cod_ramo = '019' then	--VERFICAR LIMITE DE COBERTURA DE ADELANTO
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
			select limite_1
			  into _limite_1
			  from emipocob
			 where no_poliza = a_no_poliza
			   and cod_cobertura = '00988';
            if _limite_1 = 0 OR _limite_1 is null then
				let _error_cod  = 1;
				let _error_desc = "NO PUEDE DEJAR SIN VALOR EL LIMITE DE LA COBERTURA DE ADELANTO 35%, Verifique";
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
			select limite_1
			  into _limite_1
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

	foreach
	  select no_unidad
	    into _no_unidad
	    from emipouni
	   where no_poliza = a_no_poliza
	   order by no_unidad

		select count(*)
		  into _cantidad
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _cantidad > 0 then
		else
			if _pbs_endoso <> 0.00 then
				let _error_cod  = 1;
				let _error_desc = "Para la Unidad: " || _no_unidad || " No Existe Reaseguro, Verifique";
				Return _error_cod, _error_desc with resume;
			end if
		end if
	end foreach
    let _suma_unidad = 0;
	let _suma_uni_rea = 0;
	if _cod_tipoprod = '001' then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = a_no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if
	foreach
		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_unidad
		  from emipouni
		 where no_poliza = a_no_poliza
		 order by no_unidad
		
		let _suma_unidad = _suma_unidad * _porc_coas_ancon /100;	--Coas May, sacar solo la parte de ancon
		foreach
			select cod_cober_reas,
				   cod_contrato
			  into _cod_cober_reas,
				   _cod_contrato
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad

			select count(*)
			  into _cantidad
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _cantidad > 0 then
			else
				let _error_cod  = 1;
				let _error_desc = "No existe cobertura de reaseguro para la Unidad: " || _no_unidad || " Contrato: " || _cod_contrato;
				Return _error_cod, _error_desc with resume;					  
			end if
			
			--Verificar que la suma asegurada de la unidad, sea igual a la suma asegurada total de la unidad en el reaseguro (emifacon) Puesto 15/05/2023 Armando
			select sum(suma_asegurada)
			  into _suma_uni_rea
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;
			
			if _cod_ramo not in('002','020') then
				if _suma_unidad <> _suma_uni_rea then
					if _cod_cober_reas not in('050','051') then	--VIDA RETENCION, LA SUMA ASEG ES CERO.
						let _error_cod  = 1;
						let _error_desc = "Unidad: " || _no_unidad || " Suma Asegurada de la unidad, es diferente a la unidad del reaseguro, Verifique";
						Return _error_cod, _error_desc with resume;
					end if
				end if
			else
				select sum(suma_asegurada)
				  into _suma_uni_rea
				  from emifacon
				 where no_poliza = a_no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;
				   
				if _suma_unidad <> _suma_uni_rea then
					let _error_cod  = 1;
					let _error_desc = "Unidad: " || _no_unidad || " Suma Asegurada de la unidad, es diferente a la unidad del reaseguro, Verifique";
					Return _error_cod, _error_desc with resume;					  
				end if
			end if	
			
		end foreach
	end foreach
end foreach;
end

let _error_cod  = 0;
let _error_desc = "Proceso Completado.";	

return _error_cod, _error_desc;
end procedure 