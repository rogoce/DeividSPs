-- Procedure que verifica diariamente que cglresumen sea cglsaldodet de contabilidad
-- Creado    : 26/04/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac183;
create procedure "informix".sp_sac183()
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

--set debug file to "sp_sac183.trc";
--trace on;

set isolation to dirty read;
let _may_periodo = today;

-- SAC

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
	
	let _dias =  - _fecha_cierre;

	if _dias > _dias_control then
		return 1, _sac_periodo, _nombre_cia with resume;
	end if

end if

LET res_db = 0;
LET res_cr = 0;

FOREACH
select cta_cuenta,cta_nivel,cta_recibe,cta_auxiliar,referencia
  into _cuenta,_nivel,_recibe,_auxiliar,_refe
  from cglcuentas
 where cta_recibe = "S"
END FOREACH

FOREACH
select per_mes
  into _mes
  from cglperiodo
 where per_ano = 2010
   and per_status = "A"
 order by 1

END FOREACH

FOREACH
 select sum(res_debito), sum(res_credito)
   into res_db,res_cr
   from cglresumen
  where year(res_fechatrx) = 2010
    and month(res_fechatrx) = 3
    and res_cuenta = "231010202"

END FOREACH

LET sldet_db = 0;
LET sldet_cr = 0;

FOREACH
Select sum(sldet_debtop), sum(sldet_cretop)
  into sldet_db,sldet_cr
  from cglsaldodet
 where sldet_cuenta  = "231010202"
   and sldet_ano     = "2010"
   and sldet_periodo = 3
END FOREACH

end procedure
