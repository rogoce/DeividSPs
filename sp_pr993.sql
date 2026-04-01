DROP PROCEDURE sp_pr993;

CREATE PROCEDURE "informix".sp_pr993(a_compania CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_agente CHAR(255) DEFAULT "*",a_tipo CHAR(2) DEFAULT "01")
RETURNING CHAR(7),CHAR(7),SMALLINT,CHAR(50),CHAR(10),DATE,CHAR(255),CHAR(255),DECIMAL(16,2),DECIMAL(16,2),CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,CHAR(100),DATE;

-- Procedimiento que genera los estados de cuenta de reaseguro
-- Creado    : 07/10/2009 - Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	  d_prod_sp_pr991_crit    
-- execute procedure sp_pr991("001","2009-07","2009-09","*","01")

BEGIN
		DEFINE v_cod_ramo         CHAR(3);
		DEFINE v_no_poliza        CHAR(10);
		DEFINE v_no_endoso        CHAR(5);
		DEFINE v_no_unidad        CHAR(5);
		--	  DEFINE cod_cober_reas	    CHAR(3);
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
		DEFINE  s_cod_ramo,v_clase  CHAR(3); 
		DEFINE  s_des_cod_ramo      CHAR(255); 
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
		DEFINE  m_periodo1			CHAR(7);
		DEFINE  m_periodo2			CHAR(7);
		DEFINE  m_renglon			Smallint;
		DEFINE  m_reasegurador		CHAR(3);
		DEFINE  m_contrato			CHAR(10);
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


SET ISOLATION TO DIRTY READ;
LET v_descr_cia  = sp_sis01(a_compania);
--set debug file to "sp_pr991.trc";	
--trace on;
{
CREATE TEMP TABLE reaestcta
				(periodo1      CHAR(7),
				periodo2	   CHAR(7),
				renglon		   SMALLINT,
				reasegurador   CHAR(3),
				contrato	   CHAR(10),
				fecha		   DATE,
				concepto1	   CHAR(255),
				concepto2	   CHAR(255),
				debe		   DECIMAL(16,2),
				haber		   DECIMAL(16,2),
				moneda		   CHAR(2),
				saldo_favor	   DECIMAL(16,2),
				saldo_final	   DECIMAL(16,2),
				Total_db	   DECIMAL(16,2),
				Total_cr	   DECIMAL(16,2),
				p_partic       DECIMAL(16,2),
				seleccionado   SMALLINT DEFAULT 1,
				fecha_rep	   DATE );
                CREATE INDEX id1_reaestcta ON reaestcta(periodo1,periodo2,renglon,reasegurador,contrato,p_partic);
				}

CREATE TEMP TABLE tmp_xramo
				(periodo1      CHAR(7),
				periodo2	   CHAR(7),
				cod_ramo       CHAR(3),
				reasegurador   CHAR(3),
				contrato	   CHAR(10),			   
				p_partic   	   DECIMAL(16,2),
				monto          DECIMAL(16,2),
				renglon        smallint,
				tipo           CHAR(10));
                CREATE INDEX id1_tmp_xramo ON tmp_xramo(periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,renglon);


-- Saldos iniciales de reaseguro
LET s_renglon =	0 ;
LET s_fecha_rep = sp_sis36(a_periodo2);

if a_tipo = "01" then 
   LET s_tipo =	"Bouquet" ;
end if
if a_tipo = "02" then 
   LET s_tipo =	"Runoff" ;
end if
if a_tipo = "03" then 
   LET s_tipo =	"50%Mapfre" ;
end if


FOREACH
  SELECT reasld0.cod_coasegur, 
		 reasld0.p_partic, 
         sum(reasld0.debito), 
         sum(reasld0.credito) 
	INTO s_cod_coasegur, 
		 s_p_partic, 
         s_debito,   
         s_credito  
    FROM reasld0  
   WHERE reasld0.tipo  = a_tipo 
     and reasld0.periodo BETWEEN a_periodo1 AND a_periodo2 
