-- Reportes de Reaseguro
-- Creado: 15/11/2011 - Autor: Henry Girón
drop procedure sp_proe58;
create procedure "informix".sp_proe58(a_compania CHAR(03), a_fecha DATE,a_cod_manzana char(255) DEFAULT '*', a_poliza char(20) DEFAULT '*', a_estatus_poliza smallint,a_agente char(255) DEFAULT '*',a_grupo char(255) DEFAULT '*')
returning   char(10),		--no_poliza
			char(5),		--no_unidad
			char(20),		--no_documento
			char(100),  	--asegurado
			char(15),		--cod_manzana
			char(50),		--referencia
			char(3),		--sucursal_origen
			char(30),   	--nombre suc origen
			decimal(16,2),	--suma asegurada
			smallint,		--tipo_incendio
			date,			--vig ini
			date,	    	--vig fin
			decimal(16,2),	--suma asegurada
			smallint,		--estauts poliza
			char(100),      --agentes poliza
			decimal(16,2),	--tot_facultativo
			decimal(16,2),	--tot_excedente
			decimal(9,4),	--Porc_retencion
			decimal(9,4),	--Porc_excedente
			decimal(9,4);	--Porc_facultativo


define _no_poliza		  char(10);
define _contratante	      char(10);
define _no_unidad		  char(5);
define _fecha       	  date;
define v_asegurado		  char(100);
define _no_documento      char(20);
define v_filtros          char(255);
define _cod_manzana		  char(15);
define _suc_origen		  char(3);
define _n_suc_origen	  char(30);
define _referencia        char(50);
define _suma_asegurada    dec(16,2);
define _suma			  dec(16,2);
define _suma_ret		  dec(16,2);
define _ret_porc		  dec(9,4);
define _suma_fac		  dec(16,2);
define _fac_porc		  dec(9,4);
define _suma_exc		  dec(16,2);
define _exc_porc		  dec(9,4);
define _actualizado       smallint;
define _tipo_incendio     smallint;
define _vig_ini           date;
define _vig_fin           date;
define _cod_ramo          char(3);
define v_cod_contrato     char(5);
define v_tipo_contrato    smallint;
define _est_pol			  smallint;
define _nombre_ag		  char(255);
define _nombre_ag_acum	  char(255);
define _cod_cober_reas	  char(3);
define _porc_partic_suma  dec(9,4);
define _no_cambio	      smallint;
DEFINE v_compania_nombre  char(50);

DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision      DATE;
DEFINE _fecha_cancelacion  DATE;
DEFINE _cod_contratante    CHAR(10);
DEFINE _no_endoso 		   CHAR(5);
DEFINE _cod_ubica		   CHAR(3);
DEFINE _suma_terremoto     DEC(16,2);
DEFINE _prima_terremoto    DEC(16,2);
DEFINE _suma_incendio      DEC(16,2);
DEFINE _prima_incendio     DEC(16,2); 
DEFINE _cod_agente 		   CHAR(5);
DEFINE _porc_partic_agt    DEC(16,2);
DEFINE _porc_comis_agt     DEC(16,2); 
DEFINE _grupo   		   CHAR(5);
DEFINE _tipo    		   CHAR(3);
DEFINE _suma_otros         DEC(16,2);
DEFINE _otros_porc         DEC(16,2); 
DEFINE _prima_ter_ret      DEC(16,2);
DEFINE _prima_inc_ret      DEC(16,2); 
DEFINE _prima_ter_fac      DEC(16,2);
DEFINE _prima_inc_fac      DEC(16,2); 
DEFINE _prima_ter_otros    DEC(16,2);
DEFINE _prima_inc_otros    DEC(16,2); 
DEFINE _prima_suscrita     DEC(16,2);
DEFINE u_tipo_asegurado    CHAR(50);                   
DEFINE u_referencia        CHAR(50);                   
DEFINE v_ubicacion         CHAR(50);                   
DEFINE v_desc_grupo        CHAR(50);                   
DEFINE u_tipo_incendio     INTEGER;	 

