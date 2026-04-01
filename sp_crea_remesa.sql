-- Procedimiento que Genera la Remesa para reversar remesa electronico con rechazos fuera de hora.

-- Creado    : 13/03/2025 - Autor: Armando Moreno M.
-- Modificado: 13/03/2025 - Autor: Armando Moreno M.

DROP PROCEDURE sp_crea_remesa;
CREATE PROCEDURE sp_crea_remesa(a_compania CHAR(3),a_sucursal CHAR(3),a_user CHAR(8),a_no_recibo CHAR(10))
RETURNING SMALLINT,CHAR(100),CHAR(10);

DEFINE _error_code      INTEGER;
DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza,_no_recibo10    	CHAR(10); 
DEFINE _doc_remesa	 	CHAR(30);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _dia		      	INTEGER;
DEFINE _cod_chequera    char(3);  
DEFINE _cod_banco       char(3);
DEFINE _recibi_de  		char(50);
DEFINE _fecha_recibo    date;
DEFINE _cod_auxiliar    char(5);
DEFINE _mensaje         CHAR(100);
DEFINE _monto_dif   	DEC(16,2);
DEFINE _monto_a		   	DEC(16,2);

DEFINE _monto2,_prima_neta         DEC(16,2);
DEFINE _nombre_cliente2	CHAR(50);
DEFINE _fecha_recibo2   DATE;
DEFINE _doc_remesa2 	CHAR(30);
DEFINE _descripcion2   	CHAR(100);
define _no_documento    char(20);
define _cta_aux         char(1);

--SET DEBUG FILE TO "sp_crea_remesa.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Aplicacion de prima', '';         
END EXCEPTION           

let _monto  = 0;
let _monto2 = 0;

LET _tipo_mov   = 'N'; 
LET _null       = NULL;
LET a_no_remesa = '1'; 
LET _monto_dif  = 0; 
LET _monto_a    = 0;
LET _descripcion = "";
LET _descripcion2 = "";

LET a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
END IF	

LET _fecha = TODAY;

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

select valor_parametro
  into _cod_banco
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'COB'
   and version          = '02'
   and codigo_parametro = 'caja_caja';

let _cod_banco    = trim(_cod_banco);
let _cod_chequera = "023";
let _recibi_de    = "REVERSO DE APLICACION A CLIENTES POR RECHAZO A DESTIEMPO";

let _monto_dif = 0;

-- Insertar el Maestro de Remesas

INSERT INTO cobremae(
no_remesa,
cod_compania,
cod_sucursal,
cod_banco,
cod_cobrador,
recibi_de,
tipo_remesa,
fecha,
comis_desc,
contar_recibos,
monto_chequeo,
actualizado,
periodo,
user_added,
date_added,
user_posteo,
date_posteo,
cod_chequera
)
VALUES(
a_no_remesa,
a_compania,
a_sucursal,
_cod_banco,
_null,
_recibi_de,
'C',
_fecha,
0,
2,
0.00,
0,
_periodo,
a_user,
_fecha,
a_user,
_fecha,
_cod_chequera
);

--LET _descripcion = TRIM(_nombre_cliente);
LET _renglon     = 0;

