-- Cambio del proceso automatico que solo marque en estatus de cancelada
-- y permita en Deivid seleccionar las polizas a cancelar
-- Creado    : 27/10/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	 execute procedure sp_cob753bk()

drop procedure sp_cob753c;
create procedure sp_cob753c()
returning integer,
          char(100);

define _bitacora			varchar(255);
define _descripcion			varchar(100);
define _no_documento		char(20);
define _no_recibo			char(20);
define _no_aviso			char(15);
define _cod_pagador			char(10);
define _no_poliza2			char(10);
define _no_poliza			char(10);
define a_user_proceso		char(8);
define _periodo_c			char(7);
define _estatus				char(1);
define _saldo_con_mora		dec(16,2);
define _por_vencer_c		dec(16,2);
define _corriente_c			dec(16,2);
define _por_vencer			dec(16,2);
define _exigible_c			dec(16,2);
define _dias_180_c			dec(16,2);
define _dias_150_c			dec(16,2);
define _dias_120_c			dec(16,2);
define _dias_90_c			dec(16,2);
define _dias_60_c			dec(16,2);
define _dias_30_c			dec(16,2);
define _saldo_act			dec(16,2);
define _monto_rec			dec(16,2);
define _saldo_c				dec(16,2);
define _cancelada			smallint;
define _return				smallint;
define _error_isam			integer;
define _hay_pago			integer;
define _renglon				integer;
define _error				integer;
define _fecha_ult_pago		date;
define _fecha_gestion2		datetime year to second;
define _fecha_actual		date;
define _fecha_gestion		datetime year to second;
define _fecha_canc			date;

set isolation to dirty read;

--set debug file to "sp_cob753.trc";
--trace on;

let _fecha_gestion2	= sp_sis26();
let _fecha_actual	= sp_sis26();
{let _fecha_actual	= _fecha_actual - 2 UNITS DAY;
let _fecha_actual	= MDY(month(_fecha_actual),day(_fecha_actual),year(_fecha_actual)); }

begin
on exception set _error,_error_isam,_descripcion
	return _error,_descripcion;  -- "Error de Base de Datos";
end exception

select firma_end_canc
  into a_user_proceso
  from parparam
 where cod_compania = "001";

let _saldo_con_mora = 0;
let _renglon = 0;
let _bitacora = "";


---------------
--- PROCESAR PAGOS
---------------
--let _fecha_actual = '23/05/2017';
foreach with hold
	select distinct a.no_documento,
		   e.cod_pagador
	  into _no_documento,
		   _cod_pagador
	  from avisocanc a, emipoliza e, cobredet d
	 where a.no_documento = e.no_documento
	   and a.no_documento = d.doc_remesa
	   and a.estatus  not in ('Y','Z')
	   and d.tipo_mov in ('P')
	   and d.fecha >= a.fecha_imprimir
	   and e.cod_status = '1'
	   and d.actualizado = 1

	begin
		on exception in(-535)
		end exception
		
		begin work;
	end
	{foreach
		select distinct trim(no_poliza) 
		  into _no_poliza
		  from avisocanc 
		 where estatus not in ('Y')
		   and trim(no_documento) = _no_documento
		 order by 1 desc
		exit foreach;
	end foreach}

	let _no_poliza2 = sp_sis21(_no_documento);

	select max(fecha_ult_pago)
	  into _fecha_ult_pago
	  from emipomae
	 where no_documento = _no_documento;

	let _periodo_c = sp_sis39(_fecha_ult_pago);

	foreach
		select no_aviso,
			   renglon,
			   no_poliza
		  into _no_aviso,
		  	   _renglon,
			   _no_poliza
		  from avisocanc	   
		 where no_documento = _no_documento
		   and estatus      <> 'Y'


	   	call sp_cob245a("001","001",_no_documento,_periodo_c,_fecha_ult_pago)
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

		let _saldo_con_mora   = _dias_60_c + _dias_90_c + _dias_120_c + _dias_150_c + _dias_180_c;
		
		if _saldo_con_mora <= 5 then
			let _descripcion = "CON PAGO INMEDIATO";
			let _estatus     = "Y";
		    let _cancelada   = 0;
		    let _fecha_canc  = _fecha_ult_pago; -- sp_sis26();

			update emipomae  
			   set carta_aviso_canc		= 0,
				   fecha_aviso_canc		= null,
				   fecha_vencida_sal	= null,
				   carta_prima_gan		= 0,
				   carta_recorderis		= 0,
				   carta_vencida_sal	= 0
			 where no_poliza			in ( _no_poliza,_no_poliza2);

--			if _estatus <> 'Z' then
			if _fecha_ult_pago  is not null then
				foreach
					Select no_recibo,
						   sum(monto)
					  into _no_recibo,
						   _monto_rec
					  from cobredet
					 where doc_remesa = _no_documento	    -- Recibos de la Poliza
					   and actualizado = 1			        -- actualizado
					   and tipo_mov in ('P', 'N', 'X')	-- Pagos-Creditos
					   and fecha = _fecha_ult_pago	-- Fecha Ultimo Pago					
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

			return 1,_no_documento with resume;
		end if
	end foreach
	commit work;
end foreach
end 
return 0, "Actualizacion Exitosa ...";
end procedure