CREATE TEMP TABLE temp_ubica(
		COMPANIA			   CHAR(3),
		GRUPO				   CHAR(5),
		NOMBRE_GRUPO	       CHAR(50),
		RAMO				   CHAR(3),
		DESDE				   DATE,
		HASTA				   DATE,
		ESTATUS				   SMALLINT,
		POLIZA				   CHAR(20),
		UNIDAD				   CHAR(5),
		ASEGURADO			   CHAR(10),
		NOMBRE_ASEGURADO	   CHAR(50),
		UBICACION			   CHAR(3),
		NOMBRE_UBICACION	   CHAR(50),
		MANZANA				   CHAR(15),
		NOMBRE_MANZANA		   CHAR(50),
		CORREDOR			   CHAR(5),
		NOMBRE_CORREDOR		   CHAR(50),
		PORC_COMISION		   DEC(16,2),
		TIPO				   CHAR(15),
		SUMA_ASEGURADA		   DEC(16,2),
		RETENCION			   DEC(16,2),
		CONTRATOS			   DEC(16,2),
		FACULTATIVO			   DEC(16,2),
		TOTAL_PRIMA_SUSCRITA   DEC(16,2), 
		PRIMA_INC			   DEC(16,2),	
		INC_RETENCION  		   DEC(16,2),	
		INC_CONTRATOS  		   DEC(16,2),	
		INC_FACULTATIVO		   DEC(16,2),	
		PRIMA_TERREMOTO	   	   DEC(16,2),	
		TER_RETENCION		   DEC(16,2),	
		TER_CONTRATOS		   DEC(16,2),	
		TER_FACULTATIVO		   DEC(16,2),	
        PRIMARY KEY (POLIZA,UNIDAD,CORREDOR))
        WITH NO LOG;

SET ISOLATION TO DIRTY READ;
SET DEBUG FILE TO "sp_pr99b.trc";
trace on; 

let _fecha = CURRENT;
let _suma_asegurada = 0;
let _suma_ret       = 0;
LET  v_compania_nombre = sp_sis01(a_compania); 
LET _tipo = '000';
LET _ano_contable = YEAR(a_fecha);
IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF
LET _periodo = _ano_contable || '-' || _mes_contable;


