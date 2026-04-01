--********************************************************
-- Procedimiento que Carga los Incentivos de Fidelidad
--********************************************************

-- Creado    : 02/05/2008 - Autor: Armando Moreno M.
-- Modificado: 02/05/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che84;

CREATE PROCEDURE sp_che84
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo		    CHAR(7),
a_usuario           CHAR(8)
)
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_origen      char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_desde     date;
define _fecha_hasta     date;
define v_corr			DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _estatus_poliza  smallint;
DEFINE _periodo_ant     CHAR(7);
define _mes_act			smallint;
define _ano_act			smallint;
define _mes_ant			smallint;
define _ano_ant			smallint;
define _error           smallint;
define _prima_neta		DEC(16,2);
define _monto_p			DEC(16,2);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_cancelacion date;
define _cnt_dias,_cnt   integer;
define _nueva_renov     char(1);
define _flag            smallint;


--SET DEBUG FILE TO "sp_che84.trc";
--TRACE ON;

let _ano_act = a_periodo[1,4];
let _mes_act = a_periodo[6,7];

let _ano_ant = _ano_act - 1;

if _mes_act < 10 then
	let _periodo_ant = _ano_ant || '-0' || _mes_act;
else
	let _periodo_ant = _ano_ant || _mes_act;
end if

let _flag = 0;
let _error           = 0;
let _porc_coas_ancon = 0;
let _cnt_dias        = 0;
let _prima_neta      = 0;

CREATE TEMP TABLE t_anoant(
	no_poliza		CHAR(10),
	cod_ramo        CHAR(3),
	vig_ini         DATE,
	vig_fin         DATE,
	periodo_ant     CHAR(7)
	) WITH NO LOG;

--	PRIMARY KEY		(cod_agente, no_poliza)

