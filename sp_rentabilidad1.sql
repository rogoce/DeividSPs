--Procedimiento para realizar la carga en Rentabilidad1 Este es bk del original sp_che115_carga2017
--Creado 22/03/2017	Armando Moreno M.

--DROP PROCEDURE sp_rentabilidad1;
CREATE PROCEDURE sp_rentabilidad1(a_compania CHAR(3), a_sucursal CHAR(3))
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
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
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
define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
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
define _prima_orig      DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
define _fecha_aa        date;
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
define _fec_aa_ini   	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;

define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

define _estatus_poliza		smallint;
define _pri_sus_pag_ap  	DEC(16,2);
define _pri_pag_ap      	DEC(16,2);
define _pri_can_ap      	DEC(16,2);
define _pri_dev_ap      	DEC(16,2);
define _monto_90_aa     	DEC(16,2);
define _monto_90_ap     	DEC(16,2);

define _ano					smallint;
define _ano_ant				smallint;

define _cod_agencia			char(3);
define _suc_promotoria		char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor		char(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define _tipo_persona		char(1);
define _nombre_tipo			char(15);
define _concurso			smallint;

define _porc_res_mat		dec(5,2);
define _agente_agrupado 	char(5);

define _cod_tipo        	char(3);
define _n_cod_tipo 	    	char(50);
define _pri_sus_pag     	dec(16,2);
define _valor_prima     	dec(16,2);
define _porcentaje      	dec(16,2);
define _prima_max       	dec(16,2);
define _pri_devengada   	dec(16,2);
define _unificar        	smallint;

define _pri_cob_dev     	dec(16,2);
define _pri_cob_dev_max 	dec(16,2);
define _pri_sus_dev     	dec(16,2);
define _pri_sus_dev_max 	dec(16,2);
define _pri_cob         	dec(16,2);
define _pri_cob_max     	dec(16,2);
define _valor_cob_dev 		dec(16,2);
define _valor_sus_dev 		dec(16,2);
define _valor_cob     		dec(16,2);
define _pri_sus_orig    	dec(16,2);
define _porc_res_xramo  	dec(16,2);
define _prima_suscrita_ap 	dec(16,2);
define _pri_cob_dev_ap    	dec(16,2);

define _pri_susc_dev_aa		dec(16,2);
define _pri_susc_dev_ap		dec(16,2);
define _pri_susc_aa	    	dec(16,2);
define _pri_susc_ap	    	dec(16,2);
define _aplica          	smallint;
define _porc_prima_dev_max	dec(16,2);
define _pri_dev_max_aa		dec(16,2);
define _pri_dev_max_ap		dec(16,2);
define _prim_suscrita_min 	dec(16,2);
define _crecimiento_min   	dec(16,2);

define _prima_beneficio 	dec(16,2);
define _prima_maxima    	dec(16,2);
define _bono            	dec(16,2);
define _pri_sus_aa_tmp		dec(16,2);
define _pri_sus_ap_tmp		dec(16,2);
define _prima_ret_aa 		dec(16,2);
define _prima_ret_ap   		dec(16,2);
define _bono_rent2          smallint;

-- return 0; --se detuvo la corrida

-- SET DEBUG FILE TO "sp_che115_carga.trc";
-- TRACE ON;

let _error          	 = 0;
let _prima_can      	 = 0;
let _pri_can        	 = 0;
let _siniestralidad 	 = 0;
let _sini_incu      	 = 0;
let _prima_sus_pag  	 = 0;
let _pri_dev        	 = 0;
let _cnt            	 = 0;
let _pri_pag        	 = 0;
let _sin_pen_dic    	 = 0;
let _sin_pen_aa     	 = 0;
let _sin_pag_aa     	 = 0;
let v_por_vencer    	 = 0;
let v_exigible	    	 = 0;
let v_corriente	    	 = 0;
let v_monto_30	    	 = 0;
let v_monto_60	    	 = 0;
let v_monto_90	    	 = 0;
let v_saldo         	 = 0;
let _cantidad       	 = 0;
let _prima_orig     	 = 0;

let _pri_sus_pag_ap    	 = 0;
let _prima_suscrita_ap 	 = 0;
let _monto_90_aa       	 = 0;
let _pri_can		   	 = 0;
let	_pri_dev		   	 = 0;
let _monto_90_ap       	 = 0;
let _pri_devengada     	 = 0;
let _pri_cob_dev       	 = 0;
let _pri_cob_dev_max   	 = 0;
let _pri_cob_max       	 = 0;
let _pri_cob           	 = 0;
let _pri_sus_dev       	 = 0;
let _pri_sus_dev_max   	 = 0;
let _pri_sus           	 = 0;
let _pri_sus_orig  	   	 = 0;
let _porc_res_xramo	   	 = 0;
let _porc_coaseguro      = 0;

let _pri_susc_dev_aa	 = 0;
let _pri_susc_dev_ap	 = 0;
let _porc_partic         = 0;
let _pri_sus_aa_tmp	 = 0;
let _pri_sus_ap_tmp	 = 0;
let _prima_ret_aa 	 = 0;
let _prima_ret_ap	 = 0;

select par_ase_lider,
       par_periodo_act  -- ult_per_renta
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

if a_periodo > "2012-12" then
	let a_periodo = "2017-12";
end if

delete from rentabilidad1 where periodo = a_periodo;

select par_periodo_ant
  into a_periodo
  from parparam
 where cod_compania = a_compania;

let a_periodo   = '2017-09';

update parparam
   set agt_per_fidel = a_periodo;

let _fec_aa_ini     = "01/01/2017";	--para sacar cancelada o anulada en el periodo
let _per_ini        = "2017-01";
let _per_ini_ap     = "2016-01";
let _ano            = a_periodo[1,4];  --2014
let _ano            = _ano - 1;		   --2013
let _per_fin_ap     = _ano || a_periodo[5,7]; --2013-12

let _per_fin_dic    = "2016-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);    --31/01/2014	 
let _fecha_aa       = sp_sis36(a_periodo);	 --30/06/2014 
let _fecha_ap_ini   = sp_sis36(_per_ini_ap); --31/01/2013 
let _fecha_ap       = sp_sis36(_per_fin_ap); --31/12/2013

--***************************
truncate table fis_che115a;
--***************************

SET ISOLATION TO DIRTY READ;

--*********************
-- Prima SUSCRITA  AA -- 
--*********************

foreach	with hold

	select no_documento,
		   sum(prima_suscrita)
	  into _no_documento,
		   _prima_suscrita
	  from endedmae
	 where actualizado = 1
	   and periodo     >= _per_ini 
	   and periodo     <= a_periodo
	 group by no_documento
  
	if _prima_suscrita is null then
		let _prima_suscrita = 0;
	end if

    begin work;

	insert into fis_che115a(no_documento, pri_sus_pag, tipo)
	values (_no_documento, _prima_suscrita, 3);

	commit work;
end foreach

--***********************
-- Prima  SUSCRITA  AP --
--***********************
foreach	with hold

	select no_documento,
		   sum(prima_suscrita)
	  into _no_documento,
		   _prima_suscrita
	  from endedmae
	 where actualizado  = 1
	   and periodo >= _per_ini_ap
	   and periodo <= _per_fin_ap
	 group by no_documento
  
	if _prima_suscrita is null then
		let _prima_suscrita = 0;
	end if

    begin work;
	
	insert into fis_che115a(no_documento, pri_sus_pag_ap, tipo)
	values (_no_documento, _prima_suscrita, 4);

	commit work;
end foreach

--**********************************
-- Siniestros Pagados Anno Actual --
--**********************************

call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach	with hold

    select doc_poliza,
           pagado_bruto   
      into _no_documento,
           _sin_pag_aa
      from tmp_sinis

  begin work;
	insert into fis_che115a(no_documento, sin_pag_aa, tipo)
	values (_no_documento, _sin_pag_aa, 5);
  commit work;
end foreach

drop table tmp_sinis;

--***********************************************
-- Siniestros Pendientes Diciembre Anno Pasado --
--***********************************************

foreach	with hold
	select no_reclamo,		
		   SUM(variacion)
	  into _no_reclamo,	
		   _sin_pen_dic
	  from rectrmae 
	 where cod_compania = a_compania
	   and periodo      <= _per_fin_dic
	   and actualizado  = 1
	 group by no_reclamo
	having sum(variacion) > 0 

   begin work;
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);

	insert into fis_che115a(no_documento, sin_pen_ap, tipo)
	values (_no_documento, _sin_pen_dic, 6);
	commit work;
