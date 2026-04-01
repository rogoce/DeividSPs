
DROP PROCEDURE sp_pr991bk;

CREATE PROCEDURE "informix".sp_pr991bk(a_compania CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_agente CHAR(255) DEFAULT "*",a_tipo CHAR(2) DEFAULT "01")
RETURNING CHAR(7),CHAR(7),SMALLINT,CHAR(50),CHAR(50),DATE,CHAR(255),CHAR(255),DECIMAL(16,2),DECIMAL(16,2),CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,CHAR(100),DATE;

-- Procedimiento que genera los Estados de Cuenta de Reaseguro
-- Creado    : 07/10/2009 - Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	  d_prod_sp_pr991_crit    
-- execute procedure sp_pr991("001","2012-04","2012-06","063;","01")

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
		DEFINE s_siniestro,m_valor	DECIMAL(16,2);
		define _rengl ,_tipo2       smallint;
		define _trimestre_char      char(3); 

SET ISOLATION TO DIRTY READ;

delete from reaestcta
 where periodo1 = a_periodo1
   and periodo2 = a_periodo2;

LET v_descr_cia     = sp_sis01(a_compania);
LET s_des_clase	    = "";	
LET s_desc_contrato	= "";
LET v_cod_ramo      = "";
let s_comision		= 0;
let s_impuesto		= 0;
let s_siniestro		= 0;

--set debug file to "sp_pr991.trc";	
--trace on;

CREATE TEMP TABLE tmp_xramo
				(periodo1      CHAR(7),
				 periodo2	   CHAR(7),
				 cod_ramo      CHAR(3),
				 reasegurador  CHAR(3),
				 contrato	   CHAR(10),			   
				 p_partic      DECIMAL(16,2),
				 monto         DECIMAL(16,2),
				 renglon       smallint,
				 tipo          CHAR(10),
				 cod_clase	   CHAR(3),
				 fecha_transf  DATE,
				 no_remesa     CHAR(10));
CREATE INDEX id1_tmp_xramo ON tmp_xramo(periodo1,periodo2,cod_ramo,cod_clase,reasegurador,contrato,p_partic,renglon);

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
if a_tipo = "09" then 
   LET s_tipo =	"Bouquet-Fianzas";
end if

select cod_contrato,nombre,nombre,tipo
  into a_tipo,s_tipo,m_contrato,_tipo2
  from reacontr
 where activo = 1
   and cod_contrato = a_tipo;

CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas;

if _trim_reas = 1 then
	let _trimestre_char = '1ER';
elif _trim_reas = 2 then
	let _trimestre_char = '2DO';
elif _trim_reas = 3 then
	let _trimestre_char = '3ER';
else
	let _trimestre_char = '4TO';
end if


FOREACH

	select reasegurador,
	       saldo_inicial
	  into s_cod_coasegur,
	       s_credito 
	  from reaestct1 
	 where ano       = _anio_reas  
	   and trimestre = _trim_reas 	
	   and contrato  = a_tipo

		LET s_fecha = current;
		LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;
		LET c_cod_clase = 0;

		if s_credito is null then
		   LET s_credito =	0;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
		   and reasegurador = s_cod_coasegur
