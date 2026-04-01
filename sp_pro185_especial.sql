-- Informe para Listar las Cartera de P¢liza del Ramo Salud 
-- Creado    : 09-Julio-2007 - Autor: Rub‚n Arn ez
-- Modificado: 21-Agosto-007 - Adici¢n de campos nuevos solicitados por Nelda 
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE sp_pro185_e;
 create procedure sp_pro185_e(a_ano CHAR(20))
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
		  char(100), --13. Nombre del Contratante 
          CHAR(50),	 -- 1. Nombre del Dependiente. 
		  CHAR(50),	 -- 2. Nombre de Parentesco.		 
		  smallint,	 -- 3. Edad Calculada.		  
		  char(10),  -- 4. Cod dependientedefine _no_poluni             char(10);
		  date,		 -- 5. Fecha de Nacimientodefine v_filtros          char(255);
		  date,		 -- 6. fecha de Efectividad.define _no_poliza         char(10);
		  char(100);



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
define _Dependiente		  CHAR(50);			  
define _Parentesco		  CHAR(50);				  		  
define _Edad_Calc		  smallint;				  		  
define _Cod_dependiente	  char(10);				  		  
define _Fecha_Nacio		  date	  ;				  			  
define _Fecha_efect 	  date	  ;				  			  
define _Procedimiento    char(100);
define _si_hay		  	  smallint;

						  
SET ISOLATION TO DIRTY READ;

-- LET _fecha = MDY(12,31,a_ano);
LET _cod_ramo       = "004";
LET _cant2          =     0;
LET _Dependiente	   = "";		 
LET _Parentesco		   = "";		 	
LET _Edad_Calc		   = 0;	
LET _Cod_dependiente   = "";		 
LET _Fecha_Nacio	   = null;		 
LET _Fecha_efect 	   = null;	
LET _Procedimiento     = "";	
LET _si_hay		  	   =  0;	

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
 select a.no_poliza,
		a.cod_ramo,
        a.cod_subramo,
        a.estatus_poliza,
        a.actualizado,
	    a.no_documento,
		a.nueva_renov,
		a.cod_contratante
   into _no_poliza,
 	    _cod_ramo,
        _cod_subramo,
	    _estatus_pol,
	    _actualizado,
	    _no_documento,
		_nueva_renov,
		_contratante
   from emipomae a, emipoagt b
  where a.actualizado     = 1
    and a.cod_ramo        = _cod_ramo
    and a.estatus_poliza  = 1
    and a.colectiva       = "C"
    and a.no_poliza = b.no_poliza
    and b.cod_agente = a_ano

		select nombre
		  into _nombre_contra
		  from cliclien 
		 where cod_cliente = _contratante;
				   
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo            = _cod_ramo
	   and cod_subramo         = _cod_subramo;

	   let _cant2 = 0;
	   let _cant = 0;

	 select count(*)
       into _cant2
	   from emidepen a ,emipouni b
	  where a.activo     = "1"
	    and a.no_poliza  = _no_poliza
     	and a.no_poliza  = b.no_poliza
	    and a.no_unidad  = b.no_unidad;

		 if _cant2 is null then
			let _cant2 = 0;
		 end if
		
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
	  where no_poliza      = _no_poliza
	    and activo         = 1

{	 select count(*)
       into _cant
	   from emidepen
	  where activo         = "1"
	    and no_poliza      = _no_poliza
	    and no_unidad      = v_no_unidad;

	   	let _cant2 = _cant2   + _cant;	 }

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

