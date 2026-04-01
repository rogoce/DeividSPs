-- Procedimiento Convierte los Registros Resumen

-- Creado    : 08/08/2006 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo031;

create procedure "informix".sp_bo031()
returning integer,
          char(50);

define _cia_comp			char(3);
define _ccosto				char(3);

define _res_noregistro		integer;
define _res_tipo_resumen	char(2);
define _res_notrx			integer;
define _res_comprobante		char(15);
define _res_fechatrx		date;
define _res_tipcomp			char(3);
define _res_ccosto			char(3);
define _res_descripcion		char(50);
define _res_moneda			char(2);
define _res_cuenta			char(12);
define _res_debito			dec(16,2);
define _res_credito			dec(16,2);
define _res_usuariocap		char(15);
define _res_usuarioact		char(15);
define _res_fechacap		datetime year to fraction;
define _res_fechaact		datetime year to fraction;
define _res_origen			char(3);
define _res_status			char(1);
define _res_tabla			char(18);
define _res_periodo			smallint;
define _res_ano				char(4);

define _res1_noregistro		integer;
define _res1_linea			integer;
define _res1_tipo_resumen	char(2);
define _res1_comprobante	char(15);
define _res1_cuenta			char(12);
define _res1_auxiliar		char(5);
define _res1_debito			dec(16,2);
define _res1_credito		dec(16,2);
define _res1_origen			char(3);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

-- Utilizado para las companias que no usan Centro de Costo

let _ccosto	= "001"; 

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || _error_desc;
end exception

-- Conversion de los Movimientos de todas las companias

let _cia_comp = sp_bo050("sac");

foreach 
 select res_noregistro,
        res_tipo_resumen,
	    res_notrx,
	    res_comprobante,
	    res_fechatrx,
	    res_tipcomp,
	    res_ccosto,
	    res_descripcion,
	    res_moneda,
	    res_cuenta,
	    res_debito,
	    res_credito,
	    res_usuariocap,
	    res_usuarioact,
	    res_fechacap,
	    res_fechaact,
	    res_origen,
	    res_status,
	    res_tabla,
	    month(res_fechatrx),
	    year(res_fechatrx)
   into _res_noregistro,
       	_res_tipo_resumen,
	   	_res_notrx,
	   	_res_comprobante,
	   	_res_fechatrx,
	    _res_tipcomp,
	    _res_ccosto,
	    _res_descripcion,
	    _res_moneda,
	    _res_cuenta,
	    _res_debito,
	    _res_credito,
	    _res_usuariocap,
	    _res_usuarioact,
	    _res_fechacap,
	    _res_fechaact,
	    _res_origen,
	    _res_status,
	    _res_tabla,
	    _res_periodo,
	    _res_ano
   from sac:cglresumen
  where subir_bo = 1

	insert into ef_cglresumen    
	values (
	       _res_noregistro,
       	   _res_tipo_resumen,
	   	   _res_notrx,
	   	   _res_comprobante,
	   	   _res_fechatrx,
	       _res_tipcomp,
	       _res_ccosto,
	       _res_descripcion,
	       _res_moneda,
	       _res_cuenta,
	       _res_debito,
	       _res_credito,
	       _res_usuariocap,
	       _res_usuarioact,
	       _res_fechacap,
	       _res_fechaact,
	       _res_origen,
	       _res_status,
	       _res_tabla,
	       _res_periodo,
	       _res_ano,
		   _cia_comp
		   );

	update sac:cglresumen
	   set subir_bo       = 0
	 where res_noregistro = _res_noregistro;

end foreach

foreach
 select res1_noregistro,
	    res1_linea,
	    res1_tipo_resumen,
	    res1_comprobante,
	    res1_cuenta,
	    res1_auxiliar,
	    res1_debito,
	    res1_credito,
	    res1_origen
   into _res1_noregistro,
	    _res1_linea,
	    _res1_tipo_resumen,
	    _res1_comprobante,
	    _res1_cuenta,
	    _res1_auxiliar,
	    _res1_debito,
	    _res1_credito,
	    _res1_origen
   from sac:cglresumen1
  where subir_bo = 1

	insert into ef_cglresumen1    
	values (
	       _res1_noregistro,
		   _res1_linea,
		   _res1_tipo_resumen,
		   _res1_comprobante,
		   _res1_cuenta,
		   _res1_auxiliar,
		   _res1_debito,
		   _res1_credito,
		   _res1_origen,
	       _cia_comp, 
	       _cia_comp
		   );

	update sac:cglresumen1
	   set subir_bo        = 0
	 where res1_noregistro = _res1_noregistro
	   and res1_linea      = _res1_linea;

