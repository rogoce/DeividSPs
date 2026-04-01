   -- Proceso que guarda en la tabla histórica del reporte Estadística Men. SuperInt. Por Polizas - Automóvil - Acumulado -  Histórico
	DROP procedure sp_pro4969;
    CREATE procedure "informix".sp_pro4969(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   
   RETURNING 	INTEGER	,
				CHAR(100);				
   
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
	DEFINE _cod_cobertura     CHAR(5);
	DEFINE _opcion            SMALLINT;
	DEFINE _cod_endomov       CHAR(3);
	DEFINE _nueva_renov       CHAR(1);
	DEFINE _activo           SMALLINT;
	DEFINE _cnt_prima_nva_p, _cnt_prima_ren_p INTEGER;
	DEFINE _cnt_prima_nva_c, _cnt_prima_ren_c INTEGER;
	define _prima_suscrita_p, _prima_suscrita_c DEC(16,2);
	DEFINE _no_unidad_uso_auto CHAR(5);

--SET DEBUG FILE TO "sp_pro4963.trc"; 
--trace on;

    CREATE TEMP TABLE tmp_poliza(
			  no_documento       CHAR(20),
              cod_ramo           CHAR(3),                            
			  prima_suscrita     DECIMAL(16,2),
			  sa_poliza          DECIMAL(16,2),
			  cnt_prima_nva      INTEGER,
			  cnt_prima_ren      INTEGER,
              PRIMARY KEY(no_documento,cod_ramo)) WITH NO LOG;
			  
	CREATE TEMP TABLE tmp_unidad(
			  no_documento       CHAR(20),
			  cod_ramo           CHAR(3),                            
			  no_unidad          CHAR(20),
			  Suma_asegurada     DECIMAL(16,2),			  
			  prima_suscrita     DECIMAL(16,2),
			  uso_auto           CHAR(1),                            
			  cobertura          CHAR(1),
			  prioridad          smallint,
			  emipouni_sa        DECIMAL(16,2),
			  emipouni_ps        DECIMAL(16,2),
			  cod_tipoveh        CHAR(3),
              PRIMARY KEY(no_documento,cod_ramo,no_unidad)) WITH NO LOG;			  

	CREATE TEMP TABLE tmp_rpt(
			orden		    Smallint,  
			descripcion     CHAR(100),
			auto_co_p_cant	INTEGER,
			auto_co_p_monto	DECIMAL(16,2),
			auto_co_c_cant	INTEGER,
			auto_co_c_monto	DECIMAL(16,2),
			auto_rc_p_cant	INTEGER,
			auto_rc_p_monto	DECIMAL(16,2),
			auto_rc_c_cant	INTEGER,
			auto_rc_c_monto	DECIMAL(16,2),
			soda_co_p_cant	INTEGER,
			soda_co_p_monto	DECIMAL(16,2),
			soda_co_c_cant	INTEGER,
			soda_co_c_monto	DECIMAL(16,2),
			sub_p_tot_cant	INTEGER,
			sub_p_tot_monto	DECIMAL(16,2),
			sub_c_tot_cant	INTEGER,
			sub_c_tot_monto	DECIMAL(16,2),
			tot_cant        INTEGER,
			tot_monto       DECIMAL(16,2),
			PRIMARY KEY(orden, descripcion)) WITH NO LOG;
			  
	CREATE TEMP TABLE tmp_unidad2(
			  no_documento       CHAR(20),
			  cod_ramo           CHAR(3),                            
			  no_unidad          CHAR(20),
			  Suma_asegurada     DECIMAL(16,2),			  
			  prima_suscrita     DECIMAL(16,2),
			  uso_auto           CHAR(1),                            
			  cobertura          CHAR(1),
			  prioridad          smallint,
			  emipouni_sa        DECIMAL(16,2),
			  emipouni_ps        DECIMAL(16,2),
              PRIMARY KEY(no_documento,cod_ramo,no_unidad)) WITH NO LOG;			  
 
    CREATE TEMP TABLE tmp_poliza_v(
			  no_documento       CHAR(20),
              cod_ramo           CHAR(3), 
              PRIMARY KEY(no_documento,cod_ramo)) WITH NO LOG;
			  
	CREATE TEMP TABLE tmp_unidad_v(
			  no_documento       CHAR(20),
			  cod_ramo           CHAR(3),                            
			  no_unidad          CHAR(20),
			  uso_auto           CHAR(1),                            
			  cobertura          CHAR(1),
			  prioridad          smallint,
              suma_asegurada     DEC(16,2),	
              activo             SMALLINT DEFAULT 0,			  
              PRIMARY KEY(no_documento,cod_ramo,no_unidad)) WITH NO LOG;	

	create temp table tmp_coberturas1(
					 no_poliza      CHAR(10),
					 no_unidad      CHAR(5),
					 cod_cobertura  CHAR(5),
					 primary key (no_poliza, no_unidad, cod_cobertura)) WITH NO LOG;
			  
 
INSERT INTO tmp_rpt
VALUES(1,'POLIZAS / PRIMAS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO tmp_rpt
VALUES(2,'CANTIDAD DE AUTOS EXPUESTOS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO tmp_rpt
VALUES(3,'SUMA ASEGURADA',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

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

DELETE FROM esttrpacum WHERE periodo = a_periodo2;

{-- Prima Suscrita tmp_prod
CALL sp_pr26h(
a_cia,
a_agencia,
a_periodo,
a_periodo2,
'*',
'002,020,023;', 
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*',
'*',
'*',
'%'
) RETURNING _filtros;
}
--SET DEBUG FILE TO "sp_pro4964.trc"; 
--trace on;

delete from tmp_coberturas1;

FOREACH                   
	SELECT no_poliza, no_endoso 
      INTO _no_poliza, _no_endoso 
      FROM estpolenh 
     WHERE cod_ramo in ('002','020','023')
       AND periodo >= a_periodo	 
       AND periodo <= a_periodo2	 
    
	FOREACH
		SELECT no_unidad, cod_cobertura, opcion
		  INTO _no_unidad, _cod_cobertura, _opcion
		  FROM endedcob
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso
	  ORDER BY orden
			 
		if _opcion in (0,1) then
			 begin
			 on exception in (-239, -268)
			 end exception			 
			 insert into tmp_coberturas1
			  values (_no_poliza, _no_unidad, _cod_cobertura);
			 end
		elif _opcion = 3 then
			 delete from tmp_coberturas1 
			  where no_poliza = _no_poliza 
			    and no_unidad = _no_unidad 
				and cod_cobertura = _cod_cobertura;
		end if			 
   END FOREACH
END FOREACH	


FOREACH                   
	SELECT cod_ramo, no_poliza, no_endoso, cod_endomov, nueva_renov
      INTO _cod_ramo_ori, _no_poliza, _no_endoso, _cod_endomov, _nueva_renov
     FROM estpolenh 
     WHERE cod_ramo in ('002','020','023')
       AND periodo >= a_periodo	 
       AND periodo <= a_periodo2	 
	order by cod_ramo, no_poliza, no_endoso
	   

    LET _cnt_prima_nva = 0;	  
	LET _cnt_prima_ren = 0;
	
    IF _cod_endomov = '011' THEN
		IF _nueva_renov = 'N' THEN
			LET _cnt_prima_nva = 1;
		ELSE
			LET _cnt_prima_ren = 1;
		END IF
	END IF

    SELECT prima_suscrita
	  INTO _total_pri_sus
	  FROM endedmae
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;
	   
-- SELECT cod_ramo, total_pri_sus, no_poliza, no_endoso, cnt_prima_nva, cnt_prima_ren 
--   INTO _cod_ramo_ori, _total_pri_sus, _no_poliza, _no_endoso, _cnt_prima_nva, _cnt_prima_ren 
--   FROM tmp_prod 
--  WHERE	seleccionado = 1 
  
  	SELECT no_documento, suma_asegurada
	  INTO _no_documento, _sa_poliza
	  FROM emipomae 
	 WHERE no_poliza = _no_poliza
	   AND actualizado = 1;
			 
	  IF _suma_asegurada IS NULL THEN
		 LET _suma_asegurada = 0;
	  END IF 			 	

	  IF _cod_ramo_ori = '002' OR _cod_ramo_ori = '023' THEN 
		LET _cod_ramo = '002';
	  ELSE
		LET _cod_ramo = _cod_ramo_ori;
	  END IF
      LET _suscrita_unidad = 0.00;
	  
	  IF _total_pri_sus IS NULL THEN
		LET _total_pri_sus = 0;
	  END IF  	  	  
       let _prioridad = 0;
       FOREACH 
		SELECT 	u.no_unidad,          		 
				u.suma_asegurada,
                u.prima_suscrita				
            INTO _no_unidad,
            	 _suma_asegurada,
                 _suscrita_unidad				 
		   FROM endeduni u
		  WHERE u.no_poliza = _no_poliza
			and u.no_endoso = _no_endoso			 
			order by 1
			
			  IF _suma_asegurada IS NULL THEN
				 LET _suma_asegurada = 0;
			  END IF 			 		  		  
			
          SELECT sum(suma_asegurada),sum(prima_suscrita)
            INTO _emipouni_sa,_emipouni_ps
            FROM emipouni
           WHERE no_poliza = _no_poliza
             AND no_unidad = _no_unidad; 			
			 
			  IF _emipouni_sa IS NULL THEN
				 LET _emipouni_sa = 0;
			  END IF 	
			  IF _emipouni_ps IS NULL THEN
				 LET _emipouni_ps = 0;
			  END IF 				  

		FOREACH
			SELECT no_unidad			
				INTO _no_unidad_uso_auto			 
			   FROM endeduni 
			  WHERE no_poliza = _no_poliza
				and no_endoso = _no_endoso			 
				order by 1
		    EXIT FOREACH;
		END FOREACH

          SELECT uso_auto,    -- C - Comercial o P - Particular
		         cod_tipoveh
            INTO _uso_auto,
			     _cod_tipoveh
            FROM emiauto
           WHERE no_poliza = _no_poliza
             AND no_unidad = _no_unidad_uso_auto;         
			 
			  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN  -- Pólizas sin info en Emiauto 
				FOREACH
					  SELECT uso_auto,    -- C - Comercial o P - Particular
					         cod_tipoveh
					    INTO _uso_auto,
                             _cod_tipoveh						
						FROM endmoaut 
					   WHERE no_poliza = _no_poliza
						 AND no_unidad = _no_unidad_uso_auto         
					exit FOREACH;
				end FOREACH			 

				  IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
				   LET _uso_auto = 'P';
				  END IF 				
			  END IF 			 
			 
		select count(*)
		  into _cnt_cobertura   -- Colision y Vuelco
		  from tmp_coberturas1 a, prdcober b 
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_poliza = _no_poliza
		   and a.no_unidad = _no_unidad
		   and b.nombre like "%COLISION%";		
		   
{			select count(*)
			  into _cnt_cobertura   -- Colision y Vuelco
			  from emipocob a, prdcober b 
			 where a.cod_cobertura = b.cod_cobertura
			   and a.no_poliza = _no_poliza
			   and a.no_unidad = _no_unidad
			   and b.nombre like "%COLISION%";			 
}			 
			 if _cnt_cobertura > 0 then
			     let _cobertura = 'C';   -- Completa
            else 
			     let _cobertura = 'D';   -- R.C.
			 end if

		   BEGIN
			  ON EXCEPTION IN(-239)
				 UPDATE tmp_unidad
					SET prima_suscrita = prima_suscrita + _suscrita_unidad
				   WHERE cod_ramo       = _cod_ramo
					 and no_documento = _no_documento 
					 and no_unidad  = _no_unidad ;

			  END EXCEPTION
			  
			  let _prioridad = _prioridad + 1;
			  
			  if _cod_ramo = '020' then
				if _prioridad = 1 then
					let _emipouni_sa = 5000;
					let _suma_asegurada = 5000;
				else
					let _emipouni_sa = 0;
					let _suma_asegurada = 0;
				end if
			  end if
			  
			  INSERT INTO tmp_unidad
				  VALUES(_no_documento,				         
						 _cod_ramo,
						 _no_unidad,						 						 
						 _suma_asegurada,
						 _suscrita_unidad,
						 _uso_auto,
						 _cobertura,
						 _prioridad,
						 _emipouni_sa,
						 _emipouni_ps,
						 _cod_tipoveh
						 );
		   END
		  
       END FOREACH 

  
		   BEGIN
			  ON EXCEPTION IN(-239)
				 UPDATE tmp_poliza
					SET prima_suscrita = prima_suscrita + _total_pri_sus,
					    cnt_prima_nva = cnt_prima_nva + _cnt_prima_nva,
						cnt_prima_ren = cnt_prima_ren + _cnt_prima_ren
				   WHERE cod_ramo      = _cod_ramo
					 and no_documento  = _no_documento ;

			  END EXCEPTION
			  INSERT INTO tmp_poliza
				  VALUES(_no_documento,
						 _cod_ramo,
						 _total_pri_sus,
						 _sa_poliza,
						 _cnt_prima_nva,
						 _cnt_prima_ren
						 );
		   END

	   
END FOREACH



let _cnt_prima_nva = 0;
let _cnt_prima_ren = 0;

FOREACH WITH HOLD
   SELECT no_documento,cod_ramo, prima_suscrita, sa_poliza, cnt_prima_nva, cnt_prima_ren
     INTO _no_documento,_cod_ramo, _total_pri_sus, _sa_poliza, _cnt_prima_nva, _cnt_prima_ren
     FROM tmp_poliza
	 --where no_documento = '0201-01616-01' 
	 
			  LET _cnt_unidad = 0;
			  let _3ciclo = 1;
			  let _unidad_pri_sus = 0;
			  
		   SELECT count(*)
			 INTO _cnt_unidad
			 FROM tmp_unidad	 
			WHERE no_documento = _no_documento
			  AND cod_ramo = _cod_ramo;
			  
	WHILE _3ciclo != 4
	
 
	 --return _no_documento,_cod_ramo, _total_pri_sus,_sa_poliza with resume; 
		FOREACH WITH HOLD
			select no_unidad,suma_asegurada,prima_suscrita,cobertura,uso_auto, prioridad,(case when prioridad = 1 then 1 else 0 end) primera_u,

			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C1,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C2,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C3,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C4,

			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C5,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C6,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C7,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C8,

			(case when cod_ramo = '020' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end ) C9,
			(case when cod_ramo = '020' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end ) C10,
			(case when cod_ramo = '020' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end ) C11,
			(case when cod_ramo = '020' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end ) C12,
			emipouni_sa, emipouni_ps
			into _no_unidad,_suma_asegurada,_unidad_pri_sus,_cobertura,_uso_auto,_prioridad,_primera_u,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_c10,_c11,_c12,_emipouni_sa,_emipouni_ps
			 from tmp_unidad 
			WHERE no_documento = _no_documento
			  AND cod_ramo = _cod_ramo			 
			 order by prioridad
 
			  
			   IF _3ciclo = 1 THEN
                  LET _valor = _unidad_pri_sus ;
				 -- LET _valor = _cnt_prima_nva + _cnt_prima_ren;
				  IF _primera_u = 1 THEN
					LET _primera_u = _cnt_prima_nva + _cnt_prima_ren;
				  END IF
             ELIF _3ciclo = 2 THEN
                  LET _valor = _unidad_pri_sus ; --_emipouni_ps; --
--				  let _primera_u = 1;
             ELIF _3ciclo = 3 THEN
                  LET _valor = 0; --_suma_asegurada ; -- 
				  LET _primera_u = 0;
             END IF 
			 let _primera_u = 0;
			 let _orden = _3ciclo;
			
			let	_auto_co_p_cant	 = _c1 * _primera_u;
			let	_auto_co_p_monto = _c2 * _valor;
			let	_auto_co_c_cant	 = _c3 * _primera_u;
			let	_auto_co_c_monto = _c4 * _valor;			
			
			let	_auto_rc_p_cant	 = _c5 * _primera_u;
			let	_auto_rc_p_monto = _c6 * _valor;
			let	_auto_rc_c_cant	 = _c7 * _primera_u;
			let	_auto_rc_c_monto = _c8 * _valor;			
			
			let	_soda_co_p_cant	 = _c9 * _primera_u;
			let	_soda_co_p_monto = _c10 * _valor;
			let	_soda_co_c_cant	 = _c11 * _primera_u;
			let	_soda_co_c_monto = _c12 * _valor;
			
			let	_sub_p_tot_cant	 = _auto_co_p_cant + _auto_rc_p_cant + _soda_co_p_cant;
			let	_sub_p_tot_monto = _auto_co_p_monto + _auto_rc_p_monto + _soda_co_p_monto;
			
			let	_sub_c_tot_cant	 = _auto_co_c_cant + _auto_rc_c_cant + _soda_co_c_cant;
			let	_sub_c_tot_monto = _auto_co_c_monto + _auto_rc_c_monto + _soda_co_c_monto;
			
			let	_tot_cant	 = _sub_p_tot_cant + _sub_c_tot_cant ;
			let	_tot_monto   = _sub_p_tot_monto + _sub_c_tot_monto ;

			 UPDATE tmp_rpt
				SET auto_co_p_monto	=	auto_co_p_monto	+	_auto_co_p_monto ,
				auto_co_c_monto	=	auto_co_c_monto	+	_auto_co_c_monto ,
				auto_rc_p_monto	=	auto_rc_p_monto	+	_auto_rc_p_monto ,
				auto_rc_c_monto	=	auto_rc_c_monto	+	_auto_rc_c_monto ,
				soda_co_p_monto	=	soda_co_p_monto	+	_soda_co_p_monto ,
				soda_co_c_monto	=	soda_co_c_monto	+	_soda_co_c_monto ,
				sub_p_tot_monto	=	sub_p_tot_monto	+	_sub_p_tot_monto ,
				sub_c_tot_monto	=	sub_c_tot_monto	+	_sub_c_tot_monto,
				tot_monto	=	tot_monto	+	_tot_monto,
				auto_co_p_cant	=	auto_co_p_cant	+	_auto_co_p_cant	,
				auto_co_c_cant	=	auto_co_c_cant	+	_auto_co_c_cant	,
				auto_rc_p_cant	=	auto_rc_p_cant	+	_auto_rc_p_cant	,
				auto_rc_c_cant	=	auto_rc_c_cant	+	_auto_rc_c_cant	,
				soda_co_p_cant	=	soda_co_p_cant	+	_soda_co_p_cant	,
				soda_co_c_cant	=	soda_co_c_cant	+	_soda_co_c_cant	,
				sub_p_tot_cant	=	sub_p_tot_cant	+	_sub_p_tot_cant	,
				sub_c_tot_cant	=	sub_c_tot_cant	+	_sub_c_tot_cant	,
				tot_cant	=	tot_cant	+	_tot_cant				
			   WHERE orden = _orden ;

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
				let _valor = 0;
				let _unidad_pri_sus = 0;
				let _emipouni_sa = 0;
				let _emipouni_ps = 0;			
				
	
		END FOREACH		 		

		let _3ciclo = _3ciclo + 1;
	END WHILE	
		
END FOREACH	

-- Conteo de polizas vigentes y suma asegurada
FOREACH                   
 SELECT cod_ramo, no_poliza
   INTO _cod_ramo_ori, _no_poliza 
   FROM estpolvih 
  WHERE	periodo = a_periodo2
    AND cod_ramo IN ('002','020','023')  
  
  	SELECT no_documento, 
	       suma_asegurada,
		   cod_ramo
	  INTO _no_documento, 
	       _sa_poliza,
		   _cod_ramo_ori
	FROM emipomae 
	WHERE no_poliza = _no_poliza
	AND actualizado = 1;
			 
	  IF _suma_asegurada IS NULL THEN
		 LET _suma_asegurada = 0;
	  END IF 			 	

	  IF _cod_ramo_ori = '002' OR _cod_ramo_ori = '023' THEN 
		LET _cod_ramo = '002';
	  ELSE
		LET _cod_ramo = _cod_ramo_ori;
	  END IF
	  
      LET _suscrita_unidad = 0.00;
	  
	  IF _total_pri_sus IS NULL THEN
		LET _total_pri_sus = 0;
	  END IF  	  	  
       let _prioridad = 0;
       FOREACH 
		SELECT no_endoso,
		       cod_endomov
		  INTO _no_endoso,
		       _cod_endomov
          FROM endedmae
		 WHERE no_poliza = _no_poliza
           AND periodo <= a_periodo2
        ORDER BY no_endoso	

			IF _cod_endomov = '005' THEN
				LET _activo = 0;
			ELSE
				LET _activo = 1;			
			END IF
   			   
			FOREACH
				SELECT 	no_unidad,          		 
						suma_asegurada,
						prima_suscrita				
					INTO _no_unidad,
						 _suma_asegurada,
						 _suscrita_unidad				 
				   FROM endeduni 
				  WHERE no_poliza = _no_poliza
				    AND no_endoso = _no_endoso
					order by 1
					
					  IF _suma_asegurada IS NULL THEN
						 LET _suma_asegurada = 0;
					  END IF 			 		  		  
								 
					  IF _emipouni_sa IS NULL THEN
						 LET _emipouni_sa = 0;
					  END IF 	
					  IF _emipouni_ps IS NULL THEN
						 LET _emipouni_ps = 0;
					  END IF 				  

				  SELECT uso_auto    -- C - Comercial o P - Particular
					INTO _uso_auto
					FROM emiauto
				   WHERE no_poliza = _no_poliza
					 AND no_unidad = _no_unidad;         
					 
					  IF _uso_auto IS NULL THEN  -- Pólizas sin info en Emiauto 
						FOREACH
							  SELECT uso_auto    -- C - Comercial o P - Particular
								INTO _uso_auto 
								FROM endmoaut 
							   WHERE no_poliza = _no_poliza
								 AND no_unidad = _no_unidad         
							exit FOREACH;
						end FOREACH			 

						  IF _uso_auto IS NULL THEN
						  -- LET _uso_auto = 'P';
						  END IF 				
					  END IF 			 
					 
				select count(*)
				  into _cnt_cobertura   -- Colision y Vuelco
				  from tmp_coberturas1 a, prdcober b 
				 where a.cod_cobertura = b.cod_cobertura
				   and a.no_poliza = _no_poliza
				   and a.no_unidad = _no_unidad
				   and b.nombre like "%COLISION%";	
		   
{					select count(*)
					  into _cnt_cobertura   -- Colision y Vuelco
					  from emipocob a, prdcober b 
					 where a.cod_cobertura = b.cod_cobertura
					   and a.no_poliza = _no_poliza
					   and a.no_unidad = _no_unidad
					   and b.nombre like "%COLISION%";			 
}					 
					 if _cnt_cobertura > 0 then
						 let _cobertura = 'C';   -- Completa
					else 
						 let _cobertura = 'D';   -- R.C.
					 end if
					 
					  let _prioridad = _prioridad + 1;
					  
					  if _cod_ramo = '020' then
						if _prioridad = 1 then
							let _emipouni_sa = 5000;
							let _suma_asegurada = 5000;
						else
							let _emipouni_sa = 0;
							let _suma_asegurada = 0;
						end if
					  end if

		   BEGIN
			  ON EXCEPTION IN(-239)
				 UPDATE tmp_unidad_v
					SET suma_asegurada = suma_asegurada + _suma_asegurada,
					    activo = _activo
				   WHERE cod_ramo       = _cod_ramo
					 and no_documento = _no_documento 
					 and no_unidad  = _no_unidad ;

			  END EXCEPTION
			  
			  
			  INSERT INTO tmp_unidad_v
				  VALUES(_no_documento,				         
						 _cod_ramo,
						 _no_unidad,						 						 
						 _uso_auto,
						 _cobertura,
						 _prioridad,
						 _suma_asegurada,
						 _activo
						 );
		   END

								 
			  
		   END FOREACH 
		END FOREACH
			  INSERT INTO tmp_poliza_v
				  VALUES(_no_documento,
						 _cod_ramo
						 );

	   
END FOREACH

FOREACH WITH HOLD
   SELECT no_documento,cod_ramo
     INTO _no_documento,_cod_ramo
     FROM tmp_poliza_v
	 --where no_documento = '0201-01616-01' 
	 
			  LET _cnt_unidad = 0;
			  let _3ciclo = 1;
			  let _unidad_pri_sus = 0;
			  
		   SELECT count(*)
			 INTO _cnt_unidad
			 FROM tmp_unidad	 
			WHERE no_documento = _no_documento
			  AND cod_ramo = _cod_ramo;
			  
	WHILE _3ciclo != 4
	
 
	 --return _no_documento,_cod_ramo, _total_pri_sus,_sa_poliza with resume; 
		FOREACH WITH HOLD
			select suma_asegurada, no_unidad,cobertura,uso_auto, prioridad,(case when prioridad = 1 then 1 else 0 end) primera_u,

			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C1,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C2,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C3,
			(case when cod_ramo = '002' then (case when cobertura = 'C' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C4,

			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C5,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end )  else 0 end ) C6,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C7,
			(case when cod_ramo = '002' then (case when cobertura = 'D' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end )  else 0 end ) C8,

			(case when cod_ramo = '020' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end ) C9,
			(case when cod_ramo = '020' then (case when uso_auto = 'P' then 1  else 0 end )  else 0 end ) C10,
			(case when cod_ramo = '020' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end ) C11,
			(case when cod_ramo = '020' then (case when uso_auto = 'C' then 1  else 0 end )  else 0 end ) C12,
			activo
			into _suma_asegurada,_no_unidad,_cobertura,_uso_auto,_prioridad,_primera_u,_c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_c10,_c11,_c12,_activo
			 from tmp_unidad_v 
			WHERE no_documento = _no_documento
			  AND cod_ramo = _cod_ramo			 
			 order by prioridad
 
			  
			   IF _3ciclo = 1 THEN
                  LET _valor = 0 ;
				 -- LET _valor = _cnt_prima_nva + _cnt_prima_ren;
				  --IF _primera_u = 1 THEN
				--	LET _primera_u = _cnt_prima_nva + _cnt_prima_ren;
				 -- END IF
             ELIF _3ciclo = 2 THEN
                  LET _valor = 0 ; --_emipouni_ps; --
				  let _primera_u = _activo;
             ELIF _3ciclo = 3 THEN
                  LET _valor = _suma_asegurada ; -- 
				  LET _primera_u = 0;
             END IF 
			 let _orden = _3ciclo;
			
			let	_auto_co_p_cant	 = _c1 * _primera_u;
			let	_auto_co_p_monto = _c2 * _valor;
			let	_auto_co_c_cant	 = _c3 * _primera_u;
			let	_auto_co_c_monto = _c4 * _valor;			
			
			let	_auto_rc_p_cant	 = _c5 * _primera_u;
			let	_auto_rc_p_monto = _c6 * _valor;
			let	_auto_rc_c_cant	 = _c7 * _primera_u;
			let	_auto_rc_c_monto = _c8 * _valor;			
			
			let	_soda_co_p_cant	 = _c9 * _primera_u;
			let	_soda_co_p_monto = _c10 * _valor;
			let	_soda_co_c_cant	 = _c11 * _primera_u;
			let	_soda_co_c_monto = _c12 * _valor;
			
			let	_sub_p_tot_cant	 = _auto_co_p_cant + _auto_rc_p_cant + _soda_co_p_cant;
			let	_sub_p_tot_monto = _auto_co_p_monto + _auto_rc_p_monto + _soda_co_p_monto;
			
			let	_sub_c_tot_cant	 = _auto_co_c_cant + _auto_rc_c_cant + _soda_co_c_cant;
			let	_sub_c_tot_monto = _auto_co_c_monto + _auto_rc_c_monto + _soda_co_c_monto;
			
			let	_tot_cant	 = _sub_p_tot_cant + _sub_c_tot_cant ;
			let	_tot_monto   = _sub_p_tot_monto + _sub_c_tot_monto ;

			 UPDATE tmp_rpt
				SET auto_co_p_monto	=	auto_co_p_monto	+	_auto_co_p_monto ,
				auto_co_c_monto	=	auto_co_c_monto	+	_auto_co_c_monto ,
				auto_rc_p_monto	=	auto_rc_p_monto	+	_auto_rc_p_monto ,
				auto_rc_c_monto	=	auto_rc_c_monto	+	_auto_rc_c_monto ,
				soda_co_p_monto	=	soda_co_p_monto	+	_soda_co_p_monto ,
				soda_co_c_monto	=	soda_co_c_monto	+	_soda_co_c_monto ,
				sub_p_tot_monto	=	sub_p_tot_monto	+	_sub_p_tot_monto ,
				sub_c_tot_monto	=	sub_c_tot_monto	+	_sub_c_tot_monto,
				tot_monto	=	tot_monto	+	_tot_monto,
				auto_co_p_cant	=	auto_co_p_cant	+	_auto_co_p_cant	,
				auto_co_c_cant	=	auto_co_c_cant	+	_auto_co_c_cant	,
				auto_rc_p_cant	=	auto_rc_p_cant	+	_auto_rc_p_cant	,
				auto_rc_c_cant	=	auto_rc_c_cant	+	_auto_rc_c_cant	,
				soda_co_p_cant	=	soda_co_p_cant	+	_soda_co_p_cant	,
				soda_co_c_cant	=	soda_co_c_cant	+	_soda_co_c_cant	,
				sub_p_tot_cant	=	sub_p_tot_cant	+	_sub_p_tot_cant	,
				sub_c_tot_cant	=	sub_c_tot_cant	+	_sub_c_tot_cant	,
				tot_cant	=	tot_cant	+	_tot_cant				
			   WHERE orden = _orden ;

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
				let _valor = 0;
				let _unidad_pri_sus = 0;
				let _emipouni_sa = 0;
				let _emipouni_ps = 0;			
				
	
		END FOREACH		 		

		let _3ciclo = _3ciclo + 1;
	END WHILE	
		
END FOREACH	

--SET DEBUG FILE TO "sp_pro4969.trc"; 
--trace on;

-- Se puso en comentario para el informe de taxis
select sum(cnt_polizas),
       sum(cnt_asegurados)
  into _cnt_prima_nva,
       _cnt_prima_ren
  from ramosubrh
 where cod_ramo = '002'
    and periodo = a_periodo2;

select sum(cnt_polizas),
       sum(cnt_asegurados)
  into _cnt_prima_nva_p,
       _cnt_prima_ren_p
  from ramosubrh
 where cod_ramo = '002'
   and cod_subramo = '001'
   and periodo = a_periodo2;
   
select sum(cnt_polizas),
       sum(cnt_asegurados)
  into _cnt_prima_nva_c,
       _cnt_prima_ren_c
  from ramosubrh
 where cod_ramo = '002'
   and cod_subramo = '002'
   and periodo = a_periodo2;

select sum(prima_suscrita)
  into _prima_suscrita_p
  from ramosubrh
 where cod_ramo = '002'
   and cod_subramo = '001'
   and periodo >= a_periodo
   and periodo <= a_periodo2;
   
select sum(prima_suscrita)
  into _prima_suscrita_c
  from ramosubrh
 where cod_ramo = '002'
   and cod_subramo = '002'
   and periodo >= a_periodo
   and periodo <= a_periodo2;

{-- Se puso para el informe de taxis luego poner en comentario
select sum(seleccionado),
       sum(cnt_unidades)
  into _cnt_prima_nva,
       _cnt_prima_ren
  from temp_perfil; 
}  
  
FOREACH WITH HOLD
   SELECT orden,descripcion,auto_co_p_cant,auto_co_p_monto,auto_co_c_cant,auto_co_c_monto,auto_rc_p_cant,auto_rc_p_monto,auto_rc_c_cant,
          auto_rc_c_monto,soda_co_p_cant,soda_co_p_monto,soda_co_c_cant,soda_co_c_monto,sub_p_tot_cant,sub_p_tot_monto,sub_c_tot_cant,sub_c_tot_monto,tot_cant,tot_monto
     INTO _orden,_descripcion,_auto_co_p_cant,_auto_co_p_monto,_auto_co_c_cant,_auto_co_c_monto,_auto_rc_p_cant,_auto_rc_p_monto,_auto_rc_c_cant,
          _auto_rc_c_monto,_soda_co_p_cant,_soda_co_p_monto,_soda_co_c_cant,_soda_co_c_monto,_sub_p_tot_cant,_sub_p_tot_monto,_sub_c_tot_cant,_sub_c_tot_monto,_tot_cant,_tot_monto
     FROM tmp_rpt
	 order by orden asc
	 
{	 IF _orden = 1 THEN
		IF _cnt_prima_nva  > _tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant + (_cnt_prima_nva - _tot_cant);
			LET _sub_p_tot_cant = _sub_p_tot_cant + (_cnt_prima_nva - _tot_cant);
			LET _tot_cant = _cnt_prima_nva;
		ELIF _cnt_prima_nva < _tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant - (_tot_cant - _cnt_prima_nva);
			LET _sub_p_tot_cant = _sub_p_tot_cant - (_tot_cant - _cnt_prima_nva);
			LET _tot_cant = _cnt_prima_nva ;
		END IF
     ELIF _orden = 2 THEN		
		IF _cnt_prima_ren  > _tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant + (_cnt_prima_ren - _tot_cant);
			LET _sub_p_tot_cant = _sub_p_tot_cant + (_cnt_prima_ren - _tot_cant);
			LET _tot_cant = _cnt_prima_ren;
		ELIF _cnt_prima_ren < _tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant - (_tot_cant - _cnt_prima_ren);
			LET _sub_p_tot_cant = _sub_p_tot_cant - (_tot_cant - _cnt_prima_ren);
			LET _tot_cant = _cnt_prima_ren ;
		END IF
	 END IF}

	IF _orden = 1 THEN
		IF _cnt_prima_nva_p > _sub_p_tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant + (_cnt_prima_nva_p - _sub_p_tot_cant);
			LET _sub_p_tot_cant = _sub_p_tot_cant + (_cnt_prima_nva_p - _sub_p_tot_cant);
		ELIF _cnt_prima_nva_p < _sub_p_tot_cant THEN --aqui
			LET _auto_co_p_cant = _auto_co_p_cant - (_sub_p_tot_cant - _cnt_prima_nva_p);
			LET _sub_p_tot_cant = _sub_p_tot_cant - (_sub_p_tot_cant - _cnt_prima_nva_p);
		END IF		
		IF _cnt_prima_nva_c > _sub_c_tot_cant THEN
			LET _auto_co_c_cant = _auto_co_c_cant + (_cnt_prima_nva_c - _sub_c_tot_cant);
			LET _sub_c_tot_cant = _sub_c_tot_cant + (_cnt_prima_nva_c - _sub_c_tot_cant);
		ELIF _cnt_prima_nva_c < _sub_p_tot_cant THEN --aqui
			LET _auto_co_c_cant = _auto_co_c_cant - (_sub_c_tot_cant - _cnt_prima_nva_c);
			LET _sub_c_tot_cant = _sub_c_tot_cant - (_sub_c_tot_cant - _cnt_prima_nva_c);
		END IF		
		LET _tot_cant = _cnt_prima_nva;
    ELIF _orden = 2 THEN		
		IF _cnt_prima_ren_p > _sub_p_tot_cant THEN
			LET _auto_co_p_cant = _auto_co_p_cant + (_cnt_prima_ren_p - _sub_p_tot_cant);
			LET _sub_p_tot_cant = _sub_p_tot_cant + (_cnt_prima_ren_p - _sub_p_tot_cant);
		ELIF _cnt_prima_ren_p < _sub_p_tot_cant THEN --aqui
			LET _auto_co_p_cant = _auto_co_p_cant - (_sub_p_tot_cant - _cnt_prima_ren_p);
			LET _sub_p_tot_cant = _sub_p_tot_cant - (_sub_p_tot_cant - _cnt_prima_ren_p);
		END IF		
		IF _cnt_prima_ren_c > _sub_c_tot_cant THEN
			LET _auto_co_c_cant = _auto_co_c_cant + (_cnt_prima_ren_c - _sub_c_tot_cant);
			LET _sub_c_tot_cant = _sub_c_tot_cant + (_cnt_prima_ren_c - _sub_c_tot_cant);
		ELIF _cnt_prima_ren_c < _sub_p_tot_cant THEN --aqui
			LET _auto_co_c_cant = _auto_co_c_cant - (_sub_c_tot_cant - _cnt_prima_ren_c);
			LET _sub_c_tot_cant = _sub_c_tot_cant - (_sub_c_tot_cant - _cnt_prima_ren_c);
		END IF		
		LET _tot_cant = _cnt_prima_ren;
	END IF
-------------------------------------------------------------
	IF _orden = 1 THEN
		IF _prima_suscrita_p > _sub_p_tot_monto THEN
			LET _auto_co_p_monto = _auto_co_p_monto + (_prima_suscrita_p - _sub_p_tot_monto);
			LET _sub_p_tot_monto = _sub_p_tot_monto + (_prima_suscrita_p - _sub_p_tot_monto);
		ELIF _prima_suscrita_p < _sub_p_tot_monto THEN --aqui
			LET _auto_co_p_monto = _auto_co_p_monto - (_sub_p_tot_monto - _prima_suscrita_p);
			LET _sub_p_tot_monto = _sub_p_tot_monto - (_sub_p_tot_monto - _prima_suscrita_p);
		END IF		
		IF _prima_suscrita_c > _sub_c_tot_monto THEN
			LET _auto_co_c_monto = _auto_co_c_monto + (_prima_suscrita_c - _sub_c_tot_monto);
			LET _sub_c_tot_monto = _sub_c_tot_monto + (_prima_suscrita_c - _sub_c_tot_monto);
		ELIF _prima_suscrita_c < _sub_p_tot_monto THEN --aqui
			LET _auto_co_c_monto = _auto_co_c_monto - (_sub_c_tot_monto - _prima_suscrita_c);
			LET _sub_c_tot_monto = _sub_c_tot_monto - (_sub_c_tot_monto - _prima_suscrita_c);
		END IF		
		LET _tot_monto = _prima_suscrita_p + _prima_suscrita_c;
    ELIF _orden = 2 THEN		
		IF _prima_suscrita_p > _sub_p_tot_monto THEN
			LET _auto_co_p_monto = _auto_co_p_monto + (_prima_suscrita_p - _sub_p_tot_monto);
			LET _sub_p_tot_monto = _sub_p_tot_monto + (_prima_suscrita_p - _sub_p_tot_monto);
		ELIF _prima_suscrita_p < _sub_p_tot_monto THEN --aqui
			LET _auto_co_p_monto = _auto_co_p_monto - (_sub_p_tot_monto - _prima_suscrita_p);
			LET _sub_p_tot_monto = _sub_p_tot_monto - (_sub_p_tot_monto - _prima_suscrita_p);
		END IF		
		IF _prima_suscrita_c > _sub_c_tot_monto THEN
			LET _auto_co_c_monto = _auto_co_c_monto + (_prima_suscrita_c - _sub_c_tot_monto);
			LET _sub_c_tot_monto = _sub_c_tot_monto + (_prima_suscrita_c - _sub_c_tot_monto);
		ELIF _prima_suscrita_c < _sub_c_tot_monto THEN --aqui
			LET _auto_co_c_monto = _auto_co_c_monto - (_sub_c_tot_monto - _prima_suscrita_c);
			LET _sub_c_tot_monto = _sub_c_tot_monto - (_sub_c_tot_monto - _prima_suscrita_c);
		END IF		
		LET _tot_monto = _prima_suscrita_p + _prima_suscrita_c;
	END IF
	 
	 insert into esttrpacum(
		periodo,
		orden,
		auto_co_p_cant,
		auto_co_p_monto,
		auto_co_c_cant,
		auto_co_c_monto,
		auto_rc_p_cant,
		auto_rc_p_monto,
		auto_rc_c_cant,
        auto_rc_c_monto,
		soda_co_p_cant,
		soda_co_p_monto,
		soda_co_c_cant,
		soda_co_c_monto,
		sub_p_tot_cant,
		sub_p_tot_monto,
		sub_c_tot_cant,
		sub_c_tot_monto,
		tot_cant,
		tot_monto)
		values (
		a_periodo2,
		_orden,
		_auto_co_p_cant,
		_auto_co_p_monto,
		_auto_co_c_cant,
		_auto_co_c_monto,
		_auto_rc_p_cant,
		_auto_rc_p_monto,
		_auto_rc_c_cant,
        _auto_rc_c_monto,
		_soda_co_p_cant,
		_soda_co_p_monto,
		_soda_co_c_cant,
		_soda_co_c_monto,
		_sub_p_tot_cant,
		_sub_p_tot_monto,
		_sub_c_tot_cant,
		_sub_c_tot_monto,
		_tot_cant,
		_tot_monto); 
	 
END FOREACH	

DROP TABLE  if exists tmp_prod;
DROP TABLE  if exists tmp_poliza;
DROP TABLE  if exists tmp_unidad;
DROP TABLE  if exists tmp_rpt;
DROP TABLE  if exists temp_perfil;
DROP TABLE  if exists tmp_unidad2;
DROP TABLE  if exists tmp_poliza_v;
DROP TABLE  if exists tmp_unidad_v;
DROP TABLE  if exists tmp_coberturas1;

return 0, "Proceso Satisfactorio";

END PROCEDURE;
