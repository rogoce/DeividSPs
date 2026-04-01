-- Informaci¢n: para SuperIntendecnia, para ser suminitrada a la ATTT, para que nos den los numeros de placa
-- Creado     : 02/10/2015 - Autor: Amado Perez


DROP PROCEDURE sp_super22;
create procedure sp_super22()
returning VARCHAR(25), -- Cia
		  VARCHAR(30), -- Vin
		  VARCHAR(30), -- Motor		  
		  VARCHAR(25); -- Marca

DEFINE v_poliza			 VARCHAR(25);
DEFINE v_marca			 VARCHAR(25);
DEFINE v_placa			 VARCHAR(10);
DEFINE _fecha_hoy		DATE;
DEFINE _no_poliza		CHAR(10);


DEFINE v_no_motor       VARCHAR(20);
DEFINE _cod_ramo        CHAR(3);
define _vin             char(30);



SET ISOLATION TO DIRTY READ;

let v_placa = null;
let v_no_motor = null;
let _vin = null;

FOREACH
  SELECT a.no_documento,
		 a.no_poliza,
		 a.cod_ramo,
         c.nombre,
  		 e.placa,
		 e.no_motor,
		 e.no_chasis
	INTO v_poliza,
		 _no_poliza,
		 _cod_ramo,
		 v_marca,
		 v_placa,
		 v_no_motor,
		 _vin
    FROM emipomae a, emimarca c, emimodel d, emipouni g, emiauto f, emivehic e
   WHERE a.no_poliza = g.no_poliza
     AND g.no_poliza = f.no_poliza
     AND g.no_unidad = f.no_unidad
     AND f.no_motor = e.no_motor
     AND e.cod_marca = c.cod_marca
     AND e.cod_marca = d.cod_marca
     AND e.cod_modelo = d.cod_modelo
     AND (a.cod_ramo in ('002','020','023') 
	 AND a.cod_tipoprod in ('001','005')
     AND g.vigencia_inic <= date(current)
     AND g.vigencia_final >= date(current)
     AND a.actualizado = 1
     AND a.estatus_poliza = 1)

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF

    {IF v_placa IS NULL or v_placa = "" THEN
    else
		continue foreach;
	END IF}

    IF v_no_motor IS NULL and _vin IS NULL THEN
		CONTINUE FOREACH;
		LET v_no_motor = "";
	END IF
	IF trim(v_no_motor) = "" and trim(_vin) = "" THEN
		CONTINUE FOREACH;
	end if
	LET v_marca = UPPER(v_marca);
	LET v_marca = REPLACE(v_marca,"Á","A");
	LET v_marca = REPLACE(v_marca,"É","E");
	LET v_marca = REPLACE(v_marca,"Í","I");
	LET v_marca = REPLACE(v_marca,"Ó","O");
	LET v_marca = REPLACE(v_marca,"Ú","U");
	LET v_marca = REPLACE(v_marca,","," ");
	LET v_marca = REPLACE(v_marca,";"," ");
	LET v_marca = REPLACE(v_marca,"|"," ");
	LET v_marca = REPLACE(v_marca,"'"," ");
	LET v_marca = REPLACE(v_marca,"Ñ","N");
	LET v_marca = REPLACE(v_marca,"!'"," ");
	LET v_marca = REPLACE(v_marca,"$"," ");
	LET v_marca = REPLACE(v_marca,"%"," ");
	LET v_marca = REPLACE(v_marca,"&"," ");
	LET v_marca = REPLACE(v_marca,"^"," ");

   RETURN   'ASEGURADORA ANCON, S.A.',_vin,v_no_motor,v_marca WITH RESUME;
END FOREACH 
end procedure;