-- Consulta de Unidades para los Saldos
-- Creado    : 12/10/2000 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cob30;

CREATE PROCEDURE "informix".sp_cob30(a_no_poliza CHAR(10))
RETURNING CHAR(5),	     -- no_unidad
		  CHAR(100),     -- desc_unidad
		  DEC(16,2),     -- suma_asegurada
		  CHAR(50),      -- nombre_asegurado
		  CHAR(50), 	 -- nombre_marca
		  CHAR(50),	     -- nombre_modelo
		  CHAR(30),      -- no_motor
		  CHAR(5),		 -- tipo(nuevo - usado)
		  char(10);      -- placa
		  		  		         

DEFINE _no_unidad         CHAR(5);
DEFINE _desc_unidad       VARCHAR(50);
DEFINE _suma_asegurada    DEC(16,2);
DEFINE _nombre_asegurado  CHAR(50);
DEFINE _nombre_marca	  VARCHAR(50);
DEFINE _nombre_modelo     VARCHAR(50);
DEFINE _cod_marca         CHAR(5);
DEFINE _cod_modelo        CHAR(5);
DEFINE _no_motor          CHAR(30);
DEFINE _cod_cliente    	  CHAR(10);
define _fecha             date;
define _ano_act,_anos     integer;
define _tipo_auto         char(5);
define _ano_auto          integer;
DEFINE _cod_asegurado  	  CHAR(10);
define _placa             char(10);


{CREATE TEMP TABLE tmp_uni_saldos
               (no_unidad        CHAR(5),
				desc_unidad      CHAR(100),
				suma_asegurada   DEC(16,2),
				nombre_asegurado CHAR(50),
				nombre_marca     CHAR(50),
				nombre_modelo    CHAR(50),
				no_motor         CHAR(30),
				tipo             CHAR(5),
				placa            char(10)
				) WITH NO LOG;   }

SET ISOLATION TO DIRTY READ;

let _fecha = current;
let _ano_act = year(_fecha);
let _tipo_auto = "";

FOREACH
	SELECT no_unidad,
	       desc_unidad,
		   suma_asegurada,
           cod_asegurado		   
      INTO _no_unidad,
	       _desc_unidad,
		   _suma_asegurada,
		   _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = a_no_poliza 

	SELECT no_unidad,
	       no_motor
	  INTO _no_unidad,
	       _no_motor
	  FROM emiauto
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;
	
	SELECT no_poliza,
	       cod_contratante
	  INTO a_no_poliza,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;
	
    SELECT no_motor,
	       cod_marca,
	       cod_modelo,
	       ano_auto,
		   placa 
	  INTO _no_motor,
	       _cod_marca,
		   _cod_modelo,
		   _ano_auto,
		   _placa
      FROM emivehic
	 WHERE no_motor = _no_motor;

    SELECT nombre
	  INTO _nombre_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

	SELECT nombre
	  INTO _nombre_modelo
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

	SELECT nombre
      INTO _nombre_asegurado
      FROM cliclien
	 WHERE cod_cliente = _cod_asegurado; --_cod_cliente;

 	 if _no_motor is null or _no_motor = "" then
		let _tipo_auto = '';
	 else
		 let _anos = _ano_act - _ano_auto;
	     if _anos <= 0 then
			let _tipo_auto = 'NUEVO';
		 else
			let _tipo_auto = 'USADO';
		 end if
	 end if

{   		INSERT INTO tmp_uni_saldos(
		    no_unidad,
			desc_unidad,
			suma_asegurada,
			nombre_asegurado,
			nombre_marca, 
			nombre_modelo,     
			no_motor,
			tipo_auto,
			placa)  
			   
		VALUES(
		    _no_unidad,
		    _desc_unidad,
			_suma_asegurada,
			_nombre_asegurado,
			_nombre_marca,
			_nombre_modelo,
			_no_motor,
			_tipo_auto,
			_placa);}

		  RETURN 
		 _no_unidad,
		 _desc_unidad,
		 _suma_asegurada,
		 _nombre_asegurado,
		 _nombre_marca,
		 _nombre_modelo,
		 _no_motor,
		 _tipo_auto,
		 _placa
    	 WITH RESUME;
	  
END FOREACH

--DROP TABLE tmp_uni_saldos;
END PROCEDURE;
