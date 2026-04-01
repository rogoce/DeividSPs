-- Procedimiento para barrer camrea e insertar nuevos registros en emireaco/emireama producto de traspaso de cartera
-- correo enviado por Cesia 21/11/2022
-- Creado:     21/11/2022 - Autor Armando Moreno M.

drop procedure ap_reainv_amm2;
create procedure ap_reainv_amm2()
returning	integer;

define _error_desc			char(100);
define _error		        integer;
define _error_isam	        integer;
define _no_poliza_c,_no_remesa,_no_tranrec,_no_reclamo    char(10); 
define _max_no_cambio		smallint;
define _cod_contrato,_no_unidad,_no_endoso  char(5);
define _cantidad,_cnt,_renglon            smallint;
define _periodo             char(7);
define _no_documento        char(20);
define _cod_endomov         char(3);


--set debug file to "sp_reainv_amm2.trc";
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
--00760	RETENCION AUTO   2023	00766	RETENCION AUTO 2024
--00761	CUOTA PARTE AUTO 2023	00767	CUOTA PARTE AUTO 2024
--00762	FACULTATIVO AUTO 2024	00768	FACULTATIVO AUTO 2024


let _cantidad = 0;

--ENDOSOS
foreach
	select  distinct no_poliza,
	       no_unidad,
		   no_documento
	  into _no_poliza_c,
	       _no_unidad,
		   _no_documento
	  from camrea
	 where no_poliza in (
	 '1912204',
'1912204',
'1925616',
'1925616',
'1928749',
'1928749',
'2048155',
'2048155',
'2258917',
'2258917',
'2258917',
'2258917',
'2465026',
'2465026',
'2543123',
'2543123',
'2543123',
'2543123',
'2574856',
'2574856',
'2586436',
'2586436',
'2586531',
'2586531')
	 order by no_poliza,no_unidad
	 
	foreach
		select cod_endomov,
		       no_endoso,
			   periodo
		  into _cod_endomov,
			   _no_endoso,
			   _periodo
		  from endedmae
		 where actualizado = 1
           and no_poliza   = _no_poliza_c
		   and periodo     >= '2024-05'
		   
		foreach
			select no_unidad
			  into _no_unidad
			  from endeduni
			 where no_poliza = _no_poliza_c
               and no_endoso = _no_endoso			 
		   
			select count(*)
			  into _cnt
			  from camrea2
			 where no_poliza = _no_poliza_c
			   and no_unidad = _no_unidad
			   and no_endoso = _no_endoso;
					 
			if _cnt is null THEN
				let _cnt = 0;
			end if
					
			if _cnt = 0 then 
				insert into camrea2(
				no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha,cod_endomov)
				values(_no_poliza_c,_no_unidad,0,_no_endoso,_periodo,_no_documento,1,today,_cod_endomov);
			end if
		end foreach
	end foreach
end foreach

--COBROS
foreach
	select no_poliza
	  into _no_poliza_c
	  from camrea
	 where fecha = '06-05-2024'
	 group by no_poliza 
	 order by no_poliza
	 
	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza_c; 
	 
	foreach
		select no_remesa,
		       renglon,
			   periodo
		  into _no_remesa,
			   _renglon,
			   _periodo
		  from cobredet
		 where actualizado = 1
           and no_poliza   = _no_poliza_c
		   and periodo     >= '2024-05'
		   
		insert into camrea2(
		no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha,cod_endomov,renglon)
		values(_no_poliza_c,'',0,_no_remesa,_periodo,_no_documento,2,today,'',_renglon);

	end foreach
end foreach

--RECLAMOS
foreach
	select no_poliza,
	       no_unidad,
		   no_documento
	  into _no_poliza_c,
	       _no_unidad,
		   _no_documento
	  from camrea
	 where fecha = '06-05-2024'
	 order by no_poliza,no_unidad
	 
	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where actualizado = 1
           and no_poliza   = _no_poliza_c
		   and no_unidad   = _no_unidad
		   
		foreach
			select no_tranrec,
				   periodo
			  into _no_tranrec,
				   _periodo
			  from rectrmae
			 where actualizado = 1
			   and no_reclamo  = _no_reclamo
			   and periodo     >= '2024-05'
			   
			insert into camrea2(
			no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha,cod_endomov,renglon)
			values(_no_poliza_c,_no_unidad,0,_no_tranrec,_periodo,_no_documento,3,today,'',0);
			
		end foreach	

	end foreach
end foreach

--REVISAR SI HAY CHEQUES

foreach
	select distinct no_poliza,
		   no_documento
	  into _no_poliza_c,
		   _no_documento
	  from camrea
	 where fecha = '06-05-2024'
	 order by no_poliza
	 
	foreach
		select distinct a.no_requis,
		       b.periodo
		  into _no_tranrec,
		       _periodo
		  from chqreaco a, chqchmae b
		 where a.no_requis = b.no_requis
           and a.no_poliza   = _no_poliza_c
		   and b.periodo >= '2024-05'
			   
			insert into camrea2(
			no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha,cod_endomov,renglon)
			values(_no_poliza_c,'',0,_no_tranrec,_periodo,_no_documento,4,today,'',0);
			

	end foreach
end foreach


return _cantidad;
end
end procedure;