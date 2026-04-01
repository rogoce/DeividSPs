-- Procedimiento de Detalle de la cuenta 222
-- Creado    : 06/01/2024- Autor: Amado Perez
-- execute procedure sp_super30('2025-02','2025-02')
drop procedure sp_super30;
create procedure sp_super30(
a_periodo1  char(7), 
a_periodo2  char(7))
returning	CHAR(50) as Descripcion,
            CHAR(50) as Ramo,
			DECIMAL(16,2) as Prima_Retenida ,
			DECIMAL(16,2) as Prima_Devengada ,
			SMALLINT as orden,
			SMALLINT as orden_subramo;

define _tri					varchar(255);
define v_ramo_nombre		varchar(50);
define _nom_cuenta			varchar(50);
define v_compania_nombre	varchar(50);
define _cuenta				char(18);
define _no_poliza			char(10);
define _ano					char(4);
define _cod_ramo			char(3);
define v_incurrido_bruto	dec(16,2);
define v_recupero_bruto		dec(16,2);
define v_pagado_bruto1		dec(16,2);
define v_reserva_recup		dec(16,2);
define v_reserva_bruto		dec(16,2);
define v_incurrido_bru		dec(16,2);
define v_pagado_total		dec(16,2);
define v_pagado_bruto		dec(16,2);
define v_reserva_neto		dec(16,2);
define v_pagado_neto		dec(16,2);
define v_salv_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _diferencia			dec(16,2);
define v_dec_bruto			dec(16,2);
define _saldo				dec(16,2);
define _ramo_sis			smallint;
define _mes					smallint;
define v_reserva_cedido		dec(16,2);
define _cod_subramo         char(3);
define _orden               smallint;
define _orden_sub           smallint;
define v_desc_ramo          CHAR(50);
define v_desc_subramo       CHAR(50);
define _nueva_renov         char(1);
define _vigencia_inic       date;
define li_dia               integer;
define li_mes               integer;
define li_anio              integer;
define _vig_fin_vida        date;
define _cantidad            integer;
define _error_isam			smallint;           
define _error				smallint;
define _error_desc 			varchar(100);  
define _res_mayor           char(3);    
define _prima_retenida      dec(16,2);
define _prima_devengada     dec(16,2);
define _sal_411             dec(16,2);
define _sal_511             dec(16,2);
define _sal_otro            dec(16,2);
define _res_cuenta          char(20);
define _prima_retenida_tot  dec(16,2);


--let v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_mov_cuentas;

UPDATE ramosubr222
   SET prima_suscrita  = 0, cnt_polizas = 0, cnt_reclamo = 0, incurrido_bruto = 0, pago_ded = 0, salv_rec = 0, var_reserva = 0, casos_cerrados  = 0,
	   cnt_polizas_ma  = 0, cnt_pol_nuevas  = 0, cnt_pol_ren = 0, cnt_pol_can_cad = 0, cnt_asegurados = 0, cnt_incurridos = 0, cnt_vencidas = 0, reserva_cedido = 0, prima_devengada = 0, prima_retenida = 0;

UPDATE ramootro222
   SET prima_suscrita  = 0, cnt_polizas = 0, cnt_reclamo = 0, incurrido_bruto = 0, pago_ded = 0, salv_rec = 0, var_reserva = 0, casos_cerrados  = 0,
	   cnt_polizas_ma  = 0, cnt_pol_nuevas  = 0, cnt_pol_ren = 0, cnt_pol_can_cad = 0, cnt_asegurados = 0, cnt_incurridos = 0, cnt_vencidas = 0, prima_devengada = 0, prima_retenida = 0;

call DetallePrimaDevengada(a_periodo1, a_periodo2) returning _error, _error_isam, _error_desc;

update tmp_mov_cuentas
   set CodRamo = '002'
 where CodRamo = '020';

update tmp_mov_cuentas
   set CodRamo = '002'
 where CodRamo = '023';

update tmp_mov_cuentas
   set CodRamo = '001'
 where CodRamo = '021';

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];

