-- Calculo de la Prima de las Coberturas
--
-- Creado    : 31/10/2000 - Autor: Victor Molinar
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza

drop procedure sp_pro464;

create procedure "informix".sp_pro464(v_poliza char(10), v_endoso char(5), v_unidad char(5))
RETURNING SMALLINT, CHAR(30);

DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   v_producto    CHAR(5);
DEFINE   v_acepta      SMALLINT;
DEFINE   r_prima       DECIMAL(16,2);
DEFINE   r_descuento   DECIMAL(16,2);
DEFINE   r_recargo     DECIMAL(16,2);
DEFINE   r_prima_neta  DECIMAL(16,2);
DEFINE   r_impuesto    DECIMAL(16,4);
DEFINE   r_prima_bruta DECIMAL(16,2);
DEFINE   v_cobertura   CHAR(5);
DEFINE   limite        VARCHAR(50);
DEFINE   v_factor      Decimal(9,6);
DEFINE   v_prima       Decimal(16,2);
DEFINE   v_dias        Smallint;
DEFINE   v_cantidad    Smallint;
DEFINE   r_cant        Smallint;
DEFINE   v_impuesto    Decimal(16,4);
DEFINE   v_rata_dia    Decimal(16,2);
DEFINE   v_poliza_inic Date;
DEFINE   v_poliza_fin  Date;
DEFINE   v_prima_uni   Decimal(16,2);
DEFINE   v_prima_cob   Decimal(16,2);
DEFINE   v_tot_descto  Decimal(16,2);
DEFINE   v_porc_descto Decimal(16,2);
DEFINE   v_tot_recargo Decimal(16,2);
DEFINE   v_prima_neta  Decimal(16,2);
DEFINE   v_prima_bruta Decimal(16,2);
DEFINE   v_prima_descto DECIMAL(16,2);
DEFINE   v_signo       SMALLINT;
DEFINE _descuento_max	DECIMAL(5,2);
DEFINE _tipo_descuento  SMALLINT;
DEFINE _desc_cob 		DECIMAL(16,2);
DEFINE _tipo_auto       SMALLINT;
DEFINE _desc_porc       DECIMAL(7,4);
DEFINE _fecha_suscripcion DATE;
DEFINE _cod_tipo_tar    CHAR(3);
DEFINE ld_prima_aux     DECIMAL(16,2);
define _nueva_renov     char(1);
define _cod_ramo        char(3);
define _cod_endomov     char(3);


SET ISOLATION TO DIRTY READ;

BEGIN

LET limite        = NULL;
LET v_factor      = 0.00;
LET v_prima       = 0.00;
LET v_dias        = 0;   
LET v_cantidad    = 0;   
LET v_impuesto    = 0.00;
LET v_rata_dia    = 0.00;
LET v_prima_uni   = 0.00;
LET v_prima_cob   = 0.00;
LET v_tot_descto  = 0.00;
LET v_porc_descto = 0.00;
LET v_tot_recargo = 0.00;
LET v_prima_neta  = 0.00;
LET v_prima_bruta = 0.00;

LET r_error       = 0;   
LET r_descripcion = NULL;
LET r_prima       = 0.00;
LET r_descuento   = 0.00;
LET r_recargo     = 0.00;
LET r_prima_neta  = 0.00;
LET r_impuesto    = 0.00;
LET r_prima_bruta = 0.00;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro464.trc";
--TRACE ON;

----------------
-----  Calculos de las coberturas
----------------
Select fecha_suscripcion, nueva_renov,cod_ramo
  Into _fecha_suscripcion, _nueva_renov,_cod_ramo
  From emipomae
 Where no_poliza = v_poliza;
 
Select cod_tipo_tar
  Into _cod_tipo_tar
  from emipouni
 where x.no_poliza = v_poliza
   and x.no_unidad = v_unidad;
   
if _cod_tipo_tar is null then
	let _cod_tipo_tar = '001';
end if
 
select x.factor_vigencia,
       x.cod_endomov 
  into v_factor,
       _cod_endomov
  from endedmae x
 where x.no_poliza = v_poliza
   and x.no_endoso = v_endoso;

let v_prima    = 0.00;

