--- Inclusion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

--drop procedure sp_pro493bkk;

create procedure "informix".sp_pro493bkk(
v_poliza char(10),
v_endoso char(5),
v_factor dec(9,6))
returning smallint, char(30);

define r_descripcion		char(30);
define _no_documento		char(20);
define _cod_manzana			char(15);
define v_cobertura			char(5);
define v_unidades			char(5);
define v_producto			char(5);
define v_contrato			char(5);
define v_unidad				char(5);
define _cober				char(5);
define _cod_impuesto_i		char(3);
define _cod_subramo_i		char(3);
define _cod_origen_i		char(3); 
define _cod_compania		char(3);
define _cod_coasegur		char(3);
define _cod_impuesto		char(3);
define v_cober_reas			char(3);
define _cod_ramo_i			char(3);
define v_tipocalc			char(3);
define v_coasegur			char(3);
define v_cod_mov			char(3);
define _cod_ramo			char(3);
define v_descto				dec(5,2);
define r_signo				dec(9,2);
define v_factores			dec(9,4);
define v_partic_prima		dec(9,6);
define v_partic_reas		dec(9,6);
define v_partic_suma		dec(9,6);
define _porct_imp_i			dec(9,6);
define v_impto				dec(9,6);
define _factor_impuesto		dec(5,2);
define v_porc_descto		dec(16,4);
define v_impuesto			dec(16,4);
define _porc_coas			dec(16,4);
define v_prima_reaseguro	dec(16,2);
define v_suma_reaseguro		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_retenida		dec(16,2);
define r_prima_unidad		dec(16,2);
define _tot_reaseguro		dec(16,2);
define v_prima_bruta		dec(16,2);
define r_prima_cober		dec(16,2);
define v_tot_recargo		dec(16,2);
define v_cober_total		dec(16,2);
define v_prima_total		dec(16,2);
define r_prima_anual		dec(16,2);
define v_prima_reas			dec(16,2);
define v_tot_descto			dec(16,2);
define _prima_salud			dec(16,2);
define r_prima_neta			dec(16,2);
define v_tot_bruta			dec(16,2);
define v_suma_reas			dec(16,2);
define _prima_neta			dec(16,2);
define r_descuento			dec(16,2);
define v_tot_saldo			dec(16,2);
define v_prima_cob			dec(16,2);
define v_descuento			dec(16,2);
define _descuento			dec(16,2);
define v_recargo			dec(16,2);
define r_recargo			dec(16,2);
define _sum_imp				dec(16,2);
define v_prima				dec(16,2);
define v_saldo				dec(16,2);
define _gastos				dec(16,2);
define _neta				dec(16,2);
define _acepta_descuento	smallint;
define _tipo_produccion		smallint;
define _tiene_impuesto		smallint;
define _tipo_incendio		smallint;
define _aplica_imp_i		smallint;
define _existe_imp_i		smallint;
define _impuesto_tot		smallint;
define v_tipo_mov			smallint;
define _no_cambio			smallint;
define v_acepta				smallint;
define _ramo_sis			smallint;
define _canti_i				smallint;
define _end_imp				smallint;
define _cnt_cober			smallint;
define v_orden				smallint;
define r_error				smallint;
define _cant1				smallint;
define _cant				smallint;

begin
on exception set r_error
 	return r_error, 'Error al Realizar el Calculo';
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro493.trc";
--trace on;

-- let v_factor = v_factor * -1;

-- verificaciones para coaseguro mayoritario
select t.tipo_produccion,
	   p.cod_compania,
	   p.cod_ramo
  into _tipo_produccion,
	   _cod_compania,
	   _cod_ramo
  from emipomae	p, emitipro t
 where p.no_poliza    = v_poliza
   and p.cod_tipoprod = t.cod_tipoprod;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
if _ramo_sis = 8 then --multiriesgo debe llevar contenido
	let _tipo_incendio = 2;
else
	let _tipo_incendio = null;
end if

if _tipo_produccion = 2 then
	select par_ase_lider
	  into _cod_coasegur
	  from parparam
	 where cod_compania = _cod_compania;

	select porc_partic_coas
	  into _porc_coas
	  from emicoama
	 where no_poliza    = v_poliza
	   and cod_coasegur = _cod_coasegur;
