-- Concurso bogota 2017   
-- 
-- Creado    : 15/03/2017 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_web41;
CREATE procedure "informix".sp_web41(
a_cod_agente 	varchar(5)
)
RETURNING decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  varchar(20),
		  varchar(1),
		  smallint,
		  smallint;

BEGIN
	DEFINE v_pri_sus_min_global_a	decimal(16,2);
	DEFINE v_pri_sus_min_global_b	decimal(16,2);
	DEFINE v_pri_sus_aa_a         	decimal(16,2);
	DEFINE v_pri_sus_aa_b         	decimal(16,2);
	DEFINE v_faltante_pri_sus_a   	decimal(16,2);
	DEFINE v_faltante_pri_sus_b   	decimal(16,2);
	DEFINE v_pri_sus_salud_a     	decimal(16,2);
	DEFINE v_pri_sus_mr_a	      	decimal(16,2);
	DEFINE v_pri_sus_auto_a     	decimal(16,2);
	DEFINE v_pri_sus_vida_a      	decimal(16,2);
	DEFINE v_pri_sus_cancer_a     	decimal(16,2);
	DEFINE v_pri_sus_salud_b     	decimal(16,2);
	DEFINE v_pri_sus_mr_b	      	decimal(16,2);
	DEFINE v_pri_sus_vida_b      	decimal(16,2);
	DEFINE v_pri_sus_cancer_b     	decimal(16,2);
	DEFINE v_tipo_agente            varchar(20);
	DEFINE v_cnt_puntacana          SMALLINT;
	DEFINE v_licencia               char(1);
	DEFINE v_cod_ramo               varchar(3);
	DEFINE v_meta_global            smallint;
	DEFINE v_meta_ramo              smallint;

	SET ISOLATION TO DIRTY READ;

	--set debug file to "sp_web41.trc";
	--trace on;
	
	select estatus_licencia
	  into v_licencia 
	  from agtagent 
	 where cod_agente = a_cod_agente;
	 
	select count(*)
	  into v_cnt_puntacana
	  from punta_cana
	  where cod_agente = a_cod_agente;
	
	let v_pri_sus_min_global_a    = 0;
	let v_pri_sus_min_global_b    = 0;	
    let v_pri_sus_aa_a 			  = 0;
	let v_pri_sus_aa_b 			  = 0;	 	
	let v_faltante_pri_sus_a      = 0;	
    let v_faltante_pri_sus_b      = 0;		
	let v_pri_sus_salud_a         = 0;	    
	let v_pri_sus_mr_a            = 0;	      
	let v_pri_sus_auto_a          = 0;	     
	let v_pri_sus_vida_a          = 0;	
	let	v_pri_sus_cancer_a        = 0;
	let v_pri_sus_salud_b         = 0;	    
	let v_pri_sus_mr_b           = 0;	          
	let v_pri_sus_vida_b          = 0;	
	let	v_pri_sus_cancer_b        = 0;	  	
	let	v_tipo_agente             = "";   
	let v_meta_global             = 0;
    let v_meta_ramo               = 0; 
	
	if v_licencia = 'A' and v_cnt_puntacana > 0 then
	--Opcion A
	   select sum(prima_sus_nva)
		 into v_pri_sus_aa_a
		 from punta_cana
		where cod_agente = a_cod_agente
		and cod_ramo in('018','003','019','002')
	 group by tipo_agente;
	
		select sum(prima_salud)
		 into v_pri_sus_salud_a
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019','002');
	 
		if v_pri_sus_salud_a is null then
			let v_pri_sus_salud_a = 0;
		end if
		
		select sum(prima_mr)
		 into v_pri_sus_mr_a
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019','002');
	 
		if v_pri_sus_mr_a is null then
			let v_pri_sus_mr_a = 0;
		end if
		
		select sum(prima_cancer)
		 into v_pri_sus_cancer_a
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019','002');
	 
		if v_pri_sus_cancer_a is null then
			let v_pri_sus_cancer_a = 0;
		end if
		
		select sum(prima_vida)
		 into v_pri_sus_vida_a
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019','002');
	 
		if v_pri_sus_vida_a is null then
			let v_pri_sus_vida_a = 0;
		end if	
		
		select sum(prima_auto)
		 into v_pri_sus_auto_a
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019','002');
	 
		if v_pri_sus_auto_a is null then
			let v_pri_sus_auto_a = 0;
		end if	
		
	--Opcion B
		select sum(prima_sus_nva)
		 into  v_pri_sus_aa_b
		 from punta_cana
		where cod_agente = a_cod_agente
		and cod_ramo in('018','003','019')
	 group by tipo_agente;

		select sum(prima_salud)
		 into v_pri_sus_salud_b
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019');
	 
		if v_pri_sus_salud_b is null then
			let v_pri_sus_salud_b = 0;
		end if
		
		select sum(prima_mr)
		 into v_pri_sus_mr_b
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019');
	 
		if v_pri_sus_mr_b is null then
			let v_pri_sus_mr_b = 0;
		end if
		
		select sum(prima_cancer)
		 into v_pri_sus_cancer_b
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019');
	 
		if v_pri_sus_cancer_b is null then
			let v_pri_sus_cancer_b = 0;
		end if
		
		select sum(prima_vida)
		 into v_pri_sus_vida_b
		 from punta_cana
		where cod_agente = a_cod_agente
		  and cod_ramo in('018','003','019');
	 
		if v_pri_sus_vida_b is null then
			let v_pri_sus_vida_b = 0;
		end if
		
