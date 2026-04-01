-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo014_2;

create procedure "informix".sp_bo014_2()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _sldet_tipo		char(2);
define _sldet_cuenta	char(12);
define _sldet_ccosto	char(3);
define _sldet_ano		char(4);
define _sldet_periodo	smallint;
define _sldet_debtop	dec(15,2);
define _sldet_cretop	dec(15,2);
define _sldet_saldop	dec(15,2);


define _enlace 		char(10);
define _cuenta		char(12);
define _recibe  	char(1);
define _null		char(1);
define _cia_comp	char(3);

define _ano			char(4);
define _ano_fiscal	smallint;

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

set lock mode to wait;
{
insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _enlace, 
	   _recibe,
	   _cia_comp
  from sac001:cglsaldodet
 where sldet_ano >= _ano;
}

foreach
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
	  from sac001:cglsaldodet
	 where sldet_ano >= _ano

	insert into ef_saldodet (sldet_tipo, sldet_cuenta, sldet_ccosto, sldet_ano, sldet_periodo, sldet_debtop,
	 		sldet_cretop, sldet_saldop, sldet_enlace, sldet_recibe, sldet_cia_comp) 
	 values	(_sldet_tipo, _sldet_cuenta, _sldet_ccosto,	_sldet_ano,	_sldet_periodo,	_sldet_debtop,
		   _sldet_cretop, _sldet_saldop, _enlace, _recibe,	_cia_comp);



end foreach

{
let _error_desc = "Insertando ef_cglpre02 en SAC001";
insert into sac999:ef_cglpre02
select _cia_comp,
       "01",
	   pre2_cuenta,
	   pre2_ccosto,
	   pre2_ano,
	   pre2_periodo,
	   pre2_montomes,
	   pre2_montoacu,
	   _null, 
	   _null
  from sac001:cglpre02
 where pre2_ano >= _ano; 	
}

end

set isolation to dirty read;

return 0, "Actualizacion Exitosa";

end procedure