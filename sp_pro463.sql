--- Eliminacion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

drop procedure sp_pro463;
create procedure sp_pro463(
v_poliza	char(10),
v_endoso	char(5),
v_unidad	char(5),
v_cant_dias	smallint,
v_factor	dec(16,2))
returning	smallint,
			char(30),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);
begin

define _limite_desc  		varchar(50);
define r_descripcion		char(30);
define v_cobertura			char(5);
define v_contrato			char(5);
define _cod_tipocalc		char(3);
define _cod_impuesto    	char(3);
define v_cober_reas			char(3);
define _cod_endomov			char(3);
define _cod_subramo     	char(3);
define _cod_origen      	char(3);
define v_coasegur			char(3);
define _cod_ramo        	char(3);
define v_partic_prima		dec(9,6);
define v_partic_reas		dec(9,6);
define v_partic_suma		dec(9,6);
define _porct_imp			dec(9,6);
define factor				dec(9,6);
define v_prima_reaseguro	dec(16,2);
define v_suma_reaseguro		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_descto		dec(16,2);
define v_prima_bruta		dec(16,2);
define r_prima_bruta		dec(16,2);
define r_prima_cober		dec(16,2);
define v_porc_descto		dec(16,2);
define v_tot_recargo		dec(16,2);
define v_tot_descto			dec(16,2);
define v_prima_reas			dec(16,2);
define v_prima_neta			dec(16,2);
define r_prima_neta			dec(16,2);
define r_descuento			dec(16,2);
define v_suma_reas			dec(16,2);
define v_prima_uni			dec(16,2);
define v_prima_cob			dec(16,2);
define v_rata_dia			dec(16,2);
define r_recargo			dec(16,2);
define r_prima				dec(16,2);
define v_prima				dec(16,2);
define v_impuesto			dec(16,4);
define r_impuesto			dec(16,4);
define _aplica_imp			smallint;
define _existe_imp			smallint;
define v_cantidad			smallint;
define _no_cambio			smallint;
define _tipo_mov			smallint;
define r_error				smallint;
define v_impto				smallint;
define v_signo				smallint;
define v_dias				smallint;
define r_cant				smallint;
define _canti				smallint;
define v_orden				smallint;
define v_poliza_inic		date;
define v_poliza_fin			date;
define _cod_acreedor		char(5);
define _lim                 decimal(16,2);

set isolation to dirty read;

let v_tot_recargo = 0.00;
let v_prima_bruta = 0.00;
let r_prima_bruta = 0.00;
let v_porc_descto = 0.00;
let v_tot_descto  = 0.00;
let v_prima_neta  = 0.00;
let r_prima_neta  = 0.00;
let r_descuento   = 0.00;
let v_prima_uni   = 0.00;
let v_prima_cob   = 0.00;
let v_impuesto    = 0.00;
let r_impuesto    = 0.00;
let v_rata_dia    = 0.00;
let r_recargo     = 0.00;
let r_prima       = 0.00;
let v_prima 	  = 0.00;
let factor  	  = 0.00;
let v_cantidad    = 0;
let r_error       = 0;
let v_dias  	  = 0;
let r_descripcion = null;
let _lim     	  = 0.00;
let _limite_desc  = null;

-------------
---  Buscar la vigencia del endoso y la prima para calcular el factor
------------
{if v_poliza = '0001642968' and v_unidad = '00005' then
 set debug file to "sp_pro463.trc";
 trace on;
end if}

select vigencia_inic,
	   vigencia_final
  into v_poliza_inic,
	   v_poliza_fin
  from emipouni
 where no_poliza = v_poliza
   and no_unidad = v_unidad;

let v_dias = v_poliza_fin - v_poliza_inic;

select cod_endomov,
	   cod_tipocalc
  into _cod_endomov,
	   _cod_tipocalc
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

select tipo_mov
  into _tipo_mov
  from endtimov
 where cod_endomov = _cod_endomov;

if _tipo_mov = 5 and _cod_tipocalc = "005" then
   let v_factor = 0.00;
end if

-------------
---  Pasar la unidad de la poliza al endoso
------------
let r_cant = 0;

select count(*) 
  into r_cant
  from endeduni
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;
   