--		   and p_partic     = s_p_partic	
		   and contrato     = s_tipo;

		if s_renglon is null then
		   LET s_renglon =	0 ;
		end if

		LET s_renglon =	s_renglon + 1 ;

		INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		VALUES                (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0,s_credito,"01",0,0,0,0,0,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
END FOREACH

if a_tipo = "04" then --Facultativo
	FOREACH
		SELECT cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
		       sum(prima),
		       sum(comision),
		       sum(impuesto),
		       sum(siniestro)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito,
			   s_comision,
			   s_impuesto,
			   s_siniestro
		  FROM reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
	  group by cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
		       cod_ramo
	  order by cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
		       cod_ramo

		LET s_debito = 0;
		if s_debito is null then
		   LET s_debito = 0;
		end if
		if s_credito is null then
		   LET s_credito = 0;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
	       and reasegurador = s_cod_coasegur
	       and contrato     = s_tipo;

		if s_renglon is null then
		   LET s_renglon =	0 ;
		end if

		if  s_renglon =	0 then
			LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;
			 LET s_renglon = 1;
		end if

		foreach

			select trim(nombre),renglon
			  into s_des_cod_clase,_rengl
			  from reaestdif
		     where contrato = a_tipo

			LET s_renglon =	s_renglon + 1;
			LET s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"";
			end if

			select trim(nombre),trim(desc_contrato) 
			  into s_des_clase,s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

		    LET s_debito =	0;

			if _rengl = 2 then
			   let s_credito = s_comision;
			elif _rengl = 3 then
			   let s_credito = s_impuesto;
            elif _rengl = 4 then
			   let s_credito = s_siniestro;
			end if

			if _rengl in(2,3,4) then

			    if s_credito < 0 then 
				   LET s_debito  =	0;
			    else
				   LET s_debito  = s_credito;
				   LET s_credito = 0;
			    end if
			else

				if s_credito < 0 then 
				   LET s_debito  =	-1 * s_credito;
				   LET s_credito = 0;
				end if
			end if

	 		LET c_cod_clase = s_cod_clase;

			INSERT INTO reaestcta(periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,_rengl,s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

		end foreach

	END FOREACH

end if
 
if a_tipo = "08" or a_tipo = "03" or a_tipo = "02" then --Cuaota parte acc y vida-50%Mapfre-RunOff
	LET s_renglon =	0 ;
	LET s_debito  =	0 ;
	LET s_credito =	0 ;
	-- participacion de reaseguro
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,012,014),
	--                 5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	FOREACH
		SELECT reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
			   reacoest.cod_ramo,
		       sum(reacoest.participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  FROM reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
	  group by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo
	  order by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo

			LET s_debito =	0;

			if s_debito is null then
			   LET s_debito =	0;
			end if
			if s_credito is null then
			   LET s_credito =	0;
			end if

			select max(renglon)
			  into s_renglon
			  from reaestcta
			 where periodo1     = a_periodo1
			   and periodo2     = a_periodo2
		       and reasegurador = s_cod_coasegur
		       and p_partic     = s_p_partic	
		       and contrato     = s_tipo;

			if s_renglon is null then
			   LET s_renglon =	0 ;
			end if

			if  s_renglon =	0 then
				LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

				INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
				VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0');
				 LET s_renglon = 1;
			end if

			LET s_renglon =	s_renglon + 1;
			LET s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"";
			end if

			select trim(nombre),trim(desc_contrato) 
			  into s_des_clase,s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

			  LET s_des_cod_clase = 'Saldo Cuenta Tecnica '|| _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

			if s_credito < 0 then 
			   LET s_debito  =	-1 * s_credito ;
			   LET s_credito = 0;
			end if

     		LET c_cod_clase = s_cod_clase ;

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

	END FOREACH

end if
if a_tipo = "01" then --Bouquet

	LET s_renglon =	0 ;
	LET s_debito  =	0 ;
	LET s_credito =	0 ;
	-- participacion de reaseguro
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,012,014),
	--                 5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	FOREACH
		SELECT reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
			   reacoest.cod_ramo,
		       sum(reacoest.participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  FROM reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		   and p_partic  < 100
	  group by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo
	  order by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo

			LET s_debito =	0 ;

			if s_debito is null then
			   LET s_debito =	0 ;
			end if
			if s_credito is null then
			   LET s_credito =	0 ;
			end if

--			LET s_p_partic = 50;

			select max(renglon)
			  into s_renglon
			  from reaestcta
			 where periodo1     = a_periodo1
			   and periodo2     = a_periodo2
		       and reasegurador = s_cod_coasegur
		       and p_partic     = s_p_partic	
		       and contrato     = s_tipo ;

			if s_renglon is null then
			   LET s_renglon =	0 ;
			end if

			if  s_renglon =	0 then
				LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1 ;

				INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
				VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;
				 LET s_renglon = 1;
			end if

			LET s_renglon =	s_renglon + 1;
			LET s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"";
			end if
																 
			select trim(nombre),trim(desc_contrato) 
			  into s_des_clase,s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

			  LET s_des_cod_clase = 'Saldo Cuenta Tecnica ' || _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

			if s_credito < 0 then 
			   LET s_debito  =	-1 * s_credito ;
			   LET s_credito = 0;
			end if

     		LET c_cod_clase = s_cod_clase ;

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

	END FOREACH

elif a_tipo = "06" or a_tipo = '09' then --Facilidad CAR, BOUQUET FIANZAS
	LET s_renglon =	0 ;
	LET s_debito  =	0 ;
	LET s_credito =	0 ;

	FOREACH
		SELECT reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
			   reacoest.cod_ramo,
		       sum(reacoest.participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  FROM reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
	  group by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo
	  order by reacoest.cod_coasegur,
		       reacoest.p_partic,
		       reacoest.cod_clase,
		       reacoest.cod_contrato,
		       reacoest.cod_ramo

			LET s_debito =	0 ;

			if s_debito is null then
			   LET s_debito =	0 ;
			end if
			if s_credito is null then
			   LET s_credito =	0 ;
			end if

--			LET s_p_partic = 50;

			select max(renglon)
			  into s_renglon
			  from reaestcta
			 where periodo1 = a_periodo1
			   and periodo2 = a_periodo2
		       and reasegurador = s_cod_coasegur
		       and p_partic = s_p_partic	
		       and contrato = s_tipo ;

			if s_renglon is null then
			   LET s_renglon =	0 ;
			end if

			if  s_renglon =	0 then
				LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1 ;

				INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
				VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;
				 LET s_renglon = 1;
			end if

			LET s_renglon =	s_renglon + 1;
			LET s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"";
			end if

			select trim(nombre),trim(desc_contrato) 
			  into s_des_clase,s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

			  LET s_des_cod_clase = 'Saldo Cuenta Tecnica ' || _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

			if s_credito < 0 then 
			   LET s_debito  =	-1 * s_credito ;
			   LET s_credito = 0;
			end if

     		LET c_cod_clase = s_cod_clase ;

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

	END FOREACH
end if
	-- Carga de transacciones x tipo 
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014), 
	--                 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)] 

	LET s_renglon =	0 ;
	LET s_debito =	0 ;
	LET s_credito =	0 ;
    let v_clase = '' ;

	 FOREACH
		  SELECT cod_coasegur
		    INTO s_cod_coasegur
		    FROM reacoest
		   where anio      = _anio_reas
		     and trimestre = _trim_reas
		     and borderaux = a_tipo
		GROUP BY cod_coasegur
		ORDER BY cod_coasegur

	   foreach
			select p_partic
			  into s_p_partic
			  FROM reacoest
			 where anio         = _anio_reas
			   and trimestre    = _trim_reas
			   and borderaux    = a_tipo
			   and cod_coasegur = s_cod_coasegur

	         exit foreach;
		end foreach

		FOREACH

		    SELECT no_remesa,
		           tipo,
		           monto
		      into _no_remesa,
		           t_tipo,
		           s_credito
		      FROM reatrx1
		     WHERE cod_contrato = a_tipo
		       and periodo BETWEEN a_periodo1 AND a_periodo2 
			   and cod_coasegur = s_cod_coasegur
			   and actualizado  = 1

			 foreach
				select cod_ramo
				  into s_cod_clase
				  from reatrx2
				 where no_remesa = _no_remesa

				exit foreach;
			 end foreach

				select fecha_transf
				  into _fecha_transf
				  from reatrx1
				 where no_remesa = _no_remesa;

				if s_cod_clase = '001' then 
					 let v_clase = '1' ;
				end if
				if s_cod_clase = '002' or v_cod_ramo = '003' then 
					 let v_clase = '2' ;
				end if					
				if s_cod_clase = '004' then --'010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
					 let v_clase = '4' ;
				end if
				if s_cod_clase = '005' then  --005
					 let v_clase = '5' ;
				end if
				if s_cod_clase = '006' then --004
					 let v_clase = '6' ;
				end if
				if s_cod_clase = '007' then --019 y 016
					 let v_clase = '7' ;
				end if
				LET s_renglon   = s_renglon + 1 ;
         		LET c_cod_clase = v_clase ;
				LET c_cod_ramo  = s_cod_clase ;

				INSERT INTO tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo,cod_clase,fecha_transf,no_remesa)
				VALUES (a_periodo1,a_periodo2,c_cod_ramo,s_cod_coasegur,s_tipo,s_p_partic,s_credito,s_renglon,t_tipo,c_cod_clase,_fecha_transf,_no_remesa);


		END FOREACH
	END FOREACH

