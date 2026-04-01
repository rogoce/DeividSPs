-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rwf168;

CREATE PROCEDURE "informix".sp_rwf168(a_no_reclamo char(10))
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
define _cant            smallint;
define _no_poliza       char(10);
define _no_unidad       char(5);
define _cod_producto    char(5);
DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

--set debug file to "sp_rwf12.trc";
--trace on;

--begin work;

set lock mode to wait 60;

let a_no_reclamo = a_no_reclamo;
let _null        = null;

begin
on exception set _error, _error_isam, _error_desc
--	rollback work;
	return _error, "Error al Generar la Transaccion Inicial","","";	
end exception

select cod_compania,
       cod_sucursal,
	   no_poliza,
	   no_unidad
  into _cod_compania,
       _cod_sucursal,
	   _no_poliza,
	   _no_unidad
  from recrcmae
 where no_reclamo = a_no_reclamo;

let _aplicacion = "REC";

SELECT version
  INTO _version
  FROM insapli
 WHERE aplicacion = _aplicacion;

SELECT valor_parametro
  INTO _valor_parametro
  FROM inspaag
 WHERE codigo_compania  = _cod_compania
   AND aplicacion       = _aplicacion
   AND version          = _version
   AND codigo_parametro	= 'fecha_recl_default';

IF TRIM(_valor_parametro) = '1' THEN   --Toma la fecha del servidor

	LET _fecha_no_server = CURRENT;				

ELSE								   --Toma la fecha de un parametro establecido por computo.

	SELECT valor_parametro			  
      INTO _valor_parametro2
	  FROM inspaag
	 WHERE codigo_compania  = _cod_compania
	   AND aplicacion       = _aplicacion
	   AND version          = _version
	   AND codigo_parametro	= 'fecha_recl_valor';

	LET _fecha_no_server = DATE(_valor_parametro2);				

END IF

IF MONTH(_fecha_no_server) < 10 THEN
	LET _periodo_rec = YEAR(_fecha_no_server) || "-0" || MONTH(_fecha_no_server);
ELSE
	LET _periodo_rec = YEAR(_fecha_no_server) || "-" || MONTH(_fecha_no_server);
END IF
 
select cod_producto
  into _cod_producto
  from emipouni
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad;

update recrcmae
   set cod_producto = _cod_producto,
       periodo = _periodo_rec,
	   fecha_reclamo = _fecha_no_server
 where no_reclamo = a_no_reclamo;

let _cant = 0;

select count(*)
  into _cant
  from rectrmae
 where no_reclamo = a_no_reclamo
   and cod_tipotran = "001"; 


if _cant = 0 then
	let _transaccion = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);
	let _no_tranrec  = sp_sis13(_cod_compania, 'REC', '02', 'par_tran_genera');

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
	cod_proveedor,
	yoseguro
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
	_periodo_rec,
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
	_null,
	yoseguro
	from recrcmae
	where no_reclamo = a_no_reclamo;
	
	delete from rectrcob where no_tranrec = _no_tranrec;
	delete from rectrde2 where no_tranrec = _no_tranrec;
	   
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
	reserva_inicial, --0.00  ---> Se cambio para que traiga el valor desde recrcmae nuevo programa 
	reserva_inicial, --0.00  ---> Se cambio para que traiga el valor desde recrcmae nuevo programa
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
	
else
   select no_tranrec, transaccion
     into _no_tranrec, _transaccion
	 from rectrmae
	where no_reclamo = a_no_reclamo
	  and cod_tipotran = "001"; 
end if


end

--commit work;

return 0, "Actualizacion Exitosa ... ", _no_tranrec, _transaccion;	

end procedure