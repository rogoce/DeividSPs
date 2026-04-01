-- Informaci¢n: para Panama  Asistencia Ramo Salud, carga de productos vida individual, 
-- Programa de Ancon Viajero para pólizas de salud el 01/09/2017.
-- Los nuevos se enviarán en el reporte diario y las renovaciones mensualmente. 
-- Creado     : 21/09/2017 - Autor: Henry Giron.
DROP PROCEDURE sp_pro410; 
create procedure sp_pro410() 
returning 	CHAR(50) as Asegurado, -- 1. Nombre del Titular 
			CHAR(20) as Cedula, -- 2. Cedula del Titular 
			char(50) as Dependiente, -- 3. Nombre del Dependiente 
			CHAR(20) as ced_dependiente, -- 4. Cedula del Dependiente 
			CHAR(20) as Poliza, -- 5. Numero de Documento 
			CHAR(10) as Vigencia_Inic, -- 6. Vigencia Inicial de la Poliza 
			CHAR(10) as Vigencia_Fin, -- 7. Vigencia Final de la Poliza 
			CHAR(50) as Producto, -- 8. Nombre del Producto 
			CHAR(20) as PIN; --10. PIN   (INDIVIDUAL o COLECTIVO) 
	 
define _no_poliza         char(10);	 
define _cod_ramo          char(3);   
define _nombre_aseg	      char(50);  
define v_no_unidad	   	  char(5);   
define _cod_asegurado     char(10);	 
define _no_documento      CHAR(20);  
define _cod_producto   	  char(5);	 
define _nombre_producto	  char(50);	 
define _nombre_depen      char(30);  
define _cedula            char(30);	 
define _cant 			  integer;   
define _vigencia_inic     date;      
define _vigencia_final    date;      
define _cod_cltdepe       char(10);	 -- 
define _cod_parent        char(3);   -- 
define _tipo_parent       char(15);  --
define _fecha1_char       char(10);	 --
define _fecha2_char       char(10);	 --
define _fechaa            char(10);	 --
define _fechab            char(10);	 --
define _cedula_depen      char(30);	 --
define _fecha			  date;
define _periodo			  char(7);
define _fecha_ult_dia     DATE;
define _nueva_renov       char(1);
define _estado            char(10);
define _desc_estatus      char(10);
define _tipo              char(10);
define _error_desc			CHAR(50);
define _error_isam			integer;
define _error				integer;
Define _filtro				char(1);

drop table if exists temp_data0;
	  
create temp table temp_data0(
		nombre_aseg 	CHAR(50), -- 1. Nombre del Titular
		cedula			CHAR(20), -- 2. Cedula del Titular
		nombre_depen	CHAR(50), -- 3. Nombre del Dependiente
		cedula_depen	CHAR(20), -- 4. Cedula del Dependiente
		no_documento	CHAR(20), -- 5. Numero de Documento
		fechaa			CHAR(10), -- 6. Vigencia Inicial de la Poliza
		fechab			CHAR(10), -- 7. Vigencia Final de la Poliza
		nombre_producto	CHAR(50), -- 8. Nombre del Producto
		estado			CHAR(20), -- 9. Estatus Poliza
		tipo			CHAR(20)) with no log;
CREATE INDEX idx1_temp_data0 ON temp_data0(no_documento,cedula,cedula_depen);		
--,primary key (no_documento,cedula,cedula_depen)		

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error,_error_isam,_error_desc	
	return _error,_error_desc,'','','','','','','';
end exception 

LET _cod_ramo 		= "018";
LET _cant    		=     0;
LET _tipo  		    =  "INDIVIDUAL";
LET _tipo_parent 	= "";
LET _nombre_depen 	= "";
let _cod_cltdepe 	= "";
let _cod_parent 	= "";
let _cedula_depen   = "";

let _fecha          = today;
let _periodo        = sp_sis39(_fecha);
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;
let _fecha_ult_dia = _fecha;
drop table if exists tmp_codigos;
if _fecha <> _fecha_ult_dia then  --and _cod_producto  IN ( '03643','03644','03645','03646','03647','03648','03649','03650','03651','03652') then
CALL  sp_sis04('03665,03666,03667,03668,03669,03670;') returning _filtro;
else
	CALL  sp_sis04('03665,03666,03667,03668,03669,03670,03643,03644,03645,03646,03647,03648,03649,03650,03651,03652;') returning _filtro;
end if

