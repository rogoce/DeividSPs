-- Procedimiento del reporte de Campañas de Actualización de Datos en el módulo de Atención al Cliente 
-- Creado:	26/07/2022 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_atc40(current)

drop procedure sp_atc40;
create procedure sp_atc40(a_fecha1 date)
RETURNING CHAR(15) as tipo_persona,
		CHAR(10) as cod_cliente,
		VARCHAR(30) as cedula, 
		DATE as fecha_aniversario, 
		VARCHAR(50) as direccion_1, 
		CHAR(10) as telefono1, 
		CHAR(10) as telefono2, 
		CHAR(10) as telefono3, 
		CHAR(10) as celular,  
		CHAR(50) as e_mail , 
		VARCHAR(100) as nombre, 
		CHAR(15) as sexo,
		VARCHAR(50) as direccion_2, 
		VARCHAR(50) as profesion,
		VARCHAR(50) as ocupacion,
		CHAR(10) as categoria,
		CHAR(20) as no_documento,
		VARCHAR(50) as ramo, 
		DATE as date_changed, 
		CHAR(20) as telefono1_sg, 
		CHAR(20) as telefono2_sg, 
		CHAR(20) as telefono3_sg, 
		CHAR(20) as celular_sg;
		


DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
DEFINE _no_poliza    	CHAR(10); 
define	_tipo_persona CHAR(15);
define	_cod_cliente CHAR(10);
define	_cedula VARCHAR(30)	;
define	_fecha_aniversario DATE;
define	_direccion_1 VARCHAR(50);
define	_telefono1 CHAR(10);
define	_telefono2 CHAR(10);
define	_telefono3 CHAR(10);
define	_celular CHAR(10);
define	_e_mail CHAR(50);
define	_nombre VARCHAR(100);
define	_sexo CHAR(15);
define	_direccion_2 VARCHAR(50);
define	_profesion VARCHAR(50);
define	_cod_categoria CHAR(1);
define	_cod_ocupacion CHAR(3);
define	_categoria CHAR(10);
define	_no_documento CHAR(20);
define	_ramo VARCHAR(50);
define	_date_changed DATE;
define	_telefono1_sg CHAR(20);
define	_telefono2_sg CHAR(20);
define	_telefono3_sg CHAR(20);
define	_celular_sg CHAR(20);
define _cod_profesion char(5);
define	_ocupacion VARCHAR(50);

	drop table if exists tmp_sp_atc40;
CREATE TEMP TABLE tmp_sp_atc40
		(tipo_persona CHAR(15),
		cod_cliente CHAR(10),
		cedula VARCHAR(30), 
		fecha_aniversario DATE, 
		direccion_1 VARCHAR(50), 
		telefono1 CHAR(10), 
		telefono2 CHAR(10), 
		telefono3 CHAR(10), 
		celular CHAR(10),  
		e_mail CHAR(50), 
		nombre VARCHAR(100) , 
		sexo CHAR(15),
		direccion_2 VARCHAR(50), 
		profesion VARCHAR(50),
		ocupacion VARCHAR(50),
		categoria CHAR(10),
		no_documento CHAR(20),
		ramo VARCHAR(50), 
		date_changed DATE, 
		telefono1_sg CHAR(20), 
		telefono2_sg CHAR(20), 
		telefono3_sg CHAR(20), 
		celular_sg CHAR(20),  		
      PRIMARY KEY (no_documento, cod_cliente))
      WITH NO LOG;	  



BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN 	'','','',null,'','','','','','','','','','','','','',r_descripcion,null, '','','','';
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_atc40.trc"; 
--trace on;

