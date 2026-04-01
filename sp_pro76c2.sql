-- Procedimiento que genera las cartas de Salud para una póliza
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado o dependiente cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado    :12/08/2015 - Autor: Federico Coronado

DROP PROCEDURE "informix".sp_pro76c2;

CREATE PROCEDURE "informix".sp_pro76c2(
a_compania      CHAR(50),
a_sucursal      CHAR(50),
a_mes           varchar(20),
a_ano           smallint,
a_fecha         date,
a_no_documento  varchar(20)
)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(50),      -- Direccion_1
		   CHAR(50),      -- Direccion_2
		   DATE,   	      -- Fecha aniversario
		   CHAR(50),      -- Nombre del Agente
		   DECIMAL(16,2), -- Nueva prima
		   DATE,          -- fecha
		   decimal(16,2), -- edad
		   CHAR(50),      -- Nombre de la Compania
		   char(10),			  		         
		   char(10),
		   char(10),		   
		   varchar(50),
		   decimal(16,2),
		   varchar(20),
		   varchar(30);

DEFINE _no_documento      		CHAR(20);
DEFINE _nombre_cliente    		CHAR(50);
DEFINE _direccion1		  		CHAR(50);
DEFINE _direccion2        		CHAR(50);
DEFINE _fecha_ani				date;
DEFINE _nombre_corredor   		CHAR(50);
DEFINE _prima_neta              DECIMAL(16,2);
DEFINE _fecha_carta				date;
DEFINE v_compania_nombre		char(50);
define _telefono1		  		char(10);
define _telefono2		  		char(10);
define _telefono3		  		char(10);
define _nombre_dependiente 		varchar(50);
define ld_recargo               decimal(16,2);
DEFINE _prima_bruta             DECIMAL(16,2);
DEFINE _periodo					char(7);
define _mes						char(2);
define v_firma_cartas		    varchar(20);
define v_nombre_completo 		varchar(30);

  			  		    
SET ISOLATION TO DIRTY READ;
--let _mes = a_mes[1,2];
--let _periodo = a_ano || "-" ||_mes;

select max(periodo)
  into _periodo
  from enviocartadet
 where fecha = a_fecha
   and no_documento = a_no_documento;
   
SELECT valor_parametro 
  INTO v_firma_cartas
  FROM inspaag
 WHERE codigo_parametro = "firma_carta_salud"; 
 
SELECT descripcion
  INTO v_nombre_completo
  FROM insuser
 WHERE usuario = v_firma_cartas;
   
foreach	 
	select no_documento,
		   nombre_cliente,
		   direccion1,
		   direccion2,
		   fecha_ani,
		   nombre_corredor,
		   sum(prima),
		   fecha,
		   compania,
		   telefono1,
		   telefono2,
		   telefono3,
		   nombre_dependiente,
		   sum(recargo),
		   sum(prima_total)
	  into  _no_documento,
			 _nombre_cliente,
			 _direccion1,
			 _direccion2,
			 _fecha_ani,
			 _nombre_corredor,
			 _prima_neta,
			 _fecha_carta,
			 v_compania_nombre,
			_telefono1,
			_telefono2,
			_telefono3,
			_nombre_dependiente,
			ld_recargo,
			_prima_bruta
	 from enviocartadet
	where fecha = a_fecha
	  and periodo = _periodo
	  and no_documento = a_no_documento
	group by 1,2,3,4,5,6,8,9,10,11,12,13
	
		RETURN 
		_no_documento,
		_nombre_cliente,
		_direccion1,
		_direccion2,
		_fecha_ani,
		trim(_nombre_corredor),
		_prima_bruta,
		_fecha_carta,
		ld_recargo,
		v_compania_nombre,
		_telefono1,
		_telefono2,
		_telefono3,
		_nombre_dependiente,
		_prima_bruta,
		v_firma_cartas,	
		v_nombre_completo
		WITH RESUME;
end foreach

END PROCEDURE;