foreach 
	 select a.no_poliza,
		    a.no_documento,
			a.vigencia_inic,  
			a.vigencia_final,
			(case when a.nueva_renov = "N" then "NUEVA" else "RENOVADA" end) nueva_renov,
			g.no_unidad,
			g.cod_asegurado,
			g.cod_producto,
			(case when a.estatus_poliza = 1 then "VIGENTE" else "" end) desc_estatus
	  into _no_poliza,
		    _no_documento,
			_fecha1_char,
			_fecha2_char,
			_estado,
			 v_no_unidad,
			_cod_asegurado,
			_cod_producto,
			_desc_estatus
	   from emipomae a,emipouni g
	  where a.no_poliza      = g.no_poliza
	    and a.cod_ramo       = _cod_ramo
		and a.actualizado    = 1
		and a.estatus_poliza = 1	    	    
		and g.activo         = 1
		AND g.vigencia_inic <= _fecha
		AND g.vigencia_final >= _fecha
		and g.cod_producto  IN (select codigo  from tmp_codigos )		
   order by g.cod_asegurado,a.no_poliza,g.no_unidad     
   
   {and g.cod_producto  IN (	'03665','03666',
								'03667','03668','03669','03670',
								'03643','03644','03645',
								'03646','03647','03648','03649',
								'03650','03651','03652')}


	let _no_documento = trim(_no_documento);	

	 select nombre,		        
			cedula
	   into _nombre_aseg,		        
			_cedula
	   from cliclien 
	  where cod_cliente = _cod_asegurado;

	 select nombre
	   into _nombre_producto
	   from prdprod 
	  where cod_producto  = _cod_producto;

	let _nombre_aseg     = trim(_nombre_aseg);
	let _nombre_producto = trim(_nombre_producto);
	let _cedula          = trim(_cedula);		
	let _fechaa          = REPLACE(trim(_fecha1_char),"/","");  
	let _fechab          = REPLACE(trim(_fecha2_char),"/","");
	 
	 select count(*)
	   into _cant
	   from emidepen
	  where activo         = "1"
		and no_poliza      = _no_poliza
		and no_unidad      = v_no_unidad;
		
	  If _cant = 0	 then	--> Lo puse en comentario para que se envie los datos del asegurado (Cedula)
			  LET _tipo_parent = "";
			  LET _nombre_depen = "";
			  
			  begin
					on exception in(-239)
					end exception

					insert into temp_data0
					values (
							_nombre_aseg, 	
							_cedula,      	
							_nombre_depen, 	
							_cedula_depen , 
							_no_documento, 	
							_fechaa, 		
							_fechab, 		
							_nombre_producto, 
							_estado, 			
							_tipo
							);
				end							  
			
	 else		
	 
		 foreach		 
			 select cod_cliente,
					cod_parentesco
			   into _cod_cltdepe,
					_cod_parent
			   from emidepen
			  where activo     = "1"
				and no_poliza  = _no_poliza
				and no_unidad  = v_no_unidad

			 select nombre, cedula
			   into _nombre_depen, _cedula_depen  
			   from cliclien 					  
			  where cod_cliente = _cod_cltdepe;
			 
			  begin
					on exception in(-239)
					end exception

					insert into temp_data0
					values (
							_nombre_aseg, 	
							_cedula,      	
							_nombre_depen, 	
							_cedula_depen , 
							_no_documento, 	
							_fechaa, 		
							_fechab, 			
							_nombre_producto, 	
							_estado, 			
							_tipo
							);
				end				 
			 
		   
		  end foreach;
	end if
	 
   end foreach;
   
foreach with hold
	 select nombre_aseg,
			cedula,
			nombre_depen,
			cedula_depen,
			no_documento,
			fechaa,
			fechab,
			nombre_producto,
			estado,
			tipo
	  into 	_nombre_aseg,
			_cedula,
			_nombre_depen,
			_cedula_depen,
			_no_documento,
			_fechaa, 
			_fechab, 
			_nombre_producto,
			_estado,
		    _tipo
	  from temp_data0
	 order by nombre_aseg,no_documento,nombre_depen	 	 
	 

	return	_nombre_aseg, 		-- 1. Nombre del Titular
			_cedula,      		-- 2. Cedula del Titular
			_nombre_depen, 		-- 3. Nombre del Dependiente
			_cedula_depen , 	-- 4. Cedula del Dependiente
			_no_documento, 		-- 5. Numero de Documento
			_fechaa, 			-- 6. Vigencia Inicial de la Poliza
			_fechab, 			-- 7. Vigencia Final de la Poliza
			_nombre_producto, 	-- 8. Nombre del Producto
			_tipo       		--10. PIN   (INDIVIDUAL o COLECTIVO)				  
	  with resume;			  
			  
end foreach
   

   
   end
   end procedure;