-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasCoberturas 
-- Creado    : 28/04/2021 - Autor: Amado Perez

DROP PROCEDURE sp_eco03;
CREATE PROCEDURE sp_eco03(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING char(10) as IdPoliza,
          char(5) as IdItem,
          varchar(50) as Cobertura,	
          dec(16,2) as SumaAsegurada,
    	  varchar(50) as Deducible, 
          dec(16,2) as LimitePorPersona,
          dec(16,2) as LimitePorAccidente,	
          dec(16,2) as PrimaBruta,
          smallint as IdCompania,
          char(5) as IdEndoso,
          char(5) as NroCertificado,
          char(5) as CodProducto,
          char(3) as CodRamo,
          char(5) as CodCorredor,
          date as Fecha,
          date as FechaCreacion,
          char(5) as CodCobertura;

	DEFINE _no_poliza 			char(10);
	DEFINE _no_unidad           char(5);
	DEFINE _Cobertura			varchar(50);
	DEFINE _suma_asegurada		dec(16,2);
	DEFINE _deducible			varchar(50);
	DEFINE _limite_1			dec(16,2);
	DEFINE _limite_2			dec(16,2);
	DEFINE _prima_bruta         dec(16,2);
	DEFINE _IdEndoso			char(5);
	DEFINE _cod_producto        char(5);
	DEFINE _cod_ramo 			char(3);
	DEFINE _CodigoCorredor      char(5);
    DEFINE _fecha_emision   	date;
	DEFINE _cod_cobertura		char(5);
    DEFINE _cod_agente_i        char(10);
           

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;


FOREACH
	select mae.no_poliza
		  ,cob.no_unidad 
		  ,rcob.nombre 
		  ,u.suma_asegurada 
		  ,cob.deducible 
		  ,cob.limite_1 
		  ,cob.limite_2 
		  ,cob.prima 
		  ,case cob.no_endoso  when '00000' then null else cob.no_endoso end as IdEndoso
		  ,u.cod_producto 
		  ,emi.cod_ramo 
		  ,cor.cod_agente 
		  ,mae.fecha_emision 
		  ,cob.cod_cobertura
	  into _no_poliza,
		   _no_unidad,
		   _Cobertura,
		   _suma_asegurada,
		   _deducible,
		   _limite_1,
		   _limite_2,
		   _prima_bruta,
		   _IdEndoso,
		   _cod_producto,
		   _cod_ramo,
		   _CodigoCorredor,
		   _fecha_emision,
		   _cod_cobertura
	  from endedmae mae
	 inner join emipomae emi 
	         on (emi.no_poliza = mae.no_poliza and mae.actualizado = 1 and mae.fecha_emision >= a_fecha1 and mae.fecha_emision <= a_fecha2)
			 and emi.cod_tipoprod <> '002'
	 inner join emipoagt cor
			 on cor.no_poliza = emi.no_poliza
	 inner join agtagent pro
			 on pro.cod_agente = cor.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join endeduni u on (mae.no_poliza = u.no_poliza and mae.no_endoso = u.no_endoso)
	 inner join endedcob cob on (cob.no_poliza = u.no_poliza and cob.no_endoso = u.no_endoso and cob.no_unidad = u.no_unidad)
	 inner join prdcober rcob on (cob.cod_cobertura = rcob.cod_cobertura)
--	 where emi.no_documento in ('0123-02239-01','0223-00687-01','0224-00964-09') and mae.no_endoso = '00000'
	 
	 
	RETURN _no_poliza,
		   _no_unidad,
		   _Cobertura,
		   _suma_asegurada,
		   _deducible,
		   _limite_1,
		   _limite_2,
		   _prima_bruta,
		   4,
		   _IdEndoso,
		   _no_unidad,
		   _cod_producto,
		   _cod_ramo,
		   _CodigoCorredor,
		   _fecha_emision,
		   _fecha_emision,
		   _cod_cobertura
		   WITH RESUME;		      
END FOREACH;

END PROCEDURE	  