-- Procedure que carga los datos para E Pago

-- Creado    : 29/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_epa01;

create procedure "informix".sp_epa01()

define _no_documento	char(20);
define _no_poliza		char(10);
define _cedula			char(30);
define _nombre			char(50);
define _cod_cliente		char(10);
define _cod_perpago		char(10);
define _nombre_pago		char(50);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _cod_sucursal	char(3);
define _nombre_suc		char(50);

set isolation to dirty read;

delete from epa_saldos;

foreach
 select no_documento
   into	_no_documento
   from emipomae
  where actualizado = 1
    and cod_ramo    = "005"
  group by no_documento
	
	let _no_poliza = sp_sis21(_no_documento);

	select cod_contratante,
	       cod_perpago,
		   cod_ramo,
		   sucursal_origen
	  into _cod_cliente,
	       _cod_perpago,
		   _cod_ramo,
		   _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_pago
	  from cobperpa      
	 where cod_perpago = _cod_perpago;

	select descripcion
	  into _nombre_suc
	  from insagen      
	 where codigo_compania = "001"
	   and codigo_agencia  = _cod_sucursal;

	select nombre
	  into _nombre_ramo
	  from prdramo  
	 where cod_ramo = _cod_ramo;

	select nombre,
	       cedula
	  into _nombre,
	       _cedula
	  from cliclien      
	 where cod_cliente = _cod_cliente;

	insert into epa_saldos(
	poliza,
	cedula,
	asegurado,
	forma_pago,
	sucursal,
	ramo,
	saldo,
	corriente,
	dias_30,									
	dias_60,
	dias_90,
	por_vencer
	)
	values(
	_no_documento,
	_cedula,
	_nombre,
	_nombre_pago,
	_nombre_suc,
	_nombre_ramo,
	0,
	0,
	0,
	0,
	0,
	0
	);

end foreach

end procedure





