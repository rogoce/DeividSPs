DROP procedure sp_jean19v2;
CREATE procedure sp_jean19v2()
RETURNING char(5)  as cod_agente,
          char(50) as n_agente,
		  char(3)  as cod_vta_per,
		  char(50) as n_zona_per,
		  char(3)  as cod_vta_gen,
		  char(50) as n_zona_gen,
		  char(50) as n_zona_cob,
		  integer   as cant_pol_vig,
		  dec(16,2) as prima_neta_vi,
		  dec(16,2) as saldo_exi_vi,
		  integer   as cant_pol_ce,
		  dec(16,2) as prima_neta_ce,
		  dec(16,2) as saldo_exi_ce,
		  integer   as cant_pol_ve,
		  dec(16,2) as prima_neta_ve,
		  dec(16,2) as saldo_exi_ve,
		  integer   as cant_pol_sa,
		  dec(16,2) as prima_neta_sa,
		  dec(16,2) as saldo_exi_sa,
 		  integer   as cant_pol_ve_vi,
		  dec(16,2) as prima_neta_ve_vi,
		  dec(16,2) as saldo_exi_ve_vi,
  		  integer   as cant_pol_ca,
		  dec(16,2) as prima_neta_ca,
		  dec(16,2) as saldo_exi_ca,
 		  integer   as cant_pol_an,
		  dec(16,2) as prima_neta_an,
		  dec(16,2) as saldo_exi_an;

DEFINE _no_poliza,_no_factura	 	CHAR(10);
DEFINE _no_documento                CHAR(20);
DEFINE _cod_agente                  CHAR(5);
define _cod_ramo,_cod_tipoprod      char(3);
define _cod_contratante             char(10);
define _porc_coas_ancon,_porc_partic_agt		        dec(5,2);
DEFINE _n_zona_per,_n_agente,_n_zona_gen,_n_zona_cob   	CHAR(50);
define _vi,_vf,_fecha_emision		    date;
define _cod_formapag,_cod_vendedor,_cod_vendedor2,_cod_cobrador,_cod_no_renov	CHAR(3);
define _pro_cotizacion,_cant,_estatus_poliza,_cnt  								integer;
define _cantidad_vi,_cantidad_ce,_cantidad_ve_vi,_cantidad_an,_cantidad_ca,_cantidad_sa,_cantidad_ve 	integer;
define _prima_neta_ce,_saldo_exi_ce,_prima_neta_ve,_saldo_exi_ve,_prima_neta_sa,_saldo_exi_sa decimal(16,2);
define _prima_neta_ve_vi,_saldo_exi_ve_vi,_prima_neta_ca,_saldo_exi_ca,_exigible  decimal(16,2);
define _prima_neta_an,_saldo_exi_an,_prima_neta_vi,_saldo_exi_vi dec(16,2);
define _prima_neta,_prima_neta_r,_exigible_r    decimal(16,2);
	
let _prima_neta_ce = 0;
let _saldo_exi_ce  = 0;
let _prima_neta_ve = 0;
let _saldo_exi_ve  = 0;
let _prima_neta_sa = 0;
let _saldo_exi_sa  = 0;
let _prima_neta_ve_vi = 0;
let _saldo_exi_ve_vi = 0;
let _prima_neta_ca = 0;
let _saldo_exi_ca  = 0;
let _prima_neta_an = 0;
let _saldo_exi_an  = 0;
let _prima_neta_vi = 0;
let _saldo_exi_vi  = 0;
let _prima_neta    = 0;
let _porc_coas_ancon = 0.00;

delete from deivid_tmp:cnt_polizas_agente;

