-- Cambio del proceso automatico que solo marque en estatus de cancelada
-- y permita en Deivid seleccionar las polizas a cancelar
-- Creado    : 27/10/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	 execute procedure sp_cob753_pg()

drop procedure sp_cob753_PG;
create procedure sp_cob753_PG()
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
define _hay_pago			smallint;
define _cantidad			smallint;
define _return				smallint;
define _dias				smallint;
define _tm_ultima_gestion	integer;
define _tm_fecha_efectiva	integer;
define _renglon				integer;
define _error				integer;
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
define _fecha_gestion		datetime year to second;
define _fecha_gestion2		datetime year to second;

--define _tm_ultima_gestion SMALLINT;

set isolation to dirty read;
--set debug file to "sp_cob753.trc";
--trace on;
let _fecha_actual	= sp_sis26();
let _fecha_gestion2	= _fecha_actual;
let _fecha_actual	= _fecha_actual - 1 UNITS DAY;
let _fecha_actual	= MDY(month(_fecha_actual),day(_fecha_actual),year(_fecha_actual)); 
--trace off;

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
--trace on;
let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;
--if _fecha_actual <> '15/02/2012' then
let _fecha_actual = '07/07/2012';
--let _fecha_actual = '29/04/2012';
--end if

let _return_trace = 'A';
--- desmarcar cancelacion motivos varios  
{foreach
	select p.no_documento,f.no_factura,m.nombre,f.fecha_emision --,p.fecha_cancelacion
	  into	_no_documento,_no_factura,_descripcion,_fecha_proceso
	  from emipomae p, endedmae f , endtican m
	 where p.fecha_cancelacion is not null 
	   and p.estatus_poliza	= '2'
	   and p.no_poliza		= f.no_poliza
	   and f.fecha_emision	= _fecha_actual  
	   and trim(p.no_documento) in (select distinct trim(no_documento) from avisocanc where estatus not in ('Y','Z'))
	   and f.cod_endomov	= '002'
	   and f.actualizado	= 1
	   and f.activa			= 1
	   and f.cod_tipocan	= m.cod_tipocan
	 order by 1,2

	let _cantidad = 0;
	select count(*)
	  into _cantidad 
	  from avisocanc  
	 where estatus not in ('Y','Z') 
	   and trim(no_documento) = _no_documento; 

	if _cantidad > 0 then 

		foreach
			select distinct trim(no_poliza) 
			  into _no_poliza 
			  from avisocanc 
			 where estatus not in ('Y','Z') 
			   and trim(no_documento) = _no_documento 
			exit foreach; 
		end foreach 

		foreach
			select no_aviso,renglon,estatus_poliza
			  into _no_aviso,_renglon,_estatus_poliza
			  from avisocanc
			 where no_documento = _no_documento
			   and no_poliza    = _no_poliza
			 order by fecha_proceso desc

			exit foreach;
		end foreach

		select cod_pagador
		  into _cod_pagador
		  from emipomae 
		 where trim(no_poliza) = _no_poliza and trim(no_documento) = _no_documento;

		update avisocanc
		   set estatus			= "Y",  -- Se desmarca y se coloca motivo
		       cancela			= 1,
			   fecha_cancela	= _fecha_actual,
			   motivo			= _descripcion,
			   user_cancela		= a_user_proceso,
			   fecha_vence		= _fecha_actual,
			   no_factura		= _no_factura
		 where no_poliza		= _no_poliza
		   and no_aviso			= _no_aviso
		   and renglon			= _renglon;

   		let _fecha_gestion  = current year to second;
		let _fecha_gestion  = _fecha_gestion + 1 units second;

		if _fecha_gestion = _fecha_gestion2 then
			let _fecha_gestion  = _fecha_gestion + 1 units second;			
		end if 

		let _fecha_gestion2 = _fecha_gestion;		
		let _bitacora = "CANCELACION MOTIVOS VARIOS, FACTURA: "||trim(_no_factura)||" MOTIVO: "||trim(_descripcion)||" El DIA: "||_fecha_proceso||" REF.: "||trim(_no_aviso);

		select count(*)
		  into _hay_pago
		  from cobgesti
		 where no_poliza = _no_poliza
		   and fecha_gestion = _fecha_gestion;

		if _hay_pago = 0 then

			insert into cobgesti(no_poliza,
								 fecha_gestion,
								 desc_gestion,
								 user_added,
								 no_documento,
								 fecha_aviso,
								 tipo_aviso,
								 cod_gestion,
								 cod_pagador)
						  values(_no_poliza,
						  		 _fecha_gestion,
						  		 _bitacora,
						  		 a_user_proceso,
						  		 _no_documento,
						  		 _fecha_proceso,
						  		 0,
						  		 null,
						  		 _cod_pagador);
			--					values(_no_poliza,_fecha_proceso,_bitacora,a_user_proceso,_no_documento,_fecha_actual,0,null,_cod_pagador);	

			if _estatus_poliza = 1 then
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
				 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 2 then
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
				 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 3 then	 --Vencida
				update emipomae  
			   	   set carta_aviso_canc		= 0,
					   fecha_aviso_canc		= null,
					   fecha_vencida_sal	= null,
					   carta_prima_gan		= 0,
					   carta_recorderis		= 0,
					   carta_vencida_sal	= 0
				 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 4 then	-- Anulada
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
				 where no_poliza			= _no_poliza;
			end if
		end if
	end if
end foreach	}

