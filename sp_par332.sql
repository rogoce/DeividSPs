-- INSERTA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN SUMINISTROS

-- Creado    : 19/02/2013 - Autor: Amado Perez
-- Igual al sp_soc002

--drop procedure sp_par332;

create procedure "informix".sp_par332(as_ruc varchar(30), av_nombre varchar(100), as_user char(8)) RETURNING CHAR(10);

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

   --let	_cod_cliente = '0';

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
		   aseg_primer_nom)  -- 30
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
           'J',   			 -- 18
           'A',   			 -- 19
           as_ruc,   		 -- 20
		   _fecha,   		 -- 21
           as_user,			 -- 22
		   0,				 -- 23
           0,   			 -- 24
           'M',   			 -- 25
           1,   			 -- 26
           0,   			 -- 27
           0,				 -- 28
		   0,				 -- 29
		   av_nombre)  ;	 -- 30
	else
		SELECT cod_cliente
		  INTO _cod_cliente
	      FROM cliclien
	     WHERE cliclien.cedula =  as_ruc ;
	end if

END
RETURN _cod_cliente;
end procedure;