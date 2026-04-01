-- Reporte de los Bonificacion de Rentabilidad  
-- Creado    : 16/02/2009 - Autor: Henry Giron
-- Modificado: 16/02/2009 - Autor: Henry Giron

DROP PROCEDURE sp_che110;

CREATE PROCEDURE sp_che110(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
RETURNING 	CHAR(50),  	-- cia
			CHAR(50), 	-- agente
			CHAR(50), 	-- tipo
			DEC(16,2),	-- siniestralidad	  
			DEC(16,2),	-- crecimiento	  
			DEC(16,2),	-- siniestros	
			DEC(16,2),	-- prima anterior
			DEC(16,2),	-- prima actual
			DEC(16,2),	-- comision
			DEC(16,2),	-- porcentaje
			smallint,	-- s_aplica
			smallint;   -- n_aplica

DEFINE _tipo             CHAR(1);
DEFINE v_cod_agente      CHAR(5);  
DEFINE v_no_poliza       CHAR(10); 
DEFINE v_monto           DEC(16,2);
DEFINE v_no_recibo       CHAR(10); 
DEFINE v_fecha           DATE;     
DEFINE v_prima           DEC(16,2);
DEFINE v_porc_comis      DEC(16,2); 
DEFINE v_porc_cre	     DEC(16,2); 
DEFINE v_porc_sin	     DEC(16,2); 
DEFINE v_comision        DEC(16,2);
DEFINE v_nombre_clte     CHAR(100);
DEFINE v_no_documento    CHAR(20);
DEFINE v_nombre_agt      CHAR(50);
DEFINE v_nombre_cia      CHAR(50);
DEFINE _fecha_comis      DATE;
DEFINE _porc_persis      DEC(16,2);
DEFINE _porcentaje       DEC(16,2);
DEFINE _estatus_licencia CHAR(1);
DEFINE _cod_ramo	     CHAR(3);
DEFINE _prima_ap         DEC(16,2);
DEFINE _nombre_ramo      CHAR(50);
DEFINE _cod_ramo1        CHAR(3);
DEFINE _nombre_ramo1     CHAR(50);
DEFINE _prima_ap1        DEC(16,2);
DEFINE _prima_neta1      DEC(16,2);
DEFINE _comision1        DEC(16,2);
DEFINE _sini_g           DEC(16,2);
DEFINE _sini             DEC(16,2);   
DEFINE _incremento_psp   DEC(16,2);
DEFINE _crecimiento      DEC(16,2);
DEFINE _siniestralidad   DEC(16,2);
DEFINE _nombre_tipo      CHAR(50);
DEFINE s_aplica,n_aplica SMALLINT;
DEFINE t_aplica          SMALLINT;


--SET DEBUG FILE TO "che110.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

let v_nombre_cia = sp_sis01(a_compania); 

let t_aplica = 0;
let s_aplica = 0;
let n_aplica = 0;

select count(distinct cod_agente)
  into t_aplica
  from chqrenta
 where periodo    = a_periodo
   and cod_agente matches a_cod_agente ;

if t_aplica is null then
   let t_aplica = 0.00;
end if

select count(distinct cod_agente)
  into s_aplica
  from chqrenta3
 where periodo    = a_periodo
   and cod_agente matches a_cod_agente ;

if s_aplica is null then
   let s_aplica = 0.00;
end if

let n_aplica = t_aplica - s_aplica ;

FOREACH
	select tipo,
	       cod_agente,
		   n_agente,
		   sum(pri_sus_pag_ap), -- Prima_anterior
		   sum(pri_sus_pag_aa), -- Prima_actual
		   sum(sini_inc) siniestro
	  into _tipo,
		   v_cod_agente,
		   v_nombre_agt,
		   _prima_ap1,
		   _prima_neta1,
		   _sini_g
	  from chqrenta
	 where periodo    = a_periodo
	   and cod_agente matches a_cod_agente
	 group by tipo,cod_agente,n_agente
	 order by 3,1

		let _comision1      = 0;
		let _porcentaje     = 0;
        let _incremento_psp = 0;
		let _crecimiento    = 0;
		let _siniestralidad = 0; 			

		if  _tipo = 'A' then 
		  let _nombre_tipo = 'AUTOMOVIL'  ;
        end if
		if  _tipo = 'B' then 
		  let _nombre_tipo = 'SALUD'  ;
        end if
		if  _tipo = 'C' then 
		  let _nombre_tipo = 'PATRIMONIAL'  ;
        end if
		if _tipo = 'D' then 
		  let _nombre_tipo = 'PERSONAS'  ;
        end if
		if  _tipo = 'E' then 
		  let _nombre_tipo = 'FIANZAS'  ;
        end if

		SELECT porcentaje_g, sum(comision)
		  into _porcentaje,_comision1
		  FROM chqrenta3
		 WHERE cod_agente = v_cod_agente
		   and periodo    = a_periodo      
		   and tipo_g     =	_tipo
		 group by porcentaje_g;

		if _comision1 is null then
		   let _comision1 = 0.00;
		end if

		if _porcentaje is null then
		   let _porcentaje = 0.00;
		end if

	
		--************************************************
		--   Calculos para incremeto de PSP 2008 vs 2007
		--************************************************
		let _incremento_psp  = _prima_neta1 - _prima_ap1 ;				
	
		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************
		if _prima_ap1 <> 0 then
			let _crecimiento = ((_prima_neta1 - _prima_ap1) / _prima_ap1) * 100;
		end if
	
		if _crecimiento = 0 then
			let _crecimiento = 100;
		end if
		
		--************************************************
		--    Calculos % de siniestralidad 2008	
		--************************************************
		let _siniestralidad = 0;
		if _prima_neta1 <> 0 then
			let _siniestralidad = (_sini_g / _prima_neta1) * 100;
 		end if							


	RETURN v_nombre_cia,
	       v_nombre_agt,
		   _nombre_tipo,
		   _siniestralidad,
		   _crecimiento,
		   _sini_g,
		   _prima_ap1,
		   _prima_neta1,
		   _comision1,
		   _porcentaje,
		   s_aplica,
		   n_aplica
		   WITH RESUME;	
	
END FOREACH

END PROCEDURE;  
