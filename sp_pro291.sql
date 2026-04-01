-- Informe para la red de Hospitales 004 / Laboratorios 005
-- Creado    : 17 Agosto de 2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.

 DROP PROCEDURE sp_pro291;

create procedure sp_pro291()
returning CHAR(50),  -- 1. Nombre de la Instituci¢n.  
		  CHAR(50),  -- 2. Lugar donde esta ubicada la Instituci¢n. 
		  CHAR(10),  -- 3. Tel‚fono de la Instituci¢n.
	      CHAR(10);	 -- 4. Fax de la Instituci¢n.

define _nombre          char(50);
define _localidad      	char(20);
define _telefono        char(10);
define _fax             char(10);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE 	tmp_hosp_lab (
					nombre  	  char(50),            
					localidad 	  char(20),	         
					telefono 	  char(10),	         
					fax 		  char(10)		         
	) WITH NO LOG;

foreach 
 select nombre,
		direccion_1,
		telefono1,
		fax
   into _nombre,
 	    _localidad,
        _telefono,
	    _fax
   from cliclien
  where cod_actividad = "004" or cod_actividad = "005"	

insert  into tmp_hosp_lab
   			 (
			 nombre,
			 localidad,
			 telefono,
			 fax
			 )
	  values (
			 _nombre,
			 _localidad,
			 _telefono,
		     _fax
			 );

	  return _nombre,  	 -- 1.Nombre de la Instituci¢n. 
	    	 _localidad, -- 2.Lugar donde est  ubicada la Instituci¢n. 
		  	 _telefono,  -- 3.Telefono de la Intituci¢n. 
		     _fax      	 -- 4.Fax de la Instituci¢n. 
	    with resume;
 end foreach
drop table tmp_hosp_lab;--*Recordar desactivar la eliminaci¢n para no eliminar la tabla al momento de cargar los datos*--	  
end procedure
