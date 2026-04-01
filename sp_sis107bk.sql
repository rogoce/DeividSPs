-- Procedimiento que Actualiza los datos para las cotizaciones de polizas en WEB
-- 
-- Creado    : 06/06/2008 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.


--drop procedure sp_sis107bk;

create procedure sp_sis107bk(a_no_poliza char(10))
returning integer,
          char(50);

define _cod_compania	char(3);
define _serie			smallint;
define _cod_ramo		char(3);
define _periodo			char(7);
define _cod_ruta		char(5);

define _orden			smallint;
define _cod_contrato    char(5);
define _tipo_contrato	smallint;
define _porc_par_prima	dec(9,6);
define _porc_par_suma	dec(9,6);

define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_cober_reas  char(3);
define _suma_asegurada	dec(16,2);
define _prima_neta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _vig_ini         date;

define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define ll_rea_glo,_valor  integer;

set isolation to dirty read; 

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
 
let _no_endoso = "00000";

-- Seleccion de Registros

select serie,
       cod_ramo,
	   cod_compania,
	   vigencia_inic
  into _serie,
       _cod_ramo,
	   _cod_compania,
	   _vig_ini
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cantidad
  from rearumae
 where cod_ramo = _cod_ramo
   and ruta_web = 1
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;

if _cantidad = 0 then
	return 1, "No Hay Ruta de Reaseguro, Contactar Ancon, Gracias";
end if

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = _cod_compania;

-- Actualizacion de Polizas

update emipomae
   set periodo        = _periodo,
       prima_suscrita = 0.00,
       prima_retenida = 0.00
 where no_poliza      = a_no_poliza;

select cod_ruta,serie
  into _cod_ruta,_serie
  from rearumae
 where cod_ramo = _cod_ramo
   and ruta_web = 1
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;


delete from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;


select count(*) 
  into ll_rea_glo
  from emigloco
 where emigloco.no_poliza = a_no_poliza;

if ll_rea_glo is null then
   let ll_rea_glo = 0;
end if

if ll_rea_glo = 0 then --Para cuando no hay emigloco

	select * 
	  from rearucon
	 where cod_ruta = _cod_ruta
	  into temp prueba;

	insert into emigloco(
	no_poliza,
	no_endoso,
	orden,
	cod_contrato,
	cod_ruta,
	porc_partic_prima,
	porc_partic_suma,
	suma_asegurada,
	prima)
	select a_no_poliza,
	       _no_endoso,
			orden,
			cod_contrato,
	        cod_ruta,
			porc_partic_prima,
			porc_partic_suma,
	       	0,0
	  from prueba;

	drop table prueba;
end if

foreach
 select	no_unidad,
        suma_asegurada,
		prima_neta
   into _no_unidad,
        _suma_asegurada,
		_prima_neta
   from emipouni
  where no_poliza = a_no_poliza

	let _prima_retenida = 0.00;

	let _valor = sp_proe04(a_no_poliza,_no_unidad,_suma_asegurada,'001');

	select sum(prima)
	  into _prima_retenida
	  from emifacon c, reacomae r
	 where r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 1
	   and no_poliza = a_no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = _no_endoso;

	update emipouni
	   set prima_suscrita = _prima_neta,
	       prima_retenida = _prima_retenida,
		   cod_ruta       = _cod_ruta
	 where no_poliza      = a_no_poliza
	   and no_unidad      = _no_unidad;     

	update emipomae
	   set prima_suscrita = prima_suscrita + _prima_neta,
	       prima_retenida = prima_retenida + _prima_retenida,
		   serie          = _serie
	 where no_poliza      = a_no_poliza;

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure