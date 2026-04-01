-- Procedure que recuerda que no se ha cerrado un mes de contabilidad

-- Creado    : 01/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac39;

create procedure "informix".sp_sac39()
returning integer,
          char(7),
          char(50);

define _emi_periodo		char(7);
define _cob_periodo		char(7);
define _sac_periodo		char(7);
define _may_periodo		char(7);
define _sac_mes			char(2);
define _sac_ano			char(4);
define _dias			smallint;
define _fecha_cierre	date;
define _nombre_cia		char(50);
define _dias_control	smallint;
define _mes_int			smallint;

--set debug file to "sp_sac39.trc";
--trace on;

set isolation to dirty read;

let _dias_control = 30;

select par_periodo_act
  into _may_periodo
  from parparam;

-- sac

let _nombre_cia = "ASEGURADORA ANCON, S. A.";

select par_mesfiscal,
	   par_anofiscal
  into _mes_int,
       _sac_ano
  from sac:cglparam;

if _mes_int < 10 then
	let _sac_mes = "0" || _mes_int;
else
	let _sac_mes = _mes_int;
end if 

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	if _sac_mes in('13','14') then
		let _dias_control = 31;
	else
		let _fecha_cierre = sp_sis36(_sac_periodo);
		let _dias = today - _fecha_cierre;
	end if	

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

-- sac001

let _nombre_cia = "ALLIED INSURANCE AND REINSURANCE CO.,LTD";

select par_mesfiscal,
	   par_anofiscal
  into _mes_int,
       _sac_ano
  from sac001:cglparam;

if _mes_int < 10 then
	let _sac_mes = "0" || _mes_int;
else
	let _sac_mes = _mes_int;
end if 

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	
    if _sac_mes in('13','14') then
		let _dias_control = 31;
	else
		let _fecha_cierre = sp_sis36(_sac_periodo);
		let _dias = today - _fecha_cierre;
	end if	

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

-- sac002

let _nombre_cia = "ANCON INVESTMENT CORPORATION";

select par_mesfiscal,
	   par_anofiscal
  into _mes_int,
       _sac_ano
  from sac002:cglparam;

if _mes_int < 10 then
	let _sac_mes = "0" || _mes_int;
else
	let _sac_mes = _mes_int;
end if 

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	if _sac_mes in('13','14') then
		let _dias_control = 31;
	else
		let _fecha_cierre = sp_sis36(_sac_periodo);
		let _dias = today - _fecha_cierre;
	end if	

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

-- sac006

let _nombre_cia = "PROMOTORA TORRE ASEGURADORA ANCON";

select par_mesfiscal,
	   par_anofiscal
  into _mes_int,
       _sac_ano
  from sac006:cglparam;

if _mes_int < 10 then
	let _sac_mes = "0" || _mes_int;
else
	let _sac_mes = _mes_int;
end if 

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	if _sac_mes in('13','14') then
		let _dias_control = 31;
	else
		let _fecha_cierre = sp_sis36(_sac_periodo);
		let _dias = today - _fecha_cierre;
	end if	

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

-- sac003
{
let _nombre_cia = "UNITED INTERNATIONAL REINSURANCE CO.";

select par_mesfiscal,
	   par_anofiscal
  into _sac_mes,
       _sac_ano
  from sac003:cglparam;

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	
	let _dias = today - _fecha_cierre;

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

-- sac004

let _nombre_cia = "DERVAL FINANCIAL, S.A.";

select par_mesfiscal,
	   par_anofiscal
  into _mes_int,
       _sac_ano
  from sac004:cglparam;

if _mes_int < 10 then
	let _sac_mes = "0" || _mes_int;
else
	let _sac_mes = _mes_int;
end if 

let _sac_periodo = _sac_ano || "-" || _sac_mes;

if _may_periodo > _sac_periodo then
	
	let _dias = today - _fecha_cierre;

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if
}

end procedure
