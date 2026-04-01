-- Informaci¢n: para Panama  Asistencia Ramo Salud, carga de productos vida individual, 
-- Programa de Ancon Viajero para pólizas de salud el 01/09/2017.
-- Los nuevos se enviarán en el reporte diario y las renovaciones mensualmente. 
-- Creado     : 21/09/2017 - Autor: Henry Giron.
		
DROP PROCEDURE sp1_pro410; 
create procedure sp1_pro410() 
returning 	
			VARCHAR(20) as CEDULA,	
			VARCHAR(60) as NOMBRE, 	
			VARCHAR(25) as POLIZA,	
			VARCHAR(10) as UNIDAD,
			DATE as FECHA_NACIO,      -- dd/mm/yyyy	
			VARCHAR(2) as EDAD,
			VARCHAR(150) as DIRECCION,	
			VARCHAR(50) as CORREO,	
			VARCHAR(10) as TEL_CEL,
			VARCHAR(20) as PIN,	
			VARCHAR(20) as TIPO_COBERTURA,	
			DATE as FECHA_INICIAL,	  -- dd/mm/yyyy	
			DATE as FECHA_FINAL,	  -- dd/mm/yyyy	
			DATE as FECHA_BASE_DATOS, -- dd/mm/yyyy	
			VARCHAR(10) as ATRIBUTO1,	
			VARCHAR(30) as ATRIBUTO2,	
			VARCHAR(50) as ATRIBUTO3,	
			VARCHAR(80) as ATRIBUTO4,	
			VARCHAR(100) as ATRIBUTO5,	
			VARCHAR(150) as ATRIBUTO6;
	
			
define _no_poliza, _no_poliza_ant         char(10);	 
define _cod_ramo          char(3);   
define _nombre_aseg	      char(50);  
define v_no_unidad	   	  char(5);   
define _cod_asegurado     char(10);	 
define _no_documento      CHAR(20);  
define _no_documento_ant  CHAR(20);  
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
define _tipo              char(20);
define _error_desc			CHAR(50);
define _error_isam			integer;
define _error				integer;
Define _filtro				char(1);
define _unidad    		   integer;
define _fecha_nac         date;
define _edad,_orden		 smallint;
define _nombre_parentesco char(50); 

define _fecha1          date;	 --
define _fecha2          date;	 --

define _direccion_1		VARCHAR(150);
define _direccion_2		VARCHAR(150);
define _e_mail			VARCHAR(50);
define _telefono1       VARCHAR(10);
define _celular         VARCHAR(10);

define	CEDULA_data				VARCHAR(20);	
define	NOMBRE_data				VARCHAR(60);	
define	POLIZA_data				VARCHAR(25);	
define	UNIDAD_data				VARCHAR(10);	
define	FECHA_NACIO_data		DATE;	
define	EDAD_data				VARCHAR(2);	
define	DIRECCION_data			VARCHAR(150);	
define	CORREO_data				VARCHAR(50);	
define	TEL_CEL_data		    VARCHAR(10);	
define	PIN_data	            VARCHAR(20);	
define	TIPO_COBERTURA_data		VARCHAR(20);	
define	FECHA_INICIAL_data		DATE;	
define	FECHA_FINAL_data		DATE;	
define	FECHA_BASE_DATOS_data	DATE;	
define	ATRIBUTO1_data			VARCHAR(10);	
define	ATRIBUTO2_data			VARCHAR(30);	
define	ATRIBUTO3_data			VARCHAR(50);	
define	ATRIBUTO4_data			VARCHAR(80);	
define	ATRIBUTO5_data			VARCHAR(100);
define	ATRIBUTO6_data			VARCHAR(150);	
DEFINE  _cod_subramo	CHAR(3);
DEFINE _desc_ramo,_desc_subramo CHAR(50);

drop table if exists temp_real0;
create temp table temp_real0(
			t_no_poliza      char(10),
		    t_no_documento   char(20),
			t_fecha1_char    char(10),
			t_fecha2_char    char(10),
			t_estado         char(10),
			t_no_unidad      char(5),
			t_cod_asegurado  char(10),
			t_cod_producto   char(5),
			t_desc_estatus   char(10),
			t_fecha1         date,
			t_fecha2         date
) with no log;
CREATE INDEX idx1_temp_real0 ON temp_real0(t_no_poliza,t_cod_asegurado,t_no_unidad);

