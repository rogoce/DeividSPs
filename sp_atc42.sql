-- contratantes de Polizas Activas
-- Creado    : 19/01/2024 - Autor: HGIRON  SD#9057:JEPEREZ: Reporte de Contratantes 1 y 2
-- SIS v.2.0 - - DEIVID, S.A.
DROP PROCEDURE sp_atc42;

CREATE PROCEDURE "informix".sp_atc42(a_cia CHAR(3), a_agencia CHAR(3), a_fecha date, a_tipo_persona CHAR(1), a_opcion SMALLINT default 0)
returning VARCHAR(250) as Contratante,
        VARCHAR(30) as cedula,
		VARCHAR(10) as Telefono1,
		VARCHAR(10) as Telefono2,
		VARCHAR(10) as Telefono3,
		VARCHAR(10) as Celular,
           CHAR(10) as cod_contratante;
		
DEFINE _tipo_persona     CHAR(1);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_contratante  CHAR(10);
DEFINE _aseg_primer_nom  VARCHAR(60);
DEFINE _aseg_segundo_nom VARCHAR(60);
DEFINE _aseg_primer_ape  VARCHAR(60);
DEFINE _aseg_segundo_ape VARCHAR(60);
DEFINE _Contratante      VARCHAR(250);
DEFINE _Contratantef     VARCHAR(250);
define _e_mail			 VARCHAR(50);
define _telefono1        VARCHAR(10);
define _telefono2        VARCHAR(10);
define _telefono3        VARCHAR(10);
define _celular          VARCHAR(10);
define _cedula           VARCHAR(30);	
define _cantidad         integer;
 
drop table if exists temp_perfil;
drop table if exists tmp_perfil1;
drop table if exists tmp_perfil2;

drop table if exists tmp_Contratante;
	    CREATE TEMP TABLE tmp_Contratante(
              Contratante      CHAR(250),
			  Identificacion   VARCHAR(30),
			  telefono1        VARCHAR(10),
			  telefono2        VARCHAR(10),
			  telefono3        VARCHAR(10),
			  Celular          VARCHAR(10),
			  cod_contratante   char(10))
              WITH NO LOG;


SET ISOLATION TO DIRTY READ;
LET v_descr_cia = sp_sis01(a_cia);
LET _aseg_primer_nom = NULL;
LET _aseg_segundo_nom = NULL;
LET _aseg_primer_ape = NULL;
LET _aseg_segundo_ape = NULL;
let _tipo_persona = '';
let _cantidad = 0;

--polizas vigentes a la fecha
drop table if exists temp_perfil;
drop table if exists tmp_perfil1;
drop table if exists tmp_perfil2;

CALL sp_pro03(a_cia, a_agencia, a_fecha, '*') RETURNING v_filtros;

 SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
   FROM temp_perfil temp_perfil
  INNER JOIN emipomae pol ON temp_perfil.no_poliza = pol.no_poliza
  WHERE temp_perfil.seleccionado = 1  
    AND (pol.cod_no_renov in ( '039' ) or nvl(pol.cod_no_renov ,'') = '') --  PÃ³lizas con Estatus VIGENTES y VIGENTES con Motivo de No RenovaciÃ³n 039 - Cese de Coberturas (LEY 68)
   INTO temp tmp_perfil1;

  
