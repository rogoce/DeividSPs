-- Procedimiento que Realiza la Renovacion de la Poliza

-- Creado    : 04/12/2000 - Autor: Victor Molinar  
-- Modificado: 18/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_ren_sel_de_pol_a_ren - DEIVID, S.A.
--
-- 18/05/2001 Se Incluyo el porcentaje de depreciacion de forma automatica (Demetrio)

drop procedure sp_pro281;
create procedure "informix".sp_pro281(v_usuario Char(8), v_poliza char(10), v_poliza_nuevo char(10))

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

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro281.trc"; 

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

select x.anos_pagador 
  Into r_anos 
  from prueba x
 where x.no_poliza    = v_poliza;

If r_anos > 0 Then
   LET r_anos = r_anos - 1;
Else
   LET r_anos = 0;
End If

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
       vigencia_final    = vigencia_final + 1 UNITS YEAR,
       fecha_ult_pago    = NULL,
       saldo             = 0
 where no_poliza         = v_poliza;

insert into emipomae
select * from prueba
 where no_poliza = v_poliza_nuevo;

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

select * 
  from emipoagt
 where no_poliza = v_poliza
  into temp prueba;

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

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipouni
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipode2
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipode2
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emipoacr
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipoacr
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emiunide
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunide
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiunire
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunire
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emifian1
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifian1
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emifigar
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifigar
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiauto
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiauto
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emicupol
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicupol
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emipocob
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipocob
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emicobde
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicobde
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

delete from emirepol
where no_poliza = v_poliza;

-- Calculo de la Depreciacion

SELECT porc_depreciacion
  INTO _porc_depre_pol
  FROM emirepol
 WHERE no_poliza = v_poliza;

IF _porc_depre_pol <> 0.00 THEN

	FOREACH
	 SELECT no_unidad,
			cod_producto
	   INTO _no_unidad,
			_cod_producto
	   FROM emipouni
	  WHERE no_poliza = v_poliza_nuevo

		SELECT porc_depreciacion
		  INTO _porc_depre_uni
		  FROM emirepod
		 WHERE no_poliza = v_poliza
		   AND no_unidad = _no_unidad;
			
		IF _porc_depre_uni = 0.00 THEN  
			LET _porc_depre = _porc_depre_pol;
		ELSE
			LET _porc_depre = _porc_depre_uni;
		END IF

		UPDATE emipouni
		   SET suma_asegurada = suma_asegurada * (1 - _porc_depre/100)
		 WHERE no_poliza      = v_poliza_nuevo
		   AND no_unidad      = _no_unidad;

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
				   SET limite_1      = limite_1 * (1 - _porc_depre/100)
				 WHERE no_poliza     = v_poliza_nuevo
				   AND no_unidad     = _no_unidad
				   AND cod_cobertura = _cod_cobertura;

			END IF

		END FOREACH

	END FOREACH

END IF

END

end procedure;
