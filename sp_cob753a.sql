-- Cambio del proceso automatico que solo marque en estatus de cancelada
-- y permita en Deivid seleccionar las polizas a cancelar
-- Creado    : 27/10/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	 execute procedure sp_cob753()

drop procedure sp_cob753a;
create procedure sp_cob753a(a_no_documento char(20))
returning integer,
          char(100);

define _bitacora			char(255);
define _descripcion			char(100);
define _nombre				char(50);
define _nombre_formapag		char(50);
define _no_documento		char(20);
define _no_recibo			char(20);
define a_user_proceso		char(15);
define _no_aviso			char(15);
define _no_poliza2			char(10);
define _no_poliza			char(10);
define _user_ciclo			char(15);
define _cod_pagador			char(10);
define _no_factura			char(10);
define _periodo_c			char(7);
define _user_added			char(8);
define _ano_char			char(4);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_ramo			char(3);
define _mes_char			char(2);
define _estatus_poliza		char(1);  
define _cobra_poliza		char(1);
define _estatus				char(1);
define _return_trace		char(1);
define _estatus_poliza2		smallint;
define _tipo_forma			smallint;
define _cancelada			smallint;
define _pago_moro			smallint;
define _hay_pago			integer;
define _cantidad			integer;
define _return				smallint;
define _tm_ultima_gestion	integer;
define _tm_fecha_efectiva	integer;
define _renglon				integer;
define _error				integer;
define _dias				integer;
define _saldo				dec(16,2);
define _saldo_act			dec(16,2);
define _saldo_canc			dec(16,2);
define _por_vencer			dec(16,2);
define _exigible			dec(16,2);
define _corriente			dec(16,2);
define _dias_30				dec(16,2);
define _dias_60				dec(16,2);
define _dias_90				dec(16,2);
define _dias_120			dec(16,2);
define _dias_150			dec(16,2);
define _dias_180			dec(16,2);
define _saldo_pago			dec(16,2);
define _saldo_c				dec(16,2);
define _corriente_c			dec(16,2);
define _por_vencer_c		dec(16,2);
define _exigible_c			dec(16,2);
define _dias_30_c			dec(16,2);
define _dias_60_c			dec(16,2);
define _dias_90_c			dec(16,2);
define _dias_120_c			dec(16,2);
define _dias_150_c			dec(16,2);
define _dias_180_c			dec(16,2);
define _saldo_sin_mora		dec(16,2);
define _saldo_con_mora		dec(16,2);
define _monto_rec			dec(16,2);
define _saldo1				dec(16,2);
define _fecha_ult_gestion	date;
define _fecha_ult_pago		date;
define _fecha_proceso		date;
define _fecha_ult_vig		date;
define _fecha_emision		date;
define _fecha_quitar		date;
define _fecha_actual		date;
define _fecha_marcar		date;
define _fecha_canc			date;
define v_existe_end			integer;
define _existe_rev			integer;
define _fecha_gestion		datetime year to second;
define _fecha_gestion2		datetime year to second;


set isolation to dirty read;

--set debug file to "sp_cob753.trc";
--trace on;

{let _fecha_actual	= sp_sis26();
let _fecha_gestion2	= _fecha_actual;
let _fecha_actual	= _fecha_actual - 1 UNITS DAY;
let _fecha_actual	= MDY(month(_fecha_actual),day(_fecha_actual),year(_fecha_actual)); }

let _fecha_actual = today;
let _fecha_gestion2	= _fecha_actual;

begin
on exception set _error
	return _error,_return_trace;  -- "Error de Base de Datos";
end exception

select firma_end_canc
  into a_user_proceso
  from parparam
 where cod_compania = "001";

let _renglon = 0;
let _saldo_canc	= 0;
let _tm_ultima_gestion = 0;
let _tm_fecha_efectiva = 0;
let _saldo_sin_mora = 0;
let _saldo_con_mora = 0;
let _user_ciclo = "";
let _bitacora = "";

if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;

let _return_trace = 'A';
	 
---------------
--- PROCESAR PAGOS