--- PROCESAR PAGOS

foreach
	select fecha,doc_remesa,sum(monto)
	  into	_fecha_ult_pago,_no_documento,_saldo
	  from cobredet
	 where actualizado  = 1
	   and trim(doc_remesa) in (select distinct trim(no_documento) from avisocanc where estatus not in ('Y','Z'))
	   and tipo_mov     in ('P', 'N', 'X')	-- Pagos - Creditos
	   and fecha        >= '01/01/2012' --_fecha_actual
	 group by 1,2
	 order by 1,2

	foreach
		select distinct trim(no_poliza) 
		  into _no_poliza
		  from avisocanc 
		 where estatus not in ('Y','Z')
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
	 where trim(no_poliza) =  _no_poliza2
	   and trim(no_documento) =	_no_documento;

	foreach
		select no_aviso,
			   renglon,
			   cod_ramo,
			   saldo,
			   estatus,
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
		  	   _estatus,
		  	   _exigible,
		  	   _dias_90,
		  	   _dias_120,
		  	   _dias_150,
		  	   _dias_180,
		  	   _fecha_proceso
		  from avisocanc
		 where no_documento = _no_documento
	    and no_poliza    = _no_poliza

		let _dias_90  	  = 0;
		let _dias_120 	  = 0;
		let _dias_150 	  = 0;
		let _dias_180	  = 0;