else
	let _porc_coas = 100;
end if

------------------------
-- Cargar las Unidades
------------------------
create temp table prue(
   no_poliza         char(10),
   no_endoso	     char(5),
   no_unidad	     char(5),
   descripcion       text
   ) with no log;

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

delete from endcuend
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

select *
  from endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso
  into temp tmp_endmoaut;

delete from endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

insert into endeduni(
	   no_poliza, 
	   no_endoso, 
	   no_unidad, 
	   cod_ruta, 
	   cod_producto, 
	   cod_cliente, 
	   suma_asegurada,
       prima, 
       descuento, 
       recargo, 
       prima_neta, 
       impuesto, 
       prima_bruta, 
       reasegurada, 
       vigencia_inic,
       vigencia_final, 
       beneficio_max, 
       desc_unidad, 
       prima_suscrita, 
       prima_retenida, 
       suma_aseg_adic,
       gastos, 
	   tipo_incendio)	
select v_poliza,
	   v_endoso,
	   no_unidad,
	   cod_ruta,
	   cod_producto,
	   cod_asegurado,
	   suma_asegurada,
       prima,
       descuento,
       recargo,
       prima_neta,
       impuesto,
       prima_bruta,
       reasegurada,
       vigencia_inic,
       vigencia_final,
       beneficio_max,
       desc_unidad,
       prima_suscrita,
       prima_retenida,
       0,
	   gastos,
	   _tipo_incendio
  from emipouni
 where no_poliza = v_poliza;

insert into endmoaut
select *
  from tmp_endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

drop table tmp_endmoaut;

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

select cod_tipocalc, cod_endomov
  into v_tipocalc, v_cod_mov
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

select tipo_mov
  into v_tipo_mov
  from endtimov
 where cod_endomov = v_cod_mov;

if v_tipocalc = "004" then -- POR SALDO
	select prima_bruta,
		   no_documento
	  into v_prima_bruta,
		   _no_documento
	  from emipomae
	 where no_poliza = v_poliza;

	let v_saldo = sp_cob174(_no_documento);

   {select sum(saldo)
     into v_saldo
     from emipomae
    where no_documento = _no_documento
      and actualizado  = 1;	}

	select Sum(y.factor_impuesto) 
	  into v_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = v_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	if v_impuesto > 0 then
		let v_impuesto = v_impuesto;
	else
		if v_tipo_mov = "4" or v_tipo_mov = "6" or v_tipo_mov = "1" then
			select cod_ramo,
				   cod_subramo,
				   cod_origen
			  into _cod_ramo_i,
				   _cod_subramo_i,
				   _cod_origen_i
			  from emipomae
			 where no_poliza = v_poliza;

			if _cod_ramo_i = "008" or _cod_ramo_i = "019" or _cod_ramo_i = "016" then
				select count(*)
				  into _canti_i
				  from emipolim
				 where no_poliza = v_poliza;

				if _canti_i = 0 then
					select aplica_impuesto
					  into _aplica_imp_i
					  from parorig
					 where cod_origen = _cod_origen_i;

					if _aplica_imp_i = 1 then
						foreach
							Select cod_impuesto
							  into _cod_impuesto_i
							  From prdimsub
							 Where cod_ramo    = _cod_ramo_i
							   And cod_subramo = _cod_subramo_i
							
							let _existe_imp_i = 0;

							select count(*)
							  into _existe_imp_i
							  from endedimp
							 where no_poliza = v_poliza
							   and no_endoso = v_endoso
							   and cod_impuesto = _cod_impuesto_i;

							if _existe_imp_i = 0 then
								Insert Into endedimp (no_poliza, no_endoso, cod_impuesto, monto)
								Values (v_poliza, v_endoso, _cod_impuesto_i, 0.00);
							end if
						end foreach

						select Sum(y.factor_impuesto) 
						  Into _porct_imp_i
						  From endedimp x, prdimpue y
						 where x.no_poliza    = v_poliza
						   and x.no_endoso    = v_endoso
						   and x.cod_impuesto = y.cod_impuesto
						   and y.pagado_por   = "C";
						
						let v_impuesto = _porct_imp_i;
					else
						let v_impuesto = 0.00;

					end if
				else
					let v_impuesto = 0.00;
				end if
			else
				let v_impuesto = 0.00;
			end if					
		else					
			let v_impuesto = 0.00;				
		end if		   
	end if
	
	let v_impuesto = v_impuesto + 100.00;
	LET _prima_salud = v_saldo / (v_impuesto / 100);

	{select tipo_mov
	  Into v_tipo_mov
	  from endtimov
	 where cod_endomov = v_cod_mov;}

	if v_tipo_mov = "3" Then
		let r_signo = 1;
	end if

	if _ramo_sis = 5 then
		let v_factor = 1 * r_signo;
	else
		if v_prima_bruta <> 0 then
			let v_factor = (v_saldo / v_prima_bruta) * r_signo;
		end if
	end if