foreach
	select no_poliza,
		   CodRamo,
		   CodSubramo,
		   res_mayor,
		   sum(saldo) * (-1)
	  into _no_poliza,
		   _cod_ramo,	
		   _cod_subramo,
		   _res_mayor,
		   _saldo
	  from tmp_mov_cuentas 
	 where res_origen <> "CGL"
	 group by no_poliza, CodRamo, CodSubramo, res_mayor
	 order by no_poliza, CodRamo, CodSubramo, res_mayor

	let _sal_411 = 0;
	let _sal_511 = 0;
	let _sal_otro = 0;
	
	if _res_mayor = '411' then
		let _sal_411 = _saldo;
    elif _res_mayor = '511' then
		let _sal_511 = _saldo;
	else
		let _sal_otro = _saldo;
	end if
					
	if _saldo <> 0.00 then
		SELECT nueva_renov,
			   vigencia_inic
		  INTO _nueva_renov,
			   _vigencia_inic
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		let li_dia = day(_vigencia_inic);
		let li_mes = month(_vigencia_inic);
		let li_anio = year(_vigencia_inic);

		If li_mes = 2 Then
			If li_dia > 28 Then
				let li_dia = 28;
				let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
			else
				let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
			End If
		else
			let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		End If

		LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;
		
		IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
			select count(*)
			  into _cantidad
			  from emipouni
			 where no_poliza = _no_poliza;
			 
			IF _cantidad > 1 then
				UPDATE ramosubr222
				   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				       prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "002";				   
			ELSE
				UPDATE ramosubr222
				   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				       prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "001";		
			END IF			 
		END IF	
		
		IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			 WHERE cod_ramo        = '010'
			   AND cod_subramo = "001";
		END IF
		IF _cod_ramo = "010" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "002";
		END IF
		IF _cod_ramo = "012" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "003";
		END IF
		IF _cod_ramo = "011" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "004";
		END IF
		IF _cod_ramo = "022" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "005";
		END IF
		IF _cod_ramo = "007" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "006";
		END IF
		IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "008" THEN
		  IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
			  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			   WHERE cod_ramo        = _cod_ramo
				 AND cod_subramo     = '001';
		  else
			  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			   WHERE cod_ramo        = _cod_ramo
				 AND cod_subramo     = '002';
		  end if
		end if  
		IF _cod_ramo = "001" and _cod_subramo = '001' THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "001" and _cod_subramo in ('002', '007') THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '003';
		END IF	

		IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243 
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "004";
		END IF	
		IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN    -- Colectivo de Vida Amado 28-05-2021
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
		END IF

		IF _cod_ramo = "016" AND _cod_subramo = "007" THEN      -- Colectivo de Deuda Amado 28-05-2021 
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "001";
		END IF	

		IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "002";
		END IF

		IF _cod_ramo = "002" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		  WHERE cod_ramo     = _cod_ramo
			AND cod_subramo  = "001";
	    END IF
		
 		IF _cod_ramo = "006" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
          WHERE cod_ramo     = _cod_ramo
            AND cod_subramo  = "001";
	    END IF
		
  		IF _cod_ramo = "015" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
          WHERE cod_ramo        = _cod_ramo
            AND cod_subramo     = "001";
			
		 UPDATE ramootro222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
          WHERE cod_ramo        = _cod_ramo
            AND cod_subramo     = _cod_subramo;
		END IF
	end if
end foreach

foreach
	select cod_ramo,
	       sum(prima_retenida)
	  into _cod_ramo,
	       _prima_retenida_tot
	  from ramosubr222
	 group by cod_ramo
 
    foreach
		select cod_subramo,
		       prima_retenida
          into _cod_subramo,
		       _prima_retenida
          from ramosubr222
         where cod_ramo = _cod_ramo
		 
		update ramosubr222 
		   set porc_partic = _prima_retenida / _prima_retenida_tot * 100
		 where cod_ramo = _cod_ramo
		   and cod_subramo = _cod_subramo;
	end foreach
end foreach

--set debug file to "sp_super30.trc";
--trace on;


foreach
	select cod_ramo,
	       sum(prima_retenida)
	  into _cod_ramo,
	       _prima_retenida_tot
	  from ramootro222
	 group by cod_ramo
 
    foreach
		select cod_subramo,
		       prima_retenida
          into _cod_subramo,
		       _prima_retenida
          from ramootro222
         where cod_ramo = _cod_ramo
		 
		update ramootro222 
		   set porc_partic = _prima_retenida / _prima_retenida_tot * 100
		 where cod_ramo = _cod_ramo
		   and cod_subramo = _cod_subramo;
	end foreach
end foreach

--trace oFF;

