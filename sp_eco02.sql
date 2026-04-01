-- Eco Integracion
-- Genera Información para la tabla Tbl_Polizas 
-- Creado    : 26/04/2021 - Autor: Amado Perez

DROP PROCEDURE sp_eco02;
CREATE PROCEDURE sp_eco02(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING  char(10) as IdPoliza,
		   smallint as IdCompania, --4
		   char(10) as IdContratante,
		   varchar(100) as Nombres,
		   varchar(100) as Apellidos,
		   varchar(100) as RazonSocial,
		   smallint as IdTipoPersona,
		   varchar(30) as Identificacion,
		   varchar(50) as Email,
		   varchar(10) as Telefono,
		   varchar(101) as Direccion,
		   char(20) as NroPoliza,
		   date as FechaFacturacion,
		   date as FechaDesde,
		   date as FechaHasta,
		   varchar(10) as CodRamo,
           varchar(50) as Ramo,
		   char(3) as CodFormaPago,
		   varchar(50) as FormaPago,
           char(3) as CodFrecuenciaPago,
		   varchar(50) as FrecuenciaPago,
		   dec(5,2) as PorcComision,
		   char(5) as CodigoCorredor,
		   dec(16,2) as PrimaBruta,
		   dec(16,2) as PorcImpuesto,
		   dec(16,2) as Impuesto,
		   dec(16,2) as Descuento,
		   dec(16,2) as PrimaNeta,
           char(1) as IdTipoPoliza, --null
           smallint as CantidadLetras,
		   char(1) as DocPoliza,
		   char(1) as LinkDescargaDoc,
		   date as FechaCreacion,
		   varchar(50) as Estatus,
		   varchar(50) as Pais,
		   char(1) as Provincia,
		   char(1) as Sexo,
		   char(5) as IdEndoso,
		   varchar(50) as TipoEndoso,
		   char(3) as CodTipoEndoso,
		   char(10) as NroFactura,
		   varchar(50) as CodPlan,
		   char(1) as RevPlan,
		   date as FechaNacimiento,
		   char(8) as Agente,
		   dec(16,2) as PrimaBrutaConDecRec,
		   dec(16,2) as Recargo,
		   dec(16,2) as PrimaSinRecaDcto;
           
	DEFINE _no_poliza 			char(10);
    DEFINE _cod_cliente 		char(10);
    DEFINE _nombres    			varchar(100);
    DEFINE _apellidos       	varchar(100);
    DEFINE _razon_social    	varchar(100);      		
    DEFINE _IdTipoPersona   	smallint;
    DEFINE _cedula				varchar(30);
    DEFINE _e_mail 				varchar(50);
    DEFINE _telefono1       	varchar(10);
    DEFINE _direccion       	varchar(101);
    DEFINE _no_documento    	char(20);
    DEFINE _fecha_emision   	date;
    DEFINE _vigencia_inic_pol	date;
	DEFINE _vigencia_final_pol	date;
	DEFINE _cod_ramo 			varchar(10);
	DEFINE _ramo         		varchar(50);
	DEFINE _cod_formapag        char(3);
	DEFINE _FormaPago			varchar(50);
	DEFINE _cod_perpago			char(3);
	DEFINE _FrecuenciaPago		varchar(50);
	DEFINE _PorcComision        dec(5,2);
	DEFINE _CodigoCorredor      char(5);
	DEFINE _prima_bruta         dec(16,2);
	DEFINE _PorcImpuesto		dec(16,2);
	DEFINE _impuesto			dec(16,2);
	DEFINE _descuento			dec(16,2);
	DEFINE _prima_neta			dec(16,2);
	DEFINE _no_pagos			smallint;
	DEFINE _FechaCreacion		date;
	DEFINE _Estatus             varchar(50);
	DEFINE _pais				varchar(50);
	DEFINE _sexo         		char(1);
	DEFINE _IdEndoso			char(5);
	DEFINE _TipoEndoso			varchar(50);
	DEFINE _cod_endomov			char(3);
	DEFINE _NroFactura			char(10);
	DEFINE _CodPlan				varchar(50);
	DEFINE _fecha_aniversario	date;
	DEFINE _user_added			char(8);
	DEFINE _recargo				dec(16,2);
	DEFINE _cod_agente_i        char(5);
	DEFINE _no_poliza_i         char(10);
	DEFINE _nueva_renov         char(1);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;

FOREACH
	select distinct
		   mae.no_poliza
		   ,con.cod_cliente
		   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
		   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
		   ,case con.tipo_persona when "N" then "" else con.nombre_razon end razon_social
		   ,case con.tipo_persona when "N" then 1 when "J" then 2 else 3 end IdTipoPersona
		   ,con.cedula
		   ,con.e_mail
		   ,con.telefono1
		   ,trim(con.direccion_1) || trim(con.direccion_2) as direccion
		   ,mae.no_documento
		   ,mae.fecha_emision
		   ,mae.vigencia_inic_pol
		   ,mae.vigencia_final_pol
		   ,trim(emi.cod_ramo) || "-" || trim(emi.cod_subramo) as cod_ramo
		   ,trim(ram.nombre) || "-" || trim(sub.nombre) as ramo
		   ,emi.cod_formapag
		   ,pag.nombre as FormaPago
		   ,emi.cod_perpago
		   ,per.nombre as FrecuenciaPago
		   ,agt.porc_comis_agt as PorcComision
		   ,agt.cod_agente as CodigoCorredor
		   ,mae.prima
		   ,case mae.prima_neta when 0 then 0 else round(abs(mae.impuesto/mae.prima_neta) *100,0) end as PorcImpuesto
		   ,mae.impuesto
		   ,mae.descuento
		   ,mae.prima_bruta
		   ,emi.no_pagos
		   ,mae.fecha_emision as FechaCreacion
		   ,Case emi.estatus_poliza when 1 then "VIGENTE" when 2 then "CANCELADA" when 3 then "VENCIDA" when 4 then "ANULADA" end Estatus
		   ,con.nacionalidad as pais
		   ,con.sexo
		   ,case mae.no_endoso when "00000" then null else mae.no_endoso end IdEndoso
		   ,mov.nombre as TipoEndoso
		   ,mae.cod_endomov
		   ,mae.no_factura as NroFactura
		   ,sub.nombre as CodPlan
		   ,con.fecha_aniversario
		   ,mae.user_added as agente
		   ,mae.recargo
		   ,emi.nueva_renov
	  into _no_poliza,
		   _cod_cliente,
		   _nombres,
		   _apellidos,
		   _razon_social,      		
		   _IdTipoPersona,
		   _cedula,
		   _e_mail,
		   _telefono1,
		   _direccion,
		   _no_documento,
		   _fecha_emision,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _cod_ramo,
		   _ramo,
		   _cod_formapag,
		   _FormaPago,
		   _cod_perpago,
		   _FrecuenciaPago,
		   _PorcComision,
		   _CodigoCorredor,
		   _prima_bruta,
		   _PorcImpuesto,
		   _impuesto,
		   _descuento,
		   _prima_neta,
		   _no_pagos,
		   _FechaCreacion,
		   _Estatus,
		   _pais,
		   _sexo,
		   _IdEndoso,
		   _TipoEndoso,
		   _cod_endomov,
		   _NroFactura,
		   _CodPlan,
		   _fecha_aniversario,
		   _user_added,
		   _recargo,
		   _nueva_renov
	  from endedmae mae
	 inner join emipomae emi
			 on emi.no_poliza = mae.no_poliza
			and mae.fecha_emision between a_fecha1 and a_fecha2
			and emi.cod_tipoprod <> '002'
	 inner join emipoagt cor
			 on cor.no_poliza = emi.no_poliza
	 inner join agtagent pro
			 on pro.cod_agente = cor.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join cliclien con
			 on con.cod_cliente = emi.cod_contratante
	 inner join prdramo ram
			 on ram.cod_ramo = emi.cod_ramo
	 inner join cobforpa pag
			 on pag.cod_formapag = emi.cod_formapag
	 inner join cobperpa per
			 on per.cod_perpago = emi.cod_perpago
	 inner join endtimov mov
			 on mov.cod_endomov = mae.cod_endomov
	 inner join prdsubra sub
			 on sub.cod_ramo = emi.cod_ramo
			and sub.cod_subramo = emi.cod_subramo
	  left join endmoage agt
			 on agt.no_poliza = mae.no_poliza
			and agt.no_endoso = mae.no_endoso				
	  where mae.actualizado = 1
	    --and mae.no_documento in ('0123-02239-01','0223-00687-01','0224-00964-09') and mae.no_endoso = '00000'
	  
	if _IdEndoso is null then
		let _TipoEndoso = null;
		let _cod_endomov = null;
		let _NroFactura = null;
		if _nueva_renov = "N" then
			let _Estatus = "NUEVA";
		else
			let _Estatus = "RENOVACION";
		end if
    else
		let _Estatus = "ENDOSO";
	end if

	if _cedula is null then
		let _cedula = '';
	end if
	
	if _no_documento in ('0401-00217-01','0402-00135-01') then
		continue foreach;
	end if

	RETURN _no_poliza,
		   4,
		   _cod_cliente,
		   _nombres,
		   _apellidos,
		   _razon_social,      		
		   _IdTipoPersona,
		   _cedula,
		   _e_mail,
		   _telefono1,
		   _direccion,
		   _no_documento,
		   _fecha_emision,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _cod_ramo,
		   _ramo,
		   _cod_formapag,
		   _FormaPago,
		   _cod_perpago,
		   _FrecuenciaPago,
		   _PorcComision,
		   _CodigoCorredor,
		   _prima_bruta,
		   _PorcImpuesto,
		   _impuesto,
		   _descuento,
		   _prima_neta,
		   '',
		   _no_pagos,
		   null,
		   null,
		   _FechaCreacion,
		   _Estatus,
		   _pais,
		   null,
		   _sexo,
		   _IdEndoso,
		   _TipoEndoso,
		   _cod_endomov,
		   _NroFactura,
		   _CodPlan,
		   null,
		   _fecha_aniversario,
		   _user_added,
		   0,
		   _recargo,
		   0
		   WITH RESUME;		      
END FOREACH
END PROCEDURE	  