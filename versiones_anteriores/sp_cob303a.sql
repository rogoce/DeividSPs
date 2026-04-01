--Procedimiento que verifica si las comision descontada del archivo coincide con las comision descontada calculada por el sistema
--para el proceso de pagos externos 	
--Creado    : 19/03/2012 - autor: Roman Gordon

drop procedure sp_cob303a;

create procedure "informix".sp_cob303a(a_numero char(10), a_renglon smallint)
returning	char(10) as a_numero,
			smallint as renglon,
			char(20) as no_documento,
			dec(16,2) as comis_desc_calc,
			dec(16,2) as monto_comis,
			dec(16,2) as comis_dif,
			char(10) as cod_agente;
			   
--returning	smallint,			char(50);

define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _monto_calc_x_agt	dec(16,2);
define _comis_desc_calc		dec(16,2);
define _monto_comis			dec(16,2);
define _comis_dif			dec(16,2);
define _factor				dec(16,2);
define _monto				dec(16,2);
define _prima				dec(16,2);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _renglon				smallint;
define _cnt                 smallint;



set isolation to dirty read;
--set debug file to "sp_cob303.trc";
--trace on;

let _monto_comis		= 0.00;
let _comis_desc_calc	= 0.00;
let _comis_dif			= 0.00;
let _cnt = 0;

foreach
	select renglon,
		   no_documento,
		   monto_cobrado,
		   monto_comis	
	  into _renglon,
	  	   _no_documento,
		   _monto,
	  	   _monto_comis
	  from cobpaex1
	 where numero = a_numero
	 and renglon = a_renglon

	call sp_sis21(_no_documento) returning _no_poliza;

	if _no_poliza is null or _no_poliza = '' then
		continue foreach;
	end if 
	
	select cod_agente
	  into _cod_agente
	  from cobpaex0 
	 where numero = a_numero;	
	 
	   let _cnt = 0;	 
	select count(*)
	  into _cnt
	  from emipoagt
	 where no_poliza = _no_poliza
	   and cod_agente = _cod_agente;
	   
	if _cnt is null then
		let _cnt = 0;
	end if		 

	select sum(i.factor_impuesto)
	  into _factor
	  from prdimpue i, emipolim p
	 where i.cod_impuesto = p.cod_impuesto
	   and p.no_poliza    = _no_poliza;
	
	if _factor is null then
		let _factor = 0;
	end if

	let _factor   = 1 + _factor / 100;
	let _prima    = _monto / _factor;

	foreach
		select cod_agente,	
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic,
			   _porc_comis
		  from emipoagt
		 where no_poliza  = _no_poliza
		 order by porc_partic_agt asc

		let _monto_calc_x_agt	= _prima * (_porc_partic / 100) * (_porc_comis / 100);
		let _comis_desc_calc	= _comis_desc_calc + _monto_calc_x_agt;   
	  
	end foreach

	if _comis_desc_calc <> _monto_comis or _cnt = 0 then  -- HGIRON 03/09/2018, Solicita AMORENO si poliza no pertenece al agente
		let _comis_dif = _comis_desc_calc - _monto_comis;
		  
		{insert into cobpaex4
			  (numero,
			   renglon,
			   no_documento,
			   comis_desc_calc,
			   comis_desc_archivo,
			   diferencia_comis,
			   cod_agente
			  )
		values(
			   a_numero,
			   _renglon,
			   _no_documento,
			   _comis_desc_calc,
			   _monto_comis,
			   _comis_dif,
			   _cod_agente
			  );}

		  return a_numero,
			   _renglon,
			   _no_documento,
			   _comis_desc_calc,
			   _monto_comis,
			   _comis_dif,
			   _cod_agente
		   WITH RESUME;
		   
	end if

	let _monto_comis		= 0.00;	
	let _comis_desc_calc	= 0.00;
	let _monto_calc_x_agt	= 0.00;
	let _comis_dif			= 0.00;

end foreach

--Return 0,'Insercion Exitosa';

END PROCEDURE;
