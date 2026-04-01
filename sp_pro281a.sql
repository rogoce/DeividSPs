-- Procedimiento que Realiza la Renovacion de la Poliza

-- Creado    : 04/12/2000 - Autor: Victor Molinar  
-- Modificado: 18/05/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/08/2001 - Autor: Armando Moreno
-- Modificado: 03/09/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 11/02/2003 - Autor: Demetrio Hurtado Almanza
--             
-- SIS v.2.0 - d_prod_ren_sel_de_pol_a_ren - DEIVID, S.A.

-- 18/05/2001: Se Incluyo el porcentaje de depreciacion de forma automatica (Demetrio)
-- 13/08/2001: Se mod. para no renovar las unidades marcadas como perdida total
--             (Armando Moreno)
-- 03/09/2001: Se Incluyo el Calculo de la Fecha del Primer Pago para las Polizas
-- 			   con Forma de Pago No Mensual y un Solo Pago (Demetrio)

drop procedure sp_pro281a;
create procedure sp_pro281a(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10)) RETURNING   INTEGER;

--- Actualizacion de Polizas

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _vigencia_final DATE;

DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
define _saldo_unidad   smallint;
define _porc_com       DEC(5,2);
define _cod_agt        char(5);
define _cod_rammo      char(3);
define _cnt            smallint;
define _r_anos         smallint;
define _cod_prod       char(5);
define _cod_subramo    char(3);
define _tipo_agente    char(1);
define _canti          smallint;
define _cod_origen     char(3);
define _aplica_imp     smallint;
define _cod_impuesto   char(3);
define _no_documento   char(20);
define _saber_agt      smallint;
define _mes,_anno      smallint;
define _vig_fin        date;

define _vig_ini        date;
define _contar         smallint;
define _cod_ruta       char(5);
define _serie          smallint;
define _contar2        smallint;
define _no_cambio      smallint;
define _orden          smallint;
define _cod_contrato	char(5);
define _porc_prima		dec(10,4);
define _porc_suma		dec(10,4);
define _cod_cober_reas	char(3);
define _fronting2		smallint;
define _fronting		smallint;
define _tipo_contrato	char(1);
define _cod_cont_fac	char(5);
define _cod_ramo        char(3);
define _cod_grupo		char(5);
define _cant            smallint;
				
{F v_poliza = '1782292' THEN
	SET DEBUG FILE TO "sp_pro281.trc"; 
	trace on;
END IF}

BEGIN

SET LOCK MODE TO WAIT;

update emipomae
   set renovada    = 1,
       fecha_renov = CURRENT
 where no_poliza   = v_poliza;

select * 
  from emipomae
 where no_poliza = v_poliza
  into temp prueba;

Let r_anos = 0;
let _r_anos = 0;
let _saldo_unidad = 0;
let _anno = 0;
let _mes = 0;

select x.anos_pagador,
       x.vigencia_final,
       x.saldo_por_unidad,
       x.cod_ramo 
  Into r_anos,
       _vigencia_final,
       _saldo_unidad,
	   _cod_rammo
  from prueba x
 where x.no_poliza = v_poliza;

let li_mes = month(_vigencia_final);
let li_dia = day(_vigencia_final);
let li_ano = year(_vigencia_final);

If li_mes = 2 Then
	If li_dia > 28 Then
		let li_dia = 28;
	    let _vigencia_final = MDY(li_mes, li_dia, li_ano);
	End If
End If

if _cod_rammo <> "019" then
	If r_anos > 0 Then
	   LET r_anos = r_anos - 1;
	Else
	   LET r_anos = 0;
	End If
else
	let r_anos = r_anos + 1;
end if

