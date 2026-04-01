-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac116;

create procedure sp_sac116(
a_noregistro	integer
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

-- Validaciones

select param_valor 
  into _no_registro
  from seguridad:sigman25
 where param_comp     = "001"
   and param_apl_id   = "CGL"
   and param_apl_vers = "03"
   and param_codigo   = "para_resumen";

select res_tipo_resumen,
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
	   res_tabla,
	   res_cuenta,
	   res_debito,
	   res_credito
  into _tipo_resumen,
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
	   _tabla,
	   _cuenta,
	   _debito,
	   _credito
  from cglresumen
 where res_noregistro =  a_noregistro;

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
	   _debito,
	   _credito,
	   _usuariocap,
	   _usuarioact,
	   _fechacap,
	   _fechaact,
	   _origen,
	   _status,
	   _tabla
	   );

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
	   _debito,
	   _usuariocap,
	   _usuarioact,
	   _fechacap,
	   _fechaact,
	   _origen,
	   _status,
	   _tabla
	   );

update seguridad:sigman25
   set param_valor    = _no_registro
 where param_comp     = "001"
   and param_apl_id   = "CGL"
   and param_apl_vers = "03"
   and param_codigo   = "para_resumen";

return 0, "Actualizacion Exitosa";

end procedure
