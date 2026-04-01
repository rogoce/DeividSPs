--Procedimiento para realizar la carga en Rentabilidad2 para BONO DE RENTABILIDAD OPCION2
--Creado 25/01/2016	Armando Moreno M.  

DROP PROCEDURE sp_carga_rentabilidad2;
CREATE PROCEDURE sp_carga_rentabilidad2(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

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
define _fec_aa_ini   	date;
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
define _pri_sus_aa_tmp		dec(16,2);
define _pri_sus_ap_tmp		dec(16,2);
define _monto_dev			dec(16,2);
define _no_remesa			char(10);
define _fronting,_pagado	smallint;
define _fecha_anulado       date;
define _error_desc          char(50);
define _pri_dev_aa          dec(16,2);
define _pri_dev_aa_tmp      dec(16,2);

-- return 0; --se detuvo la corrida

--SET DEBUG FILE TO "sp_che115_carga.trc";
--TRACE ON;

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
let _porc_coaseguro      = 0;

let _pri_susc_dev_aa	 = 0;
let _pri_susc_dev_ap	 = 0;
let _porc_partic         = 0;
let _pri_sus_aa_tmp	 = 0;
let _pri_sus_ap_tmp	 = 0;
let _pri_dev_aa      = 0;
let _pri_dev_aa_tmp  = 0;

select par_ase_lider,
       par_periodo_act  -- ult_per_renta
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania; 

if a_periodo > "2012-12" then
	let a_periodo = "2016-12";
end if

delete from rentabilidad2 where periodo = a_periodo;

select par_periodo_ant
  into a_periodo
  from parparam
 where cod_compania = a_compania;

let a_periodo   = '2016-12';  --****PONER COMENTARIO CUANDO CORRE ANUAL

update parparam
   set ult_per_fidel = a_periodo;
   
--update parparam
   --set agt_per_fidel = a_periodo;

let _fec_aa_ini     = "01/01/2016";	--para sacar cancelada o anulada en el periodo
let _per_ini        = "2016-01";
let _per_ini_ap     = "2015-01";
let _ano            = a_periodo[1,4];  --2016
let _ano            = _ano - 1;		   --2015
let _per_fin_ap     = _ano || a_periodo[5,7]; --2014-12

let _per_fin_dic    = "2015-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);    --31/01/2016	 
let _fecha_aa       = sp_sis36(a_periodo);	 --31/01/2016 
let _fecha_ap_ini   = sp_sis36(_per_ini_ap); --31/01/2015 
let _fecha_ap       = sp_sis36(_per_fin_ap); --31/01/2015

create temp table tmp_che115a(
no_documento 	  CHAR(20), 
pri_sus_pag   	  DECIMAL(16,2) DEFAULT 0,
pri_pag  		  DECIMAL(16,2) DEFAULT 0,
pri_can  		  DECIMAL(16,2) DEFAULT 0,
pri_dev  		  DECIMAL(16,2) DEFAULT 0,
sin_pag_aa 		  DECIMAL(16,2) DEFAULT 0, 
sin_pen_aa 		  DECIMAL(16,2) DEFAULT 0, 
sin_pen_ap 		  DECIMAL(16,2) DEFAULT 0, 
no_pol_ren_aa 	  INTEGER DEFAULT 0, 
no_pol_ren_ap 	  INTEGER DEFAULT 0, 
no_pol_nue_aa 	  INTEGER DEFAULT 0, 
no_pol_nue_ap 	  INTEGER DEFAULT 0, 
no_pol_nue_ap_per INTEGER DEFAULT 0, 
pri_sus_pag_ap    DECIMAL(16,2) DEFAULT 0, 
pri_pag_ap  	  DECIMAL(16,2) DEFAULT 0,
pri_can_ap  	  DECIMAL(16,2) DEFAULT 0,
pri_dev_ap  	  DECIMAL(16,2) DEFAULT 0,
no_pol_ren_aa_per INTEGER DEFAULT 0, 
no_pol_ren_ap_per INTEGER DEFAULT 0, 
tipo              INTEGER DEFAULT 0) with no log;

create index idx_tmp_che115a1 on tmp_che115a(no_documento);

SET ISOLATION TO DIRTY READ;

--**********************************************************************************************
-- Prima Pagada Este Anno 
--**********************************************************************************************
foreach with hold
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     >= _per_ini
    and periodo     <= a_periodo
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_formapag,
		   cod_ramo,
		   estatus_poliza,
		   fronting,
		   cod_subramo
	  into _cod_tipoprod,
	       _cod_formapag,
		   _cod_ramo,
		   _estatus_poliza,
		   _fronting,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo in('008','019','018') then	--SE EXCLUYE RAMO DE FIANZAS, VIDA IND., SALUD
		continue foreach;
	elif _cod_ramo in('002','003','004','005','006','009','010','011','013','014','015','017','016','020','022') then
		if _cod_ramo = '015' AND _cod_subramo = '006' then  -- SE EXCLUYE ARTICULOS VALIOSOS
			continue foreach;
		end if
	end if
	if _fronting = 1 then 	--SE EXCLUYE FRONTING
		continue foreach;
	end if

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then		--SE EXCLUYE FACULTATIVOS
		continue foreach;
	end if	
	 
	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;		          
		end if

		let _monto = _monto * (_porc_coaseguro / 100);
	end if

	-- devoluciones de prima
	foreach
			SELECT monto,
			       no_requis
			  into _monto_dev, 
			       _no_requis
			  FROM chqchpol
             WHERE no_poliza = _no_poliza
			 
			SELECT pagado,
				   fecha_anulado
			  INTO _pagado,
				   _fecha_anulado
			  FROM chqchmae
			 WHERE no_requis = _no_requis
			   and fecha_impresion between '01/01/2016' and '31/12/2016';
			IF _pagado = 1 THEN
				IF _fecha_anulado IS NOT NULL THEN
					IF _fecha_anulado >= '01/01/2016' and _fecha_anulado <= '31/01/2016' THEN
						LET _monto_dev = 0;
					END IF
				END IF			
			ELSE
				LET _monto_dev = 0;
			END IF	
	
			IF _monto_dev IS NULL THEN
				LET _monto_dev = 0;
			END IF
			let _monto = _monto - _monto_dev;
	end foreach	

	if _cod_ramo = '001' then
		let _monto = _monto * 0.70;
	end if

	begin work;
	
	insert into tmp_che115a(no_documento, pri_sus_pag)
	values (_no_documento, _monto);

	commit work;
end foreach
--**********************************************************************************************
-- Prima Pagada Anno Pasado
--**********************************************************************************************
foreach with hold
 select doc_remesa,
        prima_neta,
		fecha,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon
   from cobredet
  where periodo     >= _per_ini_ap		
    and periodo     <= _per_fin_ap		
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_formapag,
		   cod_ramo,
		   estatus_poliza,
		   fronting,
		   cod_subramo
	  into _cod_tipoprod,
	       _cod_formapag,
		   _cod_ramo,
		   _estatus_poliza,
		   _fronting,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo in('008','019','018') then	--SE EXCLUYE RAMO DE FIANZAS, VIDA IND., SALUD
		continue foreach;
	elif _cod_ramo in('002','003','004','005','006','009','010','011','013','014','015','017','016','020','022') then
		if _cod_ramo = '015' AND _cod_subramo = '006' then  -- SE EXCLUYE ARTICULOS VALIOSOS
			continue foreach;
		end if
	end if
	if _fronting = 1 then 	--SE EXCLUYE FRONTING
		continue foreach;
	end if

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then		--SE EXCLUYE FACULTATIVOS
		continue foreach;
	end if	 

	if _cod_tipoprod = "001" then
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;
				  
		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _monto = _monto * (_porc_coaseguro / 100);
	end if
	-- devoluciones de prima
	foreach
			SELECT monto,
			       no_requis
			  into _monto_dev, 
			       _no_requis
			  FROM chqchpol
             WHERE no_poliza = _no_poliza
			 
			SELECT pagado,
				   fecha_anulado
			  INTO _pagado,
				   _fecha_anulado
			  FROM chqchmae
			 WHERE no_requis = _no_requis
			   and fecha_impresion between '01/01/2015' and '31/12/2015';
			IF _pagado = 1 THEN
				IF _fecha_anulado IS NOT NULL THEN
					IF _fecha_anulado >= '01/01/2015' and _fecha_anulado <= '31/12/2015' THEN
						LET _monto_dev = 0;
					END IF
				END IF			
			ELSE
				LET _monto_dev = 0;
			END IF	
	
			IF _monto_dev IS NULL THEN
				LET _monto_dev = 0;
			END IF
			let _monto = _monto - _monto_dev;
	end foreach	
	--fin de devoluciones de primas	
	if _cod_ramo = '001' then
		let _monto = _monto * 0.70;
	end if

	begin work;	
		insert into tmp_che115a(no_documento, pri_sus_pag_ap)
		values (_no_documento, _monto);

	commit work;
end foreach

--**********************************
-- Siniestros Pagados Anno Actual --
--**********************************

call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach	with hold

 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

  begin work;
	insert into tmp_che115a(no_documento, sin_pag_aa)
	values (_no_documento, _sin_pag_aa);
  commit work;
end foreach

drop table tmp_sinis;

--***********************************************
-- Siniestros Pendientes Diciembre Anno Pasado --
--***********************************************

foreach	with hold
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

   begin work;
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

	insert into tmp_che115a(no_documento, sin_pen_ap)
	values (_no_documento, _sin_pen_dic);
	commit work;
end foreach

--TRACE Off;
--*************************************
-- Siniestros Pendientes Anno Actual --
--*************************************

foreach	with hold
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

  begin work;
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

	insert into tmp_che115a(no_documento, sin_pen_aa)
	values (_no_documento, _sin_pen_aa);
	
	commit work;
end foreach

--********************************************
--********************************************
--********************************************
let _pri_susc_aa	 = 0;
let _pri_susc_ap	 = 0;
let _pri_susc_dev_aa = 0;
let _pri_susc_dev_ap = 0;
let _pri_dev_max_aa	 = 0;
let _pri_dev_max_ap	 = 0;
let _pri_dev_aa_tmp  = 0;
--trace on;
--CALCULAR LA PRIMA COBRADA DEVENGADA
call sp_dev05(_fec_aa_ini, _fecha_aa) returning _error, _error_desc;
--trace off;
foreach
 select no_documento,
		sum(prima_devengada)
   into _no_documento,
		_pri_dev_aa
   from tmp_pri_cob_dev
  group by no_documento
  
	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_formapag,
		   cod_ramo,
		   estatus_poliza,
		   fronting,
		   cod_subramo
	  into _cod_tipoprod,
	       _cod_formapag,
		   _cod_ramo,
		   _estatus_poliza,
		   _fronting,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo in('008','019','018') then	--SE EXCLUYE RAMO DE FIANZAS, VIDA IND., SALUD
		continue foreach;
	elif _cod_ramo in('002','003','004','005','006','009','010','011','013','014','015','017','016','020','022') then
		if _cod_ramo = '015' AND _cod_subramo = '006' then  -- SE EXCLUYE ARTICULOS VALIOSOS
			continue foreach;
		end if
	end if
	if _fronting = 1 then 	--SE EXCLUYE FRONTING
		continue foreach;
	end if

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then		--SE EXCLUYE FACULTATIVOS
		continue foreach;
	end if	 

	insert into tmp_che115a(no_documento, pri_dev)
	values (_no_documento, _pri_dev_aa);		

end foreach

drop table tmp_pri_cob_dev;

--SET DEBUG FILE TO "sp_che115_carga.trc";
--TRACE ON;
foreach
	 select no_documento,
			sum(sin_pen_aa),			--   siniestros pend actual
			sum(sin_pen_ap),			--   siniestros pend a dic
			sum(sin_pag_aa),			--   siniestros pagados actual
			sum(pri_sus_pag),			--   prima cobrada Año Actual
			sum(pri_sus_pag_ap),		--   prima cobrada Año Pasado
			sum(pri_dev)
	   into _no_documento,
		    _sin_pen_aa,
			_sin_pen_dic,
			_sin_pag_aa,
			_pri_susc_aa,
			_pri_susc_ap,
			_pri_dev_aa
	   from tmp_che115a
	  group by no_documento
	  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_grupo, 
	        cod_ramo, 
	        cod_pagador, 
	        cod_contratante, 
	        cod_tipoprod,
			sucursal_origen,
			cod_subramo,
			fronting
	   into _cod_grupo,
	        _cod_ramo,
	        _cod_pagador,
	        _cod_contratante,
	        _cod_tipoprod,
			_cod_agencia,
			_cod_subramo,
			_fronting
	   from emipomae
	  where no_poliza = _no_poliza;

	if _cod_ramo in('008','019','018') then	--SE EXCLUYE RAMO DE FIANZAS, VIDA IND., SALUD
		continue foreach;
	elif _cod_ramo in('002','003','004','005','006','009','010','011','013','014','015','017','016','020','022') then
		if _cod_ramo = '015' AND _cod_subramo = '006' then  -- SE EXCLUYE ARTICULOS VALIOSOS
			continue foreach;
		end if
	elif _cod_ramo = '001' then
		let _pri_dev_aa = _pri_dev_aa * 0.70;
	end if
	if _fronting = 1 then 	--SE EXCLUYE FRONTING
		continue foreach;
	end if
	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then		--SE EXCLUYE FACULTATIVOS
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

	select cedula,
	       nombre
	  into _cedula_cont,
	       _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

    select count(*)
      into _cnt
      from endedmae
     where no_poliza     = _no_poliza
	   and actualizado   = 1
       and cod_endomov in ('003','002','012')  	--rehabilitada o cancelada o cambio de corredor en el periodo del concurso no va
       and fecha_emision >= _fec_aa_ini
       and fecha_emision <= _fecha_aa;

    let _flag = 0;
		-- Siniestros Incurridos

	let _sini_incu = 0;
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

   	let a_periodo = '2016-12';

	foreach			   --PRIMER EMIPOAGT 

		select cod_agente,
		       porc_partic_agt
		  into _cod_agente,
		       _porc_partic
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		-- Unificar todos los KAM
		-- Se separa la unificacion por orden de leticia segun correo 12/04/2013, indica que se unen al final
		if _cod_agente IN ("02375","02378","02377","02293","02376","02360","00133","01746","01749","01852","02004","02075","02124") then  
			let _cod_agente = "00218";													
		end if
		if _cod_agente IN ("02154") then	--DUCRUET
			let _cod_agente = "00035";													
		end if
		if _cod_agente IN ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201","02349","02252","02448","02253","02393") then	--DOULOS
			let _cod_agente = "01048";													
		end if
		if _cod_agente IN ("00961","00235","00705","02155") then  --AFTA
			let _cod_agente = "01266";													
		end if
		SELECT count(*) 
		  INTO _unificar 
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente 
		   AND bono_rent2 = 1;  

		if _unificar > 0 then  -- CORREDOR PARTICIPA PARA ESTE BONO 
		else 
			let _flag = 1; 
	    end if 

		SELECT nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado,
   		       tipo_persona,
			   cod_vendedor
		  INTO _nombre, 
		       _tipo_pago,
		       _tipo_agente, 
			   _estatus_licencia,  
			   _cedula_agt, 
			   _agente_agrupado, 
			   _tipo_persona, 
			   _cod_vendedor 
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente; 

		IF _tipo_agente <> "A" then	-- Solo agentes 
			let _flag = 3; 
		END IF 

		{IF _estatus_licencia <> "A" then  -- El corredor debe estar activo 
			let _flag = 4; 
		END IF}

		if _flag in(1,3) then
			continue foreach;
		end if
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

		--************************************************
		--   Calculos para incremeto de PSP 2016 vs 2015
		--************************************************
		let _pri_sus_aa_tmp = 0;
		let _pri_sus_ap_tmp = 0;		
		let _pri_sus_aa_tmp = _pri_susc_aa * (_porc_partic / 100);
		let _pri_sus_ap_tmp = _pri_susc_ap * (_porc_partic / 100);
		let _pri_dev_aa_tmp = _pri_dev_aa * (_porc_partic / 100);
		let _incremento_psp = _pri_sus_aa_tmp - _pri_sus_ap_tmp;
		
		--************************************************  
		--   Calculos % de crecimiento de PSP
		--************************************************  

		if _pri_sus_ap_tmp <> 0 And _pri_sus_ap_tmp is not null then
			let _crecimiento = (_incremento_psp / _pri_sus_ap_tmp) * 100;
		else
			let _crecimiento = 100; 
		end if
		
		--************************************************
		--    Calculos % de siniestralidad 
		--************************************************
		let _siniestralidad = 0;
		let _aplica = 0;
		let _cod_tipo = '000';
		let _n_cod_tipo = '';
		insert into rentabilidad2(
		periodo,   			
		cod_agente,     		
		no_documento,   		
		pri_susc_aa,  		
		pri_susc_ap,  		
		pri_susc_dev_aa,  	
		pri_susc_dev_ap,  	
		pri_dev_max_aa,	--prima cobrada devengada
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
		bono,
		sin_pag_aa,
		sin_pen_aa,
		sin_pen_dic   	
		)
		values(
		a_periodo,
		_cod_agente, 
		_no_documento,
		_pri_sus_aa_tmp,  		
		_pri_sus_ap_tmp,  		
		_pri_susc_dev_aa,  	
		_pri_susc_dev_ap, 
		_pri_dev_aa_tmp,
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
		0,
		_sin_pag_aa,
		_sin_pen_aa,
		_sin_pen_dic
		);
	end foreach
end foreach

let _bono = 0;
foreach
	select cod_agente,
		   sum(pri_susc_aa),		  
		   sum(por_crecimiento),			  
		   sum(sini_inc),
		   sum(pri_dev_max_aa)
	  into _cod_agente,
		   _pri_susc_aa,
		   _crecimiento,
		   _sini_incu,
		   _pri_dev_max_aa
	  from rentabilidad2
	 where periodo    = a_periodo
	 group by cod_agente
	 order by cod_agente

		if _pri_susc_aa >= 50000 And _crecimiento >= 10 then

			let _porcentaje = 0; 
			let _bono = 0.15 * ((_pri_dev_max_aa * 0.55) - _sini_incu);
			
			update rentabilidad2
			   set bono       = _bono,
				   beneficio  = _porcentaje,
				   aplica     = 1 
			 where periodo    = a_periodo
			   and cod_agente = _cod_agente;	
								
	    end if
end foreach	  

drop table tmp_che115a;

return 0;

END PROCEDURE                                                                                                                                                                                                 
