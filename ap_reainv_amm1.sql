-- Procedimiento para barrer camrea e insertar nuevos registros en emireaco/emireama producto de traspaso de cartera
-- correo enviado por Cesia 21/11/2022
-- Creado:     21/11/2022 - Autor Armando Moreno M.

drop procedure ap_reainv_amm1;
create procedure ap_reainv_amm1()
returning	integer;

define _error_desc			char(100);
define _error		        integer;
define _error_isam	        integer;
define _no_poliza_c         char(10); 
define _max_no_cambio		smallint;
define _cod_contrato,_no_unidad  char(5);
define _cantidad, _tipo_contrato smallint;
define _cnt, _cnt2          smallint;

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

-- buscar tipo de ramo, periodo de pago y tipo de produccion
--ESTE FUE EL PRIMER CAMBIO HECHO EN 2022
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
--00760	RETENCION AUTO   2023	00766	RETENCION AUTO 2024
--00761	CUOTA PARTE AUTO 2023	00767	CUOTA PARTE AUTO 2024
--00762	FACULTATIVO AUTO 2024	00768	FACULTATIVO AUTO 2024
 

let _cantidad = 0;
let _max_no_cambio = 0;
let _cnt = 0;
let _cnt2 = 0;

foreach
	select no_poliza,
	       no_unidad
	  into _no_poliza_c,
	       _no_unidad
	  from camrea
	 where actualizado = 0
	 order by no_poliza,no_unidad
	 
	select max(no_cambio)
	  into _max_no_cambio
	  from emireaco
	 where no_poliza = _no_poliza_c
	   and no_unidad = _no_unidad;
	   
	if _max_no_cambio is null then
		let _max_no_cambio = 0;
    end if		
	
	let _cnt = 0;
	
	select count(*)
	  into _cnt
	  from emireaco a, reacomae b
	 where a.cod_contrato = b.cod_contrato
	   and a.no_poliza = _no_poliza_c
	   and a.no_unidad = _no_unidad
	   and b.tipo_contrato = 1
	   and a.porc_partic_prima <> 5
	   and a.no_cambio = _max_no_cambio;
	   
	if _cnt is null then
		let _cnt = 0;
    end if  

	let _cnt2 = 0;

	select count(*)
	  into _cnt2
	  from emireaco a, reacomae b
	 where a.cod_contrato = b.cod_contrato
	   and a.no_poliza = _no_poliza_c
	   and a.no_unidad = _no_unidad
	   and b.tipo_contrato = 5
	   and a.porc_partic_prima <> 95
	   and a.no_cambio = _max_no_cambio;

	if _cnt2 is null then
		let _cnt2 = 0;
    end if  	
	
	if _cnt = 0 and _cnt2 = 0 then
		continue foreach;
	end if
		
	
	select * from emireaco
	 where no_poliza = _no_poliza_c
	   and no_unidad = _no_unidad
	   and no_cambio = _max_no_cambio into temp prueba;
	   
	select * from emireama
	 where no_poliza = _no_poliza_c
	   and no_unidad = _no_unidad
	   and no_cambio = _max_no_cambio into temp prueba1;

	foreach
		select cod_contrato
		  into _cod_contrato
		  from prueba
		  
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato; 		  
		  
		if _tipo_contrato = 1 then -- Retencion
			update prueba
			   set cod_contrato = '00766',
			       porc_partic_suma = 5.00,
			       porc_partic_prima = 5.00				   
			 where cod_contrato = _cod_contrato;
		end if
		if _tipo_contrato = 5 then -- Cuota Parte
			update prueba
			   set cod_contrato = '00767',
			       porc_partic_suma = 95.00,
			       porc_partic_prima = 95.00	
			 where cod_contrato = _cod_contrato;
		end if
		if _tipo_contrato = 3 then -- Facultativo
			update prueba
			   set cod_contrato = '00768'
			 where cod_contrato = _cod_contrato;
		end if
	end foreach

	let _max_no_cambio = _max_no_cambio + 1;
	
	update prueba
	   set no_cambio = _max_no_cambio;
	   
	update prueba1
	   set no_cambio = _max_no_cambio;
	   
	update camrea
       set actualizado = 1
     where no_poliza = _no_poliza_c
	   and no_unidad = _no_unidad;	   
			   
	insert into emireama
	select * from prueba1;
	
	drop table prueba1;
			
  	insert into emireaco
	select * from prueba;
	
	drop table prueba;
	
	let _cantidad = _cantidad + 1;
	if _cantidad = 5000 then
		exit foreach;
	end if
	
end foreach

return _cantidad;
end
end procedure;