-- Procedimiento para crear transaccion de pago a proveedor al momento de actualizar un ajuste a orden de compra o reparacion,
-- y los montos son diferentes.
-- Creado:     07/10/2014 - Autor: Armando Moreno M.
-- Modificado: 07/10/2014 - Armando Moreno M.

DROP PROCEDURE sp_rec724;

CREATE PROCEDURE "informix".sp_rec724(a_no_ajuste char(5), a_user_added char(8))
RETURNING SMALLINT, VARCHAR(90);

DEFINE _no_reclamo			CHAR(10);
DEFINE _transaccion			CHAR(10);
DEFINE _error   			INTEGER;
DEFINE _descripcion         VARCHAR(50); 
DEFINE _no_orden            CHAR(10);
DEFINE _dif			        DEC(16,2);
DEFINE _renglon             smallint;
DEFINE _genera_incidente    SMALLINT;
DEFINE _cod_proveedor       char(10);
DEFINE _monto_factura       DECIMAL(16,2);
DEFINE _flag				SMALLINT;
DEFINE _cnt_despachado      SMALLINT;
DEFINE _despachado      	SMALLINT;
define _valor_ajust			DECIMAL(16,2);
define _valor				DECIMAL(16,2);
define _por_precio          smallint;
define _error_desc			char(50);
define _error_isam          integer;
define _dif_precio          DECIMAL(16,2);
define _monto_orden_acum	DECIMAL(16,2);
define _monto_fact_acum 	DECIMAL(16,2);
define _monto_orden         DECIMAL(16,2);
define _numrecla			char(18);
define _tipo_opc            smallint;
define _monto_alq           DECIMAL(16,2);
define _cnt_recordad        SMALLINT;
define _pagado              SMALLINT;
define _cantidad            SMALLINT;


SET ISOLATION TO DIRTY READ;

if a_no_ajuste = '06076' then
	set debug file to "sp_rec724.trc";
	trace on;
end if
	
begin

ON EXCEPTION SET _error, _error_isam, _error_desc
 	RETURN _error, _error_desc;
END EXCEPTION


let _monto_factura = 0;
let _dif           = 0;
let _por_precio    = 0;
let _dif_precio    = 0;
let _monto_alq     = 0;
let _error       = 0;

--TRANSACCIONES

select cod_proveedor
  into _cod_proveedor
  from recordam
 where no_ajus_orden = a_no_ajuste;

let _flag = 0;

foreach	 
	select no_orden,
		   renglon
	  into _no_orden,
		   _renglon
	  from recordad
	 where no_ajus_orden =  a_no_ajuste
	   and monto         <> monto_orden
	   and tipo_opc      = 0

	select sum(valor) -	sum(valor_ajust),
	       sum(cantidad),
	       sum(valor),
	       sum(cnt_despachado),
	       sum(valor_ajust)
	  into _dif,
	       _despachado,
	       _valor,
		   _cnt_despachado,
		   _valor_ajust
	  from recordadd
	 where no_ajus_orden = a_no_ajuste
	   and no_orden      = _no_orden;

    let _dif = ROUND(_dif * 1.07,2);

    -- Buscando diferencia en precios

	select (sum(valor_ajust) - sum(valor/cantidad * cnt_despachado))
	  into _dif_precio
	  from recordadd
	 where no_ajus_orden = a_no_ajuste
	   and no_orden      = _no_orden;

    let _dif_precio = ROUND(_dif_precio * 1.07,2);
	--
   	select no_reclamo,
	       trans_pend
	  into _no_reclamo,
	       _transaccion
	  from recordma
	 where no_orden = _no_orden;

	let _por_precio = 0;

    if _dif_precio <> 0 then	--Por diferencia de precio
			select no_orden,
				   renglon
			  into _no_orden,
				   _renglon
			  from recordad
			 where no_ajus_orden = a_no_ajuste
			   and no_orden      = _no_orden
			   and tipo_opc      = 0;

			 let _por_precio = 1;
			 call sp_rec725(_no_reclamo, _dif_precio, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio, 0,_no_orden) returning _error, _descripcion;

			 let _flag = 1;
	end if

	let _por_precio = 0;

	if (_despachado <> _cnt_despachado) then

	 let _dif = _dif + _dif_precio;

	 if _dif > 0 then
		 let _dif = _dif * -1;	 --transaccion negativa
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio, 0,_no_orden) returning _error, _descripcion;

		 let _dif = _dif * -1;	 --transaccion positiva
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio, 0,_no_orden) returning _error, _descripcion;

		 let _flag = 1;

	 elif _dif < 0 then
		 						 --transaccion negativa
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio, 0,_no_orden) returning _error, _descripcion;

		 let _dif = _dif * -1;	 --transaccion positiva
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio, 0,_no_orden) returning _error, _descripcion;
																											  
		 let _flag = 1;
	 end if
	end if
