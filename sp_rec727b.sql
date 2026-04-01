-- PROCESO DIARIO DE AJUSTE DE ORDEN DE COMPRA/REPARACION
-- Procedimiento para crear Requisiciones de pago a Proveedores con las transacciones que estaban pendientes de
-- aprobacion WF.

-- Creado:     10/10/2014 - Autor: Armando Moreno M.
-- Modificado: 10/10/2014 - Armando Moreno M.

DROP PROCEDURE sp_rec727b;

CREATE PROCEDURE "informix".sp_rec727b(_no_ajus_orden char(5))
RETURNING SMALLINT, VARCHAR(50);

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
DEFINE _flag,_flag2,_flag3  SMALLINT;
DEFINE _no_tranrec_neg      CHAR(10);
DEFINE _no_tranrec_pos      CHAR(10);
DEFINE _no_tranrec_pre      CHAR(10);
DEFINE _cnt                 SMALLINT;
DEFINE _transaccion_pos     CHAR(10);
DEFINE _monto_orden       	DECIMAL(16,2);
DEFINE _monto_orden_acum	DECIMAL(16,2);
DEFINE _monto_fact_acum 	DECIMAL(16,2);
DEFINE _error_isam          INTEGER;
DEFINE _error_desc          CHAR(50);
DEFINE _cantidad			INTEGER;
DEFINE _cnt_despachado		INTEGER;
DEFINE _pagado    			SMALLINT;
DEFINE _tipo_ajuste         CHAR(1);

SET ISOLATION TO DIRTY READ;

if _no_ajus_orden = '03131' then
  set debug file to "sp_rec727b.trc";
  trace on;
end if

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

	--Actualizacion campo pagado en 1 a la orden en recordma

let _monto_orden_acum = 0.00;
let _monto_fact_acum  = 0.00;

select tipo_ajuste
  into _tipo_ajuste
  from recordam
 where no_ajus_orden = _no_ajus_orden;
 

foreach	 
		select 
		       monto_orden,
		       monto,
		       no_orden,
			   no_tranrec_pos
		  into _monto_orden,
		       _monto_factura,
		       _no_orden,
			   _no_tranrec_pos
		  from recordad
		 where no_ajus_orden = _no_ajus_orden
		   and tipo_opc = 0 

		if _no_tranrec_pos is not null then
			select transaccion
			  into _transaccion_pos
			  from rectrmae
			 where no_tranrec = _no_tranrec_pos;

		   	update recordma
			   set trans_pend = _transaccion_pos
			 where no_orden   = _no_orden;

        end if

        select sum(cantidad), 
               sum(cnt_despachado)
		  into _cantidad,
		       _cnt_despachado
          from recordde
         where no_orden = _no_orden;

        let	_pagado = 0;

        if _cantidad = _cnt_despachado then
			let	_pagado = 1;	
		end if

	   	update recordma
		   set monto_pagado = monto_pagado + _monto_factura,
		       pagado       = _pagado
		 where no_orden     = _no_orden;

      	let _monto_orden_acum = _monto_orden_acum + _monto_orden;
      	let _monto_fact_acum  = _monto_fact_acum  + _monto_factura; 
        
end foreach

if _tipo_ajuste = 'A' then

	select sum(monto_orden),
	       sum(monto)
	  into _monto_orden_acum,
	       _monto_fact_acum
	  from recordad
	 where no_ajus_orden =  _no_ajus_orden;

end if


update recordam
   set actualizado       = 1,
       monto_orden       = _monto_orden_acum,
	   monto_factura     = _monto_fact_acum,
	   fecha_actualizado = current
 where no_ajus_orden     = _no_ajus_orden;


return 0, "Actualizacion Exitosa";

end
END PROCEDURE