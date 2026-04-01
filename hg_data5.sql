-- execute procedure hg_data5("001","001")
DROP PROCEDURE hg_data5;
CREATE PROCEDURE hg_data5(
a_compania          CHAR(3),
a_sucursal          CHAR(3)
) RETURNING SMALLINT;
																					  
DEFINE _no_poliza       CHAR(10);													  
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
define _cnt             integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _error           smallint;
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define _prima_orig      DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
define _fecha_aa        date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;

define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

define _estatus_poliza		smallint;
define _pri_sus_pag_ap  	DEC(16,2);
define _pri_pag_ap      	DEC(16,2);
define _pri_can_ap      	DEC(16,2);
define _pri_dev_ap      	DEC(16,2);
define _monto_90_aa     	DEC(16,2);
define _monto_90_ap     	DEC(16,2);

define _ano					smallint;
define _ano_ant				smallint;

define _cod_agencia			char(3);
define _suc_promotoria		char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor		char(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define _tipo_persona		char(1);
define _nombre_tipo			char(15);
define _concurso			smallint;

define _porc_res_mat		dec(5,2);
define _agente_agrupado 	char(5);

define _cod_tipo        	char(3);
define _n_cod_tipo 	    	char(50);
define _pri_sus_pag     	dec(16,2);
define _valor_prima     	dec(16,2);
define _porcentaje      	dec(16,2);
define _prima_max       	dec(16,2);
define _pri_devengada   	dec(16,2);
define _unificar        	smallint;

define _pri_cob_dev     	dec(16,2);
define _pri_cob_dev_max 	dec(16,2);
define _pri_sus_dev     	dec(16,2);
define _pri_sus_dev_max 	dec(16,2);
define _pri_cob         	dec(16,2);
define _pri_cob_max     	dec(16,2);
define _valor_cob_dev 		dec(16,2);
define _valor_sus_dev 		dec(16,2);
define _valor_cob     		dec(16,2);
define _pri_sus_orig    	dec(16,2);
define _porc_res_xramo  	dec(16,2);
define _prima_suscrita_ap 	dec(16,2);
define _pri_cob_dev_ap    	dec(16,2);

define _pri_susc_dev_aa		dec(16,2);
define _pri_susc_dev_ap		dec(16,2);
define _pri_susc_aa	    	dec(16,2);
define _pri_susc_ap	    	dec(16,2);
define _aplica          	smallint;
define _porc_prima_dev_max	dec(16,2);
define _pri_dev_max_aa		dec(16,2);
define _pri_dev_max_ap		dec(16,2);
define _prim_suscrita_min 	dec(16,2);
define _crecimiento_min   	dec(16,2);

define _prima_beneficio 	dec(16,2);
define _prima_maxima    	dec(16,2);
define _bono            	dec(16,2);

-- SET DEBUG FILE TO "sp_aud21.trc";
-- TRACE ON;

-- Desactivado por Order de Demetrio, para que no afecte los calculos realizados. 
-- Return 0;

let _error          	 = 0;
let _prima_can      	 = 0;
let _pri_can        	 = 0;
let _siniestralidad 	 = 0;
let _sini_incu      	 = 0;
let _prima_sus_pag  	 = 0;
let _pri_dev        	 = 0;
let _cnt            	 = 0;
let _pri_pag        	 = 0;
let _sin_pen_dic    	 = 0;
let _sin_pen_aa     	 = 0;
let _sin_pag_aa     	 = 0;
let v_por_vencer    	 = 0;
let v_exigible	    	 = 0;
let v_corriente	    	 = 0;
let v_monto_30	    	 = 0;
let v_monto_60	    	 = 0;
let v_monto_90	    	 = 0;
let v_saldo         	 = 0;
let _cantidad       	 = 0;
let _prima_orig     	 = 0;

let _pri_sus_pag_ap    	 = 0;
let _prima_suscrita_ap 	 = 0;
let _monto_90_aa       	 = 0;
let _pri_can		   	 = 0;
let	_pri_dev		   	 = 0;
let _monto_90_ap       	 = 0;
let _pri_devengada     	 = 0;
let _pri_cob_dev       	 = 0;
let _pri_cob_dev_max   	 = 0;
let _pri_cob_max       	 = 0;
let _pri_cob           	 = 0;
let _pri_sus_dev       	 = 0;
let _pri_sus_dev_max   	 = 0;
let _pri_sus           	 = 0;
let _pri_sus_orig  	   	 = 0;
let _porc_res_xramo	   	 = 0;

let _pri_susc_dev_aa	 = 0;
let _pri_susc_dev_ap	 = 0;

--delete from rentabilidad1;
--delete from tmprenta;
--delete from tmp_che115;

select par_ase_lider,																					
       par_periodo_act  -- ult_per_renta																
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

if a_periodo > "2011-12" then
	let a_periodo = "2011-12";
end if

let _per_ini        = "2011-01";
let _per_ini_ap     = "2010-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2010-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
let _fecha_ap       = sp_sis36(_per_fin_ap);

--trace off;
SET ISOLATION TO DIRTY READ;
{
--**********************
-- Prima SUSCRITA  AA -- 
--**********************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between _per_ini and a_periodo	   
  group by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_tipoprod
	   into _cod_tipoprod
	   from emipomae
	  where no_poliza = _no_poliza;

     if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;		          
		end if

		let _prima_suscrita = _prima_suscrita * (_porc_coaseguro / 100);
					
	 end if	

	insert into tmp_che115(no_documento, pri_sus_pag, tipo)
	values (_no_documento, _prima_suscrita, 3);

end foreach

--*********************
-- Prima  SUSCRITA  AP --	  
--*********************

foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between _per_ini_ap and _per_fin_ap	  
  group by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_tipoprod
	   into _cod_tipoprod
	   from emipomae
	  where no_poliza = _no_poliza;

     if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;		          
		end if

		let _prima_suscrita = _prima_suscrita * (_porc_coaseguro / 100);
							
	 end if		

	insert into tmp_che115(no_documento, pri_sus_pag_ap, tipo)
	values (_no_documento, _prima_suscrita, 4);

end foreach

--*********************************
-- Siniestros Pagados Anno Actual -
--*********************************

call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	insert into tmp_che115(no_documento, sin_pag_aa, tipo)
	values (_no_documento, _sin_pag_aa, 5);

end foreach

drop table tmp_sinis;

--***********************************************
-- Siniestros Pendientes Diciembre Anno Pasado --
--***********************************************

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_dic
   from rectrmae 
  where cod_compania = a_compania
    and periodo      <= _per_fin_dic     
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);

	insert into tmp_che115(no_documento, sin_pen_ap, tipo)
	values (_no_documento, _sin_pen_dic, 6);

end foreach

--*************************************
-- Siniestros Pendientes Anno Actual --
--*************************************

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_aa
   from rectrmae 
  where cod_compania = a_compania
    and periodo      <= a_periodo
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);

	insert into tmp_che115(no_documento, sin_pen_aa, tipo)
	values (_no_documento, _sin_pen_aa, 7);