drop table if exists temp_data0;
create temp table temp_data0(
		CEDULA				VARCHAR(20)	,
		NOMBRE				VARCHAR(60)	,
		POLIZA				VARCHAR(25)	,
		UNIDAD				VARCHAR(10)	,
		FECHA_NACIO			DATE	,
		EDAD				VARCHAR(2)	,
		DIRECCION			VARCHAR(150)	,
		CORREO				VARCHAR(50)	,
		TEL_CEL				VARCHAR(10)	,
		PIN					VARCHAR(20)	,
		TIPO_COBERTURA		VARCHAR(20)	,
		FECHA_INICIAL		DATE	,
		FECHA_FINAL		 	DATE	,
		FECHA_BASE_DATOS 	DATE	,
		ATRIBUTO1			VARCHAR(10)	,
		ATRIBUTO2			VARCHAR(30)	,
		ATRIBUTO3			VARCHAR(50)	,
		ATRIBUTO4			VARCHAR(80)	,
		ATRIBUTO5			VARCHAR(100)	,
		ATRIBUTO6			VARCHAR(150)	
) with no log;
CREATE INDEX idx1_temp_data0 ON temp_data0(POLIZA,CEDULA,UNIDAD);
	  
let _error_desc = '';
let _error = 1;
let _desc_ramo = '';
let _desc_subramo = '';
let _cod_subramo = '';
let _cod_ramo = '';
let _orden = 0;
delete from notramsub;
SET ISOLATION TO DIRTY READ;
begin 
on exception set _error,_error_isam,_error_desc	
	return _error,_error_desc,'','',null,'','','','','','',null,null,null,'','','','','','';			
end exception 

LET _cod_ramo 		= "018";
LET _cant    		=     0;
LET _tipo_parent 	= "";
LET _nombre_depen 	= "";
let _cod_cltdepe 	= "";
let _cod_parent 	= "";
let _cedula_depen   = "";
let _unidad = 0;

let _fecha          = today;
let _periodo        = sp_sis39(_fecha);
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;
let _fecha_ult_dia = _fecha;
drop table if exists tmp_codigos;
if _fecha <> _fecha_ult_dia then  -- and _cod_producto  IN ( '03643','03644','03645','03646','03647','03648','03649','03650','03651','03652') then
	CALL  sp_sis04('03665,03666,03667,03668,03669,03670;') returning _filtro;
else
	CALL  sp_sis04('03665,03666,03667,03668,03669,03670,03643,03644,03645,03646,03647,03648,03649,03650,03651,03652;') returning _filtro;
end if

-- Insertar Datos de SALUD 
	insert into temp_real0
			(t_no_poliza,
		    t_no_documento,
			t_fecha1_char,
			t_fecha2_char,
			t_estado,
			t_no_unidad,
			t_cod_asegurado,
			t_cod_producto,
			t_desc_estatus,
			t_fecha1,
			t_fecha2)
	 select a.no_poliza,
		    a.no_documento,
			a.vigencia_inic,  
			a.vigencia_final,
			(case when a.nueva_renov = "N" then "NUEVA" else "RENOVADA" end) nueva_renov,
			g.no_unidad,
			g.cod_asegurado,
			g.cod_producto,
			(case when a.estatus_poliza = 1 then "VIGENTE" else "" end) desc_estatus,
			a.vigencia_inic,  
			a.vigencia_final				 
	   from emipomae a,emipouni g
	  where a.no_poliza      = g.no_poliza
	    and a.cod_ramo       = _cod_ramo
		and a.actualizado    = 1
		and a.estatus_poliza = 1	    	    
		and g.activo         = 1
		AND g.vigencia_inic <= _fecha
		AND g.vigencia_final >= _fecha
		and g.cod_producto  IN ( SELECT prdcobpd.cod_producto
                                 FROM prdcober, prdcobpd, prdprod, emipocob
                                WHERE prdcober.cod_cobertura = prdcobpd.cod_cobertura
                                  AND prdcobpd.cod_producto = prdprod.cod_producto
                                  AND prdcober.cod_ramo = _cod_ramo
                                  AND prdcober.nombre like "ASISTENCIA%VIAJE%" 
								  AND emipocob.no_poliza = a.no_poliza
                                  AND emipocob.no_unidad = g.no_unidad
                                  AND prdcobpd.cod_cobertura = emipocob.cod_cobertura)
--		and g.cod_producto  IN (select codigo  from tmp_codigos )		
   order by g.cod_asegurado,a.no_poliza,g.no_unidad;      			
   