CREATE TEMP TABLE t_anoact(
	no_poliza		CHAR(10),
	cod_ramo        CHAR(3),
	vig_ini         DATE,
	vig_fin         DATE,
	periodo_act     CHAR(7),
	prima_neta      DEC(16,2)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 4; --Reaseguro Asumido

-- Datos de la Poliza mes y año anterior

FOREACH
    SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE actualizado          = 1
	   AND year(vigencia_inic)  = _ano_ant
	   AND month(vigencia_inic) = _mes_act
	   AND cod_tipoprod         <> _cod_tipoprod -- Reaseguro Asumido
	 GROUP BY no_documento

	LET _no_poliza = sp_sis21(_no_documento);

	SELECT vigencia_inic,
	 	   vigencia_final,
		   cod_ramo,
		   cod_contratante,
		   estatus_poliza,
		   fecha_cancelacion,
		   cod_grupo,
		   cod_pagador,
		   nueva_renov
	  INTO _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_contratante,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _cod_grupo,
		   _cod_pagador,
		   _nueva_renov
	  FROM emipomae
     WHERE no_poliza            = _no_poliza
	   AND actualizado          = 1
	   AND year(vigencia_inic)  = _ano_ant
	   AND month(vigencia_inic) = _mes_act
   	   AND cod_tipoprod         <> _cod_tipoprod; -- Reaseguro Asumido

	  select cedula
	    into _cedula_paga
	    from cliclien
	   where cod_cliente = _cod_pagador;

	  select cedula
	    into _cedula_cont
	    from cliclien
	   where cod_cliente = _cod_contratante;

	  if _cod_ramo in ("018","014","013","017","008","080","009") then --Excluir Ramos de(salud,montaje,car,casco,fianzas,transporte) 
		continue foreach;
	  end if

	  if _cod_grupo = "00000" then --excluir estado
		continue foreach;
	  end if  	

	  select count(*)
	    into _cnt
	    from emifafac
	   where no_poliza = _no_poliza;

	  if _cnt > 0 then		--los facultativos se excluyen
		continue foreach;
	  end if

	  let _cnt_dias = _vigencia_final - _vigencia_inic;

	  if _cnt_dias < 365 then	--se excluyen vigencias menores a un año.
		continue foreach;
	  end if

	  if _estatus_poliza = 2 then  --poliza cancelada
		continue foreach;
	  end if

	  let _flag = 0;

	  FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

			SELECT nombre,
			       no_licencia,
			       tipo_pago,
			       tipo_agente,
				   estatus_licencia,
				   cedula
			  INTO _nombre,
			       _no_licencia,
			       _tipo_pago,
			       _tipo_agente,
				   _estatus_licencia,
				   _cedula_agt
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then
			    let _flag = 1;
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then
			    let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	--solo agentes
			    let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  --El corredor debe ser activo
			    let _flag = 1;
				exit foreach;
			END IF

       END FOREACH

	if _flag = 1 then
		continue foreach;
	end if

	if _nueva_renov = "N" then
		INSERT INTO t_anoant(no_poliza,cod_ramo,vig_ini,vig_fin,periodo_ant)
		VALUES(_no_poliza,_cod_ramo,_vigencia_inic,_vigencia_final,_periodo_ant);
	end if

END FOREACH

-- Polizas Renovadas Anno Actual

foreach
    SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE actualizado = 1
	   AND year(vigencia_inic)  = _ano_act
	   AND month(vigencia_inic) = _mes_act
	   AND cod_tipoprod         <> _cod_tipoprod -- Reaseguro Asumido
	 GROUP BY no_documento

	LET _no_poliza = sp_sis21(_no_documento);

	select nueva_renov,
	       no_poliza,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   estatus_poliza,
		   fecha_cancelacion,
		   cod_grupo,
		   cod_pagador,
		   prima_neta
	  into _nueva_renov,
	       _no_poliza,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_contratante,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _cod_grupo,
		   _cod_pagador,
		   _prima_neta
	  from emipomae
	 where no_poliza            = _no_poliza
	   and actualizado          = 1
 	   and year(vigencia_inic)  = _ano_act
	   and month(vigencia_inic) = _mes_act
	   and cod_tipoprod         <> _cod_tipoprod; -- Reaseguro Asumido

	select cedula
	  into _cedula_paga
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select cedula
	  into _cedula_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;

    if _cod_ramo in ("018","014","013","017","008","080","009") then --Excluir Ramos de(salud,montaje,car,casco,fianzas,transporte) 
		continue foreach;
	end if

	if _cod_grupo = "00000" then --excluir estado
	    continue foreach;
	end if  	

    select count(*)
      into _cnt
      from emifafac
     where no_poliza = _no_poliza;

    if _cnt > 0 then		--los facultativos se excluyen
		continue foreach;
    end if

    let _cnt_dias = _vigencia_final - _vigencia_inic;

    if _cnt_dias < 365 then	--se excluyen vigencias menores a un año.
     	continue foreach;
    end if																	

    if _estatus_poliza = 2 then
    	continue foreach;
    end if

	let _flag = 0;

	FOREACH
			SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

			SELECT nombre,
			       no_licencia,
			       tipo_pago,
			       tipo_agente,
				   estatus_licencia,
				   cedula
			  INTO _nombre,
			       _no_licencia,
			       _tipo_pago,
			       _tipo_agente,
				   _estatus_licencia,
				   _cedula_agt
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then
			    let _flag = 1;
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then
			    let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	--solo Agentes
			    let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  --El corredor debe ser activo
			    let _flag = 1;
				exit foreach;
			END IF

	END FOREACH

	if _flag = 1 then
		continue foreach;
	end if

	if _nueva_renov = "R" then
	  INSERT INTO t_anoact(no_poliza,cod_ramo,vig_ini,vig_fin,periodo_act,prima_neta)
	  VALUES(_no_poliza,_cod_ramo,_vigencia_inic,_vigencia_final,a_periodo,_prima_neta);
	end if

end foreach

{foreach
	select count(*),
	       cod_ramo
	  into _cnt_pol_ramo_n,
	       _cod_ramo
	  from t_anoant
	 group by 2
	 order by 2;

	select count(*)
	  into _cnt
	  from t_anoact
	 where cod_ramo = _cod_ramo;

	if _cnt > 0 then

		select count(*),
		       cod_ramo
		  into _cnt_pol_ramo_r,
		       _cod_ramo
		  from t_anoact
		 where cod_ramo = _cod_ramo
		 group by 2
		 order by 2;

		_valor = _cnt_pol_ramo_r / _cnt_pol_ramo_n

		--persistencia

		if _cod_ramo <> "018" then

			if _valor > 96 and _valor <= 100 then
				let _valor_prima = _prima_neta * (2.5 / 100);
			end if
			if _valor > 86 and _valor <= 95 then
				let _valor_prima = _prima_neta * (2.0 / 100);
			end if
			if _valor > 76 and _valor <= 85 then
				let _valor_prima = _prima_neta * (1.5 / 100);
			end if
			if _valor > 70 and _valor <= 75 then
				let _valor_prima = _prima_neta * (1.0 / 100);
			end if

		end if

	end if

end foreach	}

return 0;

END PROCEDURE;