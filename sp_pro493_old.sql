--- Inclusion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

--drop table prueba;

{
drop procedure sp_victor;

create procedure "informix".sp_victor(
v_poliza char(10), 
v_endoso char(5), 
v_factor decimal(9,6)
)
--}
--{
drop procedure sp_pro493;

create procedure "informix".sp_pro493(
v_poliza char(10), 
v_endoso char(5), 
v_factor decimal(9,6))
--}

RETURNING SMALLINT, CHAR(30);

DEFINE   v_unidad          CHAR(5);
DEFINE   v_unidades        CHAR(5);
DEFINE   r_error           SMALLINT;
DEFINE   v_orden		   SMALLINT;
DEFINE   _cant             SMALLINT;
DEFINE   _cant1            SMALLINT;
DEFINE   r_descripcion     CHAR(30);
DEFINE   v_prima_suscrita  DECIMAL(16,2);
DEFINE   v_prima_retenida  DECIMAL(16,2);
DEFINE   v_descto          DECIMAL(5,2);
DEFINE   r_signo           DECIMAL(9,2);
DEFINE   v_factores        DECIMAL(9,4);
DEFINE   v_producto        CHAR(5);
DEFINE   v_tipocalc        CHAR(3);
DEFINE   v_cod_mov         CHAR(3);
DEFINE   v_cober_reas      CHAR(3);
DEFINE   v_tipo_mov	       SMALLINT;
DEFINE   v_tot_saldo       DECIMAL(16,2);
DEFINE   v_prima_total     DECIMAL(16,2);
DEFINE   r_prima_anual     DECIMAL(16,2);
DEFINE   v_prima           DECIMAL(16,2);
DEFINE   r_prima_neta      DECIMAL(16,2);
DEFINE   r_descuento       DECIMAL(16,2);
DEFINE   _descuento        DECIMAL(16,2);
DEFINE   r_recargo         DECIMAL(16,2);
DEFINE   v_saldo           DECIMAL(16,2);
DEFINE   v_prima_cob       DECIMAL(16,2);
DEFINE   v_acepta          SMALLINT;
DEFINE   v_suma_asegurada  DECIMAL(16,2);
DEFINE   v_descuento       DECIMAL(16,2);
DEFINE   v_recargo         DECIMAL(16,2);
DEFINE   v_impuesto        DECIMAL(16,4);
DEFINE   v_cober_total     DECIMAL(16,2);
DEFINE   v_cobertura       CHAR(5);
DEFINE   v_contrato        CHAR(5);
DEFINE   v_coasegur        CHAR(3);
DEFINE   v_impto           DECIMAL(9,6);
DEFINE   v_partic_suma     DECIMAl(9,6);
DEFINE   v_partic_prima    DECIMAL(9,6);
DEFINE   v_partic_reas     DECIMAL(9,6);
DEFINE   r_prima_cober     DECIMAL(16,2);
DEFINE   r_prima_unidad    DECIMAL(16,2);
DEFINE   v_prima_bruta     DECIMAL(16,2);
DEFINE   v_porc_descto     DECIMAL(16,4);
DEFINE   v_tot_descto      DECIMAL(16,2);
DEFINE   v_tot_recargo     DECIMAL(16,2);
DEFINE   v_prima_reaseguro DECIMAL(16,2);
DEFINE   v_suma_reaseguro  DECIMAL(16,2);
DEFINE   v_prima_reas      DECIMAL(16,2);
DEFINE   v_suma_reas       DECIMAL(16,2);
DEFINE   v_tot_bruta       DECIMAL(16,2);
DEFINE   _tot_reaseguro    DECIMAL(16,2);
DEFINE   _cober            CHAR(5);
DEFINE 	 _tipo_produccion  SMALLINT;
DEFINE 	 _porc_coas        DEC(16,4);
DEFINE   _cod_compania     CHAR(3);
DEFINE   _cod_coasegur     CHAR(3);
DEFINE   _cod_ramo         CHAR(3);
DEFINE   _ramo_sis,_no_cambio SMALLINT;
DEFINE   _prima_salud      DEC(16,2);
DEFINE   _neta             DEC(16,2);
DEFINE   _acepta_descuento SMALLINT;

