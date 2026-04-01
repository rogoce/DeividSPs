-- Procedimiento que genera el endoso de modificacion para la reversion de una factura
-- 
-- Creado     : 23/02/2022 - Autor: Armanod Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par130_d;
create procedure sp_par130_d(a_no_poliza char(10), a_no_endoso_ant char(5), a_usuario char(8))
returning integer, char(50), char(5);

define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso,_no_unidad		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(50);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);

--set debug file to "sp_par130.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _null = null;  -- Para campos null

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso      = sp_set_codigo(5, _no_endoso_int + 1);
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);

select * 
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set actualizado   = 0,
       no_endoso     = _no_endoso,
       no_endoso_ext = _no_endoso_ext,
	   periodo        = _periodo,
	   prima         = prima,
	   descuento     = descuento,
	   recargo       = recargo,
	   prima_neta    = prima_neta,
	   impuesto      = impuesto,
	   prima_bruta   = prima_bruta,
	   prima_suscrita = prima_suscrita,
	   prima_retenida = prima_retenida,
	   fecha_emision = today,
	   fecha_impresion = today,
	   no_factura      = _null,
	   date_added      = today,
	   date_changed    = today,
	   user_added      = a_usuario,
	   suma_asegurada  = suma_asegurada,
	   sac_asientos    = 0,
	   subir_bo        = 0,
	   wf_aprob        = 0,
	   wf_firma_aprob  = _null,
	   wf_incidente    = _null,
	   wf_fecha_entro  = _null,
	   wf_fecha_aprob  = _null,
	   fecha_indicador = today;

insert into endedmae
select * from e_prueba;

drop table e_prueba;

select * 
  from endedimp
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set no_endoso = _no_endoso,
       monto     = monto;

insert into endedimp
select * from e_prueba;

drop table e_prueba;

call sp_pro493_d(a_no_poliza, _no_endoso, a_no_endoso_ant) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

select sum(suma_asegurada)
  into _suma_asegurada
  from endeduni					 
 where no_poliza  = a_no_poliza
   and no_endoso  = _no_endoso;

update endedmae
   set suma_asegurada = _suma_asegurada
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;
end

--call sp_pro43(a_no_poliza, _no_endoso) returning _error, _descripcion;  -- Se solicita no actualizar
--if _error <> 0 then
--	return _error, _descripcion, _no_endoso;
--end if
return 0, "Actualizacion Exitosa", _no_endoso;
end procedure