-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasPatrimoniales 
-- Creado    : 11/05/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_eco04;
CREATE PROCEDURE sp_eco04(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING  char(5) as IdItem,
		   char(10) as IdPoliza,
		   char(5) as NroCertificado,
		   date as FechaAlta,
		   varchar(50) as NombreUbicacion,
		   varchar(50) as AcreedorHipotecario,
		   varchar(50) as Observaciones,
		   dec(16,2) as SumaAsegurada,
		   dec(16,2) as PrimaBruta,
		   dec(5,2) as PorcImpuesto,
		   dec(16,2) as Impuesto,
		   dec(16,2) as PrimaNeta,
		   char(3) as IdCompania,
		   char(5) as IdEndoso,
		   datetime hour to second as FechaCreacion,
		   char(10) as CodCorredor,	
		   integer as IdTipoInteres,
		   varchar(50) as CodRamo,
		   varchar(50) as CodPlan,		   
		   varchar(50) as RevPlan,
		   dec(16,2) as PrimaBrutaConDecRec,
		   dec(16,2) as Recargo,
		   dec(16,2) as PrimaSinRecaDcto,		
		   dec(16,2) as Descuento;
		   		   
  
DEFINE _no_poliza           char(10);
DEFINE _cod_agente          char(5);
DEFINE _no_endoso           char(5);
DEFINE _no_unidad           char(5);
DEFINE _suma_asegurada      dec(16,2);
DEFINE _factor_impuesto     dec(8,2);
DEFINE _color               varchar(50);
DEFINE _recargo             dec(16,2);
DEFINE _prima_neta          dec(16,2);
DEFINE _impuesto            dec(16,2);
DEFINE _descuento           dec(16,2);
DEFINE _prima_bruta         dec(16,2);
DEFINE _cod_producto        char(5);
DEFINE _producto 			varchar(50);
DEFINE _referencia     		varchar(50);
DEFINE _cod_acreedor        char(3);
DEFINE _acreedor            varchar(50);
DEFINE _fecha_emision       date;
DEFINE _cod_ramo            char(3);
DEFINE _no_endoso2          char(5);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

FOREACH
	select a.no_poliza,
		   case a.no_endoso when "00000" then null else a.no_endoso end IdEndoso,
		   a.no_endoso,
		   a.fecha_emision,
		   emi.cod_ramo,
		   u.no_unidad,
		   u.suma_asegurada,
		   u.prima,
		   u.impuesto,
		   u.descuento,
		   u.prima_bruta,
		   u.recargo,
		   u.cod_producto,
		   pr.nombre,
		   cor.cod_agente,
		   man.referencia
	  into _no_poliza,
		   _no_endoso,
		   _no_endoso2,
		   _fecha_emision,
		   _cod_ramo,
		   _no_unidad,
		   _suma_asegurada,
		   _prima_bruta,
		   _impuesto,
		   _descuento,
		   _prima_neta,
		   _recargo,
		   _cod_producto,
		   _producto,
		   _cod_agente,
		   _referencia
	  from endedmae a 
	 inner join emipomae emi on (emi.no_poliza = a.no_poliza and a.actualizado = 1 and a.fecha_emision >= a_fecha1 and a.fecha_emision <= a_fecha2)
	        and emi.cod_tipoprod <> '002'  
	 inner join prdramo ram
	         on ram.cod_ramo = emi.cod_ramo
			and ram.cod_area = 0
	 inner join emipoagt cor
			 on cor.no_poliza = emi.no_poliza
	 inner join agtagent pro
			 on pro.cod_agente = cor.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join endeduni u on (a.no_poliza = u.no_poliza and a.no_endoso = u.no_endoso)
	 inner join prdprod pr on (u.cod_producto = pr.cod_producto) 
	  left join emiman05 man on (man.cod_manzana = u.cod_manzana)
--	 where a.no_documento in ('0123-02239-01','0223-00687-01','0224-00964-09') and a.no_endoso = '00000'
	 
    let _cod_acreedor = null; 
    let _acreedor = null; 
	
	FOREACH
		select cod_acreedor
		  into _cod_acreedor
		  from endedacr
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso2
		   and no_unidad = _no_unidad
		   
		exit foreach;
	END FOREACH
	
	if _cod_acreedor is not null and trim(_cod_acreedor) <> "" then 				   
		select nombre
		  into _acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;
	end if

	select sum(a.factor_impuesto)
	  into _factor_impuesto
	  from prdimpue a, endedimp b
	 where a.cod_impuesto = b.cod_impuesto
	   and b.no_poliza = _no_poliza
	   and b.no_endoso = _no_endoso2;

	if _factor_impuesto is null then
		let _factor_impuesto = 0;
	end if

	RETURN _no_unidad,
		   _no_poliza,
		   _no_unidad,
		   today,
		   _referencia,
		   _acreedor,
		   null,
		   _suma_asegurada,
		   _prima_bruta,
		   _factor_impuesto,
		   _impuesto,
		   _prima_neta,
		   4,
		   _no_endoso,
		   _fecha_emision,
	       _cod_agente,
		   null,
		   _cod_ramo,
		   _cod_producto,
		   _producto,
		   null,
		   _recargo,
		   null,
		   _descuento
		   WITH RESUME;		      
END FOREACH
END PROCEDURE	  