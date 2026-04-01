 DROP procedure sp_actuario12;

 CREATE procedure "informix".sp_actuario12()
   RETURNING char(30),
   			 char(20),		
 			 char(3),		
			 char(50),		
			 char(12),		
			 date,		    
			 char(10),		
			 date,		    
			 date,		    
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 DEC(16,2),		
			 date,			
			 DEC(16,2),		
			 char(20),		
			 char(30),		
			 datetime year to second,
			 varchar(250);



 BEGIN

    define v_no_poliza        CHAR(10);
    define _cod_cliente       CHAR(10);
    define v_no_documento     CHAR(20);
    define v_vigencia_inic	  DATE;
    define v_vigencia_final	  DATE;
    define _fecha_hoy     	  DATE;
    define _cod_ramo          CHAR(3);
	define _fecha_suscripcion DATE;
	define _estatus           smallint;
	define _no_factura        char(10);
	define _estatus_char      char(12);
	define _cod_contratante   char(10);
	DEFINE _mes_char        CHAR(2);
	DEFINE _ano_char		CHAR(4);
	DEFINE _periodo         CHAR(7);
	DEFINE v_por_vencer     DEC(16,2);	 
	DEFINE v_exigible       DEC(16,2);
	DEFINE v_corriente		DEC(16,2);
	DEFINE v_monto_30		DEC(16,2);
	DEFINE v_monto_60		DEC(16,2);
	DEFINE v_monto_90		DEC(16,2);
	DEFINE v_apagar			DEC(16,2);
	DEFINE v_saldo			DEC(16,2);
	define _cedula          char(30);
	define _fecha_ult_dia   date;
	define _valor           integer;
	define _desc_gestion    varchar(250);
	define _n_ramo          char(50);
	define _fecha_gestion	datetime year to second;
	define _f_tmpsa         date;
	define _per_tmpsa		char(7);
	define _monto_tmpsa		DEC(16,2);
	define _no_recibo		char(20);
	define _no_remesa		char(30);
	define v_por_vencer1	DEC(16,2);
	define v_exigible1		DEC(16,2);
	define v_corriente1		DEC(16,2);
	define v_monto_301		DEC(16,2);
	define v_monto_601		DEC(16,2);
	define v_monto_901		DEC(16,2);
	define v_saldo1			DEC(16,2);

SET ISOLATION TO DIRTY READ; 

let _fecha_hoy    = today;

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

delete from cedpol2;

CREATE TEMP TABLE tmp_cedpol(
	cedula			CHAR(30),
	cod_cliente		CHAR(10)
	) WITH NO LOG;

--clientes pertenecientes a esas cedulas
foreach
	select cedula
	  into _cedula
	  from cedpol
	 order by cedula

	foreach

		select cod_cliente
		  into _cod_cliente
		  from cliclien
 		 where cedula = _cedula

		INSERT INTO tmp_cedpol(cedula,cod_cliente)
	    VALUES(_cedula,_cod_cliente);

	end foreach

end foreach

--buscar las polizas de esos clientes