end foreach

let _cia_comp = sp_bo050("sac001");

foreach 
 select res_noregistro,
        res_tipo_resumen,
	    res_notrx,
	    res_comprobante,
	    res_fechatrx,
	    res_tipcomp,
	    res_descripcion,
	    res_moneda,
	    res_cuenta,
	    res_debito,
	    res_credito,
	    res_usuariocap,
	    res_usuarioact,
	    res_fechacap,
	    res_fechaact,
	    res_origen,
	    res_status,
	    res_tabla,
	    month(res_fechatrx),
	    year(res_fechatrx)
   into _res_noregistro,
       	_res_tipo_resumen,
	   	_res_notrx,
	   	_res_comprobante,
	   	_res_fechatrx,
	    _res_tipcomp,
	    _res_descripcion,
	    _res_moneda,
	    _res_cuenta,
	    _res_debito,
	    _res_credito,
	    _res_usuariocap,
	    _res_usuarioact,
	    _res_fechacap,
	    _res_fechaact,
	    _res_origen,
	    _res_status,
	    _res_tabla,
	    _res_periodo,
	    _res_ano
   from sac001:cglresumen
  where subir_bo = 1

	insert into ef_cglresumen    
	values (
	       _res_noregistro,
       	   _res_tipo_resumen,
	   	   _res_notrx,
	   	   _res_comprobante,
	   	   _res_fechatrx,
	       _res_tipcomp,
	       _ccosto,
	       _res_descripcion,
	       _res_moneda,
	       _res_cuenta,
	       _res_debito,
	       _res_credito,
	       _res_usuariocap,
	       _res_usuarioact,
	       _res_fechacap,
	       _res_fechaact,
	       _res_origen,
	       _res_status,
	       _res_tabla,
	       _res_periodo,
	       _res_ano,
		   _cia_comp
		   );

	update sac001:cglresumen
	   set subir_bo       = 0
	 where res_noregistro = _res_noregistro;

end foreach

foreach
 select res1_noregistro,
	    res1_linea,
	    res1_tipo_resumen,
	    res1_comprobante,
	    res1_cuenta,
	    res1_auxiliar,
	    res1_debito,
	    res1_credito,
	    res1_origen
   into _res1_noregistro,
	    _res1_linea,
	    _res1_tipo_resumen,
	    _res1_comprobante,
	    _res1_cuenta,
	    _res1_auxiliar,
	    _res1_debito,
	    _res1_credito,
	    _res1_origen
   from sac001:cglresumen1
  where subir_bo = 1

	insert into ef_cglresumen1    
	values (
	       _res1_noregistro,
		   _res1_linea,
		   _res1_tipo_resumen,
		   _res1_comprobante,
		   _res1_cuenta,
		   _res1_auxiliar,
		   _res1_debito,
		   _res1_credito,
		   _res1_origen,
	       _cia_comp, 
	       _cia_comp
		   );

	update sac001:cglresumen1
	   set subir_bo        = 0
	 where res1_noregistro = _res1_noregistro
	   and res1_linea      = _res1_linea;

end foreach

let _cia_comp = sp_bo050("sac002");

foreach 
 select res_noregistro,
        res_tipo_resumen,
	    res_notrx,
	    res_comprobante,
	    res_fechatrx,
	    res_tipcomp,
	    res_descripcion,
	    res_moneda,
	    res_cuenta,
	    res_debito,
	    res_credito,
	    res_usuariocap,
	    res_usuarioact,
	    res_fechacap,
	    res_fechaact,
	    res_origen,
	    res_status,
	    res_tabla,
	    month(res_fechatrx),
	    year(res_fechatrx)
   into _res_noregistro,
       	_res_tipo_resumen,
	   	_res_notrx,
	   	_res_comprobante,
	   	_res_fechatrx,
	    _res_tipcomp,
	    _res_descripcion,
	    _res_moneda,
	    _res_cuenta,
	    _res_debito,
	    _res_credito,
	    _res_usuariocap,
	    _res_usuarioact,
	    _res_fechacap,
	    _res_fechaact,
	    _res_origen,
	    _res_status,
	    _res_tabla,
	    _res_periodo,
	    _res_ano
   from sac002:cglresumen
  where subir_bo = 1

	insert into ef_cglresumen    
	values (
	       _res_noregistro,
       	   _res_tipo_resumen,
	   	   _res_notrx,
	   	   _res_comprobante,
	   	   _res_fechatrx,
	       _res_tipcomp,
	       _ccosto,
	       _res_descripcion,
	       _res_moneda,
	       _res_cuenta,
	       _res_debito,
	       _res_credito,
	       _res_usuariocap,
	       _res_usuarioact,
	       _res_fechacap,
	       _res_fechaact,
	       _res_origen,
	       _res_status,
	       _res_tabla,
	       _res_periodo,
	       _res_ano,
		   _cia_comp
		   );

	update sac002:cglresumen
	   set subir_bo       = 0
	 where res_noregistro = _res_noregistro;