update prueba
   set no_poliza         = v_poliza_nuevo,
       serie             = Year(vigencia_final),
       no_factura        = NULL,
	   no_recibo         = NULL,
       fecha_suscripcion = Current,
       fecha_impresion   = Current,
       fecha_cancelacion = NULL,
       impreso           = 0,
       nueva_renov       = "R",
       estatus_poliza    = 1,
       actualizado       = 0,
	   posteado          = '0',
       fecha_primer_pago = vigencia_final,
       date_changed      = CURRENT,
       date_added        = CURRENT,
       carta_aviso_canc  = 0,
       carta_prima_gan   = 0,
       carta_vencida_sal = 0,
       carta_recorderis  = 0,
       fecha_aviso_canc  = NULL,
       fecha_prima_gan   = NULL,
       fecha_vencida_sal = NULL,
       fecha_recorderis  = NULL,
       user_added        = v_usuario,
       ult_no_endoso     = 0,
       renovada          = 0,
       fecha_renov       = NULL,
       fecha_no_renov    = NULL,
       no_renovar        = 0,
       perd_total        = 0,
       anos_pagador      = r_anos,
       incobrable        = 0,
       fecha_ult_pago    = NULL,
       vigencia_inic     = vigencia_final,
       vigencia_final    = _vigencia_final + 1 UNITS YEAR,
       saldo             = 0,
	   cod_banco         = cod_banco,
	   no_cuenta         = no_cuenta,
	   tiene_gastos      = 0,
	   gastos			 = 0.00,
	   cotizacion        = "",
	   de_cotizacion     = 0,
	   saldo_por_unidad  = _saldo_unidad,
	   wf_aprob          = 0,
	   wf_firma_aprob    = null,
	   wf_incidente      = null,
	   wf_fecha_entro    = null,
	   wf_fecha_aprob	 = null
 where no_poliza         = v_poliza;

let _saber_agt = 0;

{foreach
	select count(*)			   --Excluir las sodas de ducruet hasta segunda orden, Armando 17/02/2012, solicitado por Analiza.
	  into _saber_agt
	  from emipoagt
	 where no_poliza  = v_poliza
	   and cod_agente = '00035'

	exit foreach;
end foreach

if _cod_rammo = '020' and _saber_agt = 0 then --SODA

	select no_documento,vigencia_final
	  into _no_documento,_vig_fin
	  from emipomae
	 where no_poliza = v_poliza;

    let _mes = month(_vig_fin);
	let _anno = year(_vig_fin);

	if _mes > 9 and _anno > 2012 then
	else
		update prueba
		   set nueva_renov      = "N",
		       reemplaza_poliza = _no_documento,
			   no_documento     = null
		 where no_poliza = v_poliza_nuevo;
	end if

end if }	--Se quita por instr. sr Tobias C.20/09/2012

insert into emipomae
select * from prueba
 where no_poliza = v_poliza_nuevo;

SELECT fecha_primer_pago,
       no_pagos,
	   cod_perpago,
	   cod_grupo
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   ls_cod_perpago,
	   _cod_grupo
  FROM emipomae
 where no_poliza = v_poliza_nuevo;

if li_no_pagos = 1 then

	select meses
	  into li_meses
	  from cobperpa
	 where cod_perpago = ls_cod_perpago;

	let li_mes = month(ld_fecha_1_pago) + li_meses;
	let li_ano = year(ld_fecha_1_pago);
	let li_dia = day(ld_fecha_1_pago);

	If li_mes > 12 Then
		let li_mes = li_mes - 12;
		let li_ano = li_ano + 1;
	End If

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
		End If
	Elif li_mes in (4, 6, 9, 11) Then
		If li_dia > 30 Then
			let li_dia = 30;
		End If
	End If

	let ld_fecha_1_pago = MDY(li_mes, li_dia, li_ano);

	update emipomae
	   set fecha_primer_pago = ld_fecha_1_pago
	 where no_poliza = v_poliza_nuevo;

end if

drop table prueba;

select * 
  from emiporec
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiporec
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emidirco
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emidirco
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

--*** comision por agente en la poliza mod.28/04/2008

select * 
  from emipoagt
 where no_poliza = v_poliza
  into temp prueba;

select cod_ramo
  into _cod_rammo
  from emipomae
 where no_poliza = v_poliza;

select anos_pagador,
       cod_subramo,
	   cod_origen,
	   no_documento
  into _r_anos,
       _cod_subramo,
	   _cod_origen,
	   _no_documento
  from emipomae
 where no_poliza = v_poliza_nuevo;

foreach

	select cod_producto
	  into _cod_prod
	  from emipouni
	 where no_poliza = v_poliza

	exit foreach;

