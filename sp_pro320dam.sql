--****************************************************************
-- Procedimiento que Realiza la Renovacion Automatica de la Poliza
--****************************************************************
-- se copio del sp_pro281()
-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- Modificado: 28/04/2009 - Autor: Armando Moreno M.

drop procedure sp_pro320dam;
create procedure sp_pro320dam(v_usuario char(8), v_poliza char(10), v_poliza_nuevo char(10))
RETURNING INTEGER, char(100);

--- Actualizacion de Polizas
define _mensaje			char(100);
define _no_motor		char(30);
define _no_documento	char(20);
define _no_recibo       char(10);
define _cod_cobertura	char(5); 
define _cod_cont_fac	char(5);
define _cod_contrato	char(5);
define _nounidad		char(5);
define _cod_producto	char(5);
define _cod_cober		char(5); 
define _cod_grupo		char(5);
define _no_unidad		char(5); 
define _cod_ruta		char(5);
define _cod_prod		char(5);
define _cod_agt			char(5);
define _no_uni			char(5);
define _cod_cober_reas	char(3);
define ls_cod_perpago	char(3);
define _cod_impuesto	char(3);
define _cod_subramo		char(3);
define _cod_origen		char(3);
define _cod_rammo		char(3);
define _cod_ramo		char(3);
define _tipo_contrato	char(1);
define _valor_asignar	char(1); 
define _tipo_agente		char(1);
define _texto           references text;
define _porc_depre_uni	dec(5,2);
define _porc_depre_pol	dec(5,2);
define _porc_desc_max	dec(5,2);
define _porc_depre		dec(5,2);
define _porc_com		dec(5,2);
define _porc_prima		dec(10,4);
define _porc_suma		dec(10,4);
define _suma_prb		dec(16,2);
define _suma			dec(16,2);
define _limite1			dec(16,2);
define _suma_decimal	dec(16,2);
define _suma_difer		dec(16,2);
define _saldo_unidad	smallint;
define li_no_pagos		smallint;
define _aplica_imp		smallint;
define _no_cambio		smallint;
define _fronting2		smallint;
define _fronting		smallint;
define _ramo_sis		smallint;
define li_meses			smallint;
define _orden_n			smallint;
define _contar2  		smallint;
define _contar			smallint;
define _r_anos			smallint;
define li_ano			smallint;
define li_mes			smallint;
define li_dia			smallint;
define r_anos			smallint;
define _canti			smallint;
define _rengl			smallint;
define _cant			smallint;
define _cnt				smallint;
define _mes				smallint;
define _anno,_no_ren_pol			smallint;
define _suma_asegurada integer;
define _cant_unidades	integer; 
define _error_isam		integer;
define _valor			integer;
define _error			integer;
define _serie			integer;
define _orden			integer;
define _vigencia_final	date;
define v_fecha_r		date;
define _vig_fin			date;
define _vig_ini			date;

define _periodo			char(8);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _monto_180		dec(16,2);
define _monto_150		dec(16,2);
define _monto_120		dec(16,2);
define _monto_90		dec(16,2);
define _monto_60		dec(16,2);
define _monto_30		dec(16,2);
define _saldo,_suma_aseg_vida	dec(16,2);
define _saldo_mas_60	dec(16,2);	
define _fecha_aviso_canc	date;
define _carta_aviso_canc,_no_renovar	smallint;
define _can_desc        integer;

let _mensaje = '';
let _contar2 = 0;
let _contar  = 0;
let _no_ren_pol = 0;
let _texto = null;
let _suma_aseg_vida = 0.00;

begin
on exception set _error,_error_isam,_mensaje
 	return _error,_mensaje;         
end exception

set lock mode to not wait;

--SET DEBUG FILE TO "sp_pro320dam.trc";

{if v_poliza = '1937829' then
	TRACE ON;
end if}
delete from deivid_tmp:emipomae_f
where no_poliza = v_poliza;

update emipomae
   set renovada    = 1,
       fecha_renov = current
 where no_poliza   = v_poliza;

