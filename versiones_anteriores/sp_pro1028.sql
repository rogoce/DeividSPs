   --DROP procedure sp_pro94;
   --CREATE procedure "informix".sp_pro94(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   DROP procedure sp_pro1028;  --casoSD#AMADO de ZULEYKA dividir por subramo y provincias 06/07/2022
   CREATE procedure "informix".sp_pro1028(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')     
   --RETURNING CHAR(50),INT,DECIMAL(16,2),CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
   returning
		Char(50) as pais_provincia,
		INTEGER  as per_cnt_polizas, 			 			 
		INTEGER as per_cnt_asegurados, 			 
		INTEGER as gen_cnt_polizas, 			 			 
		INTEGER as gen_cnt_asegurados, 			 			 
		INTEGER as fia_cnt_polizas, 			 			 
		INTEGER as fia_cnt_asegurados, 			 			 			 
		INTEGER as tot_cnt_polizas, 			 			 
		INTEGER as tot_cnt_asegurados,
		CHAR(45) as descr_cia;	
		
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
--------------------------------------------
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo,_cod_tiporamo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,
		   _total_pri_sus,v_incurrido_bruto,
           _salv_y_recup,_pago_y_ded,_var_reserva, _calculo		   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes1, _mes2,_mes,_ano2, _ano1,_orden, _meses   SMALLINT;
	DEFINE _fecha2, _fecha1     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen,_codigo_agencia        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados, _cnt_incurrido, _cnt_vencidas, _retorno INTEGER;
	
	DEFINE _per_cnt_polizas    INTEGER;
	DEFINE _per_cnt_asegurados    INTEGER;
	DEFINE _gen_cnt_polizas    INTEGER;
	DEFINE _gen_cnt_asegurados    INTEGER;
	DEFINE _fia_cnt_polizas    INTEGER;
	DEFINE _fia_cnt_asegurados    INTEGER;
	DEFINE _tot_cnt_polizas    INTEGER;
	DEFINE _tot_cnt_asegurados    INTEGER;
	define _pais_provincia   char(50);
	define _pais_residencia   char(50);
	define _cod_contratante   char(10);	
	define _nom_sucursal	char(50);	
	define _cod_sucursal   char(3);
	
	
    CREATE TEMP TABLE temp_perfil1(
              cod_ramo       CHAR(3),
              cod_subramo    CHAR(3),
              cant_polizas    INT,
              cant_polizas_ma INT,
			  cant_asegurados INT,
              PRIMARY KEY(cod_ramo,cod_subramo)) WITH NO LOG;
	  
--  CREATE TEMP TABLE temp_perfil2(								   
	CREATE  TEMP TABLE ramosubr_3 (
	         cod_ramo CHAR(3) NOT NULL, 
			 cod_subramo CHAR(3) NOT NULL, 
			 pais_provincia Char(50) not null,
			 per_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 per_cnt_asegurados INTEGER DEFAULT  0, 			 
			 gen_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 gen_cnt_asegurados INTEGER DEFAULT  0, 			 			 
			 fia_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 fia_cnt_asegurados INTEGER DEFAULT  0, 			 			 			 
			 tot_cnt_polizas INTEGER DEFAULT  0, 			 			 
			 tot_cnt_asegurados INTEGER DEFAULT  0, 			 			 			 			 
             PRIMARY KEY(cod_ramo,cod_subramo,pais_provincia)) WITH NO LOG;				  			 
CREATE INDEX iend1_ramosubr_3 ON ramosubr_3(cod_ramo);
CREATE INDEX iend2_ramosubr_3 ON ramosubr_3(cod_subramo);			  
CREATE INDEX iend3_ramosubr_3 ON ramosubr_3(pais_provincia);				  

LET _per_cnt_polizas = 0;
LET _per_cnt_asegurados  = 0;
LET _gen_cnt_polizas = 0;
LET _gen_cnt_asegurados = 0;
LET _fia_cnt_polizas = 0;	
LET _fia_cnt_asegurados  = 0;	
LET _tot_cnt_polizas = 0;
LET _tot_cnt_asegurados = 0;	

LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
LET _cod_tiporamo    = NULL;							
let _salv_y_recup    = 0;
let _pago_y_ded      = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
LET v_cant_polizas_ma  = 0;
LET _cnt_prima_nva   = 0;
LET _cnt_prima_ren   = 0;
LET _cnt_prima_can   = 0;
LET _cnt_incurrido   = 0;
LET _cnt_vencidas    = 0;
let _pais_residencia = '';						  

SET ISOLATION TO DIRTY READ;
LET descr_cia = sp_sis01(a_cia);
-- Descomponer los periodos en fechas
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
--Crea tabla temp_ramo
--CALL sp_pr94a();
--trae cant. de polizas vig. temp_perfil
CALL sp_pro95(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;
--SET DEBUG FILE TO "sp_pro94.trc"; 
--trace on;

-- Prima Suscrita tmp_prod  CALL sp_pr26h

--trae cant. de polizas vig. del mes anterior temp_perfil_b CALL sp_pro95b(					  
--Trae los siniestros brutos incurridos tmp_siniest  CALL sp_rec14(
---- Excluye los Reclamos en Reaseguro Asumido 
 update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '023';
 
 update temp_perfil
   set cod_ramo = '002'
 where cod_ramo = '020';  
--Trae la cant. de reclamos por ramo --tmp_sinis	CALL sp_pro942(				
	   
--Cargando la prima ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009

--Cargando las polizas vigentes, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009
FOREACH WITH HOLD
   SELECT no_poliza, cod_ramo, cod_subramo
     INTO _no_poliza, v_cod_ramo, v_cod_subramo
     FROM temp_perfil
    WHERE seleccionado = 1

    SELECT nueva_renov, vigencia_inic, sucursal_origen, cod_contratante, cod_origen
      INTO _nueva_renov, _vigencia_inic, _cod_sucursal, _cod_contratante, _cod_origen	  
      FROM emipomae
     WHERE no_poliza = _no_poliza;
	 
	let _cantidad_aseg = 0; 
	 
	select count(*)
	  into _cantidad_aseg
	  from emipouni
	 where no_poliza = _no_poliza;
	 	 
   let li_dia = day(_vigencia_inic);
   let li_mes = month(_vigencia_inic);
   let li_anio = year(_vigencia_inic);

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
	    	let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		else
			let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		End If
	else
		let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
	End If	

   LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;
   
   	-- Insercion a la tabla temporal 
		LET _per_cnt_polizas = 0;
		LET _per_cnt_asegurados  = 0;
		LET _gen_cnt_polizas = 0;
		LET _gen_cnt_asegurados = 0;
		LET _fia_cnt_polizas = 0;	
		LET _fia_cnt_asegurados  = 0;	
		LET _tot_cnt_polizas = 0;
		LET _tot_cnt_asegurados = 0;	
	
	select trim(cod_tiporamo) 
	  into _cod_tiporamo
	  from prdramo
	  where cod_ramo = v_cod_ramo;	  	  
	  
	    if _cod_tiporamo = '001' then
			LET _per_cnt_polizas = 1;
			LET _per_cnt_asegurados  = _cantidad_aseg;
			LET _gen_cnt_polizas = 0;
			LET _gen_cnt_asegurados = 0;
			LET _fia_cnt_polizas = 0;	
			LET _fia_cnt_asegurados  = 0;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  
	    if _cod_tiporamo = '002' then
			LET _per_cnt_polizas = 0;
			LET _per_cnt_asegurados  = 0;
			LET _gen_cnt_polizas = 1;
			LET _gen_cnt_asegurados = _cantidad_aseg;
			LET _fia_cnt_polizas = 0;	
			LET _fia_cnt_asegurados  = 0;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  
	    if _cod_tiporamo = '003' then
			LET _per_cnt_polizas = 0;
			LET _per_cnt_asegurados  = 0;
			LET _gen_cnt_polizas = 0;
			LET _gen_cnt_asegurados = 0;
			LET _fia_cnt_polizas = 1;	
			LET _fia_cnt_asegurados  = _cantidad_aseg;	
			LET _tot_cnt_polizas = 1;
			LET _tot_cnt_asegurados = _cantidad_aseg;		
		end if			  		
		let _pais_provincia = '';
		
		IF a_origen = "001" THEN			
			  
			select codigo_agencia, trim(upper(nvl(descripcion,'')))
			  into _codigo_agencia, _nom_sucursal
			  from insagen
			 where codigo_agencia  = _cod_sucursal
			   and codigo_compania = '001';	  	   			
			   LET _pais_provincia = _nom_sucursal;			   
			   
				if _codigo_agencia in ('003','005','002') then 
				else
					if _codigo_agencia in ('007') then 
						LET  _nom_sucursal = 'PANAMÁ OESTE' ;
					else
						if _codigo_agencia in ('011') then 
							LET  _nom_sucursal = 'VERAGUAS' ;
						else
							LET  _nom_sucursal = 'PANAMA' ;
					    end if					   
				    end if					   
				end if					   
			   
				if _nom_sucursal  is null  then 
					LET  _nom_sucursal = 'PANAMA' ;
				else
					 LET _pais_provincia = _nom_sucursal;
				end if			   
		ELSE	   						
				select nvl(trim(pais_residencia),'')
				into _pais_residencia
				from cliclien
				where cod_cliente = _cod_contratante;															
				
                if _pais_residencia  is null or _pais_residencia = '' then 				
					LET  _pais_residencia = 'PANAMA' ;
				end if
                if upper(_pais_residencia) in ('PANAMA','PANAMÁ') then 				
					LET  _pais_residencia = 'PANAMA' ;
				end if				
				LET _pais_provincia = _pais_residencia;
		END IF		
		
		BEGIN
          ON EXCEPTION IN(-239, -268)
             UPDATE ramosubr_3
                SET per_cnt_polizas  = per_cnt_polizas + _per_cnt_polizas,
					per_cnt_asegurados  = per_cnt_asegurados + _per_cnt_asegurados,					
					gen_cnt_polizas  = gen_cnt_polizas + _gen_cnt_polizas,
					gen_cnt_asegurados  = gen_cnt_asegurados + _gen_cnt_asegurados,					
					fia_cnt_polizas  = fia_cnt_polizas + _fia_cnt_polizas,
					fia_cnt_asegurados  = fia_cnt_asegurados + _fia_cnt_asegurados,					
					tot_cnt_polizas  = tot_cnt_polizas + _tot_cnt_polizas,
					tot_cnt_asegurados  = tot_cnt_asegurados + _tot_cnt_asegurados
              WHERE cod_ramo   = v_cod_ramo
                AND cod_subramo    = v_cod_subramo
				 AND pais_provincia = _pais_provincia;

          END EXCEPTION
			INSERT INTO ramosubr_3(
			cod_ramo,
			cod_subramo,
			pais_provincia,
			per_cnt_polizas,
			per_cnt_asegurados,
			gen_cnt_polizas,
			gen_cnt_asegurados,
			fia_cnt_polizas,
			fia_cnt_asegurados,
			tot_cnt_polizas,
			tot_cnt_asegurados 
			)
			VALUES(
			v_cod_ramo,
			v_cod_subramo,
			_pais_provincia,
			_per_cnt_polizas,
			_per_cnt_asegurados,
			_gen_cnt_polizas,
			_gen_cnt_asegurados,
			_fia_cnt_polizas,
			_fia_cnt_asegurados,
			_tot_cnt_polizas,
			_tot_cnt_asegurados 
			);  
	   END		  

   BEGIN
      ON EXCEPTION IN(-239)
         UPDATE temp_perfil1
            SET cant_polizas   = cant_polizas + 1, cant_asegurados = cant_asegurados + _cantidad_aseg
          WHERE cod_ramo       = v_cod_ramo
            AND cod_subramo    = v_cod_subramo;

      END EXCEPTION
      INSERT INTO temp_perfil1
          VALUES(v_cod_ramo,
                 v_cod_subramo,
                 1,
				 0,
				 _cantidad_aseg
                 );
   END
END FOREACH
--Cargando las polizas vigentes del mes anterior, ramos: 019, 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 009

---RECLAMOS siniestralidad Ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 003, 001, 008, 001, 003, 009, 005, 017, 019

--Actualizar los reclamos cerrados en el mes, ramos: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 009, 005, 017, 019 

--Actualizar la cantidad de reclamos, ramo: 004, 018, 014, 013, 010, 012, 011, 022, 007, 008, 001, 003, 005, 009, 017, 019  

-- Actualizando todo para los ramos: 003, 001, 017, 005, 016, 002, 006 ,015 

--call sp_pro941b(a_periodo, a_periodo2, a_origen);
--call sp_pro422(a_periodo, a_periodo2, a_origen) returning _retorno;

foreach
	select 	pais_provincia,
			sum(per_cnt_polizas),
			sum(per_cnt_asegurados),
			sum(gen_cnt_polizas),
			sum(gen_cnt_asegurados),
			sum(fia_cnt_polizas),
			sum(fia_cnt_asegurados),
			sum(tot_cnt_polizas),
			sum(tot_cnt_asegurados) 
		INTO  _pais_provincia,
			_per_cnt_polizas,
			_per_cnt_asegurados,
			_gen_cnt_polizas,
			_gen_cnt_asegurados,
			_fia_cnt_polizas,
			_fia_cnt_asegurados,
			_tot_cnt_polizas,
			_tot_cnt_asegurados 
FROM ramosubr_3			
GROUP BY pais_provincia
order by pais_provincia
			   
		RETURN  _pais_provincia, _per_cnt_polizas, _per_cnt_asegurados, _gen_cnt_polizas, _gen_cnt_asegurados, _fia_cnt_polizas, _fia_cnt_asegurados, _tot_cnt_polizas, _tot_cnt_asegurados, descr_cia  WITH RESUME;			 
END FOREACH
{
DROP TABLE temp_perfil;
DROP TABLE temp_perfil_b;
DROP TABLE temp_perfil1;
DROP TABLE temp_perfil2;
--DROP TABLE tmp_prod;
DROP TABLE temp_ramo;
DROP TABLE tmp_siniest;
DROP TABLE tmp_sinis;
}
END PROCEDURE 
                                                                                                                                                                                                                                   