foreach
 select x.cod_cobertura, x.prima_anual 
   into v_cobertura, v_prima
   from endedcob x
  where x.no_poliza = v_poliza
    and x.no_endoso = v_endoso
    and x.no_unidad = v_unidad

  LET v_prima_cob = v_prima * v_factor;

  let v_porc_descto = 0.00;
  let v_tot_descto  = 0.00;
  let v_tot_recargo = 0.00;

  select x.cod_producto 
    into v_producto 
    from endeduni x
   where x.no_poliza = v_poliza
     and x.no_endoso = v_endoso
     and x.no_unidad = v_unidad;

  let v_acepta = 0; 

  select x.acepta_desc,x.descuento_max, x.tipo_descuento 
    into v_acepta,_descuento_max, _tipo_descuento 
    from prdcobpd x
   where x.cod_producto  = v_producto
     and x.cod_cobertura = v_cobertura;

  If v_acepta = 1 Then

	let v_prima_descto = v_prima_cob;

	--  Calcular el Descuento de la Cobertura
	
	if _tipo_descuento = 1 and _cod_tipo_tar = '002'  then	--> Descuento RC, solo polizas nuevas
	        let _tipo_auto = 0;
	        let _tipo_auto = sp_proe75(v_poliza,v_unidad);
	        if _tipo_auto = 0 then
				let _descuento_max = 0;
	        end if
	        if _cod_ramo = '023' then
				let _descuento_max = 0;
		    end if

			let _desc_porc     = _descuento_max / 100;
			let _desc_cob      = v_prima_cob * _desc_porc;
			let v_prima_descto = v_prima_cob - _desc_cob;
	 
	elif _tipo_descuento = 2 and _cod_tipo_tar = '002'  then --> Descuento Combinado Casco, solo polizas nuevas

	        let _descuento_max = sp_proe72(v_poliza,v_unidad); 

			if _cod_ramo = '023' then
				let _descuento_max = 0;
		    end if

			let _desc_porc     = _descuento_max / 100;
			let _desc_cob      = v_prima_cob * _desc_porc;
			let v_prima_descto = v_prima_cob - _desc_cob;
	end if

   	if _tipo_descuento in (1,2) and _cod_tipo_tar = '001' and _fecha_suscripcion >= "28/07/2014" and _nueva_renov = "R" then
			let _descuento_max = sp_proe78(v_poliza, v_unidad, v_producto, v_cobertura);
	        if _cod_ramo = '023' then
				let _descuento_max = 0;
		    end if

			let _desc_porc     = _descuento_max / 100;
			let _desc_cob      = v_prima_cob * _desc_porc;
			let v_prima_descto = v_prima_cob - _desc_cob;
	end if
	
   if _cod_endomov = '005' or _cod_endomov = '006' then
	   if _cod_tipo_tar = '004' or _cod_tipo_tar = '005' or _cod_tipo_tar = '006' or _cod_tipo_tar = '007' or _cod_tipo_tar = '008' then -- Descuentos por modelo y siniestralidad
			let _descuento_max = sp_sis430(v_poliza, v_endoso, v_unidad, v_cobertura);
			let _desc_porc     = _descuento_max / 100;
			let _desc_cob    = v_prima_cob * _desc_porc;
			let v_prima_descto = v_prima_cob - _desc_cob;
	   end if
	end if

    let v_tot_descto = _desc_cob;	

	 foreach
	  select x.porc_descuento 
	    Into v_porc_descto 
	    from endunide x
	   where x.no_poliza  = v_poliza
	     and x.no_endoso  = v_endoso
	     and x.no_unidad  = v_unidad

	    if v_porc_descto is null then
	       let v_porc_descto = 0.00;
	    end if

	    let v_tot_descto   = v_tot_descto + ((v_porc_descto * v_prima_descto)/100);
	    let v_prima_descto = v_prima_descto - ((v_porc_descto * v_prima_descto)/100); --v_tot_descto;

	 end foreach

	--  Calcular el Recargo de la Cobertura

	  let v_tot_recargo = 0.00;

	  select sum(x.porc_recargo) 
	    into v_porc_descto
	    from endunire x
	   where x.no_poliza  = v_poliza
	     and x.no_endoso  = v_endoso
	     and x.no_unidad  = v_unidad;

	    if v_porc_descto is null then
	       let v_porc_descto = 0.00;
	    end if

		let v_tot_recargo = ((v_porc_descto * v_prima_descto)/100);

  End If

  let v_prima_neta = v_prima_cob - v_tot_descto + v_tot_recargo;

  -------------
  ---  actualizar valores de la cobertura
  ------------
  update endedcob
     set endedcob.prima       = v_prima_cob,
         endedcob.descuento   = v_tot_descto,
         endedcob.recargo     = v_tot_recargo,
         endedcob.prima_neta  = v_prima_neta
   where endedcob.no_poliza   = v_poliza
     and endedcob.no_endoso   = v_endoso
     and endedcob.no_unidad   = v_unidad
     and endedcob.cod_cobertura = v_cobertura;

end foreach

RETURN r_error, r_descripcion  WITH RESUME;

END

end procedure;