let _valor = 0;
let v_fecha_r = current;

insert into deivid_tmp:emipomae_f
select *
  from emipomae
 where no_poliza = v_poliza;

Let r_anos = 0;
let _saldo_unidad = 0;

select x.anos_pagador,
       x.vigencia_final,
       x.saldo_por_unidad,
       x.cod_ramo,
       x.no_documento,x.carta_aviso_canc,x.fecha_aviso_canc,x.no_renovar
  Into r_anos,
       _vigencia_final,
       _saldo_unidad,
	   _cod_rammo,
	   _no_documento,_carta_aviso_canc,_fecha_aviso_canc,_no_ren_pol
  from deivid_tmp:emipomae_f x
 where no_poliza = v_poliza;

if _carta_aviso_canc is null then
	let _carta_aviso_canc = 0;
end if		
if _fecha_aviso_canc is null then
	let _fecha_aviso_canc = null;
end if

let li_mes = month(_vigencia_final);
let li_dia = day(_vigencia_final);
let li_ano = year(_vigencia_final);

if li_mes = 2 then
	if li_dia > 28 then
		let li_dia = 28;
	    let _vigencia_final = mdy(li_mes, li_dia, li_ano);
	end if
end if

if _cod_rammo <> "019" then
	If r_anos > 0 Then
	   LET r_anos = r_anos - 1;
	Else
	   LET r_anos = 0;
	End If
else
	let r_anos = r_anos + 1;
end if

let _no_recibo = null;

select no_recibo,no_renovar 
  into _no_recibo,_no_renovar
  from emirepo
 where no_poliza = v_poliza;

if trim(_no_recibo) = '' then
	let _no_recibo = null;
end if
if _no_renovar = 1 AND _cod_rammo in('002','023') then
    let _mensaje = 'No se puede renovar, póliza Con Cese de Coberturas';
	return 3,_mensaje;
end if
if _no_renovar = 0 then
	if _no_ren_pol = 1 then
	    let _mensaje = 'Poliza esta marcada como No Renovar.';
		return 3,_mensaje;
	end if
end if

-- CASO:ENILDA renovacion New no trae el check no_Poliza anterior
if _carta_aviso_canc = 1 then
	let _periodo = sp_sis39(v_fecha_r);	   
	call sp_cob245a("001","001",_no_documento,_periodo,v_fecha_r)	 
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;

	let _saldo_mas_60 = _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180;
    if _saldo_mas_60 > 0 then 
		update emipomae  
	   	   set carta_aviso_canc = 0,fecha_aviso_canc = null
		 where no_documento in (_no_documento) ;		  
	else
		let _carta_aviso_canc = 0;
		let _fecha_aviso_canc = null;		
    end if   
end if

update deivid_tmp:emipomae_f
   set no_poliza         = v_poliza_nuevo,
       serie             = year(vigencia_final),
       no_factura        = null,
       fecha_suscripcion = current,
       fecha_impresion   = current,
       fecha_cancelacion = null,
       impreso           = 0,
       nueva_renov       = "R",
       estatus_poliza    = 1,
       actualizado       = 0,
	   posteado          = '0',
       fecha_primer_pago = vigencia_final,
       date_changed      = current,
       date_added        = current,
       carta_aviso_canc  = _carta_aviso_canc,
       carta_prima_gan   = 0,
       carta_vencida_sal = 0,
       carta_recorderis  = 0,
       fecha_aviso_canc  = _fecha_aviso_canc,
       fecha_prima_gan   = null,
       fecha_vencida_sal = null,
       fecha_recorderis  = null,
       user_added        = v_usuario,
       ult_no_endoso     = 0,
       renovada          = 0,
       fecha_renov       = null,
       fecha_no_renov    = null,
       no_renovar        = 0,
       perd_total        = 0,
       anos_pagador      = r_anos,
       incobrable        = 0,
       fecha_ult_pago    = null,
       vigencia_inic     = vigencia_final,
       vigencia_final    = _vigencia_final + 1 units year,
       saldo             = 0,
	   cod_banco         = cod_banco,
	   no_cuenta         = no_cuenta,
	   tiene_gastos      = 0,
	   gastos			 = 0.00,
	   cotizacion        = "",
	   de_cotizacion     = 0,
	   saldo_por_unidad  = _saldo_unidad,
	   no_recibo		 = null
 where no_poliza         = v_poliza;