delete from temp_perfil;
CALL sp_pro03h(a_cia, a_agencia, a_fecha, '*') RETURNING v_filtros;



 SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
   FROM temp_perfil temp_perfil
  INNER JOIN emipomae pol ON temp_perfil.no_poliza = pol.no_poliza
  WHERE pol.cod_no_renov = '027'   --   Pólizas con Estatus Vencidas que tengan Motivo de No Renovación: 027 - Saldo Pendientes y Facturacion Atrasada
    AND temp_perfil.seleccionado = 1   
   INTO temp tmp_perfil2;


			  
 delete from temp_perfil;
 insert into temp_perfil select tmp_perfil1.no_poliza,tmp_perfil1.no_documento,tmp_perfil1.no_factura,tmp_perfil1.cod_ramo,tmp_perfil1.cod_subramo,tmp_perfil1.cod_sucursal,tmp_perfil1.cod_grupo,tmp_perfil1.cod_tipoprod,tmp_perfil1.cod_contratante,tmp_perfil1.cod_agente,tmp_perfil1.prima_suscrita,tmp_perfil1.prima_retenida,tmp_perfil1.vigencia_inic,tmp_perfil1.vigencia_final,tmp_perfil1.fecha_suscripcion,tmp_perfil1.usuario,tmp_perfil1.suma_asegurada,tmp_perfil1.prima_bruta,tmp_perfil1.seleccionado from tmp_perfil1;
 insert into temp_perfil select tmp_perfil2.no_poliza,tmp_perfil2.no_documento,tmp_perfil2.no_factura,tmp_perfil2.cod_ramo,tmp_perfil2.cod_subramo,tmp_perfil2.cod_sucursal,tmp_perfil2.cod_grupo,tmp_perfil2.cod_tipoprod,tmp_perfil2.cod_contratante,tmp_perfil2.cod_agente,tmp_perfil2.prima_suscrita,tmp_perfil2.prima_retenida,tmp_perfil2.vigencia_inic,tmp_perfil2.vigencia_final,tmp_perfil2.fecha_suscripcion,tmp_perfil2.usuario,tmp_perfil2.suma_asegurada,tmp_perfil2.prima_bruta,tmp_perfil2.seleccionado from tmp_perfil2;

		  
delete from tmp_perfil1;
delete from tmp_perfil2;

drop table if exists tmp_perfil1;
drop table if exists tmp_perfil2;

 if a_opcion = 1 then
 
  SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
   FROM temp_perfil temp_perfil
  INNER JOIN cliclien cli ON cli.cod_cliente = temp_perfil.cod_contratante
  WHERE trim(cli.e_mail) = ''   --  Que en su mantenimiento de clientes (cliclien --> email) no tengan información en su campo de correo electrónico.
    AND temp_perfil.seleccionado = 1   
   INTO temp tmp_perfil1;   
		select count(*)
			  into _cantidad
			  from tmp_perfil1;
 end if
 
 if a_opcion = 2 then
 
  SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
   FROM temp_perfil temp_perfil
  INNER JOIN emipomae pol ON temp_perfil.no_poliza = pol.no_poliza
  INNER JOIN cliclien cli ON cli.cod_cliente = temp_perfil.cod_contratante
  INNER JOIN emipoagt emi on emi.no_poliza = temp_perfil.no_poliza 
  INNER JOIN agtagent agt on emi.cod_agente = agt.cod_agente
  WHERE trim(cli.e_mail) = trim(agt.e_mail)    --  Que en su mantenimiento de clientes (cliclien --> email) la dirección de correo electrónico, sea igual a la del campo email del mantenimiento de corredores del corredor suscrito en la poliza vigente, vencida.
    AND temp_perfil.seleccionado = 1   
   INTO temp tmp_perfil2;  
   		select count(*)
			  into _cantidad
			  from tmp_perfil2;
   
 end if		  
 --set debug file to "sp_atc42.trc";
--trace on;  


		select count(*)
			  into _cantidad
			  from temp_perfil;
  if a_opcion = 1 then
	delete from temp_perfil;
	insert into temp_perfil select tmp_perfil1.no_poliza,tmp_perfil1.no_documento,tmp_perfil1.no_factura,tmp_perfil1.cod_ramo,tmp_perfil1.cod_subramo,tmp_perfil1.cod_sucursal,tmp_perfil1.cod_grupo,tmp_perfil1.cod_tipoprod,tmp_perfil1.cod_contratante,tmp_perfil1.cod_agente,tmp_perfil1.prima_suscrita,tmp_perfil1.prima_retenida,tmp_perfil1.vigencia_inic,tmp_perfil1.vigencia_final,tmp_perfil1.fecha_suscripcion,tmp_perfil1.usuario,tmp_perfil1.suma_asegurada,tmp_perfil1.prima_bruta,tmp_perfil1.seleccionado from tmp_perfil1;
	delete from tmp_perfil1;
	--drop table if exists tmp_perfil1;
