---------------------------------------------------------------------------------
--      TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO           
-- 		Realizado por Henry Giron 23/11/2009 filtros requeridos por Sr. Omar Wong
-- 		ACTUALIZAR TODOS LOS BORDERAUX POR PERIODO
-- 		PRIMA COBRADA
-- execute PROCEDURE sp_pr128 ("001","001","2009-07","2009-09","*","*","*","*",
-- "001,003;","*","*","*")
---------------------------------------------------------------------------------
--DROP PROCEDURE sp_pr128;
CREATE PROCEDURE sp_pr128(
		a_compania    CHAR(03),
		a_agencia     CHAR(03),
		a_periodo1    CHAR(07),
		a_periodo2    CHAR(07),
		a_codsucursal CHAR(255) DEFAULT "*",
		a_codgrupo    CHAR(255) DEFAULT "*",
		a_codagente   CHAR(255) DEFAULT "*",
		a_codusuario  CHAR(255) DEFAULT "*",
		a_codramo     CHAR(255) DEFAULT "*",
		a_reaseguro   CHAR(255) DEFAULT "*",
		a_contrato    CHAR(255) DEFAULT "*",
		a_serie       CHAR(255) DEFAULT "*"
		)
RETURNING INTEGER, CHAR(250);
--RETURNING CHAR(3),CHAR(3),CHAR(5),CHAR(3),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50), CHAR(50), CHAR(255);

DEFINE v_nopoliza                      CHAR(10);
DEFINE v_noendoso,v_cod_contrato       CHAR(5);
DEFINE v_cod_ramo,v_cobertura, v_clase CHAR(03);
DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
DEFINE v_desc_cobertura	               CHAR(100);
DEFINE v_filtros,v_filtros1            CHAR(255);
DEFINE _tipo                           CHAR(01);
DEFINE v_descr_cia                     CHAR(50);
DEFINE v_prima,v_prima1,v_prima50      DEC(16,2);      
DEFINE v_tipo_contrato                 SMALLINT;
define _porc_impuesto				   dec(16,2);
define _porc_comision				   dec(16,2);
define _cuenta						   char(25);
define _serie 						   smallint;
define _impuesto					   dec(16,2);
define _comision					   dec(16,2);
define _por_pagar					   dec(16,2);
define _siniestro					   dec(16,2);
DEFINE _cod_traspaso	 			   CHAR(5);
define _traspaso		 			   smallint;
define _tiene_comis_rea				   smallint;
define _cantidad					   smallint;
define _tipo_cont                      smallint;
define _porc_cont_partic 			   dec(16,2);
DEFINE _porc_comis_ase   			   DECIMAL(16,2);
define _monto_reas					   dec(16,2);
define v_prima_suscrita				   dec(16,2);
define _cod_coasegur	 			   char(3);
define _nombre_coas					   char(50);
define _nombre_cob					   char(50);
define _nombre_con					   char(50);
define _cod_subramo					   char(3);
define _cod_origen					   char(3);
define _prima_tot_ret                  dec(16,2);
define _prima_sus_tot				   dec(16,2);
define _prima_tot_ret_sum              dec(16,2);
define _prima_tot_sus_sum              dec(16,2);
define _no_cambio					   smallint;
define _no_unidad					   char(5);
define v_prima_cobrada           	   DEC(16,2);
define _porc_partic_coas			   dec(16,4);
define _fecha						   date;
define _porc_partic_prima			   dec(16,6);
define _p_sus_tot					   DEC(16,2);
define _p_sus_tot_sum				   DEC(16,2);
DEFINE _ano                            SMALLINT;
define _tot_comision 				   dec(16,2);
define _tot_impuesto 				   dec(16,2);
define _tot_prima_neta				   dec(16,2);
DEFINE _tiene_comision				   SMALLINT;
define _p_c_partic					   dec(16,2);
define _p_c_partic_hay				   smallint;
define v_existe                        smallint;
define nivel,_nivel,_seleccionado      smallint;
define _xnivel                         char(3);
define v_prima70, v_prima30            decimal (16,2);
define _comision70, _comision30        decimal (16,2);
define _impuesto70, _impuesto30        decimal (16,2);
define _por_pagar70, _por_pagar30      decimal (16,2);
define _siniestro70, _siniestro30      decimal (16,2);
define _siniestro50                    decimal (16,2);
define _porc_impuesto4				   dec(16,4);
define _porc_comision4,_porc_comisiond dec(16,4);
define _p_50_prima					   dec(16,2);
define _p_50_siniestro				   dec(16,2);
DEFINE _anio_reas					   char(9);
DEFINE _trim_reas					   Smallint;
DEFINE _borderaux					   CHAR(2);
define v_prima50_7 					   dec(16,4);
define _comision_7 					   dec(16,4);
define _impuesto_7 					   dec(16,4);
define _por_pagar_7  				   dec(16,4);
define _siniestro50_7 				   dec(16,4);
define v_prima50_3 					   dec(16,4);
define _comision_3 					   dec(16,4);
define _impuesto_3 					   dec(16,4);
define _por_pagar_3  				   dec(16,4);
define _siniestro50_3 				   dec(16,4);
define ls_noex,_desc_contrato          char(50);
define _error						   integer;
define _error_desc					   char(50);
define _bouquet,_facilidad_car         smallint;