{if _cod_rammo = '020' then --SODA

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
		 where no_poliza        = v_poliza_nuevo;
	end if
end if	 --Se quita 20/09/2012 por instr. sr Carrero.}

insert into emipomae
select * from deivid_tmp:emipomae_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emipomae_f
 where no_poliza = v_poliza_nuevo;

select no_pagos,
	   cod_perpago,
	   cod_ramo,
	   cod_subramo,
	   cod_origen,
	   cod_grupo,
	   suma_asegurada
  into li_no_pagos,
	   ls_cod_perpago,
	   _cod_ramo,
	   _cod_subramo,
	   _cod_origen,
	   _cod_grupo,
	   _suma_aseg_vida
  from emipomae
 where no_poliza = v_poliza_nuevo;
 
 if _no_recibo is not null then
	 update emipomae
		set no_recibo = _no_recibo
	  where no_poliza = v_poliza_nuevo;
end if	  

if _cod_origen is null then
	let _cod_origen = '001';
end if

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
--*************************************
delete from deivid_tmp:emiporec_f
where no_poliza = v_poliza;

insert into deivid_tmp:emiporec_f
select *
  from emiporec
 where no_poliza = v_poliza;

update deivid_tmp:emiporec_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiporec
select * 
  from deivid_tmp:emiporec_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emiporec_f
where no_poliza = v_poliza_nuevo; 

--*************************************
delete from deivid_tmp:emidirco_f
where no_poliza = v_poliza;

insert into deivid_tmp:emidirco_f
select *
  from emidirco
 where no_poliza = v_poliza;

update deivid_tmp:emidirco_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emidirco
select * 
  from deivid_tmp:emidirco_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emidirco_f
where no_poliza = v_poliza_nuevo; 

--*************************************

--*** comision por agente en la poliza mod.28/04/2008
delete from deivid_tmp:emipoagt_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipoagt_f
select *
  from emipoagt
 where no_poliza = v_poliza;

select anos_pagador,
       cod_subramo,
	   no_documento
  into _r_anos,
       _cod_subramo,
	   _no_documento
  from emipomae
 where no_poliza = v_poliza_nuevo;

foreach
	select cod_producto,
	       no_unidad
	  into _cod_prod,
	       _no_unidad
	  from emipouni
	 where no_poliza = v_poliza
	exit foreach;
end foreach

let _porc_com = 0;

if _cod_rammo <> '008' then -- Correo de Lineth Navarro que debe mantener la misma comisión de la vigencia anterior Amado -- 11-03-2016
	foreach
		select cod_agente
		  into _cod_agt
		  from deivid_tmp:emipoagt_f
		 where no_poliza = v_poliza

		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agt;

		if _cod_rammo <> "019" then
			call sp_pro305(_cod_agt,_cod_rammo,_cod_subramo) returning _porc_com;
			if _cod_rammo = '016' and _cod_subramo = '002' and _cod_grupo = '01016' then
				if _cod_agt = '00180' then
					let _porc_com = 25;
				end if			
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

		update deivid_tmp:emipoagt_f
		   set porc_comis_agt = _porc_com
		 where cod_agente     = _cod_agt
		   and no_poliza      = v_poliza;
	end foreach
end if

update deivid_tmp:emipoagt_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipoagt
select * 
  from deivid_tmp:emipoagt_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emipoagt_f
 where no_poliza = v_poliza_nuevo;
 
 --***********************************
 
delete from deivid_tmp:emipolim_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipolim_f
select *
  from emipolim
 where no_poliza = v_poliza;

