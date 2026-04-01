-- PROCESO DIARIO DE AJUSTE DE ORDEN DE COMPRA/REPARACION
-- Procedimiento para crear Requisiciones de pago a Proveedores con las transacciones que estaban pendientes de
-- aprobacion WF.

-- Creado:     10/10/2014 - Autor: Armando Moreno M.
-- Modificado: 10/10/2014 - Armando Moreno M.

DROP PROCEDURE sp_rec727;

CREATE PROCEDURE "informix".sp_rec727()
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
DEFINE _no_ajus_orden       char(10);
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
DEFINE _monto_precio       	DECIMAL(16,2);
DEFINE _tipo_ajuste         CHAR(1);


SET ISOLATION TO DIRTY READ;

if 
set debug file to "sp_rec727.trc";
trace on;

CREATE TEMP TABLE tmp_prov(
	cod_proveedor CHAR(10),
	no_ajus_orden CHAR(10)
	) WITH NO LOG;


begin work;
begin
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc;
end exception


let _monto_factura = 0;
let _dif           = 0;
let _flag          = 0;
let _flag2         = 0;
let _flag3         = 0;
let _cnt           = 0;
let _transaccion_pos = null;
let _no_tranrec_pre  = null;
let _no_tranrec_neg  = null;
let _no_tranrec_pos  = null;
let _monto_orden     = 0;


--VERIFICANDO QUE LAS TRANSACCIONES POSITIVAS Y NEGATIVAS ESTEN ACTUALIZADAS

foreach
	select cod_proveedor,
	       no_ajus_orden
	  into _cod_proveedor,
	       _no_ajus_orden
	  from recordam
	 where actualizado = 2
  	   and no_ajus_orden = '02017' 
  order by no_ajus_orden

	let _flag  = 0;
	let _flag2 = 0;
	let _flag3 = 0;
	let _cnt   = 0;

	foreach	 
		select no_tranrec_neg
		  into _no_tranrec_neg
		  from recordad
		 where no_ajus_orden =  _no_ajus_orden
		   and no_tranrec_neg is not null

        select count(*)
		  into _cnt
		  from rectrmae
		 where no_tranrec = _no_tranrec_neg
		   and actualizado = 1;

        if _cnt = 0 then
			let _flag = 1;	--se marca por que aun no esta actualizada la transaccion
		end if

	end foreach

	let _cnt = 0;

	foreach	 
		select no_tranrec_pos
		  into _no_tranrec_pos
		  from recordad
		 where no_ajus_orden  =  _no_ajus_orden
		   and no_tranrec_pos is not null

        select count(*)
		  into _cnt
		  from rectrmae
		 where no_tranrec  = _no_tranrec_pos
		   and actualizado = 1;

        if _cnt = 0 then
			let _flag2 = 1;
		end if

	end foreach

	let _cnt = 0;

   	foreach	 
		select no_tranrec_pre
		  into _no_tranrec_pre
		  from recordad
		 where no_ajus_orden =  _no_ajus_orden
		   and no_tranrec_pre is not null

        select count(*)
		  into _cnt
		  from rectrmae
		 where no_tranrec = _no_tranrec_pre
		   and actualizado = 1;

        if _cnt = 0 then
			let _flag3 = 1;	--se marca por que aun no esta actualizada la transaccion
		end if

	end foreach

	if _no_tranrec_pre is null then
	    let _flag3 = 0;
	end if

	if _flag = 0 AND _flag2 = 0 AND _flag3 = 0 then --Todas las transacciones negativas y positivas o por precio estan aprobadas

		insert into tmp_prov(cod_proveedor,no_ajus_orden) values(_cod_proveedor,_no_ajus_orden);
		
	end if

end foreach


foreach
	select cod_proveedor,
	       no_ajus_orden
	  into _cod_proveedor,
	       _no_ajus_orden
	  from tmp_prov

	call sp_rec726(_no_ajus_orden, _cod_proveedor) returning _error, _descripcion, _genera_incidente; --Llamado a procedimiento para crear Requisicion

	if _error <> 0 then
		rollback work;
		return _error, _descripcion;
	end if

    select tipo_ajuste
	  into _tipo_ajuste
	  from recordam
	 where no_ajus_orden = _no_ajus_orden;

	--Actualizacion campo pagado en 1 a la orden en recordma

  	let _monto_orden_acum = 0.00;
  	let _monto_fact_acum  = 0.00; 

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
		 where no_ajus_orden =  _no_ajus_orden
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

end foreach	

drop table tmp_prov;
end
commit work;
return 0, "Actualizacion Exitosa";


END PROCEDURE