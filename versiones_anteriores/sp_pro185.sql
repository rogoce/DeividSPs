-- Informe para Listar las Cartera de P¢liza del Ramo Salud 
-- Creado    : 09-Julio-2007 - Autor: Rub‚n Arn ez
-- Modificado: 21-Agosto-007 - Adici¢n de campos nuevos solicitados por Nelda 
-- Modificado: 24-Octubre-2017 - HGIRON, Caso :26513 FANY -- execute procedure sp_pro185('1804-00777-01')
               
-- SIS v.2.0 - DEIVID, S.A. 

 DROP PROCEDURE sp_pro185; 
 create procedure sp_pro185(a_no_documento CHAR(20))

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
		  smallint,  --14. Estado de la poliza 
		  
          CHAR(50),	 -- 1. Nombre del Dependiente. 
		  CHAR(50),	 -- 2. Nombre de Parentesco.
		  smallint,	 -- 3. Edad_dep Calculada.
		  char(10),  -- 4. Ced_dependiente
		  date,		 -- 5. Fecha_dep de Nacimiento
		  date,		 -- 6. fecha_ef_dep de Efectividad.		  
		  char(100), -- 7. Nombre del Procedimiento3
		  char(100), -- 8. Nombre de las exclusiones4		  
		  char(15),
		  smallint,
		  integer, smallint,char(20),char(100),char(20)	  ;	 --    Promedio de Edad Asegurado

		  
define _no_poluni         char(10);
define v_filtros          char(255);
define _no_poliza         char(10);
define _ultimo_no_poliza  char(10);
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
define _no_documento2      CHAR(20);
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
define _estatus_poliza    smallint;

define _nombre_depend2     char(50);
define _nombre_parentesco2 char(50);  
define _edadcal2		   smallint;
define _cod_cltdepe2       char(10);
define _ced_dep            char(10);
define _fecha_nac2         date;
define _fecha_efectiva2    date;

define _nom_procedimiento3 char(100);
define _nom_procedimiento4 char(100);
define _si_hay smallint;
define _renglon2 smallint;
define _grupo char(15); --'DEPENDIENTE', 'PRINCIPAL'
define _Acum_edad          integer;
define _Prom_edad          integer;
define _solo_1_xls         smallint;

define _poliza_cont char(20);
define _comp_cont char(100);
define _vig_ini_cont     date;
define _chr_ini_cont     date;


drop table if exists tmp_rpt24;
create temp table tmp_rpt24(
		  Subramo          CHAR(50), 
		  Producto         CHAR(50),  
		  Documento        CHAR(20),  
	      Asegurado        CHAR(100), 
		  Fecha_Efectiva   DATE, 
		  Prima	           DEC(16,2), 
		  Cedula           CHAR(10),	 
		  Edad             SMALLINT,	 
		  Fecha_Nacimiento DATE,  	 
		  Unidad           CHAR(5),	 
		  Poliza_interno   CHAR(10),
		  Dependientes     integer,	 
		  Contratante      char(100), 
		  Estado           smallint,  		  
          Dependiente      CHAR(50),	
		  Parentesco       CHAR(50),	 
		  Edad_dep         smallint,	 
		  Ced_dependiente  char(10),  
		  Fecha_dep        date,	
		  fecha_ef_dep     date,
		  Procedimiento3   char(100), 
		  exclusiones4     char(100), 		  
		  grupo            char(15),
		  renglon2         smallint,
		  prom_edad        integer,
		  solo_1_xls       smallint,
		  poliza_cont      char(20),
          comp_cont        char(100),
          vig_ini_cont     date) 
		  with no log;		  
		  
						  