end foreach
}

--trace on;
let _pri_susc_aa	 = 0;
let _pri_susc_ap	 = 0;
let _pri_susc_dev_aa = 0;
let _pri_susc_dev_ap = 0;
let _pri_dev_max_aa	 = 0;
let _pri_dev_max_ap	 = 0;
foreach
 select no_documento,
		sum(sin_pen_aa),			--	 siniestros pend actual
		sum(sin_pen_ap),			--   siniestros pend a dic
		sum(sin_pag_aa),			--   siniestros pagados actual
		sum(pri_sus_pag),			--   prima Suscrita Actual
		sum(pri_sus_pag_ap)			--   prima Suscrita Anio Pasado
   into _no_documento,
	    _sin_pen_aa,
		_sin_pen_dic,
		_sin_pag_aa,
		_pri_susc_aa,
		_pri_susc_ap
   from tmp_che115
--   where no_documento = 'XX-XXXXX-XX'
  group by no_documento
  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_grupo, 
	        cod_ramo, 
	        cod_pagador, 
	        cod_contratante, 
	        cod_tipoprod,
			sucursal_origen,
			cod_subramo
	   into _cod_grupo,
	        _cod_ramo,
	        _cod_pagador,
	        _cod_contratante,
	        _cod_tipoprod,
			_cod_agencia,
			_cod_subramo
	   from emipomae
	  where no_poliza = _no_poliza;

	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo; 			

	 if _cod_grupo = "00000" then -- Excluir estado
		continue foreach;
	 end if  	

	 SELECT tipo_produccion
	   INTO _tipo_prod
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

	-- Excluir Reaseguro Asumido y Coas. Minoritario
	 if _tipo_prod = 4 or _tipo_prod = 3 then 		
	   continue foreach;
	 end if

	 select count(*)
	   into _cnt
	   from emifafac
	  where no_poliza = _no_poliza;

	 if _cnt > 0 then		-- Excluir Facultativos
		 continue foreach;
	 end if

	 select cedula
	   into _cedula_paga
	   from cliclien
	  where cod_cliente = _cod_pagador;

	 select cedula,
	        nombre
	   into _cedula_cont,
	        _n_cliente
	   from cliclien
	  where cod_cliente = _cod_contratante;

     let _flag = 0;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza

           let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if

		SELECT nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado
		  INTO _nombre,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then	-- Contra pagador
			    let _flag = 1;
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then	-- Contra Contratante
			    let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	-- Solo agentes
			    let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
			    let _flag = 1;
				exit foreach;
			END IF

			if _agente_agrupado = "01068" then -- Grupo FF Seguros
			    let _flag = 1;
				exit foreach;
			end if

			if _cod_agente = "00180" and  -- Tecnica de Seguros
			   _cod_ramo   = "016"	 and  -- Colectivo de vida
			   _cod_grupo  = "01016" then -- Grupo Suntracs
			    let _flag = 1;
				exit foreach;
			end if

			if _cod_agente  = "00035" and  -- Ducruet
			   _cod_agencia = "075"   and  -- Agencia Ducruet
			   _cod_ramo    = "020"   then -- Soda
			    let _flag = 1;
				exit foreach;

			   
			   if _cod_ramo = "001" then -- Incendio se excluye
				    let _flag = 1;
					exit foreach;
			   end if			   

			end if


	 end foreach

	 if _flag = 1 then
	 	continue foreach;
	 end if

	 --trace off;
	-- Morosidades Mayores a 90 Dias (No Se Incluyen)
	call sp_cob33(a_compania, a_sucursal, _no_documento, a_periodo, _fecha_aa)
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               v_saldo;   
	-- trace on;
	-- Siniestros Incurridos
			
	let _sini_incu = 0;
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if v_monto_90 > 0 then	 
		let _pri_susc_dev_aa = 0;
		let _pri_susc_aa   = 0;


	end if


	let _pri_susc_dev_aa	 = 0;
	let _pri_susc_dev_ap	 = 0;

	-- Prima Suscrita Devengada	Año Actual 2011
	let _porc_res_mat    = 100 - _porc_res_mat;
	let _pri_susc_dev_aa = _pri_susc_aa * _porc_res_mat / 100;

	if _pri_susc_aa is null then
		let _pri_susc_aa = 0;
	end if

	-- Prima Suscrita Devengada	Año Pasado 2010
	let _pri_susc_dev_ap = _pri_susc_ap * _porc_res_mat / 100;

	if _pri_susc_ap is null then
		let _pri_susc_ap = 0;
	end if

	select cod_tipo 
	  into _cod_tipo
	  from prdrentram 
	 where periodo  = a_periodo
	   and cod_ramo = _cod_ramo ;

		if _cod_tipo is null then
		   continue foreach;
		end if
   
	 foreach
	  SELECT cod_agente
	    INTO _cod_agente
	    FROM emipoagt
	   WHERE no_poliza = _no_poliza

           let _unificar = 0;	 -- 01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if
	
		SELECT nombre,
		       tipo_persona,
			   cod_vendedor
		  INTO _nombre,
		       _tipo_persona,
			   _cod_vendedor
	      FROM agtagent
		 WHERE cod_agente = _cod_agente;

		if _tipo_persona = "N" then
			let _nombre_tipo = "INDIVIDUALES";
		else
			let _nombre_tipo = "BROKERS";
		end if

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor ;

		-- Descripcion del Tipo de Categoria
		select trim(name_tipo),porc_prima_dev_max 
		  into _n_cod_tipo,_porc_prima_dev_max
		  from prdrenttipo
  	     where periodo  = a_periodo
	       and cod_tipo = _cod_tipo 
	       and activo   = 1 ;

		--************************************************
		--   Calculos para incremeto de PSP 2011 vs 2010
		--************************************************
		let _incremento_psp  = _pri_susc_aa - _pri_susc_ap ;				

		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************
		if _pri_susc_ap <> 0 then
			let _crecimiento = (_incremento_psp / _pri_susc_ap) * 100;
		else
			let _crecimiento = 100; 
		end if	
		--************************************************
		--    Calculos % de siniestralidad 
		--************************************************
		let _siniestralidad = 0;
		if _pri_susc_aa <> 0 then
			let _siniestralidad = (_sini_incu / _pri_susc_aa) * 100;
		else
			let _siniestralidad = 100;
		end if	

		let _pri_dev_max_aa	 = _pri_susc_dev_aa * (_porc_prima_dev_max/100);
		let _pri_dev_max_ap	 = _pri_susc_dev_ap * (_porc_prima_dev_max/100);

		let _aplica = 0;
		insert into rentabilidad1(
		periodo,   			
		cod_agente,     		
		no_documento,   		
		pri_susc_aa,  		
		pri_susc_ap,  		
		pri_susc_dev_aa,  	
		pri_susc_dev_ap,  	
		pri_dev_max_aa,
		pri_dev_max_ap,
		sini_inc,  			
		monto_90,     		
		n_agente, 			
		cod_contratante, 	
		n_cliente, 			
		cod_vendedor,    	
		nombre_vendedor, 	
		cod_ramo,    		
		nombre_ramo, 		
		tipo_agente, 		
		tipo,         		
		nombre_tipo,
		por_incremento, 		
		por_crecimiento, 	
		por_siniestro,
		aplica,
		beneficio,
		bono   	
		)
		values(
		a_periodo,
		_cod_agente, 
		_no_documento,
		_pri_susc_aa,  		
		_pri_susc_ap,  		
		_pri_susc_dev_aa,  	
		_pri_susc_dev_ap, 
		_pri_dev_max_aa,
		_pri_dev_max_ap,
		_sini_incu, 
		v_monto_90,
		_nombre,
		_cod_contratante, 
		_n_cliente, 
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_cod_tipo,
		_n_cod_tipo,
		_incremento_psp,
		_crecimiento,
		_siniestralidad,
		_aplica,
		0,
		0
		);
	 end foreach
