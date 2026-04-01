-- Procedimiento para reporte de siniestralidad por poliza
-- 
-- Creado: 28/08/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_atc28;
CREATE PROCEDURE sp_atc28(a_cia CHAR(3),a_no_documento CHAR(20), a_no_unidad CHAR(10), a_usuario CHAR(8))
    RETURNING  VARCHAR(50),   --compañia   
               DATE,          --Fecha proceso	
               CHAR(20),      --no_documento                                                                       		       
			   CHAR(10),      --Unidad                                                                           		    
			   VARCHAR(50),   --Nombre ramo                                                                      		   
			   VARCHAR(50),   --Nombre sub                                                                       		                                                                               		    
			   VARCHAR(100),  --Nombre cliente                                                                            
               VARCHAR(50),   --Nombre corredor                                                                  		   
			   VARCHAR(50),   --Nombre marca                                                                     		     
			   VARCHAR(50),   --Nombre modelo                                                                    		     
			   SMALLINT,      --Ano                                                                              		       
			   CHAR(30),      --Chasis                                                                           		      
			   CHAR(10),      --Placa   
			   SMALLINT,	
			   SMALLINT,
			   DEC(16,2),
			   DEC(16,2),
			   DEC(16,2),
			   DEC(16,2),
			   DEC(16,2),
			   DEC(16,2),
			   CHAR(8),       --usuario
               CHAR(10),
			   DEC(16,2),      --No Poliza 			   
			   DEC(16,2),
			   varchar(50),
			   varchar(50),
			   varchar(50);

DEFINE _no_poliza	      CHAR(10);
DEFINE _cod_ramo          CHAR(30);
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_contratante   CHAR(10);
DEFINE _no_motor          CHAR(30);
DEFINE _no_chasis         CHAR(30);
DEFINE _placa             CHAR(10);
DEFINE _cod_marca         CHAR(5);
DEFINE _cod_modelo        CHAR(5);
DEFINE _ano_auto          SMALLINT;
DEFINE _no_documento      CHAR(20);
DEFINE _no_sinis_ult	  SMALLINT;
DEFINE _no_sinis_his	  SMALLINT;
DEFINE _no_vigencias	  DEC(16,2);
DEFINE _no_sinis_pro	  DEC(16,2);
DEFINE _incurrido_bruto	  DEC(16,2);
DEFINE _prima_devengada	  DEC(16,2);
DEFINE _siniestralidad	  DEC(16,2);
DEFINE _porc_descuento	  DEC(16,2);
DEFINE _tipo              SMALLINT;
DEFINE _nombre_modelo     VARCHAR(50);
DEFINE _nombre_marca      VARCHAR(50);
DEFINE _compania          VARCHAR(50);
DEFINE _nombre_ramo       VARCHAR(50);
DEFINE _nombre_sub        VARCHAR(50);
DEFINE _nombre_cliente    VARCHAR(100);
DEFINE _cod_agente        CHAR(5);
DEFINE _nombre_corredor   VARCHAR(50);
DEFINE _fecha_proceso	  DATE;
DEFINE _sini_ult_a        DEC(16,2);
DEFINE _incurrido_bruto_u DEC(16,2);
DEFINE _prima_devengada_u DEC(16,2);

DEFINE _moro_saldo		  DEC(16,2);
DEFINE _moro_por_vencer	  DEC(16,2);
DEFINE _moro_exigible	  DEC(16,2);
DEFINE _moro_corriente	  DEC(16,2);
DEFINE _moro_30			  DEC(16,2);
DEFINE _moro_60			  DEC(16,2);
DEFINE _moro_90			  DEC(16,2);
DEFINE _fecha_moros		  DATE;
DEFINE _periodo_moros	  CHAR(7);
define _cod_grupo         char(5);
define _cod_producto,_cod_acreedor      char(10);
define _n_prodcuto,_n_acreedor,_n_grupo varchar(50);

let _fecha_proceso = today;
LET _compania = sp_sis01(a_cia);

let _fecha_moros   = today;
let _periodo_moros = sp_sis39(_fecha_moros);

CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
--set debug file to "sp_atc28.trc";
--trace on;

SELECT cod_ramo,
       cod_subramo,
       cod_contratante,
	   cod_grupo
  INTO _cod_ramo,
       _cod_subramo,
       _cod_contratante,
	   _cod_grupo
  FROM emipomae 
 WHERE no_poliza = _no_poliza
   AND actualizado = 1;

SELECT nombre
  INTO _nombre_cliente
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;
 
select nombre
  into _n_grupo
  from cligrupo
 where cod_grupo = _cod_grupo;  
 
foreach
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
	exit foreach;
end foreach 
	
SELECT nombre
  INTO _nombre_corredor
  FROM agtagent
 WHERE cod_agente = _cod_agente;

SELECT nombre
  INTO _nombre_ramo
  FROM prdramo
 WHERE cod_ramo = _cod_ramo;

SELECT nombre
  INTO _nombre_sub 
  FROM prdsubra
 WHERE cod_ramo    =  _cod_ramo
   AND cod_subramo = _cod_subramo;

SELECT no_motor
  INTO _no_motor
  FROM emiauto
 WHERE no_poliza = _no_poliza
   AND no_unidad = a_no_unidad;
   
foreach
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
       and no_unidad = a_no_unidad

		exit foreach;
end foreach

select nombre
  into _n_prodcuto
  from prdprod
 where cod_producto = _cod_producto;
 
let _cod_acreedor = "";
foreach
	select cod_acreedor
	  into _cod_acreedor
	  from emipoacr
	 where no_poliza = _no_poliza
	   and no_unidad = a_no_unidad
	exit foreach;
end foreach	
   
let _n_acreedor = "";
select nombre
  into _n_acreedor
  from emiacre
 where cod_acreedor = _cod_acreedor;
   
SELECT no_chasis, 
	   placa,
	   cod_marca, 
	   cod_modelo,
	   ano_auto
  INTO _no_chasis,
	   _placa,
	   _cod_marca,
	   _cod_modelo,
	   _ano_auto		   
 FROM emivehic
WHERE no_motor = _no_motor;

SELECT nombre
  INTO _nombre_modelo
  FROM emimodel
 WHERE cod_modelo = _cod_modelo;

SELECT nombre
  INTO _nombre_marca
  FROM emimarca
 WHERE cod_marca = _cod_marca;

call sp_pro550a(a_no_documento)returning _no_documento,	_no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro,
										 _incurrido_bruto, _prima_devengada, _siniestralidad, _porc_descuento,
										 _tipo,	_incurrido_bruto_u, _sini_ult_a, _prima_devengada_u;
										
CALL sp_cob33('001','001',a_no_documento,_periodo_moros,_fecha_moros)
RETURNING _moro_por_vencer,	_moro_exigible,	_moro_corriente, _moro_30, _moro_60, _moro_90, _moro_saldo;

RETURN  _compania,
		_fecha_proceso,
		a_no_documento,
		a_no_unidad,
		_nombre_ramo,
		_nombre_sub,
		_nombre_cliente,
		_nombre_corredor,
		_nombre_marca,
		_nombre_modelo,
		_ano_auto,
		_no_chasis,
		_placa,
		_no_sinis_ult,
		_no_sinis_his,
		_no_vigencias,
		_no_sinis_pro,
		_incurrido_bruto,
		_prima_devengada,
		_siniestralidad,
		_porc_descuento,
		a_usuario,
		_no_poliza,
		_sini_ult_a,
		_moro_saldo,
		_n_grupo,
		_n_prodcuto,
		_n_acreedor;

END PROCEDURE