SET ISOLATION TO DIRTY READ;
--set debug file to "sp_pro185h.trc";
--trace on;
-- LET _fecha = MDY(12,31,a_ano);
LET _cod_ramo       = "018";
LET _cant2          =     0;
let _Prom_edad      =     0;
let _Acum_edad      =     0;
let _renglon2 = 0;
let _fecha_nac2 = current; 
let _fecha_efectiva2 = current; 
LET _poliza_cont       = "";
LET _comp_cont       = "";
let _chr_ini_cont = '';
LET _vig_ini_cont   = null;


--buscamos la ultima vigencia
let _ultimo_no_poliza = sp_sis21(a_no_documento);
--let _no_documento2 = '1805-01105-01';

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
 select no_poliza,
		cod_ramo,
        cod_subramo,
        estatus_poliza,
        actualizado,
	    no_documento,
		nueva_renov,
		cod_contratante,
		estatus_poliza
   into _no_poliza,
 	    _cod_ramo,
        _cod_subramo,
	    _estatus_pol,
	    _actualizado,
	    _no_documento,
		_nueva_renov,
		_contratante,
		_estatus_poliza
   from emipomae 
  where actualizado = 1
    and cod_ramo    = _cod_ramo
    and colectiva   = "C"
	and no_poliza   = _ultimo_no_poliza

	 let _grupo = 'PRINCIPAL'; 

	select nombre
	  into _nombre_contra
	  from cliclien 
	 where cod_cliente = _contratante;
				   
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

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
			prima_asegurado,poliza_cont,comp_cont,vig_ini_cont     /*se cambio la prima por prima_asegurado Solicitado por fany por un f9 11/07/2017*/
	   into v_no_unidad,
	        _cod_asegurado,
	        _fecha_efec,
	        _cod_producto,
	        _prima,_poliza_cont,_comp_cont,_vig_ini_cont 
	   from emipouni
	  where no_poliza      = _no_poliza	  
	    and activo         = 1
		order by no_unidad
			 let _renglon2 = _renglon2 + 1;				 		 

	   select nombre,
		       fecha_aniversario,
			   cedula     
		  into _nombre_aseg,
		       _fecha_nac,
			   _cedula
	   	  from cliclien 
		 where cod_cliente = _cod_asegurado;

		 let _edadcal      = sp_sis78(_fecha_nac,today);	 		 		 
		 let _Acum_edad    =  _Acum_edad + _edadcal;
		

		select nombre
		  into _nombre_producto
		  from prdprod 
		 where cod_producto = _cod_producto;

			let _nombre_depend2 = "";
			let _nombre_parentesco2 = "";
			let _edadcal2 = 0;
			let _nom_procedimiento3 = "";
			let _nom_procedimiento4 = "";
			let _cod_cltdepe2 = "";
			let _ced_dep = "";
			let _fecha_nac2 = null;
			let _fecha_efectiva2 = null;
			
			 if _poliza_cont is null then
				LET _poliza_cont  = "";
			 end if		  
			 if _comp_cont is null then
				LET _comp_cont  = "";
			 end if		  
			 if _vig_ini_cont is null then
				LET _vig_ini_cont = null;
			 end if					
			
			 
		 let _grupo = 'PRINCIPAL';	 

		 Insert into tmp_rpt24
		 values (_nombre_subramo, 
				_nombre_producto, 
				_no_documento,	  
				_nombre_aseg,	  
				_fecha_efec,      
				_prima,				
				_cedula,			
				_edadcal,			
				_fecha_nac,			
				v_no_unidad,    	
				_no_poliza,			
				_cant2,				
				_nombre_contra,		
				_estatus_poliza,    
				_nombre_depend2,    
				_nombre_parentesco2,  
				_edadcal2,				
				_cod_cltdepe2,			
				_fecha_nac2,			
				_fecha_efectiva2,		
				_nom_procedimiento3,
				_nom_procedimiento4,						   				   
				_grupo,
				_renglon2,
				0      ,1,_poliza_cont,_comp_cont,_vig_ini_cont);
		 
		 
		 
		{return _nombre_subramo,   		-- 1.Nombre del Subramo 
			   _nombre_producto,  		-- 2.Nombre del Producto 
			   _no_documento,	   		-- 3.N£mero de Documento
			   _nombre_aseg,	   		-- 4.Nombre del Asegurado
			   _fecha_efec,       		-- 5.Fecha efectiva
			   _prima,					-- 6.Prima
			   _cedula,					-- 7.C‚dula
			   _edadcal,				-- 8.Edad Calculada
			   _fecha_nac,				-- 9.Fecha de Nacimiento
			   v_no_unidad,    			--10.Unidad
			   _no_poliza,				--11.N£mero de P¢liza Interno
			   _cant2,					--12.Cantidad de Dependientes
			   _nombre_contra,			--13.Nombre del Contratante
			   _estatus_poliza,          --14.Estado de la Poliza
					_nombre_depend2,    			-- 1.Nombre de Dependiente 
					_nombre_parentesco2,   			-- 2.Nombre de Parentesco
					_edadcal2,						-- 3.Edad Calculada
					_cod_cltdepe2,					-- 4.Codigo del dependiente
					_fecha_nac2,					-- 5.Fecha de Nacimiento
					_fecha_efectiva2,				-- 6.Fecha de Efectividad						   
					_nom_procedimiento3,
					_nom_procedimiento4,						   				   
					_grupo,
					_renglon2
			   with resume;		 }
			   
         let _grupo = 'PRINCIPAL';		   
	  	--call sp_pro187(_no_poliza, v_no_unidad) returning  _nom_procedimiento4;			
		foreach 
			select b.nombre
			  into _nom_procedimiento4
			  from emipreas a, emiproce b
			 where a.no_poliza             = _no_poliza
			   and a.no_unidad             = v_no_unidad
			   and a.cod_procedimiento     = b.cod_procedimiento				 
			   
			  if _nom_procedimiento4 is null then
				 let _nom_procedimiento4 = "";
			 end if				   

			 Insert into tmp_rpt24
			 values (_nombre_subramo, 
					_nombre_producto, 
					_no_documento,	  
					_nombre_aseg,	  
					_fecha_efec,      
					_prima,				
					_cedula,			
					_edadcal,			
					_fecha_nac,			
					v_no_unidad,    	
					_no_poliza,			
					_cant2,				
					_nombre_contra,		
					_estatus_poliza,    
					_nombre_depend2,    
					_nombre_parentesco2,  
					_edadcal2,				
					_cod_cltdepe2,			
					_fecha_nac2,			
					_fecha_efectiva2,		
					_nom_procedimiento3,
					_nom_procedimiento4,						   				   
					_grupo,
					_renglon2,
					0      ,0,"","",null);
					
			{return _nombre_subramo,   		-- 1.Nombre del Subramo 
				   _nombre_producto,  		-- 2.Nombre del Producto 
				   _no_documento,	   		-- 3.N£mero de Documento
				   _nombre_aseg,	   		-- 4.Nombre del Asegurado
				   _fecha_efec,       		-- 5.Fecha efectiva
				   _prima,					-- 6.Prima
				   _cedula,					-- 7.C‚dula
				   _edadcal,				-- 8.Edad Calculada
				   _fecha_nac,				-- 9.Fecha de Nacimiento
				   v_no_unidad,    			--10.Unidad
				   _no_poliza,				--11.N£mero de P¢liza Interno
				   _cant2,					--12.Cantidad de Dependientes
				   _nombre_contra,			--13.Nombre del Contratante
				   _estatus_poliza,          --14.Estado de la Poliza
						_nombre_depend2,    			-- 1.Nombre de Dependiente 
						_nombre_parentesco2,   			-- 2.Nombre de Parentesco
						_edadcal2,						-- 3.Edad Calculada
						_cod_cltdepe2,					-- 4.Codigo del dependiente
						_fecha_nac2,					-- 5.Fecha de Nacimiento
						_fecha_efectiva2,				-- 6.Fecha de Efectividad						   
						_nom_procedimiento3,
						_nom_procedimiento4,						   				   
						_grupo,
						_renglon2
				   with resume;}
			   
		end foreach;  					 
	
		 
           let _si_hay = 0;

		select count(*)
	      into _si_hay
		  from emidepen
		 where activo       = "1"
		   and no_poliza    = _no_poliza
		   and no_unidad    = v_no_unidad;		 

		 if _si_hay is null then
			let _si_hay = 0;
		 end if		   
		 
		 if _si_hay > 0 then
			--call sp_pro186(_no_poliza, v_no_unidad) returning _nombre_depend2,_nombre_parentesco2,_edadcal2,_cod_cltdepe2,_fecha_nac2,_fecha_efectiva2 ;		  
			let _nom_procedimiento3 = "";
			let _nom_procedimiento4 = "";
 
			foreach 	 
			select b.nombre,    
					c.nombre, 	
					a.cod_cliente,	
					b.fecha_aniversario,		
					a.fecha_efectiva,a.poliza_cont,a.comp_cont,a.vig_ini_cont
			  into _nombre_depend2,    			-- 1.Nombre de Dependiente 
					_nombre_parentesco2,   		-- 2.Nombre de Parentesco	
					_cod_cltdepe2,				-- 4.Codigo del dependiente
					_fecha_nac2,				-- 5.Fecha de Nacimiento
					_fecha_efectiva2,_poliza_cont,_comp_cont,_vig_ini_cont
			  from emidepen  a, cliclien b,  emiparen c   --tmp_sppro186
			 where a.no_poliza   = _no_poliza
			   and a.no_unidad   = v_no_unidad 	   
			   and b.cod_cliente  = a.cod_cliente
			   and a.activo       = "1"
	           and c.cod_parentesco   = a.cod_parentesco 
			   
					 if _poliza_cont is null then
						LET _poliza_cont  = "";
					 end if		  
					 if _comp_cont is null then
						LET _comp_cont  = "";
					 end if		  
					 if _vig_ini_cont is null then
						LET _vig_ini_cont = null;
					 end if		  					 		 			   									
			   
			   let _edadcal2 = sp_sis78(_fecha_nac2,today);			   				
			 select  cedula     
			   into _ced_dep
			   from cliclien 
			  where cod_cliente = _cod_cltdepe2;			   
				--call sp_pro188(_no_poliza, v_no_unidad,_cod_cltdepe2) returning  _nom_procedimiento3;				   					 

				  if _nom_procedimiento3 is null then
					let _nom_procedimiento3 = "";
				 end if						 					 				 
				  if _cod_cltdepe2 is null then
					let _cod_cltdepe2 = "";
				 end if					 				 
				  if _nombre_depend2 is null then
					let _nombre_depend2 = "";
				 end if						 
				  if _nombre_parentesco2 is null then
					let _nombre_parentesco2 = "";
				 end if						 					 				 				 
				  if _edadcal2 is null then
					let _edadcal2 = 0;
				 end if						 
				  if _ced_dep is null then
					let _ced_dep = "";
				 end if					 
				 let _grupo = 'DEPENDIENTE';	
				 
				 Insert into tmp_rpt24
				 values (_nombre_subramo, 
						_nombre_producto, 
						_no_documento,	  
						_nombre_aseg,	  
						_fecha_efec,      
						_prima,				
						_cedula,			
						_edadcal,			
						_fecha_nac,			
						v_no_unidad,    	
						_no_poliza,			
						_cant2,				
						_nombre_contra,		
						_estatus_poliza,    
						_nombre_depend2,    
						_nombre_parentesco2,  
						_edadcal2,				
						_ced_dep,			
						_fecha_nac2,			
						_fecha_efectiva2,		
						_nom_procedimiento3,
						_nom_procedimiento4,						   				   
						_grupo,
						_renglon2,
						0      ,1, _poliza_cont,_comp_cont,_vig_ini_cont);				 

				{return _nombre_subramo,   		-- 1.Nombre del Subramo 
					   _nombre_producto,  		-- 2.Nombre del Producto 
					   _no_documento,	   		-- 3.N£mero de Documento
					   _nombre_aseg,	   		-- 4.Nombre del Asegurado
					   _fecha_efec,       		-- 5.Fecha efectiva
					   _prima,					-- 6.Prima
					   _cedula,					-- 7.C‚dula
					   _edadcal,				-- 8.Edad Calculada
					   _fecha_nac,				-- 9.Fecha de Nacimiento
					   v_no_unidad,    			--10.Unidad
					   _no_poliza,				--11.N£mero de P¢liza Interno
					   _cant2,					--12.Cantidad de Dependientes
					   _nombre_contra,			--13.Nombre del Contratante
					   _estatus_poliza,          --14.Estado de la Poliza
						_nombre_depend2,    			-- 1.Nombre de Dependiente 
						_nombre_parentesco2,   			-- 2.Nombre de Parentesco
						_edadcal2,						-- 3.Edad Calculada
						_cod_cltdepe2,					-- 4.Codigo del dependiente
						_fecha_nac2,					-- 5.Fecha de Nacimiento
						_fecha_efectiva2,				-- 6.Fecha de Efectividad						   
						_nom_procedimiento3,
						_nom_procedimiento4,
						_grupo,
						_renglon2						
					   with resume;}				  
					   
			let _nom_procedimiento3 = "";
			let _nom_procedimiento4 = "";					   
					   
			foreach 
				select b.nombre 
				  into _nom_procedimiento3
				  from emiprede a, emiproce b
				 where a.no_poliza   = _no_poliza
				   and a.no_unidad   = v_no_unidad
				   and a.cod_cliente = _cod_cltdepe2
				   and a.cod_procedimiento = b.cod_procedimiento
				 
				  if _nom_procedimiento3 is null then
					let _nom_procedimiento3 = "";
				 end if						 					 				 
				  if _nom_procedimiento4 is null then
					let _nom_procedimiento4 = "";
				 end if						 
				  if _cod_cltdepe2 is null then
					let _cod_cltdepe2 = "";
				 end if					 				 
				  if _nombre_depend2 is null then
					let _nombre_depend2 = "";
				 end if						 
				  if _nombre_parentesco2 is null then
					let _nombre_parentesco2 = "";
				 end if						 					 				 				 
				  if _edadcal2 is null then
					let _edadcal2 = 0;
				 end if						 
				  if _ced_dep is null then
					let _ced_dep = "";
				 end if					 
				 let _grupo = 'DEPENDIENTE';	
				 
				 Insert into tmp_rpt24
				 values (_nombre_subramo, 
						_nombre_producto, 
						_no_documento,	  
						_nombre_aseg,	  
						_fecha_efec,      
						_prima,				
						_cedula,			
						_edadcal,			
						_fecha_nac,			
						v_no_unidad,    	
						_no_poliza,			
						_cant2,				
						_nombre_contra,		
						_estatus_poliza,    
						_nombre_depend2,    
						_nombre_parentesco2,  
						_edadcal2,				
						_ced_dep,			
						_fecha_nac2,			
						_fecha_efectiva2,		
						_nom_procedimiento3,
						_nom_procedimiento4,						   				   
						_grupo,
						_renglon2,
						0      ,0, _poliza_cont,_comp_cont,_vig_ini_cont);				 				 
						
				{return _nombre_subramo,   		-- 1.Nombre del Subramo 
					   _nombre_producto,  		-- 2.Nombre del Producto 
					   _no_documento,	   		-- 3.N£mero de Documento
					   _nombre_aseg,	   		-- 4.Nombre del Asegurado
					   _fecha_efec,       		-- 5.Fecha efectiva
					   _prima,					-- 6.Prima
					   _cedula,					-- 7.C‚dula
					   _edadcal,				-- 8.Edad Calculada
					   _fecha_nac,				-- 9.Fecha de Nacimiento
					   v_no_unidad,    			--10.Unidad
					   _no_poliza,				--11.N£mero de P¢liza Interno
					   _cant2,					--12.Cantidad de Dependientes
					   _nombre_contra,			--13.Nombre del Contratante
					   _estatus_poliza,          --14.Estado de la Poliza
						_nombre_depend2,    			-- 1.Nombre de Dependiente 
						_nombre_parentesco2,   			-- 2.Nombre de Parentesco
						_edadcal2,						-- 3.Edad Calculada
						_cod_cltdepe2,					-- 4.Codigo del dependiente
						_fecha_nac2,					-- 5.Fecha de Nacimiento
						_fecha_efectiva2,				-- 6.Fecha de Efectividad						   
						_nom_procedimiento3,
						_nom_procedimiento4,
						_grupo,
						_renglon2						
					   with resume;}				  

			end foreach;					   
				  
			  end foreach;			 	
	 end if						 		   
	   
	  end foreach;
 	end foreach;	
	 
