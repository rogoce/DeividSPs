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


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rec724.trc";
--trace on;

begin

ON EXCEPTION SET _error, _error_isam, _error_desc
 	RETURN _error, _error_desc;
END EXCEPTION


let _monto_factura = 0;
let _dif           = 0;
let _por_precio    = 0;
let _dif_precio = 0;

--TRANSACCIONES

select cod_proveedor
  into _cod_proveedor
  from recordam
 where no_ajus_orden = a_no_ajuste;

let _flag = 0;

foreach	 
	select monto_orden - monto,
	       no_orden,
		   renglon
	  into _dif,
	       _no_orden,
		   _renglon
	  from recordad
	 where no_ajus_orden =  a_no_ajuste
	   and monto         <> monto_orden

	select sum(cantidad),
	       sum(valor),
	       sum(cnt_despachado),
	       sum(valor_ajust)
	  into _despachado,
	       _valor,
		   _cnt_despachado,
		   _valor_ajust
	  from recordadd
	 where no_ajus_orden = a_no_ajuste
	   and no_orden      = _no_orden;

    -- Buscando diferencia en precios

	select (sum(valor_ajust) - sum(valor/cantidad * cnt_despachado))
	  into _dif_precio
	  from recordadd
	 where no_ajus_orden = a_no_ajuste
	   and no_orden      = _no_orden;

   	select no_reclamo,
	       trans_pend
	  into _no_reclamo,
	       _transaccion
	  from recordma
	 where no_orden = _no_orden;

	let _por_precio = 0;
    if (_despachado = _cnt_despachado) And (_valor < _valor_ajust) then	--Por precio mayor
			select monto - monto_orden,
			       no_orden,
				   renglon
			  into _dif,
			       _no_orden,
				   _renglon
			  from recordad
			 where no_ajus_orden = a_no_ajuste
			   and no_orden      = _no_orden;

			 let _por_precio = 1;
			 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;

			 let _flag = 1;
	elif (_despachado = _cnt_despachado) And (_valor > _valor_ajust) then	--Por precio menor

			select monto_orden - monto,
			       no_orden,
				   renglon
			  into _dif,
			       _no_orden,
				   _renglon
			  from recordad
			 where no_ajus_orden = a_no_ajuste
			   and no_orden      = _no_orden;

			 let _dif = _dif * -1;
			 let _por_precio = 2;
			 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;

			 let _flag = 1;

	elif (_despachado <> _cnt_despachado) then

	 if _dif > 0 then
		 let _dif = _dif * -1;	 --transaccion negativa
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;

		 let _dif = _dif * -1;	 --transaccion positiva
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;

		 let _flag = 1;

	 elif _dif < 0 then
		 						 --transaccion negativa
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;

		 let _dif = _dif * -1;	 --transaccion positiva
		 call sp_rec725(_no_reclamo, _dif, _cod_proveedor, _transaccion, a_no_ajuste, _renglon, a_user_added, _por_precio) returning _error, _descripcion;
																											  
		 let _flag = 1;
	 end if
	end if
end foreach

if _flag = 1 then
	update recordam
	   set actualizado   = 2
	 where no_ajus_orden = a_no_ajuste;
 
  	 return 0, "Las transacciones del Ajuste, se ha enviado a aprobacion en Workflow.";
end if


call sp_rec726(a_no_ajuste, _cod_proveedor) returning _error, _descripcion, _genera_incidente;

if _error <> 0 then
	return 1, 'Ocurrio un error al generar la Requisicion.';
end if

--Actualizacion campo pagado en 1 a la orden en recordma

foreach	 
	select monto,
	       no_orden
	  into _monto_factura,
	       _no_orden
	  from recordad
	 where no_ajus_orden = a_no_ajuste

   	update recordma
	   set pagado       = 1,
	       monto_pagado = monto_pagado + _monto_factura
	 where no_orden     = _no_orden;

end foreach

update recordam
   set actualizado   = 1
 where no_ajus_orden = a_no_ajuste;

--delete from recordadd where no_ajus_orden =	a_no_ajuste and despachado = 0;

return 0, "Actualizacion Exitosa";
end

END PROCEDURE