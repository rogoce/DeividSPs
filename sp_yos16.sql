-- INSERTA REGISTROS EN CLICLIEN DE YOSEGURO AL MOMENTO DE CREAR UN TERCERO

-- Creado    : 19/06/2019 - Autor: Federico Coronado
-- Igual al sp_par332

drop procedure sp_yos16;

create procedure "informix".sp_yos16(a_cod_conductor 		varchar(10),
									 a_cod_tipolic   		char(3), 
									 a_tiene_audiencia 		smallint, 
									 a_fecha_audiencia		date,
									 a_cod_lugci			char(3),
									 a_parte_policivo		CHAR(10),
									 a_hora_audiencia		datetime hour to second,
									 a_no_resolucion		VARCHAR(20), 
									 a_no_denuncia			VARCHAR(20),
									 a_no_placa_policia		VARCHAR(30),
									 a_estatus_audiencia	SMALLINT,
									 a_no_reclamo varchar(10)) RETURNING smallint;

define 	_error			smallint;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION
--set debug file to "sp_yos16.trc"; 
--trace on;
update 	recrcmae 
   set 	cod_conductor		= a_cod_conductor,
		cod_tipolic			= a_cod_tipolic, 
		tiene_audiencia		= a_tiene_audiencia,
		fecha_audiencia		= a_fecha_audiencia,
		cod_lugci			= a_cod_lugci,
		parte_policivo      = a_parte_policivo,
		hora_audiencia		= a_hora_audiencia,
		no_resolucion       = a_no_resolucion,
		no_denuncia			= a_no_denuncia,
		no_placa_policia    = a_no_placa_policia,
		estatus_audiencia   = a_estatus_audiencia
 where no_reclamo = a_no_reclamo;
END
RETURN 0;
end procedure;