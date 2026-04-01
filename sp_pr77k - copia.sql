-- Cumulos por Ubicacion
-- 
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 23/04/2002 - Autor: Amado Perez - Se cambia para que lea de la tabla de "endcuend"
-- 
--
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_pro77k;

CREATE PROCEDURE "informix".sp_pro77k(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_fecha2 DATE) 
returning   char(50) as ubicacion,  -- ubicacion
            integer as cnt_poliza,       -- cnt. poliza
			dec(16,2) as suma_asegurada, -- suma asegurada
			dec(16,2) as retencion, -- retencion ancon
			integer as cnt_ret,
			dec(16,2) as excedente, -- 1er excedente
			integer as cnt_exc,
			dec(16,2) as facultativo, -- facultativo
			integer as cnt_fac,
			dec(16,2) as prima, -- prima suscrita terremoto
			char(50) as cia,  -- compania
			smallint as tipo,
			char(20) as poliza,  -- documento
			char(5) as unidad,   -- unidad
			date as vigencia_inic,      -- vigencia_inic		
			date as vigencia_final,      -- vigencia_final		
			CHAR(10) as no_poliza,  -- poliza
			CHAR(50) as tipo_incendio;  -- tipo incendio			
			
--			CHAR(255); -- Filtros

DEFINE v_filtros           		CHAR(255);
DEFINE v_ubicacion         		CHAR(50);
DEFINE v_cnt_poliza        		INT; 
DEFINE v_suma_asegurada    		DEC(16,2);
DEFINE v_retencion         		DEC(16,2);
DEFINE v_excedente         		DEC(16,2);
DEFINE v_facultativo       		DEC(16,2);
DEFINE v_prima			   		DEC(16,2);
DEFINE v_compania_nombre   		CHAR(50);
DEFINE v_nodocumento       		CHAR(20);
define _documento	     	    char(20);
DEFINE _no_poliza          		CHAR(10);
DEFINE _no_unidad, _no_endoso	CHAR(5);
DEFINE _cod_ubica          		CHAR(3);
DEFINE _suma     		   		DEC(16,2);
DEFINE _prima    		   		DEC(16,2);
DEFINE _suma_retencion     		DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   		DEC(16,2);
DEFINE _suma_excedente     		DEC(16,2);
DEFINE _porc_partic_suma   		DEC(9,6);
DEFINE _porcentaje		   		DEC(9,6);
DEFINE _tipo_contrato      		SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   		CHAR(5);
DEFINE _mes_contable      		CHAR(2);
DEFINE _ano_contable      		CHAR(4);
DEFINE _periodo           		CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;
define _tipo_incendio           smallint;
define _orden                   smallint;
DEFINE _prima_cobrada      DEC(16,2);
define _f_emision_unidad    date;
DEFINE _cod_endomov        		CHAR(3);

define _prima_porcion       dec(16,2);
define _prima_cobrada_uni   dec(16,2);
define _suma_aseg_total     dec(16,2);
define _prima_unidad        dec(16,2);
define _cod_cober_reas		char(3);
define _vigencia_final		date;
define _vigencia_inic		date;
define v_tipo CHAR(50);


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  no_poliza        CHAR(10),
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
		  --no_endoso        char(5),
		  suma_aseg_total     dec(16,2),		  
PRIMARY KEY (no_poliza, no_unidad))		  
WITH NO LOG;
--          PRIMARY KEY (no_poliza, no_unidad, no_endoso))
          --WITH NO LOG;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

LET _ano_contable = YEAR(a_fecha);

{IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;}
let _periodo = sp_sis39(a_fecha);
let _documento = '';

