-- Informe de Hijos-Hijas Mayores de 24 Anios como Dependiente 
-- Creado    : 08-Mayo-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.

 DROP PROCEDURE sp_pro182;

create procedure sp_pro182(a_ano char(4))
returning CHAR(10),  -- 1. Codigo de P¢liza
	      CHAR(100), -- 2. Nombre del Asegurado
	      CHAR(50),  -- 3. Nombre del Subramo 
		  CHAR(3),   -- 4. Forma de Pago	
	      CHAR(10),  -- 5. Codigo del Asegurado 
	      DATE,      -- 6. Fecha de Nacimiento del Dependiente
      	  CHAR(50),  -- 7. Nombre del dependiente
    	  CHAR(10),  -- 8. Codigo del dependiente
	      CHAR(3),   -- 9. Codigo de Ramo
	      CHAR(3),   --10. Codigo de Subramo
		  CHAR(50);  --11. Nombre de la Forma de Pago 
   --     INTEGER;   --11. Edad 

define _no_poliza       char(10);
define _poldepen        char(10);
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _nombre_ramo		char(50);
define _nombre_subramo  char(50);     
define _estatus_pol     smallint;
define _actualizado 	smallint;
define _cod_parent      char(3);
define _activo          smallint;
define _cod_cltdepe     char(10);
define _cod_cliente     char(10);
define _compania	    char(3);
define _status          char(1);
define _cod_formapag    char(3);
define _nombre_depend   char(50);
define _nombre_aseg		char(100);
define _fecha_nac       date;
define _fecha     		date;
define _edad            integer;
define _codformapg      char(3);
define _nombrepago      char(50);

SET ISOLATION TO DIRTY READ;

let _fecha = MDY(12,31,a_ano);

-- Seleccionamos todas las polizas vigentes del ramo de Salud

foreach 
      select  no_poliza,
      		  cod_ramo,
              cod_subramo,
              estatus_poliza,
              actualizado,
			  cod_formapag,
			  cod_cliente
         into _no_poliza,
         	  _cod_ramo,
              _cod_subramo,
			  _estatus_pol,
			  _actualizado,
			  _cod_formapag,
			  _cod_cliente	 -- cod_contratante
		 from emipomae 
        where actualizado        = "1"
		  and cod_ramo           = "018"
		  and estatus_poliza     = "1"
			   
	  select nombre
		into _nombre_subramo
	  	from prdsubra
	   where cod_ramo            = _cod_ramo
	     and cod_subramo         = _cod_subramo;

	  select nombre  
		into _nombrepago
	    from cobforpa
	   where cod_formapag        = _cod_formapag;       	

	  select nombre,
	   	     fecha_aniversario
	 	into _nombre_aseg,
		     _fecha_nac       
	 	from cliclien 
	   where cod_cliente         = _cod_cliente;

	  foreach
		   select  no_poliza,
		  		   cod_cliente,
		  		   cod_parentesco,
				   activo
		     into  _poldepen,
		     	   _cod_cltdepe,
			       _cod_parent,
				   _activo
		  	 from  emidepen
		    where  activo         = "1"
			  and  no_poliza      = _no_poliza
		      and  cod_parentesco in("002","007") -- Hijo, Hija

		    select nombre
		      into _nombre_depend       
  		      from cliclien 
  		     where cod_cliente    = _cod_cltdepe;
									  
		   return  _poldepen,	 	-- 1.Codigo de la P¢liza
			   	   _nombre_aseg,	-- 2.Nombre del Asegurado
			       _nombre_subramo, -- 3.Nombre del Subramo 
				   _cod_formapag,	-- 4.Forma de Pago
				   _cod_cliente, 	-- 5.Codigo del Asegurado
			       _fecha_nac,   	-- 6.Fecha de Nacimiento del Dependiente 
		    	   _nombre_depend,  -- 7.Nombre del Dependiente
		     	   _cod_cltdepe, 	-- 8.Codigo de dependiente
				   _cod_ramo,       -- 9.Codigo de Ramo
				   _cod_subramo,	--10.Codigo de SubRamo
				   _nombrepago     --11.Nombre del forma de Pago
			   --  _edad        	--11.Edad
		       with resume;
  	  end foreach;
end foreach;

end procedure;