-- Procedimiento para crear la descripcion de la transaccion.

-- Creado:     29/10/2014 - Autor: Armando Moreno M.
-- Modificado: 29/10/2014 -        Armando Moreno M.

DROP PROCEDURE sp_rec728;

CREATE PROCEDURE "informix".sp_rec728(a_no_tranrec char(10), a_monto dec(16,2), a_concepto smallint, a_monto_pagar dec(16,2),a_no_ajus_orden char(10), a_orden char(10),a_por_precio smallint)
RETURNING SMALLINT, CHAR(50);

--Cuando es de pago y el monto es positivo, entonces se barre recordadd con lo no despachado


DEFINE _no_reclamo			CHAR(10);
DEFINE _transaccion			CHAR(10);
DEFINE _error   			INTEGER;
DEFINE _descripcion         VARCHAR(60); 
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
define _tipo_opc            smallint;
define _cant,i              smallint;
define _desc_orden          varchar(50);
define _valor_pend          DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rec728.trc";
--trace on;

begin

ON EXCEPTION SET _error, _error_isam, _error_desc
 	RETURN _error, _error_desc;
END EXCEPTION

let _desc_orden = '';

let _flag = 0;

let _valor		 = 0;
let _valor_ajust = 0;
let _valor_pend  = 0;

if a_concepto = 1 then       --Alineamiento
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE ALINEAMIENTO.';
	let _cant = 1;
elif a_concepto = 2 then     --Flete
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE FLETE.';
	let _cant = 1;
elif a_concepto = 3 then     --DED EN CAJA
	let _descripcion = 'CLIENTE PAGA DEDUCIBLE EN ANCON ' || a_monto;
	let _cant = 1;
elif a_concepto = 4 then     --DED EXONERADO
	let _descripcion = 'DEDUCIBLE EXONERADO';
	let _cant = 1;
elif a_concepto = 6 then  -- ALQUILER
	let _descripcion = 'SE REGISTRA AJUSTE PARA PAGAR: ' || a_monto_pagar;
	let _cant = 1;
elif a_concepto = 7 then -- NOTA DE CREDITO
	let _descripcion = 'SE REGISTRA NOTA DE CREDITO PARA LA ORDEN: ' || a_orden;
	let _cant = 1;
elif a_concepto = 0 then     --Pago
	   if a_por_precio = 0 then

		   select sum(valor - valor_ajust) * 1.07
		     into _valor_pend
	         from recordadd
	        where no_ajus_orden =  a_no_ajus_orden
	          and no_orden      = a_orden
              and despachado    in(0,2);

		   let i = 1;
		   INSERT INTO rectrde2(
		   no_tranrec,
		   renglon,
		   desc_transaccion
		   )
		   VALUES(
		   a_no_tranrec,
		   i,
		   'PENDIENTE: '||_valor_pend
		   );

		   foreach 
				select desc_orden
				  into _desc_orden
			      from recordadd
			     where no_ajus_orden = a_no_ajus_orden
			       and no_orden      = a_orden
		           and despachado    in(0,2)

			      let _descripcion = trim(_desc_orden);
				  let i = i + 1;

					INSERT INTO rectrde2(
					no_tranrec,
					renglon,
					desc_transaccion
					)
					VALUES(
					a_no_tranrec,
					i,
					_descripcion
					);

				  let _flag = 1;
				  
		   end foreach
	   else

		   let i = 1;
		   INSERT INTO rectrde2(
		   no_tranrec,
		   renglon,
		   desc_transaccion
		   )
		   VALUES(
		   a_no_tranrec,
		   i,
		   'SE AJUSTA POR DIFERENCIA DE PRECIO:'
		   );

		   foreach 
				select desc_orden,
				       valor,
					   valor_ajust
				  into _desc_orden,
				       _valor,
					   _valor_ajust
			      from recordadd
			     where no_ajus_orden = a_no_ajus_orden
			       and no_orden      = a_orden
		           and despachado    = 1
				   and valor <> valor_ajust

			      let _descripcion = trim(_desc_orden) || 'DE: ' || _valor || 'A: ' || _valor_ajust;
				  let i = i + 1;

					INSERT INTO rectrde2(
					no_tranrec,
					renglon,
					desc_transaccion
					)
					VALUES(
					a_no_tranrec,
					i,
					_descripcion
					);

				  let _flag = 1;
				  
		   end foreach

	   end if
elif a_concepto = 8 then -- MECANICA
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE MECANICA.';
	let _cant = 1;
elif a_concepto = 9 then -- AIRE ACONDICIONADO
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE AIRE ACONDICIONADO.';
	let _cant = 1;
elif a_concepto = 10 then -- ELECTROMECANICA
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE ELECTROMECANICA.';
	let _cant = 1;
elif a_concepto = 11 then -- CHAPISTERIA
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE CHAPISTERIA.';
	let _cant = 1;
elif a_concepto = 12 then -- OTROS
	let _descripcion = 'TRANSACCION PARA PAGAR: ' || a_monto  || ' EN CONCEPTO DE OTROS.';
	let _cant = 1;
end if

if _flag <> 1 then

	for i = 1 to _cant

		INSERT INTO rectrde2(
		no_tranrec,
		renglon,
		desc_transaccion
		)
		VALUES(
		a_no_tranrec,
		i,
		_descripcion
		);

	end for

end if

return 0, "Actualizacion Exitosa";
end

END PROCEDURE