-- Insertar Datos de SALUD - COLECTIVOS 
	insert into temp_real0
			(t_no_poliza,
		    t_no_documento,
			t_fecha1_char,
			t_fecha2_char,
			t_estado,
			t_no_unidad,
			t_cod_asegurado,
			t_cod_producto,
			t_desc_estatus,
			t_fecha1,
			t_fecha2)
	 select a.no_poliza,
		    a.no_documento,
			a.vigencia_inic,  
			a.vigencia_final,
			(case when a.nueva_renov = "N" then "NUEVA" else "RENOVADA" end) nueva_renov,
			g.no_unidad,
			g.cod_asegurado,
			g.cod_producto,
			(case when a.estatus_poliza = 1 then "VIGENTE" else "" end) desc_estatus,
			a.vigencia_inic,  
			a.vigencia_final			
	   from emipomae a,emipouni g
	  where a.no_poliza      = g.no_poliza
	    and a.cod_ramo       = '018'  -- SALUD
        and a.cod_subramo    = '012'  -- COLECTIVO    --EMAIL:FANY 15/01/2018, ASEGURADOS y DEPENDIENTES
		and a.actualizado    = 1
		and a.estatus_poliza = 1	    	    
		and g.activo         = 1
		AND g.vigencia_inic <= _fecha
		AND g.vigencia_final >= _fecha
        --  and g.cod_producto  IN ('01731','01732','02182','03804','03801','01139','01140','01141','01046','01047','01048','01148','01150','01149','01147','01146','01151','00812','00813','00814','00822','00823','00824','02360','0944','0945','0946','01585','01584','01583','02119','02120','02121','02246','02247','02248','01602','01603','01604','01615','01590','01614','00635','00633','00634','01386','01387','01388','01057','01058','01059','00959','00960','00961','00923','00924','00925','01622','00893','00894','00895','01623','01624','01625','02287','01877','01939','01940','01619','01620','01621','04239','04240','04241')
        --  and a.no_documento in ('1803-00392-01','1805-01105-01','1805-01117-01','1807-00644-01','1807-00705-01','1815-00205-01','1804-01394-01','1810-01760-01','1814-00321-01','1815-00200-01','1810-01883-01','1810-01813-01','1807-00018-01','1806-00058-01','1805-00059-01','1806-00089-01','1805-00068-01','1811-00086-01','1808-00049-01','1811-00081-01','1816-00009-01','1813-00033-01','1811-00087-01')	
		and g.cod_producto in ( select rtrim(cod_producto) from polprod19 )
   order by g.cod_asegurado,a.no_poliza,g.no_unidad;         
   
--return _error,_error_desc,'','',null,'','','','','','',null,null,null,'','','','','','';   

-- Insertar Datos de ACCIDENTES PERSONALES
	insert into temp_real0
			(t_no_poliza,
		    t_no_documento,
			t_fecha1_char,
			t_fecha2_char,
			t_estado,
			t_no_unidad,
			t_cod_asegurado,
			t_cod_producto,
			t_desc_estatus,
			t_fecha1,
			t_fecha2)
	 select a.no_poliza,
		    a.no_documento,
			a.vigencia_inic,
			a.vigencia_final,
			(case when a.nueva_renov = "N" then "NUEVA" else "RENOVADA" end) nueva_renov,
			g.no_unidad,
			g.cod_asegurado,
			g.cod_producto,
			(case when a.estatus_poliza = 1 then "VIGENTE" else "" end) desc_estatus,
			a.vigencia_inic,
			a.vigencia_final
 	   from emipomae a,emipouni g, emipocob h
	  where a.no_poliza      = g.no_poliza
        and g.no_poliza      = h.no_poliza
        and g.no_unidad      = h.no_unidad
	    and a.cod_ramo       = '004'  -- ACCIDENTES PERSONALES
 		and a.actualizado    = 1
		and a.estatus_poliza = 1
		and g.activo         = 1
		and g.vigencia_inic  <= _fecha
		and g.vigencia_final >= _fecha
 		and g.cod_producto in ( '08741', '08742' )
        and h.cod_cobertura  = '01854'
   order by g.cod_asegurado,a.no_poliza,g.no_unidad;