if _Acum_edad > 0 then
	 Let _Prom_edad  = (_Acum_edad / _renglon2 );	
end if
		 
foreach
	 select Subramo,
		  Producto,
		  Documento,
	      Asegurado,
		  Fecha_Efectiva,
		  Prima,
		  Cedula,
		  Edad,
		  Fecha_Nacimiento,
		  Unidad,
		  Poliza_interno,
		  Dependientes,
		  Contratante,
		  Estado,
          Dependiente,
		  Parentesco,
		  Edad_dep,
		  Ced_dependiente,
		  Fecha_dep,
		  fecha_ef_dep,
		  Procedimiento3,
		  exclusiones4,
		  grupo,
		  renglon2,solo_1_xls,poliza_cont,comp_cont,vig_ini_cont
		  
	  into 	_nombre_subramo, 
			_nombre_producto, 
			_no_documento,	  
			_nombre_aseg,	  
			_fecha_efec,      
			_prima,				
			_cedula,			
			_edadcal,			
			_fecha_nac,			
			v_no_unidad,    	
			_no_poliza,			
			_cant2,				
			_nombre_contra,		
			_estatus_poliza,    
			_nombre_depend2,    
			_nombre_parentesco2,  
			_edadcal2,				
			_cod_cltdepe2,			
			_fecha_nac2,			
			_fecha_efectiva2,		
			_nom_procedimiento3,
			_nom_procedimiento4,						   				   
			_grupo,
			_renglon2,_solo_1_xls,_poliza_cont,_comp_cont,_vig_ini_cont
	  from tmp_rpt24	 	 
	 order by renglon2
	 
			  if _vig_ini_cont is null then						 
				 let _chr_ini_cont = '';
			else
				 let _chr_ini_cont = cast(_vig_ini_cont as char(20));
			 end if		

	return	_nombre_subramo, 
			_nombre_producto, 
			_no_documento,	  
			_nombre_aseg,	  
			_fecha_efec,      
			_prima,				
			_cedula,			
			_edadcal,			
			_fecha_nac,			
			v_no_unidad,    	
			_no_poliza,			
			_cant2,				
			_nombre_contra,		
			_estatus_poliza,    
			_nombre_depend2,    
			_nombre_parentesco2,  
			_edadcal2,				
			_cod_cltdepe2,			
			_fecha_nac2,			
			_fecha_efectiva2,		
			_nom_procedimiento3,
			_nom_procedimiento4,						   				   
			_grupo,
			_renglon2,
			_Prom_edad, _solo_1_xls,_poliza_cont,_comp_cont,_chr_ini_cont
	  with resume;			  
			  
end foreach
	
--drop table if exists tmp_sppro186;
--drop table if exists tmp_sppro187;
--drop table if exists tmp_sppro188;	
end procedure;

		   