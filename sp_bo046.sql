-- Procedimiento que carga el Reporte de Indicadores para Multinacional
-- 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo046;		

create procedure "informix".sp_bo046()
returning char(20),
		  date,
		  date,
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _emi_periodo		char(7);
define _cob_periodo		char(7);

define _per_ini_aa		char(7);
define _per_fin_aa		char(7);
define _per_ini_ap		char(7);
define _per_fin_ap		char(7);
define _per_fin_dic		char(7);
define _ano				integer;
define _mes_evaluar		smallint;

define _fecha_ini_ap	date;
define _fecha_fin_ap	date;
define _fecha_ini_aa	date;
define _fecha_fin_aa	date;

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_reclamo		char(10);
define _no_requis		char(10);
define _monto			dec(16,2);
define _pos_ramo		smallint;
define _cod_ramo		char(3);
define _cod_tipoprod	char(3);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur	char(3);

define _pri_cob_ap		dec(16,2);
define _pri_cob_aa		dec(16,2);
define _pri_dev_ap		dec(16,2);
define _pri_dev_aa		dec(16,2);
define _pri_sus_ap		dec(16,2);
define _pri_sus_aa		dec(16,2);

define _vigen_ini		date;
define _vigen_fin		date;
define _fecha_pago		date;
define _fecha_dic_ap	date;
define _fecha_hoy		date;
define _factor_vig		dec(16,2);
define _dias1			integer;
define _dias2			integer;

define _nueva_renov		char(1);
define _cant_nueva		smallint;
define _cant_renov		smallint;

define _no_pol_ren_ap	integer;
define _no_pol_nue_ap	integer;
define _no_pol_tot_ap	integer;
define _no_pol_ren_aa	integer;
define _no_pol_nue_aa	integer;
define _no_pol_tot_aa	integer;

define _ano_ant			integer;
define _vigencia_ant	date;
define _vigencia_act	date;

define _com_pag_ap		dec(16,2);
define _com_pag_aa		dec(16,2);
define _monto_che		dec(16,2);

define _sin_ocu_ap		integer;
define _sin_ocu_aa		integer;
define _sin_pag_ap		dec(16,2);
define _sin_pag_aa		dec(16,2);
define _sin_pen_ap		dec(16,2);
define _sin_pen_aa		dec(16,2);
define _sin_pen_dic		dec(16,2);
define _sin_pen_12avos	dec(16,2);

define _filtros			char(255);

set isolation to dirty read;

-- Definiciones Iniciales

-- Periodos de Comparacion

select emi_periodo,
       cob_periodo,
	   par_ase_lider
  into _emi_periodo,
       _cob_periodo,
	   _cod_coasegur
  from parparam;

-- Año Actual

if _emi_periodo <= _cob_periodo then
	let _per_fin_aa	= _emi_periodo;
else
	let _per_fin_aa	= _cob_periodo;
end if
	 
let _per_fin_aa = "2008-01";

let _ano          = _per_fin_aa[1,4];
let _per_ini_aa   = _ano || "-01";

let _fecha_ini_aa = MDY(1, 1, _ano);
let _fecha_fin_aa = sp_sis36(_per_fin_aa);

let _mes_evaluar  = _per_fin_aa[6,7];

let _fecha_hoy    = sp_sis36(_per_fin_aa);

if _fecha_hoy > today then
	let _fecha_hoy = today;
end if

-- Año Pasado

let _ano = _ano - 1;

let _per_fin_ap   = _ano || _per_fin_aa[5,7];
let _per_ini_ap   = _ano || "-01";

let _fecha_dic_ap = MDY(12, 31, _ano);
let _per_fin_dic  = _ano || "-12";

let _fecha_ini_ap = MDY(1, 1, _ano);
let _fecha_fin_ap = sp_sis36(_per_fin_ap);

-- Primas Devengadas Año Pasado
{
foreach
 select doc_remesa,
        prima_neta,
		fecha
   into _no_documento,
   		_monto,
		_fecha_pago
   from cobredet
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_dic
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	and doc_remesa[1,2]  = "01"
	and doc_remesa  = "0193-0364-01"

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
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

	if _vigen_fin < _fecha_dic_ap then
							    
		let _pri_dev_aa = 0.00;
		let _factor_vig = 0;
		let _pri_dev_ap = _monto;

	elif _fecha_hoy >= _vigen_fin then

		let _dias1      = _vigen_fin    - _vigen_ini;
		let _dias2      = _fecha_dic_ap - _vigen_ini;
		let _factor_vig = _dias2 / _dias1;

		let _pri_dev_ap = _monto * _factor_vig;
		let _pri_dev_aa = _monto - _pri_dev_ap;

	elif _fecha_hoy < _vigen_fin then

		let _dias1      = _vigen_fin    - _vigen_ini;
		let _dias2      = _fecha_dic_ap - _vigen_ini;
		let _factor_vig = _dias2 / _dias1;

		let _pri_dev_ap = _monto * _factor_vig;

		let _dias1      = _vigen_fin - _vigen_ini;
		let _dias2      = _fecha_hoy - _vigen_ini;
		let _factor_vig = _dias2 / _dias1;

		let _pri_dev_aa = _monto * _factor_vig;
		let _pri_dev_aa = _pri_dev_aa - _pri_dev_ap;

	end if

	return _no_documento,
	       _fecha_pago,
		   _vigen_ini,
		   _vigen_fin,
		   _monto,
		   _pri_dev_ap,
		   _pri_dev_aa,
		   _factor_vig,
		   (_monto - _pri_dev_ap - _pri_dev_aa)
		   with resume;

end foreach
--}

-- Cobros de este Año
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha
   into _no_documento,
   		_monto,
		_fecha_pago
   from cobredet
  where periodo     >= _per_ini_aa
    and periodo     <= _per_fin_aa
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	and doc_remesa[1,2]  = "18"
--	and doc_remesa  = "0193-0364-01"
	
	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
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

	if _vigen_fin is null then
		let _vigen_fin = _fecha_pago; 
	end if

	if _vigen_ini is null then
		let _vigen_ini = _fecha_pago; 
	end if

	if _fecha_hoy >= _vigen_fin then

		let _factor_vig = 1;

	elif _fecha_hoy <= _vigen_ini then

		let _factor_vig = 0;

	else

		let _dias1      = _vigen_fin - _vigen_ini;
		let _dias2      = _fecha_hoy - _vigen_ini;
		let _factor_vig = _dias2 / _dias1;

	end if

	let _pri_dev_aa = _monto * _factor_vig;
	let _pri_dev_ap = 0.00;

	return _no_documento,
	       _fecha_pago,
		   _vigen_ini,
		   _vigen_fin,
		   _monto,
		   _pri_dev_ap,
		   _pri_dev_aa,
		   _factor_vig,
		   (_monto - _pri_dev_ap - _pri_dev_aa)
		   with resume;

end foreach
--}

end procedure