end foreach

-- Por flete, alineamiento, deducible en caja o deducible exonerado, Alquiler de auto
foreach
	select no_orden,
		   renglon,
		   tipo_opc,
		   monto,
		   transaccion_alq,
		   monto - monto_orden
	  into _no_orden,
		   _renglon,
		   _tipo_opc,
		   _monto_factura,
		   _transaccion,
		   _monto_alq
	  from recordad
	 where no_ajus_orden =  a_no_ajuste
	   and tipo_opc <> 0
	   and tipo_opc <> 5

	if _tipo_opc not in (6,7) then
	   	select no_reclamo,
		       trans_pend
		  into _no_reclamo,
		       _transaccion
		  from recordma
		 where no_orden = _no_orden;
	elif _tipo_opc = 6 then
	   	select no_reclamo
		  into _no_reclamo
		  from rectrmae
		 where transaccion = _transaccion;

		 let _monto_factura = _monto_alq;
    elif _tipo_opc = 7 then -- Nota de credito
		if _transaccion is not null and trim(_transaccion) <> "" then
			select no_reclamo
			  into _no_reclamo
			  from rectrmae
			 where transaccion = _transaccion;
		else
			select no_reclamo,
				   trans_pend
			  into _no_reclamo,
				   _transaccion
			  from recordma
			 where no_orden = _no_orden;
		end if
	end if
	
	if _monto_factura <> 0 then
		call sp_rec725(_no_reclamo, _monto_factura, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, 0, _tipo_opc,_no_orden) returning _error, _descripcion;
		if _error <> 0 then
			exit foreach;
		end if
		let _flag = 1;
	end if
end foreach

if _error <> 0 then
	return _error, _descripcion;
end if

if _flag = 1 then
	update recordam
	   set actualizado   = 2
	 where no_ajus_orden = a_no_ajuste;
 
  	 return 0, "Las Transacciones del Ajuste, se ha enviado a aprobacion en Workflow.";
end if

call sp_rec726(a_no_ajuste, _cod_proveedor) returning _error, _descripcion, _genera_incidente;

if _error <> 0 then
	return _error, 'Ocurrio un error al generar la Requisicion.';
end if

--Actualizacion campo pagado en 1 a la orden en recordma

let _monto_orden_acum = 0.00;
let _monto_fact_acum  = 0.00; 

foreach	 
	select monto,
	       no_orden,
		   monto_orden
	  into _monto_factura,
	       _no_orden,
		   _monto_orden
	  from recordad
	 where no_ajus_orden = a_no_ajuste

   	update recordma
	   set pagado       = 1,
	       monto_pagado = monto_pagado + _monto_factura
	 where no_orden     = _no_orden;

      	let _monto_orden_acum = _monto_orden_acum + _monto_orden;
      	let _monto_fact_acum  = _monto_fact_acum  + _monto_factura; 

end foreach

update recordam
   set actualizado   = 1,
       monto_orden   = _monto_orden_acum,
	   monto_factura = _monto_fact_acum,
	   fecha_actualizado = current
 where no_ajus_orden = a_no_ajuste;

--delete from recordadd where no_ajus_orden =	a_no_ajuste and despachado = 0;

return 0, "Actualizacion Exitosa";
end

END PROCEDURE