FOREACH
   {  SELECT distinct reasegurador,p_partic,tipo,cod_ramo,cod_clase,fecha_transf,sum(monto)
	    INTO s_cod_coasegur, s_p_partic, t_tipo,c_cod_ramo,c_cod_clase,s_fecha,s_credito
	    FROM tmp_xramo
	GROUP BY reasegurador,p_partic,tipo,cod_ramo,cod_clase,fecha_transf	
	ORDER BY reasegurador,p_partic,tipo,cod_ramo,cod_clase,fecha_transf}

	   SELECT distinct reasegurador,p_partic,tipo,cod_ramo,cod_clase,fecha_transf,monto,no_remesa
	     INTO s_cod_coasegur, s_p_partic, t_tipo, c_cod_ramo,c_cod_clase,s_fecha,s_credito,_no_remesa
	     FROM tmp_xramo

		LET s_debito =	0 ;

		if s_debito is null then
		   LET s_debito =	0 ;
		end if

		if s_credito is null then
		   LET s_credito =	0 ;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
		   and reasegurador = s_cod_coasegur
		   and p_partic     = s_p_partic	
		   and contrato     = s_tipo ;

		if s_renglon is null then
		   LET s_renglon =	0 ;
		end if

		LET s_renglon =	s_renglon + 1 ;

		if s_credito < 0 then 
		   LET s_debito  =	-1 * s_credito ;
		   LET s_credito =	0 ;				   
		end if
		if s_credito < 0 then 
		   LET s_debito  =	-1 * s_credito ;
		   LET s_credito =	0 ;
		end if
		if t_tipo = "01" then
			LET s_des_cod_clase = "Remesa Enviada Al Reasegurador " || _no_remesa;
		elif t_tipo = "02" then
			LET s_des_cod_clase = "Remesa Recibida del Reasegurador " || _no_remesa;
		else
			select descrip
			  into s_des_cod_clase
			  from reatrx1
			 where no_remesa = _no_remesa;
		end if

		INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