end foreach

let _porc_com = 0;

foreach

	select cod_agente,
		   porc_comis_agt
	  into _cod_agt,
	       _porc_com
	  from prueba

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agt;

	if _cod_rammo <> "019" then

		if _porc_com = 0 then

			CALL sp_pro305(_cod_agt,_cod_rammo,_cod_subramo) RETURNING _porc_com;

		end if

	else
		foreach

			select porc_comis_agt
			  into _porc_com
			  from prdcoprd
			 where cod_producto = _cod_prod
			   and _r_anos between ano_desde and ano_hasta

			exit foreach;

 	    end foreach
	end if

	if _porc_com is null then
		let _porc_com = 0;
	end if

	if _tipo_agente = 'O' then
		let _porc_com = 0;
	end if

	update prueba 
	   set porc_comis_agt = _porc_com
	 where cod_agente     = _cod_agt
	   and no_poliza      = v_poliza;

end foreach

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipoagt
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolim
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolim
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select count(*)
  into _canti 
  from emipolim
 where no_poliza = v_poliza_nuevo;

if _canti = 0 then

	Select aplica_impuesto
	  Into _aplica_imp
	  From parorig
	 Where cod_origen = _cod_origen;

	if _aplica_imp = 1 then

		let _cnt = sp_sis186(_no_documento,_aplica_imp);

		if _cnt <> 0 then	--Hay error
		else

			foreach
				Select cod_impuesto
				  into _cod_impuesto
				  From prdimsub
				 Where cod_ramo    = _cod_rammo
				   And cod_subramo = _cod_subramo

				Insert Into emipolim (no_poliza, cod_impuesto, monto)
				Values (v_poliza_nuevo,_cod_impuesto, 0.00);

			end foreach

		end if
	end if
end if


select * 
  from emicoama
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoama
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emicoami
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoami
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emiciara
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiciara
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolde
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolde
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipouni
 where no_poliza = v_poliza
  into temp prueba;

select * from emipouni
 where no_poliza = v_poliza
   and perd_total = 1
  into temp prueba2;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza
   and perd_total = 0;

insert into emipouni
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select count(*)
  into _cnt
  from emipouni
 where no_poliza = v_poliza_nuevo;

if _cnt = 0 then
	return 1;
end if

select * from emipode2
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipode2
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipoacr
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipoacr
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emiunide
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunide
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiunire
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunire
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emifian1
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifian1
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emifigar
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifigar
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiauto
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiauto
select * from prueba
 where no_poliza = v_poliza_nuevo;

update emiauto
   set ano_tarifa = 1
 where no_poliza  = v_poliza_nuevo
   and ano_tarifa = 0;

update emiauto
   set ano_tarifa = ano_tarifa + 1
 where no_poliza  = v_poliza_nuevo;

drop table prueba;


select * from emicupol
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicupol
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

--------- reaseguro ---------
--if v_poliza = 'A' then
--buscar ruta
select cod_ramo,vigencia_inic
  into _cod_ramo,_vig_ini
  from emipomae
 where no_poliza = v_poliza_nuevo;

select count(*)
  into _cnt
  from rearumae
 where cod_ramo = _cod_ramo
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;

if _cnt = 0 then
	return 2;  --No existe ruta de reaseguro para esa vigencia.
end if

select count(*)
  into _contar
  from emifafac
 where no_poliza = v_poliza;
 
 if _contar is null then
	let _contar = 0;
 end if
 
foreach
	select cod_ruta,serie
	  into _cod_ruta,_serie
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
 	   and _vig_ini between vig_inic and vig_final
	   
	if _cod_ramo = '002' then
		select count(*)
		  into _contar2
		  from rearucon r, reacomae t
         where r.cod_contrato  = t.cod_contrato
		   and r.cod_ruta      = _cod_ruta
		   and t.tipo_contrato = 3;

		if _contar2 is null then
			let _contar2 = 0;
		end if

		if _contar > 0 and _contar2 > 0 then
			exit foreach;
		end if
	else
		exit foreach;
	end if	
end foreach

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = v_poliza;

update emipouni
   set cod_ruta = _cod_ruta
where no_poliza = v_poliza_nuevo;

