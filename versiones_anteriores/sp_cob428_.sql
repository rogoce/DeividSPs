-- consulta de saldos
-- Creado		:  03/10/2022	- Autor: Henry Giron.
 DROP procedure sp_cob428;
 CREATE procedure "informix".sp_cob428( a_no_poliza CHAR(10)) ---a_no_documento char(20))    
	RETURNING char(3)	as	cod_perpago	,
				char(3)	as	cod_tipocalc	,
				char(3)	as	cod_formapag	,
				char(3)	as	cod_tipoprod	,
				char(10)	as	cod_contratante	,
				char(10)	as	cod_pagador	,
				char(20)	as	no_documento	,
				date	as	vigencia_inic	,
				date	as	vigencia_final	,
				integer	as	no_pagos	,
				integer	as	estatus_poliza	,
				integer	as	direc_cobros	,
				integer	as	dia_cobros1	,
				integer	as	dia_cobros2	,
				integer	as	carta_aviso_canc	,
				integer	as	carta_prima_gan	,
				integer	as	carta_vencida_sal	,
				integer	as	carta_recorderis	,
				date	as	fecha_aviso_canc	,
				date	as	fecha_prima_gan	,
				date	as	fecha_vencida_sal	,
				date	as	fecha_recorderis	,
				dec(16,2)	as	saldo	,
				char(19)	as	no_tarjeta	,
				char(7)	as	fecha_exp	,
				char(1)	as	tipo_tarjeta	,
				char(3)	as	cod_banco	,
				char(10)	as	no_poliza	,
				char(17)	as	no_cuenta	,
				char(1)	as	tipo_cuenta	,
				date	as	fecha_primer_pago	,
				date	as	fecha_cancelacion	,
				char(20)	as	no_recibo	,
				char(1)	as	periodo_tar	,
				char(1)	as	periodo_ach	,
				char(10)	as	cod_asegurado,
				char(50)    as nombre_asegurado
				;
   

 BEGIN


	define	v_cod_perpago	char(3);
	define	v_cod_tipocalc	char(3);
	define	v_cod_formapag	char(3);
	define	v_cod_tipoprod	char(3);
	define	v_cod_contratante	char(10);
	define	v_cod_pagador	char(10);
	define	v_no_documento	char(20);
	define	v_vigencia_inic	date;
	define	v_vigencia_final	date;
	define	v_no_pagos	integer;
	define	v_estatus_poliza	integer;
	define	v_direc_cobros	integer;
	define	v_dia_cobros1	integer;
	define	v_dia_cobros2	integer;
	define	v_carta_aviso_canc	integer;
	define	v_carta_prima_gan	integer;
	define	v_carta_vencida_sal	integer;
	define	v_carta_recorderis	integer;
	define	v_fecha_aviso_canc	date;
	define	v_fecha_prima_gan	date;
	define	v_fecha_vencida_sal	date;
	define	v_fecha_recorderis	date;
	define	v_saldo	dec(16,2);
	define	v_no_tarjeta	char(19);
	define	v_fecha_exp	char(7);
	define	v_tipo_tarjeta	char(1);
	define	v_cod_banco	char(3);
	define	v_no_poliza	char(10);
	define	v_no_cuenta	char(17);
	define	v_tipo_cuenta	char(1);
	define	v_fecha_primer_pago	date;
	define	v_fecha_cancelacion	date;
	define	v_no_recibo	char(20);
	define	v_periodo_tar	char(1);
	define	v_periodo_ach	char(1);
	define	v_cod_asegurado	char(10);		 
	DEFINE v_no_unidad CHAR(5);	
	define  _null char(9);
	 DEFINE _nombre_asegurado  CHAR(50);  
	define v_cnt smallint;
drop table if exists tmp_cob428;

create temp table tmp_cob428(
			cod_perpago	char(3),
			cod_tipocalc	char(3),
			cod_formapag	char(3),
			cod_tipoprod	char(3),
			cod_contratante	char(10),
			cod_pagador	char(10),
			no_documento	char(20),
			vigencia_inic	date,
			vigencia_final	date,
			no_pagos	integer,
			estatus_poliza	integer,
			direc_cobros	integer,
			dia_cobros1	integer,
			dia_cobros2	integer,
			carta_aviso_canc	integer,
			carta_prima_gan	integer,
			carta_vencida_sal	integer,
			carta_recorderis	integer,
			fecha_aviso_canc	date,
			fecha_prima_gan	date,
			fecha_vencida_sal	date,
			fecha_recorderis	date,
			saldo	dec(16,2),
			no_tarjeta	char(19),
			fecha_exp	char(7),
			tipo_tarjeta	char(1),
			cod_banco	char(3),
			no_poliza	char(10),
			no_cuenta	char(17),
			tipo_cuenta	char(1),
			fecha_primer_pago	date,
			fecha_cancelacion	date,
			no_recibo	char(20),
			periodo_tar	char(1),
			periodo_ach	char(1),
			cod_asegurado	char(10),
			nombre_asegurado char(50)
			) with no log;				 
			 


