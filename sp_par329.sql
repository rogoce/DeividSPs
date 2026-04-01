-- Generacion de Registros Contables de Reaseguro - Primas Suscritas 50% Cuota Parte Mapfre 

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

-- drop procedure sp_par329;

create procedure "informix".sp_par329(
a_no_registro 	char(10),
_cod_contrato	char(5),
_cod_cober_reas	char(3)
)
returning integer,
		  char(100);

define _codigo_cp		char(5);
define _porc_partic_cp	dec(9,6);

select codigo_cp,
       porc_partic_cp
  into _codigo_cp,
	   _porc_partic_cp
  from reacocob
 where cod_contrato   = _cod_contrato
   and cod_cober_reas = _cod_cober_reas;

if _codigo_cp is null then
	return 0, "Actualizacion Exitosa";
end if

let _cod_contrato = _codigo_cp;	

select porc_impuesto,
       porc_comision,
	   cod_coasegur,
	   tiene_comision,
	   bouquet
  into _factor_impuesto,
	   _porc_comis_agt,
	   _cod_coasegur,
	   _tiene_comis_rea,
	   _bouquet
  from reacocob
 where cod_contrato   = _cod_contrato
   and cod_cober_reas = _cod_cober_reas;
 


end procedure