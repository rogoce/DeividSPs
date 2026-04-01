DROP procedure sp_pro4976;
   CREATE procedure "informix".sp_pro4976(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   
   RETURNING 	INTEGER	as	v_orden	,
				CHAR(100)	as	v_descripcion	,
				INTEGER	as	v_auto_co_p_cant	,
				DECIMAL(16,2)	as	v_auto_co_p_monto	,
				INTEGER	as	v_auto_co_c_cant	,
				DECIMAL(16,2)	as	v_auto_co_c_monto	,
				INTEGER	as	v_auto_rc_p_cant	,
				DECIMAL(16,2)	as	v_auto_rc_p_monto	,
				INTEGER	as	v_auto_rc_c_cant	,
				DECIMAL(16,2)	as	v_auto_rc_c_monto	,
				INTEGER	as	v_soda_co_p_cant	,
				DECIMAL(16,2)	as	v_soda_co_p_monto	,
				INTEGER	as	v_soda_co_c_cant	,
				DECIMAL(16,2)	as	v_soda_co_c_monto	,
				INTEGER	as	v_sub_p_tot_cant	,
				DECIMAL(16,2)	as	v_sub_p_tot_monto	,
				INTEGER	as	v_sub_c_tot_cant	,
				DECIMAL(16,2)	as	v_sub_c_tot_monto	,
				INTEGER	as	v_tot_cant	,
				DECIMAL(16,2)	as	v_tot_monto,
 				CHAR(30)		as  v_tipo;				
   
 --  RETURNING CHAR(20),CHAR(3),DECIMAL(16,2),DECIMAL(16,2);   
   
   ---,CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
-- execute procedure sp_pro4959('001','001','2016-06', '2016-06', '%')
--------------------------------------------
    DEFINE _no_poliza           CHAR(10);	
	define _cod_ramo_ori        CHAR(3);
	define _cod_ramo            CHAR(3);	
	define _no_documento        CHAR(20);
	define _no_unidad           CHAR(5);
	define _total_pri_sus		DECIMAL(16,2);		
	define _suma_asegurada		DECIMAL(16,2);	
	define _uso_auto            CHAR(1);	
	define _cobertura           CHAR(1);
	define _cnt_cobertura       SMALLINT;
	define _no_endoso           CHAR(5);
	DEFINE _filtros, v_filtros  CHAR(255);
	DEFINE _descr_cia	        CHAR(45);		
	define _suscrita_unidad     DECIMAL(16,2);	
	define _sa_poliza           DECIMAL(16,2);
	define _valor           DECIMAL(16,2);	
	define _emipouni_sa,_emipouni_ps DECIMAL(16,2);	
	define _prioridad           SMALLINT;
	define _cnt_unidad          SMALLINT;
	define _3ciclo              SMALLINT;
	define _primera_u,_orden  SMALLINT;	
	define _unidad_pri_sus		DECIMAL(16,2);		
	define _c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_c10,_c11,_c12	SMALLINT;
	define _p1,_P2,_p3,_p4,_p5,_p6,_p7,_p8,_p9,_p10,_p11,_p12   smallint;
	define _cod_subramo		    CHAR(3);
	
	define  _descripcion        CHAR(100);
	define  _auto_co_p_cant	INTEGER;
	define	_auto_co_p_monto	DECIMAL(16,2);
	define	_auto_co_c_cant	INTEGER;
	define	_auto_co_c_monto	DECIMAL(16,2);
	define	_auto_rc_p_cant	INTEGER;
	define	_auto_rc_p_monto	DECIMAL(16,2);
	define	_auto_rc_c_cant	INTEGER;
	define	_auto_rc_c_monto	DECIMAL(16,2);
	define	_soda_co_p_cant	INTEGER;
	define	_soda_co_p_monto	DECIMAL(16,2);
	define	_soda_co_c_cant	INTEGER;
	define	_soda_co_c_monto	DECIMAL(16,2);
	define	_sub_p_tot_cant	INTEGER;
	define	_sub_p_tot_monto	DECIMAL(16,2);
	define	_sub_c_tot_cant	INTEGER;
	define	_sub_c_tot_monto	DECIMAL(16,2);
	define _tot_cant	INTEGER;
	define _tot_monto  DECIMAL(16,2);
	DEFINE _mes2,_mes,_ano2   SMALLINT;
	DEFINE _fecha2     	      DATE;
	DEFINE _cnt_prima_nva, _cnt_prima_ren INTEGER;
	DEFINE _cod_tipoveh 	CHAR(3);
	DEFINE _grupo           CHAR(3);
	DEFINE _cod_producto    CHAR(5);
	DEFINE _no_motor        CHAR(30);
	DEFINE _cnt             SMALLINT;
	DEFINE _grupo_s         CHAR(30);
	DEFINE _nueva_renov     CHAR(1);
	DEFINE _tot_cant_sum    INTEGER;
	DEFINE _tot_cant_uni    INTEGER;
	

--SET DEBUG FILE TO "sp_pro4963.trc"; 
--trace on;

let _prioridad= 0;
let _primera_u= 0;
let _c1= 0;
let _c2= 0;
let _c3= 0;
let _c4= 0;
let _c5= 0;
let _c6= 0;
let _c7= 0;
let _c8= 0;
let _c9= 0;
let _c10= 0;
let _c11= 0;
let _c12 = 0;
let _unidad_pri_sus = 0;
let _emipouni_sa = 0;
let _emipouni_ps = 0;

LET _cod_ramo        = NULL;
LET _cod_ramo_ori   = NULL;
LET _descr_cia = NULL;

SET ISOLATION TO DIRTY READ;
LET _descr_cia = sp_sis01(a_cia);
LET _total_pri_sus = 0.00;
LET _suma_asegurada = 0.00;
let _sa_poliza = 0.00;

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

 
FOREACH WITH HOLD
   SELECT orden,auto_co_p_cant,auto_co_p_monto,auto_co_c_cant,auto_co_c_monto,auto_rc_p_cant,auto_rc_p_monto,auto_rc_c_cant,
          auto_rc_c_monto,soda_co_p_cant,soda_co_p_monto,soda_co_c_cant,soda_co_c_monto,sub_p_tot_cant,sub_p_tot_monto,sub_c_tot_cant,sub_c_tot_monto,tot_cant,tot_monto, grupo
     INTO _orden,_auto_co_p_cant,_auto_co_p_monto,_auto_co_c_cant,_auto_co_c_monto,_auto_rc_p_cant,_auto_rc_p_monto,_auto_rc_c_cant,
          _auto_rc_c_monto,_soda_co_p_cant,_soda_co_p_monto,_soda_co_c_cant,_soda_co_c_monto,_sub_p_tot_cant,_sub_p_tot_monto,_sub_c_tot_cant,_sub_c_tot_monto,_tot_cant,_tot_monto, _grupo
     FROM esttrpxtipoacum
	WHERE periodo = a_periodo2
	Order by grupo, orden asc
	
	 IF _orden = 1 THEN
		LET _descripcion = 'POLIZAS / PRIMAS';
	 ELIF _orden = 2 THEN
		LET _descripcion = 'CANTIDAD DE AUTOS EXPUESTOS';
	 ELSE
		LET _descripcion = 'SUMA ASEGURADA';
	 END IF	
	 	
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
	 return _orden,_descripcion,_auto_co_p_cant,_auto_co_p_monto,_auto_co_c_cant,_auto_co_c_monto,_auto_rc_p_cant,_auto_rc_p_monto,_auto_rc_c_cant,
          _auto_rc_c_monto,_soda_co_p_cant,_soda_co_p_monto,_soda_co_c_cant,_soda_co_c_monto,_sub_p_tot_cant,_sub_p_tot_monto,_sub_c_tot_cant,_sub_c_tot_monto,_tot_cant,_tot_monto,_grupo_s with resume; 
	 
END FOREACH	


END PROCEDURE;
