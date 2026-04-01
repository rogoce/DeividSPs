--BONO DE PERSISTENCIA

--FECHA: 12/02/2022
--ARMANDO MORENO M.

drop procedure sp_che_persis1;
create procedure sp_che_persis1()
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
define _pagada	            smallint;
define _prima_suscrita,_monto_p      dec(16,2);
define _mes1,_declarativa   smallint;
define _mes2,_meses  		smallint;
define _error,_valor,_cnt	integer;
define _porc_partic_agt     dec(5,2);
define my_sessionid,_no_pol_nue_ap_per,_no_pol_ren_ap_per,_no_pol_ren_aa_per   integer;

set isolation to dirty read;


--set debug file to "sp_che_persis1.trc";
--trace on;
--trace off;

--**PERSISTENCIA**
--***************************************
-- Polizas Nuevas y Renovadas AÑO PASADO
--***************************************
let _no_pol_nue_ap_per = 0;
delete from chepersisapt;
foreach
	select cod_agente,
		   no_documento,
		   sum(no_pol_nue_ap_per) + sum(no_pol_ren_ap_per)
	  into _cod_agente,
           _no_documento,
           _no_pol_nue_ap_per
	  from chepersisap
	 group by cod_agente,no_documento
	 order by cod_agente
		 
    if _no_pol_nue_ap_per = 2 then
		let _no_pol_nue_ap_per = 1;
	end if
	select count(*)
	  into _cnt
	  from chepersisapt
	 where cod_agente = _cod_agente;

	if _cnt = 0 then 
		insert into chepersisapt(
		cant_pol,
		cod_agente
		)
		values(
		_no_pol_nue_ap_per,
		_cod_agente
		);
	else
		update chepersisapt
           set cant_pol = cant_pol + _no_pol_nue_ap_per
         where cod_agente = _cod_agente;
	end if
end foreach	
end procedure;