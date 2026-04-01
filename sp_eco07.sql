-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasComisiones 
-- Creado    : 07/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_eco07;
CREATE PROCEDURE sp_eco07(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING  char(10) as IdPoliza,
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
		   date as FechaPagoDesde,
		   date as FechaPagoHasta,
		   date as FechaPagoRecibo,
		   varchar(50) as NroRecibo,
		   varchar(50) as Referencia,
		   varchar(50) as Remesa,
		   dec(16,2) as MontoPrimaC,
		   dec(16,2) as VidaPrimerAno,
		   dec(16,2) as VidaSegundoRenovacion,
		   dec(16,2) as PorcComision,
		   dec(16,2) as MontoHonP,
		   dec(16,2) as VidaPrimeAnoH,
		   dec(16,2) as VidaRenovacionH,
		   dec(16,2) as Saldo,
		   date as FechaRegistro,
		   varchar(50) as Token;		   
  
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
DEFINE _fecha_desde         date;
DEFINE _fecha_hasta         date;
DEFINE _fecha               date;
DEFINE _no_recibo           char(10);
DEFINE _no_remesa           char(10);
DEFINE _porc_comis          dec(5,2);
DEFINE _comision            dec(16,2);
DEFINE _monto               dec(16,2);
DEFINE _saldo               dec(16,2);
DEFINE _fecha_genera        date;
DEFINE _monto_c             dec(16,2);
DEFINE _saldo_c             dec(16,2);
DEFINE _cnt                 int;
DEFINE _no_remesa_c         char(10);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_eco07.trc";	
--  trace on;

let _no_remesa = null;

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
		   ,emi.vigencia_inic
		   ,emi.vigencia_final
		   ,mae.cod_agente as CodigoCorredor
		   ,mae.fecha_desde
		   ,mae.fecha_hasta
		   ,mae.fecha
		   ,mae.no_recibo
		   ,mae.porc_comis
		   ,mae.comision
		   ,mae.fecha_genera
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
		   _fecha_desde,
		   _fecha_hasta,
		   _fecha,
		   _no_recibo,
		   _porc_comis,
		   _comision,
		   _fecha_genera
	  from chqcomis mae
	 inner join agtagent pro
			 on pro.cod_agente = mae.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
			and mae.no_requis is not null
	 inner join chqchmae chq on chq.no_requis = mae.no_requis and chq.anulado = 0 and chq.pagado = 1
	  left join emipomae emi on emi.no_poliza = mae.no_poliza
	        and emi.cod_tipoprod <> '002'
	 inner join cliclien con on con.cod_cliente = emi.cod_contratante	   
	 inner join prdramo ram
			 on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub
			 on sub.cod_ramo = emi.cod_ramo
			and sub.cod_subramo = emi.cod_subramo
	where mae.fecha_genera >= a_fecha1
	  and mae.fecha_genera <= a_fecha2
	  and mae.comision <> 0
	  
	let _cnt = 0;  
	let _monto = 0;
	let _saldo = 0;
	let _monto_c = 0;
	let _saldo_c = 0;
	let _no_remesa = null;
	let _no_remesa_c = null;
	 
    FOREACH	 
		select a.no_remesa,
		       a.monto,
			   a.saldo
		  into _no_remesa_c,
		       _monto_c,
			   _saldo_c
		  from cobredet a
		 inner join cobreagt b
		    on b.no_remesa = a.no_remesa
           and b.renglon = a.renglon
         where b.cod_agente = _CodigoCorredor
           and a.no_poliza = _no_poliza
           and a.no_recibo = _no_recibo
           and a.fecha = _fecha
		 order by a.monto desc
		 
		if _cnt = 0 then
			let _no_remesa = _no_remesa_c;
		end if
		
		let _monto = _monto + _monto_c;
		let _saldo = _saldo + _saldo_c;
		let _cnt = _cnt + 1;         
	END FOREACH	
	  
		   
	RETURN _no_poliza,	   
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
		   _fecha_desde, 
		   _fecha_hasta,
		   _fecha,
		   _no_recibo,
		   null,
		   _no_remesa,
		   _monto,
		   null,
		   null,
		   _porc_comis,
		   _comision,
		   null,
		   null,
		   _saldo,
		   _fecha_genera,
		   null WITH RESUME;		 
		   
END FOREACH
END PROCEDURE	  