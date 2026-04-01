-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/04/2015- Autor: Jaime Chevalier

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web32;		

create procedure "informix".sp_web32()
returning integer,
		  char(100);


define _no_documento	char(20);		  
define _filtros			char(255);	
define _no_poliza		char(10);  
define _periodo      	char(7);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _nombre_agente	char(50);
define _nombre_vendedor	char(50);
define _per_ini_aa		char(7);
define _per_fin_aa		char(7);
define _per_ini_ap		char(7);
define _per_fin_ap		char(7);
define _cob_periodo		char(7);
define _emi_periodo		char(7);
define _cod_agente		char(5);
define _no_pol_ren_ap_per integer;
define _no_pol_nue_ap_per integer;
define _no_pol_ren_aa_per integer;
define _ano             integer;
define _no_pol_ren_ap	integer;
define _no_pol_nue_ap	integer;
define _no_pol_tot_ap	integer;
define _no_pol_ren_aa	integer;
define _no_pol_nue_aa	integer;
define _no_pol_tot_aa	integer;
define _sin_ocu_ap		integer;
define _sin_ocu_aa		integer;
define _dife_no_pol     integer;
define _pri_sus_ap		decimal(16,2);
define _pri_sus_aa		decimal(16,2);
define _pri_cob_ap		decimal(16,2);
define _pri_cob_aa		decimal(16,2);
define _pri_dev_aa		decimal(16,2);
define _persis_divi     decimal(16,2);
define _pri_sus_ap1		decimal(16,0);
define _pri_sus_aa1		decimal(16,0);
define _pri_cob_ap1		decimal(16,0);
define _pri_cob_aa1		decimal(16,0);
define _pri_dev_aa1		decimal(16,0);
define _persi_por       decimal(16,2);
	
define _incu_bruto_aa   decimal(16,2);
define _incu_bruto_ap   decimal(16,2);
define _divi            decimal(16,2);
define _diferencia      decimal(16,2);
define _diferencia_cobra decimal(16,2);
define _dife            decimal(16,2); 
define _crecimiento     decimal(16,2);
define _var_pri_sus     decimal(16,2);
define _divi_cobra      decimal(16,2);
define _var_pri_cob     decimal(16,2);
define _sinises_aa      decimal(16,2);
define _sinises         decimal(16,2);
define _sinises_ap      decimal(16,2);
define _divi_pol        decimal(16,2);
define _var_no_pol      decimal(16,2);
define _persistencia	decimal(16,2);
define _sinises_div_aa  decimal(16,2);
define _sinises_div_ap  decimal(16,2);
define _fecha_hoy       date;
define _fecha_cierre	date;
define _sin_pag_aa      decimal(16,2);
define _sin_pen_aa     decimal(16,2);
define _sin_pen_dic     decimal(16,2);

create temp table tmp_reporte(
no_documento        char(20),
pri_cob_ap			dec(16,2) 	default 0,
pri_cob_aa			dec(16,2) 	default 0,
pri_dev_aa			dec(16,2) 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_nue_ap		integer		default 0,
no_pol_tot_ap		integer 	default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_tot_aa		integer 	default 0,
pri_sus_ap			dec(16,2) 	default 0,
pri_sus_aa			dec(16,2) 	default 0,
periodo             char(7),
no_pol_ren_ap_per	integer 	default 0,
no_pol_nue_ap_per   integer     default 0,
no_pol_ren_aa_per	integer 	default 0,
cod_ramo            char(3),
nombre_ramo         char(50),
cod_agente          char(5),
no_poliza           char(10),
sin_pag_aa          decimal(16,2),
sin_pen_aa         decimal(16,2),     
sin_pen_dic         decimal(16,2)
) with no log;

LET _fecha_hoy   = today;

SELECT par_periodo_ant,
	   par_periodo_act,
	   fecha_cierre
  INTO _emi_periodo,
       _cob_periodo,
	   _fecha_cierre
  FROM parparam;  

-- Año Actual

if (today - _fecha_cierre) > 1 then
	let _per_fin_aa	= _cob_periodo;
else
	let _per_fin_aa	= _emi_periodo;
end if

-- Año Actual
let _ano          = _per_fin_aa[1,4];
let _per_ini_aa   = _ano || "-01";

-- Año Pasado
let _ano = _ano - 1;

let _per_fin_ap   = _ano || _per_fin_aa[5,7];
let _per_ini_ap   = _ano || "-01";