update deivid_tmp:emipolim_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolim
select * 
  from deivid_tmp:emipolim_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emipolim_f
where no_poliza = v_poliza_nuevo; 
--*********************************

if _cod_rammo = '016' and _cod_subramo = '002' and _cod_grupo = '01016' then
	update emipolim
	   set monto = 0
	 where no_poliza = v_poliza_nuevo;
end if

select count(*)
  into _canti 
  from emipolim
 where no_poliza = v_poliza_nuevo;

if _canti = 0 then

	select aplica_impuesto
	  into _aplica_imp
	  from parorig
	 where cod_origen = _cod_origen;

	if _aplica_imp = 1 then

		let _cnt = sp_sis186(_no_documento,_aplica_imp);

		if _cnt <> 0 then	--No Lleva impuesto.
		else
			foreach
				select cod_impuesto
				  into _cod_impuesto
				  from prdimsub
				 where cod_ramo    = _cod_ramo
				   and cod_subramo = _cod_subramo

				insert into emipolim (no_poliza, cod_impuesto, monto)
				values (v_poliza_nuevo,_cod_impuesto, 0.00);
			end foreach
		end if
	end if
end if
--*********************************
delete from deivid_tmp:emicoama_f
where no_poliza = v_poliza;

insert into deivid_tmp:emicoama_f
select *
  from emicoama
 where no_poliza = v_poliza;

update deivid_tmp:emicoama_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoama
select * 
  from deivid_tmp:emicoama_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emicoama_f
where no_poliza = v_poliza_nuevo; 

--********************************
delete from deivid_tmp:emicoami_f
where no_poliza = v_poliza;

insert into deivid_tmp:emicoami_f
select *
  from emicoami
 where no_poliza = v_poliza;

update deivid_tmp:emicoami_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoami
select * 
  from deivid_tmp:emicoami_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emicoami_f
where no_poliza = v_poliza_nuevo;
--********************************
delete from deivid_tmp:emiciara_f;

insert into deivid_tmp:emiciara_f
select *
  from emiciara
 where no_poliza = v_poliza;

update deivid_tmp:emiciara_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiciara
select * 
  from deivid_tmp:emiciara_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emiciara_f
where no_poliza = v_poliza_nuevo;
--*************************************
delete from deivid_tmp:emipolde_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipolde_f
select *
  from emipolde
 where no_poliza = v_poliza;

update deivid_tmp:emipolde_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolde
select * 
  from deivid_tmp:emipolde_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emipolde_f
where no_poliza = v_poliza_nuevo;
--*********************************

delete from deivid_tmp:emipouni_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipouni_f
select *
  from emipouni
 where no_poliza = v_poliza;

insert into deivid_tmp:emipouni2_f
select *
  from emipouni
 where no_poliza = v_poliza
   and perd_total = 1;
 
let _suma_prb = 0;
if _cod_rammo = '016' and _cod_subramo = '002' and _cod_grupo = '01016' then
	select sum(suma_asegurada)
	  into _suma_prb
	  from deivid_tmp:emipouni_f
	 where no_poliza = v_poliza;

	{if _suma_prb <> 51000 then
		update prueba
		   set suma_asegurada = 25000
		 where no_poliza = v_poliza
		   and no_unidad = "00001";
	end if}
		update deivid_tmp:emipouni_f
		   set prima_neta     = 0,
			   prima          = 0,
			   impuesto       = 0,
			   prima_bruta	  = 0
		 where no_poliza = v_poliza;
end if

update deivid_tmp:emipouni_f 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza
   and perd_total = 0;

insert into emipouni
select * 
  from deivid_tmp:emipouni_f
 where no_poliza = v_poliza_nuevo;

delete from deivid_tmp:emipouni_f
where no_poliza = v_poliza_nuevo;

--****ESTA NO SE CAMBIO POR EL TIPO BLOB
select * from emipode2
 where no_poliza = v_poliza
  into temp prueba;

--****ESTA NO SE CAMBIO POR EL TIPO BLOB
select * from emiredes
 where no_poliza = v_poliza
  into temp prueba3;