update emipomae
   set serie     = _serie
 where no_poliza = v_poliza_nuevo;

--Para sunctracs
if _cod_rammo = '016' and _cod_subramo = '002' and _cod_grupo = '01016' then

	foreach
		select orden,
		       cod_contrato,
			   porc_partic_prima,
			   porc_partic_suma
		  into _orden,
		       _cod_contrato,
			   _porc_prima,
			   _porc_suma
		 from rearucon
		where cod_ruta = _cod_ruta
		  and porc_partic_prima <> 0
		  and porc_partic_suma  <> 0

		foreach
			select a.no_unidad,
				   a.cod_cober_reas
			  into _no_unidad,
				   _cod_cober_reas
			  from emireaco a, emipouni b
			 where a.no_unidad = b.no_unidad
			   and a.no_poliza = v_poliza
			   and a.no_cambio = _no_cambio
			   and b.no_poliza = v_poliza_nuevo
			 group by 1,2

			let _fronting  = 0;
			let _fronting2 = 0;

			select tipo_contrato,
				   fronting
			  into _tipo_contrato,
				   _fronting
			  from reacomae
			 where cod_contrato = _cod_contrato;

			insert into emifacon(
					no_poliza,
					no_endoso,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_ruta,
					porc_partic_prima,
					porc_partic_suma,
					suma_asegurada,
					prima)
			values(	v_poliza_nuevo,
					"00000",
					_no_unidad,
					_cod_cober_reas,
					_orden,
					_cod_contrato,
					_cod_ruta,
					_porc_prima,
					_porc_suma,
					0.00,
					0.00);
	    end foreach
	end foreach
else
	foreach
		select a.no_unidad,
			   a.cod_cober_reas,
			   a.orden,
			   a.cod_contrato,
			   a.porc_partic_suma,
			   a.porc_partic_prima
		  into _no_unidad,
			   _cod_cober_reas,
			   _orden,
			   _cod_contrato,
			   _porc_suma,
			   _porc_prima
		   from emireaco a, emipouni b 
		  where a.no_unidad = b.no_unidad
		    and a.no_poliza = v_poliza
		    and a.no_cambio = _no_cambio
			and b.no_poliza = v_poliza_nuevo

			let _fronting  = 0;
			let _fronting2 = 0;

		select tipo_contrato,
			   fronting
		  into _tipo_contrato,
			   _fronting
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _cod_rammo in ('002','023','020') then
			foreach
			    select cod_cober_reas,
				       orden,
					   cod_contrato,
					   porc_partic_suma,
					   porc_partic_prima
				  into _cod_cober_reas,
				       _orden,
					   _cod_contrato,
					   _porc_suma,
					   _porc_prima
				  from rearucon r, rearumae e
				 where r.cod_ruta     = e.cod_ruta
				   and e.cod_ramo     = _cod_rammo
				   and e.activo       = 1
				   and e.cod_ruta     = _cod_ruta

				select count(*)
				  into _cant
				  from emifacon		  
				 where no_poliza	  = v_poliza_nuevo
				   and no_endoso	  = '00000'
				   and no_unidad	  = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and orden		  = _orden;

				if _cant = 0 then
					insert into emifacon(
							no_poliza,
							no_endoso,
							no_unidad,
							cod_cober_reas,
							orden,
							cod_contrato,
							cod_ruta,
							porc_partic_prima,
							porc_partic_suma,
							suma_asegurada,
							prima)
					values(	v_poliza_nuevo,
							"00000",
							_no_unidad,
							_cod_cober_reas,
							_orden,
							_cod_contrato,
							_cod_ruta,
							_porc_prima,
							_porc_suma,
							0.00,
							0.00);
				end if
			end foreach
		else
			foreach
				select cod_contrato
				  into _cod_contrato
				  from reacomae
				 where tipo_contrato = _tipo_contrato
				   and serie 		 = _serie
				   and fronting      = _fronting

				select count(*)
				  into _cnt
				  from rearucon r, rearumae e
				 where r.cod_ruta     = e.cod_ruta
				   and r.cod_contrato = _cod_contrato
				   and e.cod_ramo     = _cod_rammo
				   and e.activo       = 1
				   and e.serie        = _serie;

				if _cnt = 0 then
				else
				  exit foreach;
				end if
			end foreach

			insert into emifacon(
					no_poliza,
					no_endoso,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_ruta,
					porc_partic_prima,
					porc_partic_suma,
					suma_asegurada,
					prima)
			values(	v_poliza_nuevo,
					"00000",
					_no_unidad,
					_cod_cober_reas,
					_orden,
					_cod_contrato,
					_cod_ruta,
					_porc_prima,
					_porc_suma,
					0.00,
					0.00);

		end if
	end foreach