if a_poliza = '*' then 
   if a_cod_manzana	<> '' and a_cod_manzana <> "*" Then
	if a_estatus_poliza <> 4 then
	   FOREACH WITH HOLD
				select no_unidad,
					   emipouni.no_poliza,
					   emipouni.suma_asegurada,
					   cod_asegurado,
					   tipo_incendio,
					   cod_manzana 
				 into  _no_unidad,
					   _no_poliza,
					   _suma_asegurada,
					   _contratante,
					   _tipo_incendio,
					   _cod_manzana
				 from emipouni,
					  emipomae
				where emipouni.cod_manzana LIKE TRIM(a_cod_manzana) || "%"
				  and emipouni.no_poliza = emipomae.no_poliza
				  and emipomae.estatus_poliza = a_estatus_poliza
				  and (emipouni.cod_manzana <> '' and emipouni.cod_manzana is not null)
				order by emipouni.cod_manzana, emipouni.no_poliza, emipouni.no_unidad

	   		SELECT nombre
	     	 INTO  v_asegurado
	     	 FROM  cliclien
	    	 WHERE cod_cliente = _contratante;

			SELECT sucursal_origen,
			       no_documento,
			  	   actualizado,
				   vigencia_inic,
				   vigencia_final,
				   cod_ramo,
				   estatus_poliza
			  INTO _suc_origen,
			       _no_documento,
			  	   _actualizado,
				   _vig_ini,
				   _vig_fin,
				   _cod_ramo,
				   _est_pol
			  FROM emipomae
		     WHERE no_poliza      = _no_poliza
			   and estatus_poliza = a_estatus_poliza;

		   	if _cod_ramo not in ("001", "003") then
			   continue foreach;
		    end if

		   	if _actualizado = 0 then
			   continue foreach;
		    end if

		    SELECT descripcion
		     INTO  _n_suc_origen
		     FROM  insagen
		     WHERE codigo_compania = "001"
		     AND   codigo_agencia  = _suc_origen;

	   		SELECT referencia
	     	  INTO _referencia
	          FROM emiman05
	         WHERE cod_manzana = _cod_manzana;

			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;

			let _no_cambio = null;

			if _cod_ramo in ("001") then
				let _cod_cober_reas = "001";
			else
				let _cod_cober_reas = "003";
			end if

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			FOREACH

				 SELECT cod_contrato,
				        porc_partic_suma
				   INTO v_cod_contrato,
				        _porc_partic_suma
				   FROM emireaco
				  WHERE no_poliza      = _no_poliza
				    AND no_unidad      = _no_unidad
				    AND no_cambio      = _no_cambio
					AND cod_cober_reas = _cod_cober_reas

			      SELECT tipo_contrato
			        INTO v_tipo_contrato
			        FROM reacomae
			       WHERE cod_contrato = v_cod_contrato;

				  IF _porc_partic_suma IS NULL THEN
				  	  LET _porc_partic_suma = 0;
				  END IF

				  IF _suma_asegurada IS NULL THEN
				  	  LET _suma_asegurada = 0;
				  END IF

			      IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
				  	let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
				  	let _ret_porc = _porc_partic_suma;
				  end if

			      IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
				  	let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
				  	let _fac_porc = _porc_partic_suma;
				  end if

			      IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
				  	let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
				  	let _exc_porc = _porc_partic_suma;
				  end if

		   END FOREACH		

			--AGENTES DE LA POLIZA
			LET _nombre_ag = "";
			LET _nombre_ag_acum = "";

			FOREACH
				  SELECT TRIM(agtagent.nombre)
					INTO _nombre_ag
					FROM agtagent,   
						emipoagt 
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and  
						  ( emipoagt.no_poliza = _no_poliza )  

				LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;

			END FOREACH

	   		RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia, _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,
	   		       _vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc  WITH RESUME;

	   END FOREACH
	 
	else --TODOS LOS ESTATUS
		   FOREACH WITH HOLD
				select no_unidad,
					   emipouni.no_poliza,
					   emipouni.suma_asegurada,
					   cod_asegurado,
					   tipo_incendio,
					   cod_manzana 
				 into  _no_unidad,
					   _no_poliza,
					   _suma_asegurada,
					   _contratante,
					   _tipo_incendio,
					   _cod_manzana
				 from emipouni,
					  emipomae
				where cod_manzana LIKE TRIM(a_cod_manzana) || "%"
				  and emipouni.no_poliza = emipomae.no_poliza
				  and   (cod_manzana <> ''  and cod_manzana is not null)
				order by cod_manzana, no_poliza, no_unidad

	   		SELECT nombre
	     	 INTO  v_asegurado
	     	 FROM  cliclien
	    	 WHERE cod_cliente = _contratante;

			SELECT sucursal_origen,
			       no_documento,
			  	   actualizado,
				   vigencia_inic,
				   vigencia_final,
				   cod_ramo,
				   estatus_poliza
			  INTO _suc_origen,
			       _no_documento,
			  	   _actualizado,
				   _vig_ini,
				   _vig_fin,
				   _cod_ramo,
				   _est_pol
			  FROM emipomae
			  WHERE no_poliza = _no_poliza ;

		   	if _cod_ramo not in ("001", "003") then
			   continue foreach;
		    end if

		   	if _actualizado = 0 then
			   continue foreach;
		    end if

		    SELECT descripcion
		     INTO  _n_suc_origen
		     FROM  insagen
		     WHERE codigo_compania = "001"
		     AND   codigo_agencia  = _suc_origen;

	   		SELECT referencia
	     	  INTO _referencia
	          FROM emiman05
	         WHERE cod_manzana = _cod_manzana;

			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;

			let _no_cambio = null;

			if _cod_ramo in ("001") then
				let _cod_cober_reas = "001";
			else
				let _cod_cober_reas = "003";
			end if

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			FOREACH
			 SELECT cod_contrato,porc_partic_suma
			   INTO v_cod_contrato,_porc_partic_suma
			   FROM emireaco
			  WHERE no_poliza      = _no_poliza
			    AND no_unidad      = _no_unidad
			    AND no_cambio      = _no_cambio
				AND cod_cober_reas = _cod_cober_reas

		       SELECT tipo_contrato
		         INTO v_tipo_contrato
		         FROM reacomae
		        WHERE cod_contrato = v_cod_contrato;

			   	   IF _porc_partic_suma IS NULL THEN
			   		  LET _porc_partic_suma = 0;
			   	  END IF

			   	   IF _suma_asegurada IS NULL THEN
			   		  LET _suma_asegurada = 0;
			   	  END IF

		       IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
					let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
					let _ret_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
					let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
					let _fac_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
					let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
					let _exc_porc = _porc_partic_suma;
			   end if

		   END FOREACH

			--AGENTES DE LA POLIZA
			LET _nombre_ag = "";
			LET _nombre_ag_acum = "";

			FOREACH
				  SELECT TRIM(agtagent.nombre)
					INTO _nombre_ag
					FROM agtagent,   
						emipoagt 
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and  
						  ( emipoagt.no_poliza = _no_poliza )  

				LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;
			END FOREACH

	   		RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,
	          	   _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,_vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc  WITH RESUME;

	   END FOREACH

	end if

   else 
	  LET a_cod_manzana = '*';

	  if a_estatus_poliza <> 4 then

	   FOREACH WITH HOLD
	   		select no_unidad,
		           emipouni.no_poliza,
				   emipouni.suma_asegurada,
				   cod_asegurado,
				   tipo_incendio,
				   cod_manzana
		     into  _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _contratante,
				   _tipo_incendio,
				   _cod_manzana
			 from emipouni,
				  emipomae
			 where emipouni.no_poliza = emipomae.no_poliza
			  and emipomae.estatus_poliza = a_estatus_poliza
			 and   (cod_manzana <> ''  OR cod_manzana is not null)
			 order by no_poliza, no_unidad

	   		SELECT nombre
	     	 INTO  v_asegurado
	     	 FROM  cliclien
	    	 WHERE cod_cliente = _contratante;

			SELECT sucursal_origen,
			       no_documento,
			  	   actualizado,
				   vigencia_inic,
				   vigencia_final, 
				   cod_ramo,
				   estatus_poliza
			  INTO _suc_origen,
			       _no_documento,
			  	   _actualizado,
				   _vig_ini,
				   _vig_fin,
				   _cod_ramo,
				   _est_pol
			  FROM  emipomae
			  WHERE no_poliza = _no_poliza
			   and estatus_poliza = a_estatus_poliza;

		   	if _cod_ramo not in ("001", "003") then
			   continue foreach;
		    end if

		   	if _actualizado = 0 then
			   continue foreach;
		    end if

		    SELECT descripcion
		     INTO  _n_suc_origen
		     FROM  insagen
		     WHERE codigo_compania = "001"
		     AND   codigo_agencia  = _suc_origen;

	   		SELECT referencia
	     	 INTO  _referencia
	         FROM  emiman05
	         WHERE cod_manzana = _cod_manzana;

			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;
			let _no_cambio = null;

			if _cod_ramo in ("001") then
				let _cod_cober_reas = "001";
			else
				let _cod_cober_reas = "003";
			end if

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			FOREACH
			 SELECT cod_contrato,porc_partic_suma
			   INTO v_cod_contrato,_porc_partic_suma
			   FROM emireaco
			  WHERE no_poliza      = _no_poliza
			    AND no_unidad      = _no_unidad
			    AND no_cambio      = _no_cambio
				AND cod_cober_reas = _cod_cober_reas

		       SELECT tipo_contrato
		         INTO v_tipo_contrato
		         FROM reacomae
		        WHERE cod_contrato = v_cod_contrato;

			   	   IF _porc_partic_suma IS NULL THEN
			   		  LET _porc_partic_suma = 0;
			   	  END IF

			   	   IF _suma_asegurada IS NULL THEN
			   		  LET _suma_asegurada = 0;
			   	  END IF

		       IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
					let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
					let _ret_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
					let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
					let _fac_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
					let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
					let _exc_porc = _porc_partic_suma;
			   end if

		   END FOREACH


			--AGENTES DE LA POLIZA
			LET _nombre_ag = "";
			LET _nombre_ag_acum = "";

			FOREACH
				  SELECT TRIM(agtagent.nombre)
					INTO _nombre_ag
					FROM agtagent,   
						emipoagt 
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and  
						  ( emipoagt.no_poliza = _no_poliza )  

				LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;

			END FOREACH

	   		RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,
	          	   _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,_vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc  WITH RESUME;

	   END FOREACH

	   else --TODOS LOS ESTATUS
			   FOREACH WITH HOLD
				select no_unidad,
					   emipouni.no_poliza,
					   emipouni.suma_asegurada,
					   cod_asegurado,
					   tipo_incendio,
					   cod_manzana
				 into  _no_unidad,
					   _no_poliza,
					   _suma_asegurada,
					   _contratante,
					   _tipo_incendio,
					   _cod_manzana
				 from emipouni,
					emipomae
				 where emipouni.no_poliza = emipomae.no_poliza
				  and   (cod_manzana <> ''  OR cod_manzana is not null)
				 order by no_poliza, no_unidad

				SELECT nombre
				 INTO  v_asegurado
				 FROM  cliclien
				 WHERE cod_cliente = _contratante;

				SELECT sucursal_origen,
					   no_documento,
					   actualizado,
					   vigencia_inic,
					   vigencia_final,
					   cod_ramo,
					   estatus_poliza
				  INTO _suc_origen,
					   _no_documento,
					   _actualizado,
					   _vig_ini,
					   _vig_fin,
					   _cod_ramo,
					   _est_pol
				  FROM  emipomae
				  WHERE no_poliza = _no_poliza;

				if _cod_ramo not in ("001", "003") then
				   continue foreach;
				end if

				if _actualizado = 0 then
				   continue foreach;
				end if

				SELECT descripcion
				 INTO  _n_suc_origen
				 FROM  insagen
				 WHERE codigo_compania = "001"
				 AND   codigo_agencia  = _suc_origen;

				SELECT referencia
				 INTO  _referencia
				 FROM  emiman05
				 WHERE cod_manzana = _cod_manzana;

				let _suma_ret = 0;
				let _ret_porc = 0;
				let _suma_fac = 0;
				let _fac_porc = 0;
				let _suma_exc = 0;
				let	_exc_porc = 0;
				let _cod_cober_reas	= null; 
				let	_porc_partic_suma = 0;

				let _no_cambio = null;

				if _cod_ramo in ("001") then
					let _cod_cober_reas = "001";
				else
					let _cod_cober_reas = "003";
				end if

			   	SELECT max(no_cambio)
				  INTO _no_cambio
				  FROM emireama
				 WHERE no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and cod_cober_reas = _cod_cober_reas;

				FOREACH
				 SELECT cod_contrato,porc_partic_suma
				   INTO v_cod_contrato,_porc_partic_suma
				   FROM emireaco
				  WHERE no_poliza      = _no_poliza
				    AND no_unidad      = _no_unidad
				    AND no_cambio      = _no_cambio
					AND cod_cober_reas = _cod_cober_reas

			       SELECT tipo_contrato
			         INTO v_tipo_contrato
			         FROM reacomae
			        WHERE cod_contrato = v_cod_contrato;

				   	   IF _porc_partic_suma IS NULL THEN
				   		  LET _porc_partic_suma = 0;
				   	  END IF

				   	   IF _suma_asegurada IS NULL THEN
				   		  LET _suma_asegurada = 0;
				   	  END IF

			       IF v_tipo_contrato = 1 and _ret_porc = 0 THEN
						let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
						let _ret_porc = _porc_partic_suma;
				   end if
			       IF v_tipo_contrato = 3 and _fac_porc = 0 THEN
						let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
						let _fac_porc = _porc_partic_suma;
				   end if
			       IF v_tipo_contrato = 7 and _exc_porc = 0 THEN
						let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
						let _exc_porc = _porc_partic_suma;
				   end if

			   END FOREACH


				--AGENTES DE LA POLIZA
				LET _nombre_ag = "";
				LET _nombre_ag_acum = "";

				FOREACH
					  SELECT TRIM(agtagent.nombre)
						INTO _nombre_ag
						FROM agtagent,   
							emipoagt 
						WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) and  
							  ( emipoagt.no_poliza = _no_poliza )  
					
					LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;
					
				END FOREACH

				RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,
					   _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,_vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc  WITH RESUME;

		   END FOREACH
	   end if


   End if

