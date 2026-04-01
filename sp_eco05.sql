-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasPersonas 
-- Creado    : 26/04/2021 - Autor: Amado Perez

DROP PROCEDURE sp_eco05;
CREATE PROCEDURE sp_eco05(a_fecha1 date, a_fecha2 date, a_agente char(10) default '*') 
RETURNING  integer as IdItem,
           char(10) as IdPoliza,
		   char(5) as NroCertificado,
		   date as FechaNacimiento,
		   date as FechaAlta,
		   varchar(100) as Nombre,
		   varchar(100) as Apellido,
           dec(16,2) as SumaAsegurada,
		   varchar(100) as DeducibleInterno,
           varchar(100) as DeducibleExterno,
		   dec(16,2) as Copago,
		   dec(16,2) as PrimaBruta,
		   dec(16,2) as PorcImpuesto,
		   dec(16,2) as Impuesto,
		   dec(16,2) as PrimaNeta,
		   smallint as IdCompania, --4
		   char(5) as IdEndoso,
		   integer as IdTipoObjeto,		
           dec(16,2) as PorcentajeParticipacion,	
           integer as IdItemPadre,		   
		   char(10) as CodCorredor,	
           varchar(50) as Parentesco,
		   varchar(50) as CodPlan,
		   varchar(50) as RevPlan,
		   varchar(50) as Email,
		   varchar(101) as Direccion,
		   varchar(50) as EstadoCivil,
		   varchar(50) as Celular,
		   varchar(50) as TelOficina,
		   varchar(50) as TelCasa,
		   varchar(50) as Pais,
		   varchar(30) as Identificacion,
		   varchar(50) as LugarNacimiento,
		   varchar(50) as Ocupacion,
		   char(1) as Sexo,
		   date as FechaCreacion,
		   dec(16,2) as PrimaBrutaConDecRec,
		   dec(16,2) as Recargo,
		   dec(16,2) as PrimaSinRecaDcto,
		   dec(16,2) as Descuento;

           
	DEFINE _no_poliza 			char(10);
    DEFINE _cod_cliente 		integer;
    DEFINE _nombres    			varchar(100);
    DEFINE _apellidos       	varchar(100);
    DEFINE _razon_social    	varchar(100);      		
    DEFINE _IdTipoPersona   	smallint;
    DEFINE _cedula				varchar(30);
    DEFINE _e_mail 				varchar(50);
    DEFINE _telefono1       	varchar(50);
    DEFINE _direccion       	varchar(101);
    DEFINE _no_documento    	char(20);
    DEFINE _fecha_emision   	date;
    DEFINE _vigencia_inic_pol	date;
	DEFINE _vigencia_final_pol	date;
	DEFINE _cod_ramo 			char(3);
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
	DEFINE _no_unidad           char(5);
	DEFINE _suma_asegurada      dec(16,2);
	DEFINE _cod_producto        char(5);
	DEFINE _producto            varchar(50);
	DEFINE _celular             varchar(50);
	DEFINE _telefono2           varchar(50);
	DEFINE _ocupacion			varchar(50);
	DEFINE _date_added          date;
	DEFINE _parentesco          varchar(50);
	DEFINE _cod_cliente2        char(10);
	DEFINE _porc_partic_ben     dec(5,2);
	DEFINE _prima_depen         dec(16,2);
	DEFINE _prima_aseg          dec(16,2);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;