end if

select * 
  from emifafac
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_poliza = v_poliza
   and no_endoso <> "00000";

foreach
	select c.cod_contrato
	  into _cod_cont_fac
	  from emifacon c, reacomae r
	 where c.cod_contrato = r.cod_contrato
	   and c.no_poliza = v_poliza_nuevo
	   and r.tipo_contrato = 3
	exit foreach;
end foreach

update prueba 
   set no_poliza    = v_poliza_nuevo,
       no_cesion    = null,
	   cod_contrato = _cod_cont_fac
 where no_poliza    = v_poliza;

insert into emifafac	--facultativo
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

--end if
-----------

select * from emipocob
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipocob
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emicobde
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicobde
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;
drop table prueba2;

select * 
  from emibenef
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emibenef
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


-- Calculo de la Depreciacion

SELECT porc_depreciacion
  INTO _porc_depre_pol
  FROM emirepol
 WHERE no_poliza = v_poliza;

IF _porc_depre_pol <> 0.00 THEN

	FOREACH
	 SELECT no_unidad,
			cod_producto,
			suma_asegurada
	   INTO _no_unidad,
			_cod_producto,
			_suma_decimal
	   FROM emipouni
	  WHERE no_poliza = v_poliza_nuevo

		SELECT porc_depreciacion
		  INTO _porc_depre_uni
		  FROM emirepod
		 WHERE no_poliza = v_poliza
		   AND no_unidad = _no_unidad;

		SELECT no_motor
		  INTO _no_motor
		  FROM emiauto
		 WHERE no_poliza = v_poliza_nuevo
		   AND no_unidad = _no_unidad;

		IF _porc_depre_uni IS NULL THEN  
			LET _porc_depre_uni = 0.00;
		END IF

		IF _porc_depre_uni = 0.00 THEN  
			LET _porc_depre = _porc_depre_pol;
		ELSE
			LET _porc_depre = _porc_depre_uni;
		END IF

		LET _suma_asegurada = _suma_decimal * (1 - _porc_depre/100); 
		LET _suma_decimal   = _suma_decimal * (1 - _porc_depre/100); 

		LET _suma_difer = _suma_decimal - _suma_asegurada;

		IF _suma_difer >= 0.5 THEN
			LET _suma_asegurada = _suma_asegurada + 1;
		END IF

		UPDATE emipouni
		   SET suma_asegurada = _suma_asegurada
		 WHERE no_poliza      = v_poliza_nuevo
		   AND no_unidad      = _no_unidad;

		UPDATE emivehic
		   SET valor_auto = _suma_asegurada
		 WHERE no_motor   = _no_motor;
		
		FOREACH
		 SELECT cod_cobertura
		   INTO _cod_cobertura
		   FROM emipocob
		  WHERE no_poliza = v_poliza_nuevo
		    AND no_unidad = _no_unidad

			SELECT valor_asignar
			  INTO _valor_asignar
			  FROM prdcobpd
			 WHERE cod_producto  = _cod_producto
			   AND cod_cobertura = _cod_cobertura;  

			IF _valor_asignar = 'S' THEN

				UPDATE emipocob
				   SET limite_1      = _suma_asegurada
				 WHERE no_poliza     = v_poliza_nuevo
				   AND no_unidad     = _no_unidad
				   AND cod_cobertura = _cod_cobertura;

			END IF

		END FOREACH

	END FOREACH

END IF

DELETE FROM emirepod
 WHERE no_poliza = v_poliza;

DELETE FROM emirepol
 WHERE no_poliza = v_poliza;

return 0;
END
end procedure;