-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_bo014_1_;

create procedure "informix".sp_bo014_1_()
returning integer,
          char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _enlace 			char(10);
define _cuenta			char(12);
define _recibe  		char(1);
define _null			char(1);
define _cia_comp		char(3);

define _pre2_cuenta		char(12);
define _pre2_ccosto		char(3);
define _pre2_ano		char(4);
define _pre2_periodo	smallint;
define _pre2_montomes	decimal(16,2);
define _pre2_montoacu	decimal(16,2);

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

let _error_desc = "Insertando ef_cglpre02 en SAC";

{
insert into sac999:ef_cglpre02
select _cia_comp,
       "01",
	   pre2_cuenta,
	   pre2_ccosto,
	   pre2_ano,
	   pre2_periodo,
	   pre2_montomes,
	   pre2_montoacu,
	   _enlace, 
	   _recibe
  from sac:cglpre02
 where pre2_ano >= _ano;
 }

foreach
	select pre2_cuenta,
		   pre2_ccosto,
		   pre2_ano,
		   pre2_periodo,
		   pre2_montomes,
		   pre2_montoacu
	  into _pre2_cuenta,
		   _pre2_ccosto,
		   _pre2_ano,
		   _pre2_periodo,
		   _pre2_montomes,
		   _pre2_montoacu
	  from sac:cglpre02
	 where pre2_ano >= _ano


	insert into sac999:ef_cglpre02 (pre2_cia_comp, pre2_tipo, pre2_cuenta, pre2_ccosto,
	pre2_ano, pre2_periodo, pre2_montomes, pre2_montoacu, pre2_enlace, pre2_recibe)
	values(_cia_comp, "01",_pre2_cuenta, _pre2_ccosto, _pre2_ano,  _pre2_periodo,
		   _pre2_montomes, _pre2_montoacu, _enlace, _recibe);
 	

end foreach



end

set isolation to dirty read;

return 0, "Actualizacion Exitosa";

end procedure