SET ISOLATION TO DIRTY READ; 


let _null = '';
let v_cnt = 0;
FOREACH WITH HOLD
       SELECT  cod_perpago,
			 cod_tipocalc,
			 cod_formapag,
			 cod_tipoprod,
			 cod_contratante,
			 cod_pagador,
			 no_documento,
			 vigencia_inic,
			 vigencia_final,
			 no_pagos,
			 estatus_poliza,
			 direc_cobros,
			 dia_cobros1,
			 dia_cobros2,
			 carta_aviso_canc,
			 carta_prima_gan,
			 carta_vencida_sal,
			 carta_recorderis,
			 fecha_aviso_canc,
			 fecha_prima_gan,
			 fecha_vencida_sal,
			 fecha_recorderis,
			 saldo,
			 no_tarjeta,
			 fecha_exp,
			 tipo_tarjeta,
			 cod_banco,
			 no_poliza,
			 no_cuenta,
			 tipo_cuenta,
			 fecha_primer_pago,
			 fecha_cancelacion,
			 no_recibo	   
         INTO v_cod_perpago,
			v_cod_tipocalc,
			v_cod_formapag,
			v_cod_tipoprod,
			v_cod_contratante,
			v_cod_pagador,
			v_no_documento,
			v_vigencia_inic,
			v_vigencia_final,
			v_no_pagos,
			v_estatus_poliza,
			v_direc_cobros,
			v_dia_cobros1,
			v_dia_cobros2,
			v_carta_aviso_canc,
			v_carta_prima_gan,
			v_carta_vencida_sal,
			v_carta_recorderis,
			v_fecha_aviso_canc,
			v_fecha_prima_gan,
			v_fecha_vencida_sal,
			v_fecha_recorderis,
			v_saldo,
			v_no_tarjeta,
			v_fecha_exp,
			v_tipo_tarjeta,
			v_cod_banco,
			v_no_poliza,
			v_no_cuenta,
			v_tipo_cuenta,
			v_fecha_primer_pago,
			v_fecha_cancelacion,
			v_no_recibo	
         FROM emipomae
        WHERE no_poliza =  a_no_poliza
		  AND actualizado = 1
		 -- and estatus_poliza = '1'	
		  
		  select periodo  
		    into v_periodo_tar
		    from cobtacre  
		   Where no_tarjeta = v_no_tarjeta 
		     and no_documento = v_no_documento;

			if v_periodo_tar is null then
			   LET v_periodo_tar = '' ;
			end if			 
		  
		  select periodo  
		    into v_periodo_ach
		    from cobcutas  
		   Where no_cuenta  = v_no_cuenta  
		     and no_documento = v_no_documento;		

			if v_periodo_ach is null then
			   LET v_periodo_ach = '' ;
			end if		

       FOREACH        
          SELECT no_unidad,
				 cod_asegurado
            INTO v_no_unidad,
				 v_cod_asegurado
            FROM emipouni
           WHERE no_poliza = v_no_poliza	
             and activo = 1		   
			 order by 1
			 exit foreach;
       END FOREACH 			   
	
		SELECT nombre
		  INTO _nombre_asegurado
		  FROM cliclien
		 WHERE cod_cliente = v_cod_asegurado; 	   

		
		INSERT INTO tmp_cob428(
				cod_perpago,
				cod_tipocalc,
				cod_formapag,
				cod_tipoprod,
				cod_contratante,
				cod_pagador,
				no_documento,
				vigencia_inic,
				vigencia_final,
				no_pagos,
				estatus_poliza,
				direc_cobros,
				dia_cobros1,
				dia_cobros2,
				carta_aviso_canc,
				carta_prima_gan,
				carta_vencida_sal,
				carta_recorderis,
				fecha_aviso_canc,
				fecha_prima_gan,
				fecha_vencida_sal,
				fecha_recorderis,
				saldo,
				no_tarjeta,
				fecha_exp,
				tipo_tarjeta,
				cod_banco,
				no_poliza,
				no_cuenta,
				tipo_cuenta,
				fecha_primer_pago,
				fecha_cancelacion,
				no_recibo,
				periodo_tar,
				periodo_ach,
				cod_asegurado,
                nombre_asegurado				
				)
			
		   VALUES(
			    v_cod_perpago,
				v_cod_tipocalc,
				v_cod_formapag,
				v_cod_tipoprod,
				v_cod_contratante,
				v_cod_pagador,
				v_no_documento,
				v_vigencia_inic,
				v_vigencia_final,
				v_no_pagos,
				v_estatus_poliza,
				v_direc_cobros,
				v_dia_cobros1,
				v_dia_cobros2,
				v_carta_aviso_canc,
				v_carta_prima_gan,
				v_carta_vencida_sal,
				v_carta_recorderis,
				v_fecha_aviso_canc,
				v_fecha_prima_gan,
				v_fecha_vencida_sal,
				v_fecha_recorderis,
				v_saldo,
				v_no_tarjeta,
				v_fecha_exp,
				v_tipo_tarjeta,
				v_cod_banco,
				v_no_poliza,
				v_no_cuenta,
				v_tipo_cuenta,
				v_fecha_primer_pago,
				v_fecha_cancelacion,
				v_no_recibo,
				v_periodo_tar,
				v_periodo_ach,
				v_cod_asegurado,
                _nombre_asegurado);									 


