-- Morosidad por Asegurado

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_cob116a;

CREATE PROCEDURE sp_cob116a(a_no_poliza CHAR(10))
RETURNING VARCHAR(255);

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

--set debug file to "sp_rwf02.trc";

let v_email = "";
let v_email_supervisor = "";
let v_email_gerente = "";
let v_email_todos = "";
let v_email_electronico = "";


SET ISOLATION TO DIRTY READ;

select cod_formapag
  into _cod_formapag
  from emipomae
 where no_poliza = a_no_poliza;


-- Zona de Cobros
select cod_cobrador
  into _cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;

SELECT usuario, cod_supervisor
  INTO _usuario, _cod_supervisor 
  FROM cobcobra
 WHERE cod_cobrador = _cod_cobrador;

if _usuario is null then
	if _cod_cobrador = '218' then  -- Electronico
		FOREACH
			SELECT usuario, cod_supervisor
			  INTO _usuario, _cod_supervisor 
			  FROM cobcobra
			 WHERE tipo_cobrador = 4
			   and activo = 1

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
	end if
else
	SELECT e_mail
	  INTO v_email
	  FROM insuser
	 WHERE usuario = _usuario;

end if

{SELECT e_mail
  INTO v_email_gerente
  FROM insuser
 WHERE codigo_perfil = '014'   
   AND status = 'A';}


if v_email is null then
	let v_email = "";
end if

{if v_email_gerente is null then
	let v_email_gerente = "";
else 
	if trim(v_email_todos) <> "" then
    	let v_email_todos = v_email_todos || ";" ||	trim(v_email_gerente);
	else
		let v_email_todos = trim(v_email_gerente);
	end if 
end if}

RETURN v_email;

END PROCEDURE;