-- PBI
-- Devuelve Información para la tabla FacTableCoberturas
-- Creado    : 28/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi09;
CREATE PROCEDURE sp_pbi09(a_fecha1 date, a_fecha2 date)
RETURNING char(5)     as CodCobertura,
          date        as FechaEmision,
          date        as FechaDesde,
		  date        as FechaHasta,
		  dec(9,6)    as Tarifa,
      	  varchar(50) as Deducible,
          dec(16,2)   as LimitePorPersona,
          dec(16,2)   as LimitePorAccidente,	
		  dec(16,2)   as PrimaAnual,
		  dec(16,2)   as PrimaBruta,
		  dec(16,2)   as PrimaNeta,
		  dec(16,2)   as Primacedida,
  		  dec(16,2)   as Primaretenida,
		  dec(16,2)   as Primafacultativo,
		  dec(16,2)   as Primadiaria,
          dec(16,2)   as SumaAsegurada,
		  dec(16,2)   as Descuento,
		  dec(16,2)   as Recargo,
		  dec(16,2)   as Comision,
		  dec(9,6)    as Factor;

	DEFINE _no_poliza 			char(10);
	DEFINE _no_endoso           char(5);
	DEFINE _suma_asegurada		dec(16,2);
	DEFINE _deducible			varchar(50);
	DEFINE _limite_1			dec(16,2);
	DEFINE _limite_2			dec(16,2);
	DEFINE _prima_neta_cob,_prima_anual,_recargo,_descuento,_comision  dec(16,2);
	DEFINE _prima_ced,_prima_ret,_prima_fac,_prima_dia_cob             dec(16,2);
	DEFINE _factor,_tarifa,_porc_prima      dec(9,6);
	DEFINE _porc_comis_agt      dec(5,2);
    DEFINE _fecha_emision   	date;
	DEFINE _cod_cobertura		char(5);
	DEFINE _cod_cober_reas      char(3);
    DEFINE _cant_dias           integer;
	DEFINE _vigencia_final,_vigencia_inic date;
           
SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi09.trc";	
 -- trace on;

FOREACH
	select mae.no_poliza,
		   mae.no_endoso,
	       cob.cod_cobertura,
	       mae.fecha_emision,
		   mae.vigencia_inic,
		   mae.vigencia_final,
		   cob.tarifa,
		   cob.deducible, 
		   cob.limite_1, 
		   cob.limite_2, 
		   cob.prima_anual,
		   cob.prima_neta,
		   cob.limite_1,
		   cob.descuento,
		   cob.recargo,
		   cob.factor_vigencia,
		   rcob.cod_cober_reas,
		   mae.vigencia_final - mae.vigencia_inic
	  into _no_poliza,
		   _no_endoso,
		   _cod_cobertura,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final,
		   _tarifa,
		   _deducible,
		   _limite_1,
		   _limite_2,
		   _prima_anual,
		   _prima_neta_cob,
		   _suma_asegurada,
		   _descuento,
		   _recargo,
		   _factor,
		   _cod_cober_reas,
		   _cant_dias
	  from endedmae mae
 	 inner join endeduni u 
	         on (mae.no_poliza = u.no_poliza and mae.no_endoso = u.no_endoso)
	 inner join endedcob cob 
	         on (cob.no_poliza = u.no_poliza and cob.no_endoso = u.no_endoso and cob.no_unidad = u.no_unidad)
	 inner join prdcober rcob 
	         on (cob.cod_cobertura = rcob.cod_cobertura)
	 where mae.actualizado = 1 
	   and mae.fecha_emision >= a_fecha1 and mae.fecha_emision <= a_fecha2
	 order by no_poliza,no_endoso

    --Calculo de prima retenida
	select sum(e.porc_partic_prima)
      into _porc_prima
	  from emifacon e, reacomae r
	 where e.cod_contrato   = r.cod_contrato
	   and e.no_poliza      = _no_poliza
	   and e.no_endoso      = _no_endoso
	   and e.cod_cober_reas = _cod_cober_reas
	   and r.tipo_contrato in(1);
	   
	if _porc_prima is null then
		let _porc_prima = 0;
	end if
    let _prima_ret = 0.00;
	let _prima_ret = _prima_neta_cob * _porc_prima /100;
    --**************************
    --Calculo de prima cedida
	select sum(e.porc_partic_prima)
      into _porc_prima
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = _no_poliza
	   and e.no_endoso = _no_endoso
	   and e.cod_cober_reas = _cod_cober_reas
	   and r.tipo_contrato not in(1,3);
	   
	if _porc_prima is null then
		let _porc_prima = 0;
	end if
    let _prima_ced = 0.00;
	let _prima_ced = _prima_neta_cob * _porc_prima /100;
	--****************************************************
	--Calculo de prima facultativo
	select sum(e.porc_partic_prima)
      into _porc_prima
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = _no_poliza
	   and e.no_endoso = _no_endoso
	   and e.cod_cober_reas = _cod_cober_reas
	   and r.tipo_contrato in(3);
	   
	if _porc_prima is null then
		let _porc_prima = 0;
	end if
    let _prima_fac = 0.00;
	let _prima_fac = _prima_neta_cob * _porc_prima /100;
	--****************************************************
	--Calculo de prima diaria
	let _prima_dia_cob = 0;
	let _prima_dia_cob = _prima_neta_cob / _cant_dias;
	--****************************************************
	--Calculo de comision de corredor
	let _comision = 0.00;
	foreach
		select porc_comis_agt
		  into _porc_comis_agt
		  from endmoage
		 where no_poliza = _no_poliza
           and no_endoso = _no_endoso

		exit foreach;
	end foreach
	if _porc_comis_agt is null then
		let _porc_comis_agt = 0; 
    end if	
	let _comision = _prima_neta_cob * _prima_neta_cob /100;
	--****************************************************
	RETURN _cod_cobertura,
		   _fecha_emision,
		   _vigencia_inic,
		   _vigencia_final,
		   _tarifa,
		   _deducible,
		   _limite_1,
		   _limite_2,
		   _prima_anual,
		   0,
		   _prima_neta_cob,
		   _prima_ced,
		   _prima_ret,
		   _prima_fac,
		   _prima_dia_cob,
		   _suma_asegurada,
		   _descuento,
		   _recargo,
		   _comision,
		   _factor
		   WITH RESUME;		      
END FOREACH;
END PROCEDURE	  