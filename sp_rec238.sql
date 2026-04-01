-- Procedure para reporte de piezas pendientes por proveedor 													   
-- Creado por: Amado Perez 07/10/2014

drop procedure sp_rec238;

create procedure sp_rec238(a_proveedor VARCHAR(255) default "*", a_fecha_desde date, a_fecha_hasta date)
returning char(10),varchar(100),char(10),char(1),date,char(10),char(5),varchar(50),smallint,dec(16,2),dec(16,2);


define _no_orden        char(10);
define _cod_proveedor   char(10);
define _proveedor       varchar(100);
define _fecha_orden		date;
define _no_parte		char(5);
define _desc_orden		varchar(50);
define _cantidad		smallint;
define _valor			dec(16,2);
define _valor_ori		dec(16,2);
define _tipo_ord_comp   char(1);
define _trans_pend      char(10);
define _monto_pend      dec(16,2);
define _valor_pend      dec(16,2);

define v_filtros          CHAR(255);
define _tipo              CHAR(1);


--SET DEBUG FILE TO "sp_rec238.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

CREATE TEMP TABLE tmp_prov(
  cod_proveedor   char(10),
  proveedor       varchar(100),
  no_orden        char(10),
  tipo_ord_comp   char(1),
  fecha_orden	  date,
  trans_pend      char(10),
  no_parte		  char(5),
  desc_orden	  varchar(50),
  cantidad		  smallint,
  valor			  dec(16,2),
  monto_pend	  dec(16,2),
  seleccionado    SMALLINT  DEFAULT 1 NOT NULL		
  ) WITH NO LOG;

foreach with hold
	select no_orden,
	       cod_proveedor,
	       date(fecha_orden),
	       tipo_ord_comp,
	       trans_pend,
	       monto - monto_pagado 
	  into _no_orden,
	       _cod_proveedor,
	       _fecha_orden,
	       _tipo_ord_comp,
	       _trans_pend,
	       _monto_pend 
	  from recordma
	 where date(fecha_orden) >= a_fecha_desde
	   and date(fecha_orden) <= a_fecha_hasta
	   and pagado <> 1
	 order by 1

    select nombre 
	  into _proveedor
	  from cliclien
	 where cod_cliente = _cod_proveedor;

	foreach
	    select	no_parte,
				desc_orden,
				cantidad - cnt_despachado,
				(valor / cantidad) * (cantidad - cnt_despachado)
		   into _no_parte,
		        _desc_orden,
				_cantidad,
				_valor
		   from	recordde
		  where no_orden = _no_orden
		    and cantidad <> cnt_despachado 
		
		insert into tmp_prov (
		       cod_proveedor,
		       proveedor,    
		       no_orden,     
		       tipo_ord_comp,
		       fecha_orden,	
		       trans_pend,   
		       no_parte,		
		       desc_orden,	
		       cantidad,		
		       valor,
		       monto_pend)
		values(_cod_proveedor,
		       _proveedor,
		       _no_orden,
			   _tipo_ord_comp,
		       _fecha_orden,
			   _trans_pend,
		       _no_parte,
		       _desc_orden,
			   _cantidad,
			   _valor,
			   _monto_pend);
	 end foreach

end foreach

-- Procesos para Filtros

LET v_filtros = "";

IF a_proveedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Proveedor: " ||  TRIM(a_proveedor);

	LET _tipo = sp_sis04(a_proveedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_proveedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prov
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_proveedor IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


FOREACH WITH HOLD
	select cod_proveedor, 
		   proveedor,     
		   no_orden,      
		   tipo_ord_comp, 
		   fecha_orden,	
		   trans_pend,    
		   no_parte,		
		   desc_orden,	
		   cantidad,		
		   valor,
		   monto_pend
	  into _cod_proveedor,	   
		   _proveedor,													 
		   _no_orden,
		   _tipo_ord_comp,
		   _fecha_orden,
		   _trans_pend,
		   _no_parte,
		   _desc_orden,
		   _cantidad,
		   _valor,
		   _monto_pend
	  from tmp_prov
	 where seleccionado = 1	  
	order by 2, 3 
		return _cod_proveedor,
		       _proveedor,
		       _no_orden,
			   _tipo_ord_comp,
		       _fecha_orden,
			   _trans_pend,
		       _no_parte,
		       _desc_orden,
			   _cantidad,
			   _valor,
			   _monto_pend with resume;

END FOREACH

drop table tmp_prov;

end procedure