end foreach

--*************************************
-- Siniestros Pendientes Anno Actual --
--*************************************

foreach	with hold
	select no_reclamo,		
	       SUM(variacion)
	  into _no_reclamo,	
		   _sin_pen_aa
	  from rectrmae 
	 where cod_compania = a_compania
	   and periodo      <= a_periodo
	   and actualizado  = 1
     group by no_reclamo
	having sum(variacion) > 0 

    begin work;
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);

	insert into fis_che115a(no_documento, sin_pen_aa, tipo)
	values (_no_documento, _sin_pen_aa, 7);
	commit work;
end foreach

let _pri_susc_aa	 = 0;
let _pri_susc_ap	 = 0;
let _pri_susc_dev_aa = 0;
let _pri_susc_dev_ap = 0;
let _pri_dev_max_aa	 = 0;
let _pri_dev_max_ap	 = 0;

foreach
	 select no_documento,
			sum(sin_pen_aa),			--   siniestros pend actual
			sum(sin_pen_ap),			--   siniestros pend a dic
			sum(sin_pag_aa),			--   siniestros pagados actual
			sum(pri_sus_pag),			--   prima Suscrita Actual
			sum(pri_sus_pag_ap)			--   prima Suscrita Anio Pasado
	   into _no_documento,
		    _sin_pen_aa,
			_sin_pen_dic,
			_sin_pag_aa,
			_pri_susc_aa,
			_pri_susc_ap
	   from fis_che115a
	  group by no_documento
	  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_grupo, 
	        cod_ramo, 
	        cod_pagador, 
	        cod_contratante, 
	        cod_tipoprod,
			sucursal_origen,
			cod_subramo
	   into _cod_grupo,
	        _cod_ramo,
	        _cod_pagador,
	        _cod_contratante,
	        _cod_tipoprod,
			_cod_agencia,
			_cod_subramo
	   from emipomae
	  where no_poliza = _no_poliza;

	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	   
	{foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	    			
	 exit foreach;
	end foreach}

	if _cod_ramo = '023' then
		let _cod_ramo = '002';
	end if

    if _cod_ramo in("002","020","004","016","012","014","017","010","022","013","003","006","015","005","011","021","009","007",'023') then
	else
		continue foreach;
    end if
     			   
	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- Excluir Reaseguro Asumido y Coas. Minoritario

	 if _tipo_prod = 4 or _tipo_prod = 3 then
	   --INSERT INTO bonibita2(periodo,poliza,descripcion,tipo,cod_agente,cod_ramo,prima_suscrita) VALUES (a_periodo,_no_documento,'REAS. ASUM. Y COAS. MIN. NO APLICA',2,_cod_agente,_cod_ramo,_pri_susc_aa);
	   continue foreach;
	 end if

	 select count(*)
	   into _cnt
	   from emifafac
	  where no_poliza = _no_poliza;

	 if _cnt > 0 then		-- Facultativos, solo nuestra parte
		let _prima_ret_aa = 0;
		let _prima_ret_ap = 0;
		select sum(prima_retenida)
		  into _prima_ret_aa
		  from endedmae
		 where actualizado  = 1
		   and periodo      >= '2017-01'
		   and periodo  	 <= '2017-12'
		   and no_documento = _no_documento
		 group by no_documento;
		 
		select sum(prima_retenida)
		  into _prima_ret_ap
		  from endedmae
		 where actualizado  = 1
		   and periodo      >= '2016-01'
		   and periodo  	 <= '2016-12'
		   and no_documento = _no_documento
		 group by no_documento;

		if _prima_ret_aa is null then
			let _prima_ret_aa = 0;
		end if
		if _prima_ret_ap is null then
			let _prima_ret_ap = 0;
		end if
		
		 update fis_che115a
		   set pri_sus_pag    = _prima_ret_aa,
			   pri_sus_pag_ap = _prima_ret_ap
		 where no_documento   = _no_documento;
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

    select count(*)
      into _cnt
      from endedmae
     where no_poliza     = _no_poliza
	   and actualizado   = 1
       and cod_endomov in ('003','002')  	--rehabilitada o cancelada en el periodo del concurso no va
       and fecha_emision >= _fec_aa_ini
       and fecha_emision <= _fecha_aa;

    if _cnt > 0 then
		continue foreach;
    end if

    let _flag = 0;

	foreach			   --PRIMER EMIPOAGT
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

        let _unificar = 0;	 --02420 somos seguros :08/05/2017 correo Analisa
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "02420";

	    if _unificar <> 0 then
		   let _cod_agente = "02420";
		end if
		
	    let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01727";

	    if _unificar <> 0 then
		   let _cod_agente = "01727";
		end if

		let _unificar = 0;		 --Unificar FF SEGUROS

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01068";

		if _unificar <> 0 then
		   let _cod_agente = "01068";
		end if
		--*******************************************************
		if _cod_agente in('02243') then 		--Unificar Inv. y seg Panamericanos con su codigo de chorrera
		    let _cod_agente = "00473";
		end if
		if _cod_agente in('01481') then 		--Unificar Jose Caballero a Marta Caballero
		    let _cod_agente = "01555";
		end if
		if _cod_agente in('02302','02354') then --Unificar LIZSENELL GIONELLA BERNAL RAMIREZ, correo 24/03/17 Alicia
		    let _cod_agente = "02319";
		end if
		if _cod_agente in('01480','00492') then --Unificar Ricardo Caballero, los ases del seguro a Patricia Caballero
		    let _cod_agente = "01479";
		end if
		if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then --Unificar Felix Abadia
		    let _cod_agente = "01001";
		end if
		if _cod_agente in ("00636","00732","00731") then
		    let _cod_agente = "01435";
	    end if
		if _cod_agente = "01880" then
			let _cod_agente = "00395";													
		end if
		if _cod_agente = "00239" then
			let _cod_agente = "00946";													
		end if
		if _cod_agente in("02015") then
			let _cod_agente = "00125";													
		end if
		if _cod_agente in("01745","01743","01744","01751","01851") then
			let _cod_agente = "00166";													
		end if
		if _cod_agente in("02081") then
			let _cod_agente = "00474";													
		end if
		if _cod_agente in("01990") then
			let _cod_agente = "01009";
		end if
		if _cod_agente in("02103") then
			let _cod_agente = "01670";
		end if
		if _cod_agente in("02196") then
			let _cod_agente = "01898";
		end if
		if _cod_agente in("00197") then
			let _cod_agente = "00291";
		end if
		if _cod_agente in("01904","00138","01867","00965") then
			let _cod_agente = "00011";
		end if
		if _cod_agente in("01948") then
			let _cod_agente = "02208";
		end if
		if _cod_agente in("02102") then
			let _cod_agente = "00817";
		end if
		if _cod_agente in("00517") then
			let _cod_agente = "01440";
		end if
		if _cod_agente in("00525") then
			let _cod_agente = "00779";
		end if
		if _cod_agente in("00076","00937") then
			let _cod_agente = "02119";
		end if
		if _cod_agente in("00050") then
			let _cod_agente = "00845";
		end if
		if _cod_agente in("01916") then
			let _cod_agente = "00793";
		end if
		if _cod_agente in("00104","02037") then
			let _cod_agente = "00119";
		end if
		if _cod_agente in("01779","02431","02429") then
			let _cod_agente = "02229";
		end if
		if _cod_agente in("01504") then
			let _cod_agente = "02424";
		End if
		if _cod_agente in("02440","02441") then	--Javier Ibarra
			let _cod_agente = "01642";
		end if
		if _cod_agente in("01893","02356") then	--Mizrachi, Madariaga & Asoc
			let _cod_agente = "02415";
		end if
		if _cod_agente in("02373","02372") then	--Francisco Antonio Jaén Urriola
			let _cod_agente = "02370";
		end if
		if _cod_agente in("02351","01988") then	--Génesis Asesores de Seguros
			let _cod_agente = "01988";
		end if
		-- Unificar todos los KAM
		-- Se separa la unificacion por orden de leticia segun correo 12/04/2013, indica que se unen al final
		if _cod_agente IN ("02375","02378","02377","02293","02376","02360","00133","01746","01749","01852","02004","02075","02124") then  
			let _cod_agente = "00218";													
		end if
		if _cod_agente IN ("02154",'02904') then	--DUCRUET
			let _cod_agente = "00035";													
		end if
		if _cod_agente IN ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201","02349","02252","02448","02253","02393") then	--DOULOS
			let _cod_agente = "01048";													
		end if
		if _cod_agente IN ("00961","00235","00705","02155") then  --AFTA
			let _cod_agente = "01266";													
		end if
		SELECT nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado,
			   bono_rent2
		  INTO _nombre,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado,
			   _bono_rent2
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
		 
		if _bono_rent2 = 1 then	--Tiene bono rentabilidad 2, NO debe participar en Rentabilidad 1
			let _flag = 8;
			exit foreach;
		end if
		if trim(_cedula_agt) = trim(_cedula_paga) then	-- Contra pagador
			let _flag = 1;
			exit foreach;
		end if
		if trim(_cedula_agt) = trim(_cedula_cont) then	-- Contra Contratante
			let _flag = 2;
			exit foreach;
		end if
		IF _tipo_agente <> "A" then	-- Solo agentes
			let _flag = 3;
			exit foreach;
		END IF
		if _agente_agrupado = "00270" then -- MARSH Semusa no Aplica a rentabilidad correo Analisa 01/06/2017
			let _flag = 9;
			exit foreach;
		end if
		if _cod_agente = "00180" and  -- Tecnica de Seguros
		   _cod_ramo   = "016"	 and  -- Colectivo de vida
		   _cod_grupo  = "01016" then -- Grupo Suntracs
			let _flag = 6;
			exit foreach;
		end if
		if _cod_agente  = "00035" and  -- Ducruet
		   _cod_agencia = "075"   and  -- Agencia Ducruet
		   _cod_ramo    = "020"   then -- Soda
			let _flag = 7;
			exit foreach;
		end if
	end foreach

	if _flag in(1,2,3,4,5,6,7,8,9) then
	 	continue foreach;
	end if

	-- Morosidades Mayores a 90 Dias (No Se Incluyen)

	call sp_cob33(a_compania, a_sucursal, _no_documento, a_periodo, _fecha_aa)
	returning v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_60,v_monto_90,v_saldo;

	-- Siniestros Incurridos
			
	let _sini_incu = 0;
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if v_monto_90 > 0 then	 
		let _pri_susc_dev_aa = 0;
		let _pri_susc_aa     = 0;
	end if

   	let a_periodo = '2017-12';

	-- dinamico
	select cod_tipo 
	  into _cod_tipo
	  from prdrentram 
	 where periodo  = a_periodo
	   and cod_ramo = _cod_ramo;
   
	foreach
	  SELECT cod_agente,
	         porc_partic_agt
	    INTO _cod_agente,
		     _porc_partic
	    FROM emipoagt
	   WHERE no_poliza = _no_poliza

        let _unificar = 0;	 -- 01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		if _unificar <> 0 then
		   let _cod_agente = "01727";
		end if
		
		let _unificar = 0;
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01068";

		if _unificar <> 0 then
		   let _cod_agente = "01068";
		end if
		--******************************************************************************
		if _cod_agente in('02243') then 		--Unificar Inv. y seg Panamericanos con su codigo de chorrera
		    let _cod_agente = "00473";
		end if
		if _cod_agente in('01481') then 		--Unificar Jose Caballero a Marta Caballero
		    let _cod_agente = "01555";
		end if
		if _cod_agente in('02302','02354') then --Unificar LIZSENELL GIONELLA BERNAL RAMIREZ, correo 24/03/17 Alicia
		    let _cod_agente = "02319";
		end if
		if _cod_agente in('01480','00492') then --Unificar Ricardo Caballero, los ases del seguro a Patricia Caballero
		    let _cod_agente = "01479";
		end if
		if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then --Unificar Felix Abadia
		    let _cod_agente = "01001";
		end if
		if _cod_agente in ("00636","00732","00731") then
		    let _cod_agente = "01435";
	    end if
		if _cod_agente = "01880" then
			let _cod_agente = "00395";													
		end if
		if _cod_agente = "00239" then
			let _cod_agente = "00946";													
		end if
		if _cod_agente in("02015") then
			let _cod_agente = "00125";													
		end if
		if _cod_agente in("01745","01743","01744","01751","01851") then
			let _cod_agente = "00166";													
		end if
		if _cod_agente in("02081") then
			let _cod_agente = "00474";													
		end if
		if _cod_agente in("01990") then
			let _cod_agente = "01009";
		end if
		if _cod_agente in("02103") then
			let _cod_agente = "01670";
		end if
		if _cod_agente in("02196") then
			let _cod_agente = "01898";
		end if
		if _cod_agente in("00197") then
			let _cod_agente = "00291";
		end if
		if _cod_agente in("01904","00138","01867","00965") then
			let _cod_agente = "00011";
		end if
		if _cod_agente in("01948") then
			let _cod_agente = "02208";
		end if
		if _cod_agente in("02102") then
			let _cod_agente = "00817";
		end if
		if _cod_agente in("00517") then
			let _cod_agente = "01440";
		end if
		if _cod_agente in("00525") then
			let _cod_agente = "00779";
		end if
		if _cod_agente in("00076","00937") then
			let _cod_agente = "02119";
		end if
		if _cod_agente in("00050") then
			let _cod_agente = "00845";
		end if
		if _cod_agente in("01916") then
			let _cod_agente = "00793";
		end if
		if _cod_agente in("00104","02037") then
			let _cod_agente = "00119";
		end if
		if _cod_agente in("01779","02431","02429") then
			let _cod_agente = "02229";
		end if
		if _cod_agente in("01504") then
			let _cod_agente = "02424";
		End if
		if _cod_agente in("02440","02441") then	--Javier Ibarra
			let _cod_agente = "01642";
		end if
		if _cod_agente in("01893","02356") then	--Mizrachi, Madariaga & Asoc
			let _cod_agente = "02415";
		end if
		if _cod_agente in("02373","02372") then	--Francisco Antonio Jaén Urriola
			let _cod_agente = "02370";
		end if
		if _cod_agente in("02351","01988") then	--Génesis Asesores de Seguros
			let _cod_agente = "01988";
		end if

		-- Unificar todos los KAM
		-- Se separa la unificacion por orden de leticia segun correo 12/04/2013, indica que se unen al final
		if _cod_agente IN ("02375","02378","02377","02293","02376","02360","00133","01746","01749","01852","02004","02075","02124") then  
			let _cod_agente = "00218";													
		end if
		if _cod_agente IN ("02154") then	--DUCRUET
			let _cod_agente = "00035";													
		end if
		if _cod_agente IN ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201","02349","02252","02448","02253","02393") then	--DOULOS
			let _cod_agente = "01048";													
		end if
		if _cod_agente IN ("00961","00235","00705","02155") then  --AFTA
			let _cod_agente = "01266";													
		end if
		SELECT nombre,
		       tipo_persona,
			   cod_vendedor,
			   bono_rent2,
			   agente_agrupado
		  INTO _nombre,
		       _tipo_persona,
			   _cod_vendedor,
			   _bono_rent2,
			   _agente_agrupado
	      FROM agtagent
		 WHERE cod_agente = _cod_agente;

		if _bono_rent2 = 1 then
			continue foreach;
		end if
		if _tipo_persona = "N" then
			let _nombre_tipo = "INDIVIDUALES";
		else
			let _nombre_tipo = "BROKERS";
		end if

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor ;

		--dinamico
		select trim(name_tipo),
		       porc_prima_dev_max 
		  into _n_cod_tipo,
		       _porc_prima_dev_max
		  from prdrenttipo
  	     where periodo  = a_periodo
	       and cod_tipo = _cod_tipo 
	       and activo   = 1;

		--************************************************
		--   Calculos para incremeto de PSP 2012 vs 2011
		--************************************************
		let _pri_sus_aa_tmp = 0;
		let _pri_sus_ap_tmp = 0;		
		let _pri_sus_aa_tmp = _pri_susc_aa * (_porc_partic / 100);
		let _pri_sus_ap_tmp = _pri_susc_ap * (_porc_partic / 100);		
		let _incremento_psp = _pri_sus_aa_tmp - _pri_susc_ap;
		
		--************************************************************************************************
		let _pri_susc_dev_aa	 = 0;
		let _pri_susc_dev_ap	 = 0;

		-- Prima Suscrita Devengada	Año Actual 2015
		let _porc_res_mat    = 100 - _porc_res_mat;
		let _pri_susc_dev_aa = _pri_sus_aa_tmp * _porc_res_mat / 100;

		if _pri_sus_aa_tmp is null then
			let _pri_sus_aa_tmp = 0;
		end if

		-- Prima Suscrita Devengada	Año Pasado 2014
		let _pri_susc_dev_ap = _pri_sus_ap_tmp * _porc_res_mat / 100;

		if _pri_sus_ap_tmp is null then
			let _pri_sus_ap_tmp = 0;
		end if

		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************

		if _pri_sus_ap_tmp <> 0 then
			let _crecimiento = (_incremento_psp / _pri_sus_ap_tmp) * 100;
		else
			let _crecimiento = 100; 
		end if
		
		--************************************************
		--    Calculos % de siniestralidad 
		--************************************************

		let _siniestralidad = 0;
		if _pri_sus_aa_tmp <> 0 then
			let _siniestralidad = (_sini_incu / _pri_sus_aa_tmp) * 100;
		else
			continue foreach;
		end if	

		let _pri_dev_max_aa	 = _pri_susc_dev_aa * (_porc_prima_dev_max/100);
		let _pri_dev_max_ap	 = _pri_susc_dev_ap * (_porc_prima_dev_max/100);

		let _aplica = 0;
		insert into rentabilidad1(
		periodo,   			
		cod_agente,     		
		no_documento,   		
		pri_susc_aa,  		
		pri_susc_ap,  		
		pri_susc_dev_aa,  	
		pri_susc_dev_ap,  	
		pri_dev_max_aa,
		pri_dev_max_ap,
		sini_inc,  			
		monto_90,     		
		n_agente, 			
		cod_contratante, 	
		n_cliente, 			
		cod_vendedor,    	
		nombre_vendedor, 	
		cod_ramo,    		
		nombre_ramo, 		
		tipo_agente, 		
		tipo,         		
		nombre_tipo,
		por_incremento, 		
		por_crecimiento, 	
		por_siniestro,
		aplica,
		beneficio,
		bono,
		sin_pag_aa,
		sin_pen_aa,
		sin_pen_dic   	
		)
		values(
		a_periodo,
		_cod_agente, 
		_no_documento,
		_pri_sus_aa_tmp,  		
		_pri_sus_ap_tmp,  		
		_pri_susc_dev_aa,  	
		_pri_susc_dev_ap, 
		_pri_dev_max_aa,
		_pri_dev_max_ap,
		_sini_incu, 
		v_monto_90,
		_nombre,
		_cod_contratante, 
		_n_cliente, 
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_cod_tipo,
		_n_cod_tipo,
		_incremento_psp,
		_crecimiento,
		_siniestralidad,
		_aplica,
		0,
		0,
		_sin_pag_aa,
		_sin_pen_aa,
		_sin_pen_dic
		);
	end foreach
