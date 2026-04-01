-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo071;

create procedure "informix".sp_bo071()
returning integer,
          char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _ano				smallint;
define _ano_char		char(4);
define _ano_fiscal		smallint;

define _sldet_tipo		char(2);
define _sldet_cuenta	char(25);
define _sldet_ccosto	char(3);
define _sldet_ano		char(4);
define _sldet_periodo	smallint;
define _sldet_cia_comp	char(3);


define _pre2_cia_comp	char(3);
define _pre2_tipo		char(2);
define _pre2_cuenta		char(25);
define _pre2_ccosto		char(3);
define _pre2_ano		char(4);
define _pre2_periodo	smallint;

define _cant_reg		integer;
define _cant_pro		integer;

set isolation to dirty read;

begin 
on exception set _error
	return _error, _error_desc;
end exception

select par_anofiscal
  into _ano_fiscal
  from cglparam;

let _ano      = _ano_fiscal - 1;
let _ano_char = _ano;

let _error_desc = "Borrando ef_saldodet";

let _cant_reg = 0;
let _cant_pro = 100000;

foreach with hold
 select sldet_tipo,	
 		sldet_cuenta,
 		sldet_ccosto,
 		sldet_ano,
		sldet_periodo,
		sldet_cia_comp
   into _sldet_tipo,				
 		_sldet_cuenta,
 		_sldet_ccosto,
 		_sldet_ano,
		_sldet_periodo,
		_sldet_cia_comp
   from sac999:ef_saldodet 
  where sldet_ano >= _ano_char			
  
	let _cant_reg = _cant_reg + 1;

	delete from sac999:ef_saldodet 
	 where sldet_tipo     = _sldet_tipo	
 	   and sldet_cuenta   = _sldet_cuenta
 	   and sldet_ccosto   = _sldet_ccosto
 	   and sldet_ano      = _sldet_ano
 	   and sldet_periodo  = _sldet_periodo
 	   and sldet_cia_comp = _sldet_cia_comp;

	if _cant_reg >= _cant_pro then
		commit work;
		begin work;
		let _cant_reg = 0;
	end if

end foreach

if _cant_reg < _cant_pro and _cant_reg <> 0 then
	commit work;
	begin work;
end if

let _error_desc = "Borrando ef_cglpre02";

let _cant_reg = 0;

foreach with hold
 select pre2_cia_comp,	
 		pre2_tipo,
 		pre2_cuenta,
 		pre2_ccosto,
		pre2_ano,
		pre2_periodo
   into _pre2_cia_comp,	
 		_pre2_tipo,
 		_pre2_cuenta,
 		_pre2_ccosto,
		_pre2_ano,
		_pre2_periodo
   from sac999:ef_cglpre02 
  where pre2_ano >= _ano_char			
  
	let _cant_reg = _cant_reg + 1;

	delete from sac999:ef_cglpre02 
	 where pre2_cia_comp = _pre2_cia_comp	
 	   and pre2_tipo     = _pre2_tipo
 	   and pre2_cuenta   = _pre2_cuenta
 	   and pre2_ccosto   = _pre2_ccosto
 	   and pre2_ano      = _pre2_ano
 	   and pre2_periodo  = _pre2_periodo;

	if _cant_reg >= _cant_pro then
		commit work;
		begin work;
		let _cant_reg = 0;
	end if

end foreach

if _cant_reg < _cant_pro and _cant_reg <> 0 then
	commit work;
end if

end

return 0, "Actualizacion Exitosa";

end procedure