{foreach 
	 select a.no_poliza,
		    a.no_documento,
			a.vigencia_inic,  
			a.vigencia_final,
			(case when a.nueva_renov = "N" then "NUEVA" else "RENOVADA" end) nueva_renov,
			g.no_unidad,
			g.cod_asegurado,
			g.cod_producto,
			(case when a.estatus_poliza = 1 then "VIGENTE" else "" end) desc_estatus,
			a.vigencia_inic,  
			a.vigencia_final			
	  into _no_poliza,
		    _no_documento,
			_fecha1_char,
			_fecha2_char,
			_estado,
			 v_no_unidad,
			_cod_asegurado,
			_cod_producto,
			_desc_estatus,
			_fecha1,
			_fecha2
	   from emipomae a,emipouni g
	  where a.no_poliza      = g.no_poliza
	    and a.cod_ramo       = _cod_ramo
		and a.actualizado    = 1
		and a.estatus_poliza = 1	    	    
		and g.activo         = 1
		AND g.vigencia_inic <= _fecha
		AND g.vigencia_final >= _fecha
		and g.cod_producto  IN (select codigo  from tmp_codigos )		
   order by g.cod_asegurado,a.no_poliza,g.no_unidad}  

let _no_documento_ant = "";
   
foreach 
	 select t_no_poliza,
		    t_no_documento,
			t_fecha1_char,
			t_fecha2_char,
			t_estado,
			t_no_unidad,
			t_cod_asegurado,
			t_cod_producto,
			t_desc_estatus,
			t_fecha1,
			t_fecha2
	  into _no_poliza,
		    _no_documento,
			_fecha1_char,
			_fecha2_char,
			_estado,
			 v_no_unidad,
			_cod_asegurado,
			_cod_producto,
			_desc_estatus,
			_fecha1,
			_fecha2
	   from temp_real0	  
   group by t_no_poliza,
		    t_no_documento,
			t_fecha1_char,
			t_fecha2_char,
			t_estado,
			t_no_unidad,
			t_cod_asegurado,
			t_cod_producto,
			t_desc_estatus,
			t_fecha1,
			t_fecha2 	   
   order by t_no_poliza,t_no_unidad   
   
	let _no_documento = trim(_no_documento);	

	 select nombre,		        
			cedula,
			fecha_aniversario,
			telefono1,
			celular, 
			e_mail, 
			direccion_1, 
			direccion_2
	   into _nombre_aseg,		        
			_cedula,
			_fecha_nac,
			_telefono1,
			_celular, 
			_e_mail, 
			_direccion_1, 
			_direccion_2			
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
	let _edad            = sp_sis78(_fecha_nac,today);	 
	LET _tipo  		    =  "INDIVIDUAL";	
	  
		  LET _tipo_parent = "";
		  LET _nombre_depen = "";
		  let _nombre_parentesco = "PRINCIPAL";
		  
		  IF trim(_no_documento_ant) <> trim(_no_documento) THEN
			let _unidad = 1;
		  ELSE
			let _unidad = _unidad + 1;
		  END IF
		  
		  let _no_documento_ant = _no_documento;
		  
		  begin
				on exception in(-239)
				end exception

				insert into temp_data0(
						CEDULA,
						NOMBRE,
						POLIZA,
						UNIDAD,
						FECHA_NACIO,
						EDAD,
						DIRECCION,
						CORREO,
						TEL_CEL,
						PIN,
						TIPO_COBERTURA,
						FECHA_INICIAL,
						FECHA_FINAL,
						FECHA_BASE_DATOS,
						ATRIBUTO1,
						ATRIBUTO2,
						ATRIBUTO3,
						ATRIBUTO4,
						ATRIBUTO5,
						ATRIBUTO6)
						Values(
						_cedula,
						_nombre_aseg,
						_no_documento,
						_unidad,
						_fecha_nac,
						_edad,
						_direccion_1,
						_e_mail,
						_telefono1,
						_tipo,
						_nombre_parentesco,
						_fecha1,
						_fecha2,
						_fecha,
						'',
						'',
						'',
						'',
						'',
						''
						);

				

			end							  
			
	 
	 select count(*)
	   into _cant
	   from emidepen
	  where activo         = "1"
		and no_poliza      = _no_poliza
		and no_unidad      = v_no_unidad;
		
		if _cant > 0 then		
		
		LET _tipo  		    =  "DEPENDIENTE";
	
			 foreach		 
				 select cod_cliente,
						cod_parentesco
				   into _cod_cltdepe,
						_cod_parent
				   from emidepen
				  where activo     = "1"
					and no_poliza  = _no_poliza
					and no_unidad  = v_no_unidad
					
					let _unidad = _unidad + 1;

				 select nombre, 
				        cedula,
				 		fecha_aniversario,
						telefono1,
						celular, 
						e_mail, 
						direccion_1, 
						direccion_2
				   into _nombre_depen, 
				        _cedula_depen, 
						_fecha_nac,
						_telefono1,
						_celular, 
						_e_mail, 
						_direccion_1, 
						_direccion_2	
				   from cliclien 					  
				  where cod_cliente = _cod_cltdepe;
				  	let _edad            = sp_sis78(_fecha_nac,today);	 	
					  if _cedula_depen is null then
					     let _cedula_depen = _cod_cltdepe;
					  end if
				  
				select upper(nombre)
				  into _nombre_parentesco
				  from emiparen
				 where cod_parentesco   = _cod_parent;				  
				 
				  begin
						on exception in(-239)
						end exception
					insert into temp_data0(
							CEDULA,
							NOMBRE,
							POLIZA,
							UNIDAD,
							FECHA_NACIO,
							EDAD,
							DIRECCION,
							CORREO,
							TEL_CEL,
							PIN,
							TIPO_COBERTURA,
							FECHA_INICIAL,
							FECHA_FINAL,
							FECHA_BASE_DATOS,
							ATRIBUTO1,
							ATRIBUTO2,
							ATRIBUTO3,
							ATRIBUTO4,
							ATRIBUTO5,
							ATRIBUTO6)
							Values(
							_cedula_depen,
							_nombre_depen,
							_no_documento,
							_unidad,
							_fecha_nac,
							_edad,
							_direccion_1,
							_e_mail,
							_telefono1,
							_tipo,
							_nombre_parentesco,
							_fecha1,
							_fecha2,
							_fecha,
							'',
							'',
							'',
							'',
							'',
							''
							);
					end				 
				 
			   
			  end foreach;
		  end if  
	 
   end foreach;
   