elif v_tipocalc = "005" then -- Por Perdida Total

	select tipo_mov 
	  Into v_tipo_mov
	  from endtimov
	 where cod_endomov = v_cod_mov;

	let v_saldo  = 0.00;
	let v_factor = 0.00;
elif v_tipocalc = "006" Then -- Manual
	select prima_bruta
	  into v_saldo
	  from endedmae
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso;

	if v_tipo_mov = "2" or v_tipo_mov = "24" or v_tipo_mov = "1" or v_tipo_mov = "25" or v_tipo_mov = "3" or v_tipo_mov = "19" then
		select sum(prima),
			   sum(prima_neta)
		  into v_prima_bruta,
		       _prima_neta
	      from emipocob
		 where no_poliza = v_poliza;

		if v_tipo_mov <> "24" and v_tipo_mov <> "25" then
			LET v_prima_bruta = _prima_neta;
		end if

		select Sum(y.factor_impuesto)
		  Into v_impuesto
		  From emipolim x, prdimpue y
		 where x.no_poliza    = v_poliza
		   and x.cod_impuesto = y.cod_impuesto
		   and y.pagado_por   = "C";

		select tiene_impuesto
		    into _tiene_impuesto
		    from emipomae
		   where no_poliza = v_poliza;

		if v_impuesto > 0 then
			let v_impuesto = v_prima_bruta * ( v_impuesto / 100);
		else
			if v_tipo_mov = "4" or v_tipo_mov = "6" or v_tipo_mov = "1" then
				SELECT cod_ramo,
					   cod_subramo,
					   cod_origen
				  INTO _cod_ramo_i,
					   _cod_subramo_i,
					   _cod_origen_i
				  FROM emipomae
				 where no_poliza = v_poliza;

				if _cod_ramo_i = "008" or _cod_ramo_i = "019" or _cod_ramo_i = "016" then
					select count(*)
					  into _canti_i
					  from emipolim
					 where no_poliza = v_poliza;
					
					if _canti_i = 0 then
						Select aplica_impuesto
						  Into _aplica_imp_i
						  From parorig
						 Where cod_origen = _cod_origen_i;

						if _aplica_imp_i = 1 then
							foreach
								Select cod_impuesto
								  into _cod_impuesto_i
								  From prdimsub
								 Where cod_ramo    = _cod_ramo_i
								   And cod_subramo = _cod_subramo_i
								
								let _existe_imp_i = 0;

								select count(*)
								  into _existe_imp_i
								  from endedimp
								 where no_poliza = v_poliza
								   and no_endoso = v_endoso
								   and cod_impuesto = _cod_impuesto_i;
								
								if _existe_imp_i = 0 then
									Insert Into endedimp (no_poliza, no_endoso, cod_impuesto, monto)
									Values (v_poliza, v_endoso, _cod_impuesto_i, 0.00);
								end if
							end foreach								
								
							select Sum(y.factor_impuesto) 
							  Into _porct_imp_i
							  From endedimp x, prdimpue y
							 where x.no_poliza    = v_poliza
							   and x.no_endoso    = v_endoso
							   and x.cod_impuesto = y.cod_impuesto
							   and y.pagado_por   = "C";
											  
							let v_impuesto = v_prima_bruta * ( _porct_imp_i / 100);
						else
							let v_impuesto = 0.00;
						end if
					else
						let v_impuesto = 0.00;
					end if
				else					
					let v_impuesto = 0.00;
				end if				
			else
				let v_impuesto = 0.00;
			end if
		end if
		--LET v_impuesto = v_prima_bruta * (v_impuesto / 100);
		LET v_prima_bruta = v_prima_bruta + v_impuesto ;
	else
		select Sum(y.factor_impuesto)
		  Into v_impuesto
		  From emipolim x,prdimpue y
		 where x.no_poliza  = v_poliza
		   and x.cod_impuesto = y.cod_impuesto
		   and y.pagado_por   = "C";

		if v_impuesto is null then
			let v_impuesto = 0.00;
		end if

		select prima_bruta,
			   prima_neta,
			   tiene_impuesto
		  into v_prima_bruta,
			   _prima_neta,
			   _tiene_impuesto
		  from emipomae
		 where no_poliza = v_poliza;

		IF _tiene_impuesto <> 1 THEN
			LET v_impuesto = v_prima_bruta * (v_impuesto / 100);
			LET v_prima_bruta = v_prima_bruta + v_impuesto ;
		END IF
	end if

	if v_tipo_mov = "3" Or
		v_tipo_mov = "1" Then
		let r_signo = 1;
	end if

	IF v_prima_bruta <> 0 THEN
		if r_signo < 0 then
			let v_factor = (v_saldo / v_prima_bruta);
		else
			let v_factor = (v_saldo / v_prima_bruta) * r_signo;
		end if
	END IF
   
   --if v_poliza = "398411" then