else
-- [HENRY] **** Inicia cambios ****
--let _no_poliza = sp_sis21(a_poliza);

FOREACH WITH HOLD
   select d.sucursal_origen,
          d.no_documento,
		  d.actualizado,
		  d.vigencia_inic,
		  d.vigencia_final,
		  d.cod_ramo,
		  d.estatus_poliza,
		  d.no_poliza,
		  e.no_endoso,
		  d.fecha_cancelacion,
		  d.cod_contratante,
		  d.cod_grupo  
     into _suc_origen,
	      _no_documento,
		  _actualizado,
		  _vig_ini,
		  _vig_fin, 
		  _cod_ramo,
		  _est_pol,
		  _no_poliza,
		  _no_endoso,
		  _fecha_cancelacion,
		  _cod_contratante,
		  _grupo
--     from emipomae d
--    where d.no_poliza = _no_poliza
     FROM emipomae d, endedmae e
    WHERE d.cod_compania = a_compania
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha
	   OR d.vigencia_final IS NULL)
      AND d.fecha_suscripcion <= a_fecha
	  AND d.vigencia_inic < a_fecha
      AND d.actualizado = 1
	  AND e.no_poliza = d.no_poliza
	  AND e.periodo <= _periodo
	  AND e.fecha_emision <= a_fecha
      AND e.actualizado = 1
	  AND trim(d.no_documento) = trim(a_poliza)

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

   if _cod_ramo not in ("001", "003") then
      continue foreach;
   end if

   if _actualizado = 0 then
	  continue foreach;
   end if

   SELECT descripcion
     INTO _n_suc_origen
     FROM insagen
    WHERE codigo_compania = "001"
     AND codigo_agencia  = _suc_origen;

	foreach
	 SELECT	cod_ubica, 
	        no_unidad,
			suma_terremoto, 
			prima_terremoto, 
			suma_incendio, 
			prima_incendio 
	   INTO _cod_ubica, 
	        _no_unidad,
			_suma_terremoto, 
			_prima_terremoto, 
			_suma_incendio, 
			_prima_incendio
	   FROM	endcuend
	  WHERE no_poliza = _no_poliza
		AND no_endoso = _no_endoso

	   select suma_asegurada,
			  cod_asegurado,
			  tipo_incendio,
			  cod_manzana,
			  prima_suscrita
	     into _suma_asegurada,
			  _contratante,
			  _tipo_incendio,
			  _cod_manzana,
			  _prima_suscrita
		 from emipouni
		where no_poliza = _no_poliza
		  and no_unidad = _no_unidad;
