-- Reporte de polizas que cambia de prima por cambio de edad
-- creado   :02/08/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_rep16;

CREATE PROCEDURE "informix".sp_rep16()
 RETURNING varchar(10),
		   date,
		   varchar(1),
		   integer,
		   integer,
		   varchar(10),
		   varchar(10),
		   varchar(5),
		   varchar(3),
		   varchar(10),
		   varchar(1),
		   varchar(1),
		   varchar(50),
		   varchar(1),
		   varchar(30),
		   varchar(30),
		   varchar(60),
		   date,
		   varchar(25),
		   date,
		   date,
		   date,
		   date,
		   date,
		   date,
		   varchar(1),
		   varchar(10),
		   varchar(50),
		   varchar(1),
		   varchar(1);  

	
define v_cod_producto		varchar(5);
define v_cod_ramo           varchar(3);
define v_cod_contratante    varchar(10);
define v_no_documento		varchar(25);
define v_no_poliza			varchar(10);	
define v_vigencia_inic		date;   
define v_vigencia_final     date;
define v_fecha_nac_emipomae date;
define v_no_unidad          varchar(10);
define v_placa              varchar(10);
define v_nacionalidad       varchar(1);
define v_ced_provincia      varchar(1);
define v_aseg_primer_nom    varchar(20);
define v_aseg_segundo_nom	varchar(20);
define v_aseg_primer_ape    varchar(20);
define v_aseg_segundo_ape   varchar(20);
define v_nombre_emipomae    varchar(60);
define v_cedula_emipomae    varchar(50);
define v_cedula_emipomae1   varchar(50);

define v_nombres            varchar(30);
define v_apellidos          varchar(30);
define v_cod_perpago        varchar(3);
define v_forma_pago         varchar(1);
define v_sexo               varchar(1);
define v_nombre_prod        varchar(50);
define v_cnt_cobertura      smallint;
define _fecha_hoy           date;
DEFINE _mes_char        	CHAR(2);
DEFINE _ano_char			CHAR(4);
DEFINE _periodo         	CHAR(7);
DEFINE v_por_vencer     	DEC(16,2);	 
DEFINE v_exigible      	 	DEC(16,2);
DEFINE v_corriente			DEC(16,2);
DEFINE v_monto_30			DEC(16,2);
DEFINE v_monto_60			DEC(16,2);
DEFINE v_monto_90			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
define i                    smallint;
define _char		        char(1);
define _valor		        varchar(20);
define _contador            integer;


SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "sp_rep16.trc";
-- TRACE ON;

	let _fecha_hoy    = today;
	let _contador     = 0;
	
	-- Armar varibale que contiene el periodo(aaaa-mm)

	IF  MONTH(_fecha_hoy) < 10 THEN
		LET _mes_char = '0'|| MONTH(_fecha_hoy);
	ELSE
		LET _mes_char = MONTH(_fecha_hoy);
	END IF
	LET _ano_char = YEAR(_fecha_hoy);
	LET _periodo  = _ano_char || "-" || _mes_char;

	foreach
        SELECT a.no_documento,
		       a.no_poliza,
               a.vigencia_inic,
               a.vigencia_final,
		       a.cod_ramo,
  		       b.nombre,
		       b.cedula,
		       b.fecha_aniversario,
               g.no_unidad,
  		       e.placa,
			   g.cod_producto,
			   b.ced_provincia,
			   aseg_primer_nom, 
			   aseg_segundo_nom, 
			   aseg_primer_ape, 
			   aseg_segundo_ape,
			   a.cod_perpago,
			   b.sexo
		 into  v_no_documento,
			   v_no_poliza,
			   v_vigencia_inic,
			   v_vigencia_final,
			   v_cod_ramo,
			   v_nombre_emipomae,
			   v_cedula_emipomae,
			   v_fecha_nac_emipomae,
			   v_no_unidad,
			   v_placa,
			   v_cod_producto,
			   v_ced_provincia,
			   v_aseg_primer_nom,
			   v_aseg_segundo_nom,
			   v_aseg_primer_ape,
			   v_aseg_segundo_ape,
			   v_cod_perpago,
			   v_sexo
		 FROM emipomae a, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h
		WHERE a.cod_contratante = b.cod_cliente
          AND a.no_poliza = g.no_poliza
          AND g.no_poliza = f.no_poliza
          AND g.no_unidad = f.no_unidad
          AND f.no_motor = e.no_motor
		  AND g.no_poliza = h.no_poliza
	      AND g.no_unidad = h.no_unidad 
		  AND (g.cod_producto in('03138','02181','02068','01961')
	      AND a.vigencia_inic <= date(current)
	      AND a.vigencia_final >= date(current)
	      --AND a.vigencia_inic >= '01/12/2016'
	      --AND a.vigencia_inic <= '31/01/2016'
		  AND h.cod_cobertura in('01577', '01578', '01579')	--> Cobertura Odontologica
		  AND a.actualizado = 1
		  AND a.estatus_poliza = 1)
     order by no_documento, no_unidad asc

