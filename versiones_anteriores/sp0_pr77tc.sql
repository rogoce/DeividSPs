-- Cumulos por Ubicacion  - Cobros
-- Creado : 13/09/2017 - Modificado : Henry Giron copia de temp sp_pro77 .... Prima Cobrada
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.


DROP PROCEDURE sp_pr77tc;
CREATE PROCEDURE "informix".sp_pr77tc(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_fecha2 DATE, a_ubica CHAR(255) DEFAULT "*") 
Returning integer, char(50);

DEFINE _no_poliza          CHAR(10);
DEFINE _cod_contratante    CHAR(10);
DEFINE _no_unidad, _no_endoso CHAR(5);
DEFINE _cod_ubica, _cod_ramo, _cod_subramo  CHAR(3);
DEFINE _suma     		   DEC(16,2);
DEFINE _prima    		   DEC(16,2);
DEFINE _suma_retencion     DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   DEC(16,2);
DEFINE _suma_excedente     DEC(16,2);
DEFINE _porc_partic_suma   DEC(9,6);
DEFINE _porcentaje		   DEC(9,6);
DEFINE _no_cambio, _es_terremoto,_estatus_poliza   SMALLINT;
DEFINE _mal_porc 		   CHAR(5);
DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion, _fecha_rehabilito DATE;
DEFINE _orden			   smallint;
DEFINE _prima_cobrada      DEC(16,2);
define _cod_endomov			char(3);
define _suma_aseg_total     dec(16,2);
define _prima_porcion       dec(16,2);
define _prima_cobrada_uni   dec(16,2);
define _prima_unidad        dec(16,2);
define _f_emision_unidad    date;
define _documento	     	char(20);
define _error_desc			CHAR(50);
define _error_isam			integer;
define _error				integer;
DEFINE v_compania_nombre, v_ramo, v_subramo CHAR(50);
DEFINE v_nodocumento       CHAR(20);
DEFINE v_vigencia_final    DATE;
DEFINE _tipo_contrato      SMALLINT;
define _tipo_incendio      smallint;

DEFINE v_filtros           CHAR(255);
define _tipo				char(1);
DEFINE _cod_traspaso	 CHAR(5);
DEFINE _serie,_serie1	 SMALLINT;
DEFINE _cod_contrato     CHAR(5);
DEFINE _desc_contrato    CHAR(50);
DEFINE _cod_cobertura    CHAR(3);	
DEFINE _traspaso		 SMALLINT;
DEFINE v_tipo_contrato	 SMALLINT;
DEFINE _dt_vig_inic, _fecha_cancelacion2      date;
define _excluir   		smallint;
	
drop table if exists temp_ubica;
drop table if exists temp_unidad;

   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  cod_ramo         CHAR(3),
		  cod_subramo      CHAR(3),
		  cod_contratante  CHAR(10),
		  no_poliza        CHAR(10),
		  vigencia_final   DATE,
		  no_documento	   CHAR(20),
          cantidad         INT,
          suma_asegurada   DEC(16,2),
		  mal_porc         CHAR(5),
		  retencion        DEC(16,2),
		  cant_ret         INT,
          primer_excedente DEC(16,2),
		  cant_exe         INT,
          facultativo      DEC(16,2),
		  cant_fac         INT,
          prima_terremoto  DEC(16,2),
          tipo_incendio    smallint,		  
		  orden            smallint,
		  no_unidad        char(5),   
		  suma_aseg_total  dec(16,2),		  
				serie 			 SMALLINT,
                cod_contrato     CHAR(5),
				desc_contrato    CHAR(50),
                cod_cobertura    CHAR(3),				
				seleccionado	smallint default 1,
		  primary key (no_poliza, no_unidad)) with no log;

CREATE INDEX idx1_temp_ubica ON temp_ubica(orden);

CREATE TEMP TABLE temp_unidad(
no_poliza		CHAR(10),
--no_ENDOSO		CHAR(5),
no_unidad		CHAR(5),
tipo_incendio	INT,          
cod_manzana		CHAR(15),
referencia		CHAR(50),
nombre_barrio	CHAR(50), -- );
--PRIMARY KEY (no_poliza,no_unidad)) WITH NO LOG;
PRIMARY KEY (no_poliza,no_unidad,cod_manzana,referencia,nombre_barrio)) WITH NO LOG;
CREATE INDEX idx1_temp_unidad ON temp_unidad(no_unidad);
--CREATE INDEX idx1_temp_unidad ON temp_unidad(no_poliza,no_unidad,cod_manzana);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

