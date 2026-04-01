-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasAnalisisMorosidad 
-- Creado    : 07/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_eco06;
CREATE PROCEDURE sp_eco06(a_agente char(10) default '*') 
RETURNING  integer as IdSaldo,
 		   char(10) as IdPoliza,
		   char(10) as IdContratante,
		   varchar(100) as Nombre,
           varchar(100) as Apellido,
		   varchar(100) as RazonSocial,
		   varchar(30) as Identificacion,
		   char(20) as NroPoliza,
		   varchar(10) as CodRamo,
           varchar(50) as Ramo,
		   date as FechaDesde,
		   date as FechaHasta,
		   smallint as IdCompania, --4
		   char(10) as CodCorredor,	
		   dec(16,2) as PrimaSuscrita,
		   dec(16,2) as Cobrado,
		   dec(16,2) as Saldo,
		   dec(16,2) as SaldoCorriente,
		   dec(16,2) as SaldoA30Dias,
		   dec(16,2) as SaldoA60Dias,
		   dec(16,2) as SaldoA90Dias,
		   dec(16,2) as SaldoA120Dias,
		   dec(16,2) as SaldoA150Dias,
		   dec(16,2) as SaldoA180Dias,
		   dec(16,2) as SaldoMas180Dias,
		   date as FechaActualizacion,
		   varchar(50) as Token,
		   dec(16,2) as SaldoNoVencido;
		   
  
DEFINE _no_poliza           char(10);
DEFINE _cod_cliente 		char(10);
DEFINE _nombres    			varchar(100);
DEFINE _apellidos       	varchar(100);
DEFINE _razon_social    	varchar(100);      		
DEFINE _cedula				varchar(30);
DEFINE _no_documento    	char(20);
DEFINE _cod_ramo 			varchar(10);
DEFINE _ramo         		varchar(50);
DEFINE _vigencia_inic_pol	date;
DEFINE _vigencia_final_pol	date;
DEFINE _CodigoCorredor      char(5);
DEFINE _prima_suscrita		dec(16,2);
DEFINE _corriente				dec(16,2);
DEFINE _cobrado             dec(16,2);
DEFINE _saldo               dec(16,2);
DEFINE _monto_30            dec(16,2);
DEFINE _monto_60            dec(16,2);
DEFINE _monto_90            dec(16,2);
DEFINE _monto_120           dec(16,2);
DEFINE _monto_150           dec(16,2);
DEFINE _monto_180           dec(16,2);
DEFINE _por_vencer          dec(16,2);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

FOREACH
	select mae.no_poliza
		   ,emi.cod_contratante
		   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
		   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
		   ,case con.tipo_persona when "N" then "" else con.nombre_razon end razon_social
		   ,con.cedula
		   ,mae.no_documento
		   ,trim(emi.cod_ramo) || "-" || trim(emi.cod_subramo) as cod_ramo
		   ,trim(ram.nombre) || "-" || trim(sub.nombre) as ramo
		   ,mae.vigencia_inic
		   ,mae.vigencia_fin
		   ,cor.cod_agente as CodigoCorredor
		   ,mae.prima_bruta
		   ,mae.prima_bruta - mae.saldo as Cobrado
		   ,mae.saldo
		   ,mae.corriente
		   ,mae.monto_30
		   ,mae.monto_60
		   ,mae.monto_90
		   ,mae.monto_120
		   ,mae.monto_150
		   ,mae.monto_180
		   ,mae.por_vencer
	  into _no_poliza,	   
		   _cod_cliente,
	       _nombres,
		   _apellidos,
		   _razon_social,
		   _cedula,
		   _no_documento,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _CodigoCorredor,
		   _prima_suscrita,
		   _cobrado,
		   _saldo,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _por_vencer
	  from emipoliza mae
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	        and emi.cod_tipoprod <> '002'
	 inner join emipoagt cor
			 on cor.no_poliza = emi.no_poliza
	 inner join agtagent pro
			 on pro.cod_agente = cor.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join cliclien con on con.cod_cliente = emi.cod_contratante	   
	 inner join prdramo ram
			 on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub
			 on sub.cod_ramo = emi.cod_ramo
			and sub.cod_subramo = emi.cod_subramo
	where (mae.cod_status = 1 or mae.saldo <> 0)
	  and mae.cod_ramo is not null
	  and mae.vigencia_fin is not null
		   

	RETURN null,
		   _no_poliza,	   
		   _cod_cliente,
	       _nombres,
		   _apellidos,
		   _razon_social,
		   _cedula,
		   _no_documento,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   4,
		   _CodigoCorredor,
		   _prima_suscrita, 
		   _cobrado,
		   _saldo,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   null,
		   current - 1 units day,
		   null,
		   _por_vencer WITH RESUME;		 
		   
END FOREACH
END PROCEDURE	  