FOREACH
	select distinct
		   con.cod_cliente
		   ,mae.no_poliza
		   ,u.no_unidad
		   ,con.fecha_aniversario
		   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
		   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
		   ,u.suma_asegurada
		   ,mae.prima
		   ,case mae.prima_neta when 0 then 0 else round(abs(mae.impuesto/mae.prima_neta) *100,0) end as PorcImpuesto
		   ,mae.impuesto
		   ,mae.prima_bruta
		   ,case mae.no_endoso when "00000" then null else mae.no_endoso end IdEndoso
		   ,agt.cod_agente as CodigoCorredor
		   ,u.cod_producto
		   ,prod.nombre
		   ,con.e_mail
		   ,trim(con.direccion_1) || trim(con.direccion_2) as direccion
		   ,con.celular
		   ,con.telefono2
		   ,con.telefono1
		   ,con.nacionalidad as pais
		   ,con.cedula
		   ,ocu.nombre
		   ,con.sexo
		   ,con.date_added
		   ,u.recargo
		   ,u.descuento
	  into _cod_cliente,
		   _no_poliza,
	       _no_unidad,
		   _fecha_aniversario,
		   _nombres,
		   _apellidos,
		   _suma_asegurada,
		   _prima_bruta,
		   _PorcImpuesto,
		   _impuesto,
		   _prima_neta,
		   _IdEndoso,
		   _CodigoCorredor,
		   _cod_producto,
		   _producto,
		   _e_mail,
		   _direccion,
		   _celular,
		   _telefono2,
		   _telefono1,
		   _pais,
		   _cedula,
		   _ocupacion,
		   _sexo,
		   _date_added,
		   _recargo,
		   _descuento
	  from endedmae mae
	 inner join emipomae emi
			 on emi.no_poliza = mae.no_poliza
			and mae.fecha_emision between a_fecha1 and a_fecha2
			and emi.cod_tipoprod <> '002'
	 inner join endeduni u
             on u.no_poliza = mae.no_poliza
            and u.no_endoso = mae.no_endoso			 
	 inner join emipoagt cor
			 on cor.no_poliza = emi.no_poliza
	 inner join agtagent pro
			 on pro.cod_agente = cor.cod_agente
			and pro.eco_integra = 1
			and pro.cod_agente matches a_agente
	 inner join cliclien con
			 on con.cod_cliente = u.cod_cliente
	 inner join prdramo ram
			 on ram.cod_ramo = emi.cod_ramo
			and ram.cod_area = 2
	 inner join cobforpa pag
			 on pag.cod_formapag = emi.cod_formapag
	 inner join cobperpa per
			 on per.cod_perpago = emi.cod_perpago
	 inner join endtimov mov
			 on mov.cod_endomov = mae.cod_endomov
	 inner join prdsubra sub
			 on sub.cod_ramo = emi.cod_ramo
			and sub.cod_subramo = emi.cod_subramo
	 inner join prdprod prod
	         on prod.cod_producto = u.cod_producto
	 left  join cliocupa ocu
             on ocu.cod_ocupacion = con.cod_ocupacion	 
	  left join endmoage agt
			 on agt.no_poliza = mae.no_poliza
			and agt.no_endoso = mae.no_endoso				
	  where mae.actualizado = 1
	  
	if _cedula is null then
		let _cedula = '';
	end if

    let _prima_depen = 0.00;
	
	select sum(prima)
	  into _prima_depen
	  from emidepen
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad 
	   and activo = 1;
	   
	if _prima_depen is null then
		let _prima_depen = 0;
	end if
	
	let _prima_bruta = _prima_bruta - _prima_depen;
	let _impuesto = _prima_bruta * _PorcImpuesto / 100;
	let _prima_neta = _prima_bruta + _impuesto;

	RETURN _cod_cliente,
		   _no_poliza,
	       _no_unidad,
		   _fecha_aniversario,
		   null,
		   _nombres,
		   _apellidos,
		   _suma_asegurada,
		   null,
		   null,
		   null,
		   _prima_bruta,
		   _PorcImpuesto,
		   _impuesto,
		   _prima_neta,
		   4,
		   _IdEndoso,
		   1,
		   null,
		   null,
		   _CodigoCorredor,
		   null,
		   _cod_producto,
		   _producto,
		   _e_mail,
		   _direccion,
		   null,		   
		   _celular,
		   _telefono2,
		   _telefono1,
		   _pais,
		   _cedula,
		   null,
		   _ocupacion,
		   _sexo,
		   _date_added,
		   null,
		   _recargo,
		   null,
		   _descuento
           WITH RESUME;	

    -- Dependientes		   
	FOREACH
		select distinct
			   con.cod_cliente
			   ,con.fecha_aniversario
			   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
			   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
			   ,con.e_mail
			   ,trim(con.direccion_1) || trim(con.direccion_2) as direccion
			   ,con.celular
			   ,con.telefono2
			   ,con.telefono1
			   ,con.nacionalidad as pais
			   ,con.cedula
			   ,ocu.nombre
			   ,con.sexo
			   ,con.date_added
			   ,par.nombre
			   ,dep.prima
		  into _cod_cliente2,
			   _fecha_aniversario,
			   _nombres,
			   _apellidos,
			   _e_mail,
			   _direccion,
			   _celular,
			   _telefono2,
			   _telefono1,
			   _pais,
			   _cedula,
			   _ocupacion,
			   _sexo,
			   _date_added,
			   _parentesco,
			   _prima_bruta
		  from emidepen dep
		 inner join cliclien con
				 on con.cod_cliente = dep.cod_cliente
		 inner join emiparen par
		         on par.cod_parentesco = dep.cod_parentesco
		 left  join cliocupa ocu
				 on ocu.cod_ocupacion = con.cod_ocupacion	 
		  where dep.no_poliza = _no_poliza
		    and dep.no_unidad = _no_unidad
		    and dep.activo = 1
			
		if _prima_bruta is null then
			let _prima_bruta = 0;
		end if
		let _impuesto = _prima_bruta * _PorcImpuesto / 100;
		let _prima_neta = _prima_bruta + _impuesto;			
		  
		RETURN _cod_cliente2,
			   _no_poliza,
			   _no_unidad,
			   _fecha_aniversario,
			   null,
			   _nombres,
			   _apellidos,
			   _suma_asegurada,
			   null,
			   null,
			   null,
			   _prima_bruta,
			   _PorcImpuesto,
			   _impuesto,
			   _prima_neta,
			   4,
			   _IdEndoso,
			   2,
			   null,
			   _cod_cliente,
			   _CodigoCorredor,
			   _parentesco,
			   _cod_producto,
			   _producto,
			   _e_mail,
			   _direccion,
			   null,		   
			   _celular,
			   _telefono2,
			   _telefono1,
			   _pais,
			   _cedula,
			   null,
			   _ocupacion,
			   _sexo,
			   _date_added,
			   null,
			   _recargo,
			   null,
			   _descuento
			   WITH RESUME;	
		  
	END FOREACH
	
	-- Beneficiarios
	FOREACH
		select distinct
			   con.cod_cliente
			   ,con.fecha_aniversario
			   ,case con.tipo_persona when "N" then trim(nvl(con.aseg_primer_nom,"")) || " " || trim(nvl(con.aseg_segundo_nom,"")) else "" end as nombres
			   ,trim(nvl(con.aseg_primer_ape,"")) || " " ||  trim(nvl(con.aseg_segundo_ape,"")) as apellidos
			   ,con.e_mail
			   ,trim(con.direccion_1) || trim(con.direccion_2) as direccion
			   ,con.celular
			   ,con.telefono2
			   ,con.telefono1
			   ,con.nacionalidad as pais
			   ,con.cedula
			   ,ocu.nombre
			   ,con.sexo
			   ,con.date_added
			   ,par.nombre
			   ,ben.porc_partic_ben
		  into _cod_cliente2,
			   _fecha_aniversario,
			   _nombres,
			   _apellidos,
			   _e_mail,
			   _direccion,
			   _celular,
			   _telefono2,
			   _telefono1,
			   _pais,
			   _cedula,
			   _ocupacion,
			   _sexo,
			   _date_added,
			   _parentesco,
			   _porc_partic_ben
		  from emibenef ben
		 inner join cliclien con
				 on con.cod_cliente = ben.cod_cliente
		 inner join emiparen par
		         on par.cod_parentesco = ben.cod_parentesco
		 left  join cliocupa ocu
				 on ocu.cod_ocupacion = con.cod_ocupacion	 
		  where ben.no_poliza = _no_poliza
			and ben.no_unidad = _no_unidad
		  
		RETURN _cod_cliente2,
			   _no_poliza,
			   _no_unidad,
			   _fecha_aniversario,
			   null,
			   _nombres,
			   _apellidos,
			   _suma_asegurada,
			   null,
			   null,
			   null,
			   _prima_bruta,
			   _PorcImpuesto,
			   _impuesto,
			   _prima_neta,
			   4,
			   _IdEndoso,
			   3,
			   _porc_partic_ben,
			   _cod_cliente,
			   _CodigoCorredor,
			   _parentesco,
			   _cod_producto,
			   _producto,
			   _e_mail,
			   _direccion,
			   null,		   
			   _celular,
			   _telefono2,
			   _telefono1,
			   _pais,
			   _cedula,
			   null,
			   _ocupacion,
			   _sexo,
			   _date_added,
			   null,
			   _recargo,
			   null,
			   _descuento
			   WITH RESUME;	
		  
	END FOREACH
END FOREACH
END PROCEDURE	  