--set debug file to "sp_pr128.trc";	  	  	  	
--trace on;

SET ISOLATION TO DIRTY READ;
LET _error     = 1;
LET v_filtros1 = '';
LET v_filtros  = '';
let _bouquet = 0;
let _facilidad_car = 0;

--begin work;

begin
on exception set _error
--rollback work;
return _error, "Error al Altualizar los borderaux.";
end exception

CALL sp_rea002(a_periodo2) RETURNING _anio_reas,_trim_reas; 

LET _ano        =  a_periodo1[1,4];
LET v_descr_cia = sp_sis01(a_compania);

-- Adicionar filtro contrato y serie
-- Filtro por Contrato

IF a_contrato <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Contrato "||TRIM(a_contrato);
	LET _tipo = sp_sis04(a_contrato); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_produccion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

-- Filtro por Serie

IF a_serie <> "*" THEN
	LET v_filtros1 = TRIM(v_filtros1) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_produccion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_produccion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN(SELECT codigo FROM tmp_codigos);
    END IF
	DROP TABLE tmp_codigos;
END IF

LET v_filtros = TRIM(v_filtros1)||" "|| TRIM(v_filtros);

-----------------------------------------------
-- CARGA DE BOREDERAUX PCOBRADA - POR TRIMESTRE	  FILTROS
-----------------------------------------------
-- 01	BOUQUET
-- 02	RUNOFF
-- 03	50%RET MAPFRE
-- 04	FACULTATIVO
-- 05	PROVINCIAL
-- 06	FASCILIDAD CAR
-- 07	ALLIED CUOTA PARTE
------------------------------------------------
FOREACH 
	select cod_contrato,nombre
	  into _borderaux,_desc_contrato
	  from reacontr
	 where activo = 1
	 order by 1

	DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
	DELETE FROM temphg where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;     -- Elimina borderaux datos;

	FOREACH 
	  select cod_ramo,
		     cod_subramo,
			 cod_origen,
	         cod_contrato,
			 desc_contrato,
	         cod_cobertura,
			 prima,
			 tipo,
			 comision,
			 impuesto,
			 por_pagar,
			 desc_cob,
			 porc_comision, 
			 porc_impuesto, 
			 porc_cont_partic, 
			 cod_coasegur,
			 serie
		into v_cod_ramo, 
	         _cod_subramo,
			 _cod_origen,
	         v_cod_contrato,
			 v_desc_contrato,
	         v_cobertura,	  
	         _monto_reas,	   
	         _tipo_cont,		
	         _comision, 		 
	         _impuesto, 		  
	         _por_pagar,		   
	         v_desc_cobertura,		
	         _porc_comision,		 
	         _porc_impuesto,		  
	         _porc_cont_partic,		   
	         _cod_coasegur,
	         _serie				
		from temp_produccion

			let  _p_c_partic = 0;
			let  _p_c_partic_hay = 0;
			let _bouquet = 0;

			select traspaso,tiene_comision,bouquet
			  into _traspaso,_tiene_comision,_bouquet
			  from reacocob
			 where cod_contrato = v_cod_contrato
			   and cod_cober_reas = v_cobertura;

			Select tipo_contrato, serie, facilidad_car
			  Into v_tipo_contrato,_serie, _facilidad_car
			  From reacomae
			 Where cod_contrato = v_cod_contrato;

			LET _seleccionado = 1;

			if _borderaux = '01' then	--Bouquet
			    if _bouquet <> 1 then
				   CONTINUE FOREACH;
			    end if

				if _serie < 2007  then 
					CONTINUE FOREACH;
				end if

				{if (_cod_coasegur <> "050" and _cod_coasegur <> "063" and _cod_coasegur <> "076"  and _cod_coasegur <> "042")  then
					CONTINUE FOREACH;
				end if}

				if v_cod_ramo = "001" and v_tipo_contrato <> 7 then 
					CONTINUE FOREACH;
				end if

				if v_cod_ramo = "006" and v_tipo_contrato <> 5 then 
					CONTINUE FOREACH;
				end if

				if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "013"  or v_cod_ramo = "014")  and v_tipo_contrato <> 7 then 
					CONTINUE FOREACH;
				end if
				if (v_cod_ramo = "008" or v_cod_ramo = "080")  and v_tipo_contrato <> 5 then 
					CONTINUE FOREACH;
				end if
				if (v_cod_ramo = "004" or v_cod_ramo = "016" or v_cod_ramo = "019")  and v_tipo_contrato <> 5 then 
					CONTINUE FOREACH;
				end if

				let _cantidad = 0;

				SELECT facilidad_car
				  INTO _cantidad
		          FROM reacomae
		         where cod_contrato = v_cod_contrato;  -- excluyendo facilidad car e incendio
				   
				if _cantidad = 1 then 
					CONTINUE FOREACH;
				end if

				LET nivel = 1;

				if _porc_cont_partic = 100 then
					LET nivel = 2;
				else
					LET nivel = 1;
				end if

				LET _seleccionado = nivel;

			end if

			if _borderaux = '02' then
		        if _serie > 2007  then 
					CONTINUE FOREACH;
				end if

		        if (_cod_coasegur <> "030" and _cod_coasegur <> "051" and _cod_coasegur <> "072"  and _cod_coasegur <> "042" and _cod_coasegur <> "063")  then
					CONTINUE FOREACH;
				end if

				if v_cod_ramo = "001" and v_tipo_contrato <> 7 then 
					CONTINUE FOREACH;
				end if

				if v_cod_ramo = "006" and v_tipo_contrato <> 5 then 
					CONTINUE FOREACH;
				end if

				if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "013"  or v_cod_ramo = "014")  and v_tipo_contrato <> 7 then 
					CONTINUE FOREACH;
				end if
				if (v_cod_ramo = "008" or v_cod_ramo = "080")  and (v_tipo_contrato <> 7 or v_tipo_contrato <> 5) then 
					CONTINUE FOREACH;
				end if
				if (v_cod_ramo = "004" or v_cod_ramo = "016" or v_cod_ramo = "019")  and v_tipo_contrato <> 5 then 
					CONTINUE FOREACH;
				end if

				let _cantidad = 0;

				SELECT facilidad_car
				  INTO _cantidad
		          FROM reacomae
		         where cod_contrato = v_cod_contrato;  -- excluyendo facilidad car e incendio
				   
				if _cantidad = 1 then 
					CONTINUE FOREACH;
				end if

				LET nivel = 1;

				if _porc_cont_partic = 100 then
					LET nivel = 2;
		 		else
					LET nivel = 1;
				end if

				LET _seleccionado = nivel;

			end if

			if _borderaux = '03' then	 -- 50 % Retencion MAPFRE	
				if _serie < 2008 then
					LET _seleccionado = 0;
				end if

				if (v_cod_ramo = "010" or v_cod_ramo = "011" or v_cod_ramo = "012" or v_cod_ramo = "013"  or v_cod_ramo = "014" or v_cod_ramo = "001"  or v_cod_ramo = "003") then 
					LET _seleccionado = 1;
				end if
				if v_cobertura = '021' and  v_cod_ramo = '001' then
					LET _seleccionado = 1;
				end if

				if v_cobertura = '022' and  v_cod_ramo = '003' then
					LET _seleccionado = 1;
				end if

				if v_tipo_contrato <> 1 then 
					LET _seleccionado = 0;
				end if
			end if

			if _borderaux = '04' then	 -- FACULTATIVO
			    LET _seleccionado =  1;
				if v_tipo_contrato <> 3 then  -- trabajar solo facultativo
					continue foreach;
				end if	

			end if

			if _borderaux = '05' then	 -- PROVINCIAL
			    LET _seleccionado =  1;
				let _cantidad = 0;

				SELECT count(*)
				  INTO _cantidad
		          FROM reacomae
		         where lower(nombre) like ('%facilidad%incendio%')	  -- excluyendo facilidad car e incendio
				   and cod_contrato = v_cod_contrato ;

				if _cantidad is null then
				   let _cantidad = 0;
				end if

				if _cantidad = 0 then 
					CONTINUE FOREACH;
				end if

			end if

			if _borderaux = '06' then	 -- FASCILIDAD CAR
			    LET _seleccionado =  1;
				let _cantidad = 0;

				SELECT facilidad_car
				  INTO _cantidad
		          FROM reacomae
		         where cod_contrato = v_cod_contrato;  -- excluyendo facilidad car e incendio
				   
				if _cantidad = 0 then 
					CONTINUE FOREACH;
				end if

			end if

			if _borderaux = '07' then	 -- ALLIED CUOTA PARTE
			    LET _seleccionado =  1;
				if _serie < 2006 then
					CONTINUE FOREACH;
				end if
				if (v_cod_ramo <> "010" and v_cod_ramo <> "011" and v_cod_ramo <> "013" and v_cod_ramo <> "014" and v_cod_ramo <> "001" and v_cod_ramo <> "003") then 
					CONTINUE FOREACH;
				end if

				if v_cod_contrato <>  "00544" and v_cod_contrato <>  "00562"  and v_cod_contrato <> "00570"  and v_cod_contrato <>  "00580" then  -- Contrato Provincial  2006,2007,2008,2009  
					CONTINUE FOREACH;
				end if
			end if


			INSERT INTO temphg
			VALUES (_cod_coasegur,
			         v_cod_ramo,
			         v_cod_contrato,
					 v_desc_contrato,
			         v_cobertura,
			         _monto_reas,
			         _tipo_cont,
			         _comision, 
			         _impuesto, 
			         _por_pagar,
			         v_desc_cobertura,
			         _porc_comision,
			         _porc_impuesto,
			         _porc_cont_partic,
			         _serie,
			         v_tipo_contrato,
			         _tiene_comision,
			         _seleccionado,
			         _anio_reas,
					 _trim_reas,
					 _borderaux) ;

	END FOREACH

-- Guarda la informacion en las tablas y valida las condiciones de los borderaux
CALL sp_pr129(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro,a_contrato,a_serie) 
RETURNING  _error, _error_desc ;

IF _error = 1 THEN
--	rollback work;
	RETURN  _error, "No genero Saldos de Borderaux";
ELSE
--	commit work;
	return 0, "Actualizacion Exitosa ...";
END IF


END FOREACH

END

END PROCEDURE  