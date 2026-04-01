   DROP procedure sp_super05a;
   CREATE procedure sp_super05a()
   RETURNING char(10),char(100),char(30),char(1),char(50),char(50),char(1),date,char(50),char(10),char(10),char(10),char(10),char(10),char(200),
             char(3),char(50),char(2),char(50),char(2),char(50),char(2),char(50),char(5),char(50),char(20),char(1);

DEFINE _cod_cliente 	CHAR(10);
define _cedula      	char(30);
define _email           char(50);
define _n_cliente		char(100);
define _fecha_aniv      date;

define _tipo_persona,_sexo,_vip    char(1);
define _direccion1,_direccion2 char(50);
define v_filtros      			varchar(255);
define _celular,_tele1,_tele2,_tele3,_fax char(10);
define _dir_cob	char(200);
define _code_pais   char(3);
define _n_pais,_n_prov,_n_ciud,_n_dist,_n_correg      char(50);
define _code_provincia,_code_cuidad,_code_distrito,_code_correg	char(2);
define _apartado   char(20);
define _cnt smallint;

let _cnt = 0;
	
SET ISOLATION TO DIRTY READ;

{FOREACH
	select nombre
	  into _nombre_z
	  from zona_franca
	 order by nombre
	 
	let _nombre_z = trim(_nombre_z) || '%';
	
    foreach
	    SELECT cod_cliente,
	           nombre,
			   direccion_1
	      INTO _cod_cliente,
	           _nombre_c,
			   _direccion
	      FROM cliclien
	     WHERE trim(nombre) like _nombre_z
	  
	  return _nombre_z,_cod_cliente,_nombre_c,_direccion with resume;
		
	end foreach
end foreach}
{FOREACH
	select nombre
	  into _nombre_z
	  from zona_libre
	 order by nombre
	 
	let _nombre_z = trim(_nombre_z) || '%';
	
    foreach
	    SELECT cod_cliente,
	           nombre,
			   direccion_1
	      INTO _cod_cliente,
	           _nombre_c,
			   _direccion
	      FROM cliclien
	     WHERE trim(nombre) like _nombre_z
	  
	  return _nombre_z,_cod_cliente,_nombre_c,_direccion with resume;
		
	end foreach
end foreach}
drop table if exists temp_perfil;
CALL sp_pro95a(
'001',
'001',
'31/07/2017',
'*',
'*'
) RETURNING v_filtros;

foreach
	select distinct cod_contratante
	  into _cod_cliente
	  from temp_perfil
	 where seleccionado = 1

	select nombre,cedula,tipo_persona,direccion_1,direccion_2,sexo,fecha_aniversario,e_mail,celular,telefono1,telefono2,telefono3,fax,direccion_cob,
	       code_pais,code_provincia,code_ciudad,code_distrito,code_correg,apartado
	  into _n_cliente,_cedula,_tipo_persona,_direccion1,_direccion2,_sexo,_fecha_aniv,_email,_celular,_tele1,_tele2,_tele3,_fax,_dir_cob,
           _code_pais,_code_provincia,_code_cuidad,_code_distrito,_code_correg,_apartado
	  from cliclien
     where cod_cliente = _cod_cliente;

	select count(*)
      into _cnt
      from clivip
     where cod_cliente = _cod_cliente;

    if _cnt is null then
		let _cnt = 0;
    end if
	let _vip = 'N';
	if _cnt > 0 then
		let _vip = 'S';
	end if
	select nombre into _n_pais from genpais where code_pais = _code_pais;
	select nombre into _n_prov from genprov where code_pais = _code_pais
		   and code_provincia = _code_provincia;
	select nombre into _n_ciud from genciud where code_pais = _code_pais
		   and code_provincia = _code_provincia
		   and code_ciudad = _code_cuidad;
	select nombre into _n_dist from gendtto where code_pais = _code_pais
		   and code_provincia = _code_provincia
		   and code_ciudad    = _code_cuidad
		   and code_distrito  = _code_distrito;
	select nombre into _n_correg from gencorr where code_pais = _code_pais
		   and code_provincia = _code_provincia
		   and code_ciudad    = _code_cuidad
		   and code_distrito  = _code_distrito
		   and code_correg    = _code_correg;
		   
		Return _cod_cliente,_n_cliente,_cedula,_tipo_persona,_direccion1,_direccion2,_sexo,_fecha_aniv,_email,_celular,_tele1,_tele2,_tele3,_fax,_dir_cob,
		       _code_pais,_n_pais,_code_provincia,_n_prov,_code_cuidad,_n_ciud,_code_distrito,_n_dist,_code_correg,_n_correg,_apartado,_vip with resume;
		   
end foreach

END PROCEDURE;