group by reasld0.cod_coasegur,reasld0.p_partic 

		LET s_fecha = current;
		LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

		if s_debito is null then
		   LET s_debito =	0 ;
		end if
		if s_credito is null then
		   LET s_credito =	0 ;
		end if

		select max(renglon)
		into s_renglon
		from reaestcta
		where periodo1 = a_periodo1
		and   periodo2 = a_periodo2
		and   reasegurador = s_cod_coasegur
		and   p_partic = s_p_partic	
		and   contrato = s_tipo ;

		if s_renglon is null then
		   LET s_renglon =	0 ;
		end if

		LET s_renglon =	s_renglon + 1 ;

		INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
		VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;

END FOREACH

if a_tipo = "01" then

	LET s_renglon =	0 ;
	LET s_debito =	0 ;
	LET s_credito =	0 ;
	-- participacion de reaseguro
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,012,014),
	--                 5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
 
	FOREACH
		SELECT   reacoest.cod_coasegur,
		         reacoest.p_partic,
		         reacoest.cod_ramo,
		         reacoest.cod_contrato,
		         sum(reacoest.participar)
		    into s_cod_coasegur, 
				 s_p_partic, 
				 s_cod_ramo,
				 s_cod_contrato,
	   	         s_credito
		    FROM reacoest
		   group by reacoest.cod_coasegur,
		         reacoest.p_partic,
		         reacoest.cod_ramo,
		         reacoest.cod_contrato
	    order by reacoest.cod_coasegur,
		         reacoest.p_partic,
		         reacoest.cod_ramo,
		         reacoest.cod_contrato

			LET s_debito =	0 ;

			if s_debito is null then
			   LET s_debito =	0 ;
			end if
			if s_credito is null then
			   LET s_credito =	0 ;
			end if

			LET s_p_partic = 50;

			select max(renglon)
			into s_renglon
			from reaestcta
			where periodo1 = a_periodo1
			and   periodo2 = a_periodo2
			and   reasegurador = s_cod_coasegur
			and   p_partic = s_p_partic	
			and   contrato = s_tipo ;

			if s_renglon is null then
			   LET s_renglon =	0 ;
			end if

			if  s_renglon =	0 then
				LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

				INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
				VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;
				 LET s_renglon =	1 ;
			end if

			LET s_renglon =	s_renglon + 1 ;
			LET s_fecha = sp_sis36(a_periodo2) ;

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"" ;
			end if

			if s_cod_ramo = '1' then
			   LET s_des_cod_ramo =	"R.C. General - Cuota Parte Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '2' then
			   LET s_des_cod_ramo =	"Incendio - Excedente Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '3' then
			   LET s_des_cod_ramo =	"Terremoto - Excedente Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '4' then
			   LET s_des_cod_ramo =	"Ramos Tecnicos - Excedente Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '5' then
			   LET s_des_cod_ramo =	"Fianzas - Excedente Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '6' then
			   LET s_des_cod_ramo =	"Acc. Personales - Cuota Parte Serie "||s_cod_contrato ;
			end if
			if s_cod_ramo = '7' then
			   LET s_des_cod_ramo =	"Vida Ind. / Col. - Cuota Parte Serie "||s_cod_contrato ;
			end if	 

			if s_credito < 0 then 
			   LET s_debito  =	-1 * s_credito ;
			   LET s_credito =	0 ;
			end if

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_ramo,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;

	END FOREACH

end if

