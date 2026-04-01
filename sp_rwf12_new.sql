-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf12;

CREATE PROCEDURE "informix".sp_rwf12(a_no_reclamo char(10))
returning integer, 
          char(26),
          char(10),
          char(10);

define _transaccion		char(10);
define _no_tranrec		char(10);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _null			char(1);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _monto           dec(16,2);
define _variacion       dec(16,2);

--set debug file to "sp_rwf12.trc";
--trace on;

--begin work;

let a_no_reclamo = a_no_reclamo;

begin
on exception set _error, _error_isam, _error_desc
--	rollback work;
	return _error, "Error al Generar la Transaccion Inicial","","";	
end exception

select cod_compania,
       cod_sucursal
  into _cod_compania,
       _cod_sucursal
  from recrcmae
 where no_reclamo = a_no_reclamo;

let _transaccion = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);
let _no_tranrec  = sp_sis13(_cod_compania, 'REC', '02', 'par_tran_genera');
let _null        = null;

insert into rectrmae(
no_tranrec,
cod_compania,
cod_sucursal,
no_reclamo,
cod_cliente,
cod_tipotran,
cod_tipopago,
no_requis,
no_remesa,
renglon,
numrecla,
fecha,
impreso,
transaccion,
perd_total,
cerrar_rec,
no_impresion,
periodo,
pagado,
monto,
variacion,
generar_cheque,
actualizado,
user_added,
fecha_pagado,
facturado,
elegible,
a_deducible,
co_pago,
monto_no_cubierto,
coaseguro,
ahorro,
cod_cpt,
incurrido_total,
incurrido_bruto,
incurrido_neto,
pagado_proveedor,
pagado_taller,
pagado_asegurado,
pagado_tercero,
anular_nt,
user_anulo,
fecha_anulo,
no_factura,
fecha_factura,
cod_proveedor
)
select
_no_tranrec,
cod_compania,
cod_sucursal,
no_reclamo,
cod_asegurado,
"001",
_null,
_null,
_null,
_null,
numrecla,
fecha_reclamo,
0,
_transaccion,
perd_total,
0,
0,
periodo,
0.00,
0.00,
0.00,
0,
1, --Actualizado
user_added,
_null,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
_null,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
_null,
_null,
_null,
_null,
_null,
_null
from recrcmae
where no_reclamo = a_no_reclamo;

-- Coberturas

insert into rectrcob(
no_tranrec,
cod_cobertura,
monto,
variacion,
facturado,
elegible,
a_deducible,
co_pago,
cod_no_cubierto,
monto_no_cubierto,
cod_tipo,
coaseguro,
ahorro
)
select
_no_tranrec,
cod_cobertura,
reserva_inicial, -- reserva_inicial, 0.00  ---> Se cambio para que traiga el valor desde recrcmae nuevo programa 
reserva_inicial, -- reserva_inicial, 0.00  ---> Se cambio para que traiga el valor desde recrcmae nuevo programa
0.00,
0.00,
0.00,
0.00,
_null,
0.00,
_null,
0.00,
0.00
from recrccob
where no_reclamo = a_no_reclamo;

-----------------------------------	 --
										 --
select sum(monto), sum(variacion)			 --
  into _monto, _variacion
  from rectrcob 								 --> Se recalcula para qu e se cree la nueva transaccion de aumento de reserva
 where no_tranrec = _no_tranrec;
 
update rectrmae
   set monto = _monto, variacion = _variacion
 where no_tranrec = _no_tranrec;  

-----------------------------------

-- Descripcion

insert into rectrde2(
no_tranrec,
renglon,
desc_transaccion
)
select
_no_tranrec,
renglon,
desc_transaccion
from recrcde2
where no_reclamo = a_no_reclamo;

end

--commit work;

return 0, "Actualizacion Exitosa ... ", _no_tranrec, _transaccion;	

end procedure