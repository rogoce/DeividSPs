   --Hoja C - Factor Cliente
   --Estadistico para la superintendencia
   --  Armando Moreno M. 09/03/2017
   
   DROP procedure sp_super01bk;
   CREATE procedure sp_super01bk(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING smallint,char(11),char(1),integer,integer,dec(16,2);
   
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
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	define _cnt_pol integer;
	define _cod_contratante char(10);
	define _cliente_pep smallint;
	define _tipo_persona char(1);
	define _cod_asegurado,_cod_pagador char(10);
	define _n_origen char(11);
	define _porc_partic_ben, _beneficio, _suma_asegurada dec(16,2);
	define _cnt integer;
	define _no_unidad char(5);
	define _cod_cliente  char(10);
	--define _cnt_pol_n,_cnt_ase_n,_cnt_pol_j,_cnt_ase_j integer;
	

    CREATE TEMP TABLE temp_contratante(
              tipo_persona     CHAR(1),
              origen           CHAR(3),
              cant_polizas     INT,
              prima_anualizada decimal(16,2),
			  es_pep           smallint default 0
              ) WITH NO LOG;

	CREATE TEMP TABLE temp_pagador(
              tipo_persona     CHAR(1),
              origen           CHAR(3),
              cant_polizas     INT,
              prima_anualizada decimal(16,2),
			  es_pep           smallint default 0
              ) WITH NO LOG;			  

	CREATE TEMP TABLE temp_asegurado2(
              tipo_persona     CHAR(1),
              origen           CHAR(3),
              cant_polizas     INT,
              prima_anualizada decimal(16,2),
			  es_pep           smallint default 0
              ) WITH NO LOG;			  

    CREATE TEMP TABLE temp_asegurado(
              cod_asegurado    CHAR(10),
			  prima_suscrita   DECIMAL(16,2),
			  cant_pol         integer)
              WITH NO LOG;
	CREATE INDEX i_perf6 ON temp_asegurado(cod_asegurado);
	
    CREATE TEMP TABLE temp_benef(
	          no_poliza        CHAR(10),
			  no_unidad        CHAR(5),
              cod_asegurado    CHAR(10),
			  prima_suscrita   DECIMAL(16,2),
			  cant_pol         integer)
              WITH NO LOG;
	CREATE INDEX i_perf1 ON temp_benef(cod_asegurado);

	CREATE TEMP TABLE temp_benef2(
              tipo_persona     CHAR(1),
              origen           CHAR(3),
              cant_polizas     INT,
              prima_anualizada decimal(16,2),
			  es_pep           smallint default 0
              ) WITH NO LOG;			  

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
CALL sp_pro95a(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;

--CONTRANTANTES
foreach
	select cod_contratante,
	       sum(prima_suscrita),
		   count(no_poliza)
	  into _cod_contratante,
	       _prima_suscrita,
		   _cnt_pol
	  from temp_perfil
	 group by cod_contratante
	having sum(prima_suscrita) >= 10000
	
	select cod_origen,
	       cliente_pep,
		   tipo_persona
	  into _cod_origen,
	       _cliente_pep,
		   _tipo_persona
	  from cliclien
     where cod_cliente = _cod_contratante;
	 
	{if _cliente_pep = 1 then
		continue foreach;
	end if}
	 
	insert into temp_contratante(tipo_persona,origen,cant_polizas,prima_anualizada,es_pep)
	values(_tipo_persona,_cod_origen,_cnt_pol,_prima_suscrita,_cliente_pep);
	  
end foreach

--CLIENTES PEP
foreach
	select cod_contratante,
	       sum(prima_suscrita),
		   count(no_poliza)
	  into _cod_contratante,
	       _prima_suscrita,
		   _cnt_pol
	  from temp_perfil
	 group by cod_contratante
	
	select cod_origen,
	       cliente_pep,
		   tipo_persona
	  into _cod_origen,
	       _cliente_pep,
		   _tipo_persona
	  from cliclien
     where cod_cliente = _cod_contratante;
	 
	if _tipo_persona = "N" then
	else
		continue foreach;
	end if
	if _cliente_pep = 0 then
		continue foreach;
	end if
	insert into temp_contratante(tipo_persona,origen,cant_polizas,prima_anualizada,es_pep)
	values(_tipo_persona,_cod_origen,_cnt_pol,_prima_suscrita,_cliente_pep);
end foreach

--ASEGURADOS
foreach
	select distinct no_poliza
	  into _no_poliza
	  from temp_perfil

	foreach
		select cod_asegurado, prima_suscrita
		  into _cod_asegurado,_prima_suscrita
		  from emipouni
		 where no_poliza = _no_poliza
		 
		insert into temp_asegurado(cod_asegurado,prima_suscrita,cant_pol)
		values(_cod_asegurado,_prima_suscrita,1);
		 
	end foreach
end foreach
--ASEGURADOS
foreach
	select cod_asegurado,
	       sum(prima_suscrita),
		   sum(cant_pol)
	  into _cod_asegurado,
		   _prima_suscrita,
		   _cnt_pol
	  from temp_asegurado
	 group by cod_asegurado
	having sum(prima_suscrita) >= 10000
	
	select cod_origen,
	       cliente_pep,
		   tipo_persona
	  into _cod_origen,
	       _cliente_pep,
		   _tipo_persona
	  from cliclien
     where cod_cliente = _cod_asegurado;
	 
	{if _cliente_pep = 1 then
		continue foreach;
	end if}
	 
	insert into temp_asegurado2(tipo_persona,origen,cant_polizas,prima_anualizada,es_pep)
	values(_tipo_persona,_cod_origen,_cnt_pol,_prima_suscrita,_cliente_pep);
end foreach

--PAGADORES
foreach
	select cod_pagador,
	       sum(prima_suscrita),
		   count(no_poliza)
	  into _cod_pagador,
	       _prima_suscrita,
		   _cnt_pol
	  from temp_perfil
	 group by cod_pagador
	having sum(prima_suscrita) >= 10000
	
	select cod_origen,
	       cliente_pep,
		   tipo_persona
	  into _cod_origen,
	       _cliente_pep,
		   _tipo_persona
	  from cliclien
     where cod_cliente = _cod_pagador;
	 
	{if _cliente_pep = 1 then
		continue foreach;
	end if}
	 
	insert into temp_pagador(tipo_persona,origen,cant_polizas,prima_anualizada,es_pep)
	values(_tipo_persona,_cod_origen,_cnt_pol,_prima_suscrita,_cliente_pep);
	  
end foreach

--BENEFICIARIOS
foreach
	select distinct no_poliza
	  into _no_poliza
	  from temp_perfil
	 where cod_ramo in('016','019')	--solo polizas de vida

	foreach
		select no_unidad,cod_asegurado, prima_suscrita, suma_asegurada
		  into _no_unidad,_cod_asegurado,_prima_suscrita, _suma_asegurada
		  from emipouni
		 where no_poliza = _no_poliza
		 
		if _suma_asegurada >= 50000 then
			select count(*)
			  into _cnt
			  from emibenef
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad;
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then	
				foreach
				
					select porc_partic_ben,
					       cod_cliente
					  into _porc_partic_ben,
						   _cod_cliente
					  from emibenef
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					   
					let _beneficio = 0;   
					let _beneficio = _suma_asegurada * _porc_partic_ben /100;
					if _beneficio >= 50000 then
						let _cnt_pol = 1;
						select count(*)
						  into _cnt
						  from temp_benef
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
						if _cnt is null then
							let _cnt = 0;
						end if
						if _cnt > 0 then
							let _prima_suscrita = 0;
							let _cnt_pol        = 0;
						end if
						insert into temp_benef(no_poliza,no_unidad,cod_asegurado,prima_suscrita,cant_pol)
						values(_no_poliza,_no_unidad,_cod_cliente,_prima_suscrita,_cnt_pol);
					end if
					   
				end foreach
			end if
		else
			continue foreach;
		end if
	end foreach
end foreach

--BENEFICIARIOS NOPEP
foreach
	select cod_asegurado,
	       sum(prima_suscrita),
		   sum(cant_pol)
	  into _cod_asegurado,
		   _prima_suscrita,
		   _cnt_pol
	  from temp_benef
	 group by cod_asegurado
	
	select cod_origen,
	       cliente_pep,
		   tipo_persona
	  into _cod_origen,
	       _cliente_pep,
		   _tipo_persona
	  from cliclien
     where cod_cliente = _cod_asegurado;
	 
	{if _cliente_pep = 1 then
		continue foreach;
	end if}
	 
	insert into temp_benef2(tipo_persona,origen,cant_polizas,prima_anualizada,es_pep)
	values(_tipo_persona,_cod_origen,_cnt_pol,_prima_suscrita,_cliente_pep);
end foreach

--****salida
--CONTRATANTES******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_contratante
	 where tipo_persona in('N','J')
	   --and es_pep = 0
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 1,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--ASEGURADOS******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_asegurado2
	 where tipo_persona in('N','J')
	   --and es_pep = 0
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 2,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--PAGADOR******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_pagador
	 where tipo_persona in('N','J')
	   --and es_pep = 0
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 3,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--BENEFICIARIOS******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_benef2
	 where tipo_persona in('N','J')
	   --and es_pep = 0
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 4,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--CLIENTES PEPS******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_contratante
	 where tipo_persona in('N','J')
	   and es_pep = 1
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 5,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--ASEGURADOS PEP******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_asegurado2
	 where tipo_persona in('N','J')
	   and es_pep = 1
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 6,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--PAGADOR PEP******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_pagador
	 where tipo_persona in('N','J')
	   and es_pep = 1
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 7,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
--BENEFICIARIOS PEP******************
foreach
	select origen,
	       tipo_persona,
		   sum(cant_polizas),
		   sum(prima_anualizada),
		   count(tipo_persona)
	  into _cod_origen,
	       _tipo_persona,
		   _cnt_pol,
		   _prima_suscrita,
		   _cantidad_aseg
	  from temp_benef2
	 where tipo_persona in('N','J')
	   and es_pep = 1
	 group by origen,tipo_persona
	 order by origen,tipo_persona desc
	  
	  if _cod_origen = '001' then
		let _n_origen = 'NACIONALES';
	  else
		let _n_origen = 'EXTRANJEROS';
	  end if
	  
	  return 8,_n_origen,_tipo_persona,_cantidad_aseg,_cnt_pol,_prima_suscrita with resume;
end foreach
drop table temp_perfil;
drop table temp_contratante;
drop table temp_pagador;
drop table temp_asegurado;
drop table temp_asegurado2;
drop table temp_benef;
drop table temp_benef2;
END PROCEDURE;