--	   TRACE Off;
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
--	   TRACE ON;
		if _cod_ramo in ("004","016","018","019") then
			let _saldo_sin_mora   = _saldo_c - (_dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
			let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c;
		else
			let _saldo_sin_mora   = _saldo_c - (_dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
			let _saldo_con_mora   = _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
		end if

		if (_saldo_con_mora = 0 or _saldo_con_mora <= 5) then
			let _descripcion = "CON PAGO INMEDIATO";
			let _estatus     = "Y";
		    let _cancelada   = 0;
		    let _fecha_canc  = _fecha_ult_pago; -- sp_sis26();

			if _estatus_poliza = 1 then	     -- Vigentes
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
		 		 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 2 then	 -- Canceladas
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
		 		 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 3 then	 -- Vencida
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
		 		 where no_poliza			= _no_poliza;
			elif _estatus_poliza = 4 then	 -- Anulada
				update emipomae  
			   	   set carta_aviso_canc		= 0,
			   	   	   fecha_aviso_canc		= null,
			   	   	   fecha_vencida_sal	= null,
			   	   	   carta_prima_gan		= 0,
			   	   	   carta_recorderis		= 0,
			   	   	   carta_vencida_sal	= 0
		 		 where no_poliza			= _no_poliza;
			end if

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
	end foreach
end foreach

let _return_trace = 'B';
--- CICLO DE ULTIMA GESTION -- FECHA EFECTIVA 48 horas
{select no_poliza,
	   user_proceso,
	   no_documento,
	   fecha_proceso,
	   cod_ramo,
	   saldo,
	   no_aviso,
	   renglon,
	   estatus_poliza,
	   estatus,
	   fecha_marcar,
	   fecha_ult_gestion 
  from avisocanc
 where estatus		= "X" 
   and ult_gestion	= "1"  
  into temp tmp_pol_gestion;

let _fecha_gestion2  = current year to second;
foreach	
	select no_poliza,
		   user_proceso,
		   no_documento,
		   fecha_proceso,
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

	select tm_ultima_gestion,
		   tm_fecha_efectiva
	  into _tm_ultima_gestion,
	  	   _tm_fecha_efectiva
	  from avicanpar
	 where cod_avican = _no_aviso;
--		   trace off;
	call sp_sis388a(_fecha_ult_gestion,_tm_ultima_gestion) returning _fecha_quitar; 				   
--		   trace on;
	if _fecha_quitar = _fecha_actual then

	select cod_pagador
	  into _cod_pagador
	  from emipomae 
	 where trim(no_poliza) = _no_poliza and trim(no_documento) = _no_documento;
--		   trace off;
	call sp_sis388a(_fecha_marcar,_tm_fecha_efectiva) returning _fecha_canc; 	
--		   trace on;
	update avisocanc
	   set ult_gestion			= 0,
	   	   user_ult_gestion		= "",
	   	   fecha_ult_gestion	= null,
	   	   fecha_cancela		= _fecha_canc,
	   	   fecha_vence			= _fecha_canc
	 where no_poliza			= _no_poliza    
	   and no_aviso				= _no_aviso    
	   and renglon				= _renglon;    

	let _fecha_gestion  = CURRENT YEAR TO SECOND;
	LET _fecha_gestion  = _fecha_gestion + 1 UNITS SECOND;
    		
	if _fecha_gestion = _fecha_gestion2 then
		let _fecha_gestion  = _fecha_gestion + 1 UNITS SECOND;
	end if

	let _fecha_gestion2 = _fecha_gestion;	
    let _bitacora = "VENCIO ULTIMA GESTION "||_fecha_quitar||" REF.: "||trim(_no_aviso);

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
	values(_no_poliza,
		   _fecha_gestion,
		   _bitacora,
		   a_user_proceso,
		   _no_documento,
		   _fecha_quitar,
		   0,
		   null,
		   _cod_pagador);	
   
   end if
end foreach
drop table tmp_pol_gestion;	}

let _return_trace = 'C';
--- Procesar vencidas a la vigencia.
{
foreach
	select no_documento,
		   no_poliza,
		   saldo,
		   estatus_poliza,
		   vigencia_final,
		   cod_pagador
	  into _no_documento,
	  	   _no_poliza,
	  	   _saldo,
	  	   _estatus_poliza,
	  	   _fecha_ult_vig,
	  	   _cod_pagador
	  from emipomae 
	 where trim(no_poliza||'.'||no_documento) in (select distinct trim(no_poliza||'.'||no_documento) from avisocanc where fecha_proceso > '10/11/2011' and estatus = 'G' and estatus_poliza = 1 ) 
 	   and estatus_poliza = 3  and vigencia_final >= '10/11/2011'
	 order by 5,1,2

	let _dias_90  	  = 0;
	let _dias_120 	  = 0;
	let _dias_150 	  = 0;
	let _dias_180	  = 0;

	foreach
		select no_aviso,
			   renglon,
			   cod_ramo,
			   saldo,
			   estatus,
			   exigible,
			   dias_90,
			   dias_120,
			   dias_150,
			   dias_180
		  into _no_aviso,
		  	   _renglon,
		  	   _cod_ramo,
		  	   _saldo_canc,
		  	   _estatus,
		  	   _exigible,
		  	   _dias_90,
		  	   _dias_120,
		  	   _dias_150,
		  	   _dias_180
		  from avisocanc
		 where no_documento = _no_documento
		   and no_poliza    = _no_poliza

		if _estatus not in ('Z','Y') then
		   -- si el pago es en el dia
--		       TRACE Off;
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
--		       TRACE ON;
			if _cod_ramo in ("004","016","018","019") then
				let _saldo_sin_mora   = _saldo_c - (_dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
				let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
			else
				let _saldo_sin_mora   = _saldo_c - (_dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c );
				let _saldo_con_mora   = _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
		    end if

		 	if (_saldo_con_mora = 0 or _saldo_con_mora <= 5) then
				let _descripcion = "CON PAGO INMEDIATO";
				let _estatus     = "Y";
				let _cancelada   = 0;
				let _fecha_canc  = _fecha_ult_vig; -- sp_sis26();

				if _estatus_poliza = 1 then
					update emipomae  
					   set carta_aviso_canc 	= 0,
					   	   fecha_aviso_canc		= null,
					   	   fecha_vencida_sal	= null,
					   	   carta_prima_gan		= 0,
					   	   carta_recorderis		= 0,
					   	   carta_vencida_sal	= 0
			 		 where no_poliza			= _no_poliza;
				elif _estatus_poliza = 2 then
					update emipomae  
				   	   set carta_aviso_canc		= 0,
				   	   	   fecha_aviso_canc		= null,
				   	   	   fecha_vencida_sal	= null,
				   	   	   carta_prima_gan		= 0,
				   	   	   carta_recorderis		= 0,
				   	   	   carta_vencida_sal	= 0
			 		 where no_poliza			= _no_poliza;
				elif _estatus_poliza = 3 then	 --Vencida
					update emipomae  
				   	   set carta_aviso_canc		= 0,
				   	   	   fecha_aviso_canc		= null,
				   	   	   fecha_vencida_sal	= null,
				   	   	   carta_prima_gan		= 0,
				   	   	   carta_recorderis		= 0,
				   	   	   carta_vencida_sal	= 0
			 		 where no_poliza			= _no_poliza;
				elif _estatus_poliza = 4 then	-- Anulada
					update emipomae  
				   	   set carta_aviso_canc		= 0,
				   	   	   fecha_aviso_canc		= null,
				   	   	   fecha_vencida_sal	= null,
				   	   	   carta_prima_gan		= 0,
				   	   	   carta_recorderis		= 0,
				   	   	   carta_vencida_sal	= 0
			 		 where no_poliza			= _no_poliza;
				end if

			else
				let _descripcion = "";
				let _cancelada   = 0;
				let _fecha_canc  = sp_sis26();  -- Null;
			end if
			let _estatus = "3";
			if _fecha_ult_vig  is not null then
				let _fecha_gestion  = current year to second;
				let _fecha_gestion  = _fecha_gestion + 1 units second;
				
				if _fecha_gestion = _fecha_gestion2 then
					let _fecha_gestion  = _fecha_gestion + 1 units second;
				end if

				let _fecha_gestion2 = _fecha_gestion;						
		    	let _bitacora = "POLIZA VENCIDA POR VIGENCIA FINAL AL "||_fecha_ult_vig||" REF.: "||trim(_no_aviso);

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
				values(_no_poliza,
					   _fecha_gestion,
					   _bitacora,
					   a_user_proceso,
					   _no_documento,
					   _fecha_ult_vig,
					   0,
					   null,
					   _cod_pagador);
			end if
			update avisocanc
			   set estatus_poliza  = _estatus,
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
	end foreach
end foreach	
 }
let _return_trace = 'D';
--- CICLO DE ENTREGADOS -- FECHA EFECTIVA 10 dias
{foreach	
	select no_poliza,
		   user_proceso,
		   no_documento,
		   fecha_proceso,  -- fecha_vence
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
	 where estatus   = "M" 

	--  let _no_poliza2 = sp_sis21(_no_documento); 
	if _fecha_proceso is null then
		continue foreach;
	end if
	if _fecha_marcar is null then
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
		   set carta_vencida_sal = 1,fecha_vencida_sal = today   --,carta_prima_gan = 0
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
	 where cod_avican = _no_aviso;

	let _dias = _fecha_actual - _fecha_proceso;
	let _dias = 20;
--	    TRACE Off;
	call sp_sis388(_fecha_marcar,_fecha_actual) returning _dias;	 -- Se debe quitar este comentario
--	    TRACE On;
 
	if _dias <= _tm_fecha_efectiva then
		continue foreach;
	end if		
--	    TRACE Off;
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
--	    TRACE ON;
	  -- Para salud la morosidad es a 31 dias y para los demas a 91 dias
	if _cod_ramo in ("004","016","018","019") then
		let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
	else
		let _saldo_con_mora   = _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c ;
	end if

	let _cancelada   = 0;
	let _fecha_canc  = sp_sis26();
	if (_saldo_con_mora = 0 or _saldo_con_mora <= 5) then	 -- Y: Desmarca por pago
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
	else								                           -- X: Saldo moroso 
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
	end if 
end foreach} 
end 
return 0, "Actualizacion Exitosa ...";
end procedure	