end if
  if a_opcion = 2 then
    delete from temp_perfil;
	 insert into temp_perfil select tmp_perfil2.no_poliza,tmp_perfil2.no_documento,tmp_perfil2.no_factura,tmp_perfil2.cod_ramo,tmp_perfil2.cod_subramo,tmp_perfil2.cod_sucursal,tmp_perfil2.cod_grupo,tmp_perfil2.cod_tipoprod,tmp_perfil2.cod_contratante,tmp_perfil2.cod_agente,tmp_perfil2.prima_suscrita,tmp_perfil2.prima_retenida,tmp_perfil2.vigencia_inic,tmp_perfil2.vigencia_final,tmp_perfil2.fecha_suscripcion,tmp_perfil2.usuario,tmp_perfil2.suma_asegurada,tmp_perfil2.prima_bruta,tmp_perfil2.seleccionado from tmp_perfil2;
	delete from tmp_perfil2;
	--drop table if exists tmp_perfil2;
end if	 
		select count(*)
			  into _cantidad
			  from temp_perfil;
FOREACH
 SELECT distinct cod_contratante
   INTO _cod_contratante
   FROM temp_perfil
  WHERE seleccionado = 1       

		SELECT distinct trim(aseg_primer_nom),
			   trim(aseg_segundo_nom),
			   trim(replace(upper(trim(aseg_primer_ape)),'Ñ','N')),   --aseg_primer_ape,
			   trim(replace(upper(trim(aseg_segundo_ape)),'Ñ','N')),   --aseg_segundo_ape,
			   trim(tipo_persona),
			   telefono1,
			   telefono2,
			   telefono3,
			   celular, 
			   e_mail,
			   cedula
		  INTO _aseg_primer_nom,
			   _aseg_segundo_nom,
			   _aseg_primer_ape,
			   _aseg_segundo_ape,
			   _tipo_persona,
			   _telefono1,
			   _telefono2,
			   _telefono3,
			   _celular, 
			   _e_mail,
			   _cedula
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;		  

		 if _tipo_persona not in ('N','J') then
		     continue foreach;
		 end if
		 if a_tipo_persona not in ('0') then
			 if _tipo_persona  <> a_tipo_persona then
				 continue foreach;
			 end if
		 end if

    if _aseg_primer_nom is null then
		LET _aseg_primer_nom = '';
	end if
    if _aseg_segundo_nom is null then
		LET _aseg_segundo_nom = '';
	end if
	    if _aseg_primer_ape is null then
		LET _aseg_primer_ape = '';
	end if
    if _aseg_segundo_ape is null then
		LET _aseg_segundo_ape = '';
	end if
    LET _aseg_primer_nom = UPPER(_aseg_primer_nom);	
	LET _aseg_segundo_nom = UPPER(_aseg_segundo_nom);
	LET _aseg_primer_ape = UPPER(_aseg_primer_ape);	
	LET _aseg_segundo_ape = UPPER(_aseg_segundo_ape);
	
	let _Contratante = trim(_aseg_primer_nom)||" "||trim(_aseg_segundo_nom)||" "||trim(_aseg_primer_ape)||" "||trim(_aseg_segundo_ape);
	
	if _Contratante is null then
	    continue foreach;
	end if

	if a_tipo_persona in ('N','J','0') then
		let _contratantef = '';
		let _Contratante = rtrim(_Contratante);	
		let _Contratante = ltrim(_Contratante);				
		call sp_atc41a(_Contratante) returning _contratantef;			
		if _Contratantef is null or trim(_Contratantef) = '' then
			continue foreach;
		end if			
		BEGIN
		ON EXCEPTION IN(-239,-268)
		END EXCEPTION
		insert into tmp_Contratante(
		Contratante,
		Identificacion,
		Telefono1,
		Telefono2,
		Telefono3,
		Celular,
		cod_contratante)
		values(_Contratantef,
		_Cedula,
		_Telefono1,
		_Telefono2,
		_Telefono3,
		_Celular,
		_cod_contratante);
		END
	end if

END FOREACH

foreach
 select distinct Contratante,
		Identificacion,
		Telefono1,
		Telefono2,
		Telefono3,
		Celular,
		cod_contratante
   into _Contratante,
        _cedula,
		_Telefono1,
		_Telefono2,
		_Telefono3,
		_Celular,
		_cod_contratante
   from tmp_Contratante
 -- group by 1,2,3,4,5,6

RETURN  _Contratante,
        _cedula,
		_Telefono1,
		_Telefono2,
		_Telefono3,
		_Celular,
        _cod_contratante		
		WITH RESUME;

end foreach

END PROCEDURE