set debug file to "sp_pro77.trc";
trace on;
begin 
on exception set _error,_error_isam,_error_desc	
	return _error,_error_desc;
end exception 


drop table if exists tmp_emiubik;
let v_filtros = '';
SELECT cod_ubica 
  FROM emiubica
  into temp tmp_emiubik;
  
IF a_ubica <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Ubicacion: " ||  TRIM(a_ubica);
	LET _tipo = sp_sis04(a_ubica);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
		DELETE FROM tmp_emiubik		   
		 WHERE cod_ubica NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- (E) Excluir estos Registros
		DELETE FROM tmp_emiubik
		 WHERE cod_ubica IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF


LET  v_compania_nombre = sp_sis01(a_compania); 
let _documento = '';
LET _ano_contable = YEAR(a_fecha);
LET v_filtros =  '';
IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

FOREACH
   SELECT d.no_poliza, e.no_endoso, d.no_documento, d.cod_contratante, d.cod_ramo, d.cod_subramo, d.vigencia_final,  d.fecha_cancelacion, d.estatus_poliza, e.cod_endomov
     INTO _no_poliza, _no_endoso, v_nodocumento, _cod_contratante, _cod_ramo, _cod_subramo, v_vigencia_final, _fecha_cancelacion, _estatus_poliza, _cod_endomov
     FROM emipomae d, endedmae e
    WHERE d.cod_compania = a_compania
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha OR d.vigencia_final IS NULL)
   	  and e.fecha_emision <= a_fecha   -- se corrige 16/05/2022 HGIRON
	  and e.periodo <= _periodo        -- se corrige 16/05/2022 HGIRON
	  and d.actualizado = 1	           -- se corrige 16/05/2022 HGIRON
      AND d.fecha_suscripcion <= a_fecha
	  AND d.vigencia_inic < a_fecha
      AND d.actualizado = 1
	  AND e.no_poliza = d.no_poliza
	  AND d.no_documento in (
	  '0120-00234-01','0323-00060-01','0122-00025-02','0122-00024-02','0122-00277-01')
	  --'0116-00842-01','0116-00843-01','0307-00157-01','0316-00143-01')
      AND e.actualizado = 1
	  
if _fecha_cancelacion is null then 

	SELECT max(fecha_emision)
	  INTO _fecha_cancelacion
	  FROM endedmae
	 WHERE no_documento = v_nodocumento   --no_poliza = v_nopoliza
	   AND cod_endomov = '002'
	   AND fecha_emision <= a_fecha;	
