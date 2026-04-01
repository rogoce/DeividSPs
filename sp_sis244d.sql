-- Cartera Activa Insurance Solutions
-- Creado por: Amado Pérez Mendoza
-- Fecha 	 : 07/08/2019

drop procedure sp_sis244d;

create procedure sp_sis244d() returning
			char(20) as no_documento,
			char(10) as placa,
			varchar(50) as marca,
			varchar(50) as modelo,
			smallint as agno,
			smallint as mes_placa,
			char(5) as no_unidad,
			dec(16,2) as prima_suscrita;

define v_filtros   	    char(255);
define _no_documento    char(20);
define _no_poliza       char(10);   
define _no_unidad       char(5);
define _prima_suscrita  dec(16,2);
define _no_motor        char(30);
define _cod_marca       char(5);
define _cod_modelo      char(5);
define _ano_auto        smallint;
define _placa           char(10);
define _marca           varchar(50);
define _modelo          varchar(50);

--SET DEBUG FILE TO "sp_che133.trc";
--tRACE ON;


SET ISOLATION TO DIRTY READ;

CALL sp_sis244b(
'001',
'001',
'30/08/2019',
'*',
'4;Ex') RETURNING v_filtros;

 
FOREACH
	SELECT no_poliza,   
           no_documento		 
	  INTO _no_poliza,   
           _no_documento
      FROM temp_perfil 
	 WHERE cod_ramo in ('002','020','023')
    ORDER BY no_documento	 
	
	FOREACH 
		SELECT no_unidad,
		       prima_suscrita
		  INTO _no_unidad,
		       _prima_suscrita
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		ORDER BY no_unidad

		SELECT no_motor
		  INTO _no_motor
		  FROM emiauto
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;
		
		SELECT cod_marca,
		       cod_modelo,
			   ano_auto,
			   placa
		  INTO _cod_marca,
		       _cod_modelo,
			   _ano_auto,
			   _placa
		  FROM emivehic
		 WHERE no_motor = _no_motor;
		 
		SELECT nombre 
		  INTO _marca
		  FROM emimarca
		 WHERE cod_marca = _cod_marca;
		 
		SELECT nombre 
		  INTO _modelo
		  FROM emimodel
		 WHERE cod_modelo = _cod_modelo;
		 
		RETURN _no_documento,
			   _placa,
			   _marca,
			   _modelo,
			   _ano_auto,
			   null,
			   _no_unidad,
			   _prima_suscrita
			   with resume;    
	END FOREACH
END FOREACH	
	
DROP TABLE temp_perfil;

end procedure
