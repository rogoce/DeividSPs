-- Procedimiento que genera el reporte de los recaudos mayores a 10,000.00
-- 
-- Creado     : 17/06/2013 - Autor: Federico V. Coronado T.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob400;
create procedure sp_cob400(a_periodo char(7), a_rango1 integer, a_rango2 integer)
returning integer,
          varchar(50),
          char(13),
          char(50),
          date,
          varchar(10),
		  dec(16,2),
		  varchar(50),
		  varchar(50),
		  varchar(25);
		  
define _no_documento	 char(13);
define _error			 integer;
define _error_isam		 integer;
define _error_desc		 varchar(100);
define _no_poliza		 varchar(10);
define _fecha            date;
define _monto            dec(16,2);
define _tipo_mov         char(1);
define _cod_contratante  varchar(10);
define _cod_ramo         char(3);
define _nombre           varchar(50);
define _nombre_ramo      varchar(50);
define _no_recibo        varchar(10);
define v_compania_nombre varchar(50);
define _no_remesa		 varchar(10);
define _renglon          integer;
define _tipo_pago        integer;
define _descripcion_pago varchar(50);
define _tipo_cheque      smallint;
define _desc_tipo_cheque  varchar(25);

--set debug file to "sp_cob400.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam, "", _error_desc, "", "", "",'',"","";
end exception

LET  v_compania_nombre = sp_sis01('001'); 
let _tipo_cheque = 0;
if a_rango1 > 0 And a_rango2 > 0 then
	foreach
		select no_poliza, 
			   fecha, 
			   no_recibo, 
			   monto, 
			   tipo_mov,
			   no_remesa,
			   renglon
		  into _no_poliza,
			   _fecha,
			   _no_recibo,
			   _monto,
			   _tipo_mov,
			   _no_remesa,
			   _renglon
		  from cobredet
		 where periodo     = a_periodo
		   and tipo_mov    in ("P","N")
		   and monto       >= a_rango1
		   and monto       <= a_rango2
		   and actualizado = 1
		   
		select cod_contratante, 
			   no_documento, 
			   cod_ramo
		  into _cod_contratante,
			   _no_documento,
			   _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		 select nombre 
		   into _nombre_ramo
		   from prdramo 
		  where cod_ramo = _cod_ramo;

		let _tipo_pago = null;
		foreach	
			select tipo_pago,
				   tipo_cheque	 
			  into _tipo_pago,
				   _tipo_cheque
			  from cobrepag 
			 where no_remesa = _no_remesa
			   and importe   >= 10000

			exit foreach;
		end foreach	
		  
		 select nombre
		   into _nombre
		   from cliclien 
		  where cod_cliente = _cod_contratante;
		  
		  let _descripcion_pago = " ";
		  LET _desc_tipo_cheque = "";
		  if _tipo_pago is null then
			let _tipo_pago = 0;
		  end if
		  
		  if _tipo_pago = 1 then
			let _descripcion_pago = "EFECTIVO";
		  elif _tipo_pago = 2 then
			let _descripcion_pago = "CHEQUE";
			if _tipo_cheque = 1 then
				let _desc_tipo_cheque = "LOCAL PERSONAL";
			elif _tipo_cheque = 2 then
				let _desc_tipo_cheque = "LOCAL DE GERENCIA";
			elif _tipo_cheque = 3 then	
				let _desc_tipo_cheque = "EXTRANJERO PERSONAL";
			elif _tipo_cheque = 4 then	
				let _desc_tipo_cheque = "EXTRANJERO DE GERENCIA";
			end if	
		  elif _tipo_pago = 3 then
			let _descripcion_pago = "CLAVE";
		  elif _tipo_pago = 4 then
			let _descripcion_pago = "TARJETA DE CREDITO";
		  else
			let _descripcion_pago = "REMESA COMPROBANTE";
		  end if
		  
		 RETURN 1, _nombre, _no_documento, _nombre_ramo, _fecha, _no_recibo, _monto, v_compania_nombre, _descripcion_pago, _desc_tipo_cheque WITH RESUME; 
	end foreach
else
	foreach
		select no_poliza, 
			   fecha, 
			   no_recibo, 
			   monto, 
			   tipo_mov,
			   no_remesa,
			   renglon
		  into _no_poliza,
			   _fecha,
			   _no_recibo,
			   _monto,
			   _tipo_mov,
			   _no_remesa,
			   _renglon
		  from cobredet
		 where periodo     = a_periodo
		   and tipo_mov    in ("P","N")
		   and monto       >= 10000
		   and actualizado = 1
		   
		select cod_contratante, 
			   no_documento, 
			   cod_ramo
		  into _cod_contratante,
			   _no_documento,
			   _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		 select nombre 
		   into _nombre_ramo
		   from prdramo 
		  where cod_ramo = _cod_ramo;

		let _tipo_pago = null;
		foreach	
			select tipo_pago,
				   tipo_cheque	 
			  into _tipo_pago,
				   _tipo_cheque
			  from cobrepag 
			 where no_remesa = _no_remesa
			   and importe   >= 10000

			exit foreach;
		end foreach	
		  
		 select nombre
		   into _nombre
		   from cliclien 
		  where cod_cliente = _cod_contratante;
		  
		  let _descripcion_pago = " ";
		  LET _desc_tipo_cheque = "";
		  if _tipo_pago is null then
			let _tipo_pago = 0;
		  end if
		  
		  if _tipo_pago = 1 then
			let _descripcion_pago = "EFECTIVO";
		  elif _tipo_pago = 2 then
			let _descripcion_pago = "CHEQUE";
			if _tipo_cheque = 1 then
				let _desc_tipo_cheque = "LOCAL PERSONAL";
			elif _tipo_cheque = 2 then
				let _desc_tipo_cheque = "LOCAL DE GERENCIA";
			elif _tipo_cheque = 3 then	
				let _desc_tipo_cheque = "EXTRANJERO PERSONAL";
			elif _tipo_cheque = 4 then	
				let _desc_tipo_cheque = "EXTRANJERO DE GERENCIA";
			end if	
		  elif _tipo_pago = 3 then
			let _descripcion_pago = "CLAVE";
		  elif _tipo_pago = 4 then
			let _descripcion_pago = "TARJETA DE CREDITO";
		  else
			let _descripcion_pago = "REMESA COMPROBANTE";
		  end if
		  
		 RETURN 0, _nombre, _no_documento, _nombre_ramo, _fecha, _no_recibo, _monto, v_compania_nombre, _descripcion_pago, _desc_tipo_cheque WITH RESUME; 
	end foreach
end if
end 
end procedure