-- Procedimiento de Detalle de la cuenta 222
-- Creado    : 06/01/2024- Autor: Amado Perez

drop procedure sp_rec354;
create procedure informix.sp_rec354(a_periodo1  char(7))
returning	INTEGER,
            VARCHAR(50);

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
define _error				integer;
define _error_desc			VARCHAR(50);
define _error_isam			smallint; 
define _no_poliza2          char(10);
define _no_unidad           char(5);
define _uso_auto            char(1);
define _no_reclamo			char(10);
--let v_compania_nombre = sp_sis01(a_compania);

set isolation to dirty read;

begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception

drop table if exists tmp_sinis;

UPDATE ramosubrh
   SET reserva_cedido = 0
 WHERE periodo = a_periodo1
   AND origen = 1;

let _tri = sp_rec01d('001', '001', a_periodo1, a_periodo1);

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
	select no_reclamo,
	       no_poliza,
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
	  into _no_reclamo,
	       _no_poliza,
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
	 group by no_reclamo, no_poliza, cod_ramo, cod_subramo
	 order by no_reclamo, no_poliza, cod_ramo, cod_subramo

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
				UPDATE ramosubrh
				   SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo        	= _cod_ramo
				   AND cod_subramo     	= "002"
				   AND periodo		   	= a_periodo1
				   AND origen			= 1;				   
			ELSE
				UPDATE ramosubrh
				   SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo        	= _cod_ramo
				   AND cod_subramo     	= "001"
				   AND periodo		   	= a_periodo1
				   AND origen			= 1;		
			END IF			 
		END IF	
		
		IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
			UPDATE ramosubrh
			   SET reserva_cedido	= reserva_cedido + v_reserva_cedido
			 WHERE cod_ramo        	= '010'
			   AND cod_subramo 	   	= "001"
			   AND periodo		   	= a_periodo1
			   AND origen			= 1;
		END IF
		IF _cod_ramo = "010" THEN
			UPDATE ramosubrh
				SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "002"			   
			    AND periodo		   	= a_periodo1
				AND origen			= 1;
		END IF
		IF _cod_ramo = "012" THEN
			UPDATE ramosubrh
			   SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
			 WHERE cod_ramo        	= '010'
			   AND cod_subramo     	= "003"
			   AND periodo		   	= a_periodo1
			   AND origen			= 1;
		END IF
		IF _cod_ramo = "011" THEN
			UPDATE ramosubrh
				SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "004"
			    AND periodo		   	= a_periodo1
				AND origen			= 1;
		END IF
		IF _cod_ramo = "022" THEN
			UPDATE ramosubrh
				SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			    AND cod_subramo     = "005"
			    AND periodo		   	= a_periodo1				
				AND origen			= 1;
		END IF
		IF _cod_ramo = "007" THEN
			UPDATE ramosubrh
				SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
			  WHERE cod_ramo        = '010'
			    AND cod_subramo    	= "006"
			    AND periodo		   	= a_periodo1
				AND origen			= 1;
		END IF
		IF _cod_ramo = "003" AND _cod_subramo = "001" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF
		IF _cod_ramo = "008" THEN
		  IF _cod_subramo = "002" OR _cod_subramo = "018" THEN
			  UPDATE ramosubrh
				 SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo       = _cod_ramo
				 AND cod_subramo    = '001'
			     AND periodo		= a_periodo1
				 AND origen			= 1;
		  ELIF 	_cod_subramo = "003" THEN	   
			  UPDATE ramosubrh
				 SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo       = _cod_ramo
				 AND cod_subramo    = '003'
			     AND periodo		= a_periodo1
				 AND origen			= 1;
	      ELIF 	_cod_subramo = "012" THEN	   
			  UPDATE ramosubrh
				 SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo       = _cod_ramo
				 AND cod_subramo    = '004'
			     AND periodo		= a_periodo1
				 AND origen			= 1;
	      ELIF 	_cod_subramo = "009" THEN	   
			  UPDATE ramosubrh
				 SET reserva_cedido = reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo       = _cod_ramo
				 AND cod_subramo    = '005'
			     AND periodo		= a_periodo1
				 AND origen			= 1;
		  else
			  UPDATE ramosubrh
				 SET reserva_cedido	= reserva_cedido + v_reserva_cedido
			   WHERE cod_ramo       = _cod_ramo
				 AND cod_subramo    = '002'
			     AND periodo		= a_periodo1
				 AND origen			= 1;
		  end if
		end if  
		IF _cod_ramo = "001" and _cod_subramo = '001' THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		 	= a_periodo1
			 AND origen			= 1;
		END IF
		IF _cod_ramo = "001" and _cod_subramo in ('002', '007') THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '002'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF
		IF _cod_ramo = "001" and _cod_subramo in('003','004','006') THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '003'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF	

		IF _cod_ramo = "003" AND _cod_subramo <> "001" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '002'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF
		IF _cod_ramo = "009" AND _cod_subramo in('001','002','006','009') THEN -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243 
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '002'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF
		IF _cod_ramo = "009" AND _cod_subramo = "003" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF
		IF _cod_ramo = "009" AND _cod_subramo IN ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= "004"
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF	
		IF _cod_ramo = "005" AND _cod_subramo = "001" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "016" AND _cod_subramo <> "007" THEN    -- Colectivo de Vida Amado 28-05-2021
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '001'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "016" AND _cod_subramo = "007" THEN      -- Colectivo de Deuda Amado 28-05-2021 
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= '002'
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "001" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "017" AND _cod_subramo = "002" THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= _cod_subramo
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "019" AND _nueva_renov = 'N' THEN
		  UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= "001"
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF	

		IF _cod_ramo = "019" AND _nueva_renov = 'R' THEN
		 UPDATE ramosubrh
			 SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
		   WHERE cod_ramo        	= _cod_ramo
			 AND cod_subramo     	= "002"
			 AND periodo		   	= a_periodo1
			 AND origen				= 1;
		END IF

		IF _cod_ramo = "002" THEN
			SELECT no_poliza,
			       no_unidad
			  INTO _no_poliza2,
			       _no_unidad
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;
			  
			SELECT uso_auto    -- C - Comercial o P - Particular
			  INTO _uso_auto
			  FROM emiauto
			 WHERE no_poliza = _no_poliza2
			   AND no_unidad = _no_unidad;         
		 
			IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN  -- Pólizas sin info en Emiauto 
				FOREACH
					SELECT uso_auto    -- C - Comercial o P - Particular
					  INTO _uso_auto 
					  FROM endmoaut 
					 WHERE no_poliza = _no_poliza2
					   AND no_unidad = _no_unidad         
					exit FOREACH;
				end FOREACH			 

				IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
					LET _uso_auto = 'P';
				END IF 				
			END IF 			 
		 
			IF _uso_auto = 'P' THEN
				UPDATE ramosubrh
				   SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo     	= _cod_ramo
				   AND cod_subramo  	= "001"
			       AND periodo			= a_periodo1
				   AND origen			= 1;
			ELSE
				UPDATE ramosubrh
				   SET reserva_cedido 	= reserva_cedido + v_reserva_cedido
				 WHERE cod_ramo     	= _cod_ramo
				   AND cod_subramo  	= "002"
			       AND periodo			= a_periodo1
				   AND origen			= 1;
			END IF
	    END IF
		
 		IF _cod_ramo = "006" THEN
		 UPDATE ramosubrh
			SET reserva_cedido 	= reserva_cedido + v_reserva_cedido			
          WHERE cod_ramo     	= _cod_ramo
            AND cod_subramo  	= "001"
			AND periodo	   		= a_periodo1
			AND origen			= 1;
	    END IF
		
  		IF _cod_ramo = "015" THEN
		 UPDATE ramosubrh
			SET reserva_cedido 	= reserva_cedido + v_reserva_cedido			
          WHERE cod_ramo        = _cod_ramo
            AND cod_subramo     = "001"
			AND periodo			= a_periodo1
			AND origen			= 1;
		END IF

  		IF _cod_ramo IN ("026","027") THEN
		 UPDATE ramosubrh
			SET reserva_cedido 	= reserva_cedido + v_reserva_cedido			
          WHERE cod_ramo        = '015'
            AND cod_subramo     = "001"
			AND periodo 		= a_periodo1
			AND origen          = 1;
		END IF
	end if
end foreach

drop table if exists tmp_sinis;

return 0, "Actualizacion Exitosa";

end

end procedure;