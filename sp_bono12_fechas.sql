--************************************************************************************************************
-- Procedimiento que genera la tabla con la información para el Bono de Productividad para Comercializacion
--************************************************************************************************************
--execute procedure sp_bono12('001','001')

drop procedure sp_bono12_fechas;
create procedure sp_bono12_fechas(a_compania char(3), a_sucursal char(3))
returning	date		as fecha_ini_ap,
			date	    as fecha_fin_ap,
			date        as fecha_ini_aa,
			date        as fecha_fin_aa;

define _filtros				varchar(255);
define _n_cliente			varchar(100);
define _nombre_vendedor		varchar(50);
define _nombre_ramo			varchar(50);
define _error_desc			varchar(50);
define _cedula_agt			varchar(30);
define _reemplaza_poliza	char(20); 
define _no_documento		char(20); 
define _cod_contratante		char(10);
define _no_reclamo			char(10);
define _no_poliza_r			char(10);
define _no_poliza			char(10);
define _emi_periodo			char(7);
define _per_fin_dic			char(7);
define _per_ini_ap			char(7);
define _per_fin_ap			char(7);
define _per_fin_aa			char(7);
define _per_ini				char(7);
define _periodo				char(7);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_vendedor		char(3);
define _cod_agencia			char(3);
define _cod_ramo			char(3);
define _estatus_licencia	char(1);
define _tipo_agente			char(1);
define _nueva_renov			char(1);
define _porc_coas_ancon		dec(5,2);
define _prima_suscrita_ap	dec(16,2);
define _siniestralidad		dec(16,2);
define _porc_coaseguro		dec(16,4);
define _prima_suscrita		dec(16,2);
define _prima_sus_pag		dec(16,2);
define _sin_pen_dic			dec(16,2);
define _pri_pag_ap			dec(16,2);
define _sin_pag_aa			dec(16,2);
define _sin_pen_aa			dec(16,2);
define _sini_incu			dec(16,2);
define _pri_pag				dec(16,2);
define _monto				dec(16,2);
define _cnt_somos			smallint;  
define _fronting			smallint;  
define _trimestre			smallint;  
define _dias				smallint;
define _flag				smallint;
define _anio				smallint;
define _mes					smallint;
define _ano					smallint;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;
define _no_pol_ren_ap		integer;
define _no_pol_nue_aa		integer;
define _no_pol_nue_ap		integer;
define _no_pol_ren_aa		integer;
define my_sessionid			integer;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_aa_ini		date;
define _fecha_ap_ini		date;
define _fecha_cierre		date;
define _fecha_fin_ap		date;
define _fecha_cobro			date;
define _fecha_aa			date;
define _fecha_ap			date;
define _fecha				date;
define _fecha_proceso		datetime year to fraction(5);


begin 

let _error          = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;

-- Periodo Actual
select par_ase_lider,
       par_periodo_act,
	   par_periodo_ant,
	   fecha_cierre
  into _cod_coasegur,
	   _per_fin_aa,
	   _emi_periodo,
	   _fecha_cierre
  from parparam;

--Para que tome en cuenta el periodo anterior mientras no se haya cerrado.
if (today - _fecha_cierre) > 1 then
	let _per_fin_aa = _per_fin_aa;
else
	let _per_fin_aa = _emi_periodo;
end if

--*****************************
-- Periodo Inicial del Bono
--*****************************
--let _per_fin_aa = '2019-06';

-- Periodo Final del Concurso
if _per_fin_aa > '2019-12' then
	let _per_fin_aa = '2019-12';
end if

select ano,
	   trimestre
  into _anio,
	   _trimestre
  from tribono 
 where _per_fin_aa in (periodo1,periodo2,periodo3);

select periodo1
  into _per_ini
  from tribono
 where ano       = _anio
   and trimestre = _trimestre;

let _fecha_fin_ap = sp_sis36(_per_ini);

-- Periodo Pasado
let _ano            = _per_ini[1,4];		  --2019
let _ano            = _ano - 1;				  --2018
let _per_ini_ap     = _ano || _per_ini[5,7];  --2018-04

let _ano            = _per_fin_aa[1,4];		     --2019
let _ano            = _ano - 1;				     --2018
let _per_fin_ap     = _ano || _per_fin_aa[5,7];  --2018-04

-- Diciembre
let _per_fin_dic    = _per_fin_ap[1,4] || '-12'; --2018-12

-- Fechas de los Periodos
let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);        --01/04/2019
let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);  --01/04/2018

let _fecha_aa     = sp_sis36(_per_fin_aa);  -- último día del periodo actual               --30/04/2019
let _fecha_ap     = sp_sis36(_per_fin_ap);  --último día del periodo final del año pasado  --30/04/2018

end
return _fecha_ap_ini,_fecha_ap,_fecha_aa_ini,_fecha_aa;
end procedure;