END FOREACH


-- Procesos v_filtros
LET v_filtros ="";
IF a_agente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Reasegurador "||TRIM(a_agente) ;
	LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE reaestcta
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE reaestcta
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

foreach
		SELECT periodo1,
			   periodo2,
			   renglon,
			   moneda
		  into m_periodo1,
			   m_periodo2,
			   m_renglon,
			   m_moneda
	      FROM reaestcta
		 where periodo1 = a_periodo1
		   and periodo2 = a_periodo2
		   and seleccionado in(1)
  exit foreach;
end foreach

foreach
		SELECT reasegurador,
			   concepto1,
			   concepto2,
			   sum(debe),
			   sum(haber),
			   fecha
		  into m_reasegurador,
			   m_concepto1,
			   m_concepto2,
			   m_debe,
			   m_haber,
			   m_fecha
	      FROM reaestcta
		 where periodo1 = a_periodo1
		   and periodo2 = a_periodo2
		   and seleccionado in(1)
	  group by reasegurador,concepto1,concepto2,fecha
	  order by reasegurador,concepto2,fecha

	if a_tipo = '04' then
		if m_haber < 0 then
			let m_haber = m_haber * -1;
		end if
	end if

	if m_moneda = "01" then
		let t_moneda = "Dolares";
	end if

    if m_debe = 0 and m_haber = 0 then
    	continue foreach;
    end if

	let m_valor = 0;
	let m_valor = m_debe - m_haber;

	if m_valor < 0 then
	   let m_haber = ABS(m_valor);
	   let m_debe = 0;
	else
	   let m_debe  = ABS(m_valor);
	   let m_haber = 0;
	end if

	select nombre
	  into t_reasegurador
	  from emicoase
	 where cod_coasegur = m_reasegurador;

    RETURN  m_periodo1,	   
			m_periodo2,	   
			m_renglon,	   
			t_reasegurador,
			m_contrato,	   
			m_fecha,	   
			m_concepto1,   
			m_concepto2,   
			m_debe,		   
			m_haber,	   
			t_moneda,	   
			0,			   
			0,			   
			0,			   
			0,			   
			0,			   
			1,			   
			v_descr_cia,   
			s_fecha_rep	        
    WITH RESUME;

end foreach

DROP TABLE tmp_xramo;

END
END PROCEDURE;	 