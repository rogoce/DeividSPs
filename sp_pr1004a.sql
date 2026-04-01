
--DROP PROCEDURE sp_pr1004a;
CREATE PROCEDURE "informix".sp_pr1004a(a_compania CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_agente CHAR(255) DEFAULT "*",a_tipo CHAR(2) DEFAULT "01")
RETURNING CHAR(7),CHAR(7),SMALLINT,CHAR(50),CHAR(50),DATE,CHAR(255),CHAR(255),DECIMAL(16,2),DECIMAL(16,2),CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,CHAR(100),DATE,char(20),char(50),char(50),varchar(50),varchar(50),varchar(255);

-- Procedimiento que genera la Carta de reaseguro
-- Armando Moreno
-- 18/10/2012

BEGIN
		DEFINE v_cod_ramo         CHAR(3);
		DEFINE v_no_poliza        CHAR(10);
		DEFINE v_no_endoso        CHAR(5);
		DEFINE v_no_unidad        CHAR(5);
		DEFINE v_prima_suscrita   DEC(16,2);
		DEFINE e_prima_suscrita   DEC(16,2);
		DEFINE v_prima	          DEC(16,2);
		DEFINE v_prima_det        DEC(16,2);
		DEFINE v_prima_enc	      DEC(16,2);
		DEFINE _tipo              CHAR(01);
		DEFINE v_filtros          CHAR(255);
		DEFINE v_desc_ramo        CHAR(50);
		DEFINE v_descr_cia        CHAR(50);
		DEFINE li_si              smallint;

		DEFINE f_cod_ramo           CHAR(3);
		DEFINE f_no_poliza          CHAR(10);
		DEFINE f_no_endoso          CHAR(5);
		DEFINE f_prima_suscrita     DECIMAL(16,2);
		DEFINE f_p_emifacon         DECIMAL(16,2);
		DEFINE f_diferencia			DECIMAL(16,2);
		DEFINE f_unidad				CHAR(5);
		DEFINE f_prima_eduni		DECIMAL(16,2);
		DEFINE f_prima_dfac  		DECIMAL(16,2);
		DEFINE f_no_documento       CHAR(20);
		DEFINE v_no_documento       CHAR(20);
		DEFINE eu_total 			DECIMAL(16,2);
		DEFINE ef_total				DECIMAL(16,2);
		DEFINE _obs					CHAR(255);
		DEFINE _obsp,_Porc		    CHAR(14);
		DEFINE _q_endeuni		    DEC(16,2);
		DEFINE q_facuni_xuni        DEC(16,2);
		DEFINE _acumulado           DEC(16,2);
		DEFINE _dif_redondeo        DEC(16,2);
		DEFINE _q_facuni		    DEC(16,2);
		DEFINE f_hay,f_ns100        smallint;
		DEFINE _realizar			smallint;
		DEFINE  i_serie				integer;
		DEFINE  i_cod_ramo			char(3);
		DEFINE  i_cod_ruta			char(5);	
		DEFINE  i_no_cambio			smallint;
		DEFINE  i_no_unidad			CHAR(5);
		DEFINE  v_cod_cober_reas	char(3);
		DEFINE  i_cod_cober_reas	char(3);
		DEFINE  i_orden,i_orden_ult	integer;
		DEFINE  i_cod_contrato		char(5);
		DEFINE  i_porc_suma			DEC(10,4);
		DEFINE  i_porc_prima		DEC(10,4);
		DEFINE  i_tipo_contrato		char(1);
		DEFINE  i_suma_asegurada 	DECIMAL(16,2);
		DEFINE  s_porc_partic_prima	DEC(10,4);

		DEFINE  i_periodo1      	CHAR(7);
		DEFINE  i_periodo2	   		CHAR(7);
		DEFINE  i_renglon		   	Smallint;
		DEFINE  i_reasegurador   	CHAR(3);
		DEFINE  i_contrato	   		CHAR(5);
		DEFINE  i_fecha		   		DATE;															
		DEFINE  i_concepto1	   		CHAR(255);
		DEFINE  i_concepto2	   		CHAR(255);
		DEFINE  i_debe		   		DECIMAL(16,2);
		DEFINE  i_haber		   		DECIMAL(16,2);
		DEFINE  i_moneda		   	CHAR(2);
		DEFINE  i_saldo_favor	   	DECIMAL(16,2);
		DEFINE  i_saldo_final	   	DECIMAL(16,2);
		DEFINE  i_Total_db	   		DECIMAL(16,2);
		DEFINE  i_Total_cr	   		DECIMAL(16,2);

		DEFINE  s_tipo,t_tipo    	CHAR(10);
		DEFINE  s_fecha             DATE;
		DEFINE  s_periodo           CHAR(7);
		DEFINE  s_cod_coasegur      CHAR(3);
		DEFINE  s_cod_clase,v_clase  CHAR(3); 
		DEFINE  s_des_cod_clase      CHAR(255); 
		DEFINE  s_cod_contrato      CHAR(5);
		DEFINE  s_usuario           CHAR(15); 
		DEFINE  s_cuenta            CHAR(12); 
		DEFINE  s_ccosto            CHAR(3); 
		DEFINE  s_ano               CHAR(4); 
		DEFINE  s_inicioano         DECIMAL(16,2);
		DEFINE  s_debito            DECIMAL(16,2);
		DEFINE  s_credito           DECIMAL(16,2);
		DEFINE  s_p_partic          DECIMAL(16,2);
		DEFINE  s_renglon,v_renglon	Smallint;
        DEFINE  s_cod_cobertura 	CHAR(3);
		DEFINE 	s_des_clase			CHAR(50);
		DEFINE  s_desc_contrato		CHAR(70);
		DEFINE  m_periodo1			CHAR(7);
		DEFINE  m_periodo2			CHAR(7);
		DEFINE  m_renglon			Smallint;
		DEFINE  m_reasegurador		CHAR(3);
		DEFINE  m_contrato			CHAR(50);
		DEFINE  m_fecha				DATE;
		DEFINE  m_concepto1			CHAR(255);
		DEFINE  m_concepto2			CHAR(255);
		DEFINE  m_debe				DECIMAL(16,2);
		DEFINE  m_haber				DECIMAL(16,2);
		DEFINE  m_moneda			char(2);
		DEFINE  m_saldo_favor		DECIMAL(16,2);
		DEFINE  m_saldo_final		DECIMAL(16,2);
		DEFINE  m_Total_db			DECIMAL(16,2);
		DEFINE  m_Total_cr			DECIMAL(16,2);
		DEFINE  m_p_partic			DECIMAL(16,2);
		DEFINE  m_seleccionado		smallint;
		DEFINE  s_fechastr          CHAR(10);
		DEFINE  t_moneda           	CHAR(10);
		DEFINE  t_reasegurador		CHAR(50);
		DEFINE  s_fecha_rep         date;
		DEFINE  v_cod_clase         CHAR(3);
		DEFINE  c_cod_ramo,c_cod_clase CHAR(3);
		DEFINE _anio_reas			Char(9);
		DEFINE _trim_reas			Smallint;
		DEFINE _fecha_transf        date;
		DEFINE _no_remesa           char(10);
		DEFINE s_comision			DECIMAL(16,2);
		DEFINE s_impuesto			DECIMAL(16,2);
		DEFINE s_siniestro			DECIMAL(16,2);
		define _rengl               smallint;
		define _usuario             char(20);
		define _descripcion         char(50);
		define _cargo				char(50);
		define _tipo2               smallint;
		define _direccion_1,_des_final  varchar(50,0);
		define _monto_letras        varchar(255);
		define _monto_chequeo		DECIMAL(16,2);


