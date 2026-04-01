-- Morosidad por Asegurado

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf10;

--CREATE PROCEDURE sp_rwf10(a_cod_cliente CHAR(10))
CREATE PROCEDURE sp_rwf10(a_no_documento CHAR(20))
RETURNING DEC(16,2),
		  DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          DEC(16,2),
          VARCHAR(255),
          VARCHAR(30),
          VARCHAR(30),
          VARCHAR(255);

DEFINE v_cod_cliente  		CHAR(10);  

DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_no_unidad	 	    CHAR(5);

DEFINE v_no_poliza	 	    CHAR(10);
define _actualizado			smallint;
DEFINE _no_endoso	 	    CHAR(5);
define _estatus_poliza		smallint;
define _estatus_desc		char(10);
DEFINE _cod_agente          CHAR(5);
DEFINE _cod_cobrador, _cod_supervisor	CHAR(3);
DEFINE _usuario				CHAR(10);
define _mes_char			char(2);
define _ano_char			char(4);
define _periodo			    char(7);
DEFINE v_email_supervisor, v_email_gerente  varchar(30);
define v_email_todos, v_email, v_email_electronico  varchar(255);
define _cod_compania, _cod_sucursal char(3);
define v_saldo_tot, v_por_vencer, _exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo dec(16,2);
define _cod_formapag char(3);

--set debug file to "sp_rwf10.trc";
--trace on;

{create temp table tmp_polizas(
    no_documento char(20),
	no_unidad	 char(5),
	cod_compania char(3),
	cod_sucursal char(3),
	PRIMARY KEY (no_documento)) with no log;
}

let v_email = "";
let v_email_supervisor = "";
let v_email_gerente = "";
let v_email_todos = "";
let v_email_electronico = "";


SET ISOLATION TO DIRTY READ;

IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;


{FOREACH
 SELECT	no_poliza,
        no_unidad,
		no_endoso
   INTO v_no_poliza,
        v_no_unidad,
		_no_endoso
   FROM	endeduni 
  WHERE cod_cliente = a_cod_cliente

	select no_documento,
	       cod_compania,
		   cod_sucursal,
	       actualizado
	  into v_documento,
	       _cod_compania,
		   _cod_sucursal,
	       _actualizado
	  from endedmae
	 where no_poliza = v_no_poliza
	   and no_endoso = _no_endoso;

	if _actualizado = 0 then
		continue foreach;
	end if

   BEGIN
	ON EXCEPTION IN(-239)
	END EXCEPTION
	insert into tmp_polizas
	values (v_documento, v_no_unidad, _cod_compania, _cod_sucursal);
   END
END FOREACH

FOREACH
 SELECT	no_poliza
   INTO v_no_poliza
   FROM	emipomae 
  WHERE actualizado      = 1
    and (cod_pagador     = a_cod_cliente or
		 cod_contratante = a_cod_cliente)

	foreach
	 select	no_unidad,
	        no_endoso
	   into v_no_unidad,
	        _no_endoso
	   from endeduni
	  where no_poliza = v_no_poliza

		select no_documento,
		       cod_compania,
			   cod_sucursal,
		       actualizado
		  into v_documento,
		       _cod_compania,
			   _cod_sucursal,
		       _actualizado
		  from endedmae
		 where no_poliza = v_no_poliza
		   and no_endoso = _no_endoso;

		if _actualizado = 0 then
			continue foreach;
		end if

	   BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
			insert into tmp_polizas
			values (v_documento, v_no_unidad, _cod_compania, _cod_sucursal);
	   END

	end foreach

END FOREACH

LET v_saldo_tot = 0;
LET v_documento = "";

foreach
 select no_documento,
		cod_compania,
		cod_sucursal,
        no_unidad
   into v_documento,
		_cod_compania,
		_cod_sucursal,
        v_no_unidad
   from tmp_polizas
  where no_documento[1,2] in ("02","20") 
}

FOREACH   
    SELECT cod_compania,
		   sucursal_origen,
		   no_documento,
		   no_poliza,
		   cod_formapag
	  INTO _cod_compania,
		   _cod_sucursal,
		   v_documento,
		   v_no_poliza,
		   _cod_formapag
	  FROM emipomae
	 WHERE no_documento = a_no_documento
	ORDER BY no_poliza DESC
	EXIT FOREACH;
