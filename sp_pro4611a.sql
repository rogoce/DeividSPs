--- Eliminacion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

drop procedure sp_pro4611a;
create procedure sp_pro4611a(v_poliza char(10), v_endoso char(5))

returning	smallint, 
			char(30), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2);

--returning smallint, char(30);

begin

define limite			varchar(50);  
define r_descripcion	char(30);     
define r_imp			char(16);     
define v_cobertura		char(5);      
define v_producto		char(5);      
define r_unidad			char(5);
define _cod_tipocalc	char(3);
define _cod_impuesto	char(3);
define _cod_endomov		char(3);
define _cod_subramo		char(3);
define _cod_origen		char(3); 
define _cod_ramo		char(3);
define _tipo_mov		char(1);
define v_prima_suscrita	dec(16,2);
define v_prima_retenida	dec(16,2);
define v_suma_asegurada	dec(16,2);
define v_prima_descto	dec(16,2);
define v_tot_recargo	dec(16,2);
define r_prima_bruta	dec(16,2);
define v_porc_descto	dec(16,2);
define v_prima_bruta	dec(16,2);
define v_prima_neta		dec(16,2);
define r_prima_neta		dec(16,2);
define v_tot_descto		dec(16,2);
define v_prima_uni		dec(16,2);
define v_prima_cob		dec(16,2);
define r_suma_aseg		dec(16,2);
define r_descuento		dec(16,2);
define r_impuesto		dec(16,2);
define v_impuesto		dec(16,2);
define v_rata_dia		dec(16,2);
define r_recargo		dec(16,2);
define r_suma			dec(16,2);
define r_prima			dec(16,2);
define v_prima			dec(16,2);
define _porct_imp		dec(9,6);
define v_factor			dec(9,6); 
define _aplica_imp		smallint;
define _existe_imp		smallint;
define v_cantidad		smallint;     
define v_acepta			smallint;     
define v_impto			smallint;     
define v_signo			smallint;     
define r_error			smallint;     
define r_cant			smallint;     
define v_dias			smallint;     
define _canti			smallint;
define v_poliza_inic    date;
define v_poliza_fin     date;
define r_prima_neta_uni dec(16,2);
define _cod_ramo_uni    char(3);
define _impuesto_acum   dec(16,2);


set isolation to dirty read;

let r_descripcion    = null;
let limite           = null;
let v_cantidad       = 0;
let r_error          = 0;
let v_dias           = 0;   
let r_suma           = 0.00;
let v_prima_suscrita = 0.00;
let v_prima_retenida = 0.00;
let v_porc_descto    = 0.00;
let v_tot_recargo    = 0.00;
let v_prima_bruta    = 0.00;
let v_tot_descto     = 0.00;
let v_prima_neta     = 0.00;
let r_prima_neta     = 0.00;
let r_descuento      = 0.00;
let v_prima_uni      = 0.00;
let v_prima_cob      = 0.00;
let r_suma_aseg      = 0.00;
let v_rata_dia       = 0.00;
let v_impuesto       = 0.00;
let r_impuesto       = 0.00;
let r_recargo        = 0.00;
let v_factor         = 0.00;
let v_prima          = 0.00;
let r_prima          = 0.00;

-------------
---  Buscar la vigencia del endoso y la prima para calcular el factor
------------
--set debug file to 'sp_pro4611a.trc';
--trace on;

select sum(x.prima),
	   sum(x.descuento),
	   sum(x.recargo),
	   sum(x.prima_neta),
	   sum(x.impuesto),
	   sum(x.prima_bruta),
	   sum(suma_asegurada),
	   sum(x.prima_suscrita),
	   sum(x.prima_retenida)
  into r_prima,
	   r_descuento, 
	   r_recargo,
	   r_prima_neta,
	   r_impuesto,
	   r_prima_bruta, 
       r_suma_aseg,
	   v_prima_suscrita,
	   v_prima_retenida
  from endeduni x
 where x.no_poliza = v_poliza
   and x.no_endoso = v_endoso;
   
select cod_ramo,
	   cod_subramo,
	   cod_origen
 into _cod_ramo,
	  _cod_subramo,
	  _cod_origen
 from emipomae
where no_poliza = v_poliza;

-------------
---  Calcular el impuesto de la unidad
------------
let v_impuesto = 0.00;