SET ISOLATION TO DIRTY READ;

LET v_descr_cia     = sp_sis01(a_compania);
LET s_des_clase	    = "";	
LET s_desc_contrato	= "";
LET v_cod_ramo      = "";
let s_comision		= 0;
let s_impuesto		= 0;
let s_siniestro		= 0;
let _direccion_1    = "";
let _monto_letras   = "";
let _monto_chequeo  = 0;

--set debug file to "sp_pr1004.trc";	
--trace on;

-- Saldos iniciales de reaseguro
LET s_renglon   = 0 ;
LET s_fecha_rep = sp_sis36(a_periodo2) ;
LET c_cod_clase = 0 ;
LET c_cod_ramo  = 0 ;

if a_tipo = "01" then 
   LET s_tipo =	"Bouquet";
end if
if a_tipo = "02" then 
   LET s_tipo =	"Runoff";
end if
if a_tipo = "03" then 
   LET s_tipo =	"50%Mapfre";
end if
if a_tipo = "06" then 
   LET s_tipo =	"Facilidad CAR";
end if
if a_tipo = "08" then 
   LET s_tipo =	"Cuota Parte / Vida y Acc. P.";
end if
if a_tipo = "04" then
   let s_tipo = "Facultativo";
end if

select cod_contrato,nombre,nombre,tipo
  into a_tipo,s_tipo,m_contrato,_tipo2
  from reacontr
 where activo = 1
   and cod_contrato = a_tipo;