BEGIN

ON EXCEPTION SET r_error 
 	RETURN r_error, 'Error al Realizar el Calculo';         
END EXCEPTION           

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_pro493.trc";  
--TRACE ON;                                                                 

-- Let v_factor = v_factor * -1;

-- Verificaciones para Coaseguro Mayoritario

SELECT t.tipo_produccion,
	   p.cod_compania,
	   p.cod_ramo	
  INTO _tipo_produccion,
	   _cod_compania,
	   _cod_ramo	
  FROM emipomae	p, emitipro t
 WHERE p.no_poliza    = v_poliza
   AND p.cod_tipoprod = t.cod_tipoprod;

SELECT ramo_sis
  INTO _ramo_sis
  FROM prdramo
 WHERE cod_ramo = _cod_ramo;

IF _tipo_produccion = 2 THEN

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = _cod_compania;

	SELECT porc_partic_coas
	  INTO _porc_coas
	  FROM emicoama
	 WHERE no_poliza    = v_poliza
	   AND cod_coasegur = _cod_coasegur;
ELSE
	LET _porc_coas = 100;
END IF

------------------------
-- Cargar las Unidades
------------------------

delete from endcobde
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endcobre
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedcob
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from emifafac
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from emifacon
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endunide
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endunire
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

create temp table prue(
   no_poliza         CHAR(10),
   no_endoso	     CHAR(5),
   no_unidad	     CHAR(5),
   descripcion       TEXT
   ) with no log;

insert into prue 
select * from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedacr
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

Insert into endeduni
select v_poliza, v_endoso, no_unidad, cod_ruta, cod_producto, cod_asegurado, suma_asegurada,
       prima, descuento, recargo, prima_neta, impuesto, prima_bruta, reasegurada, vigencia_inic,
       vigencia_final, beneficio_max, desc_unidad, prima_suscrita, prima_retenida
  from emipouni
 where no_poliza = v_poliza;

insert into endedde2
select * from prue
 where no_poliza = v_poliza
   and no_endoso = v_endoso;
drop table prue;

if v_factor >= 0 Then
   let r_signo = 1;
else
   let r_signo = -1;
end if

select cod_tipocalc, cod_endomov Into v_tipocalc, v_cod_mov
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

if v_tipocalc = "004" Then
   select prima_bruta, saldo into v_prima_bruta, v_saldo
     from emipomae
    where no_poliza = v_poliza;

   select Sum(y.factor_impuesto) Into v_impuesto From emipolim x, prdimpue y
    where x.no_poliza    = v_poliza
  	  and x.cod_impuesto = y.cod_impuesto
	  and y.pagado_por   = "C";

   if v_impuesto is null then
      let v_impuesto = 0.00;
   end if

   let v_impuesto = v_impuesto + 100.00;

   LET _prima_salud = v_saldo / (v_impuesto / 100);	

   select tipo_mov Into v_tipo_mov
     from endtimov
    where cod_endomov = v_cod_mov;

   if v_tipo_mov = "3" Then
      let r_signo = 1;
   end if

   IF _ramo_sis = 5 THEN
   	  let v_factor = 1 * r_signo;
   ELSE
	  let v_factor = (v_saldo / v_prima_bruta) * r_signo;
   END IF

end if 

if v_tipocalc = "005" Then
   let v_saldo  = 0.00;
   let v_factor = 0.00;
end if
if v_tipocalc = "006" Then
   select prima_neta Into v_saldo
     from endedmae
    where no_poliza = v_poliza
      and no_endoso = v_endoso;

   select prima_neta into v_prima_bruta
     from emipomae
    where no_poliza = v_poliza;

   select tipo_mov Into v_tipo_mov
     from endtimov
    where cod_endomov = v_cod_mov;
   if v_tipo_mov = "3" Or v_tipo_mov = "1" Then
      let r_signo = 1;
   end if

   if r_signo < 0 then
	  let v_factor = (v_saldo / v_prima_bruta);
   else
	  let v_factor = (v_saldo / v_prima_bruta) * r_signo;
   end if
end if

