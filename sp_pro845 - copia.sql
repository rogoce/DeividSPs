-- Actualizacion Masiva polizas vigentes (Codificacion de Manzanas)
-- Creado: 08/10/2008 - Autor: Armando Moreno Montenegro

drop procedure sp_pro845;

create procedure "informix".sp_pro845(a_cod_manzana char(255) default '*', a_poliza char(20) DEFAULT '*', a_estatus_poliza smallint default 1)
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


SET ISOLATION TO DIRTY READ;

let _fecha = CURRENT;
let _suma_asegurada = 0;
let _suma_ret       = 0;

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

let _no_poliza = sp_sis21(a_poliza);

FOREACH WITH HOLD

   select sucursal_origen,
          no_documento,
		  actualizado,
		  vigencia_inic,
		  vigencia_final,
		  cod_ramo,
		  estatus_poliza
     into _suc_origen,
	      _no_documento,
		  _actualizado,
		  _vig_ini,
		  _vig_fin, 
		  _cod_ramo,
		  _est_pol
     from emipomae
    where no_poliza = _no_poliza

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
	   select no_unidad,
	          no_poliza,
			  suma_asegurada,
			  cod_asegurado,
			  tipo_incendio,
			  cod_manzana
	     into _no_unidad,
			  _no_poliza,
			  _suma_asegurada,
			  _contratante,
			  _tipo_incendio,
			  _cod_manzana
		 from emipouni
		where no_poliza = _no_poliza
		order by no_poliza, no_unidad

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

	end foreach

END FOREACH
end if

end procedure