foreach
	select distinct e.prima_neta ,e.cod_tipoprod,e.cod_ramo,e.no_poliza,e.estatus_poliza,e.cod_no_renov
	  into _prima_neta,_cod_tipoprod,_cod_ramo,_no_poliza,_estatus_poliza,_cod_no_renov
	  from emipomae e
	 where e.actualizado = 1
	   and e.vigencia_inic >= '01/01/2024'
	 order by e.no_poliza
	 
	let _exigible = 0.00;

	select monto_90 + monto_60 + monto_30 + corriente
	  into _exigible
	  from emipoliza
	 where no_poliza = _no_poliza;
	 
	if _exigible is null then
		let _exigible = 0.00;
	end if

	if _cod_tipoprod = '001' then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if
	
	let _prima_neta   = _prima_neta * _porc_coas_ancon /100;
	let _prima_neta_r = 0.00;
	let _exigible_r   = 0.00;
	foreach
		select cod_agente,
		       porc_partic_agt
          into _cod_agente,
		       _porc_partic_agt
		  from emipoagt
         where no_poliza = _no_poliza

		select count(*)
		  into _cnt
		  from deivid_tmp:cnt_polizas_agente
		 where cod_agente = _cod_agente;
		 
		let _prima_neta_r = _prima_neta * _porc_partic_agt /100;
		let _exigible_r   = _exigible * _porc_partic_agt /100;

		if _estatus_poliza = 1 then	--polizas vigentes
			if _cod_no_renov = '039' then	--polizas vigentes y que tenga no_renovacion 039 - Vigentes Cese
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt = 0 then
					
					insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_ce,prima_neta_ce,saldo_exi_ce)
					values(_cod_agente,1,_prima_neta_r,_exigible_r);
					continue foreach;
				else
					update deivid_tmp:cnt_polizas_agente
					   set prima_neta_ce = prima_neta_ce + _prima_neta_r,
						   saldo_exi_ce = saldo_exi_ce + _exigible_r,
						   cantidad_ce = cantidad_ce + 1
					 where cod_agente = _cod_agente;
					 continue foreach;
				end if
			end if
			
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				
				insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_vi,prima_neta_vi,saldo_exi_vi)
				values(_cod_agente,1,_prima_neta_r,_exigible_r);
				continue foreach;
			else
				update deivid_tmp:cnt_polizas_agente
				   set prima_neta_vi = prima_neta_vi + _prima_neta_r,
					   saldo_exi_vi = saldo_exi_vi + _exigible_r,
					   cantidad_vi = cantidad_vi + 1
				 where cod_agente = _cod_agente;
				 continue foreach;
			end if
		end if
		
		if _estatus_poliza = 3 then	--polizas vencida
			if _cod_ramo = '018' And _cod_no_renov = '027' then	--Ramo 018 y que tenga no_renovacion 027 - Vencida Salud
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt = 0 then
					
					insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_sa,prima_neta_sa,saldo_exi_sa)
					values(_cod_agente,1,_prima_neta_r,_exigible_r);
					continue foreach;
				else
					update deivid_tmp:cnt_polizas_agente
					   set prima_neta_sa = prima_neta_sa + _prima_neta_r,
						   saldo_exi_sa = saldo_exi_sa + _exigible_r,
						   cantidad_sa = cantidad_sa + 1
					 where cod_agente = _cod_agente;
					continue foreach;
				end if
			end if
			if _cod_ramo = '019' And _cod_no_renov = '041' then	--Ramo 019 y que tenga no_renovacion 041 - Vencidas Vida
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt = 0 then
					
					insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_ve_vi,prima_neta_ve_vi,saldo_exi_ve_vi)
					values(_cod_agente,1,_prima_neta_r,_exigible_r);
					continue foreach;
				else
					update deivid_tmp:cnt_polizas_agente
					   set prima_neta_ve_vi = prima_neta_ve_vi + _prima_neta_r,
						   saldo_exi_ve_vi = saldo_exi_ve_vi + _exigible_r,
						   cantidad_ve_vi = cantidad_ve_vi + 1
					 where cod_agente = _cod_agente;
					continue foreach;
				end if
			end if
			
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				
				insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_ve,prima_neta_ve,saldo_exi_ve)
				values(_cod_agente,1,_prima_neta_r,_exigible_r);
				continue foreach;
			else
				update deivid_tmp:cnt_polizas_agente
				   set prima_neta_ve = prima_neta_ve + _prima_neta_r,
					   saldo_exi_ve = saldo_exi_ve + _exigible_r,
					   cantidad_ve = cantidad_ve + 1
				 where cod_agente = _cod_agente;
				 continue foreach;
			end if
		end if
		
		if _estatus_poliza = 2 then	--polizas Canceladas
		
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				
				insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_ca,prima_neta_ca,saldo_exi_ca)
				values(_cod_agente,1,_prima_neta_r,_exigible_r);
				continue foreach;
			else
				update deivid_tmp:cnt_polizas_agente
				   set prima_neta_ca = prima_neta_ca + _prima_neta_r,
					   saldo_exi_ca = saldo_exi_ca + _exigible_r,
					   cantidad_ca = cantidad_ca + 1
				 where cod_agente = _cod_agente;
				 continue foreach;
			end if
		end if
		if _estatus_poliza = 4 then	--polizas Anuladas
		
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				
				insert into deivid_tmp:cnt_polizas_agente(cod_agente,cantidad_an,prima_neta_an,saldo_exi_an)
				values(_cod_agente,1,_prima_neta_r,_exigible_r);
				continue foreach;
			else
				update deivid_tmp:cnt_polizas_agente
				   set prima_neta_an = prima_neta_an + _prima_neta_r,
					   saldo_exi_an = saldo_exi_an + _exigible_r,
					   cantidad_an = cantidad_an + 1
				 where cod_agente = _cod_agente;
				 continue foreach;
			end if
		end if
	end foreach