select x.tiene_impuesto
  into v_impto
  from endedmae x
 where x.no_poliza    = v_poliza
   and x.no_endoso    = v_endoso;

if v_impto = 1 then
	let r_impuesto = 0.00;

	select sum(y.factor_impuesto) 
	  into v_impuesto 
	  from emipolim x, prdimpue y
	 where x.no_poliza    = v_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = 'C';
	   
	if v_impuesto is null then

		--VALIDACION PARA POLIZAS DE FIANZAS, VIDA, COLEC VIDA*****************************************************************************

		if _cod_ramo in ('008','019','016') then

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
						 Where cod_ramo    = _cod_ramo
						   And cod_subramo = _cod_subramo

						   let _existe_imp = 0;

						select count(*)
						  into _existe_imp
						  from endedimp
						 where no_poliza = v_poliza
						   and no_endoso = v_endoso
						   and cod_impuesto = _cod_impuesto;

						if _existe_imp = 0 then
							Insert Into endedimp(
									no_poliza,
									no_endoso,
									cod_impuesto,
									monto)
							Values(	v_poliza,
									v_endoso,
									_cod_impuesto,
									0.00);
						end if
					end foreach					

					select Sum(y.factor_impuesto) 
					  Into _porct_imp
					  From endedimp x, prdimpue y
					 where x.no_poliza    = v_poliza
					   and x.no_endoso    = v_endoso
					   and x.cod_impuesto = y.cod_impuesto
					   and y.pagado_por   = 'C';

					let v_impuesto = r_prima_neta * ( _porct_imp / 100);

					update endedimp
					   set monto = v_impuesto
					 where no_poliza = v_poliza
					   and no_endoso = v_endoso;
				end if
			end if
		else
			let v_impuesto = 0;
		end if	
	else
	  if _cod_ramo = '024' then
	    let _impuesto_acum = 0;
		   foreach
				select no_unidad,prima_neta
				  into r_unidad,r_prima_neta_uni
				  from endeduni
				 where no_poliza = v_poliza
				   and no_endoso = v_endoso
				
				select cod_ramo
				  into _cod_ramo_uni
				  from emipouni
				 where no_poliza = v_poliza
				   and no_unidad = r_unidad;
			   
				if _cod_ramo_uni = '020' then
					let v_impuesto = 6;
				else
					let v_impuesto = 5;
				end if

				let _impuesto_acum = _impuesto_acum + ((r_prima_neta_uni * v_impuesto) / 100);
		end foreach
		let v_impuesto = _impuesto_acum;
	   else	
			let v_impuesto = ((r_prima_neta * v_impuesto) / 100);
	   end if	
	end if
end if

let r_impuesto = v_impuesto;
let r_prima_bruta = r_prima_neta + r_impuesto;

update endedmae
   set endedmae.prima       = r_prima,
       endedmae.descuento   = r_descuento,
	   endedmae.recargo     = r_recargo,
	   endedmae.prima_neta  = r_prima_neta,
	   endedmae.impuesto    = r_impuesto,
	   endedmae.prima_bruta = r_prima_bruta,
	   endedmae.prima_suscrita = v_prima_suscrita,
	   endedmae.prima_retenida = v_prima_retenida,
	   endedmae.suma_asegurada = r_suma_aseg
 where endedmae.no_poliza   = v_poliza
   and endedmae.no_endoso   = v_endoso;

select x.prima,
	   x.descuento,
	   x.recargo,
	   x.prima_neta,
	   x.impuesto,
	   x.prima_bruta,
	   x.suma_asegurada,
	   x.prima_suscrita,
	   x.prima_retenida
  into r_prima,
	   r_descuento,
	   r_recargo,
	   r_prima_neta,
	   r_impuesto,
	   r_prima_bruta,
	   r_suma,
	   v_prima_suscrita,
	   v_prima_retenida
  from endedmae x
 where x.no_poliza = v_poliza
   and x.no_endoso = v_endoso;

return r_error, 
	   r_descripcion, 
	   r_prima, 
	   r_descuento, 
	   r_recargo, 
	   r_prima_neta, 
	   r_impuesto,
       r_prima_bruta, 
       r_suma, 
       v_prima_suscrita, 
       v_prima_retenida;
end
end procedure;