/*	 
	  select count(*)
	    into v_cnt_cobertura
		from emipocob
	   where no_poliza 		= v_no_poliza
		 and no_unidad 		= v_no_unidad
		 and cod_cobertura in('01577','01578','01579');
		
		if v_cnt_cobertura is null or v_cnt_cobertura = 0 then
			continue foreach;
		end if
		
		select cod_perpago
		  into v_cod_perpago
		  from cobperpa
		 where cod_perpago = v_cod_perpago;
*/		 
		
	-- quitando los - de la cedula
		let v_cedula_emipomae1 = "";
		let _valor        = "";
		
		for i = 1 to 30
			let _char		= v_cedula_emipomae[1,1];
			let v_cedula_emipomae	= v_cedula_emipomae[2,20];
			if _char = '-' then
				let _valor =  trim(_valor) || "";
			else
				let _valor = trim(_valor) || _char;
			end if
		end for
		
		let v_cedula_emipomae1 = _valor;
		
		if v_cod_perpago = '002' then
			let v_forma_pago = "M";
		elif v_cod_perpago = '004' then
			let v_forma_pago = "T";
		elif v_cod_perpago = '007' then
			let v_forma_pago = "S";
		else
			let v_forma_pago = "A";
		end if
		
	    select nombre
		  into v_nombre_prod
		  from prdprod
		 where cod_producto = v_cod_producto;
		
		let v_nacionalidad = "E";
		
		if v_aseg_segundo_nom is null then
			let v_aseg_segundo_nom = " ";
		end if
		
		let v_nombres 	= trim(v_aseg_primer_nom) || " " || trim(v_aseg_segundo_nom);
		let v_apellidos = trim(v_aseg_primer_ape) || " " || trim(v_aseg_segundo_ape);
		
		CALL sp_cob33(
		"001",
		"001",
		v_no_documento,
		_periodo,
		current
		) RETURNING v_por_vencer,	   
					v_exigible,  	   
					v_corriente, 	   
					v_monto_30,  	   
					v_monto_60,  	   
					v_monto_90,  	   
					v_saldo;
	
		if (v_monto_60 + v_monto_90 > 0) then
		continue foreach;
		end if
	let _contador = _contador + 1;	
	return '23',
		   _fecha_hoy,
		   'C',
	       0,
		   _contador,
		   '',
		   '',
		   v_cod_producto,
		   'OD',
		   v_placa,
		   v_nacionalidad,
		   'T',
		   v_cedula_emipomae1,
		   v_nacionalidad,
		   v_nombres,
		   v_apellidos,
		   v_nombre_emipomae,
		   v_fecha_nac_emipomae,
		   v_no_documento,
		   v_vigencia_inic,
		   v_vigencia_final,
		   '',
		   '',
		   '',
		   '',
		   'C',
		   '',
		   v_nombre_prod,
		   v_sexo,
		   v_forma_pago
		   with resume;
		   
	end foreach
END PROCEDURE;