FOREACH
	
	SELECT no_documento,
	       pri_cob_ap,
		   pri_cob_aa,
		   pri_dev_aa,
		   no_pol_ren_ap,
		   no_pol_nue_ap,
		   no_pol_tot_ap,
		   no_pol_ren_aa,
		   no_pol_nue_aa,
		   no_pol_tot_aa,
		   no_poliza,
		   pri_sus_ap,
		   pri_sus_aa,
		   periodo,
		   cod_ramo,
		   nombre_ramo,
		   no_pol_ren_ap_per,
		   no_pol_nue_ap_per,
		   no_pol_ren_aa_per,
		   sin_pag_aa,
		   sin_pen_aa,
		   sin_pen_dic
      INTO _no_documento,
	       _pri_cob_ap,
           _pri_cob_aa,
           _pri_dev_aa,
           _no_pol_ren_ap,
           _no_pol_nue_ap,
		   _no_pol_tot_ap,
		   _no_pol_ren_aa,
		   _no_pol_nue_aa,
		   _no_pol_tot_aa,
		   _no_poliza,
		   _pri_sus_ap,
		   _pri_sus_aa,
		   _periodo,
		   _cod_ramo,
		   _nombre_ramo,
		   _no_pol_ren_ap_per,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_aa_per,
		   _sin_pag_aa,
		   _sin_pen_aa,
		   _sin_pen_dic
    FROM deivid_bo:boindmul
	
	FOREACH
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by porc_partic_agt desc
		exit foreach;
	END FOREACH
	
		INSERT INTO tmp_reporte (
	    no_documento,
	    pri_cob_ap,			
		pri_cob_aa,			
		pri_dev_aa,			
		no_pol_ren_ap,		
		no_pol_nue_ap,		
		no_pol_tot_ap,		
		no_pol_ren_aa,		
		no_pol_nue_aa,		
		no_pol_tot_aa,		       	
		pri_sus_ap,			
		pri_sus_aa,		
		periodo,           
		no_pol_ren_ap_per,	
		no_pol_nue_ap_per,		
		no_pol_ren_aa_per,	
		cod_ramo,           
		nombre_ramo,
        cod_agente,
        sin_pag_aa,
		sin_pen_aa,
		sin_pen_dic        
		)values
		(
		_no_documento,
		_pri_cob_ap,
		_pri_cob_aa,
		_pri_dev_aa,
		_no_pol_ren_ap,
		_no_pol_nue_ap,
		_no_pol_tot_ap,
		_no_pol_ren_aa,
		_no_pol_nue_aa,
		_no_pol_tot_aa,
		_pri_sus_ap,
		_pri_sus_aa,
		_periodo,
		_no_pol_ren_ap_per,
		_no_pol_nue_ap_per,
		_no_pol_ren_aa_per,
		_cod_ramo,
		_nombre_ramo,
		_cod_agente,
		_sin_pag_aa,
		_sin_pen_aa,
		_sin_pen_dic
		);
	
