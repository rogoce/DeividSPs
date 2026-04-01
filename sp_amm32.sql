-- POLIZAS VIGENTES 
--

--   DROP procedure sp_amm32;
   CREATE procedure "informix".sp_amm32(a_fecha date)

   RETURNING CHAR(50),CHAR(5),INT,INT;

    DEFINE _no_poliza	 	CHAR(10);
    DEFINE v_desc_prod  	CHAR(50);
    DEFINE _no_documento    CHAR(20);
    DEFINE _cod_producto    CHAR(5);
	define _cantidad		integer;
	define v_filtros		CHAR(255);
	define _pro_cotizacion,_cant  integer;

	create temp table tmp_temporal(
	no_poliza       char(10),
	cod_producto	char(5),
	cantidad		integer,
	PRIMARY KEY(no_poliza,cod_producto)
	) with no log;


    CALL sp_pro03("001","001",a_fecha,"002;") RETURNING v_filtros;

foreach
	  select no_poliza
	    into _no_poliza
	    from temp_perfil
	   where seleccionado = 1

	  foreach	
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza

    	BEGIN
          ON EXCEPTION IN(-239)

          END EXCEPTION
			insert into tmp_temporal
			values (_no_poliza,_cod_producto, 1);

    	END

	  end foreach
end foreach

foreach
	  select cod_producto,
			 sum(cantidad)
	    into _cod_producto,
		     _cant
		from tmp_temporal
	   group by 1
	   order by 1

	  select nombre,
			 pro_cotizacion
	    into v_desc_prod,
			 _pro_cotizacion
	    from prdprod
	   where cod_producto = _cod_producto;

	RETURN  v_desc_prod, 
			_cod_producto,
			_cant, 
			_pro_cotizacion
			WITH RESUME;
end foreach

DROP TABLE temp_perfil;
DROP TABLE tmp_temporal;

END PROCEDURE;