foreach 
   select no_unidad, 
   		  cod_producto, 
   		  prima, 
   		  suma_asegurada
     Into v_unidad, 
          v_producto, 
          r_prima_unidad, 
          v_suma_asegurada
     from endeduni
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso
--	  and no_unidad   = '00057'
	  	
	-- Pasar los descuentos de la unidad de la poliza al endoso

	delete from endunide
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso
	   and no_unidad = v_unidad;

	insert into endunide
	select no_poliza, v_endoso, no_unidad, cod_descuen, porc_descuento
	  from emiunide
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	-- Cargar Reaseguros Individuales

	create temp table prueba(
	       no_poliza         CHAR(10),
		   no_endoso	     CHAR(5),
		   no_unidad	     CHAR(5),
		   cod_cober_reas    CHAR(3),
		   orden		     SMALLINT,
		   cod_contrato	     CHAR(5),
		   cod_ruta		     CHAR(5),
		   porc_partic_suma	 DECIMAL(9,6),
		   porc_partic_prima DECIMAL(9,6),
		   suma_asegurada	 DECIMAL(16,2) default 0,
		   prima			 DECIMAL(16,2) default 0
		   ) with no log;

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = v_poliza;

	insert into prueba(
	no_poliza,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	)
    select 
    no_poliza,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
    from emireaco
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad
	   and no_cambio = _no_cambio
   	   and (porc_partic_suma > 0.00 Or 
   	       porc_partic_prima > 0.00);

	update prueba
	   set no_endoso = v_endoso
	 Where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	insert into emifacon(
	no_poliza,        
	no_endoso,	    
	no_unidad,	    
	cod_cober_reas,   
	orden,		    
	cod_contrato,	    
	cod_ruta,		    
	porc_partic_suma,	
	porc_partic_prima,
	suma_asegurada,	
	prima			
	)
	select 
	no_poliza,        
	no_endoso,	    
	no_unidad,	    
	cod_cober_reas,   
	orden,		    
	cod_contrato,	  
	cod_ruta,		  
	porc_partic_suma,	
	porc_partic_prima,
	suma_asegurada,	
	prima			
	from prueba
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	drop table prueba;

	--  Cargar Reaseguros Facultativos

	create temp table prueba(
	       no_poliza         CHAR(10),
		   no_endoso	     CHAR(5),
		   no_unidad	     CHAR(5),
		   cod_cober_reas    CHAR(3),
		   orden		     SMALLINT,
		   cod_contrato	     CHAR(5),
		   cod_coasegur	     CHAR(3),
		   porc_partic_reas	 DECIMAL(9,6),
		   porc_comis_fac    DECIMAL(5,2),
		   porc_impuesto	 DECIMAL(5,2),
		   suma_asegurada	 DECIMAL(16,2) default 0,
		   prima			 DECIMAL(16,2) default 0,
		   impreso           SMALLINT default 0,
		   fecha_impresion   DATE default today,
		   no_cesion         CHAR(10) default null
		   ) with no log;

	insert into prueba(
	no_poliza,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	)
    select 
    no_poliza,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
    from emireafa
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad
	   and no_cambio = _no_cambio;

    update prueba
       set no_endoso = v_endoso
     where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	insert into emifafac
	select * from prueba
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	  drop table prueba;

	-- Pasar los recargos de la unidad de la poliza al endoso

	delete from endunire
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso
	   and no_unidad = v_unidad;

	insert into endunire
	select no_poliza, v_endoso, no_unidad, cod_recargo, porc_recargo
	  from emiunire
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	-- Cargar las coberturas

	delete from endedcob
	 where no_poliza   = v_poliza
	   and no_endoso   = v_endoso
	   and no_unidad   = v_unidad;

	Insert Into endedcob
	select v_poliza, v_endoso, v_unidad, cod_cobertura, orden, 0.00, deducible,
	  	   limite_1, limite_2, prima_anual, prima, descuento, recargo, prima_neta,
	       Current, Current, desc_limite1, desc_limite2, v_factor, 0
	  from emipocob	
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	IF _ramo_sis = 5 THEN
		IF v_tipocalc = "004" Then
			UPDATE endedcob
			   SET prima_anual = _prima_salud,
			       prima_neta  = _prima_salud,
				   prima       = _prima_salud
			 WHERE no_poliza   = v_poliza
			   AND no_unidad   = v_unidad
			   AND prima_neta  <> 0.00;

		END IF
	END IF

   foreach
      select x.cod_cobertura, 
             x.prima_anual, 
             x.prima
        into v_cobertura, 
             r_prima_anual, 
             v_prima
        from endedcob x
       where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad

	  if v_tipocalc = "005" Or v_tipocalc = "006" Then

	     update endedcob
	        set endedcob.prima_anual   = endedcob.prima_anual * r_signo, -- * v_factor,
	            endedcob.prima         = endedcob.prima * v_factor,
	            endedcob.descuento     = ((endedcob.descuento * v_factor) * -1),
	            endedcob.recargo       = endedcob.recargo * v_factor,
	            endedcob.prima_neta    = endedcob.prima_neta * v_factor
	      where endedcob.no_poliza     = v_poliza
	        and endedcob.no_endoso     = v_endoso
	        and endedcob.no_unidad     = v_unidad
	        and endedcob.cod_cobertura = v_cobertura;

	  elif v_tipocalc = "001" Then 	
			
			SELECT acepta_desc
			  INTO _acepta_descuento
			  FROM prdcobpd
			 WHERE cod_producto  = v_producto
			   AND cod_cobertura = v_cobertura;

			LET v_prima      = r_prima_anual * v_factor;
			LET r_prima_neta = v_prima;

			IF _acepta_descuento = 1 THEN

				LET r_descuento = 0;
				LET r_recargo   = 0;

			   FOREACH	
				SELECT (u.porc_descuento / 100),
				       d.orden
				  INTO v_porc_descto,
				       v_orden 
				  FROM endunide u, emidescu d
				 WHERE u.no_poliza   = v_poliza
				   AND u.no_endoso   = v_endoso
				   AND u.no_unidad   = v_unidad
				   AND u.cod_descuen = d.cod_descuen
				 ORDER BY d.orden

					LET r_descuento  = r_descuento + (r_prima_neta * v_porc_descto);
					LET r_prima_neta = r_prima_neta - (r_prima_neta * v_porc_descto);

				END FOREACH

				SELECT SUM(u.porc_recargo / 100)
				  INTO v_porc_descto 
				  FROM endunire u
				 WHERE u.no_poliza = v_poliza
				   AND u.no_endoso = v_endoso
				   AND u.no_unidad = v_unidad;

				IF v_porc_descto IS NULL THEN
					LET v_porc_descto = 0;
				END IF

				LET r_recargo    = r_prima_neta * v_porc_descto;
				LET r_prima_neta = r_prima_neta + (r_prima_neta * v_porc_descto);

			ELSE
				
				LET r_descuento  = 0;
				LET r_recargo    = 0;
				LET r_prima_neta = v_prima;

			END IF

			update endedcob
			   set endedcob.prima_anual   = endedcob.prima_anual * r_signo,
			       endedcob.prima         = v_prima,
			       endedcob.descuento     = r_descuento * -1,
			       endedcob.recargo       = r_recargo,
			       endedcob.prima_neta    = r_prima_neta
			 where endedcob.no_poliza     = v_poliza
			   and endedcob.no_endoso     = v_endoso
			   and endedcob.no_unidad     = v_unidad
			   and endedcob.cod_cobertura = v_cobertura;

	  else

	     update endedcob
	        set endedcob.prima_anual   = endedcob.prima_anual * r_signo, -- * v_factor,
	            endedcob.prima         = endedcob.prima * v_factor,
	            endedcob.descuento     = ((endedcob.descuento * v_factor) * -1),
	            endedcob.recargo       = endedcob.recargo * v_factor,
	            endedcob.prima_neta    = endedcob.prima_neta * v_factor
	      where endedcob.no_poliza     = v_poliza
	        and endedcob.no_endoso     = v_endoso
	        and endedcob.no_unidad     = v_unidad
	        and endedcob.cod_cobertura = v_cobertura;

	  end if

   end foreach

   select tipo_mov Into v_tipo_mov
     from endtimov
    where cod_endomov = v_cod_mov;

   if v_tipo_mov = "1" Or v_tipo_mov = "19" Then
      update endedcob
         set endedcob.limite_1    = 0.00,
	         endedcob.limite_2    = 0.00,
	         endedcob.deducible   = 0.00
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad;

      update endeduni
         set endeduni.suma_asegurada = 0.00
       where endeduni.no_poliza   = v_poliza
         and endeduni.no_endoso   = v_endoso;

	  let v_suma_asegurada = 0.00;
   end if

   if v_tipo_mov = "1" Or v_tipo_mov = "3" Then 
	  Select sum(endedcob.descuento) into _descuento from endedcob
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad;
	  if _descuento > 0 Then
	     Update endedcob
	        Set endedcob.descuento   = endedcob.descuento * -1
	      Where endedcob.no_poliza   = v_poliza
	        and endedcob.no_endoso   = v_endoso
	        and endedcob.no_unidad   = v_unidad;
	  end if
   end if

   if v_tipo_mov = "2" Or v_tipo_mov = "19" Then 
	  Select sum(endedcob.descuento) into _descuento from endedcob
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad;
	  if _descuento < 0 Then
	     Update endedcob
	        Set endedcob.descuento   = endedcob.descuento * -1
	      Where endedcob.no_poliza   = v_poliza
	        and endedcob.no_endoso   = v_endoso
	        and endedcob.no_unidad   = v_unidad;
	  end if
   end if

   select sum(x.prima), sum(x.prima), SUM(x.descuento), SUM(x.recargo), SUM(x.prima_neta)
     into r_prima_anual, r_prima_cober, v_tot_descto, v_tot_recargo, r_prima_neta
     from endedcob x
    where x.no_poliza   = v_poliza
      and x.no_endoso   = v_endoso
      and x.no_unidad   = v_unidad;

   -- Calcular el impuesto de la unidad

   let v_impuesto = 0.00;

   Select x.tiene_impuesto Into v_impto From endedmae x
    Where x.no_poliza    = v_poliza
      And x.no_endoso    = v_endoso;

   If v_impto = 1 Then

      select Sum(y.factor_impuesto) Into v_impuesto From emipolim x, prdimpue y
	   where x.no_poliza    = v_poliza
  	     and x.cod_impuesto = y.cod_impuesto
	     and y.pagado_por   = "C";

	  if v_impuesto > 0.00 then
	     let v_impuesto = (r_prima_neta * v_impuesto) / 100;
	  else
	     let v_impuesto = 0.00;
	  end if
   End If

   let v_prima_bruta = r_prima_neta + v_impuesto;

   let _neta = r_prima_neta;
   if _neta < 0.00 Then
      let _neta = _neta * -1;
   end if

   let _neta = (_neta * _porc_coas) / 100;

   foreach
      select x.cod_cober_reas, x.orden, x.cod_contrato, x.porc_partic_suma, x.porc_partic_prima
        into v_cober_reas, v_orden, v_contrato, v_partic_suma, v_partic_prima
        from emifacon x
       where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad
