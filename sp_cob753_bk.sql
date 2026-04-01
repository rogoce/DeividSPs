-- Cambio del proceso automatico que solo marque en estatus de cancelada
-- y permita en Deivid seleccionar las polizas a cancelar
-- Creado    : 27/10/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	

drop procedure sp_cob753;
create procedure sp_cob753(a_user_proceso CHAR(15))
returning integer,
          char(100);

define _no_documento	   char(20);
define _no_poliza          char(10);
define _cod_ramo           char(3);  
define _cobra_poliza	   char(1);
define _estatus_poliza	   char(1);
define _cod_tipoprod	   char(3);
define _cantidad		   SMALLINT;
define _fecha_emision	   date;
define _fecha_actual	   date;
define _fecha_marcar	   date;
define _cod_formapag	   char(3);
define _tipo_forma		   SMALLINT;
define _nombre_formapag	   char(50);
define _dias			   smallint;
define _return			   smallint;
define _error			   integer;
define _cancelada		   SMALLINT;
define _fecha_canc		   date;
define _fecha_proceso	   date;
define _saldo			   DEC(16,2);
define _saldo_act		   DEC(16,2);
define _saldo_canc		   DEC(16,2);
define _por_vencer		   DEC(16,2);
define _exigible		   DEC(16,2);
define _corriente		   DEC(16,2);
define _dias_30  		   DEC(16,2);
define _dias_60  		   DEC(16,2);
define _dias_90  		   DEC(16,2);
define _dias_120 		   DEC(16,2);
define _dias_150 		   DEC(16,2);
define _dias_180		   dec(16,2);
define _no_aviso 		   char(15);
define _user_added		   char(8);
define _renglon            integer;
define _descripcion        char(100);
define _pago_moro          SMALLINT;
define _tm_ultima_gestion  integer;
define _tm_fecha_efectiva  integer;
define _estatus_poliza2    SMALLINT;
define _saldo1             dec(16,2);
DEFINE _estatus			   CHAR(1);
define _mes_char		   char(2);
define _ano_char		   char(4);
DEFINE _periodo_c		   CHAR(7);
DEFINE _hay_pago		   SMALLINT;
DEFINE _saldo_pago 		   DECIMAL(16,2);
DEFINE _saldo_c   		   DECIMAL(16,2);
define _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);
DEFINE _saldo_sin_mora	   DECIMAL(16,2);
DEFINE _saldo_con_mora	   DECIMAL(16,2);
DEFINE _user_ciclo         CHAR(15);
DEFINE _fecha_ult_pago     date;
define _cod_pagador		   char(10);
define _bitacora		   char(255);
define _no_recibo		   char(20);
DEFINE _monto_rec	       DECIMAL(16,2);
DEFINE _fecha_quitar       date;
DEFINE _fecha_ult_gestion  date;
--define _tm_ultima_gestion  SMALLINT;

set isolation to dirty read;
set debug file to "sp_cob753.trc";
trace on;

begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

let _saldo_canc	= 0;
let _renglon = 0;
let _fecha_actual = sp_sis26();
let _tm_ultima_gestion = 0;
let _tm_fecha_efectiva = 0;
let _saldo_sin_mora = 0;
let _saldo_con_mora = 0;
let _user_ciclo = "";
let _bitacora = "";

IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

