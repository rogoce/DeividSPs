-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec735_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE sp_rec749b;
CREATE PROCEDURE "informix".sp_rec749b(
a_compania	CHAR(3),
a_agencia	CHAR(3),
a_periodo1	CHAR(7),
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_contrato	CHAR(255) DEFAULT "*",
a_ramo		CHAR(255) DEFAULT "*",
a_serie		CHAR(255) DEFAULT "*",
a_cober		CHAR(255) DEFAULT "*",
a_subramo	CHAR(255) DEFAULT "*",
a_documento CHAR(20)  DEFAULT "*",
a_numrecla  CHAR(20)  DEFAULT "*")
RETURNING	smallint,char(25),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),char(30) ;

DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE _no_unidad         CHAR(5);
DEFINE _uso_auto		  CHAR(1);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE _transaccion       CHAR(10);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente,_no_tranrec       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;
DEFINE _porc_coas         dec;

DEFINE _perd_total        smallint;
DEFINE _monto_bruto,_monto_total,_monto_pagado       dec(16,2);
define _cod_cobertura     char(5);
define _cobertura         char(2);
define _cod_tipopago      char(3);
define _tipo_pago         char(1);
define _tipo_linea        char(1);
define v_filtros          char(255);
define _fila 		smallint;
define _a_caso_p,_cnt  	integer;
define _a_monto_p 	dec(16,2);
define _a_caso_c 	integer;
define _a_monto_c	dec(16,2);
define _t_caso_p 	integer;
define _t_monto_p	dec(16,2);
define _t_caso_c 	integer;
define _t_monto_c	dec(16,2);
define _nombre_fila char(25);
define _so_caso_p 	integer;
define _so_monto_p	dec(16,2);
define _so_caso_c 	integer;
define _so_monto_c	dec(16,2);
define _tipo_cobertura char(2);
define _casos_cerrados integer;
define _cnt_cobertura       SMALLINT;
define v_no_orden    char(5);
define v_desc_orden	   	varchar(50);
define v_deducible	   	varchar(50);
define _fecha_siniestro  date;
define _no_endoso    char(5);
define _opcion       smallint;
define _cod_tipoveh  char(3);
define _grupo        char(3);
DEFINE _grupo_s         CHAR(30);
DEFINE _cod_producto    CHAR(5);
DEFINE _no_motor        CHAR(30);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);
let _cod_tipopago = null;

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;


foreach
	select fila,
	       a_caso_p,
		   a_monto_p,
		   a_caso_c,
		   a_monto_c,
		   t_caso_p,
		   t_monto_p,
		   t_caso_c,
		   t_monto_c,
		   so_caso_p,
		   so_monto_p,
		   so_caso_c,
		   so_monto_c,
		   grupo
	  into _fila,
	       _a_caso_p,
		   _a_monto_p,
		   _a_caso_c,
		   _a_monto_c,
		   _t_caso_p,
		   _t_monto_p,
		   _t_caso_c,
		   _t_monto_c,
		   _so_caso_p,
		   _so_monto_p,
		   _so_caso_c,
		   _so_monto_c,
		   _grupo
	  from sinsuperxtipo
	 order by grupo, fila
	 
	if _fila = 1 then
		let _nombre_fila = 'SINIESTROS PAGADOS';
	elif _fila = 2 then
		let _nombre_fila = 'Colision o Vuelco';
	elif _fila = 3 then
		let _nombre_fila = 'Robo';
	elif _fila = 4 then
		let _nombre_fila = 'Incendio';
	elif _fila = 5 then
		let _nombre_fila = 'Inundacion';
	elif _fila = 6 then
		let _nombre_fila = 'Comprensivo';
	elif _fila = 7 then
		let _nombre_fila = 'GASTOS MEDICOS';
	elif _fila = 8 then
		let _nombre_fila = 'PERDIDA TOTAL';
	elif _fila = 9 then
		let _nombre_fila = 'Colision o Vuelco';
	elif _fila = 10 then
		let _nombre_fila = 'Robo';
	elif _fila = 11 then
		let _nombre_fila = 'Inundacion';
	elif _fila = 12 then
		let _nombre_fila = 'Incendio';
	elif _fila = 13 then
		let _nombre_fila = 'RESPONSABILDAD CIVIL';
	elif _fila = 14 then
		let _nombre_fila = 'Lesiones Corporales';
	elif _fila = 15 then
		let _nombre_fila = 'Muerte';
	elif _fila = 16 then
		let _nombre_fila = 'Daños a la propiedad';
	elif _fila = 17 then
		let _nombre_fila = 'OTROS GASTOS';
	end if	
	
	IF _grupo = '001' THEN
		LET _grupo_s = 'TRANSPORTE SELECTIVO (TAXI)';
	ELIF _grupo = '002' THEN
		LET _grupo_s = 'BUSES, MICROBUS Y/O OMNIBUS';
	ELIF _grupo = '003' THEN
		LET _grupo_s = 'TAXIS DE TURISMO';
	ELIF _grupo = '004' THEN
		LET _grupo_s = 'TRANSPORTE DE CARGA';
    ELSE
 		LET _grupo_s = 'OTROS';
   END IF	
	
	return _fila,_nombre_fila,_a_caso_p,round(_a_monto_p,2),_a_caso_c,round(_a_monto_c,2),_t_caso_p,round(_t_monto_p,2),_t_caso_c,round(_t_monto_c,2),_so_caso_p,round(_so_monto_p,2),_so_caso_c,round(_so_monto_c,2), _grupo_s with resume;
end foreach	

END PROCEDURE;