-- Procedimiento que retorna los elemtos de la carta de reclamos para las aseguradora

-- Creado    : 05/01/2015 - Autor: Jame Chevalier
 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_recl_carta;

create procedure sp_recl_carta(
a_cia              CHAR(3), 
a_suc              CHAR(3), 
a_no_recupero      CHAR(5), 
a_usuario          CHAR(8),
a_usuario_sistema  CHAR(8),
a_nombre_cia       CHAR(100),
a_su_reclamo       CHAR(10))

returning CHAR(5),                          --no_recupero
		  VARCHAR(100),                        --nombre_tercero
		  VARCHAR(100),                        --nombre_cliente
		  VARCHAR(250),                        --monto_letra
		  CHAR(18),                         --no_reclamo
		  VARCHAR(250),                        --fecha_siniestro
		  VARCHAR(10),                         --placa
		  DECIMAL(16,2),                    --monto_numero
		  CHAR(250),                        --fecha_del_dia
		  CHAR(50),
		  CHAR(100),
		  VARCHAR(20),
		  CHAR(10),
		  CHAR(50),
		  CHAR(50),
		  VARCHAR(100),
		  CHAR(10);

DEFINE v_no_recupero	 	CHAR(5);
DEFINE v_nombre_tercero	 	VARCHAR(100);
DEFINE v_nombre_cliente	 	VARCHAR(100);
DEFINE _monto    	     	DECIMAL(16,2);
DEFINE v_num_reclamo	 	CHAR(18);
DEFINE _fecha_siniestro	 	DATE;
DEFINE _no_poliza        	CHAR(10);
DEFINE _no_motor         	CHAR(30);
DEFINE _cod_coasegur        CHAR(3);
 
DEFINE v_fecha_siniestro 	CHAR(250);
DEFINE v_dia             	CHAR(2);
DEFINE v_ano             	CHAR(4);
DEFINE v_monto           	VARCHAR(250);
DEFINE v_placa           	CHAR(11);
DEFINE _placa           	CHAR(10);
DEFINE v_monto_num          DECIMAL (16,2); 
DEFINE _fecha_hoy           DATE;
DEFINE v_fecha_dia          CHAR(250);
DEFINE v_usuario_sistema    CHAR(50);
DEFINE v_nombre_cia         CHAR(100);
DEFINE v_su_reclamo         CHAR(10);
DEFINE v_tel_directo        CHAR(10);
DEFINE v_cargo              CHAR(50);
DEFINE v_cod_coasegur       CHAR(50);
DEFINE v_nombre_conductor   VARCHAR(100);
DEFINE v_reclamo_tercero    VARCHAR(20);
DEFINE v_placa_tercero      VARCHAR(10);
DEFINE _no_unidad           CHAR(5);

--SET DEBUG FILE TO "sp_rec259.trc";  
--TRACE ON;                                                                 


LET _fecha_hoy   = today;
IF MONTH(_fecha_hoy) = 1 THEN
      LET v_fecha_dia = 'enero';
   ELIF MONTH(_fecha_hoy) = 2 THEN
      LET v_fecha_dia = 'febrero';
   ELIF MONTH(_fecha_hoy) = 3 THEN
      LET v_fecha_dia = 'marzo';
   ELIF MONTH(_fecha_hoy) = 4 THEN
      LET v_fecha_dia = 'abril';
   ELIF MONTH(_fecha_hoy) = 5 THEN
      LET v_fecha_dia = 'mayo';
   ELIF MONTH(_fecha_hoy) = 6 THEN
      LET v_fecha_dia = 'junio';
   ELIF MONTH(_fecha_hoy) = 7 THEN
      LET v_fecha_dia = 'julio';
   ELIF MONTH(_fecha_hoy) = 8 THEN
      LET v_fecha_dia = 'agosto';
   ELIF MONTH(_fecha_hoy) = 9 THEN
      LET v_fecha_dia = 'septiembre';
   ELIF MONTH(_fecha_hoy) = 10 THEN
      LET v_fecha_dia = 'octubre';
   ELIF MONTH(_fecha_hoy) = 11 THEN
      LET v_fecha_dia = 'noviembre';
   ELIF MONTH(_fecha_hoy) = 12 THEN
      LET v_fecha_dia = 'diciembre';
END IF

   LET v_dia = DAY(_fecha_hoy);
   LET v_ano = YEAR(_fecha_hoy);
   LET v_fecha_dia = TRIM(v_dia)||' de '||TRIM(v_fecha_dia)||' de '||TRIM(v_ano);