foreach 
	select monto,
		   prima_neta,
		   impuesto,
		   no_poliza,
		   doc_remesa,
		   renglon
	  into _monto,
		   _prima_neta,
		   _impuesto,
		   _no_poliza,
		   _no_documento,
		   _renglon
	  from cobredet	   
	 where no_remesa = '2073182'
	   and doc_remesa in('1921-00494-01','1921-00033-03','1923-00002-11','1923-00125-01','1924-00063-01','1924-00045-07','1921-00492-01','1917-00064-06',
	'1917-00154-01','1912-00005-01','1917-00110-01','1918-00135-01','1925-00007-01','1818-00178-01','1924-00231-01','1921-00035-07','1824-00010-11',
	'1921-00471-01','1923-00446-01','1924-00202-01','1908-00142-01','1915-00012-02','1923-00030-03','1921-00036-01','1922-00004-03','1923-00222-01','1922-00086-01',
	'0216-00466-12','1922-00062-01','0218-00754-07','0218-01174-11','0213-00499-09','0223-01543-01','0221-02728-09','0219-00356-02','1923-00449-01','0214-04033-01',
	'0218-04534-09','0221-01902-01','0220-00193-02','0220-01029-09','1922-00063-01','1920-00015-01','0217-03410-01','1922-00276-01','0219-00744-03','0224-02589-01','0223-05899-09',
	'0215-02579-01','0220-00481-01','0221-00263-09','0219-04358-09','1919-00011-12','0223-00258-09','0220-01840-09','0223-06332-09','1921-00182-01','0216-01741-01','1923-00057-01',
	'0221-00623-01','0218-01046-01','0220-00490-09','0223-01172-01','0216-00585-05','0222-00010-11','0218-01044-11','1919-00023-12','0218-01256-09','1923-00378-01','0222-03110-09',
	'0221-01096-01','1921-00004-11','1917-00001-01','0222-00169-02','0221-01949-01','0220-01597-01','0218-02657-09','1907-00134-01','1922-00127-01','0220-00247-02','0222-00746-09',
	'0218-01541-09','0220-01498-09','1921-00479-01','0218-04245-09','0216-02304-03','0219-00872-06','0221-02460-09','0219-05607-09','0218-04296-09','0219-05397-09','0218-00271-12',
	'0224-00425-09','0222-01743-09','0221-01610-01','0215-00342-09','0224-01329-05','0218-00221-12','0223-03871-09','0219-05062-09','0219-00208-10','0623-00030-01','0222-00904-09',
	'0224-00149-10','0223-06977-09','0222-03444-01','0218-01246-01','0219-00001-12','0217-01674-03','0218-00170-12','0217-00044-06','0213-00867-06','0217-00635-09','0222-00304-02',
	'0218-01071-03','0223-09456-09','0219-02824-09','0219-02596-09','0222-03945-09','0319-00031-01','0218-04899-09','0223-03695-01','0221-01559-03','1922-00264-01','0219-04751-09',
	'0220-00913-09','0224-01970-01','1920-00021-01','1918-00282-01','0223-01804-03','0218-03793-09','0221-00960-01','0225-00079-09','0221-03652-09','0218-01158-11','0221-01876-01',
	'0222-00381-02','0224-05533-09','0223-00263-11','0122-00006-10','0222-00311-09','0224-01502-03','0221-00768-03','1922-00182-01','0221-02748-09','0219-00135-09','0224-07525-09',
	'0218-00519-10','0224-06776-09','0216-01211-01','0223-10237-09','0222-03508-09','0222-00506-11','1924-00059-01','0222-02629-01','0220-00289-11','0218-00391-12','0221-00328-02',
	'0223-00111-01','0217-00057-07','0223-00040-03','0222-00146-07','0220-01013-01','0220-00139-07','0216-01110-01','1921-00317-01','0222-02946-09','1917-00210-01','0217-00011-20',
	'0224-05150-09','0224-00372-03','1921-00035-01','0223-00216-10','0223-05475-09','0223-00288-01','0223-06650-09','0220-00509-09','0224-00977-10','0217-00380-06','0218-03470-09',
	'0223-06396-09','1810-00142-04','0222-02832-01','0224-00598-10','0223-03093-01','0224-02856-01','0222-05420-09','0219-05524-09','0223-01849-09','0222-02549-09','1922-00425-01',
	'0223-00557-07','0222-00015-06','0224-08793-09','0224-08073-09','0220-00358-10','0223-00553-09','0223-01424-01','0222-03524-09','1925-00018-01','0222-03819-01','0223-09180-09',
	'0218-01104-03','0224-01208-10','0222-07072-09','0224-00222-10','1919-00002-01','0221-00457-01','0221-00476-11','0224-07092-09','1922-00032-07','0224-00182-09','0224-00067-11',
	'0225-00112-09','0223-06819-09','0223-02489-01','0222-01574-03','0223-00290-11','1922-00384-01','0224-00047-11','0224-00048-11','0223-00660-11','0221-00410-05','0222-05791-09',
	'0223-08089-09','0224-01489-10','0223-07700-09','0224-00399-07','0225-00510-09','0223-09310-09','0224-06737-09','0223-00644-10','0223-01318-09','0224-02172-09','0222-02718-01',
	'0224-06162-09','0224-04698-09','0224-06038-09','0224-00514-11','0923-00021-01','0923-00024-11','0223-02239-01','1921-00034-07','0210-00913-03','0219-00690-10','0222-03641-09',
	'0223-09736-09','0221-00264-01','0224-03992-09','0224-00285-10','1921-00242-01','0218-01209-11','0224-01649-01','0223-02184-01','0224-00274-11','0223-07101-09','0224-01943-01',
	'0224-06828-09','0223-01010-03','1923-00139-01','0222-00054-11','1918-00086-01','0222-02410-09','0224-00597-10','0223-00786-02','0223-01825-03','1923-00461-01','0215-01025-06',
	'0618-00123-01','0223-01380-10','1923-00214-01','1923-00384-01','0223-09037-09','0222-00051-11','0221-00488-11','0220-00275-11','0225-00013-05','0224-07197-09','0224-05722-09',
	'0223-10115-09','0224-00177-01','0224-01027-03','0224-00631-03','0225-00167-05','0223-00606-11','0224-04464-09','0223-02844-01','0918-00092-01','0218-02309-01','0224-00523-11',
	'1924-00197-01','0223-00568-11','1824-00004-03','1811-00622-01','1823-00151-01','1825-00005-01','1923-00409-01','1925-00016-01','1824-00185-01','1808-00255-01','1815-00132-01',
	'1822-00324-01','1823-00194-01','1810-00453-01','1811-00533-01','1804-00912-01','1810-00638-01','1805-00081-03','1820-00215-01','1817-00096-01','1809-00143-01','1824-00026-01',
	'1816-00013-01','1814-00290-01','1922-00060-07','0224-01346-03','1811-00004-03','2318-00076-01')

--	LET _renglon    = _renglon + 1;
	LET _monto      = _monto * -1;
	LET _prima_neta = _prima_neta * -1;
	LET _impuesto   = _impuesto * -1;

	-- Detalle de la Remesa
	INSERT INTO cobredet(
	no_remesa,
	renglon,
	cod_compania,
	cod_sucursal,
	no_recibo,
	doc_remesa,
	tipo_mov,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	comis_desc,
	desc_remesa,
	saldo,
	periodo,
	fecha,
	actualizado,
	no_poliza
	)
	VALUES(
	a_no_remesa,
	_renglon,
	a_compania,
	a_sucursal,
	a_no_recibo,
	_no_documento,
	_tipo_mov,
	_monto,
	_prima_neta,
	_impuesto,
	0,
	0,
	_descripcion,
	0,
	_periodo,
	_fecha,
	0,
	_no_poliza
	
	);
	
	{update cobcutas
	   set procesar = 1,
	       rechazada = 1
	 where no_documento = _no_documento;	   }
	

end foreach
RETURN 0, 'Creación Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 
END
END PROCEDURE;
