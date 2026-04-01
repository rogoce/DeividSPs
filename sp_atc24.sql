-- Procedimiento Para Actualizar los Datos de la tabla de atcacbdd desde la web , acutliza los datos para la tombola
-- 
-- Creado    : 20/03/2013 - Autor : Enocjahaziel Carrasco 
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_atc24;

create procedure "informix".sp_atc24(	a_sucursal_web_data char (3),
     									no_boleto_utl char (5),
     									cedula_tabla char(30), 
										a_entro integer,
										a_apto_postal varchar(20),
										a_apellido varchar(40),
										a_aseg_casada_ape varchar (40),
										a_asiento char (7),
										a_folio char (7),
										a_inicial char (2),
										a_provincia char (2),
										a_tomo char (7),
										a_cedula char (30),
										a_cell char (10),
										a_codigo char (10) ,
										a_hoy date,
										a_Direccion_1 varchar (50),
										a_Direccion_2 varchar (50),
										a_e_mail varchar (50),
										a_fecha_nac date, 
										a_l_trabajo varchar (100),
										a_aseg_primer_nombre varchar(100) ,
										a_seg_apellido varchar (40),
										a_seg_nombre varchar (40) ,
										a_sexo char (1),
										a_tel_office char (10),
										a_telefono_1 char (10),
										a_telefono_2 char (10),
										a_Tipo_dato char (1),
										a_Tipo_Persona char (1),
										a_user_changed char (8),
										a_date_added date,
										a_user_added char(8))

returning integer,
          char(10);


define _error		integer;
define _error_isam		integer;
define _error_desc		char(50);
define _boleto char (5);

SET LOCK MODE TO WAIT;

begin work;

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc
rollback work;
  RETURN _error, _error_desc;
END EXCEPTION
	  --  a_entro es igual a 1: debe actualizar 
if a_entro=1 then
-- 

			UPDATE atcacbdd SET 
			apartado=  a_apto_postal,
			apellido=  a_apellido,
			apellido_casada=a_aseg_casada_ape,
			ced_asiento=a_asiento,
			ced_folio=a_folio,
			ced_inicial=a_inicial,
			ced_provincia=a_provincia,
			ced_tomo=a_tomo,
			cedula=a_cedula,
			celular=a_cell,
			cod_cliente=a_codigo,
			date_changed=a_hoy,
			direccion_1=a_Direccion_1,
			direccion_2=a_Direccion_2,
			e_mail=a_e_mail,
			fecha_nac=a_fecha_nac,
			lugar_trabajo=a_l_trabajo,
			nombre=a_aseg_primer_nombre,
			seg_apellido=a_seg_apellido,
			seg_nombre=a_seg_nombre,
			sexo=a_sexo,
			telefono_ofi=a_tel_office,
			telefono1=a_telefono_1,
			telefono2=a_telefono_2,
			tipo_dato=a_Tipo_dato,
			tipo_persona=a_Tipo_Persona,
			user_changed=a_user_changed 
			WHERE cedula = cedula_tabla and no_boleto= no_boleto_utl; 

 --
else 
let _boleto = sp_sis13('001','ATC','02','atc_atcacbdd');
		
Insert Into atcacbdd  (
		no_boleto,
		apartado,
		apellido,
		apellido_casada,
		ced_asiento,
		ced_folio,
		ced_inicial,
		ced_provincia,
		ced_tomo,
		cedula,
		celular,
		cod_cliente,
		cod_sucursal,
		date_changed,
		direccion_1,
		direccion_2,
		e_mail,
		fecha_nac,
		lugar_trabajo,
		nombre,
		seg_apellido,
		seg_nombre,
		sexo,
		telefono_ofi,
		telefono1,
		telefono2,
		tipo_dato,
		tipo_persona,
		user_changed,
		date_added,
		user_added)
		Values (
		 _boleto ,
		a_apto_postal ,
		a_apellido ,
		a_aseg_casada_ape ,
		a_asiento ,
		a_folio,
		a_inicial ,
		a_provincia ,
		a_tomo ,
		a_cedula ,
		a_cell ,
		a_codigo ,
		a_sucursal_web_data,
		a_hoy ,
		a_Direccion_1,
		a_Direccion_2,
		a_e_mail ,
		a_fecha_nac, 
		a_l_trabajo,
		a_aseg_primer_nombre ,
		a_seg_apellido ,
		a_seg_nombre ,
		a_sexo,
		a_tel_office ,
		a_telefono_1 ,
		a_telefono_2 ,
		a_Tipo_dato ,
		a_Tipo_Persona,
		a_user_changed,
		a_date_added,
		a_user_added); 
end if 

	
		
		

END
commit work;

return 0,"Actualizacion Exitosa";
END PROCEDURE;