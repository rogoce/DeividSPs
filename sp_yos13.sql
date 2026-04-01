-- INSERTA REGISTROS EN CLICLIEN DE YOSEGURO AL MOMENTO DE CREAR UN TERCERO

-- Creado    : 19/06/2019 - Autor: Federico Coronado
-- Igual al sp_par332

drop procedure sp_yos13;

create procedure "informix".sp_yos13(as_ruc 			varchar(30), 
									 av_nombre 			varchar(100), 
									 as_user 			char(8), 
									 a_tipo_persona 	char(1), 
									 a_primer_nom		varchar(100), 
									 a_segundo_nom 		varchar(40),
									 a_primer_ape 		varchar(40),
									 a_segundo_ape 		varchar(40),
									 a_apellido_cas 	varchar(100),
									 a_digito_ver   	char(2),
									 a_sexo         	char(1),
									 a_fecha_nac    	date,
									 a_pais_residencia 	varchar(20),
									 a_nacionalidad     varchar(20),
									 a_direccion        varchar(50),
									 a_cod_cliente      varchar(10) default null,
									 a_telefono         varchar(10),
									 a_email            varchar(50)
									 ) RETURNING CHAR(10);

define 	_error			smallint;
define	_cod_cliente	char(10);
define	_fecha			date;
define	_existe			smallint;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION
--set debug file to "sp_YOS13.trc"; 
--trace on;
let _existe = 0;

If a_cod_cliente = '' then
	let a_cod_cliente = null;
end if

if a_cod_cliente is not null then
  SELECT count(*)
	into _existe
    FROM cliclien
   WHERE cliclien.cod_cliente =  a_cod_cliente ;
 end if


   if _existe = 0 then

	let	_cod_cliente = sp_sis13("001", 'PAR', '02', 'par_cliente');
	let	_fecha = sp_sis26();

	  INSERT INTO cliclien
         ( cod_cliente,		 --  1
           cod_compania,	 --  2
           cod_sucursal,	 --  3
           cod_origen,		 --  4
           cod_grupo,		 --  5
           cod_clasehosp,	 --  6
           cod_espmedica,	 --  7
           cod_ocupacion,	 --  8
           cod_trabajo,		 --  9
           cod_actividad,	 -- 10
           code_pais,		 -- 11
           code_provincia,	 -- 12
           code_ciudad,		 -- 13
           code_distrito,	 -- 14
           code_correg,		 -- 15
           nombre,			 -- 16
           nombre_razon,	 -- 17
           tipo_persona,	 -- 18
           actual_potencial, -- 19
           cedula,			 -- 20
           date_added,		 -- 21
           user_added,		 -- 22
           de_la_red,		 -- 23
           mala_referencia,  -- 24
           sexo,   			 -- 25
           ced_correcta,   	 -- 26
           es_taller,   	 -- 27
           cliente_web,   	 -- 28
           reset_password,	 -- 29
		   aseg_primer_nom,
		   aseg_segundo_nom,
		   aseg_primer_ape,
		   aseg_segundo_ape,
		   aseg_casada_ape,
		   digito_ver,
		   fecha_aniversario,
		   pais_residencia,
		   nacionalidad,
		   direccion_1,
		   telefono1,
		   e_mail)  -- 30
  VALUES ( _cod_cliente,   	 --  1
           '001',   		 --  2
           '001',   		 --  3
           '001',   		 --  4
           '00001',   		 --  5
           '001',   		 --  6
           '001',   		 --  7
           '038',   		 --  8
           '029',   		 --  9
           '001',   		 -- 10
           '001',   		 -- 11
           '01',   			 -- 12
           '01',   			 -- 13
           '01',   			 -- 14
           '01',   			 -- 15
           av_nombre,   	 -- 16
           av_nombre,   	 -- 17
           a_tipo_persona,	 -- 18
           'A',   			 -- 19
           as_ruc,   		 -- 20
		   _fecha,   		 -- 21
           as_user,			 -- 22
		   0,				 -- 23
           0,   			 -- 24
           a_sexo,  		 -- 25
           1,   			 -- 26
           0,   			 -- 27
           0,				 -- 28
		   0,				 -- 29
		   a_primer_nom,	 -- 30
		   a_segundo_nom,    -- 31
		   a_primer_ape,	 -- 32
		   a_segundo_ape,    -- 33
		   a_apellido_cas,   -- 34
		   a_digito_ver, 	 -- 35
		   a_fecha_nac,		 -- 36
		   a_pais_residencia,-- 37
		   a_nacionalidad, -- 38
		   a_direccion,		 -- 39	
		   a_telefono,		 -- 40
		   a_email)  ;	 	 -- 41
	else
		update cliclien
		   set 	aseg_primer_nom		= a_primer_nom,
				aseg_segundo_nom	= a_segundo_nom,
				aseg_primer_ape		= a_primer_ape,
				aseg_segundo_ape	= a_segundo_ape,
				aseg_casada_ape		= a_apellido_cas,
				digito_ver			= a_digito_ver,
				fecha_aniversario	= a_fecha_nac,
				pais_residencia		= a_pais_residencia,
				nacionalidad		= a_nacionalidad,
				direccion_1			= a_direccion,
				tipo_persona		= a_tipo_persona,
				sexo				= a_sexo,
				cedula				= as_ruc,
				nombre				= av_nombre,
				nombre_razon		= av_nombre,
				user_changed		= as_user,
				telefono1           = a_telefono,
				e_mail				= a_email
	     WHERE cliclien.cod_cliente =  a_cod_cliente ;
		let _cod_cliente = a_cod_cliente;
	end if

END
RETURN _cod_cliente;
end procedure;