--		let v_factor = -0.264406;
  -- end if

	if _ramo_sis = 5 then  --> amado 13/05/2009 se agrego esto porque no esta calculando bien el factor cuando es salud; lo trae sin decimales
		let _impuesto_tot    = 0;
		let _factor_impuesto = 0;
		foreach
			select cod_impuesto
			  into _cod_impuesto
			  from emipolim
			 where no_poliza = v_poliza

	        select factor_impuesto
			  into _factor_impuesto
			  from prdimpue
			 where cod_impuesto = _cod_impuesto;

	        let _impuesto_tot =  _impuesto_tot + _factor_impuesto;
		end foreach

		let v_saldo = v_saldo / (1 + (_impuesto_tot / 100));

		if _prima_neta <> 0 then
			if r_signo < 0 then
				let v_factor = (v_saldo / _prima_neta);
			else
				let v_factor = (v_saldo / _prima_neta) * r_signo;
			end if
		end if
	end if 
end if

foreach
	select no_unidad,
		   cod_producto,
		   prima,
		   suma_asegurada,
		   gastos
	  Into v_unidad,
		   v_producto,
		   r_prima_unidad,
		   v_suma_asegurada,
		   _gastos
	  from endeduni
	 where no_poliza   = v_poliza
	   and no_endoso   = v_endoso

	-- Pasar los descuentos de la unidad de la poliza al endoso
	delete from endunide
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso
	   and no_unidad = v_unidad;

	insert into endunide(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_descuen,
			porc_descuento)
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_descuen,
		   porc_descuento
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
		   porc_partic_suma	 dec(9,6),
		   porc_partic_prima dec(9,6),
		   suma_asegurada	 dec(16,2) default 0,
		   prima			 dec(16,2) default 0
		   ) with no log;

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

