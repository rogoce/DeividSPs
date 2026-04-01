--***************************************************************--
-- Procedimiento que Carga tabla anno anterior Incentivos de Fidelidad--
-- Este proceso se debe correr una sola vez en enero de cada anno, debido a que al argumento a_periodo,
-- se le resta 1 para sacar el anno anterior.
--***************************************************************--

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
DEFINE _periodo_ant     CHAR(7);
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
define _saldo           dec(16,2);
define _per_cero        char(7);
define _suc_origen      char(3);
define _beneficios      smallint;

--SET DEBUG FILE TO "sp_che84.trc";
--TRACE ON;

let _error           = 0;
let _porc_coas_ancon = 0;
let _cnt_dias        = 0;
let _prima_neta      = 0;

SET ISOLATION TO DIRTY READ;

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 4; --Reaseguro Asumido

let _ano_ant     = a_periodo[1,4];
let _ano_ant     = _ano_ant - 1;
let _periodo_ant = _ano_ant || '-' || '12';

FOREACH
    SELECT no_documento,
		   no_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_contratante,
		   fecha_cancelacion,
		   cod_grupo,
		   cod_pagador,
		   nueva_renov,
		   sucursal_origen
	  INTO _no_documento,
		   _no_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_contratante,
		   _fecha_cancelacion,
		   _cod_grupo,
		   _cod_pagador,
		   _nueva_renov,
		   _suc_origen
	  FROM emipomae
	 WHERE actualizado         = 1
	   AND year(vigencia_inic) = _ano_ant
	   AND cod_tipoprod        <> _cod_tipoprod -- Reaseguro Asumido
	 ORDER BY no_documento

	--LET _no_poliza = sp_sis21(_no_documento);

	  select beneficios
	    into _beneficios
	    from insagen
	   where codigo_agencia  = _suc_origen
		 and codigo_compania = a_compania;

	  if _beneficios = 0 then
			INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'La Suc. no paga beneficios: ' || _suc_origen,1);
			continue foreach;
	  end if

	  if _vigencia_inic is null then
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'La Vig. Inicial esta nula',1);
		continue foreach;
	  end if

	  select cedula
	    into _cedula_paga
	    from cliclien
	   where cod_cliente = _cod_pagador;

	  select cedula
	    into _cedula_cont
	    from cliclien
	   where cod_cliente = _cod_contratante;

	  if _cod_ramo in ("014","013","017","008","080","009") then --Excluir Ramos de(montaje,car,casco,fianzas,transporte)
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'Ramo excluido: ' || _cod_ramo,1);
		continue foreach;
	  end if

	  if _cod_grupo = "00000" then --Excluir Grupo Estado
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'No Grupo del Estado.',1);
		continue foreach;
	  end if  	

	  select count(*)
	    into _cnt
	    from emifafac
	   where no_poliza = _no_poliza;

	  if _cnt > 0 then		--Excluir los facultativos
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'No Facultativos',1);
		continue foreach;
	  end if

	  let _cnt_dias = _vigencia_final - _vigencia_inic;

	  if _cnt_dias < 365 then	--Excluir vigencias menores a un año.
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'No Vig. menor de un ano.',1);
		continue foreach;
	  end if

      let _per_cero = sp_sis381(a_compania,_no_documento,_periodo_ant,0,'');

	  if _per_cero = "" then
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (_periodo_ant[1,4],_no_documento,'No fue pagada, ano anterior: ' || _periodo_ant,1);
		continue foreach;
	  end if

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

			--FF SEGUROS no entra en plan de negocios. 17/09/09
			if _cod_agente in("01068","01653","01654","01655","01656","01657","01658","01659","01660","01661","01662","01663","01664") then
				continue foreach;
			end if

			if trim(_cedula_agt) = trim(_cedula_paga) then
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	--solo agentes
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  --El corredor debe estar activo
				exit foreach;
			END IF

			INSERT INTO incent07(periodo,no_poliza,cod_ramo,cod_agente,no_documento,seleccionado)
			VALUES(_per_cero,_no_poliza,_cod_ramo,_cod_agente,_no_documento,0);

      END FOREACH

END FOREACH

return 0;

END PROCEDURE;