-- Procedimiento que Genera el Cheque de bonificacion de cobranza para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 19/01/2006 - Autor: Amado Perez 
--             cuando se genere la comision, en el detalle debe aparecer 
--             desde la ultima fecha de comision si esta es menor que la
--             fecha desde se este generando la comision 

-- Modificado: 17/03/2006 - Autor: Demetrio Hurtado Almanza
--             Se separa la creacion de los registros contables y se incluyo en una rutina aparte que es la
--             sp_par205, que es la crea los registros contables de cheques de comisiones
-- 					  
-- Modificado: 25/02/2008 - Autor: Amado Perez
--             Se modifica la 
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che82_prueba;

CREATE PROCEDURE sp_che82_prueba(a_cod_agente CHAR(5),a_periodo CHAR(7))
 RETURNING INTEGER,dec(16,2); 

DEFINE _comision 		DEC(16,2);
DEFINE _comision2 		DEC(16,2);
DEFINE _monto_banco		DEC(16,2);
DEFINE _no_requis, _no_requis_c		CHAR(10);
DEFINE _nombre      	CHAR(50);
DEFINE _periodo     	CHAR(7);
DEFINE _cod_ramo    	CHAR(3);
DEFINE _cod_subramo 	CHAR(3);
DEFINE _saldo       	DEC(16,2);
DEFINE _descripcion 	CHAR(60);
DEFINE _cuenta      	CHAR(25);
DEFINE _tipo_agente 	CHAR(1);
DEFINE _tipo_pago   	SMALLINT;
DEFINE _tipo_requis 	CHAR(1);
DEFINE _quincena    	CHAR(3);
DEFINE _fecha_letra 	CHAR(10);
define _cod_origen		char(3);
define _renglon			smallint;
DEFINE _ano         	CHAR(4);  
DEFINE _banco       	CHAR(3);
DEFINE _banco_ach   	CHAR(3);
DEFINE _chequera    	CHAR(3);
define _origen_banc		char(3);
define _autorizado  	smallint;
define _autorizado_por	char(8);
define _origen_cheque   CHAR(1);
DEFINE _alias     		CHAR(50);
define _nombre_mes      char(10);
define _error			integer;
define _error_desc		char(50);
define _cta_chequera    smallint;
define _enlace_cta      char(20);
define _comision_enero  DEC(16,2);
define _desde           char(7);
define _hasta           char(7);
define _es_mensual      smallint;

define _fecha_ult_comis_orig date;
define _fecha_ult_comis      date;

set isolation to dirty read;

-- SET DEBUG FILE TO "sp_che82.trc"; 
-- TRACE ON;                                                                

--BEGIN WORK;

let _origen_cheque  = '8';
let _error          = 0;
let _comision_enero = 0;
let _es_mensual     = 1;

select es_mensual,
       desde,
       hasta
  into _es_mensual,
       _desde,
	   _hasta
  from chqboagt
 where cod_agente = a_cod_agente;


	if _hasta = a_periodo then	--Verifico si ya le debo pagar
		
		SELECT SUM(comision)
		  INTO _comision
		  FROM chqboni
		 WHERE cod_agente = a_cod_agente
		   AND periodo    >= _desde
		   AND periodo    <= a_periodo;

	else
		RETURN 0,0;
	end if


RETURN 0,_comision;

END PROCEDURE;