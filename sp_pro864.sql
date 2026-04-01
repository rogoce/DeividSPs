--******************************************************************************************
-- Procedimiento que genera la tabla caribe para consurso a serie del caribe en venezuela
--******************************************************************************************

-- Creado    : 17/12/2009 - Autor: Armando Moreno M.
-- Modificado: 17/12/2009 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro864;
CREATE PROCEDURE sp_pro864(
a_compania          CHAR(3),
a_sucursal          CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE _dif		        DEC(16,2);
define _cnt             integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _error           smallint;
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define v_monto_90       DEC(16,2);
define _prima_orig      DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini    date;
define _fecha_aa_fin    date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;
define _no_pol_nue_ap_per	integer;
define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _valor		    DEC(16,2);
define _prima_neta      DEC(16,2);

define _ano				smallint;
define _ano_ant			smallint;

define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(15);
define _concurso,_unificar smallint;


--SET DEBUG FILE TO "sp_pro864.trc";
--TRACE ON;

let _error          = 0;
let _prima_can      = 0;
let _pri_can        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_dev        = 0;
let _cnt            = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_90	    = 0;
let _valor          = 0;
let _dif            = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;

--***SE COLOCA ESTO PARA USAR EL DIARIO DE PORLAMAR PARA EJECUTAR LA MINI CONVENCION MEXICO 2023
--let _error = sp_minic2023('001','001');

--***SE COLOCA ESTO PARA USAR EL DIARIO DE PORLAMAR PARA EJECUTAR LA MINI CONVENCION SERIE PUERTO RICO BAD BUNNY 2025
let _error = sp_minic2025('001','001');

--***SE COLOCA ESTO PARA USAR EL DIARIO DE PORLAMAR PARA EJECUTAR LA MINI CONVENCION MIAMI 2019
--let _error = sp_pro868a('001','001');

--***********************************************************************************
--SE USA ESTE DIARIO PARA EJECUTAR BONO POR PERSISTENCIA, SE EJECUTA CON TERCER ARG.
--DEFAULT CERO, PARA QUE CORRA DIARIAMENTE, YA QUE SE CARGO LA TABLA AÑO PASADO.
--SOLO SE EJECUTA CON TERCER ARG. EN 1, CUANDO SE INICIA EL BONO (UNA SOLA VEZ).
let _error = sp_che_persis(a_compania, a_sucursal);
--**************************************************************
--SE USA ESTE DIARIO PARA EJECUTAR EL INCENTIVO 1, PROYECTO CCP
let _error = sp_bonoccp01();
--***************************************************************
return _error;

delete from caribe;

let _fecha_aa_ini = "01/09/2013";
let _fecha_aa_fin = "31/12/2013";
let _prima_neta   = 0;

create temp table tmp_caribe(
no_documento		char(20),
pri_pag				dec(16,2) 	default 0,
pri_pag_dif			dec(16,2) 	default 0
) with no log;

SET ISOLATION TO DIRTY READ;

--Periodo de Clasificacion: Del 01 de Sept. de 2013 al  31 de Dic del 2013
--Metas: 
--Ducruet:00035/Semusa:00270/Tecnica de Seguros:00180 = 200,000
--Individual: B/.    60,000  Primas Nuevas Pagadas 
--Brokers :   B/.   100,000  Primas Nuevas Pagadas 
--*****************************
-- Polizas Nuevas
--*****************************

foreach

 select no_documento
   into _no_documento
   from emipomae
  where cod_compania  = a_compania
    and actualizado   = 1
	and nueva_renov   = "N"
    and vigencia_inic between _fecha_aa_ini and _fecha_aa_fin
   group by no_documento
   order by no_documento

	let _no_poliza = sp_sis21(_no_documento);

    select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt > 0 then		-- se excluyen los facultativos
		continue foreach;
	end if

   { select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cnt > 1 then		--se excluye Colectivos y Flotas
		continue foreach;
	end if}

	select nueva_renov,
	       no_documento,
		   estatus_poliza,
		   cod_pagador, 
		   cod_contratante,
		   cod_tipoprod,
		   prima_neta,
		   cod_grupo
	  into _nueva_renov,
	       _no_documento,
		   _estatus_poliza,
		   _cod_pagador,
		   _cod_contratante,
		   _cod_tipoprod,
		   _prima_neta,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _prima_neta < 50 then	--No Prima menores a 50
		continue foreach;	
	end if

	 if _cod_grupo in("00000","1000") then -- Excluir Estado
		continue foreach;
	 end if  	

	 SELECT tipo_produccion
	   INTO _tipo_prod
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

   	 IF _tipo_prod = 3 or _tipo_prod = 4 or _tipo_prod = 2 THEN   -- Excluir Coaseguros y Reaseguro Asumido
	   CONTINUE FOREACH;
	 END IF

	if _estatus_poliza = 2 then  --no polizas canceladas o anuladas
		continue foreach;
	end if	

  	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov = '003';

	if _cnt > 0 then			--no polizas rehabilitadas
		continue foreach;
	end if

  	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov = '012';

	if _cnt > 0 then			--no Cambio de Corredores
		continue foreach;
	end if

	 select cedula
	   into _cedula_paga
	   from cliclien
	  where cod_cliente = _cod_pagador;

	 select cedula,
	        nombre
	   into _cedula_cont,
	        _n_cliente
	   from cliclien
	  where cod_cliente = _cod_contratante;

     let _flag = 0;

	 foreach
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		SELECT nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula
		  INTO _nombre,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then	--Contra pagador
			    let _flag = 1;
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then	--Contra Contratante
			    let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	--solo agentes
			    let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  --El corredor debe estar activo
			    let _flag = 1;
				exit foreach;
			END IF

	 end foreach

	 if _flag = 1 then
	 	continue foreach;
	 end if

	if _nueva_renov = "N" then
		insert into tmp_caribe(no_documento)
		values (_no_documento);
	end if

end foreach

--****************
-- Prima Pagada --
--****************

foreach

	select no_documento
	  into _no_documento
	  from tmp_caribe
	 order by no_documento

  foreach

	select prima_neta,
		   fecha,
		   renglon
	  into _monto,
		   _fecha_pago,
		   _renglon
	  from cobredet
	 where doc_remesa  = _no_documento
	   and actualizado = 1
	   and fecha       >= _fecha_aa_ini
	   and fecha       <= _fecha_aa_fin
	   and tipo_mov    in ("P", "N")
		
	if _monto < 50 then		--No recibos menores a 50
		continue foreach;
	end if

	insert into tmp_caribe(no_documento, pri_pag)
	values (_no_documento, _monto);

  end foreach

end foreach

foreach

	 select no_documento,
		    sum(pri_pag)
	   into _no_documento,
		    _pri_pag
	   from tmp_caribe
	  group by no_documento
	  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_ramo,
	        sucursal_origen
	   into _cod_ramo,
	        _cod_agencia
	   from emipomae
	  where no_poliza = _no_poliza;

	 select nombre
	   into _nombre_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;

	 let _dif = 0;
		
	 foreach

	  	SELECT cod_agente
	      INTO _cod_agente
	      FROM emipoagt
	   	 WHERE no_poliza = _no_poliza
	
		SELECT nombre,
		       tipo_persona
		  INTO _nombre,
		       _tipo_persona
	      FROM agtagent
		 WHERE cod_agente = _cod_agente;

        let _unificar = 0;	 --Unificar Felix Alberto Abadia Pretelt	:correo Demetrio 16/09/2013 por Leticia

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado in("01001","02129");

	    if _unificar <> 0 then
		   let _cod_agente = "01001";
	    end if

		--Unificar FFseguros segun correo de Omayra 28/11/2013
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado in("01068");

	    if _unificar <> 0 then
		   let _cod_agente = "01068";
	    end if


		if _tipo_persona = "N" then
			let _nombre_tipo = "INDIVIDUALES";
			let _valor = 60000;
		else
			let _nombre_tipo = "BROKERS";
			let _valor = 100000;
		end if

		if _cod_agente in('00035','00270','00180') then   --Ducruet:00035/Semusa:00270/Tecnica de Seguros:00180 = 200,000
			let _valor = 200000;
			let _nombre_tipo = "DUC.-SEM.-TEC.";
		end if

		let _dif = _valor - _pri_pag;

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_promotoria
		   and cod_ramo	   = _cod_ramo;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		insert into caribe(
		cod_agente,
		no_documento,
		n_agente,
		pri_pag_nueva,
		pri_pag_dif,
		cod_vendedor,
		nombre_vendedor,
		cod_ramo,
		nombre_ramo,
		tipo_agente
		)
		values(
		_cod_agente, 
		_no_documento, 
		_nombre,
		_pri_pag,
		_dif,
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo
		);

	 end foreach

end foreach

drop table tmp_caribe;

return 0;

END PROCEDURE;