foreach
	select b.fecha,b.doc_remesa,sum(b.monto)
	  into _fecha_ult_pago,_no_documento,_saldo
	  from cobremae a,cobredet b
	 where a.no_remesa = b.no_remesa
	   and b.actualizado  = 1
	   and trim(b.doc_remesa) = a_no_documento
	   and b.tipo_mov     in ('P', 'N', 'X')	-- Pagos - Creditos
	   and a.date_posteo	>= _fecha_actual --'25/02/2014'
	 group by 1,2
	 order by 1,2

	foreach
		select distinct trim(no_poliza) 
		  into _no_poliza
		  from avisocanc 
		 where estatus not in ('Y')
		   and trim(no_documento) = _no_documento
		 order by 1 desc
		exit foreach;
	end foreach

	let _no_poliza2 = sp_sis21(_no_documento);

	select saldo,
		   estatus_poliza, 
		   cod_pagador
	  into _saldo,
		   _estatus_poliza,
		   _cod_pagador
	  from emipomae 
	 where trim(no_poliza)    = _no_poliza2
	   and trim(no_documento) =	_no_documento;

	foreach
		select no_aviso,
			   renglon,
			   cod_ramo,
			   saldo,
			   exigible,
			   dias_90,
			   dias_120,
			   dias_150,
			   dias_180,
			   fecha_proceso
		  into _no_aviso,
		  	   _renglon,
		  	   _cod_ramo,
		  	   _saldo_canc,
		  	   _exigible,
		  	   _dias_90,
		  	   _dias_120,
		  	   _dias_150,
		  	   _dias_180,
		  	   _fecha_proceso
		  from avisocanc	   
		 where no_documento = _no_documento
	       and no_poliza    = _no_poliza
		   and estatus      <> 'Y'

		let _dias_90  	  = 0;
		let _dias_120 	  = 0;
		let _dias_150 	  = 0;
		let _dias_180	  = 0;

	   	call sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
		returning _por_vencer_c,
				  _exigible_c,
				  _corriente_c,
				  _dias_30_c,
				  _dias_60_c,
				  _dias_90_c,
				  _dias_120_c,
				  _dias_150_c,
				  _dias_180_c,
				  _saldo_c;
				
		let _saldo_sin_mora   = _saldo_c - (_dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
		let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;

		if _saldo_con_mora <= 5 then
			let _descripcion = "CON PAGO INMEDIATO";
			let _estatus     = "Y";
		    let _cancelada   = 0;
		    let _fecha_canc  = _fecha_ult_pago; -- sp_sis26();
			let _pago_moro = 1;

			update emipomae  
			   set carta_aviso_canc		= 0,
				   fecha_aviso_canc		= null,
				   fecha_vencida_sal	= null,
				   carta_prima_gan		= 0,
				   carta_recorderis		= 0,
				   carta_vencida_sal	= 0
			 where no_poliza			= _no_poliza;

			if _fecha_ult_pago  is not null then
				foreach
					Select no_recibo,sum(monto)
					  into _no_recibo,_monto_rec
					  from cobredet
					 where doc_remesa   = _no_documento	-- Recibos de la Poliza
					   and actualizado  = 1			    -- actualizado
					   and tipo_mov     in ('P', 'N', 'X')	-- Pagos-Creditos
					   and fecha        = _fecha_ult_pago	-- Fecha Ultimo Pago					
					 group by 1
					 order by 2 desc
					exit foreach;
				end foreach

				let _fecha_gestion  = current year to second;
				let _fecha_gestion  = _fecha_gestion + 1 units second;		

				if _fecha_gestion = _fecha_gestion2 then
					let _fecha_gestion  = _fecha_gestion + 1 units second;
				end if
				
				let _fecha_gestion2 = _fecha_gestion;	
				let _bitacora = "PAGO EFECTUADO "||_fecha_ult_pago||" RECIBO: "||trim(_no_recibo)|| ", MONTO: "||_monto_rec||" Y REF.: "||trim(_no_aviso);

				select count(*)
				  into _hay_pago
				  from cobgesti
				 where no_poliza = _no_poliza
				   and fecha_gestion = _fecha_gestion;

				if _hay_pago = 0 then
					insert into cobgesti(
						   no_poliza,
						   fecha_gestion,
						   desc_gestion,
						   user_added,
						   no_documento,
						   fecha_aviso,
						   tipo_aviso,
						   cod_gestion,
						   cod_pagador)
					values(
						   _no_poliza,
						   _fecha_gestion,
						   _bitacora,
						   a_user_proceso,
						   _no_documento,
						   _fecha_ult_pago,
						   0,
						   null,
						   _cod_pagador);
				end if
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
			
			return 1,'La Póliza '|| trim(a_no_documento) ||' fue Pagada el día de hoy.';
		end if
	end foreach
end foreach
end 
return 0, "Actualizacion Exitosa ...";
end procedure	