end foreach

--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
let _bono = 0;
foreach
	select tipo,
		   cod_agente,
		   sum(pri_susc_aa),		  
		   sum(por_crecimiento),			  
		   sum(por_siniestro),
		   sum(pri_dev_max_aa),
		   sum(pri_dev_max_ap)
	  into _cod_tipo,
		   _cod_agente,
		   _pri_susc_aa,
		   _crecimiento,
		   _siniestralidad,
		   _pri_dev_max_aa,
		   _pri_dev_max_ap
	  from rentabilidad1
	 where periodo    = a_periodo
	   and monto_90   = 0
	 group by cod_agente,tipo
	 order by cod_agente,tipo

	select prim_suscrita_min,
	       crecimiento_min
	  into _prim_suscrita_min,
		   _crecimiento_min  
	  from prdrenttipo 
     where periodo  = a_periodo
       and cod_tipo = _cod_tipo 
       and activo   = 1;

		if _pri_susc_aa >= _prim_suscrita_min then

		   if _crecimiento >= _crecimiento_min then

				let _porcentaje = 0; 

				select beneficio 
				  into _porcentaje
				  from prdrenttsin
				 where periodo  = a_periodo
				   and cod_tipo = _cod_tipo
				   and _siniestralidad between rango_inicial and rango_final;

				   if _porcentaje <> 0 then

					   let _prima_maxima    = _pri_dev_max_aa + _pri_dev_max_ap;
					   let _prima_beneficio = _pri_susc_aa * (_porcentaje/100);

					   if _prima_beneficio > _prima_maxima then
						  let _bono = _prima_maxima;
					   else

						 let _bono = _prima_beneficio;

						 update rentabilidad1
							set bono       = _bono,
							    beneficio  = _porcentaje,
							    aplica     = 1 
						  where periodo    = a_periodo
							and cod_agente = _cod_agente
							and tipo       = _cod_tipo
							and monto_90   = 0
							and aplica     = 0;	
								
					   end if
				   end if
		   end if
	    end if
end foreach	  
--drop table tmp_che115a;
return 0;

END PROCEDURE                                                                                                                                                                                                 