--	IF _no_cambio IS NULL THEN
--	   LET _no_cambio = 0;
--	END IF

	insert into prueba(
			no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima)
    select no_poliza,
		   no_unidad,
		   cod_cober_reas,
		   orden,
		   cod_contrato,
		   porc_partic_suma,
		   porc_partic_prima
	  from emireaco
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad
	   and no_cambio = _no_cambio;

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
		prima)
	select no_poliza,        
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
		no_poliza			char(10),
		no_endoso			char(5),
		no_unidad			char(5),
		cod_cober_reas		char(3),
		orden				smallint,
		cod_contrato		char(5),
		cod_coasegur		char(3),
		porc_partic_reas	dec(9,6),
		porc_comis_fac		dec(5,2),
		porc_impuesto		dec(5,2),
		suma_asegurada		dec(16,2) default 0,
		prima				dec(16,2) default 0,
		impreso				smallint default 0,
		fecha_impresion		date default today,
		no_cesion			char(10) default null,
		subir_bo			smallint default 0,
		monto_comision		dec(16,2),
		monto_impuesto		dec(16,2)
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
			porc_impuesto)
	select no_poliza,
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
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_recargo,
		   porc_recargo
	  from emiunire
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	-- Cargar las coberturas

	delete from endedcob
	 where no_poliza   = v_poliza
	   and no_endoso   = v_endoso
	   and no_unidad   = v_unidad;

	Insert Into endedcob(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cobertura,
			orden,
			tarifa,
			deducible,
			limite_1,
			limite_2,
			prima_anual,
			prima,
			descuento,
			recargo,
			prima_neta,
			date_added,
			date_changed,
			desc_limite1,
			desc_limite2,
			factor_vigencia,
			opcion)
	select v_poliza,
		   v_endoso,
		   v_unidad,
		   cod_cobertura,
		   orden,
		   0.00,
		   deducible,
	  	   limite_1,
		   limite_2,
		   prima_anual,
		   prima,
		   descuento,
		   recargo,
		   prima_neta,
	       current,
		   current,
		   desc_limite1,
		   desc_limite2,
		   v_factor,
		   0
	  from emipocob
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	if _ramo_sis = 5 then
		if v_tipocalc = "004" then
			update endedcob
			   set prima_anual = _prima_salud,
			       prima_neta  = _prima_salud,
				   prima       = _prima_salud
			 where no_poliza   = v_poliza
			   and no_endoso   = v_endoso
			   and no_unidad   = v_unidad
			   and prima_neta  <> 0.00;
		end if
	end if

	foreach
		select cod_cobertura,
			   prima_anual,
			   prima
		  into v_cobertura,
			   r_prima_anual,
			   v_prima
		  from endedcob
		 where no_poliza = v_poliza
		   and no_endoso = v_endoso
		   and no_unidad = v_unidad

		if v_tipocalc = "005" or v_tipocalc = "006" then
			if v_tipo_mov = "24" or v_tipo_mov = "25" then
				update endedcob
				   set endedcob.prima_anual   = endedcob.prima_anual * r_signo, -- * v_factor,
					   endedcob.prima         = (endedcob.prima  * v_factor),
					   endedcob.descuento     = 0,
					   endedcob.recargo       = endedcob.recargo * v_factor * -1,
					   endedcob.prima_neta    = (endedcob.prima  * v_factor)
				 where endedcob.no_poliza     = v_poliza
				   and endedcob.no_endoso     = v_endoso
				   and endedcob.no_unidad     = v_unidad
				   and endedcob.cod_cobertura = v_cobertura;
			else
				update endedcob
				   set endedcob.prima_anual   = endedcob.prima_anual * r_signo, -- * v_factor,
					   endedcob.prima         = (endedcob.prima  * v_factor),
					   endedcob.descuento     = (endedcob.descuento  * v_factor),
					   endedcob.recargo       = endedcob.recargo     * v_factor * -1, -- Amado 21/05/2012 se estaba haciendo mal el calculo del recargo
					   endedcob.prima_neta    = endedcob.prima_neta  * v_factor
				 where endedcob.no_poliza     = v_poliza
				   and endedcob.no_endoso     = v_endoso
				   and endedcob.no_unidad     = v_unidad
				   and endedcob.cod_cobertura = v_cobertura;
			end if
		elif v_tipocalc = "001" Then
			select acepta_desc
			  into _acepta_descuento
			  from prdcobpd
			 where cod_producto  = v_producto
			   and cod_cobertura = v_cobertura;

			let v_prima      = r_prima_anual * v_factor;
			let r_prima_neta = v_prima;

			if _acepta_descuento = 1 then
				let r_descuento = 0;
				let r_recargo   = 0;

				foreach
					select (u.porc_descuento / 100),
						   d.orden
					  into v_porc_descto,
						   v_orden
					  from endunide u, emidescu d
					 where u.no_poliza   = v_poliza
					   and u.no_endoso   = v_endoso
					   and u.no_unidad   = v_unidad
					   and u.cod_descuen = d.cod_descuen
					 order by d.orden

					let r_descuento  = r_descuento + (r_prima_neta * v_porc_descto);
					let r_prima_neta = r_prima_neta - (r_prima_neta * v_porc_descto);
				end foreach

				select sum(u.porc_recargo / 100)
				  into v_porc_descto
				  from endunire u
				 where u.no_poliza = v_poliza
				   and u.no_endoso = v_endoso
				   and u.no_unidad = v_unidad;

				if v_porc_descto is null then
					let v_porc_descto = 0;
				end if

				let r_recargo    = r_prima_neta * v_porc_descto;
				let r_prima_neta = r_prima_neta + (r_prima_neta * v_porc_descto);
			else
				let r_descuento  = 0;
				let r_recargo    = 0;
				let r_prima_neta = v_prima;
			end if

			update endedcob
			   set endedcob.prima_anual   = endedcob.prima_anual * r_signo,
			       endedcob.prima         = v_prima,
				   --endedcob.descuento     = r_descuento * -1,
			       endedcob.descuento     = r_descuento,
			       endedcob.recargo       = r_recargo * -1,
			       endedcob.prima_neta    = r_prima_neta
			 where endedcob.no_poliza     = v_poliza
			   and endedcob.no_endoso     = v_endoso
			   and endedcob.no_unidad     = v_unidad
			   and endedcob.cod_cobertura = v_cobertura;
		else
			update endedcob
			   set endedcob.prima_anual   = endedcob.prima_anual * r_signo, -- * v_factor,
				   endedcob.prima         = endedcob.prima * v_factor,
				   endedcob.descuento     = (endedcob.descuento * v_factor),
				   endedcob.recargo       = endedcob.recargo * v_factor * -1,
				   endedcob.prima_neta    = endedcob.prima_neta * v_factor
			 where endedcob.no_poliza     = v_poliza
			   and endedcob.no_endoso     = v_endoso
			   and endedcob.no_unidad     = v_unidad
			   and endedcob.cod_cobertura = v_cobertura;
		end if
	end foreach

	{if v_poliza = '429234' and v_endoso = '00008'then
		update endedcob
	       set endedcob.prima_neta    = 644737.51
	     where endedcob.no_poliza     = v_poliza
	       and endedcob.no_endoso     = v_endoso
	       and endedcob.no_unidad     = v_unidad
	       and endedcob.cod_cobertura = '00358';	
	end if}

	{select tipo_mov
	  Into v_tipo_mov
	  from endtimov
	 where cod_endomov = v_cod_mov;}

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

	{if v_tipo_mov = "1" Or v_tipo_mov = "3" Then 
		Select sum(endedcob.descuento)
		  into _descuento
		  from endedcob
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
	if v_tipo_mov = "2" Or v_tipo_mov = "19" Or v_tipo_mov = "24" Then 
		select sum(endedcob.descuento) 
		  into _descuento 
		  from endedcob
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
	end if}

	select sum(x.prima),
		   sum(x.prima),
		   sum(x.descuento),
		   sum(x.recargo),
		   sum(x.prima_neta)
	  into r_prima_anual,
		   r_prima_cober,
		   v_tot_descto,
		   v_tot_recargo,
		   r_prima_neta
	  from endedcob x
	 where x.no_poliza = v_poliza
	   and x.no_endoso = v_endoso
	   and x.no_unidad = v_unidad;

	if  v_tipocalc = "006" and v_tipo_mov = "2"  then
		let v_tot_descto = 0.00;
	end if

	-- Calcular el impuesto de la unidad
	let v_impuesto = 0.00;

	select x.tiene_impuesto
	  into v_impto
	  from endedmae x
	 where x.no_poliza    = v_poliza
	   and x.no_endoso    = v_endoso;

	if v_impto = 1 then
		select sum(y.factor_impuesto)
		  into v_impuesto
		  from emipolim x, prdimpue y
		 where x.no_poliza    = v_poliza
		   and x.cod_impuesto = y.cod_impuesto
		   and y.pagado_por   = "C";
		
		if v_impuesto > 0.00 then
			let v_impuesto = (r_prima_neta * v_impuesto) / 100;
		else
			if v_tipo_mov = "4" or v_tipo_mov = "6" or v_tipo_mov = "1" then	  
				select cod_ramo,
					   cod_subramo,
					   cod_origen
				  into _cod_ramo_i,
					   _cod_subramo_i,
					   _cod_origen_i
				  from emipomae
				 where no_poliza = v_poliza;

				if _cod_ramo_i = "008" or _cod_ramo_i = "019" or _cod_ramo_i = "016" then
					select count(*)
					  into _canti_i
					  from emipolim
					 where no_poliza = v_poliza;

					if _canti_i = 0 then
						select aplica_impuesto
						  into _aplica_imp_i
						  from parorig
						 where cod_origen = _cod_origen_i;

						if _aplica_imp_i = 1 then								
							foreach
								select cod_impuesto
								  into _cod_impuesto_i
								  from prdimsub
								 where cod_ramo    = _cod_ramo_i
								   and cod_subramo = _cod_subramo_i

								let _existe_imp_i = 0;

								select count(*)
								  into _existe_imp_i
								  from endedimp
								 where no_poliza = v_poliza
								   and no_endoso = v_endoso
								   and cod_impuesto = _cod_impuesto_i;

								if _existe_imp_i = 0 then
									insert into endedimp (no_poliza, no_endoso, cod_impuesto, monto)
									values (v_poliza, v_endoso, _cod_impuesto_i, 0.00);
								end if
							end foreach

							select sum(y.factor_impuesto) 
							  into _porct_imp_i
							  from endedimp x, prdimpue y
							 where x.no_poliza    = v_poliza
							   and x.no_endoso    = v_endoso
							   and x.cod_impuesto = y.cod_impuesto
							   and y.pagado_por   = "C";

							let v_impuesto = r_prima_neta * ( _porct_imp_i / 100);
						else
							let v_impuesto = 0.00;
						end if
					else
						let v_impuesto = 0.00;
					end if							
				else
					let v_impuesto = 0.00;										
				end if
			else			
				let v_impuesto = 0.00;		
			end if
		end if
	end if

	let v_prima_bruta = r_prima_neta + v_impuesto + (_gastos * v_factor);
	let _neta = r_prima_neta;
	
	{if _neta < 0.00 Then
		let _neta = _neta * -1;
	end if}
	
	let _neta = (_neta * _porc_coas) / 100;

	foreach
		select cod_cober_reas, 
			   orden,
			   cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  into v_cober_reas,
			   v_orden,
			   v_contrato,
			   v_partic_suma,
			   v_partic_prima
		  from emifacon
		 where no_poliza = v_poliza
		   and no_endoso = v_endoso
		   and no_unidad = v_unidad

		select sum(x.prima_neta)
		  into r_prima_cober
		  from prdcober y, endedcob x
		 where x.no_poliza      = v_poliza
		   and x.no_endoso      = v_endoso
		   and x.no_unidad      = v_unidad
		   and x.cod_cobertura  = y.cod_cobertura
		   and y.cod_cober_reas = v_cober_reas;

		let v_prima_reaseguro = (v_partic_prima * r_prima_cober)    / 100; 
		let v_suma_reaseguro  = (v_partic_suma  * v_suma_asegurada) / 100;
		let v_prima_reaseguro =  v_prima_reaseguro * _porc_coas / 100;	
		let v_suma_reaseguro  =  v_suma_reaseguro  * _porc_coas / 100;	

		if v_prima_reaseguro is null then
			let v_prima_reaseguro = 0.00;
		end if

		if v_suma_reaseguro is null then
			let v_suma_reaseguro = 0.00;
		end if

		{TRACE ON; 
			LET v_prima_reaseguro = v_prima_reaseguro;
		TRACE OFF;}

		update emifacon
		   set emifacon.prima          = v_prima_reaseguro,
			   emifacon.suma_asegurada = v_suma_reaseguro  * r_signo
		 where emifacon.no_poliza      = v_poliza
		   and emifacon.no_endoso      = v_endoso
		   and emifacon.no_unidad      = v_unidad
		   and emifacon.cod_cober_reas = v_cober_reas
		   and emifacon.orden          = v_orden;

		foreach
			select cod_coasegur,
				   porc_partic_reas
			  into v_coasegur,
				   v_partic_reas
			  from emifafac 
			 where no_poliza      = v_poliza
			   and no_endoso      = v_endoso
			   and no_unidad      = v_unidad
			   and cod_cober_reas = v_cober_reas
			   and orden          = v_orden
			   and cod_contrato   = v_contrato
			   
			let v_prima_reas = (v_partic_reas * v_prima_reaseguro) / 100; 
			let v_suma_reas  = (v_partic_reas * v_suma_reaseguro) / 100;

			if v_prima_reas is null then
				let v_prima_reas = 0.00;
			end if
			
			if v_suma_reas is null then
			   let v_suma_reas = 0.00;
			end if

			update emifafac
			   set emifafac.prima          = v_prima_reas,
				   emifafac.suma_asegurada = v_suma_reas  * r_signo
			 where emifafac.no_poliza      = v_poliza
			   and emifafac.no_endoso      = v_endoso
			   and emifafac.no_unidad      = v_unidad
			   and emifafac.cod_cober_reas = v_cober_reas
			   and emifafac.orden          = v_orden
			   and emifafac.cod_contrato   = v_contrato
			   and emifafac.cod_coasegur   = v_coasegur;
		end foreach
	end foreach

	select sum(emifacon.prima)
	  into v_prima_suscrita
	  from emifacon
	 where emifacon.no_poliza  = v_poliza
	  and emifacon.no_endoso   = v_endoso
	  and emifacon.no_unidad   = v_unidad;

	if v_prima_suscrita is null Then
		let v_prima_suscrita = 0.00;
		let v_cober_reas     = null;
	end if

	let _tot_reaseguro = v_prima_suscrita;

	if _tot_reaseguro <> _neta Then
		let v_prima_suscrita = _neta;
		let _neta = _neta - _tot_reaseguro;
		{if _tot_reaseguro < 0 Then
			let _neta = _neta + _tot_reaseguro;
		else
			let _neta = _neta - _tot_reaseguro;
		end if}

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

	select sum(emifacon.prima)
	  into v_prima_retenida
	  from emifacon, reacomae
	 where emifacon.no_poliza     = v_poliza
	   and emifacon.no_endoso     = v_endoso
	   and emifacon.no_unidad     = v_unidad
	   and emifacon.cod_contrato  = reacomae.cod_contrato
	   and reacomae.tipo_contrato = "1";

	if v_prima_retenida is null Then
		let v_prima_retenida = 0.00;
	end if

	if r_prima_anual is null Then
		let r_prima_anual = 0.00;
	end if

	if v_tot_descto is null Then
		let v_tot_descto = 0.00;
	end if

	if v_tot_recargo is null Then
		let v_tot_recargo = 0.00;
	end if

	if r_prima_neta is null Then
		let r_prima_neta = 0.00;
	end if

	if v_impuesto is null Then
		let v_impuesto = 0.00;
	end if

	if v_prima_bruta is null Then
		let v_prima_bruta = 0.00;
	end if

	if v_prima_suscrita is null Then
		let v_prima_suscrita = 0.00;
	end if

	if v_prima_retenida is null Then
		let v_prima_retenida = 0.00;
	end if

	if v_suma_asegurada is null Then
		let v_suma_asegurada = 0.00;
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
		   endeduni.suma_asegurada = v_suma_asegurada * r_signo,
		   endeduni.gastos         = endeduni.gastos  * r_signo
	 where endeduni.no_poliza      = v_poliza
	   and endeduni.no_endoso      = v_endoso
	   and endeduni.no_unidad      = v_unidad;	  
end foreach

if _cod_ramo = "008" or _cod_ramo = "019" or _cod_ramo = "016" then
	select sum(impuesto)
	  into _sum_imp
	  from endeduni
	 where no_poliza    = v_poliza
	   and no_endoso    = v_endoso;

	select count(*)
	  into _end_imp
	  from endedimp
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso;

	if _end_imp > 0 then
		update endedimp
		   set monto = _sum_imp
		 where no_poliza = v_poliza
		   and no_endoso = v_endoso;
	end if
end if

-- Verificacion de Prima Neta para el Calculo Manual y Por Saldo
select sum(impuesto)
  into _sum_imp
  from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

if _sum_imp = 0 then
	let v_tipocalc = "001";
end if


return r_error, r_descripcion;

end

end procedure;