CALL sp_rea002(a_periodo2,_tipo2)  RETURNING _anio_reas,_trim_reas;
CALL sp_rea002a(a_periodo2,_tipo2) RETURNING _des_final;

let m_fecha = sp_sis26();

select usuario,descripcion,cargo
  into _usuario,_descripcion,_cargo
  from insuser
 where trim(cargo) = 'Jefe de Reaseguro';

{	SELECT periodo1,
		   periodo2,
		   renglon,
		   reasegurador,
		   contrato,
		   concepto1,
		   concepto2,
		   moneda,
		   p_partic,
		   seleccionado,
		   fecha_rep,
		   sum(debe),
		   sum(haber),
		   sum(saldo_favor),
		   sum(saldo_final),
		   sum(Total_db),
		   sum(Total_cr)
	  INTO m_periodo1,
		   m_periodo2,
		   m_renglon,
		   m_reasegurador,
		   s_tipo,
		   m_concepto1,
		   m_concepto2,
		   m_moneda,
		   m_p_partic,
		   m_seleccionado,
		   s_fecha_rep,
		   m_debe,
		   m_haber,
		   m_saldo_favor,
		   m_saldo_final,
		   m_Total_db,
		   m_Total_cr
      FROM reaestcta
	 where periodo1 = a_periodo1
	   and periodo2 = a_periodo2
	   and seleccionado in(1)
  group by periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,moneda,p_partic,seleccionado,fecha_rep
  order by reasegurador,contrato,periodo1,periodo2,renglon}

FOREACH

   		SELECT reasegurador,
			   sum(debe),
			   sum(haber),
			   sum(haber) - sum(debe)
		  into m_reasegurador,
			   m_debe,
			   m_haber,
			   _monto_chequeo
	      FROM reaestcta
		 where periodo1 = a_periodo1
		   and periodo2 = a_periodo2
		   and seleccionado in(1)
	  group by reasegurador
	  order by reasegurador

	select nombre,direccion_1
	  into t_reasegurador,_direccion_1
	  from emicoase
	 where cod_coasegur = m_reasegurador;

     if _direccion_1 is null then
		let _direccion_1 = "";
	 end if

	 let _monto_chequeo = abs(_monto_chequeo);

   	 Let _monto_letras = sp_sis11(_monto_chequeo);

    RETURN  a_periodo1,						--01
			a_periodo2,						--02
			0,						--03
			t_reasegurador,					--04
			m_contrato,						--05
			m_fecha,						--06
			"",					--07
			"",					--08
			m_debe,							--09
			m_haber,						--10
			"",						--11
			0,					--12
			0,					--13
			0,						--14
			0,						--15
			0,						--16
			1,					--17
			v_descr_cia, 					--18
			m_fecha,					--19
			_usuario,
			_descripcion,
			_cargo,
			_direccion_1,
			_des_final,
			_monto_letras
			WITH RESUME;

END FOREACH

END
END PROCEDURE;	 