foreach
	select no_unidad
	  into _nounidad
	  from prueba3

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

insert into prueba
select * from prueba3;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach


if _cod_prod in ('01496','04486') and _cod_ramo = '020' then	--BOLIVARE 02/11/2022  HGIRON POOL AUTOMATICO
	if v_fecha_r >= date('02/11/2022') then  ---desde envio del correo
		FOREACH
			select descripcion
			  into _texto
			  from prddesc
			 where cod_producto = _cod_prod
			EXIT FOREACH;
		END FOREACH
							
		update prueba 
		   set no_poliza = v_poliza_nuevo,
			   descripcion = _texto
		 where no_poliza   = v_poliza;
	end if	 
else
	update prueba 
	   set no_poliza = v_poliza_nuevo
	 where no_poliza   = v_poliza;
end if
insert into emipode2
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;
drop table prueba3;
--*************************************
delete from deivid_tmp:emipoacr_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipoacr_f
select *
  from emipoacr
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emipoacr_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;
end foreach

update deivid_tmp:emipoacr_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipoacr
select * from deivid_tmp:emipoacr_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emipoacr_f
where no_poliza = v_poliza_nuevo; 
 
--**************************************
delete from deivid_tmp:emiunide_f
where no_poliza = v_poliza;

insert into deivid_tmp:emiunide_f
select *
  from emiunide
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza  = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emiunide_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;
end foreach

update deivid_tmp:emiunide_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

if _cod_prod = '00313' then	--esto segun correo de Maryelis 12/12/2018
	update deivid_tmp:emiunide_f
	   set porc_descuento = 20
	 where no_poliza   = v_poliza_nuevo
       and cod_descuen = '001';	 
end if

insert into emiunide
select * from deivid_tmp:emiunide_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emiunide_f
where no_poliza = v_poliza_nuevo;
 
--****************************************
delete from deivid_tmp:emiunire_f
where no_poliza = v_poliza;

insert into deivid_tmp:emiunire_f
select *
  from emiunire
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emiunire_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;

end foreach

update deivid_tmp:emiunire_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiunire
select * from deivid_tmp:emiunire_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emiunire_f
where no_poliza = v_poliza_nuevo; 
--************************************ 

if _cod_ramo = '008' then

	delete from deivid_tmp:emifian1_f
	where no_poliza = v_poliza;

	insert into deivid_tmp:emifian1_f
	select *
	  from emifian1
	 where no_poliza = v_poliza;

	foreach
		select no_unidad
		  into _nounidad
		  from deivid_tmp:emipouni2_f
		 where no_poliza = v_poliza
		   and perd_total = 1

		delete from deivid_tmp:emifian1_f
		 where no_poliza = v_poliza
		   and no_unidad = _nounidad;
	end foreach

	update deivid_tmp:emifian1_f
	   set no_poliza = v_poliza_nuevo
	 where no_poliza = v_poliza;

	insert into emifian1
	select * from deivid_tmp:emifian1_f
	 where no_poliza = v_poliza_nuevo;

end if
--**************************************
delete from deivid_tmp:emifigar_f
where no_poliza = v_poliza;

insert into deivid_tmp:emifigar_f
select *
  from emifigar
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emifigar_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;
end foreach

update deivid_tmp:emifigar_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emifigar
select * from deivid_tmp:emifigar_f
 where no_poliza = v_poliza_nuevo;
--********************************
delete from deivid_tmp:emiauto_f
where no_poliza = v_poliza;

insert into deivid_tmp:emiauto_f
select *
  from emiauto
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza  = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emiauto_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;

end foreach

update deivid_tmp:emiauto_f 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiauto
select * from deivid_tmp:emiauto_f
 where no_poliza = v_poliza_nuevo;

update emiauto
   set ano_tarifa = ano_tarifa + 1
 where no_poliza  = v_poliza_nuevo;

update emiauto
   set ano_tarifa = 1
 where no_poliza  = v_poliza_nuevo
   and ano_tarifa = 0;
   
