-- Procedure para reporte de piezas pendientes por proveedor 													   
-- Creado por: 06/06/2018 - Hgiron Caso:28306 piezas compradas

drop procedure sp_rec281;

create procedure sp_rec281(a_proveedor VARCHAR(255) default "*", a_fecha_desde date, a_fecha_hasta date)
returning char(20) as no_reclamo,     --•	N° de Reclamo
		varchar(50) as desc_pieza,  --•	Nombre de la pieza
		char(5) as no_parte,        --    No Parte
		smallint as cantidad,       --    Cantidad
		dec(16,2) as Costo_Pieza,   --•	Costo de la pieza
		char(10) as no_orden,       --    No Orden
		date as fecha_orden,        --•	Fecha de la orden de compra
		char(10) as cod_proveedor,  --•	Codigo Proveedor al cual se le compro
		varchar(100) as proveedor,  --•	Proveedor al cual se le compro
		char(50) as marca,          --•	Marca del Auto
		char(50) as modelo,         --•	Modelo del Auto
		smallint as anio_auto,      --•	Año del Auto
		varchar(30) as chasis;      --•	Serial de Chasis


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
define _no_reclamo		  char(10);
define _no_poliza		  char(10);
define _no_unidad         char(5);
define _cod_marca,_cod_modelo char(5);
define _n_marca,_n_modelo char(50);
define _ano_auto          smallint;
define _placa             char(10);
define _no_motor          char(30);
define _no_chasis		  varchar(30);
define _numrecla   		  char(20);

  

--SET DEBUG FILE TO "sp_rec281.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

CREATE TEMP TABLE tmp_prov(
  cod_proveedor   char(10),
  proveedor       varchar(100), --	Proveedor al cual se le compro
  no_orden        char(10),
  tipo_ord_comp   char(1),
  fecha_orden	  date,         --  Fecha de la orden de compra
  trans_pend      char(10),
  no_parte		  char(5),
  desc_orden	  varchar(50),  --	Nombre de la pieza
  cantidad		  smallint,
  valor			  dec(16,2),    -- 	Costo de la pieza
  monto_pend	  dec(16,2),
  no_reclamo		char(20),   -- 	Numero Reclamo  
  n_marca           char(50),   --	Marca del Auto
  n_modelo          char(50),   --	Modelo del Auto
  ano_auto          smallint,   --	Año del Auto
  no_chasis		  varchar(30),  --	Serial de Chasis
  seleccionado    SMALLINT  DEFAULT 1 NOT NULL		
  ) WITH NO LOG;  
  
    

foreach with hold
	select no_orden,
	       cod_proveedor,
	       date(fecha_orden),
	       tipo_ord_comp,
	       trans_pend,
		   no_reclamo,
	       monto - monto_pagado 
	  into _no_orden,
	       _cod_proveedor,
	       _fecha_orden,
	       _tipo_ord_comp,
	       _trans_pend,
		   _no_reclamo,
	       _monto_pend 
	  from recordma
	 where date(fecha_orden) >= a_fecha_desde
	   and date(fecha_orden) <= a_fecha_hasta
	   and pagado = 1
	 order by 1

    select nombre 
	  into _proveedor
	  from cliclien
	 where cod_cliente = _cod_proveedor;
	 

	select no_poliza,
		   no_unidad,
		   numrecla
	  into _no_poliza,
		   _no_unidad,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	  
	   let _no_motor = null;
	select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _no_motor is null then
		foreach
			select no_motor
			   into _no_motor
			   from endmoaut
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad
				exit foreach;
		end foreach
	end if

    select cod_marca,cod_modelo,ano_auto,no_chasis
      into _cod_marca,_cod_modelo,_ano_auto,_no_chasis
      from emivehic c
     where no_motor = _no_motor;
	
	select nombre
      into _n_marca
	  from emimarca 
	 where cod_marca = _cod_marca;
		
	 select nombre
	   into _n_modelo
	   from emimodel 
	  where cod_modelo = _cod_modelo;	
 

	foreach
	    select	no_parte,
				desc_orden,
				cnt_despachado  ,
				(valor / cantidad) * (cnt_despachado )
		   into _no_parte,
		        _desc_orden,
				_cantidad,
				_valor
		   from	recordde
		  where no_orden = _no_orden	
		
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
		       monto_pend,
			   no_reclamo,
			   n_marca,
			   n_modelo,
			   ano_auto,
			   no_chasis)
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
			   _monto_pend,
			   _numrecla, --_no_reclamo,
			   _n_marca,
			   _n_modelo,
			   _ano_auto,
			   _no_chasis			   
			   );
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
	select no_reclamo,
		   desc_orden,			
		   no_parte,		
		   cantidad,		   
		   valor,		  
		   no_orden,      
		   fecha_orden,		   
           cod_proveedor, 
		   proveedor,     		   
		   n_marca,
		   n_modelo,
		   ano_auto,
		   no_chasis
	  into _numrecla, --_no_reclamo,		   
		   _desc_orden,
		   _no_parte,
		   _cantidad,		   
		   _valor,		
		   _no_orden,		   
		   _fecha_orden,
		   _cod_proveedor,	   
		   _proveedor,													 
		   _n_marca,
		   _n_modelo,
		   _ano_auto,
		   _no_chasis
	  from tmp_prov
	 where seleccionado = 1	  
	order by proveedor, no_orden 	


		return _numrecla, --_no_reclamo,
		       _desc_orden,
		       _no_parte,
			   _cantidad,			   
			   _valor,			
			   _no_orden,
               _fecha_orden,			   
			   _cod_proveedor,
		       _proveedor,
			   _n_marca,
			   _n_modelo,
			   _ano_auto,
			   _no_chasis
		   with resume;

END FOREACH



drop table tmp_prov;

end procedure