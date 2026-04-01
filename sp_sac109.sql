-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac109;

create procedure sp_sac109(
a_notrx	integer
) returning integer,
            char(50);

define _ccosto			char(3);
define _ccosto_mal		char(3);
define _origen			char(3);
define _cuenta			char(12);
define _no_registro		integer;

define _tipo_resumen	char(2);
define _notrx			integer;
define _comprobante		char(8);
define _fechatrx		date;
define _tipcomp			char(3);
define _descripcion		char(50);
define _moneda			char(2);
define _usuariocap		char(15);
define _usuarioact		char(15);
define _fechacap		datetime year to fraction;
define _fechaact		datetime year to fraction;
define _status			char(1);
define _tabla			char(18);

define _cantidad		smallint;
define _debito			dec(16,2);
define _credito			dec(16,2);

let _ccosto = "017";
let _origen = "COB";
let _cuenta = "26410";

-- Validaciones

select count(*)
  into _cantidad 
  from cglresumen
 where res_notrx  = a_notrx
   and res_ccosto = _ccosto
   and res_origen = _origen;

if _cantidad <> 1 then

	return 1, "Hay mas de 1 registro para " || a_notrx || " " || _ccosto || " " || _origen || " " || _cantidad;	

end if

select count(*)
  into _cantidad 
  from cglresumen
 where res_notrx  = a_notrx
   and res_origen = _origen
   and res_cuenta = _cuenta;

if _cantidad <> 1 then

	return 1, "Hay mas de 1 registro para " || a_notrx || " " || _cuenta || " " || _origen || " " || _cantidad;	

end if

select res_ccosto
  into _ccosto_mal 
  from cglresumen
 where res_notrx  = a_notrx
   and res_origen = _origen
   and res_cuenta = _cuenta;

-- Proceso de Actualizacion

select res_debito,
       res_credito,
       res_tipo_resumen,
	   res_notrx,
	   res_comprobante,
	   res_fechatrx,
	   res_tipcomp,
	   res_ccosto,
	   res_descripcion,
	   res_moneda,
	   res_usuariocap,
	   res_usuarioact,
	   res_fechacap,
	   res_fechaact,
	   res_origen,
	   res_status,
	   res_tabla
  into _debito,
       _credito, 
       _tipo_resumen,
	   _notrx,
	   _comprobante,
	   _fechatrx,
	   _tipcomp,
	   _ccosto,
	   _descripcion,
	   _moneda,
	   _usuariocap,
	   _usuarioact,
	   _fechacap,
	   _fechaact,
	   _origen,
	   _status,
	   _tabla
  from cglresumen
 where res_notrx  = a_notrx
   and res_ccosto = _ccosto
   and res_origen = _origen;

select param_valor 
  into _no_registro
  from seguridad:sigman25
 where param_comp     = "001"
   and param_apl_id   = "CGL"
   and param_apl_vers = "03"
   and param_codigo   = "para_resumen";

if _debito <> 0 then

	-- Cancelar Centro Costo Errado

	let _no_registro = _no_registro + 1;

	insert into cglresumen (res_noregistro,res_tipo_resumen,res_notrx,res_comprobante,res_fechatrx,res_tipcomp,res_ccosto,res_descripcion,res_moneda,res_cuenta,res_debito,res_credito,res_usuariocap,res_usuarioact,res_fechacap,res_fechaact,res_origen,res_status,res_tabla)
	values (
	       _no_registro,
	       _tipo_resumen,
		   _notrx,
		   _comprobante,
		   _fechatrx,
		   _tipcomp,
		   _ccosto_mal,
		   _descripcion,
		   _moneda,
		   _cuenta,
		   _debito,
		   0.00,
		   _usuariocap,
		   _usuarioact,
		   _fechacap,
		   _fechaact,
		   _origen,
		   _status,
		   _tabla
		   );

	-- Crear Centro de Costo 017 (Fianzas)

	let _no_registro = _no_registro + 1;
	
	insert into cglresumen (res_noregistro,res_tipo_resumen,res_notrx,res_comprobante,res_fechatrx,res_tipcomp,res_ccosto,res_descripcion,res_moneda,res_cuenta,res_debito,res_credito,res_usuariocap,res_usuarioact,res_fechacap,res_fechaact,res_origen,res_status,res_tabla)
	values (
	       _no_registro,
	       _tipo_resumen,
		   _notrx,
		   _comprobante,
		   _fechatrx,
		   _tipcomp,
		   _ccosto,
		   _descripcion,
		   _moneda,
		   _cuenta,
		   0.00,
		   _debito,
		   _usuariocap,
		   _usuarioact,
		   _fechacap,
		   _fechaact,
		   _origen,
		   _status,
		   _tabla
		   );

end if

if _credito <> 0 then

	-- Cancelar Centro Costo Errado

	let _no_registro = _no_registro + 1;

	insert into cglresumen (res_noregistro,res_tipo_resumen,res_notrx,res_comprobante,res_fechatrx,res_tipcomp,res_ccosto,res_descripcion,res_moneda,res_cuenta,res_debito,res_credito,res_usuariocap,res_usuarioact,res_fechacap,res_fechaact,res_origen,res_status,res_tabla)
	values (
	       _no_registro,
	       _tipo_resumen,
		   _notrx,
		   _comprobante,
		   _fechatrx,
		   _tipcomp,
		   _ccosto_mal,
		   _descripcion,
		   _moneda,
		   _cuenta,
		   0.00,
		   _credito,
		   _usuariocap,
		   _usuarioact,
		   _fechacap,
		   _fechaact,
		   _origen,
		   _status,
		   _tabla
		   );

	-- Crear Centro de Costo 017 (Fianzas)

	let _no_registro = _no_registro + 1;
	
	insert into cglresumen (res_noregistro,res_tipo_resumen,res_notrx,res_comprobante,res_fechatrx,res_tipcomp,res_ccosto,res_descripcion,res_moneda,res_cuenta,res_debito,res_credito,res_usuariocap,res_usuarioact,res_fechacap,res_fechaact,res_origen,res_status,res_tabla)
	values (
	       _no_registro,
	       _tipo_resumen,
		   _notrx,
		   _comprobante,
		   _fechatrx,
		   _tipcomp,
		   _ccosto,
		   _descripcion,
		   _moneda,
		   _cuenta,
		   _credito,
		   0.00,
		   _usuariocap,
		   _usuarioact,
		   _fechacap,
		   _fechaact,
		   _origen,
		   _status,
		   _tabla
		   );

end if

update seguridad:sigman25
   set param_valor    = _no_registro
 where param_comp     = "001"
   and param_apl_id   = "CGL"
   and param_apl_vers = "03"
   and param_codigo   = "para_resumen";

return 0, "Actualizacion Exitosa";

end procedure
