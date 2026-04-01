   --Hoja F - Factor de Zona Geografica
   --Estadistico para la superintendencia
   --  Armando Moreno M. 11/03/2017
   
   DROP procedure sp_super03;
   CREATE procedure sp_super03(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING char(50),integer,integer,integer,decimal(16,2),char(15),integer,integer,integer;
   
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,
		   _total_pri_sus,v_incurrido_bruto,
           _salv_y_recup,_pago_y_ded,_var_reserva		   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg,
	       v_cant_asegurados,_bien_cnt_pol,_contador_cli  INTEGER;
	define _cnt_pol integer;
	define _cod_contratante char(10);
	define _cliente_pep smallint;
	define _tipo_persona char(1);
	define _cod_asegurado,_cod_pagador char(10);
	define _n_origen char(11);
	define _porc_partic_ben, _beneficio, _suma_asegurada,_prima_agt dec(16,2);
	define _cnt integer;
	define _no_unidad,_cod_agente char(5);
	define _cod_cliente  char(10);
	define _tipo_per_cte,_tipo_agente char(1);
	define _n_agente     char(50);
	define _tipo_incendio         smallint;
	define _cantidad_j, _cnt_j integer;
	define _cod_formapag,_cod_sucursal  char(3);
	define _code_prov     char(3);
	define _cod_prov      char(2);
	define _n_prov        char(50);
	define _cod_manzana   char(15);
	define _orden_char         char(15);
	

    CREATE TEMP TABLE temp_zona_a(
			  cod_contratante  char(10),
			  code_prov		   char(3),
			  cod_sucursal     char(3),
			  prima_suscrita   dec(16,2),
			  no_poliza        char(10)
              ) WITH NO LOG;

    CREATE TEMP TABLE temp_zona_b(
			  cod_contratante  char(10),
			  no_poliza        char(10),
			  cod_manzana      char(15)
              ) WITH NO LOG;
			  
    CREATE TEMP TABLE temp_zona_aa(
			  cod_asegurado  char(10),
			  code_prov		   char(3),
			  cod_sucursal     char(3),
			  no_poliza        char(10)
              ) WITH NO LOG;
	CREATE INDEX i_perf61 ON temp_zona_aa(cod_sucursal);
	CREATE INDEX i_perf66 ON temp_zona_aa(cod_asegurado);

LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _salv_y_recup    = 0;
let _pago_y_ded      = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
LET v_cant_polizas_ma  = 0;
LET _cnt_prima_nva   = 0;
LET _cnt_prima_ren   = 0;
LET _cnt_prima_can   = 0;
let _prima_agt       = 0;
let _cantidad_j      = 0;
let _cnt_j           = 0;
let _cantidad        = 0;
let _cnt             = 0;
let _bien_cnt_pol    = 0;

SET ISOLATION TO DIRTY READ;
LET descr_cia = sp_sis01(a_cia);
-- Descomponer los periodos en fechas
LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;
--trae cant. de polizas vig. temp_perfil

CALL sp_pro95a(a_cia,a_agencia,_fecha2,'*','4;Ex',a_origen)
RETURNING v_filtros;

update prov_zona
   set cnt_contratante = 0,
       bien_cnt_cont   = 0,
	   cnt_polizas     = 0,
	   bien_cnt_pol    = 0,
	   prima_suscrita  = 0,
	   cnt_asegurado   = 0,
	   cnt_pol_ase     = 0;

--SECCION CANTIDAD
foreach
	select no_poliza,
	       prima_suscrita,
		   cod_contratante
	  into _no_poliza,
	       _prima_suscrita,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1 
	
	select code_provincia
	  into _code_prov
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	select cod_sucursal
	  into _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_contratante in('07856','75844','80162','35278','209571','314693','424664','141099') then --zona Franca
		let _cod_sucursal = '013'; -- zona franca
		let _code_prov    = '013';
	end if
	select count(*) into _cnt from zona_libre where cod_cliente = _cod_contratante; --zona libre
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then --Es cliente zona libre
		let _cod_sucursal = '014'; -- zona libre
		let _code_prov    = '014';
	end if

	insert into temp_zona_a(cod_contratante,code_prov,cod_sucursal,prima_suscrita,no_poliza)
	values(_cod_contratante,_code_prov,_cod_sucursal,_prima_suscrita,_no_poliza);
end foreach

foreach
	select cod_sucursal, 
	       count(distinct cod_contratante)
	  into _code_prov,
           _cantidad	  
	  from temp_zona_a
     group by cod_sucursal
     order by cod_sucursal desc
	
	if _code_prov not in('002','003','005','007','011','013','014') then
		let _code_prov = '001';
	end if
	 
	update prov_zona
       set cnt_contratante = cnt_contratante + _cantidad
	 where code_provincia  = _code_prov;
	 
end foreach

let _cantidad       = 0;
let _prima_suscrita = 0;
foreach
	select cod_sucursal,
	       count(distinct no_poliza),
	       sum(prima_suscrita)
	  into _cod_sucursal,
	       _cantidad,
		   _prima_suscrita
	  from temp_zona_a
	 group by 1
	 order by 1
	 
	if _cod_sucursal in('002') then --colon
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '002';
	elif _cod_sucursal in('003') then --chiriqui
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '003';
	elif _cod_sucursal in('005') then --chitre
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '005';
	elif _cod_sucursal in('007') then --chorrera
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '007';
		 
	elif _cod_sucursal in('011') then --veraguas
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '011';
	elif _cod_sucursal in('013') then --zona franca
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '013';
	elif _cod_sucursal in('014') then --zona libre
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '014';
	else
		update prov_zona
		   set cnt_polizas    = cnt_polizas    + _cantidad,
		       prima_suscrita = prima_suscrita + _prima_suscrita
		 where code_provincia  = '001';
	end if
end foreach

--SECCION bien asegurado, solo aplica Incendio
foreach
	select no_poliza,
		   cod_contratante
	  into _no_poliza,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1
       and cod_ramo = '001' 	 
	  
	foreach
		select distinct cod_manzana
		  into _cod_manzana
		  from emipouni
		 where no_poliza = _no_poliza
		   and tipo_incendio = 1
		   
			insert into temp_zona_b(cod_contratante,no_poliza,cod_manzana)
			values(_cod_contratante,_no_poliza,_cod_manzana);
	end foreach
	
end foreach	

foreach
	select distinct cod_contratante
	  into _cod_contratante
	  from temp_zona_b
	 order by cod_contratante
	 
	let _contador_cli = 1;
	
	 foreach
		select distinct no_poliza
		  into _no_poliza
		  from temp_zona_b
		 where cod_contratante = _cod_contratante
		 order by no_poliza
		
		foreach
			select cod_manzana[1,2]
			  into _cod_prov
			  from temp_zona_b
			 where cod_contratante = _cod_contratante
			   and no_poliza       = _no_poliza
			   
			if _cod_prov = '01' then	--Bocas
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '017';
			end if
			if _cod_prov = '02' then	--cocle
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '018';
			end if
			if _cod_prov = '03' then	--colon
				update prov_zona
				   set bien_cnt_cont   = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '002';
			end if
			if _cod_prov = '04' then	--chiriqui
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '003';
			end if
			if _cod_prov = '05' then	--darien
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '016';
			end if
			if _cod_prov = '06' then	--herrera
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
	                   bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '005';
			end if
			if _cod_prov = '07' then	--Los Santos
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '015';
			end if
			if _cod_prov = '08' then	--panama
				update prov_zona
				   set bien_cnt_cont   = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '001';
			end if
			if _cod_prov = '09' then	--veraguas
				update prov_zona
				   set bien_cnt_cont    = bien_cnt_cont + _contador_cli,
				       bien_cnt_pol    = bien_cnt_pol + 1
				 where code_provincia  = '011';
			end if
			let _contador_cli = 0;
		end foreach
	 end foreach
end foreach

--****seccion asegurados

--SACAR TODOS LOS ASEGURADOS Y CLASEFICARLOS POR PROVINCIA
let _cnt_pol = 0;
foreach
	select distinct no_poliza
	  into _no_poliza
	  from temp_perfil
	 where seleccionado = 1

    let _cnt_pol = 1;
	
	foreach
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		   and (activo = 1 or (activo = 0 and no_activo_desde > _fecha2))
		   
		select code_provincia
		  into _code_prov
		  from cliclien
		 where cod_cliente = _cod_asegurado;
	 
		select cod_sucursal
		  into _cod_sucursal
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_asegurado in('07856','75844','80162','35278','209571','314693','424664','141099') then --zona Franca
			let _cod_sucursal = '013'; -- zona franca
			let _code_prov    = '013';
		end if
		
		select count(*) into _cnt from zona_libre where cod_cliente = _cod_asegurado; --zona libre
		
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then --Es cliente zona libre
			let _cod_sucursal = '014'; -- zona libre
			let _code_prov    = '014';
		end if

		insert into temp_zona_aa(cod_asegurado,code_prov,cod_sucursal,no_poliza)
		values(_cod_asegurado,_code_prov,_cod_sucursal,_no_poliza);
		   
	end foreach
end foreach

--CNT ASEGURADOS
let _cantidad = 0;
foreach
	select cod_sucursal, 
	       count(distinct cod_asegurado)
	  into _code_prov,
           _cantidad	  
	  from temp_zona_aa
     group by cod_sucursal
     order by cod_sucursal desc
	
	if _code_prov not in('002','003','005','007','011','013','014') then
		let _code_prov = '001';
	end if
	 
	update prov_zona
       set cnt_asegurado = cnt_asegurado + _cantidad
	 where code_provincia  = _code_prov;
	 
end foreach

let _cantidad = 0;

--ACTUALIZAR TABLA DE SALIDA CON INFO DE LOS ASEGURADOS
foreach
	select cod_sucursal,
	       count(distinct no_poliza)
	  into _cod_sucursal,
	       _cantidad
	  from temp_zona_aa
	 group by 1
	 order by 1
	 
	if _cod_sucursal in('002') then --colon
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '002';
	elif _cod_sucursal in('003') then --chiriqui
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '003';
	elif _cod_sucursal in('005') then --chitre
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '005';
	elif _cod_sucursal in('007') then --chorrera
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '007';
	elif _cod_sucursal in('011') then --veraguas
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '011';
	elif _cod_sucursal in('013') then --zona franca
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '013';
	elif _cod_sucursal in('014') then --zona libre
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '014';
	else
		update prov_zona
		   set cnt_pol_ase    = cnt_pol_ase    + _cantidad
		 where code_provincia  = '001';
	end if
end foreach
	 
let _prima_suscrita = 0;
let _cantidad = 0;
let v_cant_polizas = 0;

--SALIDA***
foreach
	select orden,nombre, cnt_contratante,bien_cnt_cont,cnt_polizas,prima_suscrita,bien_cnt_pol,cnt_asegurado,cnt_pol_ase
	  into _orden_char,_n_prov,_cnt,_cnt_cerra,_cnt_pol,_prima_suscrita,_bien_cnt_pol,_cantidad,v_cant_polizas
	  from prov_zona
	  order by orden
	  
	if _cnt = 0 and _cnt_cerra = 0 and _cnt_pol = 0 and _prima_suscrita = 0 and _bien_cnt_pol = 0 then
		continue foreach;
	end if
	return _n_prov,_cnt,_cnt_cerra,_cnt_pol,_prima_suscrita,_orden_char,_bien_cnt_pol,_cantidad,v_cant_polizas with resume;
end foreach

drop table temp_perfil;
drop table temp_zona_a;
drop table temp_zona_b;
drop table temp_zona_aa;
END PROCEDURE;