SELECT  nombre_tercero,
        monto_arreglo,
        cod_coasegur,
        numrecla,
		conductor_tercero,
		reclamo_tercero,
		placa_tercero
   INTO v_nombre_tercero,
		_monto,
		_cod_coasegur,
		v_num_reclamo,
		v_nombre_conductor,
		v_reclamo_tercero,
		v_placa_tercero
   FROM recrecup
 WHERE cod_compania = a_cia  AND
       cod_sucursal = a_suc  AND
       no_recupero = a_no_recupero AND
       user_added = a_usuario;  
	   
IF 	v_nombre_tercero IS NULL THEN
	LET v_nombre_tercero = '';
END IF   
IF 	_cod_coasegur IS NULL THEN
	LET _cod_coasegur = '';
END IF   
IF 	v_num_reclamo IS NULL THEN
	LET v_num_reclamo = '';
END IF   
IF 	v_nombre_conductor IS NULL THEN
	LET v_nombre_conductor = '';
END IF   
IF 	v_reclamo_tercero IS NULL THEN
	LET v_reclamo_tercero = '';
END IF   
IF 	v_placa_tercero IS NULL THEN
	LET v_placa_tercero = '';
END IF   

LET v_cod_coasegur = '';

IF _cod_coasegur <> '' THEN 	   
	SELECT nombre  
	  INTO v_cod_coasegur
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur; 
END IF  
	   
SELECT no_poliza,
       no_unidad,
       fecha_siniestro,
	   no_motor
  INTO _no_poliza,
       _no_unidad,
       _fecha_siniestro,
	   _no_motor
  FROM recrcmae
WHERE numrecla = v_num_reclamo;

SELECT nombre
  INTO v_nombre_cliente
  FROM cliclien,
       emipomae
 WHERE no_poliza = _no_poliza
   AND emipomae.cod_contratante = cliclien.cod_cliente; 



IF MONTH(_fecha_siniestro) = 1 THEN
      LET v_fecha_siniestro = 'enero';
   ELIF MONTH(_fecha_siniestro) = 2 THEN
      LET v_fecha_siniestro = 'febrero';
   ELIF MONTH(_fecha_siniestro) = 3 THEN
      LET v_fecha_siniestro = 'marzo';
   ELIF MONTH(_fecha_siniestro) = 4 THEN
      LET v_fecha_siniestro = 'abril';
   ELIF MONTH(_fecha_siniestro) = 5 THEN
      LET v_fecha_siniestro = 'mayo';
   ELIF MONTH(_fecha_siniestro) = 6 THEN
      LET v_fecha_siniestro = 'junio';
   ELIF MONTH(_fecha_siniestro) = 7 THEN
      LET v_fecha_siniestro = 'julio';
   ELIF MONTH(_fecha_siniestro) = 8 THEN
      LET v_fecha_siniestro = 'agosto';
   ELIF MONTH(_fecha_siniestro) = 9 THEN
      LET v_fecha_siniestro = 'septiembre';
   ELIF MONTH(_fecha_siniestro) = 10 THEN
      LET v_fecha_siniestro = 'octubre';
   ELIF MONTH(_fecha_siniestro) = 11 THEN
      LET v_fecha_siniestro = 'noviembre';
   ELIF MONTH(_fecha_siniestro) = 12 THEN
      LET v_fecha_siniestro = 'diciembre';
END IF

   LET v_dia = DAY(_fecha_siniestro);
   LET v_ano = YEAR(_fecha_siniestro);
   LET v_fecha_siniestro = TRIM(v_dia)||' de '||TRIM(v_fecha_siniestro)||' de '||TRIM(v_ano);
   
 LET v_monto_num = _monto;
 LET v_nombre_cia      = a_nombre_cia;
 LET v_su_reclamo      = a_su_reclamo;
 CALL sp_sis11(_monto) RETURNING v_monto;
 
 SELECT descripcion,
        tel_directo,
        cargo
   INTO v_usuario_sistema,
        v_tel_directo,
		v_cargo
 FROM insuser 
 WHERE usuario = a_usuario_sistema;

 SELECT placa 
  INTO _placa
  FROM emivehic
 WHERE no_motor = _no_motor;
 
 LET v_no_recupero = a_no_recupero;
 LET v_placa = TRIM(_placa)||',';
 
	 
	RETURN 	v_no_recupero,              --0
			TRIM(v_nombre_cliente),           --2
			TRIM(v_nombre_tercero),           --1
			TRIM(v_monto),                    --3
			v_num_reclamo,              --4
			TRIM(v_fecha_siniestro),          --5
			v_placa_tercero,                    --6
			v_monto_num,                --7
			v_fecha_dia,                --8
			v_usuario_sistema,          --9 
			v_nombre_cia,               --10
			v_reclamo_tercero,               --11
			v_tel_directo,              --12
		    v_cargo,                     --13
			v_cod_coasegur,
			v_nombre_conductor,
			_placa
			WITH RESUME; 
end procedure;