if a_tipo = "03" then 

	-- participacion de 50% MAPFRE
	-- cobertura 001 - INCENDIO y TERREMOTO , 002 - RAMOS TECNICOS
	-- cod_ramo  001 - INCENDIO, 003 - TERREMOTO, 010 - EQUIPO ELECTRONICO , 011 - ROTURA DE MAQUINARIA , 012 - CALDERAS , 013 - MONTAJE, 014 - CAR

	LET s_renglon =	0 ;
	LET s_debito =	0 ;
	LET s_credito =	0 ;

	FOREACH
	  SELECT reacoret.cod_coasegur,
	         reacoret.cod_cobertura,
	         reacoret.cod_ramo,
	         reacoret.cod_contrato,
	         sum(reacoret.p_partic)
	  into   s_cod_coasegur,
	         s_cod_cobertura,
	         s_cod_ramo,
	         s_cod_contrato,
	         s_credito
	    FROM reacoret
	   WHERE reacoret.cod_coasegur = '063'
	   group by reacoret.cod_coasegur,
	         reacoret.cod_cobertura,
	         reacoret.cod_ramo,
	         reacoret.cod_contrato
	   order by reacoret.cod_coasegur,
	         reacoret.cod_cobertura,
	         reacoret.cod_ramo,
	         reacoret.cod_contrato

			LET s_debito =	0 ;
			LET s_fecha = sp_sis36(a_periodo2);

			if s_debito is null then
			   LET s_debito =	0 ;
			end if
			if s_credito is null then
			   LET s_credito =	0 ;
			end if

			LET s_p_partic = 50;

			select max(renglon)
			into s_renglon
			from reaestcta
			where periodo1 = a_periodo1
			and   periodo2 = a_periodo2
			and   reasegurador = s_cod_coasegur
			and   p_partic = s_p_partic	
			and   contrato = s_tipo ;

			if s_renglon is null then
			   LET s_renglon =	0 ;
			end if

			if  s_renglon =	0 then
				LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

				INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
				VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;
				LET s_renglon =	1;
			end if

			LET s_renglon =	s_renglon + 1 ;

			if s_cod_contrato is null then
			   LET s_cod_contrato =	"" ;
			end if

		    SELECT nombre
		      INTO s_des_cod_ramo
		      FROM prdramo
		     WHERE cod_ramo = s_cod_ramo;

			if s_cod_ramo = '001' then
			   LET s_des_cod_ramo = 'INCENDIO' ;
			end if
			if s_cod_ramo = '003' then
			   LET s_des_cod_ramo = 'TERREMOTO' ;
			end if

			LET s_des_cod_ramo = s_des_cod_ramo||" SERIE "||s_cod_contrato	;

			if s_credito < 0 then 
			   LET s_debito  =	-1 * s_credito ;
			   LET s_credito =	0 ;
			end if

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
			VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_ramo,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;

	END FOREACH
end if

if a_tipo = "01" then 

	-- Carga de transacciones x tipo 
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014), 
	--                 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)] 

	LET s_renglon =	0 ;
	LET s_debito =	0 ;
	LET s_credito =	0 ;

	 FOREACH
		  SELECT distinct cod_coasegur,p_partic
		    INTO s_cod_coasegur, s_p_partic
		    FROM reacoest
		ORDER BY cod_coasegur, p_partic

			FOREACH
				SELECT   a.tipo, b.cod_ramo, sum(a.monto)
				    into t_tipo, s_cod_ramo, s_credito
				    FROM reatrx1 a,reatrx2 b
				   WHERE a.no_remesa = b.no_remesa
				     and a.cod_compania = b.cod_compania
				     and a.cod_sucursal = b.cod_sucursal
				     and a.tipo = b.tipo
				     and a.cod_contrato = a_tipo
				     and a.periodo BETWEEN a_periodo1 AND a_periodo2 
					 and a.cod_coasegur = s_cod_coasegur
				group by a.tipo, b.cod_ramo

					if s_cod_ramo = '006' then 
						 let v_clase = '1' ;
					end if
					if s_cod_ramo = '001' or v_cod_ramo = '003' then 
						 let v_clase = '2' ;
					end if					
					if s_cod_ramo = '010' or v_cod_ramo = '010' or v_cod_ramo = '011'  or v_cod_ramo = '014' then 
						 let v_clase = '4' ;
					end if
					if s_cod_ramo = '008' or v_cod_ramo = '080' then 
						 let v_clase = '5' ;
					end if
					if s_cod_ramo = '004' then 
						 let v_clase = '6' ;
					end if
					if s_cod_ramo = '016' or v_cod_ramo = '019' then 
						 let v_clase = '7' ;
					end if
					LET v_renglon =	v_renglon + 1 ;


					INSERT INTO tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo)
					VALUES (a_periodo1,a_periodo2,v_clase,s_cod_coasegur,s_tipo,s_p_partic,s_credito,v_renglon,t_tipo) ;


			END FOREACH
	END FOREACH

end if

