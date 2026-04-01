   --Estadistico para la superintendencia
   --  Armando Moreno M. 27/12/2022
   
   DROP procedure sp_super0101;
   CREATE procedure sp_super0101(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7),a_origen CHAR(3) default "%")
   RETURNING char(20),varchar(50),varchar(50),varchar(50),varchar(30),varchar(30),varchar(30),char(50),char(50),char(50),
             date,date,date,char(50),varchar(30),smallint,dec(16,2),decimal(16,2),char(30),varchar(50);
   
   
    DEFINE _cod_ramo           CHAR(3);
    DEFINE n_ramo,n_agente     CHAR(50);
    DEFINE descr_cia	       CHAR(45);
	define _n_perpago          char(40);
    DEFINE _no_poliza          CHAR(10);
    DEFINE _prima_suscrita     DECIMAL(16,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _fecha_suscripcion, _vig_fin     DATE;
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad,_cod_riesgo            INTEGER;
	define _cod_origen        CHAR(3);
	define _cod_contratante char(10);
	define _cliente_pep smallint;
	define _tipo_persona char(1);
	define _cod_asegurado,_cod_pagador,_cod_agente char(10);
	define _no_documento char(20);
	define n_riesgo,_ced_aseg,_ced_cont,_ced_pag      varchar(30);
	define _n_origen char(11);
	define _suma_asegurada dec(16,2);
	define _cnt 				integer;
	define _no_unidad 			char(5);
	define _cod_perpago 		char(3);
	define _cod_cliente  		char(10);
	define _nacionalidad,_nacionalidad_ase,_nacionalidad_pag,n_cont,n_aseg,n_pag             varchar(50);
		

CREATE TEMP TABLE temp_contpol(
              cod_contratante CHAR(10),
			  cod_asegurado   char(10),
			  cod_pagador     char(10),
              no_documento    CHAR(20),
              cod_agente      char(10),
			  n_agente        char(100),
			  suma            decimal(16,2),
              prima           decimal(16,2),
			  fecha_susc      date,
			  vigencia_inic   date,
			  vigencia_final  date,
			  ramo            char(50),
			  frec_pago       char(40),
			  tipo_persona    char(1)
              ) WITH NO LOG;			  

LET _prima_suscrita  = 0;

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

--CONTRANTANTES MAYORES A 10,000 TODOS
foreach
	select cod_contratante,
	       sum(prima_suscrita)
	  into _cod_contratante,
	       _prima_suscrita
	  from temp_perfil
	 where seleccionado = 1
	 group by cod_contratante
	having sum(prima_suscrita) >= 10000
	
	select tipo_persona
	  into _tipo_persona
	  from cliclien
     where cod_cliente = _cod_contratante;
	 
	foreach
		select no_documento,
		       no_poliza,
	           prima_suscrita,
			   vigencia_inic,
			   vigencia_final,
			   suma_asegurada,
			   cod_pagador,
			   fecha_suscripcion,
			   cod_ramo
	      into _no_documento,
		       _no_poliza,
	           _prima_suscrita,
		       _vigencia_inic,
			   _vig_fin,
			   _suma_asegurada,
			   _cod_pagador,
			   _fecha_suscripcion,
			   _cod_ramo
	      from temp_perfil
	     where seleccionado = 1
	       and cod_contratante = _cod_contratante
		   
		select cod_perpago
		  into _cod_perpago
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _n_perpago
		  from cobperpa
		 where cod_perpago = _cod_perpago;        		 
		   
		foreach
			select cod_asegurado
			  into _cod_asegurado
			  from emipouni
			 where no_poliza = _no_poliza
			 
			exit foreach; 
		end foreach
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			exit foreach; 
		end foreach
		
		select nombre
          into n_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		select nombre
          into n_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
		  
		insert into temp_contpol(cod_contratante,cod_asegurado,cod_pagador,no_documento,n_agente,suma,prima,fecha_susc,vigencia_inic,vigencia_final,ramo,frec_pago,tipo_persona)
		values(_cod_contratante,_cod_asegurado,_cod_pagador,_no_documento,n_agente,_suma_asegurada,_prima_suscrita,_fecha_suscripcion,_vigencia_inic,_vig_fin,n_ramo,_n_perpago,_tipo_persona);
	end foreach
	  
end foreach

foreach
	select cod_contratante,
	       sum(prima)
	  into _cod_contratante,
           _prima_suscrita
      from temp_contpol
     where tipo_persona = 'J'
     group by cod_contratante
     having sum(prima) >= 50000

	foreach
		select no_documento,
			   cod_asegurado,
		       cod_pagador,
			   fecha_susc,
			   vigencia_inic,
			   vigencia_final,
			   ramo,
			   suma,
			   prima,
			   frec_pago,
			   n_agente
	      into _no_documento,
		       _cod_asegurado,
			   _cod_pagador,
			   _fecha_suscripcion,
			   _vigencia_inic,
			   _vig_fin,
			   n_ramo,
			   _suma_asegurada,
			   _prima_suscrita,
			   _n_perpago,
			   n_agente
		  from temp_contpol
         where cod_contratante = _cod_contratante
		 
		select nombre,cedula,cliente_pep,nacionalidad
          into n_cont,_ced_cont,_cliente_pep,_nacionalidad
          from cliclien
	     where cod_cliente = _cod_contratante;
		 
		select nombre,cedula,nacionalidad
          into n_aseg,_ced_aseg,_nacionalidad_ase
          from cliclien
	     where cod_cliente = _cod_asegurado;
		 
		select nombre,cedula,nacionalidad
          into n_pag,_ced_pag,_nacionalidad_pag
          from cliclien
	     where cod_cliente = _cod_pagador;
		 
		select cod_riesgo into _cod_riesgo from ponderacion
        where cod_cliente = _cod_contratante;
        		
		select nombre into n_riesgo from cliriesgo
		where cod_riesgo = _cod_riesgo;
		 
		return _no_documento, n_cont, n_aseg, n_pag,_ced_cont,_ced_aseg,_ced_pag,_nacionalidad,_nacionalidad_ase,_nacionalidad_pag, _fecha_suscripcion, _vigencia_inic, _vig_fin, n_ramo,n_riesgo, 
		       _cliente_pep,_suma_asegurada, _prima_suscrita, _n_perpago, n_agente with resume;
		
	end foreach
	drop table temp_contpol;
end foreach
END PROCEDURE;