--	   order by 1, 2

      select SUM(x.prima_neta) into r_prima_cober
        from prdcober y, endedcob x
       Where x.no_poliza      = v_poliza
         and x.no_endoso      = v_endoso
         and x.no_unidad      = v_unidad
         and x.cod_cobertura  = y.cod_cobertura
         and y.cod_cober_reas = v_cober_reas;

      LET v_prima_reaseguro = (v_partic_prima * r_prima_cober)    / 100; 
      LET v_suma_reaseguro  = (v_partic_suma  * v_suma_asegurada) / 100;

	  LET v_prima_reaseguro =  v_prima_reaseguro * _porc_coas / 100;	
	  LET v_suma_reaseguro  =  v_suma_reaseguro  * _porc_coas / 100;	

	  If v_prima_reaseguro is null Then
	     let v_prima_reaseguro = 0.00;
	  End If
	  If v_suma_reaseguro is null Then
	     let v_suma_reaseguro = 0.00;
	  End If

      update emifacon
	     set emifacon.prima          = v_prima_reaseguro,
		     emifacon.suma_asegurada = v_suma_reaseguro * r_signo
       where emifacon.no_poliza      = v_poliza
         and emifacon.no_endoso      = v_endoso
         and emifacon.no_unidad      = v_unidad
         and emifacon.cod_cober_reas = v_cober_reas
         and emifacon.orden          = v_orden;

	  foreach
	    select x.cod_coasegur, x.porc_partic_reas
	      into v_coasegur, v_partic_reas
	      from emifafac x
	     where x.no_poliza      = v_poliza
	       and x.no_endoso      = v_endoso
	       and x.no_unidad      = v_unidad
	       and x.cod_cober_reas = v_cober_reas
	       and x.orden          = v_orden
	       and x.cod_contrato   = v_contrato

	    LET v_prima_reas = (v_partic_reas * v_prima_reaseguro) / 100; 
	    LET v_suma_reas  = (v_partic_reas * v_suma_reaseguro) / 100;

		If v_prima_reas is null Then
		   let v_prima_reas = 0.00;
	    End If
		If v_suma_reas is null Then
		   let v_suma_reas = 0.00;
	    End If

	    update emifafac
	       set emifafac.prima          = v_prima_reas,
	           emifafac.suma_asegurada = v_suma_reas * r_signo
	     where emifafac.no_poliza      = v_poliza
	       and emifafac.no_endoso      = v_endoso
	       and emifafac.no_unidad      = v_unidad
	       and emifafac.cod_cober_reas = v_cober_reas
	       and emifafac.orden          = v_orden
		   and emifafac.cod_contrato   = v_contrato
		   and emifafac.cod_coasegur   = v_coasegur;

	  end foreach
   end foreach

   select sum(emifacon.prima) into v_prima_suscrita
     from emifacon
    where emifacon.no_poliza   = v_poliza
      and emifacon.no_endoso   = v_endoso
      and emifacon.no_unidad   = v_unidad;
   if v_prima_suscrita is null Then
      let v_prima_suscrita = 0.00;
   end if

   Let _tot_reaseguro = v_prima_suscrita;
   if _tot_reaseguro <> _neta Then
      let v_prima_suscrita = _neta;
      if _tot_reaseguro < 0 Then
         let _neta = _neta + _tot_reaseguro;
      else
         let _neta = _neta - _tot_reaseguro;
      end if
      update emifacon
         set emifacon.prima          = emifacon.prima + _neta
       where emifacon.no_poliza      = v_poliza
         and emifacon.no_endoso      = v_endoso
         and emifacon.no_unidad      = v_unidad
         and emifacon.cod_cober_reas = v_cober_reas
         and emifacon.orden          = v_orden;

      if r_signo < 0.00 and v_prima_suscrita > 0.00 Then
	     let v_prima_suscrita = v_prima_suscrita * -1;
	  end if
   end if

   select sum(emifacon.prima) into v_prima_retenida
     from emifacon, reacomae
    where emifacon.no_poliza     = v_poliza
      and emifacon.no_endoso     = v_endoso
      and emifacon.no_unidad     = v_unidad
      and emifacon.cod_contrato  = reacomae.cod_contrato
      and reacomae.tipo_contrato = "1";

   if v_prima_retenida is null Then
      let v_prima_retenida = 0.00;
   end if

   update endeduni
      set endeduni.prima          = r_prima_anual,
          endeduni.descuento      = v_tot_descto,
          endeduni.recargo        = v_tot_recargo,
          endeduni.prima_neta     = r_prima_neta,
          endeduni.impuesto       = v_impuesto,
          endeduni.prima_bruta    = v_prima_bruta,
          endeduni.prima_suscrita = v_prima_suscrita,
          endeduni.prima_retenida = v_prima_retenida,
          endeduni.suma_asegurada = v_suma_asegurada * r_signo
    where endeduni.no_poliza      = v_poliza
      and endeduni.no_endoso      = v_endoso
      and endeduni.no_unidad      = v_unidad;

end foreach

--trace off;

RETURN r_error, r_descripcion  WITH RESUME;

END

end procedure;