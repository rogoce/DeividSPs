--****************************************************************
-- Procedimiento que Realiza la Renovacion Automatica de la Poliza
--****************************************************************
-- se copio del sp_pro281()
-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- Modificado: 28/04/2009 - Autor: Armando Moreno M.

drop procedure sp_pro320;

create procedure "informix".sp_pro320(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10)) RETURNING INTEGER;

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
define _cod_ramo       char(3);
define _ramo_sis       smallint;
define _nounidad       char(5);
define _valor          integer;
define _error          integer;
define _serie          integer;
define _cod_ruta       char(5);
define _orden          integer;
define _cod_contrato   char(5);
define _porc_prima     DEC(10,4);
define _porc_suma      DEC(10,4);
define _cod_cober_reas char(3);
define _tipo_contrato  char(1);
DEFINE _suma           DEC(16,2);
define _no_cambio      smallint;
define _cod_prod       char(5);
define _r_anos         smallint;
define _cod_subramo    char(3);
define _tipo_agente    char(1);
define _aplica_imp     smallint;
define _cod_impuesto   char(3);
define _cod_origen     char(3);
define _canti          smallint;
define _cod_cont_fac   char(5);
define _fronting       smallint;
define _fronting2	   smallint;

--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;

update emipomae
   set renovada    = 1,
       fecha_renov = CURRENT
 where no_poliza   = v_poliza;

let _valor = 0;

select * 
  from emipomae
 where no_poliza = v_poliza
  into temp prueba;

Let r_anos = 0;
let _saldo_unidad = 0;

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
	   saldo_por_unidad  = _saldo_unidad
 where no_poliza         = v_poliza;

insert into emipomae
select * from prueba
 where no_poliza = v_poliza_nuevo;

SELECT fecha_primer_pago,
       no_pagos,
	   cod_perpago,
	   cod_ramo,
	   cod_subramo,
	   cod_origen
  INTO ld_fecha_1_pago,
       li_no_pagos,
	   ls_cod_perpago,
	   _cod_ramo,
	   _cod_subramo,
	   _cod_origen
  FROM emipomae
 where no_poliza = v_poliza_nuevo;

if _cod_origen is null then
	let _cod_origen = '001';
end if

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

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
       cod_subramo
  into _r_anos,
       _cod_subramo
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

	select cod_agente
	  into _cod_agt
	  from prueba

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agt;

	if _cod_rammo <> "019" then

		CALL sp_pro305(_cod_agt,_cod_rammo,_cod_subramo) RETURNING _porc_com;

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

		foreach
			Select cod_impuesto
			  into _cod_impuesto
			  From prdimsub
			 Where cod_ramo    = _cod_ramo
			   And cod_subramo = _cod_subramo

			Insert Into emipolim (no_poliza, cod_impuesto, monto)
			Values (v_poliza_nuevo,_cod_impuesto, 0.00);

		end foreach

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

select * from emipode2
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipode2
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipoacr
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipoacr
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emiunide
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunide
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiunire
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunire
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emifian1
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifian1
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emifigar
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifigar
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiauto
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

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

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicupol
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

--buscar ruta
select serie,cod_ramo
  into _serie,_cod_ramo
  from emipomae
 where no_poliza = v_poliza_nuevo;

foreach

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where serie    = _serie
	   and cod_ramo = _cod_ramo
	   and activo   = 1

	exit foreach;

end foreach

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = v_poliza;

update emipouni
   set cod_ruta = _cod_ruta
where no_poliza = v_poliza_nuevo;

FOREACH

	 Select no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
	   Into _no_unidad,
	        _cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_suma,
			_porc_prima
	   From emireaco
	  Where no_poliza = v_poliza
	    and no_cambio = _no_cambio

		let _fronting  = 0;
		let _fronting2 = 0;

	  select tipo_contrato,
	         fronting
	    into _tipo_contrato,
		     _fronting
	    from reacomae
	   where cod_contrato = _cod_contrato;

	 { foreach
			select cod_contrato
			  into _cod_contrato2
			  from rearucon
			 where cod_ruta = _cod_ruta}

		 foreach
			  select cod_contrato
			    into _cod_contrato
				from reacomae
			   where tipo_contrato = _tipo_contrato
			     and serie         = _serie
				 and fronting      = _fronting

			  exit foreach;

		 end foreach

--	  end foreach

{	  foreach

		  select cod_contrato,
		         fronting
		    into _cod_contrato,
			     _fronting2
			from reacomae
		   where tipo_contrato = _tipo_contrato
		     and serie         = _serie

		  if _fronting = 1 then
		  	if _fronting2 = 1 then
			else
				continue foreach;
			end if
		  else
		  	if _fronting2 = 0 then
			else
				continue foreach;
			end if
		  end if

		  exit foreach;

	  end foreach  	}

	Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
	Values (v_poliza_nuevo, "00000",_no_unidad,_cod_cober_reas,_orden,_cod_contrato,_cod_ruta,_porc_prima,_porc_suma,0.00, 0.00);

END FOREACH

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

select * 
  from emipocob
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipocob
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

if _ramo_sis <> 1 then
	foreach

		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_asegurada
		  from emipouni
		 where no_poliza = v_poliza_nuevo

	    call sp_pro323(v_poliza_nuevo,_no_unidad,_suma_asegurada,'001') returning _valor;
		if _valor <> 0 then
			return _valor;
		end if

	    call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
		if _valor <> 0 then
			return _valor;
		end if

	end foreach
end if

select * from emicobde
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

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

let _valor = 0;

--cuando es auto

if _ramo_sis = 1 then

	let _valor = sp_pro321(v_poliza_nuevo,v_poliza);
	if _valor <> 0 then
		return _valor;
	end if

end if

foreach
  SELECT no_unidad,
		 suma_asegurada
	INTO _no_unidad,
		 _suma
    FROM emipouni
   WHERE no_poliza = v_poliza_nuevo

  update emipoacr
     set limite = _suma
   where no_poliza = v_poliza_nuevo
     and no_unidad = _no_unidad;

end foreach

call sp_proe03(v_poliza_nuevo,'001') returning _valor;

RETURN _valor;
END

end procedure;