If r_cant = 0 Then
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
			prima_retenida)	
	select	no_poliza,
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
			prima_retenida
	  from	emipouni
	 where	no_poliza = v_poliza
	   and	no_unidad = v_unidad;
end if
----------------
-----  Calculos de las coberturas
----------------
--trace off;

let r_cant = 0;

select count(*)
  into r_cant
  from endedcob
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;
   
if r_cant = 0 then
	foreach
		select cod_cobertura
		  into v_cobertura
		  from emipocob
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad

		let v_prima = 0.00;
		let v_rata_dia = 0.00;
		
		select prima_anual
		  into v_prima
		  from emipocob
		 where no_poliza     = v_poliza
		   and no_unidad     = v_unidad
		   and cod_cobertura = v_cobertura;
		   
		let v_prima_cob = v_prima * v_factor;
	  ----------------
	  ---  Pasar las coberturas de la poliza al endoso
	  ----------------
		insert into endedcob(
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
		select	no_poliza,
				v_endoso,
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
				_limite_desc,
				_limite_desc,
				factor,
				0
		  from	emipocob
		 where	no_poliza  = v_poliza
		   and	no_unidad  = v_unidad
		   and	cod_cobertura = v_cobertura;
	  ------------
	  ---  Calcular el descuento de la cobertura
	  ------------
		let v_porc_descto = 0.00;
		let v_tot_descto  = 0.00;
		let v_prima_descto = v_prima_cob;

		foreach
			select porc_descuento 
			  into v_porc_descto
			  from emicobde
			 where no_poliza		= v_poliza
			   and no_unidad		= v_unidad
			   and cod_cobertura	= v_cobertura
		
			if v_porc_descto is null then
				let v_porc_descto = 0.00;
			end if
			
			let v_tot_descto = v_tot_descto + ((v_porc_descto * v_prima_descto)/100);
			let v_prima_descto = v_prima_descto - v_tot_descto;
		end foreach

	  -------------
	  ---  Calcular el recargo de la cobertura
	  ------------
		let v_tot_recargo = 0.00;

		select sum(porc_recargo)
		  into v_tot_recargo
		  from emicobre
		 where no_poliza  = v_poliza
		   and no_unidad  = v_unidad
		   and cod_cobertura = v_cobertura;
		
		if v_tot_recargo is null then
			let v_tot_recargo = 0.00;
		else
			let v_tot_recargo = (v_tot_recargo * (v_prima_cob - v_tot_descto)/100);
		end if
		
		let v_prima_neta  = v_prima_cob + v_tot_descto - v_tot_recargo;

	  -------------
	  ---  actualizar valores de la cobertura
	  ------------
		if _tipo_mov = 5 AND _cod_tipocalc = "005" Then
			update endedcob
			   set prima       = 0.00,
				   descuento   = 0.00,
				   recargo     = 0.00,
				   prima_neta  = 0.00,
				   prima_anual = 0.00,
				   limite_1    = 0.00,
				   limite_2    = 0.00
			 where no_poliza		= v_poliza
			   and no_endoso		= v_endoso
			   and no_unidad		= v_unidad
			   and cod_cobertura	= v_cobertura;
		else
			update endedcob
			   set prima       = v_prima_cob,
				   descuento   = v_tot_descto,
				   recargo     = v_tot_recargo,
				   prima_neta  = v_prima_neta,
				   prima_anual = prima_anual * -1,
				   limite_1    = limite_1 * -1,
				   limite_2    = limite_2 * -1
			 where no_poliza		= v_poliza
			   and no_endoso		= v_endoso
			   and no_unidad		= v_unidad
			   and cod_cobertura	= v_cobertura;
		end if
	end foreach
end if
---  FIN DEL CALCULO DE LAS COBERTURAS
----------------------------------------------------------------------------
---  actualizar valores de la unidad
------------
select sum(prima),
	   sum(descuento),
	   sum(recargo),
	   sum(prima_neta)
  into v_prima_uni,
	   v_tot_descto,
	   v_tot_recargo,
	   v_prima_neta
  from endedcob
 where no_poliza = v_poliza
   and no_endoso = v_endoso
   and no_unidad = v_unidad;

-------------
---  Calcular el impuesto de la unidad
------------
let v_impuesto = 0.00;

select tiene_impuesto
  into v_impto
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

if v_impto = 1 then
	select sum(y.factor_impuesto)
	  into v_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = v_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	if v_impuesto is null then
	     --VALIDACION PARA POLIZAS DE FIANZAS, VIDA, COLEC VIDA*****************************************************************************
		select cod_ramo,
			   cod_subramo,
			   cod_origen
		  into _cod_ramo,
			   _cod_subramo,
			   _cod_origen
		  from emipomae
		 where no_poliza = v_poliza;

		if _tipo_mov = "4" or _tipo_mov = "6" or _tipo_mov = "1" or _tipo_mov = "5" then		
			if _cod_ramo = "008" or _cod_ramo = "019" or _cod_ramo = "016" then
			
				select count(*)
				  into _canti
				  from emipolim
				 where no_poliza = v_poliza;

				if _canti = 0 then
					select aplica_impuesto
					  into _aplica_imp
					  from parorig
					 where cod_origen = _cod_origen;

					if _aplica_imp = 1 then
						foreach
							select cod_impuesto
							  into _cod_impuesto
							  from prdimsub
							 where cod_ramo    = _cod_ramo
							   and cod_subramo = _cod_subramo

							let _existe_imp = 0;

							select count(*)
							  into _existe_imp
							  from endedimp
							 where no_poliza = v_poliza
							   and no_endoso = v_endoso
							   and cod_impuesto = _cod_impuesto;

							if _existe_imp = 0 then
								insert into endedimp(
									no_poliza,
									no_endoso,
									cod_impuesto,
									monto)
								values(
									v_poliza,
									v_endoso,
									_cod_impuesto,
									0.00);
							end if
						end foreach

						select sum(y.factor_impuesto) 
						  into _porct_imp
						  from endedimp x, prdimpue y
						 where x.no_poliza    = v_poliza
						   and x.no_endoso    = v_endoso
						   and x.cod_impuesto = y.cod_impuesto
						   and y.pagado_por   = "C";

						let v_impuesto = r_prima_neta * ( _porct_imp / 100);

						update endedimp
						   set monto = v_impuesto
						 where no_poliza = v_poliza
						   and no_endoso = v_endoso;
					end if
				end if
			end if
		end if
	else
		let v_impuesto = ((r_prima_neta * v_impuesto) / 100);
	end if
end if
  
let v_prima_bruta = v_prima_neta + v_impuesto;

-------------
let v_signo = -1;

if _tipo_mov = 5 AND _cod_tipocalc = "005" Then
	let v_signo = 0;
end if

update endeduni
   set prima       = v_prima_uni,
	   descuento   = v_tot_descto,
	   recargo     = v_tot_recargo,
	   prima_neta  = v_prima_neta,
	   impuesto    = v_impuesto,
	   prima_bruta = v_prima_bruta,
	   suma_asegurada = (suma_asegurada * v_signo)
 where no_poliza   = v_poliza
   and no_endoso   = v_endoso
   and no_unidad   = v_unidad;

---  FIN DEL CALCULO DE LAS UNIDADES
----------------------------------------------------------------------------
---  Pasar los descuentos de la coberturas de la poliza al endoso
------------
let r_cant = 0;
select count(*) 
  into r_cant
  from endcobde
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

if r_cant = 0 then
	insert into endcobde
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_cobertura,
		   cod_descuen,
		   porc_descuento
	  from emicobde
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;
end if
-------------
---  Pasar los recargos de la coberturas de la poliza al endoso
------------
let r_cant = 0;
select count(*)
  into r_cant
  from endcobre
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

if r_cant = 0 Then
	insert into endcobre
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_cobertura,
		   cod_recargo,
		   porc_recargo
	  from emicobre
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;
end if
-------------
---  Pasar los acreedores de la unidad de la poliza al endoso
------------

let r_cant = 0;

select count(*)
  into r_cant
  from endedacr
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

if r_cant = 0 or r_cant is null Then

   let v_poliza = v_poliza;
   let v_unidad = v_unidad;
   let v_endoso = v_endoso;


   foreach

	select cod_acreedor,
		   limite
	  into _cod_acreedor,
	       _lim
      from emipoacr
     where no_poliza = v_poliza
       and no_unidad = v_unidad

    insert into endedacr(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_acreedor,
	limite)
	values(
	v_poliza,
	v_endoso,
	v_unidad,
	_cod_acreedor,
	_lim
	);

   end foreach

{	insert into endedacr
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_acreedor,
		   limite
      from emipoacr
     where no_poliza = v_poliza
       and no_unidad = v_unidad;}
end if

-------------
---  Pasar la  descripcion de la unidad de la poliza al endoso
------------
--let r_cant = 0;
--select count(*) into r_cant from endedde2
-- where no_poliza = v_poliza
--   and no_unidad = v_unidad
--   and no_endoso = v_endoso;

--if r_cant = 0 Then
--   insert into endedde2
--   select no_poliza, v_endoso, no_unidad, descripcion
--     from emipode2
--    where no_poliza = v_poliza
--      and no_unidad = v_unidad;
--end if
-------------
---  Pasar los descuentos de la unidad de la poliza al endoso
------------
let r_cant = 0;

select count(*)
  into r_cant 
  from endunide
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

if r_cant = 0 Then
	insert into endunide(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_descuen,
			porc_descuento)
	select	no_poliza,
			v_endoso,
			no_unidad,
			cod_descuen,
			porc_descuento
	  from	emiunide
	 where	no_poliza = v_poliza
	   and	no_unidad = v_unidad;
end if
-------------
---  Pasar los recargos de la unidad de la poliza al endoso
------------
let r_cant = 0;

select count(*)
  into r_cant
  from endunire
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

if r_cant = 0 Then
	insert into endunire
	select no_poliza,
		   v_endoso,
		   no_unidad,
		   cod_recargo,
		   porc_recargo
	  from emiunire
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;
end if

-------------
---  Pase de distribucion de la compania
------------
--let r_cant = 0;
--select count(*) into r_cant from emifacon
-- where no_poliza = v_poliza
--   and no_unidad = v_unidad
--   and no_endoso = v_endoso;

--If r_cant = 0 Then
--   select * from emifacon
--    where no_poliza = v_poliza
--      and no_endoso = "00000"
--      and no_unidad = v_unidad
--     into temp pruebas;

--   update pruebas set no_endoso = v_endoso
--    where no_poliza = v_poliza
--      and no_endoso = "00000"
--      and no_unidad = v_unidad;

--   insert into emifacon
--  select * from pruebas
--    where no_poliza = v_poliza
--      and no_endoso = v_endoso
--      and no_unidad = v_unidad;

--  drop table pruebas;
--end if
-------------
---  Pase de distribucion del facultativo
------------
--let r_cant = 0;
--select count(*) into r_cant from emifafac
-- where no_poliza = v_poliza
--   and no_unidad = v_unidad
--   and no_endoso = v_endoso;

--If r_cant = 0 Then
--	select * from emifafac
--	 where no_poliza = v_poliza
--	   and no_endoso = "00000"
--	   and no_unidad = v_unidad
--	  into temp pruebas;

--	update pruebas set no_endoso = v_endoso
--	 where no_poliza = v_poliza
--	   and no_endoso = "00000"
--	   and no_unidad = v_unidad;

--	insert into emifafac
--	select * from pruebas
--	 where no_poliza = v_poliza
--	   and no_endoso = v_endoso
--	   and no_unidad = v_unidad;

--	drop table pruebas;
--end if

let r_cant = 0; 
select count(*)				-----> En caso que no haya registro en emireama Amado 11-10-2011
  into r_cant
  from emireama
 where no_poliza = v_poliza
   and no_unidad = v_unidad;

select suma_asegurada
  into v_suma_asegurada
  from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso
   and no_unidad = v_unidad;
if r_cant = 0 Then
-------------------------------------------	 Este reemplaza lo de arriba para que tome los cambios en los reaseguros Amado 11-10-2011 
else  
		-- Cargar Reaseguros Individuales
	{create temp table prueba(
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
		prima			 dec(16,2) default 0)
	with no log;}

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	--	IF _no_cambio IS NULL THEN
	--	   LET _no_cambio = 0;
	--	END IF

	let r_cant = 0;

	select count(*)
	  into r_cant
	  from emifacon
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad
	   and no_endoso = v_endoso;

		if r_cant = 0 then
			{
			insert into prueba(
					no_poliza,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima)
		    select	no_poliza,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima
			  from	emireaco
			 where	no_poliza = v_poliza
			   and	no_unidad = v_unidad
			   and	no_cambio = _no_cambio;

			update prueba
			   set no_endoso = v_endoso
			 where no_poliza = v_poliza
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
			select	no_poliza,        
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
			  from	prueba
			 where	no_poliza = v_poliza
			   and	no_unidad = v_unidad;
			}
			call sp_proe04b(v_poliza,v_unidad,v_suma_asegurada,v_endoso) returning r_error;
		end if

		drop table if exists prueba;
		--  Cargar Reaseguros Facultativos
		{create temp table prueba(
		       no_poliza         char(10),
			   no_endoso	     char(5),
			   no_unidad	     char(5),
			   cod_cober_reas    char(3),
			   orden		     smallint,
			   cod_contrato	     char(5),
			   cod_coasegur	     char(3),
			   porc_partic_reas	 dec(9,6),
			   porc_comis_fac    dec(5,2),
			   porc_impuesto	 dec(5,2),
			   suma_asegurada	 dec(16,2)	default 0,
			   prima			 dec(16,2)	default 0,
			   impreso           smallint	default 0,
			   fecha_impresion   date		default today,
			   no_cesion         char(10)	default null,
			   subir_bo          smallint	default 0,
			   monto_comision	 dec(16,2),
			   monto_impuesto	 dec(16,2)
			   ) with no log;}

		let r_cant = 0;

		select count(*)
		  into r_cant
		  from emifafac
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad
		   and no_endoso = v_endoso;

		if r_cant = 0 then
			select * 
			  from emifafac
			 where 1=2
			 into temp prueba;

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
		    select	no_poliza,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_coasegur,
					porc_partic_reas,
					porc_comis_fac,
					porc_impuesto
			  from	emireafa
			 where	no_poliza = v_poliza
			   and	no_unidad = v_unidad
			   and	no_cambio = _no_cambio;

		    update prueba
		       set no_endoso = v_endoso
		     where no_poliza = v_poliza
			   and no_unidad = v_unidad;

			insert into emifafac
			select * from prueba
			 where no_poliza = v_poliza
			   and no_unidad = v_unidad;
		end if
		drop table  if exists prueba;
end if

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

--	  LET v_prima_reaseguro =  v_prima_reaseguro * _porc_coas / 100;	
--	  LET v_suma_reaseguro  =  v_suma_reaseguro  * _porc_coas / 100;	

	if v_prima_reaseguro is null then
		let v_prima_reaseguro = 0.00;
	end if
	if v_suma_reaseguro is null then
		let v_suma_reaseguro = 0.00;
	end if

	update emifacon
	   set prima          = v_prima_reaseguro * v_signo,
		   suma_asegurada = v_suma_reaseguro
	 where no_poliza      = v_poliza
	   and no_endoso      = v_endoso
	   and no_unidad      = v_unidad
	   and cod_cober_reas = v_cober_reas
	   and orden          = v_orden;

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
	       set prima          = v_prima_reas,
	           suma_asegurada = v_suma_reas * v_signo
	     where no_poliza      = v_poliza
	       and no_endoso      = v_endoso
	       and no_unidad      = v_unidad
	       and cod_cober_reas = v_cober_reas
	       and orden          = v_orden
		   and cod_contrato   = v_contrato
		   and cod_coasegur   = v_coasegur;

	end foreach
end foreach
 -------------------------------------
select prima,
	   descuento,
	   recargo,
	   prima_neta,
	   impuesto,
	   prima_bruta
  into r_prima,
	   r_descuento,
	   r_recargo,
	   r_prima_neta,
	   r_impuesto,
	   r_prima_bruta
  from endeduni x
 where x.no_poliza = v_poliza
   and x.no_endoso = v_endoso
   and x.no_unidad = v_unidad;

return r_error, r_descripcion, r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto, r_prima_bruta;

end
end procedure;