END FOREACH

	CALL sp_cob33(
	_cod_compania,
	_cod_sucursal,
	v_documento,
	_periodo,
	current
	) RETURNING v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90,  
				v_saldo;

{ LET v_saldo_tot = v_saldo_tot + _exigible;
end foreach

IF v_documento = '' OR v_documento IS NULL THEN
	RETURN	0, "";
END IF

FOREACH
	SELECT no_poliza
	  INTO v_no_poliza
	  FROM emipomae
	 WHERE no_documento = v_documento
  ORDER BY 1 DESC
  EXIT FOREACH;
END FOREACH
}

-- Zona de Cobros
select cod_cobrador
  into _cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;

if _cod_cobrador is null then
	FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = v_no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT cod_cobrador
	  INTO _cod_cobrador
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

end if

SELECT usuario, cod_supervisor
  INTO _usuario, _cod_supervisor 
  FROM cobcobra
 WHERE cod_cobrador = _cod_cobrador 
   AND activo = 1;

if _usuario is null then
	if _cod_cobrador = '218' then  -- Electronico
		FOREACH
			SELECT usuario, cod_supervisor
			  INTO _usuario, _cod_supervisor 
			  FROM cobcobra
			 WHERE tipo_cobrador = 4
			   AND activo = 1

			SELECT e_mail
			  INTO v_email
			  FROM insuser
			 WHERE usuario = _usuario;

			if v_email is null then
				let v_email = "";
			end if

			if trim(v_email_electronico) <> "" then 
			    let v_email_electronico = v_email_electronico || ";" || trim(v_email);
			else 
				let v_email_electronico = trim(v_email);
			end if
		END FOREACH

        let v_email =  trim(v_email_electronico);
	else
	    FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = v_no_poliza
		    EXIT FOREACH;
		END FOREACH

		SELECT cod_cobrador
		  INTO _cod_cobrador
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		SELECT usuario, cod_supervisor
		  INTO _usuario, _cod_supervisor 
		  FROM cobcobra
		 WHERE cod_cobrador = _cod_cobrador;

		SELECT e_mail
		  INTO v_email
		  FROM insuser
		 WHERE usuario = _usuario;
	end if
else
	SELECT e_mail
	  INTO v_email
	  FROM insuser
	 WHERE usuario = _usuario;

end if


SELECT usuario
  INTO _usuario 
  FROM cobcobra
 WHERE cod_cobrador = _cod_supervisor;

SELECT e_mail
  INTO v_email_supervisor
  FROM insuser
 WHERE usuario = _usuario;
	
{SELECT e_mail
  INTO v_email_gerente
  FROM insuser
 WHERE codigo_perfil = '014'   
   AND status = 'A';
}
--let v_email = "aperez@asegurancon.com";
--let v_email_supervisor = "aperez@asegurancon.com";
--let v_email_gerente = "aperez@asegurancon.com";

if v_email is null then
	let v_email = "";
else
    let v_email_todos = trim(v_email); 
end if

if v_email_supervisor is null then
	let v_email_supervisor = "";
else
	if trim(v_email_todos) <> "" then 
    	let v_email_todos = v_email_todos || ";" ||	trim(v_email_supervisor);
	else
		let v_email_todos = trim(v_email_supervisor);
	end if
end if

if v_email_gerente is null then
	let v_email_gerente = "";
else 
	if trim(v_email_todos) <> "" then
    	let v_email_todos = v_email_todos || ";" ||	trim(v_email_gerente);
	else
		let v_email_todos = trim(v_email_gerente);
	end if 
end if

RETURN v_por_vencer, 
	   _exigible,  
	   v_corriente, 
	   v_monto_30,  
	   v_monto_60,  
	   v_monto_90,  
	   v_saldo,
       v_email,
	   v_email_supervisor,
	   v_email_gerente,
	   v_email_todos
	   WITH RESUME;


--drop table tmp_polizas;

END PROCEDURE;