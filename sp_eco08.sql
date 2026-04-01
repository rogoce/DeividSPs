-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasPagos 
-- Creado    : 10/06/2021 - Autor: Amado Perez
-- execute procedure sp_eco08('01/01/2021',today,'*')
 

DROP PROCEDURE sp_eco08;
CREATE PROCEDURE sp_eco08(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING  varchar(50) as IdPago,
		   char(10) as IdPoliza,
		   char(10) as IdContratante,
		   varchar(100) as Nombre,
           varchar(100) as Apellido,
		   varchar(100) as RazonSocial,		   
		   varchar(30) as Identificacion,		
		   smallint as IdTipoPersona,
		   varchar(50) as NroPoliza,
		   varchar(10) as CodRamo,
           varchar(50) as Ramo,
		   date as FechaDesde,
		   date as FechaHasta,
		   smallint as IdCompania, --4
		   char(10) as CodCorredor,	
		   varchar(50) as NroRecibo,
		   dec(16,2) as Pagado,
	       varchar(50) as IsDirecto,
		   dec(16,2) as Comision,
		   dec(16,2) as PorcComision,
		   date as FechaPago,
		   date as FechaRegistro,
		   varchar(50) as Token,
		   char(3) as CodFormapag,
		   varchar(50) as FormaPago,
		   varchar(15) as RemesaRenglon;		   
		   
  
DEFINE _no_remesa				char(10);
DEFINE _no_poliza				char(10);
DEFINE _cod_cliente			char(10);
DEFINE _cod_chequera			char(3);
DEFINE _cod_formapag			char(3);
DEFINE _nombres				varchar(100);
DEFINE _apellidos				varchar(100);
DEFINE _razon_social			varchar(100);      		
DEFINE _nom_formapag			varchar(50);
DEFINE _cedula				varchar(30);
DEFINE _renglon				integer;
DEFINE _IdTipoPersona		smallint;
DEFINE _cnt_cobpaex			smallint;
DEFINE _IsDirecto				smallint;
DEFINE _no_documento			char(20);
DEFINE _remesa_renglon			varchar(15);
DEFINE _cod_ramo				varchar(10);
DEFINE _ramo					varchar(50);
DEFINE _vigencia_inic_pol	date;
DEFINE _vigencia_final_pol	date;
DEFINE _CodigoCorredor		char(5);
DEFINE _no_recibo				char(10);
DEFINE _monto					dec(16,2);
DEFINE _comision				dec(16,2);
DEFINE _porc_comis			dec(5,2);
DEFINE _fecha					date;


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_eco07.trc";	
--  trace on;

let _cod_formapag = '001';
let _nom_formapag = 'TEST';

FOREACH
	select mae.no_remesa
	       ,cob.cod_chequera
		   ,mae.renglon
	       ,mae.no_poliza
		   ,emi.cod_contratante
		   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
		   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
		   ,case con.tipo_persona when "N" then "" else con.nombre_razon end razon_social
		   ,con.cedula
		   ,case con.tipo_persona when "N" then 1 when "J" then 2 else 3 end IdTipoPersona
		   ,mae.doc_remesa
		   ,trim(emi.cod_ramo) || "-" || trim(emi.cod_subramo) as cod_ramo
		   ,trim(ram.nombre) || "-" || trim(sub.nombre) as ramo
		   ,emi.vigencia_inic
		   ,emi.vigencia_final
		   ,agt.cod_agente as CodigoCorredor
		   ,mae.no_recibo
		   ,mae.monto
		   ,mae.prima_neta * (porc_comis_agt/100)
		   ,agt.porc_comis_agt
		   ,cob.date_posteo
		   ,case mae.monto_descontado
		    when 0 then 1
			else 0
			end as IsDirecto
	  into _no_remesa,
	       _cod_chequera,
		   _renglon,	   
	       _no_poliza,	   
		   _cod_cliente,
	       _nombres,
		   _apellidos,
		   _razon_social,
		   _cedula,
		   _IdTipoPersona,
		   _no_documento,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _CodigoCorredor,
		   _no_recibo,
		   _monto,
		   _comision,
		   _porc_comis,
		   _fecha,
		   _IsDirecto
	  from cobremae cob
	 inner join cobredet mae
	          on mae.no_remesa = cob.no_remesa
			 and cob.actualizado = 1 
	 inner join cobreagt agt 
	         on agt.no_remesa = mae.no_remesa
			and agt.renglon = mae.renglon
	 inner join agtagent pro
			 on pro.cod_agente = agt.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	        and emi.cod_tipoprod <> '002'
	 inner join cliclien con on con.cod_cliente = emi.cod_contratante	   
	 inner join prdramo ram
			 on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub
			 on sub.cod_ramo = emi.cod_ramo
			and sub.cod_subramo = emi.cod_subramo
	where cob.date_posteo >= a_fecha1
	  and cob.date_posteo <= a_fecha2
	  and mae.tipo_mov in ('P','N')

	if _IsDirecto = 1 then
		select count(*)
		  into _cnt_cobpaex
		  from cobpaex0
		 where no_remesa_ancon = _no_remesa
		   and cod_agente = _CodigoCorredor;

		if _cnt_cobpaex is null then
			let _cnt_cobpaex = 0;
		end if
		
		if _cnt_cobpaex = 1 then
			let _IsDirecto = 0;
			let _cod_formapag = '007';
				let _nom_formapag = 'CORREDOR REMESA';
		else
			if _cod_chequera in ('029','031') then --TCR
				let _cod_formapag = '003';
				let _nom_formapag = 'TARJETA DE CREDITO';
			elif _cod_chequera in ('038','037','036') then	--TRANSFERENCIA BANCA EN LINEA
				let _cod_formapag = '004';
				let _nom_formapag = 'BANCA EN LINEA';
			elif _cod_chequera in ('030') then	--ACH
				let _cod_formapag = '005';
				let _nom_formapag = 'DESCUENTO ACH';
			elif _cod_chequera in ('039') then	--REY PAGO
				let _cod_formapag = '002';
				let _nom_formapag = 'REY PAGO';
			elif _cod_chequera in ('035') then	--WEB PAGO
				let _cod_formapag = '001';
				let _nom_formapag = 'WEB PAGO';
			else --ANCON
				let _cod_formapag = '006';
				let _nom_formapag = 'CAJA ANCON';
			end if
		end if
	end if
	
	let _remesa_renglon = trim(_no_remesa)|| "_" || _renglon;
	
	RETURN _no_remesa,
	       _no_poliza,	   
		   _cod_cliente,
	       _nombres,
		   _apellidos,
		   _razon_social,
		   _cedula,
		   _IdTipoPersona,
		   _no_documento,
		   _cod_ramo,
		   _ramo,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   4,
		   _CodigoCorredor,
		   _no_recibo,
		   _monto,
		   _IsDirecto, --IsDirecto
		   _comision,
		   _porc_comis,
		   _fecha,
		   today,
		   null, --Token
		   _cod_formapag,
		   _nom_formapag,
		   _remesa_renglon
		   WITH RESUME;		 
		   
END FOREACH
END PROCEDURE	  