-- Procedimiento para barrer camrea2 y recalcular la distribución de las primas de los endosos traspaso de cartera
-- correo enviado por Cesia 21/11/2022
-- Creado:     22/11/2022 - Autor Armando Moreno M.

drop procedure ap_reainv_amm6;
create procedure ap_reainv_amm6()
returning	integer;

define _error_desc			char(100);
define _error		        integer;
define _error_isam	        integer;
define _no_poliza_c,_no_endoso,_no_reclamo        char(10); 
define _max_no_cambio		smallint;
define _cod_contrato,_no_unidad,_cod_contrato_n  char(5);
define _cantidad,_flag,_renglon            smallint;
define _no_documento char(20);
define _suma_asegurada      dec(16,2);
define _suma      dec(16,2);
define _suma_aseg_unidad      dec(16,2);
define _prima      dec(16,2);
define ld_retenida          dec(16,2);
define _prima_suscrita          dec(16,2);
define _porc_parti_reas          dec(5,2);
define _cod_endomov         char(3);
define _cod_cober_reas         char(3);
define _tipo_mov            smallint;
define _tipo_contrato            smallint;
define _porc_partic            smallint;

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;


-- buscar tipo de ramo, periodo de pago y tipo de produccion

--SERIE	TIPO	  ACTUAL	CAMBIO
--2018	CUOTA	  00689		00734
--2018	EXCEDENTE 00688		00733
--2019	CUOTA	  00695		00736
--2019	EXCEDENTE 00696		00735
--2020	CUOTA	  00704		00737
--2020	EXCEDENTE 00705		00738
--2021	CUOTA	  00714		00739
--2021	EXCEDENTE 00713		00740

--ESTE FUE EL SEGUNDO CAMBIO HECHO EN JULIO 2023
--Serie	Tipo	    Nuevo	Anterior
{2018	Cuota Parte	00750	00734
2018	Excedente	00755	00733
2019	Cuota Parte	00751	00735
2019	Excedente	00756	00736
2020	Cuota Parte	00752	00738
2020	Excedente	00757	00737
2021	Cuota Parte	00753	00739
2021	Excedente	00758	00740
2022	Cuota Parte	00754	00726
2022	Excedente	00759	00725
}

--TERCER CAMBIO ABRIL 2024
--CodContratoAnterior	NombreContratoAnterior	CodContratoNuevo	NombreContratoNuevo
--00760	RETENCION AUTO   2023	00766	RETENCION AUTO 2024    5.00 %
--00761	CUOTA PARTE AUTO 2023	00767	CUOTA PARTE AUTO 2024  95.00 %
--00762	FACULTATIVO AUTO 2024	00768	FACULTATIVO AUTO 2024

--PRODUCCION
foreach
	select no_poliza,
	       no_unidad,
		   no_endoso,
		   cod_cober_reas,
		   prima_suscrita,
		   suma_aseg_unidad,
		   porc_partic_reas
	  into _no_poliza_c,
	       _no_unidad,
		   _no_endoso,
		   _cod_cober_reas,
		   _prima_suscrita,
		   _suma_aseg_unidad,
		   _porc_parti_reas
	  from deivid_tmp:det_reas_auto2024
	 --where prima_suscrita <> 0
	 
	select cod_endomov
      into _cod_endomov
      from endedmae
     where no_poliza = _no_poliza_c
       and no_endoso = _no_endoso;	 
	   
	select tipo_mov
      into _tipo_mov
      from endtimov  
     where cod_endomov = _cod_endomov;	  
	 
	foreach
		select rea.cod_contrato,
			   con.tipo_contrato
		  into _cod_contrato,
			   _tipo_contrato
		  from emifacon rea
		 inner join reacomae con on con.cod_contrato = rea.cod_contrato
		 where no_poliza = _no_poliza_c 
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas

		if _tipo_contrato = 1 then
			let _cod_contrato_n = '00766';
			let _porc_partic = 5;
		else
			let _cod_contrato_n = '00767';
			let _porc_partic = 95;
		end if
		
		let _prima = _prima_suscrita * _porc_parti_reas * (_porc_partic/100);
		let _suma = _suma_aseg_unidad * _porc_parti_reas * (_porc_partic/100);
		
		update emifacon
		   set porc_partic_prima = _porc_partic,
			   porc_partic_suma = _porc_partic,
			   cod_contrato = _cod_contrato_n,
			   prima = _prima,
			   suma_asegurada = _suma
		 where no_poliza = _no_poliza_c 
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato = _cod_contrato;	
	end foreach
		
	let ld_retenida = 0.00;
	
	Select SUM(emifacon.prima) 
	  Into ld_retenida
	  From emifacon, reacomae
	 Where emifacon.no_poliza     = _no_poliza_c
	   And emifacon.no_endoso     = _no_endoso
	   and emifacon.no_unidad     = _no_unidad
	   And reacomae.cod_contrato  = emifacon.cod_contrato
	   And reacomae.tipo_contrato = 1;
	
	if ld_retenida is null then
		let ld_retenida = 0.00;
	end if
	
	update endeduni 
	   set prima_retenida = ld_retenida
     where no_poliza = _no_poliza_c
	   and no_endoso = _no_endoso
       and no_unidad = _no_unidad;

	let ld_retenida = 0.00;
	   
	Select SUM(prima_retenida) 
	  Into ld_retenida
	  From endeduni
	 Where no_poliza     = _no_poliza_c
	   And no_endoso     = _no_endoso;

	if ld_retenida is null then
		let ld_retenida = 0.00;
	end if
	   
	update endedmae 
	   set prima_retenida = ld_retenida
     where no_poliza = _no_poliza_c
	   and no_endoso = _no_endoso;

	update endedhis 
	   set prima_retenida = ld_retenida
     where no_poliza = _no_poliza_c
	   and no_endoso = _no_endoso;

	IF _tipo_mov <> 2 AND _tipo_mov <> 3 then	   
		let ld_retenida = 0.00;	   
		   
		Select SUM(a.prima_retenida) 
		  Into ld_retenida
		  From endeduni a, endedmae b
		 Where a.no_poliza = b.no_poliza
		   and a.no_endoso = b.no_endoso
		   and a.no_poliza = _no_poliza_c
		   and a.no_unidad = _no_unidad
		   and b.actualizado = 1		   
	       and cod_endomov not in ('002','003');

		if ld_retenida is null then
			let ld_retenida = 0.00;
		end if

		update emipouni
		   set prima_retenida = ld_retenida
		 where no_poliza = _no_poliza_c
		   and no_unidad = _no_unidad;

		let ld_retenida = 0.00;	   

	   
		Select SUM(a.prima_retenida) 
		  Into ld_retenida
		  From emipouni a
		 Where a.no_poliza = _no_poliza_c;
		
		if ld_retenida is null then
			let ld_retenida = 0.00;
		end if

		update emipomae
		   set prima_retenida = ld_retenida
		 where no_poliza = _no_poliza_c;
	END IF   
	
    update camrea2 
	   set reasegurado = 1
     where no_poliza = _no_poliza_c
	   and no_endoso = _no_endoso
	   and no_unidad = _no_unidad;	
end foreach

return 0;
end
end procedure;