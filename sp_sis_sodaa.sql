
-- Creado    : 11/05/2007 - Autor: Armando Moreno

drop procedure sp_sissd;

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

--SET DEBUG FILE TO "sp_sis_sodaa.trc";
--TRACE ON;


SET ISOLATION TO DIRTY READ;

foreach
                 
	 SELECT a
	   into _no_documento
	   FROM soda3
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

		select nombre
		  into _nom_prod
		  from prdprod
		 where cod_producto = _cod_producto;

	   	select count(*)
		  into _cant
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cant = 2 then

			foreach
				select cod_cobertura
				  into _cod_cobertura
				  from emipocob
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad

				if _cod_cobertura = "00102" then
				   let _cod_cobertura2 = "01021";
				elif _cod_cobertura = "00113" then
				   let _cod_cobertura2 = "01022";
				else
					continue foreach;
				end if

				--*****Actualizacion******

			   	if _cod_subramo = "012" then	--empresariales
					let _cod_subramo = "006";	--empresariales
				end if

			  { 	update emipocob
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
				   set cod_producto = "00690"		--producto soda
				 where no_poliza    = _no_poliza
	 			   and no_unidad    = _no_unidad;

				update emipouni
				   set cod_producto = "00690"		--producto soda
				 where no_poliza    = _no_poliza
	 			   and no_unidad    = _no_unidad;

				update emipomae
				   set cod_ramo    = "020",
				       cod_subramo = _cod_subramo
				 where no_poliza   = _no_poliza;   }

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

		elif _cant = 3 then

			foreach

				select cod_cobertura
				  into _cod_cobertura
				  from emipocob
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad

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

		   {	   	update emipocob
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
				 where no_poliza   = _no_poliza;  		}

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

		end if

	 {   foreach
			select no_unidad,
			       cod_producto
			  into _no_unidad,
			       _cod_producto
			  from emipouni
			 where no_poliza = _no_poliza
	 --------------------------
				select * from emireafa
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				  into temp prueba1;

				update prueba1 set cod_cober_reas = "025"
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;
	----------------------------------
				select * from emireaco
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				  into temp prueba2;

				update prueba2 set cod_cober_reas = "025"
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;
	---------------------------------
				select * from emireama
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				  into temp prueba3;

				update prueba3 set cod_cober_reas = "025"
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;
	---------------------------------

				delete from emireafa
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;

				delete from emireaco
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;

				delete from emireama
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;
	------------------------------------
			   	update emifacon
				   set cod_cober_reas = "025"
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;
	------------------------------------
				insert into emireama
				select * from prueba3
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;

				insert into emireaco
				select * from prueba2
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;

				insert into emireafa
				select * from prueba1
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad;

				drop table prueba3;
				drop table prueba2;
				drop table prueba1;
	    end foreach	  }		
	    end foreach

end foreach

end procedure
