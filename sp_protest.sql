-- Procedimiento para Obtener los Dependientes 
-- Creado    : 16-Julio-2007 - Autor: Rub‚n Arn ez
-- Modificado: 21-Agosto-007 - Autor: Rub‚n Arn ez adici¢n de nuevos campos en el reporte 

-- SIS v.2.0 - DEIVID, S.--.

DROP PROCEDURE sp_pro186;

 create procedure sp_pro186(a_no_poliza char(10), a_unidad char(5))

returning CHAR(50),	 -- 1. Nombre del Dependiente. 
		  CHAR(50),	 -- 2. Nombre de Parentesco.
		  smallint,	 -- 3. Edad Calculada.
		  char(10),  -- 4. Cod dependiente
		  date,		 -- 5. Fecha de Nacimiento
		  date;		 -- 6. fecha de Efectividad.
   
define _no_poluni         char(10);
define v_filtros          char(255);
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
define _cod_cobertura     char(5);
define _nombre_cober      char(50);
define _nombre_parentesco char(50);   
define _cod_parentesco 	  char(3);
define _sexo         	  char(1);
define _fecha_nac         date;
define _fecha_efectiva    date;
define _edadcal		  	  smallint;
define _cant_dependientes smallint;
define _prima             dec(16,2);
define _nueva_renov    	  char(1);
define _cod_procedimiento char(5);
define _nom_procedimiento char(100);
define _cedula            char(10);
define _cant              smallint;
       					  
						  
SET ISOLATION TO DIRTY READ;

foreach
    select cod_cliente,
	       cod_parentesco,
		   fecha_efectiva
      into _cod_cltdepe,
	       _cod_parentesco,
		   _fecha_efectiva
	  from emidepen
	 where activo       = "1"
	   and no_poliza    = a_no_poliza
	   and no_unidad    = a_unidad
     	   
   	select nombre,
	       fecha_aniversario
	  into _nombre_depend,
	       _fecha_nac
	  from cliclien 
	 where cod_cliente  = _cod_cltdepe;

	let _edadcal = sp_sis78(_fecha_nac,today);

    select nombre
      into _nombre_parentesco
      from emiparen
     where cod_parentesco   = _cod_parentesco;

   	return 	_nombre_depend,    			-- 1.Nombre de Dependiente 
			_nombre_parentesco,   		-- 2.Nombre de Parentesco
		   	_edadcal,					-- 3.Edad Calculada
			_cod_cltdepe,				-- 4.Codigo del dependiente
			_fecha_nac,					-- 5.Fecha de Nacimiento
			_fecha_efectiva				-- 6.Fecha de Efectividad
      with resume;

  end foreach;
end procedure;
