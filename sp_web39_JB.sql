-- Concurso roma 2017   
-- 
-- Creado    : 03/02/2017 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
-- Act. Jesus Brito - Qatar 2020

DROP procedure sp_web39_JB;
CREATE procedure "informix".sp_web39_JB(
a_cod_agente 	varchar(5)
)
RETURNING varchar(20),
		  varchar(5),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  varchar(15),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  varchar(1),
		  decimal(16,2);

BEGIN
	DEFINE v_pri_sus_pag_aa		decimal(16,2);
	DEFINE v_sini_inc           decimal(16,2);
	DEFINE v_siniestralidad     decimal(16,2);
	define v_persistencia       decimal(16,2);
	DEFINE v_porc               varchar(15);
	DEFINE v_tipo_agente        varchar(20);
	define v_licencia           varchar(1);
	define v_cnt_milan08        integer;
	define v_cnt_meta           decimal(16,2);
	define v_vigenteaa          integer;
	define v_renovaa            integer;
	define v_total_aa_cnt_pol   decimal(16,2);
	define v_pri_can_ap         decimal(16,2);
	define v_porc_1             decimal(16,2);
	define v_total_con_porc     decimal(16,2);
	define v_pri_pag_ap         decimal(16,2);
	define v_faltantepc         decimal(16,2);
	define v_grupo              integer;
	define v_cod_agente         varchar(5);
	define _error               smallint;
	

	SET ISOLATION TO DIRTY READ;

	--set debug file to "sp_web39.trc";
	--trace on;
	let v_cod_agente = a_cod_agente;
	call sp_che168(v_cod_agente) returning _error,a_cod_agente;
	
	select estatus_licencia
	  into v_licencia 
	  from agtagent 
	 where cod_agente = a_cod_agente;
	 
	select count(*)
	  into v_cnt_milan08
	  from milan08
	  where cod_agente = a_cod_agente;
	
	let v_pri_sus_pag_aa    = 0;
    let v_sini_inc          = 0;
	let v_porc              = '';
	let	v_siniestralidad 	= 0;
	let v_vigenteaa         = 0;
	let v_renovaa           = 0;
	let v_total_aa_cnt_pol  = 0;
	let v_pri_can_ap        = 0;
	let v_total_con_porc    = 0;
	let v_pri_pag_ap        = 0;
	let v_grupo             = 0;
	let v_persistencia      = 0;
	let v_faltantepc		= 0;
	let v_cnt_meta			= 0;
	let v_tipo_agente		= "";
	
	if v_licencia = 'A' and v_cnt_milan08 > 0 then
		select tipo_agente,
			   sum(sini_inc),
			   sum(pri_pag_ap),
			   sum(pri_can_ap),
			   sum(pri_sus_pag_aa),
			  --(sum(renovaa_per) / (sum(case when renovaa_per = 1 and vigenteap_per = 0 and renovap_per = 0  then vigenteap_per + 1 else vigenteap_per end) + sum(renovap_per)) * 100)  
			  (sum(renovaa_per) / case when (sum(case when renovaa_per = 1 and vigenteap_per = 0 and renovap_per = 0  then vigenteap_per + 1 else vigenteap_per end)  + sum(renovap_per)) > 0 then (sum(case when renovaa_per = 1 and vigenteap_per = 0 and renovap_per = 0  then vigenteap_per + 1 else vigenteap_per end)  + sum(renovap_per)) end  * 100)
		 into v_tipo_agente,
			  v_sini_inc,
			  v_pri_pag_ap,
			  v_pri_can_ap,
			  v_pri_sus_pag_aa,
			  v_persistencia
		 from milan08 
		where cod_agente = a_cod_agente
		group by tipo_agente;
		
		if trim(v_tipo_agente) = 'Rango 1' then
			let v_porc = '5%';
			let v_cnt_meta = 150;
			let v_porc_1 = 5;
		elif trim(v_tipo_agente) = 'Rango 2' then
			let v_porc = '7.5%';
			let v_cnt_meta = 100;
			let v_porc_1 = 7.5;
		elif trim(v_tipo_agente) = 'Rango 3' then
			let v_porc = '10%';
			let v_cnt_meta = 80;
			let v_porc_1 = 10;
		elif trim(v_tipo_agente) = 'Rango 4' then
			let v_porc = '13%';
			let v_cnt_meta = 60;
			let v_porc_1 = 13;
		elif trim(v_tipo_agente) = 'Rango 5' then
			let v_porc = "Mayor 135,000";
			let v_cnt_meta = 40;
			let v_porc_1  = 135000;
			let v_grupo   = 1;
		else
			let v_tipo_agente = 'Corredores Nuevos';
			let v_cnt_meta = 40;
			let v_porc = "Mayor 135,000";
			let v_porc_1  = 135000;
			let v_grupo   = 1;
		end if
		
		/*Siniestralidad*/
			if v_sini_inc = 0 then
				let v_siniestralidad = 0;
			elif v_pri_pag_ap = 0 then
				let v_siniestralidad = 0;
			else
				let v_siniestralidad = (v_sini_inc/v_pri_pag_ap) * 100;
			end if
			
			if v_siniestralidad < 0 then
				let v_siniestralidad = 0;
			end if
				
		/*Cantidad de polizas*/
		select sum(vigenteaa),
			   sum(renovaa)
		 into v_vigenteaa,
			  v_renovaa
		 from milan08 
		where cod_agente = a_cod_agente;
		  --and cod_ramo not in('020','004');
		
		let v_total_aa_cnt_pol     = v_vigenteaa + v_renovaa;
		
		/*Primas cobradas*/
		if v_grupo = 0 then
			let v_total_con_porc = (v_pri_can_ap * v_porc_1) / 100 + v_pri_can_ap;
			let v_faltantepc     = v_total_con_porc - v_pri_sus_pag_aa;
			if trim(v_tipo_agente) = 'Rango 4' then
				if v_total_con_porc < 135000 then
					let v_total_con_porc = 135000;
					let v_faltantepc     = v_total_con_porc - v_pri_sus_pag_aa;
				end if
			end if
		else
			let v_pri_can_ap = 0;
			let v_total_con_porc = v_pri_can_ap + v_porc_1;
			let v_faltantepc     = v_total_con_porc - v_pri_sus_pag_aa;
		end if
	end if	
	

	return v_tipo_agente,
	       a_cod_agente,
		   v_siniestralidad,
		   v_cnt_meta,
		   v_total_aa_cnt_pol,
		   v_porc,
		   v_pri_can_ap,
		   v_total_con_porc,
		   v_pri_sus_pag_aa,
		   v_faltantepc,
		   v_licencia,
		   v_persistencia
	       with resume;
END
END PROCEDURE;
