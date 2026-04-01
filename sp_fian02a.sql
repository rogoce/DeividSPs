-- Fianzas de cumplimiento estatal actualizacion
-- Creado    : 08/08/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_fian02a;
CREATE procedure "informix".sp_fian02a(
a_cia 			CHAR(3),
a_cod_ramo      CHAR(3),
a_cod_subramo   CHAR(3),
a_no_poliza  CHAR(20),
a_tipo       CHAR(10) default "ACREEDOR"
)
RETURNING varchar(50),
		  varchar(50),
		  varchar(50),
		  varchar(20),
		  varchar(100),
		  varchar(255),
		  dec(16,2),
		  varchar(30),
		  varchar(30),
		  varchar(255),
		  varchar(30),
		  varchar(30),
		  varchar(50),
		  varchar(30),
		  varchar(20),
		  varchar(2),
		  varchar(4),
		  varchar(10),
		  varchar(5),
		  varchar(100),
		  varchar(100),
		  varchar(255),
		  varchar(50),
		  varchar(30),
		  varchar(30),
		  char(10),
		  date,
		  date,
		  varchar(100);

BEGIN
	DEFINE v_documento 			 CHAR(20);
	DEFINE v_descr_cia 			 CHAR(50);
	DEFINE v_nombre_ramo		 CHAR(50);
	DEFINE v_nombre_subramo 	 CHAR(50);
	DEFINE v_nombre_asegurado 	 CHAR(50);
	DEFINE v_nombre_contratante  VARCHAR(100);
	DEFINE v_cod_contratante     CHAR(10);
	DEFINE v_suma_asegurada      dec(16,2); 
    DEFINE _monto_letras         varchar(255);
	DEFINE v_suscripcion,v_fecha_emision         date;
	DEFINE v_fecha_mes           VARCHAR(30);
	DEFINE v_fecha_letra_final   VARCHAR(30);
	DEFINE v_fecha_letra_acto    VARCHAR(30);
	DEFINE v_fecha_letra_inicial VARCHAR(30);
	DEFINE v_fecha_letra         VARCHAR(30);
	DEFINE v_dia           		 CHAR(2);
	DEFINE v_ano           		 CHAR(4);
	DEFINE v_vig_final           date;
	DEFINE v_descripcion         VARCHAR(255);
	DEFINE v_desc                VARCHAR(255);
	DEFINE v_cedula_asegurado    VARCHAR(30);
	DEFINE v_cedula_contratante  VARCHAR(30);
	DEFINE v_vig_inicial         date;
	DEFINE _cnt_unidad           SMALLINT;
	DEFINE v_cod_asegurado       CHAR(10);
	DEFINE v_sexo                char(1);
	DEFINE v_desc_sexo           char(20);
	DEFINE v_no_unidad           varchar(5);	
	DEFINE _acto_publico         varchar(100);
	DEFINE v_secuestrado         varchar(100);
	DEFINE v_demandante          varchar(100);
	DEFINE v_beneficiario        varchar(255);
	DEFINE v_dias                varchar(50);
	DEFINE v_fecha_acto          date;
	DEFINE v_no_documento        varchar(20);
	DEFINE v_fecha_garantia      date;
	DEFINE v_fecha_letra_garantia VARCHAR(30);
	
	SET ISOLATION TO DIRTY READ;

	LET v_descr_cia = sp_sis01(a_cia);
	let v_descripcion 	= "";
	let v_desc        	= "";
	let v_secuestrado 	= "";
	let v_demandante  	= "";
	let v_beneficiario  = "";
	let v_dia    		= 0;     
	
	select cod_contratante,
	       suma_asegurada,
		   fecha_suscripcion,
		   vigencia_final,
		   vigencia_inic,
		   no_documento
	  into v_cod_contratante,
		   v_suma_asegurada,
		   v_suscripcion,
		   v_vig_final,
		   v_vig_inicial,
		   v_no_documento
	  from emipomae
	 where no_poliza =  a_no_poliza;
	 
	select cedula,
	       nombre
	  into v_cedula_contratante,
	       v_nombre_contratante
	  from cliclien
	 where cod_cliente = v_cod_contratante;
 	
	select nombre 
	  into v_nombre_ramo
	  from prdramo
	 where cod_ramo = a_cod_ramo;
	 
	select nombre
	  into v_nombre_subramo
	  from prdsubra
	 where cod_ramo    = a_cod_ramo
	   and cod_subramo = a_cod_subramo;
	   
	Let _monto_letras  			= sp_sis11a(v_suma_asegurada);
	let _monto_letras 			= trim(_monto_letras);
	let v_fecha_letra_final 	= sp_sis40c(v_vig_final);
	let v_fecha_letra_inicial 	= sp_sis40c(v_vig_inicial);
	
		IF MONTH(v_suscripcion) = 1 THEN
		  LET v_fecha_mes = 'enero';
		ELIF MONTH(v_suscripcion) = 2 THEN
		  LET v_fecha_mes = 'febrero';
		ELIF MONTH(v_suscripcion) = 3 THEN
		  LET v_fecha_mes = 'marzo';
		ELIF MONTH(v_suscripcion) = 4 THEN
		  LET v_fecha_mes = 'abril';
		ELIF MONTH(v_suscripcion) = 5 THEN
		  LET v_fecha_mes = 'mayo';
		ELIF MONTH(v_suscripcion) = 6 THEN
		  LET v_fecha_mes = 'junio';
		ELIF MONTH(v_suscripcion) = 7 THEN
		  LET v_fecha_mes = 'julio';
		ELIF MONTH(v_suscripcion) = 8 THEN
		  LET v_fecha_mes = 'agosto';
		ELIF MONTH(v_suscripcion) = 9 THEN
		  LET v_fecha_mes = 'septiembre';
		ELIF MONTH(v_suscripcion) = 10 THEN
		  LET v_fecha_mes = 'octubre';
		ELIF MONTH(v_suscripcion) = 11 THEN
		  LET v_fecha_mes = 'noviembre';
		ELIF MONTH(v_suscripcion) = 12 THEN
		  LET v_fecha_mes = 'diciembre';
		END IF
		LET v_dia = DAY(v_suscripcion);
		LET v_ano = YEAR(v_suscripcion);
		
		if v_dia < 10 then
			let v_dia = "0"||v_dia;
		end if
	
	select count(*)
	  into _cnt_unidad
	  from emipouni
	 where no_poliza = a_no_poliza;
	
	if _cnt_unidad = 1 then
	
		select cod_asegurado,
		       no_unidad
		  into v_cod_asegurado,
		       v_no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza;
		 
		select cedula,
			   nombre,
			   sexo
		  into v_cedula_asegurado,
			   v_nombre_asegurado,
			   v_sexo
		  from cliclien
		 where cod_cliente = v_cod_asegurado;
		 
		IF v_sexo = 'M' then
			let v_desc_sexo = 'MASCULINO';
		ELSE
			let v_desc_sexo = 'FEMENINO';
		END IF
		
		select secuestrado,
			   demandante,
			   beneficiario,
			   dias,
			   fecha_acto,
			   fecha_garantia,
			   fecha_entrega,
			   acto_publico
		  into v_secuestrado,
			   v_demandante,
			   v_beneficiario,
			   v_dias,
			   v_fecha_acto,
			   v_fecha_garantia,
			   v_fecha_emision,
			   _acto_publico
		  from emifian1
		 where no_poliza = a_no_poliza
		   and no_unidad = v_no_unidad;
		
			let v_fecha_letra_acto 	= sp_sis40c(v_fecha_acto);
			let v_fecha_letra_garantia = sp_sis40c(v_fecha_garantia);
		
		foreach 
			select descripcion 
			  into v_descripcion
			  from blobuni
			 where no_poliza = a_no_poliza
			   and no_unidad = v_no_unidad
			   and no_endoso = '00000'
			
			let v_desc = trim( v_desc) || " " || trim(v_descripcion);
			
			if v_descripcion is null or trim(v_descripcion) = "" then
				exit foreach;
			end if
			
		end foreach 
		return upper(trim(v_descr_cia)),
			   upper(trim(v_nombre_ramo)),
			   upper(trim(v_nombre_subramo)),
			   v_no_documento,
			   upper(trim(v_nombre_contratante)),
			   upper(trim(_monto_letras)),
			   v_suma_asegurada,
			   upper(trim(v_fecha_mes)),
			   upper(trim(v_fecha_letra_final)),
			   trim(v_desc),
			   v_cedula_asegurado,
			   v_cedula_contratante,
			   upper(trim(v_nombre_asegurado)),
			   upper(trim(v_fecha_letra_inicial)),
			   upper(trim(v_desc_sexo)),
			   upper(trim(v_dia)),
			   upper(trim(v_ano)),
			   a_no_poliza,
			   v_no_unidad,
			   upper(trim(v_secuestrado)),
			   upper(trim(v_demandante)),
			   upper(trim(v_beneficiario)),
			   upper(trim(v_dias)),
			   upper(trim(v_fecha_letra_acto)),
			   upper(trim(v_fecha_letra_garantia)),
			   a_tipo,
			   v_suscripcion,
			   v_fecha_emision,
			   _acto_publico
			   with resume;
	end if
END
END PROCEDURE;