FOREACH
	select distinct --tipo_persona,
	        CASE WHEN tipo_persona = "J" THEN "JURIDICO" ELSE (CASE WHEN tipo_persona = "N" THEN "NATURAL" ELSE (CASE WHEN tipo_persona = "G" THEN "GUBERNAMENTAL" ELSE "" END) END) END,
			a.cod_cliente,
			cedula,
			fecha_aniversario,
			direccion_1,
			telefono1,
			telefono2,
			telefono3,
			celular,
			e_mail,
			a.nombre,   --sexo
			CASE WHEN sexo = "M" THEN "MASCULINO" ELSE (CASE WHEN sexo = "F" THEN "FEMENINO" ELSE (CASE WHEN sexo = "N" THEN "NEUTRO" ELSE "" END) END) END,
			direccion_2,
			profesion,
			cod_ocupacion,
			decode(b.cod_categoria,'G','GOLD','S','SILVER',''),  ---b.cod_categoria,
			polizas_activas.no_documento,
			e.nombre  as ramo,
			a.date_changed,
			d.no_poliza
	into    _tipo_persona ,
			_cod_cliente,
			_cedula,
			_fecha_aniversario,
			_direccion_1,
			_telefono1,
			_telefono2,
			_telefono3,
			_celular,
			_e_mail,
			_nombre,
			_sexo,
			_direccion_2 ,
			_profesion, 
			_cod_ocupacion,
			_categoria,
			_no_documento,
			_ramo ,
			_date_changed,
            _no_poliza			
	from cliclien a left join clivip b on (a.cod_cliente = b.cod_cliente and  ((a_fecha1 -  3 units month) <  a.date_changed)   )
	inner join (select cod_contratante, max(a.no_documento) no_documento
				from emipoliza a inner join emipomae b on (a.no_poliza = b.no_poliza and b.cod_tipoprod not in ('002') )
				where cod_status = 1
				group by   cod_contratante
				) polizas_activas   on (polizas_activas.cod_contratante = a.cod_cliente)
	inner join emipoliza d on (d.no_documento = polizas_activas.no_documento)
	inner join prdramo  e on (e.cod_ramo = d.cod_ramo)
	where (cedula is null or fecha_aniversario is null or direccion_1 is null or (telefono1 is null and telefono2 is null and telefono3 is null and celular is null) or e_mail is null)
	  and tipo_persona in ('N','J')	  	  	  

		if _celular is null then
			let _celular_sg = '';
		else 
		    let _celular_sg = replace(_celular,"-","");
			if _celular_sg is null then
				let _celular_sg = '';
			else 
				 let _celular_sg = "+507"||trim(_celular_sg);
			end if
		end if

		if _telefono1 is null then
			let _telefono1_sg = '';
		else 
		    let _telefono1_sg = replace(_telefono1,"-","");
			if _telefono1_sg is null then
				let _telefono1_sg = '';
			else 
				 let _telefono1_sg = "+507"||trim(_telefono1_sg);
			end if
		end if	  
		
		if _telefono2 is null then
			let _telefono2_sg = '';
		else 
		    let _telefono2_sg = replace(_telefono2,"-","");
			if _telefono2_sg is null then
				let _telefono2_sg = '';
			else 
				 let _telefono2_sg = "+507"||trim(_telefono2_sg);
			end if
		end if		
	  
		if _telefono3 is null then
			let _telefono3_sg = '';
		else 
		    let _telefono3_sg = replace(_telefono3,"-","");
			if _telefono3_sg is null then
				let _telefono3_sg = '';
			else 
				 let _telefono3_sg = "+507"||trim(_telefono3_sg);
			end if
		end if	   
		
		if _profesion is null then
			let _profesion = '';
		{else 
			SELECT trim(nombre)
			  into _profesion
			  FROM cliprofesion
			  where cod_profesion = _cod_profesion;}
		  
		end if
		  
		if _cod_ocupacion is null then
			let _ocupacion = '';
		else 		  
			SELECT trim(nombre) 
			  into _ocupacion    
			  FROM cliocupa   		  
			 where cod_ocupacion = _cod_ocupacion;
		end if

       begin
		ON EXCEPTION IN(-239)
		END EXCEPTION
		insert into tmp_sp_atc40(
				tipo_persona ,
				cod_cliente,
				cedula,
				fecha_aniversario,
				direccion_1,
				telefono1,
				telefono2,
				telefono3,
				celular,
				e_mail,
				nombre,
				sexo,
				direccion_2 ,
				profesion,
				ocupacion,
				categoria,
				no_documento,
				ramo ,
				date_changed,
				telefono1_sg, 
		        telefono2_sg, 
		        telefono3_sg, 
		        celular_sg
				)
				values (_tipo_persona ,
				_cod_cliente,
				_cedula,
				_fecha_aniversario,
				_direccion_1,
				_telefono1,
				_telefono2,
				_telefono3,
				_celular,
				_e_mail,
				_nombre,
				_sexo,
				_direccion_2 ,
				_profesion,
				_ocupacion,
				_categoria,
				_no_documento,
				_ramo ,
				_date_changed,
				_telefono1_sg, 
		        _telefono2_sg, 
		        _telefono3_sg, 
		        _celular_sg				
				);

	   end	               

    

END FOREACH

FOREACH	WITH HOLD
	SELECT tipo_persona ,
				cod_cliente,
				cedula,
				fecha_aniversario,
				direccion_1,
				telefono1,
				telefono2,
				telefono3,
				celular,
				e_mail,
				nombre,
				sexo,
				direccion_2 ,
				profesion,
				ocupacion,
				categoria,
				no_documento,
				ramo ,
				date_changed,
				telefono1_sg, 
		        telefono2_sg, 
		        telefono3_sg, 
		        celular_sg
	  INTO _tipo_persona ,
				_cod_cliente,
				_cedula,
				_fecha_aniversario,
				_direccion_1,
				_telefono1,
				_telefono2,
				_telefono3,
				_celular,
				_e_mail,
				_nombre,
				_sexo,
				_direccion_2 ,
				_profesion,
				_ocupacion,
				_categoria,
				_no_documento,
				_ramo ,
				_date_changed,
				_telefono1_sg, 
		        _telefono2_sg, 
		        _telefono3_sg, 
		        _celular_sg		
	  FROM tmp_sp_atc40


    RETURN _tipo_persona ,
			_cod_cliente,
			_cedula,
			_fecha_aniversario,
			_direccion_1,
			_telefono1,
			_telefono2,
			_telefono3,
			_celular,
			_e_mail,
			_nombre,
			_sexo,
			_direccion_2 ,
			_profesion,
			_ocupacion,
			_categoria,
			_no_documento,
			_ramo ,
			_date_changed,
			_telefono1_sg, 
			_telefono2_sg, 
			_telefono3_sg, 
			_celular_sg	
			WITH RESUME;

END FOREACH


END
end procedure