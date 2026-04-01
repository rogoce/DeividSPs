-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo014_3;

create procedure "informix".sp_bo014_3()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

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


let _error_desc = "Insertando ef_saldodet en SAC006";
let _cia_comp   = sp_bo050("sac006");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac006:cglsaldodet
 where sldet_ano >= _ano;

{
let _error_desc = "Insertando ef_cglpre02 en SAC002";
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
  from sac002:cglpre02
 where pre2_ano >= _ano; 	
}

{
let _error_desc = "Insertando ef_saldodet en SAC003";
let _cia_comp   = sp_bo050("sac003");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac003:cglsaldodet
 where sldet_ano >= _ano;

let _error_desc = "Insertando ef_cglpre02 en SAC003";
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
  from sac003:cglpre02
 where pre2_ano >= _ano; 	

let _error_desc = "Insertando ef_saldodet en SAC004";
let _cia_comp   = sp_bo050("sac004");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac004:cglsaldodet
 where sldet_ano >= _ano;

let _error_desc = "Insertando ef_saldodet en SAC005";
let _cia_comp   = sp_bo050("sac005");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac005:cglsaldodet
 where sldet_ano >= _ano;

let _error_desc = "Insertando ef_saldodet en SAC007";
let _cia_comp   = sp_bo050("sac007");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac007:cglsaldodet
 where sldet_ano >= _ano;

let _error_desc = "Insertando ef_saldodet en SAC008";
let _cia_comp   = sp_bo050("sac008");

insert into ef_saldodet    
select sldet_tipo,
	   sldet_cuenta,
	   sldet_ccosto,
	   sldet_ano,
	   sldet_periodo,
	   sldet_debtop,
	   sldet_cretop,
	   sldet_saldop, 
	   _null, 
	   _null,
	   _cia_comp
  from sac008:cglsaldodet
 where sldet_ano >= _ano;
}

-- Consolidacion de Companias

--let _error_desc = "Procesando sp_bo020";

--call sp_bo020() returning _error, _error_desc;

end

set isolation to dirty read;

return 0, "Actualizacion Exitosa";

end procedure