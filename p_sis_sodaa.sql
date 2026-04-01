
-- Creado    : 11/05/2007 - Autor: Armando Moreno

--drop procedure sp_sissd;

create procedure sp_sissd()
 returning char(20),char(5),char(5),char(5),char(50),char(50),char(3),char(3),char(50);


define _no_poliza		char(10);
define _no_documento	char(20);
define _no_unidad       char(5);
define _cod_producto    char(5);
define _cod_cobertura   char(5);
define _cod_cobertura2  char(5);
define _nom_prod        char(50);
define _nom_cobe        char(50);
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _sucursal_origen char(3);
define _nom_subramo     char(50);
define _cant		    smallint;

SET ISOLATION TO DIRTY READ;

FOREACH                 
	 {SELECT no_documento
	   into _no_documento
	   FROM emipomae
	  WHERE	actualizado = 1
	    and periodo[1,4] = "2007"
		and cod_ramo = "002"	
	  GROUP BY 1}

	 SELECT a
	   into _no_documento
	   FROM soda2
	  GROUP BY 1

	 let _no_poliza = sp_sis21(_no_documento);

	 SELECT cod_ramo,
	        cod_subramo,
			sucursal_origen
	   INTO	_cod_ramo,
	        _cod_subramo,
			_sucursal_origen
	   FROM emipomae
	  WHERE	actualizado = 1
	    and no_poliza   = _no_poliza;

	 {if _sucursal_origen = "002" then
	 else
		continue foreach;
	 end if}

	select nombre
	  into _nom_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	 foreach
		select no_unidad,
		       cod_producto
		  into _no_unidad,
		       _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza

		{if _cod_producto = "00698" then
		else
			continue foreach;
		end if}

		select nombre
		  into _nom_prod
		  from prdprod
		 where cod_producto = _cod_producto;

		select count(*)
		  into _cant
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		{if _cant = 2 then
		else
			continue foreach;
		end if}

		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from emipocob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			{if _cod_cobertura = "01021" or _cod_cobertura = "01022" then
			else
				continue foreach;
			end if}

			if _cod_cobertura = "00102" then
			   let _cod_cobertura2 = "01021";
			elif _cod_cobertura = "00113" then
			   let _cod_cobertura2 = "01022";
			elif _cod_cobertura = "00117" then
			   let _cod_cobertura2 = "01028";
			else
				continue foreach;
			end if

			--*****Actualizacion******

		   	if _cod_subramo = "012" then	--empresariales
				let _cod_subramo = "006";	--empresariales
			end if

		   {	update emipocob
			   set cod_cobertura = _cod_cobertura2
			 where no_poliza     = _no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;

			update endedcob
			   set cod_cobertura = _cod_cobertura2
			 where no_poliza     = _no_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = _cod_cobertura;

			update endeduni
			   set cod_producto = "00723"		--producto soda
			 where no_poliza    = _no_poliza
 			   and no_unidad    = _no_unidad;

			update emipouni
			   set cod_producto = "00723"		--producto soda
			 where no_poliza    = _no_poliza
 			   and no_unidad    = _no_unidad;

			update emipomae
			   set cod_ramo    = "020",
			       cod_subramo = _cod_subramo
			 where no_poliza   = _no_poliza; }

			select nombre
			  into _nom_cobe
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			return _no_documento,
				   _no_unidad,
				   _cod_producto,
				   _cod_cobertura,
				   _nom_prod,
				   _nom_cobe,
				   _cod_ramo,
				   _cod_subramo,
				   _nom_subramo
				    with RESUME;
		end foreach
	 end foreach

end foreach

end procedure
