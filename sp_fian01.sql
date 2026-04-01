-- Fianzas   
-- 
-- Creado    : 25/11/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_fian01;
CREATE procedure "informix".sp_fian01(
a_cia 			CHAR(3),
a_cod_ramo      CHAR(3),
a_cod_subramo   CHAR(3),
a_no_poliza  CHAR(20),
a_tipo       CHAR(10) default "ACREEDOR"
)
RETURNING VARCHAR(50),
		  VARCHAR(50),
		  VARCHAR(50),
		  VARchar(20),
		  VARchar(100),
		  varchar(255),
		  dec(16,2),
		  varchar(50),
		  varchar(30),
		  varchar(255),
		  varchar(10),
		  varchar(5),
		  varchar(100),
		  varchar(100),
		  varchar(255),
		  integer,
		  varchar(30),
		  varchar(30),
		  varchar(30),
		  varchar(50),
		  char(10);

BEGIN
	DEFINE v_documento 			   VARCHAR(20);
	DEFINE v_descr_cia 			   VARCHAR(50);
	DEFINE v_nombre_ramo		   CHAR(50);
	DEFINE v_nombre_subramo 	   CHAR(50);
	DEFINE v_nombre_asegurado 	   VARCHAR(100);
	DEFINE v_cod_contratante       CHAR(10);
	DEFINE v_suma_asegurada        dec(16,2); 
    DEFINE _monto_letras           varchar(255);
	DEFINE v_suscripcion           date;
	DEFINE v_fecha_letra_firma     VARCHAR(50);
	DEFINE v_fecha_letra_final     VARCHAR(30);
	DEFINE v_fecha_letra_inicial   VARCHAR(30);
	DEFINE v_fecha_letra_adicional VARCHAR(30);
	DEFINE v_fecha_letra           VARCHAR(30);
	DEFINE v_fecha_letra_obliga    VARCHAR(30);
	DEFINE v_dia           		   CHAR(2);
	DEFINE v_ano           		   CHAR(4);
	DEFINE v_vig_final             date;
	define v_vig_inicial           date;
	define v_vig_adicional         date;
	DEFINE v_fecha_garantia        date;
	DEFINE v_descripcion           VARCHAR(255);
	DEFINE v_desc                  VARCHAR(255);
	DEFINE _cnt_unidad             SMALLINT;
	DEFINE v_no_unidad             varchar(5);
	DEFINE v_secuestrado           varchar(100);
	define v_demandante            varchar(100);
	define v_beneficiario          varchar(255);
	define v_dias                  varchar(50);
	define v_no_documento          varchar(20);
	define v_tipo_fianza           integer;
	define v_predeclara            varchar(50);
	
	SET ISOLATION TO DIRTY READ;
	
--	SET DEBUG FILE TO "sp_fian01.trc";
--	TRACE ON;
	

	LET v_descr_cia   	= trim(upper(sp_sis01(a_cia)));
	let v_descripcion 	= "";
	let v_desc        	= "";
	let v_secuestrado 	= "";
	let v_demandante  	= "";
	let v_beneficiario  = "";
	let v_dia    		= 0;
    let v_tipo_fianza   = 0; 	
	let v_predeclara    = "";
	
	select cod_contratante,
	       suma_asegurada,
		   fecha_suscripcion,
		   vigencia_final,
		   no_documento,
		   vigencia_inic,
		   vigencia_final + day(30)
	  into v_cod_contratante,
		   v_suma_asegurada,
		   v_suscripcion,
		   v_vig_final,
		   v_no_documento,
		   v_vig_inicial,
		   v_vig_adicional
	  from emipomae
	 where no_poliza =  a_no_poliza;
	 
	select nombre
	  into v_nombre_asegurado
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
	   
	Let _monto_letras  		= sp_sis11a(v_suma_asegurada);
	let _monto_letras 		= trim(_monto_letras);
	let v_fecha_letra_final = sp_sis40c(v_vig_final);
	let v_fecha_letra_inicial = sp_sis40c(v_vig_inicial);
	let v_fecha_letra_adicional = sp_sis40c(v_vig_adicional);
	
	select count(*)
	  into _cnt_unidad
	  from emipouni
	 where no_poliza = a_no_poliza;
	
	if _cnt_unidad = 1 then
		select no_unidad
		  into v_no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza;
		 
		select secuestrado,
			   demandante,
			   beneficiario,
			   dias,
			   tipo_fianza,
			   predeclara,
			   fecha_garantia			   
		  into v_secuestrado,
			   v_demandante,
			   v_beneficiario,
			   v_dias,
			   v_tipo_fianza,
			   v_predeclara,
			   v_fecha_garantia
		  from emifian1
		 where no_poliza = a_no_poliza
		   and no_unidad = v_no_unidad;
		
		let v_fecha_letra_obliga = sp_sis40c(v_fecha_garantia);
	
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
		
	end if
	let v_fecha_letra_firma	= sp_sis40c(v_suscripcion,a_cod_subramo,v_tipo_fianza);
		
		if v_tipo_fianza <> 5 then
			let v_fecha_letra_firma = trim(upper(v_fecha_letra_firma));
		end if
	
	return upper(trim(v_descr_cia)),                --1
	       v_nombre_ramo,              				--2
		   v_nombre_subramo,           				--3
		   trim(v_no_documento),             				--4
		   trim(upper(v_nombre_asegurado)),         --5
		   _monto_letras,              				--6
		   v_suma_asegurada,           				--7
		   v_fecha_letra_firma,        				--8
		   trim(upper(v_fecha_letra_final)),        --9
		   trim(v_desc),                    			   --10
		   a_no_poliza,               			   --11
		   v_no_unidad,         			       --12
		   upper(v_secuestrado),             			   --13
		   upper(v_demandante),						   --14
		   upper(v_beneficiario),          			   --15
		   v_dia,                 				   --16
		   trim(upper(v_fecha_letra_inicial)),   			   --17
		   trim(upper(v_fecha_letra_adicional)),  			   --18
		   trim(upper(v_fecha_letra_obliga)),          --19
		   trim(upper(v_predeclara)),                  --20
		   a_tipo                                      --21
           with resume;
END
END PROCEDURE;