foreach
	select res_cuenta,
	       res_mayor,
		   sum(saldo) * (-1)
	  into _res_cuenta,
	       _res_mayor,
		   _saldo
	  from tmp_mov_cuentas 
	 where res_origen = "CGL"
	 group by res_cuenta,res_mayor
	 order by res_cuenta,res_mayor

	let _sal_411 = 0;
	let _sal_511 = 0;
	let _sal_otro = 0;
	
	if _res_mayor = '411' then
		let _sal_411 = _saldo;
    elif _res_mayor = '511' then
		let _sal_511 = _saldo;
	else
		let _sal_otro = _saldo;
	end if
	
	select cod_ramo
	  into _cod_ramo
	  from ssr_mapi
	 where cta_cuenta = _res_cuenta;	 
					
	if _saldo <> 0.00 then
		SELECT nueva_renov,
			   vigencia_inic
		  INTO _nueva_renov,
			   _vigencia_inic
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		let li_dia = day(_vigencia_inic);
		let li_mes = month(_vigencia_inic);
		let li_anio = year(_vigencia_inic);

		If li_mes = 2 Then
			If li_dia > 28 Then
				let li_dia = 28;
				let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
			else
				let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
			End If
		else
			let _vigencia_inic = mdy(li_mes, li_dia, li_anio);
		End If

		LET _vig_fin_vida = _vigencia_inic + 1 UNITS YEAR;
		
		IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
			 
				UPDATE ramosubr222
				   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
				       prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
				 WHERE cod_ramo        = _cod_ramo
				   AND prima_retenida <> 0;		
				   
		END IF	
		
		IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			 WHERE cod_ramo        = '010'
			   AND cod_subramo = "001";
		END IF
		
		IF _cod_ramo = "010" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "002";
		END IF
		
		IF _cod_ramo = "012" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "003";
		END IF
		IF _cod_ramo = "011" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "004";
		END IF
		IF _cod_ramo = "022" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "005";
		END IF
		IF _cod_ramo = "007" THEN
			UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "006";
		END IF
		IF _cod_ramo = "003" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
		     AND prima_retenida <> 0;
		END IF
		IF _cod_ramo = "008" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		end if  
		IF _cod_ramo = "001" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		END IF

		IF _cod_ramo = "009" THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243 
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		END IF
		IF _cod_ramo = "005" THEN
		  UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		   WHERE cod_ramo        = _cod_ramo;
		END IF

		IF _cod_ramo = "016" THEN    -- Colectivo de Vida Amado 28-05-2021
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		END IF

		IF _cod_ramo = "017" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		END IF

		IF _cod_ramo = "019" THEN
		  UPDATE ramosubr222
		   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
			   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
		   WHERE cod_ramo        = _cod_ramo
			 AND prima_retenida <> 0;
		END IF	

		IF _cod_ramo = "002" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
		  WHERE cod_ramo     = _cod_ramo
			AND cod_subramo  = "001";
	    END IF
		
 		IF _cod_ramo = "006" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
          WHERE cod_ramo     = _cod_ramo
            AND cod_subramo  = "001";
	    END IF
		
  		IF _cod_ramo = "015" THEN
		 UPDATE ramosubr222
			   SET prima_retenida = prima_retenida + (_sal_411 + _sal_511),
				   prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro)
          WHERE cod_ramo        = _cod_ramo
            AND cod_subramo     = "001";

		 UPDATE ramootro222
			SET prima_retenida = prima_retenida + (_sal_411 + _sal_511) * porc_partic / 100,
				prima_devengada = prima_devengada + (_sal_411 + _sal_511 + _sal_otro) * porc_partic / 100
          WHERE cod_ramo        = _cod_ramo
			AND prima_retenida <> 0;
		END IF
	end if
