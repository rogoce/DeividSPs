-- Fianzas de cumplimiento   
-- 
-- Creado    : 25/11/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_fian03;
CREATE procedure "informix".sp_fian03(
a_cia 			CHAR(3),
a_cod_ramo      CHAR(3),
a_cod_subramo   CHAR(3),
a_no_poliza  CHAR(20),
a_tipo       CHAR(10) DEFAULT 'ACREEDOR'
)
RETURNING varCHAR(50),
		  varCHAR(50),
		  varCHAR(50),
		  varchar(20),
		  varchar(50),
		  varchar(255),
		  varchar(255),
		  varchar(30),
		  varchar(30),
		  varchar(255),
		  varchar(10),
		  varchar(5),
		  varchar(100),
		  varchar(100),
		  varchar(100),
		  integer,
		  varchar(30),
		  varchar(30),
		  dec(16,2),
		  dec(16,2),
		  CHAR(10);
	--	  Lvarchar(3500);

BEGIN
	DEFINE v_documento 			   CHAR(20);
	DEFINE v_descr_cia 			   CHAR(50);
	DEFINE v_nombre_ramo		   CHAR(50);
	DEFINE v_nombre_subramo 	   CHAR(50);
	DEFINE v_nombre_asegurado 	   CHAR(50);
	DEFINE v_cod_contratante       CHAR(10);
	DEFINE v_suma_m_asegurada      dec(16,2); 
	DEFINE v_porc_suma             dec(16,2); 
    DEFINE _suma_maxima            varchar(255);
	DEFINE _suma_garantia          varchar(255);
	DEFINE v_suscripcion           date;
	DEFINE v_fecha_letra_firma     VARCHAR(30);
	DEFINE v_fecha_letra_final     VARCHAR(30);
	DEFINE v_fecha_letra_inicial   VARCHAR(30);
	DEFINE v_fecha_letra_adicional VARCHAR(30);
	DEFINE v_fecha_letra           VARCHAR(30);
	DEFINE v_dia           		   CHAR(2);
	DEFINE v_ano           		   CHAR(4);
	DEFINE v_vig_final             date;
	define v_vig_inicial           date;
	define v_vig_adicional          date;
	DEFINE v_descripcion           VARCHAR(255);
	DEFINE v_desc                  VARCHAR(255);
	DEFINE _cnt_unidad             SMALLINT;
	DEFINE v_no_unidad             varchar(5);
	DEFINE v_secuestrado           varchar(100);
	define v_demandante            varchar(100);
	define v_beneficiario          varchar(100);
	define v_dias                  integer;
	define v_no_documento          varchar(20);
	define v_desc_emifiandesc	   Lvarchar(3500);
	define _salto                  varchar(10);
	
	
	SET ISOLATION TO DIRTY READ;

	LET v_descr_cia   		= sp_sis01(a_cia);
	let v_descripcion 		= "";
	let v_desc        		= "";
	let v_secuestrado 		= "";
	let v_demandante  		= "";
	let v_beneficiario  	= "";
	let v_dia    			= 0;
    let v_porc_suma     	= 0;
	let v_suma_m_asegurada  = 0;
	let _suma_garantia		= " ";
	let _suma_maxima        = " ";

	--let _salto            = "+char(10)+";
	
	--let v_desc_emifiandesc = "HOLA "||hex(10)||" HOLA" ; 

	
	select cod_contratante,
		   fecha_suscripcion,
		   vigencia_final,
		   no_documento,
		   vigencia_inic,
		   vigencia_final + day(30)
	  into v_cod_contratante,
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
	   
	let v_fecha_letra_firma	= sp_sis40c(v_suscripcion,a_cod_subramo);
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
			   suma_maxima,
			   porc_suma
		  into v_secuestrado,
			   v_demandante,
			   v_beneficiario,
			   v_dias,
			   v_suma_m_asegurada,
			   v_porc_suma
		  from emifian1
		 where no_poliza = a_no_poliza
		   and no_unidad = v_no_unidad;
		   
		Let _suma_maxima  		= sp_sis11(v_suma_m_asegurada);
		let _suma_maxima 		= trim(_suma_maxima);
		
		Let _suma_garantia 		= sp_sis11(v_porc_suma);
		let _suma_garantia 		= trim(_suma_garantia);   		
		
		foreach 
			select descripcion 
			  into v_descripcion
			  from blobuni
			 where no_poliza = a_no_poliza
			   and no_unidad = v_no_unidad
			   and no_endoso = '00000'
			let v_desc = trim( v_desc) || " " || trim(v_descripcion);   
			
		end foreach   
		
	end if	 
	return trim(v_descr_cia),                --1
	       v_nombre_ramo,              --2
		   v_nombre_subramo,           --3
		   v_no_documento,             --4
		   upper(trim(v_nombre_asegurado)),         --5
		   _suma_maxima,               --6
		   _suma_garantia,             --7
		   upper(trim(v_fecha_letra_firma)),        --8
		   upper(trim(v_fecha_letra_final)),        --9
		   v_desc,                    --10
		   a_no_poliza,               --11
		   v_no_unidad,               --12
		   v_secuestrado,             --13
		   v_demandante,              --14
		   v_beneficiario,            --15
		   v_dia,                     --16
		   upper(v_fecha_letra_inicial),     --17
		   upper(v_fecha_letra_adicional),   --18
		   v_suma_m_asegurada,
		   v_porc_suma,
		   a_tipo
           with resume;
END
END PROCEDURE;