end foreach

foreach
 select res1_noregistro,
	    res1_linea,
	    res1_tipo_resumen,
	    res1_comprobante,
	    res1_cuenta,
	    res1_auxiliar,
	    res1_debito,
	    res1_credito,
	    res1_origen
   into _res1_noregistro,
	    _res1_linea,
	    _res1_tipo_resumen,
	    _res1_comprobante,
	    _res1_cuenta,
	    _res1_auxiliar,
	    _res1_debito,
	    _res1_credito,
	    _res1_origen
   from sac002:cglresumen1
  where subir_bo = 1

	insert into ef_cglresumen1    
	values (
	       _res1_noregistro,
		   _res1_linea,
		   _res1_tipo_resumen,
		   _res1_comprobante,
		   _res1_cuenta,
		   _res1_auxiliar,
		   _res1_debito,
		   _res1_credito,
		   _res1_origen,
	       _cia_comp, 
	       _cia_comp
		   );

	update sac002:cglresumen1
	   set subir_bo        = 0
	 where res1_noregistro = _res1_noregistro
	   and res1_linea      = _res1_linea;

end foreach

let _cia_comp = sp_bo050("sac006");

foreach 
 select res_noregistro,
        res_tipo_resumen,
	    res_notrx,
	    res_comprobante,
	    res_fechatrx,
	    res_tipcomp,
	    res_descripcion,
	    res_moneda,
	    res_cuenta,
	    res_debito,
	    res_credito,
	    res_usuariocap,
	    res_usuarioact,
	    res_fechacap,
	    res_fechaact,
	    res_origen,
	    res_status,
	    res_tabla,
	    month(res_fechatrx),
	    year(res_fechatrx)
   into _res_noregistro,
       	_res_tipo_resumen,
	   	_res_notrx,
	   	_res_comprobante,
	   	_res_fechatrx,
	    _res_tipcomp,
	    _res_descripcion,
	    _res_moneda,
	    _res_cuenta,
	    _res_debito,
	    _res_credito,
	    _res_usuariocap,
	    _res_usuarioact,
	    _res_fechacap,
	    _res_fechaact,
	    _res_origen,
	    _res_status,
	    _res_tabla,
	    _res_periodo,
	    _res_ano
   from sac006:cglresumen
  where subir_bo = 1

	insert into ef_cglresumen    
	values (
	       _res_noregistro,
       	   _res_tipo_resumen,
	   	   _res_notrx,
	   	   _res_comprobante,
	   	   _res_fechatrx,
	       _res_tipcomp,
	       _ccosto,
	       _res_descripcion,
	       _res_moneda,
	       _res_cuenta,
	       _res_debito,
	       _res_credito,
	       _res_usuariocap,
	       _res_usuarioact,
	       _res_fechacap,
	       _res_fechaact,
	       _res_origen,
	       _res_status,
	       _res_tabla,
	       _res_periodo,
	       _res_ano,
		   _cia_comp
		   );

	update sac006:cglresumen
	   set subir_bo       = 0
	 where res_noregistro = _res_noregistro;

end foreach

foreach
 select res1_noregistro,
	    res1_linea,
	    res1_tipo_resumen,
	    res1_comprobante,
	    res1_cuenta,
	    res1_auxiliar,
	    res1_debito,
	    res1_credito,
	    res1_origen
   into _res1_noregistro,
	    _res1_linea,
	    _res1_tipo_resumen,
	    _res1_comprobante,
	    _res1_cuenta,
	    _res1_auxiliar,
	    _res1_debito,
	    _res1_credito,
	    _res1_origen
   from sac006:cglresumen1
  where subir_bo = 1

	insert into ef_cglresumen1    
	values (
	       _res1_noregistro,
		   _res1_linea,
		   _res1_tipo_resumen,
		   _res1_comprobante,
		   _res1_cuenta,
		   _res1_auxiliar,
		   _res1_debito,
		   _res1_credito,
		   _res1_origen,
	       _cia_comp, 
	       _cia_comp
		   );

	update sac006:cglresumen1
	   set subir_bo        = 0
	 where res1_noregistro = _res1_noregistro
	   and res1_linea      = _res1_linea;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure