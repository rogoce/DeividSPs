-- Informacion para Panama Asistencia Ramo Salud 
-- Creado    : 13/08/2007 - Autor: Armando Moreno


--  DROP PROCEDURE sp_pro391;

 create procedure sp_pro391(a_ano CHAR(20))

returning CHAR(50),  -- 1. Nombre del Subramo 
		  CHAR(50),  -- 2. Nombre del Producto
		  CHAR(20),  -- 3. Numero de Documento
	      CHAR(100), -- 4. Nombre del Asegurado
		  DATE, 	 --	5. Fecha Efectiva          
		  DEC(16,2), -- 6. Prima	 
		  CHAR(10),	 -- 7. Cedula 
		  SMALLINT,	 -- 8. Edad
		  DATE,  	 -- 9. Fecha de Nacimiento
		  CHAR(5),	 --10. Unidad
		  CHAR(10),	 --11. N£mero de P¢liza interno
		  integer,	 --12. Cantidad de Dependientes por asegurado
		  char(100); --13. Nombre del Contratante 
		 
		  
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
define _cedula            char(10);
define _cant 			  integer;
define _cant2 			  integer;
define _contratante       char(10);
define _codigoe		      char(2);
						  
SET ISOLATION TO DIRTY READ;

LET _cod_ramo = "018";
LET _cant2    = 0;
LET _codigoe  = "15";
{
create temp table tmp_health(
nombre			char(50),
poliza          char(16),
fecha1          date,
fecha2          date,
pin 			char(10),
codigoe       	char(2),
nombres         char(30),
depto           char(15),
cedula          char(30),
plan 			cgar(25)
) with no log;
 }

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	 select no_poliza,
	        cod_subramo,
	        estatus_poliza,
	        actualizado,
		    no_documento,
			cod_pagador,
			vigencia_inic,
			vigencia_final
	  into _no_poliza,
	        _cod_subramo,
		    _estatus_pol,
		    _actualizado,
		    _no_documento,
			_contratante,
			_vigencia_inic,
			_vigencia_final
	   from emipomae
	  where actualizado    = 1
	    and cod_ramo       = _cod_ramo
	    and estatus_poliza = 1

	 select nombre,
	        cedula
	   into _nombre_contra,
		    _cedula
	   from cliclien 
	  where cod_cliente = _contratante;

	foreach
		 select no_unidad,
		        cod_asegurado,
		        cod_producto
		   into v_no_unidad,
		        _cod_asegurado,
		        _cod_producto
		   from emipouni
		  where no_poliza   = _no_poliza
		    and activo      = 1

	 select count(*)
       into _cant
	   from emidepen
	  where activo         = "1"
	    and no_poliza      = _no_poliza
	    and no_unidad      = v_no_unidad;

	   	let _cant2 = _cant2   + _cant;

	   select nombre,
		       fecha_aniversario,
			   cedula     
		  into _nombre_aseg,
		       _fecha_nac,
			   _cedula
	   	  from cliclien 
		 where cod_cliente = _cod_asegurado;

		 let _edadcal      = sp_sis78(_fecha_nac,today);

		select nombre
		  into _nombre_producto
		  from prdprod 
		 where cod_producto = _cod_producto;
	 {	
		insert into tmp_health(
			   	nombre,
				poliza,
				fecha1,
				fecha2,
				pin,   
				codigoe,
				nombres,
				depto,  
				cedula, 
				plan)
		values (_nombre,
				_poliza,
				_fecha1,
				_fecha2,
				_pin,   
				_codigoe,
				_nombres,
				_depto,  
				_cedula, 
				_plan
		       );

	  }
		  
		   	return  _nombre_subramo,   			-- 1.Nombre del Subramo 
					_nombre_producto,  			-- 2.Nombre del Producto 
					_no_documento,	   			-- 3.Numero de Documento
					_nombre_aseg,	   			-- 4.Nombre del Asegurado
	  				_fecha_efec,       			-- 5.Fecha efectiva
					_prima,						-- 6.Prima
					_cedula,					-- 7.Cedula
					_edadcal,					-- 8.Edad Calculada
					_fecha_nac,					-- 9.Fecha de Nacimiento
					v_no_unidad,    			--10.Unidad
					_no_poliza,					--11.N£mero de P¢liza Interno
					_cant2,						--12.Cantidad de Dependientes
					_nombre_contra				--13.Nombre del Contratante
			  with resume;
	   
	  end foreach;
 	end foreach;
end procedure;

		    