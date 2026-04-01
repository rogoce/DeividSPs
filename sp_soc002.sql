-- INSERTA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN SUMINISTROS

-- Creado    : 26/11/2009 - Autor: Roberto Silvera

drop procedure sp_soc002;

create procedure "informix".sp_soc002(as_ruc varchar(30), av_nombre varchar(100), as_user char(8)) RETURNING CHAR(10);

define 	_error			smallint;
define	_cod_cliente	char(10);
define	_fecha			date;
define	_existe			smallint;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

  SELECT count(*)
	into _existe
    FROM cliclien
   WHERE cliclien.cedula =  as_ruc ;

   let	_cod_cliente = '0';

   if _existe = 0 then

	let	_cod_cliente = sp_sis13("001", 'PAR', '02', 'par_cliente');
	let	_fecha = sp_sis26();

	  INSERT INTO cliclien
         ( cod_cliente,
           cod_compania,
           cod_sucursal,
           cod_origen,
           cod_grupo,
           cod_clasehosp,
           cod_espmedica,
           cod_ocupacion,
           cod_trabajo,
           cod_actividad,
           code_pais,
           code_provincia,
           code_ciudad,
           code_distrito,
           code_correg,
           nombre,
           nombre_razon,
           tipo_persona,
           actual_potencial,
           cedula,
           date_added,
           user_added,
           de_la_red,
           mala_referencia,   
           sexo,   
           ced_correcta,   
           es_taller,   
           cliente_web,   
           reset_password,
		   aseg_primer_nom)  
  VALUES ( _cod_cliente,   
           '001',   
           '001',   
           '001',   
           '00001',   
           '001',   
           '001',   
           '038',   
           '029',   
           '001',   
           '001',   
           '01',   
           '01',   
           '01',   
           '01',   
           av_nombre,   
           av_nombre,   
           'J',   
           'A',   
           as_ruc,   
		   _fecha,   
           as_user,
		   0,
           0,   
           'M',   
           1,   
           0,   
           0,
		   0,
		   av_nombre)  ;
	end if

END
RETURN _cod_cliente;
end procedure;