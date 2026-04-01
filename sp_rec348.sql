-- Procedimiento de Detalle de la cuenta 222
-- Creado    : 06/01/2024- Autor: Amado Perez

drop procedure sp_rec348;
create procedure informix.sp_rec348(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7))
returning	CHAR(50) as Ramo,
            CHAR(50) as Subramo,
			DECIMAL(16,2) as Monto ,
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

--let v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_sinis;

UPDATE ramosubr222
   SET prima_suscrita  = 0, cnt_polizas = 0, cnt_reclamo = 0, incurrido_bruto = 0, pago_ded = 0, salv_rec = 0, var_reserva = 0, casos_cerrados  = 0,
	   cnt_polizas_ma  = 0, cnt_pol_nuevas  = 0, cnt_pol_ren = 0, cnt_pol_can_cad = 0, cnt_asegurados = 0, cnt_incurridos = 0, cnt_vencidas = 0, reserva_cedido = 0;

let _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

{update tmp_sinis
   set cod_ramo = '002'
 where cod_ramo = '020';

update tmp_sinis
   set cod_ramo = '002'
 where cod_ramo = '023';}

update tmp_sinis
   set cod_ramo = '001'
 where cod_ramo = '021';

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];

foreach
	select no_poliza,
		   cod_ramo,
		   cod_subramo,
		   sum(incurrido_bruto),
		   sum(pagado_bruto),
		   sum(reserva_bruto),
		   sum(reserva_neto),
		   sum(pagado_bruto1),
		   sum(salvamento_bruto),
		   sum(recupero_bruto),
		   sum(deducible_bruto)
	  into _no_poliza,
		   _cod_ramo,	
		   _cod_subramo,
		   v_incurrido_bru,
		   v_pagado_bruto,
		   v_reserva_bruto,
		   v_reserva_neto,
		   v_pagado_bruto1,
		   v_salv_bruto,
		   v_recupero_bruto,
		   v_dec_bruto
	  from tmp_sinis 
	 where seleccionado = 1
	 group by no_poliza, cod_ramo, cod_subramo
	 order by no_poliza, cod_ramo, cod_subramo

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then -- Soda y Flota pasa a Auto
		let _cod_ramo = '002';
	end if
{
	if _cod_ramo in ('003') then -- Multiriesgo Pasa a Incendio
		let _cod_ramo = '001';
	elif _cod_ramo in ('010','011','012','013','014','022') then --Ramos Tecnicos	
		let _cod_ramo = '099';
	end if
}	
	
	let _cuenta = sp_sis15('NIIFPRSMR', '01', _no_poliza);
	
	if _cuenta[1,3] <> '149' then
		continue foreach;
	end if

	-- Reserva de Siniestros en Tramite Cuenta 222
	
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if
	
	if v_reserva_neto is null then
		let v_reserva_neto = 0.00;
	end if
	
	let v_reserva_cedido = v_reserva_bruto - v_reserva_neto;	
	
	if v_reserva_cedido <> 0.00 then
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
				   SET reserva_cedido = reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "002";				   
			ELSE
				UPDATE ramosubr222
				   SET reserva_cedido = reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "001";		
			END IF			 
		END IF	
		
		IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
			UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			 WHERE cod_ramo        = '010'
			   AND cod_subramo = "001";
		END IF
		IF _cod_ramo = "010" THEN
			UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "002";
		END IF
		IF _cod_ramo = "012" THEN
			UPDATE ramosubr222
			   SET reserva_cedido = reserva_cedido + v_reserva_cedido
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "003";
		END IF
		IF _cod_ramo = "011" THEN
			UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "004";
		END IF
		IF _cod_ramo = "022" THEN
			UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "005";
		END IF
		IF _cod_ramo = "007" THEN
			UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			   AND cod_subramo     = "006";
		END IF
		IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
			 SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "008" THEN
		  IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
			  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo        = _cod_ramo
				 AND cod_subramo     = '001';
		  else
			  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo        = _cod_ramo
				 AND cod_subramo     = '002';
		  end if
		end if  
		IF _cod_ramo = "001" and _cod_subramo = '001' THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "001" and _cod_subramo in ('002', '007') THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '003';
		END IF	

		IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243 
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF
		IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF
		IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "004";
		END IF	
		IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN    -- Colectivo de Vida Amado 28-05-2021
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '001';
		END IF

		IF _cod_ramo = "016" AND _cod_subramo = "007" THEN      -- Colectivo de Deuda Amado 28-05-2021 
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = '002';
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = _cod_subramo;
		END IF

		IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
		  UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "001";
		END IF	

		IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
		 UPDATE ramosubr222
				SET reserva_cedido = reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        = _cod_ramo
			 AND cod_subramo     = "002";
		END IF

		IF _cod_ramo = "002" THEN
		 UPDATE ramosubr222
			SET reserva_cedido = reserva_cedido + v_reserva_cedido
		  WHERE cod_ramo     = _cod_ramo
			AND cod_subramo  = "001";
	    END IF
		
 		IF _cod_ramo = "006" THEN
		 UPDATE ramosubr222
			SET reserva_cedido = reserva_cedido + v_reserva_cedido			
          WHERE cod_ramo     = _cod_ramo
            AND cod_subramo  = "001";
	    END IF
		
  		IF _cod_ramo = "015" THEN
		 UPDATE ramosubr222
			SET reserva_cedido = reserva_cedido + v_reserva_cedido			
          WHERE cod_ramo        = _cod_ramo
            AND cod_subramo     = "001";
		END IF
	end if
end foreach

FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   reserva_cedido,
			   orden
          INTO _cod_ramo,
			   _cod_subramo,
			   v_reserva_cedido,
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

       RETURN  v_desc_ramo, v_desc_subramo, v_reserva_cedido, _orden, _orden_sub WITH RESUME;
END FOREACH

drop table if exists tmp_sinis;
end procedure;