FOREACH WITH HOLD

	   select cod_cliente,cedula
	     into _cod_cliente,_cedula
		 from tmp_cedpol

   foreach

       SELECT no_documento
         INTO v_no_documento
         FROM emipomae
        WHERE actualizado = 1
		  AND cod_contratante = _cod_cliente
	    GROUP BY no_documento
		ORDER BY no_documento

	   let v_no_poliza = sp_sis21(v_no_documento);

       SELECT vigencia_inic,
              vigencia_final,
			  fecha_suscripcion,
			  estatus_poliza,
			  cod_ramo,
			  no_factura
         INTO v_vigencia_inic,
              v_vigencia_final,
			  _fecha_suscripcion,
			  _estatus,
			  _cod_ramo,
			  _no_factura
         FROM emipomae
        WHERE no_poliza   = v_no_poliza
          AND actualizado = 1;

		let _estatus_char = '';

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		elif _estatus = 2 then
			let _estatus_char = 'CANCELADA';
		elif _estatus = 3 then
			let _estatus_char = 'VENCIDA';
		else
			let _estatus_char = '*';
		end if

	   select nombre
	     into _n_ramo
		 from prdramo
		where cod_ramo = _cod_ramo;

		--buscar la morosidad de la poliza

		let v_saldo = 0;

		CALL sp_cob33(
		'001',
		'001',
		v_no_documento,
		_periodo,
		_fecha_ult_dia
		) RETURNING v_por_vencer,
				    v_exigible,  
				    v_corriente,
				    v_monto_30,  
				    v_monto_60,  
				    v_monto_90,
				    v_saldo
				    ;

		--buscar el saldo de la ultima factura

		CALL verifica('001','001',v_no_documento) RETURNING _valor;

		foreach
			select fecha,
				   periodo
			  into _f_tmpsa,
				   _per_tmpsa
			  from tmp_sa
			 where referencia = 'FACTURA'
			   and tipo_fac in('NUEVA','RENOVACION')
		     order by fecha desc

			exit foreach;
		end foreach

		let v_saldo1 = 0;
		 
		CALL sp_cob33(
		'001',
		'001',
		v_no_documento,
		_per_tmpsa,
		_f_tmpsa
		) RETURNING v_por_vencer1,
				    v_exigible1,  
				    v_corriente1,
				    v_monto_301,  
				    v_monto_601,  
				    v_monto_901,
				    v_saldo1
				    ;

		--buscar el ultimo recibo, fecha ult pago, monto ult pago, no recibo, no remesa
		foreach
			select fecha,
				   monto,
				   no_documento,
				   tipo_fac
			  into _f_tmpsa,
				   _monto_tmpsa,
				   _no_recibo,
				   _no_remesa
			  from tmp_sa
			 where referencia IN('RECIBO','COMPROBANTE')
		     order by fecha desc

			exit foreach;
		end foreach

	   --buscar la ultima fecha de gestion y su observacion
	   foreach
		select fecha_gestion,
		       desc_gestion
		  into _fecha_gestion,
		       _desc_gestion
          from cobgesti
		 where no_poliza = v_no_poliza
		 order by fecha_gestion desc
	   	exit foreach;
	   end foreach

	   drop table tmp_sa;

		INSERT INTO cedpol2(
		cedula,
		no_documento,
		cod_ramo,
		n_ramo,
		estatus_pol,
		fecha_suscripcion,
		no_factura,
		vig_ini,
		vig_fin,
		por_vencer,
		exigible,
		corriente,
		monto30,
		monto60,
		monto90,
		saldo,
		saldo_fac,
		fec_u_pago,
		monto_u_pago,
		no_recibo,
		no_remesa,
		fecha_gestion,
		obs)
	    VALUES(
	    _cedula,
		v_no_documento,
		_cod_ramo,
		_n_ramo,
		_estatus_char,
		_fecha_suscripcion,
		_no_factura,
		v_vigencia_inic,
		v_vigencia_final,
		v_por_vencer,
		v_exigible,  
		v_corriente,
		v_monto_30,  
		v_monto_60,  
		v_monto_90,
		v_saldo,
		v_saldo1,
		_f_tmpsa,
		_monto_tmpsa,
		_no_recibo,
		_no_remesa,
		_fecha_gestion,
		_desc_gestion
	    );

	   {return _cedula,
	   		  v_no_documento,
			  _cod_ramo,
			  _n_ramo,
			  _estatus_char,
			  _fecha_suscripcion,
			  _no_factura,
			  v_vigencia_inic,
			  v_vigencia_final,
			  v_por_vencer,
			  v_exigible,  
			  v_corriente,
			  v_monto_30,  
			  v_monto_60,  
			  v_monto_90,
			  v_saldo,
			  v_saldo1,
			  _f_tmpsa,
			  _monto_tmpsa,
			  _no_recibo,
			  _no_remesa,
			  _fecha_gestion,
			  _desc_gestion
	   with resume;	}

   end foreach

END FOREACH	

DROP TABLE tmp_cedpol;

END

END PROCEDURE;