if a_tipo = "03" then 

	-- Carga de transacciones x tipo 
	-- Clasificasion - 1 - INCENDIO y MUlTIRIESGOS    2 - RAMOS TECNICOS
	--                 001 - INCENDIO   003 - TERREMOTO 	010 - 011 - 012 - 013 -
	--                 

	LET s_renglon =	0 ;
	LET s_debito =	0 ;
	LET s_credito =	0 ;

	 FOREACH
		  SELECT distinct cod_coasegur 
		    INTO s_cod_coasegur
		    FROM reacoret
		ORDER BY cod_coasegur

			FOREACH
				SELECT   a.tipo, b.cod_ramo, sum(a.monto)
				    into t_tipo, s_cod_ramo, s_credito
				    FROM reatrx1 a,reatrx2 b
				   WHERE a.no_remesa = b.no_remesa
				     and a.cod_compania = b.cod_compania
				     and a.cod_sucursal = b.cod_sucursal
				     and a.tipo = b.tipo
				     and a.cod_contrato = a_tipo
				     and a.periodo BETWEEN a_periodo1 AND a_periodo2 
					 and a.cod_coasegur = s_cod_coasegur
				group by a.tipo, b.cod_ramo

					if s_cod_ramo = '001' or v_cod_ramo = '003' then 
						 let v_clase = '1' ;
					end if					
					if s_cod_ramo = '010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
						 let v_clase = '2' ;
					end if

					LET v_renglon =	v_renglon + 1 ;
					LET s_p_partic = 50 ;


					INSERT INTO tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo)
					VALUES (a_periodo1,a_periodo2,v_clase,s_cod_coasegur,s_tipo,s_p_partic,s_credito,v_renglon,t_tipo) ;


			END FOREACH
	END FOREACH

end if



FOREACH
	  SELECT distinct reasegurador,p_partic,tipo,sum(monto)
	    INTO s_cod_coasegur, s_p_partic, t_tipo, s_credito
	    FROM tmp_xramo
	GROUP BY reasegurador,p_partic,tipo	
	ORDER BY reasegurador,p_partic,tipo

		LET s_debito =	0 ;
        LET s_fecha = sp_sis36(a_periodo2);

		if s_debito is null then
		   LET s_debito =	0 ;
		end if

		if s_credito is null then
		   LET s_credito =	0 ;
		end if

		select max(renglon)
		into s_renglon
		from reaestcta
		where periodo1 = a_periodo1
		and   periodo2 = a_periodo2
		and   reasegurador = s_cod_coasegur
		and   p_partic = s_p_partic	
		and   contrato = s_tipo ;

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
			LET s_des_cod_ramo = "Pagos al Reasegurador";
		end if
		if t_tipo = "02" then
			LET s_des_cod_ramo = "Siniestros al Reasegurador";
		end if

		INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep)
		VALUES (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,s_des_cod_ramo,"",s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep) ;

END FOREACH


-- Procesos v_filtros
LET v_filtros ="";
--Filtro por a_agente
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

FOREACH
	SELECT 	periodo1,
			periodo2,
			renglon,
			reasegurador,
			contrato,
			fecha,
			concepto1,
			concepto2,
			debe,
			haber,
			moneda,
			saldo_favor,
			saldo_final,
			Total_db,
			Total_cr,
			p_partic,
			seleccionado,
			fecha_rep
		INTO  m_periodo1,
			m_periodo2,
			m_renglon,
			m_reasegurador,
			m_contrato,
			m_fecha,
			m_concepto1,
			m_concepto2,
			m_debe,
			m_haber,
			m_moneda,
			m_saldo_favor,
			m_saldo_final,
			m_Total_db,
			m_Total_cr,
			m_p_partic,
			m_seleccionado,
			s_fecha_rep
         FROM reaestcta
	     where seleccionado in (1)
		 order by  reasegurador,contrato,periodo1,periodo2,renglon

			if m_moneda = "01" then
				let t_moneda = "Dolares";
			end if

			select nombre
			into t_reasegurador
			from emicoase
			where cod_coasegur = m_reasegurador	;

	        RETURN  m_periodo1,						--01
					m_periodo2,						--02
					m_renglon,						--03
					t_reasegurador,					--04
					m_contrato,						--05
					m_fecha,						--06
					m_concepto1,					--07
					m_concepto2,					--08
					m_debe,							--09
					m_haber,						--10
					t_moneda,						--11
					m_saldo_favor,					--12
					m_saldo_final,					--13
					m_Total_db,						--14
					m_Total_cr,						--15
					m_p_partic,						--16
					m_seleccionado,					--17
					v_descr_cia, 					--18
					s_fecha_rep						--19      
	        WITH RESUME;

END FOREACH

DROP TABLE reaestcta;
DROP TABLE tmp_xramo;

END
END PROCEDURE;	 