end if	  
	  

	let _excluir = 0;  --- SD403# OMAR correo 13/04/2021 excluir BHN
	SELECT count(*) 
	  into _excluir 
	  FROM polexcluir
	 where no_documento = v_nodocumento;

	if  _excluir is null  then
		let _excluir = 0;
	end if

	if  _excluir <> 0 then
		continue foreach;
	end if	  
	  

      LET _fecha_emision = null;
	  let _fecha_cancelacion2 = null;

   {   IF _fecha_cancelacion <= a_fecha THEN
	   --  FOREACH   --HGSD#10035JHIM
		--	SELECT fecha_emision
		select max(fecha_emision)
			  INTO _fecha_emision
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			   AND cod_endomov = '002';
			 --  AND vigencia_inic = _fecha_cancelacion
		 --END FOREACH

		 IF  _fecha_emision <= a_fecha THEN
			CONTINUE FOREACH;
		 END IF
	  END IF
	  }
	  
	    if _fecha_cancelacion = '01/01/1900' then	--AMM
		ELSE
			IF _fecha_cancelacion <= a_fecha THEN
				 FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_cancelacion
					  FROM endedmae
					  WHERE no_documento = v_nodocumento 
					   AND cod_endomov = '002'
					   AND fecha_emision <= a_fecha
					   and actualizado = 1				--AMM
				 END FOREACH
					if  _fecha_cancelacion is null  then
						let _fecha_cancelacion =  '01/01/1900';
					end if				 
				 
				   FOREACH
					SELECT max(fecha_emision)
					  INTO _fecha_rehabilito
					  FROM endedmae
					   WHERE no_documento = v_nodocumento 
					   AND cod_endomov = '003'
					   AND fecha_emision <= a_fecha
					   and fecha_emision >=  _fecha_cancelacion
					   and actualizado = 1							--AMM
				 END FOREACH			 
					if  _fecha_rehabilito is null  then
						let _fecha_rehabilito =  '01/01/1900';
					end if				 
				 

				 IF  _fecha_cancelacion <= a_fecha and _fecha_cancelacion <> '01/01/1900' THEN
					if _fecha_rehabilito <= a_fecha and _fecha_rehabilito <> '01/01/1900' THEN					
						if _estatus_poliza in(2,4) then	--La poliza esta cancelada, no se debe mostrar	AMM
						
							SELECT min(fecha_emision)
							  INTO _fecha_cancelacion2
							  FROM endedmae
							 WHERE no_documento = v_nodocumento   --no_poliza = v_nopoliza
							   AND cod_endomov = '002'
							   AND fecha_emision >= _fecha_rehabilito;	
							   
								if  _fecha_cancelacion2 is null  then
									let _fecha_cancelacion2 =  '01/01/1900';
								end if									   
							   
								IF  _fecha_cancelacion2 <= a_fecha and _fecha_cancelacion2 <> '01/01/1900' THEN
									CONTINUE FOREACH;
								end if
						end if
					else
					   CONTINUE FOREACH;
					end if
				 END IF
			 END IF
		end if
		

	let _prima_cobrada = 0;
	
	let _prima_cobrada = sp_sis424(v_nodocumento, a_fecha2, a_fecha); -->buscando la prima cobrada en terremoto

	if  _prima_cobrada <= 0 then
		continue foreach;
	end if
	  
	  
	  LET _cant_ret = 0;
	  LET _cant_exe = 0;
	  LET _cant_fac = 0;
	  LET _mal_porc = '';
	  
	if  _documento <> v_nodocumento then
		if _documento <> '' then
			update temp_ubica			   
			   set suma_aseg_total =_suma_aseg_total 
			 where no_documento = _documento;
		 end if		
		let _suma_aseg_total = 0.00;
		let _documento = v_nodocumento;
	end if
	-- trace on;
	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni 
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso 
		   
		let _prima_cobrada_uni = 0.00;		
		
		-- HGIRON: 10/08/2017, no se toma en cuenta los casos donde hay endosos de eliminación de la unidad
			let _f_emision_unidad = null; 
			let _cod_endomov = '000';
			foreach 
				select e.fecha_emision,
					   e.cod_endomov
				  into _f_emision_unidad,
					   _cod_endomov
				  from endedmae e, endeduni u
				 where e.no_poliza = _no_poliza
		           and e.no_endoso = _no_endoso	   
				   and u.no_unidad = _no_unidad 					   
		           and e.no_poliza = u.no_poliza
				   and e.no_endoso = u.no_endoso
				   and e.cod_endomov in ('005','004')
				   and e.actualizado = 1
				 order by 1 desc
				exit foreach;					   
			end foreach
			
			if  _f_emision_unidad <= a_fecha and _cod_endomov = '005' then
				continue foreach;
			end if	-- hasta aqui						

		IF a_terremoto = 1 THEN

		 FOREACH 
			 SELECT	cod_ubica, 
					no_unidad, 
					suma_terremoto, 
					prima_terremoto 
			   INTO _cod_ubica, 
					_no_unidad, 
					_suma, 
					_prima 
			   FROM	endcuend 
				 where no_poliza = _no_poliza 
				   and no_endoso = _no_endoso 
				   and no_unidad = _no_unidad 
				   --AND cod_ubica IN (SELECT cod_ubica FROM tmp_emiubik)
				   
				LET _tipo_incendio = 0;						
				
			FOREACH
				SELECT tipo_incendio
				  INTO _tipo_incendio
				  FROM emipouni
				 WHERE no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				exit foreach;
			end foreach	  

			if _tipo_incendio = 0 or  _tipo_incendio is null then
				
				FOREACH
					SELECT tipo_incendio
					  INTO _tipo_incendio
					  FROM endeduni
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   and no_unidad = _no_unidad
					exit foreach;
				end foreach	  							

			end if	
			if _tipo_incendio = 0 or  _tipo_incendio is null then
				let _tipo_incendio = 0;
				FOREACH
					SELECT tipo_incendio
					  INTO _tipo_incendio
					  FROM endeduni
					 WHERE no_poliza = _no_poliza
	--					   AND no_endoso = _no_endoso
					   and no_unidad = _no_unidad
					 order by  tipo_incendio desc
					exit foreach;
				end foreach
			end if	
			LET _suma_retencion = 0;
			LET _suma_excedente = 0;
			LET _suma_facultativo = 0; 
			LET _porcentaje = 0;
			LET _es_terremoto = 0;
			let _no_cambio = 0;
			let _suma_aseg_total  = _suma_aseg_total + _suma; 
				
			FOREACH
			 SELECT	no_cambio
			   INTO	_no_cambio
			   FROM	emireama
			  WHERE	no_poliza       = _no_poliza
				AND no_unidad       = _no_unidad
				AND vigencia_inic   <= a_fecha
				AND (vigencia_final >= a_fecha
				OR vigencia_final IS NULL)
			  ORDER BY no_cambio DESC
					EXIT FOREACH;
			END FOREACH
			if _no_cambio is null then
					let _no_cambio = 0;
			end if					


			FOREACH
				SELECT x.porc_partic_suma,
					   y.tipo_contrato,
					   z.es_terremoto
				  INTO _porc_partic_suma,
					   _tipo_contrato,
					   _es_terremoto
				  FROM emireaco x, reacomae y, reacobre z
				 WHERE x.no_poliza = _no_poliza
				   AND x.no_unidad = _no_unidad
				   AND x.no_cambio = _no_cambio
				   AND y.cod_contrato = x.cod_contrato
				   AND z.cod_cober_reas = x.cod_cober_reas
				   AND z.es_terremoto = 0

				IF _tipo_contrato = 1 THEN
					LET _suma_retencion = _suma_retencion + _suma * _porc_partic_suma / 100;
					LET _cant_ret = 1;
				ELIF _tipo_contrato = 3 THEN
					LET _suma_facultativo = _suma_facultativo + _suma * _porc_partic_suma / 100;
					LET _cant_fac = 1;
				ELSE
					LET _suma_excedente = _suma_excedente  + _suma * _porc_partic_suma / 100;
					LET _cant_exe = 1;
				END IF
				LET _porcentaje =  _porcentaje + _porc_partic_suma;
				IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
				   LET _mal_porc = _no_unidad;
				ELSE
				   LET _mal_porc = '';
				END IF
					--hg_ini
					let _prima_porcion = 0.00;
					let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
					let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;

					if _prima_cobrada_uni is null then
						let _prima_cobrada_uni = 0;
					end if										
					--hg_fin				
			END FOREACH
			
			
		 select min(cod_cober_reas)
		   into _cod_cobertura
		   from emireama
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		    and no_cambio = _no_cambio;

         FOREACH
			    select cod_contrato
	              into _cod_contrato
	              from emireaco
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cobertura

				select traspaso
				  into _traspaso
				  from reacocob
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cobertura;

				Select cod_traspaso,
					   tipo_contrato,
					   serie
				  Into _cod_traspaso,
					   v_tipo_contrato,
					   _serie
				  From reacomae
				 Where cod_contrato = _cod_contrato;

				if _traspaso = 1 then
					let _cod_contrato = _cod_traspaso;
				end if

		        SELECT nombre,
				       serie
		          INTO _desc_contrato,
				       _serie
		          FROM reacomae
		         WHERE cod_contrato = _cod_contrato;


				{SELECT vigencia_inic 
				  INTO _dt_vig_inic
				  FROM endedmae 
				 WHERE no_poliza  = _no_poliza
				   AND no_endoso = '00000' 
				   AND actualizado = 1; 

			   FOREACH
			    SELECT serie 
				  INTO _serie1 
			      FROM reacomae 
				 WHERE tipo_contrato = v_tipo_contrato 
				   AND _dt_vig_inic BETWEEN vigencia_inic AND vigencia_final
				 order by serie desc
				  exit foreach;
				   end foreach

					if _serie1 is not null or _serie1 <> 0 then
					   LET _serie = _serie1;	
				   end if}
				   
		END FOREACH				   
			


			IF _es_terremoto = 0 THEN
				let _orden = sp_sis184(_cod_ubica);
				BEGIN
					ON EXCEPTION IN(-239)
						UPDATE temp_ubica			   
						   SET suma_asegurada   = suma_asegurada   + _suma,
							   mal_porc         = _mal_porc,
							   retencion        = retencion        + _suma_retencion,
							   cant_ret			= _cant_ret,
							   primer_excedente = primer_excedente + _suma_excedente,
							   cant_exe			= _cant_exe,
							   facultativo      = facultativo	   + _suma_facultativo,
							   cant_fac			= _cant_fac
							--   prima_terremoto  = prima_terremoto  + _prima
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
							   
					END EXCEPTION
					INSERT INTO temp_ubica
					   VALUES(_cod_ubica,
							  _cod_ramo,
							  _cod_subramo,
							  _cod_contratante,
							  _no_poliza,
							  v_vigencia_final,
							  v_nodocumento,
							  1,
							  _suma,  
							  _mal_porc,
							  _suma_retencion,
							  _cant_ret,
							  _suma_excedente,
							  _cant_exe,
							  _suma_facultativo,
							  _cant_fac,
							  _prima_cobrada,
							  _tipo_incendio,
							  _orden,
							  _no_unidad,
							  0, --);
							  _serie,
                              _cod_contrato,
				              _desc_contrato,
                              _cod_cobertura,1);
				
				END
				BEGIN
					ON EXCEPTION IN(-239)
					END EXCEPTION


					INSERT INTO temp_unidad(
							no_poliza,							
							no_unidad,
							tipo_incendio,
							cod_manzana,
							referencia,
							nombre_barrio)
					SELECT	_no_poliza,
							endeduni.no_unidad,
							emipouni.tipo_incendio,
							emipouni.cod_manzana,
							emiman05.referencia AS referencia,
							(SELECT emiman04.nombre
							   FROM	emiman04
							  WHERE	(emiman04.cod_provincia = emiman05.cod_provincia )
								AND	( emiman04.cod_distrito = emiman05.cod_distrito )
								AND 	( emiman04.cod_correg = emiman05.cod_correg )
								AND	( emiman04.cod_barrio = emiman05.cod_barrio )  ) AS nombre_barrio
					  FROM emipouni LEFT OUTER JOIN emiman05 ON emipouni.cod_manzana = emiman05.cod_manzana, emipomae, endeduni
					 WHERE emipomae.no_poliza = endeduni.no_poliza
					   --and emiman05.cod_barrio in ('0103','4400')
					   --AND emipomae.vigencia_final >= a_fecha --OR emipomae.vigencia_final IS NULL
					   AND emipomae.fecha_suscripcion <= a_fecha
					   AND emipomae.vigencia_inic < a_fecha
					   and emipouni.no_poliza = endeduni.no_poliza
					   and emipouni.no_unidad = endeduni.no_unidad					   
					   and emipomae.no_documento = v_nodocumento
					   and emipouni.cod_manzana is not null and emiman05.referencia is not null
					   --AND endeduni.no_poliza = _no_poliza and endeduni.no_endoso in ('00000', _no_endoso) 
					   and endeduni.no_unidad = _no_unidad
					   and emipomae.actualizado = 1
					   order by endeduni.no_endoso desc;				
					 
				END
					
			END IF 
		 END FOREACH
		ELSE
		 FOREACH
			 SELECT	cod_ubica, 
					no_unidad,
					suma_incendio, 
					prima_incendio 
			   INTO _cod_ubica, 
					_no_unidad,
					_suma, 
					_prima 
			   FROM	endcuend
			  where no_poliza = _no_poliza
				and no_endoso = _no_endoso
				and no_unidad = _no_unidad 
				--AND cod_ubica IN (SELECT cod_ubica FROM tmp_emiubik)				
				
				LET _tipo_incendio = 0;						
				
			FOREACH
				SELECT tipo_incendio
				  INTO _tipo_incendio
				  FROM emipouni
				 WHERE no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				exit foreach;
			end foreach	  

			if _tipo_incendio = 0 or  _tipo_incendio is null then
				
				FOREACH
					SELECT tipo_incendio
					  INTO _tipo_incendio
					  FROM endeduni
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   and no_unidad = _no_unidad
					exit foreach;
				end foreach	  							
			end if	
			if _tipo_incendio = 0 or  _tipo_incendio is null then
				let _tipo_incendio = 0;
				FOREACH
					SELECT tipo_incendio
					  INTO _tipo_incendio
					  FROM endeduni
					 WHERE no_poliza = _no_poliza
	--					   AND no_endoso = _no_endoso
					   and no_unidad = _no_unidad
					 order by  tipo_incendio desc
					exit foreach;
				end foreach
			end if					

			LET _suma_retencion = 0;
			LET _suma_excedente = 0;
			LET _suma_facultativo = 0; 
			LET _porcentaje = 0;
			LET _es_terremoto = 1;
			let _no_cambio = 0;
			let _suma_aseg_total  = _suma_aseg_total + _suma;			

			FOREACH
			 SELECT	no_cambio
			   INTO	_no_cambio
			   FROM	emireama
			  WHERE	no_poliza       = _no_poliza
				AND no_unidad       = _no_unidad
				AND vigencia_inic   <= a_fecha
				AND (vigencia_final >= a_fecha
				OR vigencia_final IS NULL)
			  ORDER BY no_cambio DESC
					EXIT FOREACH;
			END FOREACH
			
			if _no_cambio is null then
					let _no_cambio = 0;
			end if				


			FOREACH
				SELECT x.porc_partic_suma,
					   y.tipo_contrato,
					   z.es_terremoto
				  INTO _porc_partic_suma,
					   _tipo_contrato,
					   _es_terremoto
				  FROM emireaco x, reacomae y, reacobre z
				 WHERE y.cod_contrato = x.cod_contrato
				   AND x.no_poliza = _no_poliza
				   AND x.no_unidad = _no_unidad
				   AND x.no_cambio = _no_cambio
				   AND z.cod_cober_reas = x.cod_cober_reas
				   AND z.es_terremoto = 0

				IF _tipo_contrato = 1 THEN
					LET _suma_retencion = _suma_retencion + _suma * _porc_partic_suma / 100;
					LET _cant_ret = 1;
				ELIF _tipo_contrato = 3 THEN
					LET _suma_facultativo = _suma_facultativo + _suma * _porc_partic_suma / 100;
					LET _cant_fac = 1;
				ELSE
					LET _suma_excedente = _suma_excedente  + _suma * _porc_partic_suma / 100;
					LET _cant_exe = 1;
				END IF
				LET _porcentaje =  _porcentaje + _porc_partic_suma;
				IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
				   LET _mal_porc = _no_unidad;
				ELSE
				   LET _mal_porc = '';
				END IF
				
				--hg_ini
				let _prima_porcion = 0.00;
				let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
				let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;
			   
				if _prima_cobrada_uni is null then
					let _prima_cobrada_uni = 0;
				end if
				--hg_fin													
			END FOREACH
			
		 select min(cod_cober_reas)
		   into _cod_cobertura
		   from emireama
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		    and no_cambio = _no_cambio;

         FOREACH
			    select cod_contrato
	              into _cod_contrato
	              from emireaco
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cobertura

				select traspaso
				  into _traspaso
				  from reacocob
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cobertura;

				Select cod_traspaso,
					   tipo_contrato,
					   serie
				  Into _cod_traspaso,
					   v_tipo_contrato,
					   _serie
				  From reacomae
				 Where cod_contrato = _cod_contrato;

				if _traspaso = 1 then
					let _cod_contrato = _cod_traspaso;
				end if

		        SELECT nombre,
				       serie
		          INTO _desc_contrato,
				       _serie
		          FROM reacomae
		         WHERE cod_contrato = _cod_contrato;


				SELECT vigencia_inic 
				  INTO _dt_vig_inic
				  FROM endedmae 
				 WHERE no_poliza  = _no_poliza
				   AND no_endoso = '00000' 
				   AND actualizado = 1; 

			   FOREACH
			    SELECT serie 
				  INTO _serie1 
			      FROM reacomae 
				 WHERE tipo_contrato = v_tipo_contrato 
				   AND _dt_vig_inic BETWEEN vigencia_inic AND vigencia_final
				 order by serie desc
				  exit foreach;
				   end foreach

					if _serie1 is not null or _serie1 <> 0 then
					   LET _serie = _serie1;	
				   end if
				   
		END FOREACH					

			IF _es_terremoto = 0 THEN
				let _orden = sp_sis184(_cod_ubica);
				BEGIN
					ON EXCEPTION IN(-239)
						UPDATE temp_ubica			   
						   SET suma_asegurada   = suma_asegurada   + _suma,
							   mal_porc         = _mal_porc,
							   retencion        = retencion        + _suma_retencion,
							   cant_ret			= _cant_ret,
							   primer_excedente = primer_excedente + _suma_excedente,
							   cant_exe			= _cant_exe,
							   facultativo      = facultativo	   + _suma_facultativo,
							   cant_fac			= _cant_fac
							  -- prima_terremoto  = prima_terremoto  + _prima 
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;	
					END EXCEPTION
					INSERT INTO temp_ubica
					   VALUES(_cod_ubica,
							  _cod_ramo,
							  _cod_subramo,
							  _cod_contratante,
							  _no_poliza,
							  v_vigencia_final,
							  v_nodocumento,
							  1,
							  _suma,  
							  _mal_porc,
							  _suma_retencion,
							  _cant_ret,
							  _suma_excedente,
							  _cant_exe,
							  _suma_facultativo,
							  _cant_fac,
							  _prima_cobrada_uni, --_prima_cobrada,
							  _tipo_incendio,
							  _orden,
							  _no_unidad,
							   0, --);
							  _serie,
                              _cod_contrato,
				              _desc_contrato,
                              _cod_cobertura,1);
				END
				BEGIN
					ON EXCEPTION IN(-239)
					END EXCEPTION

					INSERT INTO temp_unidad(
							no_poliza,							
							no_unidad,
							tipo_incendio,
							cod_manzana,
							referencia,
							nombre_barrio)
					SELECT	_no_poliza,
							endeduni.no_unidad,
							emipouni.tipo_incendio,
							emipouni.cod_manzana,
							emiman05.referencia AS referencia,
							(SELECT emiman04.nombre
							   FROM	emiman04
							  WHERE	(emiman04.cod_provincia = emiman05.cod_provincia )
								AND	( emiman04.cod_distrito = emiman05.cod_distrito )
								AND 	( emiman04.cod_correg = emiman05.cod_correg )
								AND	( emiman04.cod_barrio = emiman05.cod_barrio )  ) AS nombre_barrio
					  FROM emipouni LEFT OUTER JOIN emiman05 ON emipouni.cod_manzana = emiman05.cod_manzana, emipomae, endeduni
					 WHERE emipomae.no_poliza = endeduni.no_poliza
					   --and emiman05.cod_barrio in ('0103','4400')
					   --AND emipomae.vigencia_final >= a_fecha --OR emipomae.vigencia_final IS NULL
					   AND emipomae.fecha_suscripcion <= a_fecha
					   AND emipomae.vigencia_inic < a_fecha
					   and emipouni.no_poliza = endeduni.no_poliza
					   and emipouni.no_unidad = endeduni.no_unidad					   
					   and emipomae.no_documento = v_nodocumento
					   and emipouni.cod_manzana is not null and emiman05.referencia is not null
					   --AND endeduni.no_poliza = _no_poliza and endeduni.no_endoso in ('00000', _no_endoso) 
					   and endeduni.no_unidad = _no_unidad
					   and emipomae.actualizado = 1
					   order by endeduni.no_endoso desc;			
							 
					   
				END
				
			END IF
		 END FOREACH
		END IF 
	END FOREACH
END FOREACH

if  _documento = v_nodocumento then
	if _documento <> '' then
		update temp_ubica			   
		   set suma_aseg_total =_suma_aseg_total 
		 where no_documento = _documento;
	 end if		
	let _suma_aseg_total = 0.00;
	let _documento = v_nodocumento;
end if	

--DELETE FROM temp_ubica WHERE cod_ubica NOT IN (SELECT cod_ubica FROM tmp_emiubik);

return 0, 'Tabla temporal exitosa ';
end



END PROCEDURE;