/*		select cod_ramo, 
	           sum(prima_sus_nva)
		 into v_cod_ramo,
		      v_pri_sus_aa_sa
		 from punta_cana
		where cod_agente = a_cod_agente
          and cod_ramo 	 = '018'
	 group by cod_ramo;
	 
	if v_pri_sus_aa_sa is null then
		let v_pri_sus_aa_sa = 0;
	end if	 
	
	   select cod_ramo, 
	          sum(prima_sus_nva)
		 into v_cod_ramo,
		      v_pri_sus_aa_mu
		 from punta_cana
		where cod_agente = a_cod_agente
          and cod_ramo 	 = '003'
	 group by cod_ramo; 
	
	if v_pri_sus_aa_mu is null then
		let v_pri_sus_aa_mu = 0;
	end if	
	
		select cod_ramo, 
	           sum(prima_sus_nva)
		 into v_cod_ramo,
		      v_pri_sus_aa_vi
		 from punta_cana
		where cod_agente = a_cod_agente
          and cod_ramo 	 = '019'
     group by cod_ramo;
	
	if v_pri_sus_aa_vi is null then
		let v_pri_sus_aa_vi = 0;
	end if
	*/
		select tipo_agente
		 into v_tipo_agente
		 from punta_cana
		where cod_agente = a_cod_agente
	 group by tipo_agente;
	 
		if trim(v_tipo_agente) = 'Grupo I' then
			let v_pri_sus_min_global_a = 50000;
			let v_pri_sus_min_global_b = 15000;
		elif trim(v_tipo_agente) = 'Grupo II' then
			let v_pri_sus_min_global_a = 40000;
			let v_pri_sus_min_global_b = 12000;
		elif trim(v_tipo_agente) = 'Grupo III' then
			let v_pri_sus_min_global_a = 25000;
			let v_pri_sus_min_global_b = 9000;
		elif trim(v_tipo_agente) = 'Grupo IV' then
			let v_pri_sus_min_global_a = 20000;
		    let v_pri_sus_min_global_b = 7000;
		else
			let v_pri_sus_min_global_a = 15000;
			let v_pri_sus_min_global_b = 5000;
		end if
		
		let v_faltante_pri_sus_a 		= v_pri_sus_min_global_a - v_pri_sus_aa_a;
		let v_faltante_pri_sus_b 		= v_pri_sus_min_global_b - v_pri_sus_aa_b;
		
		if v_faltante_pri_sus_a < 0 then
			let v_faltante_pri_sus_a = 0.00;
		end if
		
		if v_faltante_pri_sus_b < 0 then
			let v_faltante_pri_sus_b = 0.00;
		end if
		
		if v_pri_sus_aa_a >= v_pri_sus_min_global_a then
			 let v_meta_global = 1;
		end if
		if v_pri_sus_aa_b >= v_pri_sus_min_global_b then
			let v_meta_ramo = 1;
		end if
		
		
	end if	
	
	return v_pri_sus_min_global_a,
		   v_pri_sus_min_global_b,
	       v_pri_sus_aa_a,
		   v_pri_sus_aa_b,
		   v_faltante_pri_sus_a,
		   v_faltante_pri_sus_b,
		   v_pri_sus_salud_a,
		   v_pri_sus_mr_a,
		   v_pri_sus_vida_a,
		   v_pri_sus_cancer_a,
		   v_pri_sus_auto_a,
		   v_pri_sus_salud_a,
		   v_pri_sus_mr_a,
		   v_pri_sus_vida_a,
		   v_pri_sus_cancer_a,
		   trim(v_tipo_agente),
		   v_licencia,
		   v_meta_global, 
	       v_meta_ramo   
		   with resume;
END
END PROCEDURE;
