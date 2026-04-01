-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo003_doc;

create procedure "informix".sp_bo003_doc(
a_no_documento	char(20),
a_periodo 			char(7))
returning char(1),
          char(100);
							  
define _doc_poliza		char(20);		  
define _no_poliza		char(10);

define a_fecha			date;
define _mes_contable    char(2);
define _ano_contable    char(4);
define _periodo         char(7);

define _saldo           dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define _monto_120       dec(16,2);
define _monto_150       dec(16,2);
define _monto_180       dec(16,2);
define _cobra_poliza	char(1);
define _monto           dec(16,2);
define _monto_pagado    dec(16,2);
define _montoTotal      dec(16,2);
define _montoPagado     dec(16,2);
define _saldo_vencer    dec(16,2);
define _saldo_exigible  dec(16,2);
define _saldo_corriente dec(16,2);
define _saldo_30        dec(16,2);
define _saldo_60        dec(16,2);
define _saldo_90        dec(16,2);
define _saldo_120       dec(16,2);
define _saldo_150       dec(16,2);
define _saldo_180       dec(16,2);

define _cod_tipoprod	char(3);
define _cantidad		smallint;

define _porc_impuesto	dec(16,2);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur    char(3);

define _cobros_neto     dec(16,2);
define _por_vencer_neto dec(16,2);
define _exigible_neto   dec(16,2);
define _corriente_neto  dec(16,2);
define _monto_30_neto   dec(16,2);
define _monto_60_neto   dec(16,2);
define _monto_90_neto   dec(16,2);

define _cobros_pxc      dec(16,2);
define _por_vencer_pxc  dec(16,2);
define _exigible_pxc    dec(16,2);
define _corriente_pxc   dec(16,2);
define _monto_30_pxc    dec(16,2);
define _monto_60_pxc    dec(16,2);
define _monto_90_pxc    dec(16,2);

--SET DEBUG FILE TO "sp_bo003.trc"; 

set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam;

let a_fecha = sp_sis36(a_periodo);

update deivid_cob:cobmoros4
   set cobros_por_vencer      	= 0.00,
       cobros_exigible        	= 0.00,
	   cobros_corriente       	= 0.00,
	   cobros_30		      		= 0.00,
	   cobros_60		      		= 0.00,
	   cobros_90              		= 0.00,
	   cobros_total		      	= 0.00,
       cobros_por_vencer_neto	= 0.00,
       cobros_exigible_neto  		= 0.00,
	   cobros_corriente_neto 		= 0.00,
	   cobros_30_neto		  		= 0.00,
	   cobros_60_neto		  		= 0.00,
	   cobros_90_neto      		= 0.00,
	   cobros_total_neto	  		= 0.00,
	   cobros_por_vencer_pxc		= 0.00,
       cobros_exigible_pxc		= 0.00,
	   cobros_corriente_pxc		= 0.00,
	   cobros_30_pxc	      		= 0.00,
	   cobros_60_pxc	      		= 0.00,
	   cobros_90_pxc          		= 0.00,
	   cobros_total_pxc	      	= 0.00
 where no_documento				= a_no_documento
   and periodo                		= a_periodo;

--trace on;
foreach 
 select doc_remesa,
        sum(monto)
   into _doc_poliza,
        _monto_pagado
   from cobredet
  where doc_remesa	= a_no_documento
    and actualizado  	= 1	   
    and tipo_mov     	IN ('P', 'N')
    and periodo      	= a_periodo
  group by doc_remesa		

	let _no_poliza = sp_sis21(_doc_poliza);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from deivid_cob:cobmoros4
	 where no_documento = _doc_poliza
	   and periodo      = a_periodo;

	if _cantidad = 0 then

		call sp_bo007(_doc_poliza, a_periodo);

	end if

	select por_vencer,
	   	   exigible,
		   corriente,
		   dias_30,
		   dias_60,
		   dias_90,
		   saldo
	  into _por_vencer,
	       _exigible,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _saldo
	  from deivid_cob:cobmoros4
	 where no_documento	= _doc_poliza
	   and periodo      	= a_periodo;

	let _saldo_vencer    	= _por_vencer;
	let _saldo_exigible  	= _exigible;
	let _saldo_corriente	= _corriente;
	let _saldo_30        	= _monto_30;
	let _saldo_60        	= _monto_60;
	let _saldo_90        	= _monto_90;

	LET _montoTotal      	= _corriente + _monto_30 + _monto_60 + _monto_90 + _por_vencer;
	LET _montoPagado     	= _monto_pagado;

	IF _montoTotal > 0 THEN

		IF _monto_90 <> 0 THEN

			IF _monto_90 >= _montoPagado THEN

				LET _monto_90    = _montoPagado;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_90;

			END IF	

		END IF

		IF _monto_60 <> 0 THEN

			IF _monto_60 >= _montoPagado THEN

				LET _monto_60    = _montoPagado;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_60;

			END IF	

		END IF

		IF _monto_30 <> 0 THEN

			IF _monto_30 >= _montoPagado THEN

				LET _monto_30    = _montoPagado;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_30;

			END IF	

		END IF
		
		IF _corriente <> 0 THEN

			IF _corriente >= _montoPagado THEN

				LET _corriente   = _montoPagado;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _corriente;

			END IF	

		END IF

		IF _por_vencer <> 0 THEN

			LET _por_vencer  = _montoPagado;
			LET _montoPagado = 0;

		END IF

		IF _montoPagado <> 0 THEN
			LET _corriente = _corriente + _montoPagado;
		END IF			

	ELSE

		LET _monto_90   = 0;
		LET _monto_60   = 0;
		LET _monto_30   = 0;
		LET _corriente  = _montoPagado;
		LET _por_vencer = 0;

	END IF

	LET _exigible = _corriente + _monto_30 + _monto_60 + _monto_90;

	let _cobros_neto     	= 0.00;
	let _por_vencer_neto	= 0.00;
	let _exigible_neto   	= 0.00;
	let _corriente_neto  	= 0.00;
	let _monto_30_neto   	= 0.00;
	let _monto_60_neto   	= 0.00;
	let _monto_90_neto   	= 0.00;

	let _cobros_pxc     	= 0.00;
	let _por_vencer_pxc 	= 0.00;
	let _exigible_pxc   	= 0.00;
	let _corriente_pxc  	= 0.00;
	let _monto_30_pxc   	= 0.00;
	let _monto_60_pxc   	= 0.00;
	let _monto_90_pxc   	= 0.00;