delete from deivid_tmp:emiauto_f
where no_poliza = v_poliza_nuevo;

--******************************
delete from deivid_tmp:emicupol_f
where no_poliza = v_poliza;

insert into deivid_tmp:emicupol_f
select *
  from emicupol
 where no_poliza = v_poliza;
 
foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emicupol_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;

end foreach

update deivid_tmp:emicupol_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicupol
select * from deivid_tmp:emicupol_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emicupol_f
where no_poliza = v_poliza_nuevo;
 
--************************************

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
	return 2, 'No Existe Ruta de Reaseguro para esta Vigencia';  --_mensaje;
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
 
-- Insertar en emigloco ya que al renovar automático no está generando el reaseguro 

select * 
  from rearucon
 where cod_ruta = _cod_ruta
   and porc_partic_prima <> 0
   and porc_partic_suma <> 0
  into temp prueba;

insert into emigloco(
		no_poliza,
		no_endoso,
		orden,
		cod_contrato,
		cod_ruta,
		porc_partic_prima,
		porc_partic_suma,
		suma_asegurada,
		prima)
select	v_poliza_nuevo,
		'00000',
		orden,
		cod_contrato,
		cod_ruta,
		porc_partic_prima,
		porc_partic_suma,
		0,0
  from prueba;

drop table prueba;

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
			select no_unidad,
				   cod_cober_reas
			  into _no_unidad,
				   _cod_cober_reas
			  from emireaco
			 where no_poliza = v_poliza
			   and no_cambio = _no_cambio
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
elif _cod_rammo = '019' then	
else
	foreach
		select no_unidad,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  into _no_unidad,
			   _cod_cober_reas,
			   _orden,
			   _cod_contrato,
			   _porc_suma,
			   _porc_prima
		   from emireaco
		  where no_poliza = v_poliza
		    and no_cambio = _no_cambio

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
--*********************************
delete from deivid_tmp:emifafac_f
where no_poliza = v_poliza;

insert into deivid_tmp:emifafac_f
select *
  from emifafac
 where no_poliza = v_poliza;

delete from deivid_tmp:emifafac_f
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

update deivid_tmp:emifafac_f 
   set no_poliza    = v_poliza_nuevo,
       no_cesion    = null,
	   cod_contrato = _cod_cont_fac
 where no_poliza    = v_poliza;

insert into emifafac	--facultativo
select * 
  from deivid_tmp:emifafac_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emifafac_f
where no_poliza = v_poliza_nuevo;
 
--*************************************
delete from deivid_tmp:emipocob_f
where no_poliza = v_poliza;

insert into deivid_tmp:emipocob_f
select *
  from emipocob
 where no_poliza = v_poliza;

foreach
	select no_unidad
	  into _nounidad
	  from deivid_tmp:emipouni2_f
	 where no_poliza = v_poliza
	   and perd_total = 1

	delete from deivid_tmp:emipocob_f
	 where no_poliza = v_poliza
	   and no_unidad = _nounidad;
end foreach

update deivid_tmp:emipocob_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipocob
select * from deivid_tmp:emipocob_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emipocob_f
where no_poliza = v_poliza_nuevo; 
--**********************************

if _cod_rammo = '016' and _cod_subramo = '002' and _cod_grupo = '01016' then
	update emipocob
	   set prima 		= 0,
		   descuento 	= 0,
		   recargo 		= 0,
		   prima_neta 	= 0,
		   prima_anual 	= 0
	 where no_poliza 	= v_poliza_nuevo;
	 
	update emipouni
	   set prima 		= 0,
		   descuento 	= 0,
		   recargo 		= 0,
		   prima_neta 	= 0,
		   impuesto 	= 0,
		   prima_bruta 	= 0
	 where no_poliza 	= v_poliza_nuevo;

	update emipomae
	   set prima 		= 0,
		   descuento	= 0,
		   recargo 		= 0,
		   prima_neta 	= 0,
		   impuesto 	= 0,
		   prima_bruta 	= 0
	 where no_poliza 	= v_poliza_nuevo; 	 