--		order by no_poliza, no_unidad;

		if _cod_manzana[1,12] not in ('030010020103','030010064400') then
			continue foreach;
		end if

	   SELECT nombre
	     INTO v_asegurado
	     FROM cliclien
	    WHERE cod_cliente = _contratante;

	   SELECT referencia
	     INTO _referencia
	     FROM emiman05
	    WHERE cod_manzana = _cod_manzana;

			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;
			let _suma_otros = 0;
			let _otros_porc = 0;
			let _suma_asegurada = _suma_incendio;
			let _prima_ter_ret   = 0;
			let _prima_inc_ret   = 0;
			let	_prima_ter_fac   = 0;
			let _prima_inc_fac   = 0;
			let	_prima_ter_otros = 0;
			let _prima_inc_otros = 0;
			let _tipo = '000';

			let _no_cambio = null;

			if _cod_ramo in ("001") then
				let _cod_cober_reas = "001";
			else
				let _cod_cober_reas = "003";
			end if

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			FOREACH
			 SELECT cod_contrato,porc_partic_suma
			   INTO v_cod_contrato,_porc_partic_suma
			   FROM emireaco
			  WHERE no_poliza      = _no_poliza
			    AND no_unidad      = _no_unidad
			    AND no_cambio      = _no_cambio
				AND cod_cober_reas = _cod_cober_reas

		       SELECT tipo_contrato
		         INTO v_tipo_contrato
		         FROM reacomae
		        WHERE cod_contrato = v_cod_contrato;

			   	   IF _porc_partic_suma IS NULL THEN
			   		  LET _porc_partic_suma = 0;
			   	  END IF

			   	   IF _suma_asegurada IS NULL THEN
			   		  LET _suma_asegurada = 0;
			   	  END IF

		       IF v_tipo_contrato = 1  THEN
					let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_ret = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_ret = _prima_terremoto * _porc_partic_suma / 100;
					let _ret_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 3  THEN
					let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_fac = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_fac = _prima_terremoto * _porc_partic_suma / 100;
					let _fac_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 7  THEN
					let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
					let _exc_porc = _porc_partic_suma;
			   end if
			   if  v_tipo_contrato <> 1 and v_tipo_contrato <> 3 then
					let _suma_otros = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_otros = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_otros = _prima_terremoto * _porc_partic_suma / 100;
					let _otros_porc = _porc_partic_suma;
			   end if

		   END FOREACH	

		--AGENTES DE LA POLIZA
			LET _nombre_ag = "";
			LET _nombre_ag_acum = "";
			LET u_tipo_asegurado  = '';
			LET u_referencia      = '';
			LET u_tipo_asegurado  = 'etc';
			LET v_ubicacion       = '';

			 IF _tipo_incendio = 1 THEN
			    LET u_tipo_asegurado  = 'Edificio';
			END IF

			 IF _tipo_incendio = 2 THEN
			    LET u_tipo_asegurado  = 'Contenido';
			END IF

			 IF _tipo_incendio = 3 THEN
			    LET u_tipo_asegurado  = 'Lucro Cesante';
			END IF

	       	SELECT referencia
	       	  INTO u_referencia 
	       	  FROM emiman05 
	       	 WHERE cod_manzana = _cod_manzana; 
			  
			  IF u_referencia is null THEN
				 LET u_referencia  = '';
			 END IF

			 SELECT nombre
			   INTO v_ubicacion
			   FROM emiubica
			  WHERE cod_ubica = _cod_ubica;

	       	 SELECT nombre 
	       	   INTO v_desc_grupo 
	       	   FROM cligrupo 
	       	  WHERE cod_grupo = _grupo; 

			FOREACH
				   SELECT TRIM(agtagent.nombre),agtagent.cod_agente,emipoagt.porc_comis_agt,emipoagt.porc_partic_agt
				     INTO _nombre_ag,_cod_agente,_porc_comis_agt,_porc_partic_agt
					 FROM agtagent, emipoagt 
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) 
					  AND ( emipoagt.no_poliza = _no_poliza ) 

				      LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;
					  LET _grupo = '000';

					BEGIN
			   			ON EXCEPTION IN(-239)
							UPDATE temp_ubica			   
							   SET TOTAL_PRIMA_SUSCRITA   = TOTAL_PRIMA_SUSCRITA   + 0
							 WHERE poliza = _no_poliza
							   and unidad = _no_unidad
							   and corredor = _cod_agente;
						END EXCEPTION
						INSERT INTO temp_ubica
						(  COMPANIA, 			 
						   GRUPO,				 
						   NOMBRE_GRUPO,
						   RAMO, 				 
						   DESDE, 				 
						   HASTA, 				 
						   ESTATUS, 			 
						   POLIZA, 				 
						   UNIDAD, 				 
						   ASEGURADO, 			 
						   NOMBRE_ASEGURADO,
						   UBICACION, 			 
						   NOMBRE_UBICACION,
						   MANZANA,			
						   NOMBRE_MANZANA, 	 
						   CORREDOR, 		
						   NOMBRE_CORREDOR, 
						   PORC_COMISION, 		 
						   TIPO,				 
						   SUMA_ASEGURADA,		 
						   RETENCION,			 
						   CONTRATOS,			 
						   FACULTATIVO,			 
						   TOTAL_PRIMA_SUSCRITA, 
						   PRIMA_INC,			 
						   INC_RETENCION,  		 
						   INC_CONTRATOS,  		 
						   INC_FACULTATIVO,		 
						   PRIMA_TERREMOTO,	   	 
						   TER_RETENCION,		 
						   TER_CONTRATOS,		 
						   TER_FACULTATIVO)		 
						   VALUES(a_compania,
						   _grupo,   
						   v_desc_grupo,
						   _cod_ramo,
						   a_fecha,
						   a_fecha,
						   _est_pol,
						   _no_documento,
						   _no_unidad,
						   _contratante,
						   v_asegurado,
						   _cod_ubica,
						   v_ubicacion,
						   _cod_manzana,
						   u_referencia,
						   _cod_agente,
						   _nombre_ag,
						   _porc_comis_agt,
						   u_tipo_asegurado,
						   _suma_asegurada,
						   _suma_ret,
						   _suma_otros,
						   _suma_fac,
						   _prima_suscrita,
						   _prima_incendio,
						   _prima_inc_ret,
						   _prima_inc_otros,
						   _prima_inc_fac,
						   _prima_terremoto,
						   _prima_ter_ret,
						   _prima_ter_otros,
						   _prima_ter_fac
						   );
					END
--tipo_incendio
--1	Edificio
--2	Contenido
--3	Lucro Cesante
			END FOREACH
--	   RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,
--	          _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,_vig_ini,_vig_fin,_suma_ret, _est_pol, _nombre_ag_acum,_suma_fac,_suma_exc,_ret_porc,_fac_porc,_exc_porc  WITH RESUME;
	END FOREACH
END FOREACH
end if
drop table temp_ubica;

end procedure                                                                                                                      