{
	select sum(i.factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;  

	if _porc_impuesto is null then
		let _porc_impuesto = 0.00;
	end if


	let _cobros_neto     = _monto_pagado / (1 + (_porc_impuesto / 100));
	let _por_vencer_neto = _por_vencer   / (1 + (_porc_impuesto / 100));
	let _exigible_neto   = _exigible     / (1 + (_porc_impuesto / 100));
	let _corriente_neto  = _corriente    / (1 + (_porc_impuesto / 100));
	let _monto_30_neto   = _monto_30     / (1 + (_porc_impuesto / 100));
	let _monto_60_neto   = _monto_60     / (1 + (_porc_impuesto / 100));
	let _monto_90_neto   = _monto_90     / (1 + (_porc_impuesto / 100));

	let _cobros_pxc     = _cobros_neto;
	let _por_vencer_pxc = _por_vencer_neto;
	let _exigible_pxc   = _exigible_neto;
	let _corriente_pxc  = _corriente_neto;
	let _monto_30_pxc   = _monto_30_neto;
	let _monto_60_pxc   = _monto_60_neto;
	let _monto_90_pxc   = _monto_90_neto;

	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _cobros_neto     = _cobros_neto     * (_porc_coaseguro / 100);
		let _por_vencer_neto = _por_vencer_neto * (_porc_coaseguro / 100);
		let _exigible_neto   = _exigible_neto   * (_porc_coaseguro / 100);
		let _corriente_neto  = _corriente_neto  * (_porc_coaseguro / 100);
		let _monto_30_neto   = _monto_30_neto   * (_porc_coaseguro / 100);
		let _monto_60_neto   = _monto_60_neto   * (_porc_coaseguro / 100);
		let _monto_90_neto   = _monto_90_neto   * (_porc_coaseguro / 100);

	end if
}


	update deivid_cob:cobmoros4
	   set cobros_por_vencer      	= _por_vencer,
	       cobros_exigible        	= _exigible,
		   cobros_corriente       	= _corriente,
		   cobros_30		      		= _monto_30,
		   cobros_60		      		= _monto_60,
		   cobros_90              		= _monto_90,
		   cobros_total		      	= _monto_pagado,
	       cobros_por_vencer_neto	= _por_vencer_neto,
    	   cobros_exigible_neto   	= _exigible_neto,
	   	   cobros_corriente_neto  	= _corriente_neto,
		   cobros_30_neto		  		= _monto_30_neto,
		   cobros_60_neto		  		= _monto_60_neto,
		   cobros_90_neto         	= _monto_90_neto,
		   cobros_total_neto	  		= _cobros_neto,
		   cobros_por_vencer_pxc  	= _por_vencer_pxc,
	       cobros_exigible_pxc    	= _exigible_pxc,
		   cobros_corriente_pxc   	= _corriente_pxc,
		   cobros_30_pxc	      		= _monto_30_pxc,
		   cobros_60_pxc	      		= _monto_60_pxc,
		   cobros_90_pxc          		= _monto_90_pxc,
		   cobros_total_pxc	      	= _cobros_pxc
	 where no_documento           	= _doc_poliza
	   and periodo                		= a_periodo;

end foreach

--trace off;

return 0, "Actualizacion Exitosa";

end procedure
