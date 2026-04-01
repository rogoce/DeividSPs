-- Consulta de Clientes por Placa
-- Creado    : 31/05/2010 - Autor: Henry Giron
-- Modificado: 31/05/2010 - Autor: Henry Giron
-- SIS v.2.0 - d_ayuda_atc_placa_cte - DEIVID, S.A.

DROP PROCEDURE sp_atc12;
CREATE PROCEDURE sp_atc12(a_placa CHAR(10))
RETURNING CHAR(10),	
		  CHAR(100),
		  CHAR(30), 
		  CHAR(10), 
		  CHAR(50),
		  VARCHAR(255);

DEFINE v_cod_cliente  		CHAR(10);
DEFINE _cod_ase		  		CHAR(10);
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_prima_neta			DEC(16,2);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_impuesto			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE v_estatus_pol	    SMALLINT;
DEFINE v_actualizado	    SMALLINT;
DEFINE v_no_poliza	 	    CHAR(10);
DEFINE v_no_unidad	 	    CHAR(5);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_cte			CHAR(100);
define _cantidad			integer;
define _telefono1           char(10);
define _cedula              varchar(30);
define _direccion_1         char(50);
define _motor				char(30);
define _poliza              char(20);
define _climalare           varchar(50);
define _desc_mala_ref       varchar(250);
define _cod_mala_refe       char(3);

--SET DEBUG FILE TO "sp_atc12.trc"; 
--trace on;

CREATE TEMP TABLE temp_atc12
     (	  no_poliza        CHAR(10),
	      cod_contratante  CHAR(10),
      PRIMARY KEY (no_poliza,cod_contratante))
      WITH NO LOG;


SET ISOLATION TO DIRTY READ;

let _cedula      = null;
let _telefono1    = null;
let _direccion_1 = null;

--SACAR INFORMACION DEL MOTOR 

FOREACH -- SD # 7629 -- Amado Perez 26-08-2023 -- traía error cuando encontraba más de un vehiculo con la misma placa
	select no_motor
	  into _motor
	  from emivehic
	 where trim(placa) = trim(a_placa)

	--SACAR INFORMACION DE LA(S) POLIZA(S)

	foreach
	select no_poliza
	  into _poliza
	  from emiauto
	 where trim(no_motor) = trim(_motor)
	 order by no_poliza

		foreach
			select distinct(cod_contratante)
			  into v_cod_cliente
			  from emipomae
			 where no_poliza = _poliza
			   and actualizado  = 1

				INSERT INTO temp_atc12							
						 (no_poliza,
						 cod_contratante)
				   VALUES(_poliza,
						 v_cod_cliente );

		END FOREACH

	END FOREACH
END FOREACH
foreach
	select distinct(cod_contratante)
	  into v_cod_cliente
	  from temp_atc12
 
		 SELECT	nombre,
		        cedula,
				telefono1,
				direccion_1,
				desc_mala_ref,
				cod_mala_refe
		   INTO v_nombre_cte,
				_cedula,
				_telefono1,
				_direccion_1,
				_desc_mala_ref,
				_cod_mala_refe
		   FROM	cliclien
		  WHERE cod_cliente = v_cod_cliente;

		 select nombre
		   into _climalare
		   from climalare
		  where cod_mala_refe = _cod_mala_refe;

		if _climalare is null then	
			let _climalare = "";
		end if

		if _desc_mala_ref is null then	
			let _desc_mala_ref = "";
		end if

		RETURN  v_cod_cliente,
				v_nombre_cte,
				_cedula,
				_telefono1,
				_direccion_1,
				trim(trim(_climalare) || " " || trim(_desc_mala_ref))
				WITH RESUME;
END FOREACH

DROP TABLE temp_atc12;


END PROCEDURE;