--set debug file to "sp_pro77k.trc"; 
--trace on;
FOREACH
   SELECT d.no_poliza, e.no_endoso, d.no_documento, d.fecha_cancelacion
     INTO _no_poliza, _no_endoso, v_nodocumento, _fecha_cancelacion
     FROM emipomae d, endedmae e
    WHERE d.cod_compania = a_compania
	  AND e.no_poliza = d.no_poliza
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha  OR d.vigencia_final IS NULL)
      AND d.fecha_suscripcion <= a_fecha
	  --AND e.fecha_emision <= a_fecha	  
	  AND d.vigencia_inic < a_fecha
	  --AND e.periodo <= _periodo	  
      AND d.actualizado = 1	  
	  AND e.actualizado = 1
          --and d.no_documento = '0106-00523-01 ' --0116-00395-01'	  
order by d.no_documento,d.no_poliza,e.no_endoso	  

      LET _fecha_emision = null;

      IF _fecha_cancelacion <= a_fecha THEN 
	     FOREACH
			SELECT fecha_emision
			  INTO _fecha_emision
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			   AND cod_endomov = '002'
			   AND vigencia_inic = _fecha_cancelacion
		 END FOREACH

		 IF  _fecha_emision <= a_fecha THEN
			CONTINUE FOREACH;
		 END IF
	  END IF

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
	 --trace on; 
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
		
--trace on;
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
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso
			and no_unidad = _no_unidad 	
			
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
			
			if  _tipo_incendio is null then
				let _tipo_incendio = 0;
			end if
		end if							

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 0;		
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


		foreach
			select x.porc_partic_suma,
				   y.tipo_contrato,
				   z.es_terremoto,
				   x.cod_cober_reas
			  into _porc_partic_suma,
				   _tipo_contrato,
				   _es_terremoto,
				   _cod_cober_reas
			  from emireaco x, reacomae y, reacobre z
			 where x.no_poliza = _no_poliza
			   and x.no_unidad = _no_unidad
			   and x.no_cambio = _no_cambio
			   and y.cod_contrato = x.cod_contrato
			   and z.cod_cober_reas = x.cod_cober_reas
			   and z.es_terremoto = 1

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
			   LET _mal_porc = '';
			END IF
			
			let _prima_porcion = 0.00;
			let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
			let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;

			if _prima_cobrada_uni is null then
				let _prima_cobrada_uni = 0;
			end if			
			
		END FOREACH


		IF _es_terremoto = 1 THEN

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
						   --prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza
					   AND no_unidad = _no_unidad;
					   --AND no_endoso = _no_endoso;
					   
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
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
						  _prima_cobrada_uni,   --_prima_cobrada,
						  _tipo_incendio,
						  _orden,
						  _no_unidad,
						  --_no_endoso,
						  0);
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
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso
			and no_unidad = _no_unidad 					
			
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
			if  _tipo_incendio is null then
				let _tipo_incendio = 0;
			end if			
		end if								

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 1;

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


		foreach
			select x.porc_partic_suma,
				   y.tipo_contrato,
				   z.es_terremoto,
				   x.cod_cober_reas
			  into _porc_partic_suma,
				   _tipo_contrato,
				   _es_terremoto,
				   _cod_cober_reas
			  from emireaco x, reacomae y, reacobre z
			 where y.cod_contrato = x.cod_contrato
			   and x.no_poliza = _no_poliza
			   and x.no_unidad = _no_unidad
			   and x.no_cambio = _no_cambio
			   and z.cod_cober_reas = x.cod_cober_reas
			   and z.es_terremoto = 0

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
			   LET _mal_porc = '';
			END IF
			
			let _prima_porcion = 0.00;
			let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
			let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;
		   
			if _prima_cobrada_uni is null then
				let _prima_cobrada_uni = 0;
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
						   --prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza
					   AND no_unidad = _no_unidad;
					   --AND no_endoso = _no_endoso;
					   
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
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
						  _prima_cobrada_uni,   --_prima_cobrada,	--anterior  _prima,
						  _tipo_incendio,
						  _orden,
						  _no_unidad,
						  --_no_endoso,
						  0);
				END
			END IF
		 END FOREACH
		END IF 
	END FOREACH			