foreach
	 select CEDULA,
			NOMBRE,
			POLIZA,
			UNIDAD,
			FECHA_NACIO,
			EDAD,
			DIRECCION,
			CORREO,
			TEL_CEL,
			PIN,
			TIPO_COBERTURA,
			FECHA_INICIAL,
			FECHA_FINAL,
			FECHA_BASE_DATOS,
			ATRIBUTO1,
			ATRIBUTO2,
			ATRIBUTO3,
			ATRIBUTO4,
			ATRIBUTO5,
			ATRIBUTO6
	  into 	CEDULA_data,
			NOMBRE_data,
			POLIZA_data,
			UNIDAD_data,
			FECHA_NACIO_data,
			EDAD_data,
			DIRECCION_data,
			CORREO_data,
			TEL_CEL_data,
			PIN_data,
			TIPO_COBERTURA_data,
			FECHA_INICIAL_data,
			FECHA_FINAL_data,
			FECHA_BASE_DATOS_data,
			ATRIBUTO1_data,
			ATRIBUTO2_data,
			ATRIBUTO3_data,
			ATRIBUTO4_data,
			ATRIBUTO5_data,
			ATRIBUTO6_data
	  from temp_data0
	 order by nombre,poliza,unidad
	let _orden = _orden + 1;
		   foreach	
			select cod_ramo,
				   cod_subramo
			  into _cod_ramo,
				   _cod_subramo
			  from emipomae y
			 where no_documento = POLIZA_data
			  exit foreach;
			   end foreach	 
			   
		   SELECT nombre
			 INTO _desc_ramo
			 FROM prdramo 
			WHERE cod_ramo = _cod_ramo;

		   SELECT nombre
			 INTO _desc_subramo
			 FROM prdsubra 
			WHERE cod_ramo = _cod_ramo
			  AND cod_subramo = _cod_subramo;			   
			 
			begin
			on exception in(-239)
			end exception
				insert into notramsub(
					cod_ramo,
					cod_subramo, 
					orden, 
					desc_ramo, 
					desc_subramo, 					
					cantidad
				)
				Values(
				    _cod_ramo,
				    _cod_subramo,
					_orden,
					_desc_ramo,
					_desc_subramo,
					1
				);
			end		
	 

	return	CEDULA_data,
			NOMBRE_data,
			POLIZA_data,
			UNIDAD_data,
			FECHA_NACIO_data,
			EDAD_data,
			DIRECCION_data,
			CORREO_data,
			TEL_CEL_data,
			PIN_data,
			TIPO_COBERTURA_data,
			FECHA_INICIAL_data,
			FECHA_FINAL_data,
			FECHA_BASE_DATOS_data,
			ATRIBUTO1_data,
			ATRIBUTO2_data,
			ATRIBUTO3_data,
			ATRIBUTO4_data,
			ATRIBUTO5_data,
			ATRIBUTO6_data
	  with resume;			  
			  
end foreach
   

   
   end
   end procedure;