END FOREACH
;
foreach
	select cod_perpago,
			cod_tipocalc,
			cod_formapag,
			cod_tipoprod,
			cod_contratante,
			cod_pagador,
			no_documento,
			vigencia_inic,
			vigencia_final,
			no_pagos,
			estatus_poliza,
			direc_cobros,
			dia_cobros1,
			dia_cobros2,
			carta_aviso_canc,
			carta_prima_gan,
			carta_vencida_sal,
			carta_recorderis,
			fecha_aviso_canc,
			fecha_prima_gan,
			fecha_vencida_sal,
			fecha_recorderis,
			saldo,
			no_tarjeta,
			fecha_exp,
			tipo_tarjeta,
			cod_banco,
			no_poliza,
			no_cuenta,
			tipo_cuenta,
			fecha_primer_pago,
			fecha_cancelacion,
			no_recibo,
			periodo_tar,
			periodo_ach,
			cod_asegurado,
            nombre_asegurado			
	  into v_cod_perpago,
			v_cod_tipocalc,
			v_cod_formapag,
			v_cod_tipoprod,
			v_cod_contratante,
			v_cod_pagador,
			v_no_documento,
			v_vigencia_inic,
			v_vigencia_final,
			v_no_pagos,
			v_estatus_poliza,
			v_direc_cobros,
			v_dia_cobros1,
			v_dia_cobros2,
			v_carta_aviso_canc,
			v_carta_prima_gan,
			v_carta_vencida_sal,
			v_carta_recorderis,
			v_fecha_aviso_canc,
			v_fecha_prima_gan,
			v_fecha_vencida_sal,
			v_fecha_recorderis,
			v_saldo,
			v_no_tarjeta,
			v_fecha_exp,
			v_tipo_tarjeta,
			v_cod_banco,
			v_no_poliza,
			v_no_cuenta,
			v_tipo_cuenta,
			v_fecha_primer_pago,
			v_fecha_cancelacion,
			v_no_recibo,
			v_periodo_tar,
			v_periodo_ach,
			v_cod_asegurado,
            _nombre_asegurado			
	  from tmp_cob428
	  
  SELECT count(*)
	INTO v_cnt
	FROM emipouni
   WHERE no_poliza = v_no_poliza	
	 and activo = 1;		  
	 
	 if v_cnt > 1 then 
	    let _nombre_asegurado = 'Ver Unidades';
	 end if

	 return v_cod_perpago,
			v_cod_tipocalc,
			v_cod_formapag,
			v_cod_tipoprod,
			v_cod_contratante,
			v_cod_pagador,
			v_no_documento,
			v_vigencia_inic,
			v_vigencia_final,
			v_no_pagos,
			v_estatus_poliza,
			v_direc_cobros,
			v_dia_cobros1,
			v_dia_cobros2,
			v_carta_aviso_canc,
			v_carta_prima_gan,
			v_carta_vencida_sal,
			v_carta_recorderis,
			v_fecha_aviso_canc,
			v_fecha_prima_gan,
			v_fecha_vencida_sal,
			v_fecha_recorderis,
			v_saldo,
			v_no_tarjeta,
			v_fecha_exp,
			v_tipo_tarjeta,
			v_cod_banco,
			v_no_poliza,
			v_no_cuenta,
			v_tipo_cuenta,
			v_fecha_primer_pago,
			v_fecha_cancelacion,
			v_no_recibo,
			v_periodo_tar,
			v_periodo_ach,
			v_cod_asegurado,
            _nombre_asegurado			
	 with resume;


end foreach



END
END PROCEDURE;