end if
if _ramo_sis not in(1,6) then
	foreach
		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_asegurada
		  from emipouni
		 where no_poliza = v_poliza_nuevo

	    call sp_pro323(v_poliza_nuevo,_no_unidad,_suma_asegurada,'001') returning _valor;
		if _valor <> 0 then
			return _valor,_mensaje;
		end if

	    call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
		if _valor <> 0 then
			return _valor,_mensaje;
		end if
	end foreach
end if
--PROGRAMACION DEL NUEVO CALCULO DE PARA EL RAMO DE VIDA
if _ramo_sis = 6 then
	let _valor = sp_proe04_vida(v_poliza_nuevo,_no_unidad,_cod_ruta,_suma_aseg_vida,'001');
	if _valor <> 0 then
		if _valor = 341 then
			select descripcion into _mensaje from inserror
			 where tipo_error = 2
			   and code_error = 341;
		elif _valor = 342 then
			select descripcion into _mensaje from inserror
			 where tipo_error = 2
			   and code_error = 342;
		end if	
		return _valor,_mensaje;
	end if
	call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
	if _valor <> 0 then
		return _valor,_mensaje;
	end if
end if

delete from deivid_tmp:emipouni2_f
where no_poliza = v_poliza;
--************************************
delete from deivid_tmp:emibenef_f
where no_poliza = v_poliza;

insert into deivid_tmp:emibenef_f
select *
  from emibenef
 where no_poliza = v_poliza;

update deivid_tmp:emibenef_f
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emibenef
select * from deivid_tmp:emibenef_f
 where no_poliza = v_poliza_nuevo;
 
delete from deivid_tmp:emibenef_f
where no_poliza = v_poliza_nuevo; 
 
--***********************************

let _valor = 0;

--cuando es auto
if _ramo_sis = 1 then
	if _cod_rammo <> '024' then
		if _cod_rammo = '020' then
			select count(*)
			  into _cnt
			  from emipouni
			 where no_poliza = v_poliza
			   and cod_producto in('01961','02993');
			if _cnt > 0 then
				let _valor = sp_pro321c(v_poliza_nuevo,v_poliza);
			else
				let _valor = sp_pro321bk(v_poliza_nuevo,v_poliza);
			end if	
		else
			let _valor = sp_pro321c(v_poliza_nuevo,v_poliza);
			foreach -- Se incorpora ya que no estaba actualizando los valores de la unidad prima_suscrita - Amado 07/04/2017
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = v_poliza_nuevo

				call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
				
				if _valor <> 0 then
					return _valor,_mensaje;
				end if
			end foreach				
		end if
		if _valor <> 0 then
			return _valor,_mensaje;
		end if
	else
		foreach
			select no_unidad,
				   suma_asegurada
			  into _no_unidad,
				   _suma_asegurada
			  from emipouni
			 where no_poliza = v_poliza_nuevo

			call sp_pro323(v_poliza_nuevo,_no_unidad,_suma_asegurada,'001') returning _valor;
			if _valor <> 0 then
				return _valor,_mensaje;
			end if

			call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
			if _valor <> 0 then
				return _valor,_mensaje;
			end if
		end foreach	
	end if
end if
foreach
	select no_unidad,
		   suma_asegurada
	  into _no_unidad,
		   _suma
	  from emipouni
	 where no_poliza = v_poliza_nuevo

	update emipoacr
	   set limite = _suma
	 where no_poliza = v_poliza_nuevo
	   and no_unidad = _no_unidad;
end foreach

call sp_proe03(v_poliza_nuevo,'001') returning _valor;

--Proceso de Carga de archivo de texto de Ducruet
call sp_pro371(v_poliza_nuevo) returning _valor,_mensaje;

--verificacion de primas
call sp_sis25(v_poliza_nuevo) returning _valor,_mensaje;

return _valor,_mensaje;
end
end procedure;