end foreach	  

--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
foreach
	select tipo,
		   cod_agente,
		   sum(pri_susc_aa),		  
		   sum(pri_susc_ap),			  
		   sum(sini_inc),
		   sum(pri_susc_dev_aa),
		   sum(pri_susc_dev_ap),
		   sum(pri_dev_max_aa),
		   sum(pri_dev_max_ap)
	  into _cod_tipo,
		   _cod_agente,
		   _pri_susc_aa,
		   _pri_susc_ap,
		   _sini_incu,
		   _pri_susc_dev_aa, 
		   _pri_susc_dev_ap, 
		   _pri_dev_max_aa,
		   _pri_dev_max_ap
	  from rentabilidad1
	 where periodo    = a_periodo
	   and monto_90   = 0  --and tipo = 'X'
	 group by cod_agente,tipo
	 order by cod_agente,tipo

		--************************************************
		--   Calculos para incremeto de PS 2011 vs 2010
		--************************************************
		let _incremento_psp  = _pri_susc_aa - _pri_susc_ap ;				

		--************************************************
		--   Calculos % de crecimiento de PS
		--************************************************
		if _pri_susc_ap <> 0 then
	       let _crecimiento = (_incremento_psp / _pri_susc_ap) * 100;
	  else
	       let _crecimiento = 100; 
	   end if		

	   --************************************************
	   --    Calculos % de siniestralidad 
	   --************************************************
	   let _siniestralidad = 0;
	    if _pri_susc_aa <> 0 then
		   let _siniestralidad = (_sini_incu / _pri_susc_aa) * 100;
	  else
	   	   let _siniestralidad = 100;
	   end if	

	select prim_suscrita_min,
	       crecimiento_min,
		   porc_prima_dev_max
	  into _prim_suscrita_min,
		   _crecimiento_min,
		   _porc_prima_dev_max  
	  from prdrenttipo 
     where periodo  = a_periodo
       and cod_tipo = _cod_tipo 
       and activo   = 1 ;

		if _pri_susc_aa >= _prim_suscrita_min then

			if _crecimiento >= _crecimiento_min then

				   let _porcentaje = 0; 

				select beneficio 
				  into _porcentaje
				  from prdrenttsin
				 where periodo  = a_periodo
				   and cod_tipo = _cod_tipo
				   and round(_siniestralidad,0) between rango_inicial and rango_final;

					if _porcentaje is null then
					   let _porcentaje = 0; 
 				   end if

					if _porcentaje <> 0 then

					   let _prima_maxima = (_pri_dev_max_aa + _pri_dev_max_ap) ;
					   let _prima_beneficio = _pri_susc_aa * (_porcentaje/100);

					    if _prima_beneficio > _prima_maxima then
						    let _bono = _prima_maxima ;
					  else
						    let _bono = _prima_beneficio ;								
					    end if

					 update rentabilidad1
						set bono            = _bono,
						    beneficio       = _porcentaje,
						    aplica          = 1 
					  where periodo         = a_periodo
						and cod_agente      = _cod_agente
						and tipo            = _cod_tipo
						and monto_90        = 0
						and aplica          = 0;	
				   end if
		   end if
	   end if
end foreach	 

--drop table tmp_che115;
--drop table rentabilidad1;

return 0;

END PROCEDURE;