END FOREACH
{
-- Siniestros Pagados Año Pasado
	--{
	CALL sp_rec01("001", "001", _per_ini_ap, _per_fin_ap) returning _filtros;
	
	FOREACH
	 SELECT doc_poliza,
	        cod_ramo,
	        cod_agente,
			incurrido_bruto
	   INTO _no_documento,
	        _cod_ramo,
	        _cod_agente,
			_incu_bruto_ap
	   FROM tmp_sinis
	   
	   INSERT INTO tmp_reporte(no_documento,cod_ramo,cod_agente,incu_bruto_ap)
	   VALUES (_no_documento,_cod_ramo,_cod_agente,_incu_bruto_ap);

	END FOREACH

	DROP TABLE tmp_sinis;
	--}
	
{	-- Siniestros Pagados Año Actual
	--{

	CALL sp_rec01("001", "001", _per_ini_aa, _per_fin_aa) returning _filtros;

	FOREACH
	 SELECT doc_poliza,
	        cod_ramo,
	        cod_agente,
			incurrido_bruto   
	   INTO _no_documento,
	        _cod_ramo,
	        _cod_agente,
			_incu_bruto_aa
	   FROM tmp_sinis
	   
	   INSERT INTO tmp_reporte(no_documento,cod_ramo,cod_agente,incu_bruto_aa)
	   VALUES (_no_documento,_cod_ramo,_cod_agente,_incu_bruto_aa);

	END FOREACH

	DROP TABLE tmp_sinis;
	--}


FOREACH

	SELECT sum(pri_cob_ap),
		   sum(pri_cob_aa),
		   sum(pri_dev_aa),
		   sum(no_pol_ren_ap),
		   sum(no_pol_nue_ap),
		   sum(no_pol_tot_ap),
		   sum(no_pol_ren_aa),
		   sum(no_pol_nue_aa),
		   sum(no_pol_tot_aa),
		   sum(pri_sus_ap),
		   sum(pri_sus_aa),
		   sum(no_pol_ren_ap_per),
		   sum(no_pol_nue_ap_per),
		   sum(no_pol_ren_aa_per),
		   cod_ramo,
		   cod_agente,
		   sum(sin_pag_aa),
		   sum(sin_pen_aa),
		   sum(sin_pen_dic)		   
      INTO _pri_cob_ap,
           _pri_cob_aa,
           _pri_dev_aa,
           _no_pol_ren_ap,
           _no_pol_nue_ap,
		   _no_pol_tot_ap,
		   _no_pol_ren_aa,
		   _no_pol_nue_aa,
		   _no_pol_tot_aa,
		   _pri_sus_ap,
		   _pri_sus_aa,
		   _no_pol_ren_ap_per,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_aa_per,
		   _cod_ramo,
		   _cod_agente,
		   _sin_pag_aa,
		   _sin_pen_aa,
		   _sin_pen_dic
    FROM tmp_reporte
	GROUP BY cod_ramo,cod_agente 
	ORDER BY cod_ramo,cod_agente
	 
	--Calculo la variacion de la prima suscrita 
	IF _pri_sus_ap = 0 THEN
	    let _var_pri_sus = 100;
	ELSE
		let _diferencia = _pri_sus_aa - _pri_sus_ap;
		let _divi = _diferencia / _pri_sus_ap;
		let _var_pri_sus = _divi * 100;
	END IF 

	--Calculo la variacion de la prima cobrada 
	IF _pri_cob_ap = 0 THEN
		let _var_pri_cob = 100;
	ELSE
		let _diferencia_cobra = _pri_cob_aa - _pri_cob_ap;
		let _divi_cobra = _diferencia_cobra / _pri_cob_ap;
		let _var_pri_cob = _divi_cobra * 100;
	END IF
	
	
	--Crecimiento en base a las primas
	IF _pri_sus_ap = 0 THEN 
		let _crecimiento = 100;
	ELSE
		let _dife = _pri_sus_aa - _pri_sus_ap;
		let _crecimiento = _dife / _pri_sus_ap;
	END IF
	
	--Calculo de la siniestralidad
	IF _pri_dev_aa = 0 THEN
		let _sinises_aa = 0;
	ELSE
		let _sinises = (_sin_pag_aa + _sin_pen_aa) - _sin_pen_dic;
		let _sinises_aa = _sinises / _pri_dev_aa; 
	END IF
	
	--Variacion del numero de polizas nuevas 
	IF _no_pol_nue_ap = 0 THEN
		let _var_no_pol = 100;
	ELSE
		let _dife_no_pol = _no_pol_nue_aa - _no_pol_nue_ap;
		let _divi_pol = _dife_no_pol / _no_pol_nue_ap;
		let _var_no_pol = _divi_pol * 100;
	END IF
	
	--Calculo de la persistencia
	let _persis_divi = _no_pol_ren_ap_per + _no_pol_nue_ap_per;
	IF _persis_divi <> 0 THEN
		let _persi_por =  _no_pol_ren_aa_per / _persis_divi;
		let _persistencia =  _persi_por * 100;
	END IF
	
	let _pri_sus_ap1 = _pri_sus_ap;		
	let _pri_sus_aa1 = _pri_sus_aa;	
	let _pri_cob_ap1 = _pri_cob_ap;		
	let _pri_cob_aa1 = _pri_cob_aa;		
	let _pri_dev_aa1 = _pri_dev_aa;		
	

	INSERT INTO deivid_bo:bobitaind(
	    no_documento,
		pri_cob_ap,
		pri_cob_aa,
		pri_dev_aa,
		no_pol_ren_ap,
		no_pol_nue_ap,
		no_pol_tot_ap,
		no_pol_ren_aa,
		no_pol_nue_aa,
		no_pol_tot_aa,
		persistencia,
		var_no_pol,
		pri_sus_ap,
		pri_sus_aa,
		periodo,
		cod_ramo,
		nombre_ramo,
		no_pol_ren_ap_per,
		no_pol_nue_ap_per,
		no_pol_ren_aa_per,
		cod_agente,
		fecha,
		siniestralidad_aa,
		var_pri_sus,
		var_pri_cob,
		siniestralidad_ap,
		crecimiento,
		inc_bruto_aa,
		inc_bruto_ap,
		sin_pag_aa,
		sin_pen_aa,
		sin_pen_dic
	)VALUES(
	    '',
		_pri_cob_ap1,
		_pri_cob_aa1,
		_pri_dev_aa1,
		_no_pol_ren_ap,
	    _no_pol_nue_ap,
	    _no_pol_tot_ap,
	    _no_pol_ren_aa,
	    _no_pol_nue_aa,
	    _no_pol_tot_aa,
		_persistencia,
		_var_no_pol,
		_pri_sus_ap1,
		_pri_sus_aa1,
		'',
		_cod_ramo,
		'',
		_no_pol_ren_ap_per,
		_no_pol_nue_ap_per,
		_no_pol_ren_aa_per,
		_cod_agente,
		_fecha_hoy,
		_sinises_aa,
		_var_pri_sus,
		_var_pri_cob,
		0,
		_crecimiento,
		'',
		'',
		_sin_pag_aa,
		_sin_pen_aa,
		_sin_pen_dic
	);
    	

END FOREACH

DROP TABLE tmp_reporte;
return 0, "Actualizacion Exitosa";

END PROCEDURE