END FOREACH
--trace off;
--SET DEBUG FILE TO "sp_pro77.trc";   
--TRACE ON;
if  _documento = v_nodocumento then
	if _documento <> '' then
		update temp_ubica			   
		   set suma_aseg_total =_suma_aseg_total 
		 where no_documento = _documento;
	 end if		
	let _suma_aseg_total = 0.00;
	let _documento = v_nodocumento;
end if

FOREACH WITH HOLD

{	  SELECT cod_ubica,
	  		 tipo_incendio,
			 orden,
			 SUM(cantidad),        
			 SUM(suma_asegurada),  
			 SUM(retencion), 
			 SUM(cant_ret),      
			 SUM(primer_excedente),
			 SUM(cant_exe),
			 SUM(facultativo),
			 SUM(cant_fac),     
			 SUM(prima_terremoto)
		INTO _cod_ubica,
			 _tipo_incendio,
			 _orden,
			 v_cnt_poliza,     
			 v_suma_asegurada, 
			 v_retencion,  
			 _cant_ret,
			 v_excedente,
			 _cant_exe,      
		     v_facultativo,    
			 _cant_fac,
			 v_prima  }
			 
select no_documento,
	       no_unidad,
	       cod_ubica,
	  	   tipo_incendio,		   
		   orden,
		   cantidad,
		   suma_asegurada,
		   retencion,
		   cant_ret,
		   primer_excedente,
		   cant_exe,
		   facultativo,
		   cant_fac,
		   prima_terremoto,
		   suma_aseg_total,
		   no_poliza
	  into v_nodocumento,
	       _no_unidad,
	       _cod_ubica,
		    _tipo_incendio,
		   _orden,
		   v_cnt_poliza,
		   v_suma_asegurada,
		   v_retencion,
		   _cant_ret,
		   v_excedente,
		   _cant_exe,
		   v_facultativo,
		   _cant_fac,
		   v_prima,
		   _suma_aseg_total,
		   _no_poliza
	   FROM temp_ubica
	  -- GROUP BY cod_ubica, tipo_incendio, orden
	  order by orden,tipo_incendio,no_documento,no_unidad
	  
	  select vigencia_inic, vigencia_final
	    into _vigencia_inic, _vigencia_final
	    from emipomae
       where no_poliza = _no_poliza;

	  SELECT nombre
		INTO v_ubicacion
		FROM emiubica
	   WHERE cod_ubica = _cod_ubica;
	   
	 if _suma_aseg_total = 0 then
		let _prima_unidad = v_prima;
	else
	    let _prima_unidad = (v_suma_asegurada/_suma_aseg_total) * v_prima;
	end if	         
	
	if _tipo_incendio is null or _tipo_incendio in (0) then
		let v_tipo = 'POR ASIGNAR';		
	elif _tipo_incendio in (1) then
		let v_tipo = 'EDIFICIO';	
	elif _tipo_incendio in (2) then
		let v_tipo = 'CONTENIDO';	
	elif _tipo_incendio in (3) then
		let v_tipo = 'LUCRO CESANTE';	
	elif _tipo_incendio in (4) then
		let v_tipo = 'PERDIDA DE RENTA';  
	end if

	RETURN v_ubicacion,
		   v_cnt_poliza,    	
		   v_suma_asegurada/1000,	
		   v_retencion/1000,  	
		   _cant_ret,	
		   v_excedente/1000,	
		   _cant_exe,      	
		   v_facultativo/1000,   	
		   _cant_fac,	
		   _prima_unidad,	 --v_prima,	
		   v_compania_nombre,
		   _tipo_incendio,	
           v_nodocumento,
	       _no_unidad,
           _vigencia_inic,
		   _vigencia_final,
		   _no_poliza,
           v_tipo		   with resume;

END FOREACH					 

drop table if exists temp_ubica;
drop table if exists tmp_dist_rea;
END PROCEDURE 