-- Morosidad del Call Center
-- 
-- Creado    : 07/04/2004 - Autor: Demetrio Hurtado Almanza

drop procedure sp_cas075;

create procedure sp_cas075(a_cod_compania char(3), a_cod_sucursal char(3), a_fecha date, a_cobrador char(255) default "*")
returning char(10),
		  char(100),
		  char(20),
		  dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(50),
          char(3),
          integer,
          date,
          date,
          date,
          decimal(16,2),
		  varchar(50),
		  date;

define _tipo_cobrador    integer;
define _cod_cobrador     char(3);
define _nombre_cobrador	 char(50);
define _cod_cliente      char(10);
define _no_poliza        char(10);
define _nombre_pagador	 char(100);
define v_documento 		 CHAR(20);
DEFINE v_por_vencer      DEC(16,2);	 
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente		 DEC(16,2);
DEFINE v_monto_30		 DEC(16,2);
DEFINE v_monto_60		 DEC(16,2);
DEFINE v_monto_90		 DEC(16,2);
DEFINE v_saldo			 DEC(16,2);
DEFINE _fecha_ult_pago	 date;
define _vig_ini          date;
define _vig_fin          date;
DEFINE _tipo             CHAR(1);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);
define _monto_ult_pago   DEC(16,2);
define _nom_agente		 VARCHAR(50);
define _cod_agente       char(5);
define _fecha_aviso_canc date;


set isolation to dirty read;

--set debug file to "sp_cas075.trc";
--trace on;

-- Armar varibale que contiene el periodo(aaaa-mm)
let _monto_ult_pago = 0.00;
let _fecha_ult_pago = "01/01/1900";

IF  MONTH(a_fecha) < 10 THEN
	LET _mes_char = '0'|| MONTH(a_fecha);
ELSE
	LET _mes_char = MONTH(a_fecha);
END IF

LET _ano_char = YEAR(a_fecha);
LET _periodo  = _ano_char || "-" || _mes_char;

LET _tipo = sp_sis045(a_cobrador);  -- Separa los Valores del String en una tabla de codigos
FOREACH

 SELECT e.cod_cliente,
        e.cod_cobrador
   INTO	_cod_cliente,
	    _cod_cobrador
   FROM cascliente e, cobcobra t 
  WHERE e.cod_cobrador = t.cod_cobrador
    AND t.activo       = 1
    AND e.cod_cobrador IN (SELECT codigo FROM tmp_codigos)

	select tipo_cobrador
	  into _tipo_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_cliente;

	foreach
			 select no_documento
			   into v_documento
			   from caspoliza
			  where cod_cliente = _cod_cliente

			  let _no_poliza = sp_sis21(v_documento);
			  
			  FOREACH WITH HOLD
	  			SELECT cod_agente
	    		  INTO _cod_agente
	    		  FROM emipoagt
	   			 WHERE no_poliza = _no_poliza
	   			 EXIT FOREACH;
			  END FOREACH

	
			 SELECT nombre
	  		   INTO _nom_agente
	  		   FROM agtagent
	 		  WHERE cod_agente =_cod_agente;
			
			 SELECT fecha_aviso_canc
			   INTO _fecha_aviso_canc
			   FROM emipomae
			  WHERE no_poliza = _no_poliza;


			 select vigencia_inic,
					vigencia_final
			   into _vig_ini,
			        _vig_fin
			   from emipomae
			  where no_poliza = _no_poliza;

				 CALL sp_cob33(
				 a_cod_compania,
				 a_cod_sucursal,
				 v_documento,
				 _periodo,
				 a_fecha
				 ) RETURNING v_por_vencer,
						     v_exigible,  
						     v_corriente, 
						     v_monto_30,  
						     v_monto_60,  
						     v_monto_90,
						     v_saldo;

				if v_saldo <= 0.0 then
					continue foreach;
				end if 
			   foreach

				SELECT fecha,
				       monto
				  INTO _fecha_ult_pago,
				       _monto_ult_pago
				  FROM cobredet
				 WHERE doc_remesa   = _no_poliza	-- Recibos de la Poliza
				   AND actualizado  = 1			    -- Recibo este actualizado
				   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
				   order by 1 desc
				 exit foreach;

			   end foreach

			   if _fecha_ult_pago is null then
				let _fecha_ult_pago = "01/01/1900";
			   end if

			   if _monto_ult_pago is null then
				let _monto_ult_pago = 0;
			   end if

				return _cod_cliente,
					   _nombre_pagador,
					   v_documento,
					   v_saldo,
					   v_por_vencer,
					   v_exigible,
					   v_corriente,
					   v_monto_30,
					   v_monto_60,
					   v_monto_90,
					   _nombre_cobrador,
					   _cod_cobrador,
					   _tipo_cobrador,
					   _fecha_ult_pago,
					   _vig_ini,
					   _vig_fin,
					   _monto_ult_pago,
					   _nom_agente,
					   _fecha_aviso_canc
					   with resume;

	end foreach

end foreach
DROP TABLE tmp_codigos;
end procedure


				  