end foreach

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   prima_retenida,
			   prima_devengada,
			   orden
          INTO _cod_ramo,
			   _cod_subramo,
			   _prima_retenida,
			   _prima_devengada,
			   _orden
          FROM ramosubr222
	  ORDER BY orden,cod_ramo,cod_subramo

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;

	LET _orden_sub = 1;
		  
    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  END IF
		  --LET v_desc_subramo = "";		  
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
		  IF  _cod_subramo = '002' THEN
		  	LET v_desc_subramo = "TERRESTRE";
		  END IF
 		  IF _cod_subramo = '002' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  ELIF _cod_subramo = '004' THEN
			LET _orden_sub = 2;
		  END IF
   ELIF _cod_ramo = "004" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "018" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "016" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "COLECTIVO DE VIDA";
		  ELSE
		  	LET v_desc_subramo = "COLECTIVO DE DEUDA";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "006" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  if _cod_subramo = '001' then
			let v_desc_subramo = 'OFERTA Y CUMPLIMIENTO';
		  else
			let v_desc_subramo = 'OTRAS';
		  end if
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
		  IF _cod_subramo = "001"	THEN
			  LET v_desc_subramo = "TRC / TRM";
			  LET _orden_sub = 1;
		  ELIF _cod_subramo = "002" THEN
			  LET v_desc_subramo = "EQUIPO ELECTRONICO";
			  LET _orden_sub = 2;
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CALDERA Y MAQUINARIA";
			  LET _orden_sub = 3;
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "ROTURA DE MAQUINARIA";
			  LET _orden_sub = 4;
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "EQUIPO PESADO";
			  LET _orden_sub = 5;
		  ELSE
			  LET v_desc_subramo = "VIDRIOS";
			  LET _orden_sub = 6;
		  END IF
    ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "012" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "013" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "014" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "022" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "015" THEN
		  LET v_desc_ramo = "OTROS";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "RIESGOS VARIOS";
		  END IF
    ELIF _cod_ramo IN ("003", "017", "019") THEN
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    END IF

       RETURN  v_desc_subramo, v_desc_ramo, _prima_retenida, _prima_devengada, _orden, _orden_sub WITH RESUME;
END FOREACH

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   prima_retenida,
			   prima_devengada,
			   orden
          INTO _cod_ramo,
			   _cod_subramo,
			   _prima_retenida,
			   _prima_devengada,
			   _orden
          FROM ramootro222
	  ORDER BY orden,cod_ramo,cod_subramo

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;

	LET _orden_sub = 1;
		  
    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  END IF
		  --LET v_desc_subramo = "";		  
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
		  IF  _cod_subramo = '002' THEN
		  	LET v_desc_subramo = "TERRESTRE";
		  END IF
 		  IF _cod_subramo = '002' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '003' THEN
			LET _orden_sub = 3;
		  ELIF _cod_subramo = '004' THEN
			LET _orden_sub = 2;
		  END IF
   ELIF _cod_ramo = "004" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "018" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "INDIVIDUAL";
		  ELSE
		  	LET v_desc_subramo = "GRUPO";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "016" THEN
		  LET v_desc_subramo = "";
		  IF  _cod_subramo = '001' THEN
		  	LET v_desc_subramo = "COLECTIVO DE VIDA";
		  ELSE
		  	LET v_desc_subramo = "COLECTIVO DE DEUDA";
		  END IF
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "002" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "006" THEN
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "008" THEN
		  LET v_desc_subramo = "";
		  if _cod_subramo = '001' then
			let v_desc_subramo = 'OFERTA Y CUMPLIMIENTO';
		  else
			let v_desc_subramo = 'OTRAS';
		  end if
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
		  IF _cod_subramo = "001"	THEN
			  LET v_desc_subramo = "TRC / TRM";
			  LET _orden_sub = 1;
		  ELIF _cod_subramo = "002" THEN
			  LET v_desc_subramo = "EQUIPO ELECTRONICO";
			  LET _orden_sub = 2;
		  ELIF _cod_subramo = "003" THEN
			  LET v_desc_subramo = "CALDERA Y MAQUINARIA";
			  LET _orden_sub = 3;
		  ELIF _cod_subramo = "004" THEN
			  LET v_desc_subramo = "ROTURA DE MAQUINARIA";
			  LET _orden_sub = 4;
		  ELIF _cod_subramo = "005" THEN
			  LET v_desc_subramo = "EQUIPO PESADO";
			  LET _orden_sub = 5;
		  ELSE
			  LET v_desc_subramo = "VIDRIOS";
			  LET _orden_sub = 6;
		  END IF
    ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "012" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "013" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "014" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
    ELIF _cod_ramo = "022" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
		  LET v_desc_subramo = "";
--    ELIF _cod_ramo = "015" THEN
--		  LET v_desc_ramo = "OTROS";
--		  IF  _cod_subramo = '001' THEN
--		  	LET v_desc_subramo = "RIESGOS VARIOS";
--		  END IF
    ELIF _cod_ramo IN ("003", "017", "019") THEN
		  IF _cod_subramo = '001' THEN
			LET _orden_sub = 1;
		  ELIF _cod_subramo = '002' THEN
			LET _orden_sub = 2;
		  END IF
    END IF

       RETURN  v_desc_subramo, v_desc_ramo, _prima_retenida, _prima_devengada, _orden, _orden_sub WITH RESUME;
END FOREACH

drop table if exists tmp_sinis;
end procedure;