end foreach

--*******LECTURA Y SALIDA********
foreach
	select cod_agente,sum(cantidad_vi),sum(prima_neta_vi),sum(saldo_exi_vi),sum(cantidad_ce),sum(prima_neta_ce),sum(saldo_exi_ce),
	       sum(cantidad_ve),sum(prima_neta_ve),sum(saldo_exi_ve),sum(cantidad_sa),sum(prima_neta_sa),sum(saldo_exi_sa),
		   sum(cantidad_ve_vi),sum(prima_neta_ve_vi),sum(saldo_exi_ve_vi),sum(cantidad_ca),sum(prima_neta_ca),sum(saldo_exi_ca),
	       sum(cantidad_an),sum(prima_neta_an),sum(saldo_exi_an)
	  into _cod_agente,_cantidad_vi,_prima_neta_vi,_saldo_exi_vi,_cantidad_ce,_prima_neta_ce,_saldo_exi_ce,
		   _cantidad_ve,_prima_neta_ve,_saldo_exi_ve,_cantidad_sa,_prima_neta_sa,_saldo_exi_sa,
	       _cantidad_ve_vi,_prima_neta_ve_vi,_saldo_exi_ve_vi,_cantidad_ca,_prima_neta_ca,_saldo_exi_ca,
		   _cantidad_an,_prima_neta_an,_saldo_exi_an
	 from deivid_tmp:cnt_polizas_agente
	group by cod_agente
	
	select nombre,cod_cobrador,cod_vendedor,cod_vendedor2
	  into _n_agente,_cod_cobrador,_cod_vendedor,_cod_vendedor2
	  from agtagent
	 where cod_agente = _cod_agente;

    select nombre into _n_zona_gen from agtvende
    where cod_vendedor = _cod_vendedor;	

	select nombre into _n_zona_per from agtvende
    where cod_vendedor = _cod_vendedor2;
	
	select nombre into _n_zona_cob from cobcobra
    where cod_cobrador = _cod_cobrador;
	
	return _cod_agente,_n_agente,_cod_vendedor2,_n_zona_per,_cod_vendedor,_n_zona_gen,_n_zona_cob,_cantidad_vi,_prima_neta_vi,_saldo_exi_vi,
	       _cantidad_ce,_prima_neta_ce,_saldo_exi_ce,_cantidad_ve,_prima_neta_ve,_saldo_exi_ve,_cantidad_sa,_prima_neta_sa,_saldo_exi_sa,
		   _cantidad_ve_vi,_prima_neta_ve_vi,_saldo_exi_ve_vi,_cantidad_ca,_prima_neta_ca,_saldo_exi_ca,
		   _cantidad_an,_prima_neta_an,_saldo_exi_an with resume;
	
	
end foreach
END PROCEDURE;
