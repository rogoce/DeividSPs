-- Procedimiento para crear transaccion de pago a proveedor al momento de actualizar un ajuste a orden de compra o reparacion,
-- y los montos son diferentes.
-- Creado:     07/10/2014 - Autor: Armando Moreno M.
-- Modificado: 07/10/2014 - Armando Moreno M.

DROP PROCEDURE ap_rec724;

CREATE PROCEDURE "informix".ap_rec724(a_no_ajuste char(5))
RETURNING SMALLINT, DECIMAL(16,2);

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
define _sum_valor           DECIMAL(16,2);
define _sum_valor_ajus      DECIMAL(16,2);


SET ISOLATION TO DIRTY READ;

--set debug file to "ap_rec724.trc";
--trace on;

begin

ON EXCEPTION SET _error, _error_isam, _error_desc
 	RETURN _error, _error_desc;
END EXCEPTION


let _monto_factura = 0;
let _dif           = 0;
let _por_precio    = 0;
let _dif_precio    = 0;
let _monto_alq     = 0;

--TRANSACCIONES

select cod_proveedor
  into _cod_proveedor
  from recordam
 where no_ajus_orden = a_no_ajuste;

let _flag = 0;

foreach	with hold 
	select no_orden,
		   renglon,
		   monto_orden
	  into _no_orden,
		   _renglon,
		   _monto_orden
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

    --let _dif = ROUND(_dif * 1.07,2);
	 
	--return _renglon, _dif with resume;
	
	let _dif = ROUND(_valor * 1.07,2) - ROUND(_valor_ajust * 1.07,2);
	
	--return _renglon, _dif with resume;

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
			 
			 --return _renglon, _monto_orden + _dif_precio with resume;


			 let _flag = 1;
	end if

	let _por_precio = 0;

	if (_despachado <> _cnt_despachado) then

	 let _dif = _dif + _dif_precio;

	 if _dif > 0 then
		 let _dif = _dif * -1;	 --transaccion negativa
		 
		 return _renglon, _monto_orden + _dif with resume;


		 let _dif = _dif * -1;	 --transaccion positiva
		 
	 	--return _renglon, _dif with resume;


		 let _flag = 1;

	 elif _dif < 0 then
		 						 --transaccion negativa
	 	return _renglon, _monto_orden + _dif with resume;
						 

		 let _dif = _dif * -1;	 --transaccion positiva
		 --return _renglon, _dif with resume;

																											  
		 let _flag = 1;
	 end if
	end if
end foreach


end

END PROCEDURE