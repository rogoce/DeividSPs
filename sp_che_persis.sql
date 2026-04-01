--BONO DE PERSISTENCIA
--FECHA: 10/02/2022
--ARMANDO MORENO M.
--FECHA 2023 = 04/05/2023
--FECHA 2024 = 03/05/2024

--a_opc = 1 para que se ejecute el conteo de polizas año pasado (solo se ejecuta una sola vez).

drop procedure sp_che_persis;
create procedure sp_che_persis(a_compania char(3), a_agencia char(3), a_opc smallint default 0)
returning smallint;
			
define v_filtros			varchar(255);
define v_nombre_cliente		varchar(100);
define v_compania_nombre	varchar(50);
define v_nombre_agente		varchar(50);
define _nombre_subramo		varchar(50);
define v_nombre_ramo		varchar(50);
DEFINE v_nombre_clte		char(100);
define _error_desc varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_sucursal		char(3);
define _cod_subramo			char(3);
define _tipo_agente         char(1);
define _cod_ramo            char(3);
define _tipo				char(1);
define _pagada	            smallint;
define _prima_suscrita,_monto_p      dec(16,2);
define _mes1,_declarativa   smallint;
define _mes2,_meses  		smallint;
define _error,_valor,_cnt	integer;
define _porc_partic_agt     dec(5,2);
define my_sessionid,_no_pol_nue_ap_per,_no_pol_ren_ap_per,_no_pol_ren_aa_per   integer;

set isolation to dirty read;

let v_compania_nombre = sp_sis01(a_compania);

--set debug file to "sp_che_persis.trc";
--trace on;
--trace off;

let _tipo = '';
let _monto_p = 0.00;

RETURN 0;	--PONER EN COMENTARIO CUANDO VA A INICIAR EL BONO. YA NO DEBE CORRER POR INSTRUCCION ROMAN 12/05/2025

delete from chepersisaa;

let my_sessionid = DBINFO('sessionid');

--**PERSISTENCIA**
--***************************************
-- Polizas Nuevas y Renovadas AÑO PASADO
--***************************************
if a_opc = 1 then
	delete from chepersisap;

	call sp_bo077_per('01/01/2024', '31/12/2024') returning _error, _error_desc;

	foreach
		select no_documento,
			   sum(no_pol_nueva_per),
			   sum(no_pol_renov_per)
		  into _no_documento,
			   _no_pol_nue_ap_per,
			   _no_pol_ren_ap_per
		  from tmp_persis
		 group by no_documento

		let _no_poliza = sp_sis21(_no_documento);
		let _valor = sp_sis101a(_no_documento,'01/01/2024','31/12/2024',my_sessionid);
		foreach
			select cod_agente
			  into _cod_agente
			  from con_corr
			 where sessionid = my_sessionid
			 
			select tipo_agente into _tipo_agente from agtagent
			where cod_agente = _cod_agente;
			
			if _cod_agente = '02442' then -- se excluye 0242 cado 11579 19/09/24 9:45 am
				continue foreach;
			end if
	
			if _tipo_agente = 'O' then
				continue foreach;
			end if
			
			insert into chepersisap(
			no_documento, 
			no_pol_nue_ap_per,
			no_pol_ren_ap_per,
			cod_agente,
			no_poliza
			)
			values(
			_no_documento, 
			_no_pol_nue_ap_per,
			_no_pol_ren_ap_per,
			_cod_agente,
			_no_poliza
			);
		end foreach
	end foreach
	drop table tmp_persis;
	let _valor = sp_che_persis1();	--Crea la tabla final del año pasado con la cantidad de poliza por corredor chepersisapt.
end if
--******************************
-- Polizas Renovadas AÑO ACTUAL
--******************************
call sp_bo077_per('01/01/2025', today) returning _error, _error_desc;

foreach
	select no_documento,
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_ren_aa_per
	  from tmp_persis
	 group by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	let _valor = sp_sis101a(_no_documento,'01/01/2025','31/12/2025',my_sessionid);
	foreach
		select cod_agente
		  into _cod_agente
		  from con_corr
		 where sessionid = my_sessionid
		 
		select tipo_agente into _tipo_agente from agtagent
		where cod_agente = _cod_agente;
	
		if _tipo_agente = 'O' then
			continue foreach;
		end if
		
		if _cod_agente = '02442' then
			continue foreach;
		end if

		select count(*)
		  into _cnt
		  from chepersisapt
		 where cod_agente = _cod_agente;
        if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
	 		insert into chepersisaa(
			no_documento, 
			no_pol_ren_aa_per,
			cod_agente,
			no_poliza
			)
			values(
			_no_documento, 
			_no_pol_ren_aa_per,
			_cod_agente,
			_no_poliza
			);
		end if
	end foreach
end foreach
drop table tmp_persis;
return 0;
end procedure;