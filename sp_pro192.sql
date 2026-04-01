-- Informe para Listar las Polizas de CrediRey en donde puedan general Todos los Gastos Medicos 
-- Creado    : 25-Julio-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.--.

-- DROP PROCEDURE sp_pro192;

create procedure sp_pro192()
returning CHAR(50),  -- 1.  Nombre del Subramo 
		  CHAR(50),  -- 2.  Nombre del Producto
		  CHAR(20),  -- 3.  Numero de Documento
	      CHAR(100), -- 4.  Nombre del Asegurado
		  DATE, 	 --	13. Fecha Efectiva          
   		  CHAR(3),   -- 16. Codigo de dependiente
		  CHAR(50),	 -- 17. Nombre del Dependiente 
		  CHAR(1),	 -- 18. Sexo del Dependiente
		  CHAR(50),	 -- 19. Nombre de Parentesco
		  DEC(16,2), -- 20. Prima	 
		  CHAR(1),	 -- 21. Trato de la P¢liza
		  CHAR(100); -- 22. Nombre de las exclusiones 
		   
define _no_poluni         char(10);
define v_filtros          char(255);
define _no_poliza         char(10);
define _poldepen          char(10);
define _cod_ramo          char(3);
define _cod_subramo       char(3);
define _nombre_ramo		  char(50);
define _nombre_subramo    char(50);     
define _estatus_pol       smallint;
define _actualizado 	  smallint;
define _cod_parent        char(3);
define _activo            smallint;
define _cod_cltdepe       char(10);
define _cod_cliente       char(10);
define _compania	      char(3);
define _status            char(1);
define _cod_formapag      char(3);
define _nombre_contra     char(100);
define _nombre_aseg	      char(100);
define _fecha     	   	  date;
define _edad              integer;
define _codformapg        char(3);
define _nombrepago        char(50);
define _documento		  char(20);
define v_no_unidad	   	  char(5);
define _no_unidad	   	  char(5);
define _cod_asegurado     char(10);
define _no_documento      CHAR(20);
define _fecha_efec        date;
define _cod_producto   	  char(5);
define _nombre_producto	  char(50);	
define _renglon			  integer;
define _nombre_depend     char(50);
define _nombre_conyugue   char(100); --Nombre del Conyugue
define _nombre_depend1    char(50);  --Nombre del Dependiente
define _nombre_depend2    char(50);
define _nombre_depend3    char(50);
define _nombre_depend4    char(50);
define _nombre_depend5    char(50);
define _nombre_depend6    char(50);
define _nombre_depend7    char(50);
define _cod_cobertura     char(5);
define _nombre_cober      char(50);
define _nombre_parentesco char(50);   
define _cod_parentesco 	  char(3);
define _sexo         	  char(1);
define _fecha_nac         date;
define _edadcal		  	  smallint;
define _cant_dependientes smallint;
define _prima             dec(16,2);
define _nueva_renov    	  char(1);
define _cod_procedimiento char(5);
define _nom_procedimiento char(100);
       					  
						  
SET ISOLATION TO DIRTY READ;

LET _cod_ramo       = "018";

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
 select no_poliza,
		cod_ramo,
        cod_subramo,
        estatus_poliza,
        actualizado,
	    no_documento,
		nueva_renov
  into _no_poliza,
 	    _cod_ramo,
        _cod_subramo,
	    _estatus_pol,
	    _actualizado,
	    _no_documento,
		_nueva_renov
   from emipomae 
  where actualizado        = "1"
    and cod_ramo           = _cod_ramo
    and estatus_poliza     = "1"
 	and nueva_renov		   = "R"
-- 	and no_documento       <> "1800-00035-01" 
 	and no_documento       <> "1804-01420-01" -- P¢liza de Credirey
				   
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo            = _cod_ramo
	   and cod_subramo         = _cod_subramo;

	foreach
	 select no_unidad,
	        cod_asegurado,
	        vigencia_inic,
	        cod_producto,
			prima
	         
	   into v_no_unidad,
	        _cod_asegurado,
	        _fecha_efec,
	        _cod_producto,
	        _prima 
	   from emipouni
	  where no_poliza   = _no_poliza
	    and activo      = 1

		select nombre,
		       sexo
		  into _nombre_aseg,
		       _sexo
		  from cliclien 
		 where cod_cliente = _cod_asegurado;

		select nombre
		  into _nombre_producto
		  from prdprod 
		 where cod_producto = _cod_producto;

	   foreach
	    select cod_cliente,
		       cod_parentesco
	      into _cod_cltdepe,
		       _cod_parentesco
		  from emidepen
		 where activo       = "1"
		   and no_poliza    = _no_poliza
		   and no_unidad    = v_no_unidad
	  	   
	   	select nombre
		  into _nombre_depend
		  from cliclien 
		 where cod_cliente      = _cod_cltdepe;

        select nombre
          into _nombre_parentesco
          from emiparen
         where cod_parentesco = _cod_parentesco;

	   foreach 
		select cod_procedimiento
		  into _cod_procedimiento
		  from emipreas
		 where no_poliza   = _no_poliza
		   and no_unidad   = v_no_unidad

				select nombre 
				  into _nom_procedimiento
				  from emiproce
			     where no_poliza         = _no_poliza
		           and no_unidad         = v_no_unidad
		           and cod_procedimiento = _cod_procedimiento;

	   	return  _nombre_subramo,   			-- 1.Nombre del Subramo 
				_nombre_producto,  			-- 2.Nombre del Producto 
				_no_documento,	   			-- 3.Numero de Documento
				_nombre_aseg,	   			-- 4.Nombre del Asegurado
				_fecha_efec,       			--13.Fecha efectiva
  				_cod_parentesco,   			--16.Codigo de Parentesco
				_nombre_depend,    			--17.Nombre de Parentesco
				_sexo,						--18.Sexo 
				_nombre_parentesco,   		--19.Nombre de Parentesco
				_prima,
				_nueva_renov,
				_nom_procedimiento
		 with resume;
	   
	  end foreach;
 	end foreach;
   end foreach;
  end foreach;

end procedure;
