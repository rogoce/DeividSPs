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
		  CHAR(50),  --11. Nombre de la Forma de Pago 
		  CHAR(20),  --12. Numero de Documento
  		  SMALLINT,  --14. Edad
		  char(5),   --15. Unidad
		  varchar(50),  --14. Asegurado
		  varchar(80);  --14. Agente
		  
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
define _documento		char(20);
define _edadcal		  	smallint;
define _n_contratante   varchar(50);	
define _no_unidad 	    char(5);	
define _cnt		  	    smallint;	
define v_nombre_agente		varchar(80);
define _cod_agente			char(5);

SET ISOLATION TO DIRTY READ;

let _fecha = MDY(12,31,a_ano);
let _n_contratante = '';
let _no_unidad = '00000';
let _cnt = 0;

-- Seleccionamos todas las polizas vigentes del ramo de Salud
	--if _documento = '1823-00210-01' then
		set debug file to "sp_pro182.trc";
		trace on;
	--end if	
foreach 
      select  no_poliza,
      		  cod_ramo,
              cod_subramo,
              estatus_poliza,
              actualizado,
			  cod_formapag,
			  cod_contratante,
			  no_documento
         into _no_poliza,
         	  _cod_ramo,
              _cod_subramo,
			  _estatus_pol,
			  _actualizado,
			  _cod_formapag,
			  _cod_cliente,
			  _documento
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

    select nombre
      into _nombre_aseg
      from cliclien 
     where cod_cliente = _cod_cliente;	 	   
	 
	foreach with hold
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 exit foreach;
	end foreach		 	 

	  foreach
		   select  no_poliza,
		  		   cod_cliente,
		  		   cod_parentesco,
				   activo,
				   no_unidad
		     into  _poldepen,
		     	   _cod_cltdepe,
			       _cod_parent,
				   _activo,
				   _no_unidad
		  	 from  emidepen
		    where  activo         = "1"
			  and  no_poliza      = _no_poliza
		      and  cod_parentesco in("002","007") -- Hijo, Hija


			select nombre,
	   	           fecha_aniversario
	 		  into _nombre_depend,
		   	       _fecha_nac       
	 		  from cliclien 
	  		 where cod_cliente         = _cod_cltdepe;

			   let _edadcal = sp_sis78(_fecha_nac,today);

			   
									  
			if _edadcal >= 24 then
			     let _cnt = 0;
			  select count(*) 
				into _cnt
				from prdsubra
			   where cod_ramo            = _cod_ramo
				 and cod_subramo         = _cod_subramo
				 and lower(nombre) like ('%colectivo%');			

				if _cnt is null then
					let _cnt = 0;
				end if					 
			    let _n_contratante = '';	
				
				if _cnt >= 1 then
				select nvl(n.nombre,'')
				  into _n_contratante
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza		 
				   and e.no_unidad = _no_unidad	;	
				   end if				   
				   
				--selecciona los nombres de los corredores
				select trim(nombre)||" - "||trim(cod_agente)
				  into v_nombre_agente
				 from agtagent
				 where cod_agente = _cod_agente;					   

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
					   _nombrepago,     --11.Nombre del forma de Pago
					   _documento,		--12.Numero de Documento
				       _edadcal,        	--14.Edad
					   _no_unidad,
					   _n_contratante,
					   v_nombre_agente
			       	   with resume;
					   

			let _no_unidad = '00000';					   
            let _n_contratante = '';	
			end if

  	  end foreach;

end foreach;

end procedure;