{foreach
select no_documento,
       no_poliza,
       saldo,
	   estatus_poliza,
	   fecha_ult_pago,
	   cod_pagador
  into _no_documento,		
	   _no_poliza,
	   _saldo,
	   _estatus_poliza,
	   _fecha_ult_pago,
	   _cod_pagador
  from emipomae 
 where trim(no_poliza||'.'||no_documento) in (select distinct trim(no_poliza||'.'||no_documento) from avisocanc where fecha_proceso > '10/11/2011') --no_aviso = '00004')
   and fecha_ult_pago >= '09/11/2011'
 order by 5,1,2



   let _dias_90  	  = 0;
   let _dias_120 	  = 0;
   let _dias_150 	  = 0;
   let _dias_180	  = 0;

	foreach
	 select no_aviso,renglon,cod_ramo,saldo,estatus,exigible,dias_90,dias_120,dias_150,dias_180
	   into _no_aviso,_renglon,_cod_ramo,_saldo_canc,_estatus,_exigible,_dias_90,_dias_120,_dias_150,_dias_180
	   from avisocanc
	  where no_documento = _no_documento
	    and no_poliza    = _no_poliza
		if _saldo_canc <> _saldo then	
			if _estatus not in ('Z','Y') then
			   -- si el pago es en el dia
			   TRACE Off;
 		   	   CALL sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
 		   	   RETURNING _por_vencer_c,
			 	   _exigible_c,
			 	   _corriente_c,
			 	   _dias_30_c,
			 	   _dias_60_c,
			 	   _dias_90_c,
			 	   _dias_120_c,
			 	   _dias_150_c,
			 	   _dias_180_c,
			 	   _saldo_c;
			    TRACE ON;
				 if _cod_ramo in ("004","016","018","019") then
				    let _saldo_sin_mora   = _saldo_c - (_dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
				    let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
			   else
				    let _saldo_sin_mora   = _saldo_c - (_dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
				    let _saldo_con_mora   = _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
			    end if

			 	if  (_saldo_con_mora = 0 or _saldo_con_mora <= 5) then
					let _descripcion = "CON PAGO INMEDIATO";
					let _estatus     = "Y";
				    let _cancelada   = 0;
				    let _fecha_canc  = _fecha_ult_pago; -- sp_sis26();

					if _estatus_poliza = 1 then
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_cancelacion = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 2 then
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_cancelacion = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 3 then	 --Vencida
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_cancelacion = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 4 then	 --Anulada
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_cancelacion = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					end if

						if _fecha_ult_pago  is not null then
							foreach
							 SELECT no_recibo,sum(monto)
							   INTO	_no_recibo,_monto_rec
							   FROM cobredet
							  WHERE doc_remesa   = _no_documento	-- Recibos de la Poliza
							    AND actualizado  = 1			    -- actualizado
							    AND tipo_mov     IN ('P', 'N', 'X')	-- Pagos-Creditos
							    AND fecha        = _fecha_ult_pago	-- Fecha Ultimo Pago					
							  group by 1
							  order by 2 desc
							   exit foreach;
							    end foreach

							     let _bitacora = "PAGO EFECTUADO "||_fecha_ult_pago||" RECIBO: "||trim(_no_recibo)|| ", MONTO: "||_monto_rec||" Y REF.: "||trim(_no_aviso);

								insert into cobgesti(no_poliza,fecha_gestion,desc_gestion,user_added,no_documento,fecha_aviso,tipo_aviso,cod_gestion,cod_pagador)
								values(_no_poliza,_fecha_actual,_bitacora,a_user_proceso,_no_documento,null,0,null,_cod_pagador);
						end if
				else
					let _descripcion = "";
					let _cancelada   = 0;
					let _fecha_canc  = sp_sis26(); --null;
				end if

				update avisocanc
				   set estatus         = _estatus,
				       cancela         = _cancelada,
					   fecha_cancela   = _fecha_canc,
					   motivo          = _descripcion,
					   user_cancela    = a_user_proceso,
					   exigible		   = _exigible_c,
					   corriente	   = _corriente_c,
					   por_vencer	   = _por_vencer_c,
					   dias_30		   = _dias_30_c,
					   dias_60		   = _dias_60_c,
					   dias_90		   = _dias_90_c,
					   dias_120	       = _dias_120_c,
					   dias_150		   = _dias_150_c,
					   dias_180		   = _dias_180_c,
					   saldo		   = _saldo_c
				 where no_poliza       = _no_poliza
				   and no_aviso        = _no_aviso
				   and renglon         = _renglon;

			end if
		end if
	end foreach
end foreach		}

--- CICLO DE ULTIMA GESTION -- FECHA EFECTIVA 48 horas
 select no_poliza,user_proceso,no_documento,fecha_proceso,cod_ramo,saldo,no_aviso,renglon,estatus_poliza,estatus,fecha_marcar,fecha_ult_gestion from avisocanc
  where estatus   = "X" and ult_gestion = "1"  INTO temp tmp_pol_gestion;

foreach	
 select no_poliza,
		user_proceso,
		no_documento,
		fecha_proceso, -- fecha_vence
		cod_ramo,
		saldo,
		no_aviso,
		renglon,
		estatus_poliza,
		estatus,
		fecha_marcar,
		fecha_ult_gestion
   into _no_poliza,
		_user_added,
		_no_documento,
		_fecha_proceso,
		_cod_ramo,
		_saldo_canc,
		_no_aviso,
		_renglon,
		_estatus_poliza,
		_estatus,
		_fecha_marcar,
		_fecha_ult_gestion
   from tmp_pol_gestion

		 select tm_ultima_gestion
		   into _tm_ultima_gestion
		   from avicanpar
		  Where cod_avican = _no_aviso ;

	  call sp_sis388a(_fecha_ult_gestion,_tm_ultima_gestion) returning _fecha_quitar; 				   

		if _fecha_quitar = '25/11/2011' then --_fecha_actual then

			select cod_pagador
			  into _cod_pagador
			  from emipomae 
			 where trim(no_poliza) = _no_poliza and trim(no_documento) = _no_documento;

				update avisocanc
				   set ult_gestion = 0,user_ult_gestion= "",fecha_ult_gestion = null
				 where no_poliza       = _no_poliza
				   and no_aviso        = _no_aviso
				   and renglon         = _renglon;

		     let _bitacora = "VENCIO ULTIMA GESTION "||_fecha_quitar||" REF.: "||trim(_no_aviso);

			insert into cobgesti(no_poliza,fecha_gestion,desc_gestion,user_added,no_documento,fecha_aviso,tipo_aviso,cod_gestion,cod_pagador)
			values(_no_poliza,_fecha_actual,_bitacora,a_user_proceso,_no_documento,null,0,null,_cod_pagador);		   
	   end if
end foreach


--- CICLO DE ENTREGADOS -- FECHA EFECTIVA 10 dias
foreach	
 select no_poliza,
		user_proceso,
		no_documento,
		fecha_proceso, -- fecha_vence
		cod_ramo,
		saldo,
		no_aviso,
		renglon,
		estatus_poliza,
		estatus,
		fecha_marcar
   into _no_poliza,
		_user_added,
		_no_documento,
		_fecha_proceso,
		_cod_ramo,
		_saldo_canc,
		_no_aviso,
		_renglon,
		_estatus_poliza,
		_estatus,
		_fecha_marcar
   from avisocanc
  where estatus   = "M" --and fecha_proceso <= '10/11/2011' -- "I" 

--  and no_poliza = "470489"  -- a_no_poliza
--  and no_aviso  = "00002"

	--  let _no_poliza = sp_sis21(_no_documento);
	    if _fecha_proceso is null then
			continue foreach;
		end if

		if _estatus_poliza <> 1 then
		    let _cancelada   = 0;
		    let _fecha_canc  = sp_sis26();
			let _descripcion = "POLIZA VENCIDA CON SALDO";
			update avisocanc
			   set estatus         = "Y",
			       cancela         = _cancelada,
				   fecha_cancela   = _fecha_canc,
				   motivo          = _descripcion,
				   user_cancela    = a_user_proceso
			 where no_poliza       = _no_poliza
			   and no_aviso        = _no_aviso
			   and renglon         = _renglon;

			update emipomae  
		   	   set carta_vencida_sal = 1,carta_prima_gan = 0,fecha_vencida_sal = today
	 		 where no_poliza = _no_poliza ;

			continue foreach;
		end if

		let _saldo		  = 0;
		let _saldo_act	  = 0;
		let _por_vencer	  = 0;
		let _exigible	  = 0;
		let _corriente	  = 0;
		let _dias_30  	  = 0;
		let _dias_60  	  = 0;
		let _dias_90  	  = 0;
		let _dias_120 	  = 0;
		let _dias_150 	  = 0;
		let _dias_180	  = 0;
		let _fecha_actual = today; -- "01/08/2011" ;	-- Para realizar las pruebas

		 select tm_ultima_gestion,
		        tm_fecha_efectiva
		   into _tm_ultima_gestion,
		        _tm_fecha_efectiva
		   from avicanpar
		  Where cod_avican = _no_aviso ;

		let _dias = _fecha_actual - _fecha_proceso ;
		let _dias = 20;
	    TRACE Off;
		call sp_sis388(_fecha_proceso,_fecha_actual) returning _dias;	 -- Se debe quitar este comentario
	    TRACE On;
		--if _dias <= 10 then
		--	continue foreach;
		--end if

		 if _dias <= _tm_fecha_efectiva then
			continue foreach;
		end if		

	 select count(*)
	   into _cantidad
	   from emipoliza
      where saldo > 0
	    and no_documento = _no_documento;

		if _cantidad = 0 then 
			let _saldo = 0;
			let _por_vencer = 0;
			let _exigible = 0;
			let _corriente = 0;
			let _dias_30 = 0;
			let _dias_60 = 0;
			let _dias_90 = 0;
			let _dias_120 = 0;
			let _dias_150 = 0;
			let _dias_180= 0;
      else 
		 select saldo,
				por_vencer,
				exigible,
				corriente,
				monto_30,
				monto_60,
				monto_90,
				monto_120,
				monto_150,
				monto_180
		   into _saldo,
				_por_vencer,
				_exigible,
				_corriente,
				_dias_30,
				_dias_60,
				_dias_90,
				_dias_120,
				_dias_150,
				_dias_180
		   from emipoliza
	      where saldo > 0
		    and no_documento = _no_documento;
      end if
		let _pago_moro = 0;
		 -- Para salud la morosidad es a 31 dias y para los demas a 91 dias
		 if _cod_ramo in ("004","016","018","019") then
			let _saldo_act = _dias_30 +	_dias_60 +  _dias_90 + _dias_120 + _dias_150 + _dias_180;			
			if _dias_30 = 0 then
				let _pago_moro = 1;
			end if
	   else
			let _saldo_act = _dias_60 + _dias_90 + _dias_120 + _dias_150 + _dias_180;
			if _dias_90 = 0 then
				let _pago_moro = 1;
			end if
	    end if
		    let _cancelada   = 0;
		    let _fecha_canc  = sp_sis26();
		 if _saldo_canc >= _saldo_act and _pago_moro = 0 then		-- X: Saldo moroso 
			let _descripcion = "SIN PAGO";
			update avisocanc
			   set estatus         = "X",
			       cancela         = _cancelada,
				   fecha_cancela   = _fecha_canc,
				   motivo          = _descripcion,
				   user_cancela    = a_user_proceso,
				   fecha_vence     = _fecha_canc
			 where no_poliza       = _no_poliza
			   and no_aviso        = _no_aviso
			   and renglon         = _renglon;
	   else								                            -- Y: Desmarca por pago
			let _descripcion = "CON PAGO";
			update avisocanc
			   set estatus         = "Y",
			       cancela         = _cancelada,
				   fecha_cancela   = _fecha_canc,
				   motivo          = _descripcion,
				   user_cancela    = a_user_proceso,
				   fecha_vence     = _fecha_canc
			 where no_poliza       = _no_poliza
			   and no_aviso        = _no_aviso
			   and renglon         = _renglon;
	    end if
end foreach
end 
return 0, "Actualizacion Exitosa ...";
end procedure	