-- INSERTA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN ORDEN DE PAGO

-- Creado    : 22/12/2009 - Autor: Amado Perez

drop procedure sp_soc003;

create procedure "informix".sp_soc003(as_ruc varchar(30)) RETURNING CHAR(10);

define 	_error			smallint;
define	_cod_cliente	char(10);
define	_fecha			date;
define	_existe			smallint;
define  _correo			char(50);
define	_direccion		char(100);
define	_telefono		char(10);
define	_tipo_cuenta	char(1);
define  _cod_cuenta		char(17);
define	_cod_banco		char(3);
define	_tipo_pago		smallint;
define	_cod_ruta		char(2);
define  _cnt            smallint;

--SET DEBUG FILE TO "sp_soc003.trc";
--TRACE ON ;


BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

  SELECT count(*)
	into _existe
    FROM cliclien
   WHERE cliclien.cedula =  as_ruc ;

  SELECT count(*)
	into _cnt
    FROM cheprove
   WHERE cheprove.cedula =  as_ruc ;

  if _cnt = 0 then
	return -1;
  end if

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
		   nombre_original,
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
		   aseg_primer_nom,
		   ced_provincia,
		   ced_inicial,
		   ced_tomo,
		   ced_folio,
		   ced_asiento,
		   e_mail,
		   direccion_1,
		   telefono1,
		   tipo_cuenta,
		   cod_cuenta,
		   cod_banco,
		   tipo_pago,
		   cod_ruta,
		   pasaporte
		   )  
    SELECT _cod_cliente,   
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
           nombre,   
           nombre,   
           nombre,   
           tipo_persona,   
           'A',   
           cedula,   
		   date_added,   
           user_added,
		   0,
           0,   
           sexo,   
           1,   
           0,   
           0,
		   0,
		   nombre,
		   ced_provincia,
		   ced_inicial,
		   ced_tomo,
		   ced_folio,
		   ced_asiento,
		   correo,
		   direccion,
		   telefono,
		   tipo_cuenta,
		   cod_cuenta,
		   cod_banco,
		   tipo_pago,
		   cod_ruta,
		   pasaporte
	 from  cheprove 
	where  cedula = trim(as_ruc)  ;
	else
		SELECT correo,
			   direccion,
			   telefono,
			   tipo_cuenta,
			   cod_cuenta,
			   cod_banco,
			   tipo_pago,
			   cod_ruta,
			   cod_cliente
		  INTO _correo,
			   _direccion,
			   _telefono,
			   _tipo_cuenta,
			   _cod_cuenta,
			   _cod_banco,
			   _tipo_pago,
			   _cod_ruta,
			   _cod_cliente
		  FROM cheprove
		 WHERE cedula = trim(as_ruc);

	      UPDATE cliclien
		     SET e_mail      = _correo,    
				 direccion_1 = _direccion,
				 telefono1	 = _telefono,
				 tipo_cuenta = _tipo_cuenta,
				 cod_cuenta	 = _cod_cuenta,
				 cod_banco	 = _cod_banco,
				 tipo_pago	 = _tipo_pago,
				 cod_ruta	 = _cod_ruta
		  WHERE  cedula      = trim(as_ruc);

	end if

END
RETURN _cod_cliente;
end procedure;