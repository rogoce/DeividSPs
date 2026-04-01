-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo014_1;

create procedure "informix".sp_bo014_1()
returning integer,
          char(50);

define _sldet_tipo		char(2);
define _sldet_cuenta	char(12);
define _sldet_ccosto	char(3);
define _sldet_ano		char(4);
define _sldet_periodo	smallint;
define _sldet_debtop	dec(15,2);
define _sldet_cretop	dec(15,2);
define _sldet_saldop	dec(15,2);

define _enlace 			char(10);
define _cuenta			char(12);
define _recibe  		char(1);
define _null			char(1);
define _cia_comp		char(3);

define _ano				char(4);
define _ano_fiscal		smallint;

define _cant_reg		integer;
define _cant_pro		integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error
	return _error, _error_desc;
end exception

select par_anofiscal
  into _ano_fiscal
  from cglparam;

let _null 	= null;
let _ano  	= _ano_fiscal - 1;
let _enlace = "99999999";
let _recibe = "N";

-- Conversion de los Saldos de todas las companias

let _cia_comp   = "001";
let _error_desc = "Insertando ef_saldodet en SAC";

--{
let _cant_reg = 0;
let _cant_pro = 100000;

foreach with hold
 select sldet_tipo,
 	    sldet_cuenta,
 	    sldet_ccosto,
 	    sldet_ano,
 	    sldet_periodo,
 	    sldet_debtop,
 	    sldet_cretop,
 	    sldet_saldop
   into _sldet_tipo,
 	    _sldet_cuenta,
 	    _sldet_ccosto,
 	    _sldet_ano,
 	    _sldet_periodo,
 	    _sldet_debtop,
 	    _sldet_cretop,
 	    _sldet_saldop
   from sac:cglsaldodet
  where sldet_ano >= _ano

	let _cant_reg = _cant_reg + 1;

	insert into ef_saldodet (sldet_tipo, sldet_cuenta, sldet_ccosto, sldet_ano, sldet_periodo, sldet_debtop,
	 	     	             sldet_cretop, sldet_saldop, sldet_enlace, sldet_recibe, sldet_cia_comp) 
	values (_sldet_tipo, _sldet_cuenta, _sldet_ccosto,	_sldet_ano,	_sldet_periodo,	_sldet_debtop,
		    _sldet_cretop, _sldet_saldop, _enlace, _recibe,	_cia_comp);

	if _cant_reg >= _cant_pro then
		commit work;
		begin work;
		let _cant_reg = 0;
	end if

end foreach
--}
end

if _cant_reg < _cant_pro and _cant_reg <> 0 then
	commit work;
	begin work;
end if

return 0, "Actualizacion Exitosa";

end procedure