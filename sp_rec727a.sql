-- PROCESO DIARIO DE AJUSTE DE ORDEN DE COMPRA/REPARACION
-- Procedimiento para crear Requisiciones de pago a Proveedores con las transacciones que estaban pendientes de
-- aprobacion WF.

-- Creado:     10/10/2014 - Autor: Armando Moreno M.
-- Modificado: 10/10/2014 - Armando Moreno M.

DROP PROCEDURE sp_rec727a;

CREATE PROCEDURE "informix".sp_rec727a()
RETURNING CHAR(10), CHAR(5);

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

SET ISOLATION TO DIRTY READ;


--set debug file to "sp_rec727a.trc";
--trace on;

CREATE TEMP TABLE tmp_prov(
	cod_proveedor CHAR(10),
	no_ajus_orden CHAR(10)
	) WITH NO LOG;


begin 
{on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception}


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

let _cod_proveedor = null;

foreach
	select cod_proveedor,
	       no_ajus_orden
	  into _cod_proveedor,
	       _no_ajus_orden
	  from tmp_prov

	return _cod_proveedor, _no_ajus_orden with resume;

end foreach	

drop table tmp_prov;

--IF _cod_proveedor is null then
--	return '0','0';
--END IF

end
END PROCEDURE