--      call sp_pro186(_no_poliza, v_no_unidad) returning _Dependiente,_Parentesco,_Edad_Calc,_Cod_dependiente,_Fecha_Nac,_Fecha_efect ;		  
--	  	call sp_pro188(_no_poliza, v_no_unidad,_cod_asegurado) returning  _Procedimiento;
           let _si_hay = 0;

		select count(*)
	      into _si_hay
		  from emidepen
		 where activo       = "1"
		   and no_poliza    = _no_poliza
		   and no_unidad    = v_no_unidad;

			if _si_hay > 0 then

		   foreach
		    select cod_cliente,
			       cod_parentesco,
				   fecha_efectiva
		      into _Cod_dependiente,
			       _cod_parentesco,
				   _Fecha_efect
			  from emidepen
			 where activo       = "1"
			   and no_poliza    = _no_poliza
			   and no_unidad    = v_no_unidad
			   	     	   
		   	select nombre,
			       fecha_aniversario
			  into _Dependiente,
			       _fecha_nacio
			  from cliclien 
			 where cod_cliente  = _Cod_dependiente;

			let _Edad_Calc = sp_sis78(_fecha_nacio,today);

		    select nombre
		      into _Parentesco
		      from emiparen
		     where cod_parentesco   = _cod_parentesco;

			foreach 
				select cod_procedimiento
				  into _cod_procedimiento
				  from emiprede
				 where no_poliza   = _no_poliza
			       and no_unidad   = v_no_unidad
				   and cod_cliente = _Cod_dependiente

				select nombre 
				  into _nom_procedimiento
				  from emiproce
				 where cod_procedimiento  = _cod_procedimiento;	

				   let _Procedimiento = _nom_procedimiento; 

		      if _Procedimiento is null then
				let _Procedimiento = "";
			 end if

			   	return  _nombre_subramo,   			-- 1.Nombre del Subramo 
						_nombre_producto,  			-- 2.Nombre del Producto 
						_no_documento,	   			-- 3.N£mero de Documento
						_nombre_aseg,	   			-- 4.Nombre del Asegurado
		  				_fecha_efec,       			-- 5.Fecha efectiva
						_prima,						-- 6.Prima
						_cedula,					-- 7.C‚dula
						_edadcal,					-- 8.Edad Calculada
						_fecha_nac,					-- 9.Fecha de Nacimiento
						v_no_unidad,    			--10.Unidad
						_no_poliza,					--11.N£mero de P¢liza Interno
						_cant2,						--12.Cantidad de Dependientes
						_nombre_contra,				--13.Nombre del Contratante
						_Dependiente,				-- 1. Nombre del Dependiente. 
						_Parentesco,				-- 2. Nombre de Parentesco.
						_Edad_Calc,					-- 3. Edad Calculada.
						_Cod_dependiente,			-- 4. Cod dependiente
						_Fecha_Nacio,					-- 5. Fecha de Nacimiento
						_Fecha_efect, 				-- 6. fecha de Efectividad.
						_Procedimiento
				  with resume;
				  end foreach;
			 	end foreach;
	 	else
			   	return  _nombre_subramo,   			-- 1. Nombre del Subramo 
						_nombre_producto,  			-- 2. Nombre del Producto 
						_no_documento,	   			-- 3. N£mero de Documento
						_nombre_aseg,	   			-- 4. Nombre del Asegurado
		  				_fecha_efec,       			-- 5. Fecha efectiva
						_prima,						-- 6. Prima
						_cedula,					-- 7. C‚dula
						_edadcal,					-- 8. Edad Calculada
						_fecha_nac,					-- 9. Fecha de Nacimiento
						v_no_unidad,    			--10. Unidad
						_no_poliza,					--11. N£mero de P¢liza Interno
						_cant2,						--12. Cantidad de Dependientes
						_nombre_contra,				--13. Nombre del Contratante
						_Dependiente,				-- 1. Nombre del Dependiente. 
						_Parentesco,				-- 2. Nombre de Parentesco.
						_Edad_Calc,					-- 3. Edad Calculada.
						_Cod_dependiente,			-- 4. Cod dependiente
						_Fecha_Nacio,				-- 5. Fecha de Nacimiento
						_Fecha_efect, 				-- 6. fecha de Efectividad.
						_Procedimiento
				  with resume;	 		   
		end if
	  end foreach;
 	end foreach;
end procedure;

		   