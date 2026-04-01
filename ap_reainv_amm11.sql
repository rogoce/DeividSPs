-- Procedimiento para barrer camrea e insertar nuevos registros en emireaco/emireama producto de traspaso de cartera
-- correo enviado por Cesia 21/11/2022
-- Creado:     21/11/2022 - Autor Armando Moreno M.

drop procedure ap_reainv_amm11;
create procedure ap_reainv_amm11()
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


--RECLAMOS
foreach
	select distinct emi.no_poliza, rec.no_unidad, fac.no_tranrec, fac.periodo, emi.no_documento
	  into _no_poliza_c, _no_unidad, _no_tranrec, _periodo, _no_documento
	  from emipomae emi
        inner join recrcmae rec on rec.no_poliza = emi.no_poliza
	inner join rectrmae fac on fac.no_reclamo = rec.no_reclamo
	inner join rectrrea rea on rea.no_tranrec  = fac.no_tranrec
	inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
	where emi.cod_ramo in ('002','020','023')
	   and fac.periodo >= '2024-01'
	   and fac.periodo <= '2024-04'
	   and fac.actualizado = 1
	   and rea.porc_partic_prima <> 5
	union all
	select distinct emi.no_poliza, rec.no_unidad, fac.no_tranrec, fac.periodo, emi.no_documento
	  from emipomae emi
        inner join recrcmae rec on rec.no_poliza = emi.no_poliza
	inner join rectrmae fac on fac.no_reclamo = rec.no_reclamo
	inner join rectrrea rea on rea.no_tranrec  = fac.no_tranrec
	inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 5
	where emi.cod_ramo in ('002','020','023')
	   and fac.periodo >= '2024-01'
	   and fac.periodo <= '2024-04'
	   and fac.actualizado = 1
	   and rea.porc_partic_prima <> 95
	order by 1
			   
	select count(*)
	  into _cnt
	  from camrea2
	 where no_endoso = _no_tranrec
	   and tipo = 3;
			 
	if _cnt is null THEN
		let _cnt = 0;
	end if

	if _cnt = 0 then 		   
		insert into camrea2(
		no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha,cod_endomov,renglon)
		values(_no_poliza_c,_no_unidad,0,_no_tranrec,_periodo,_no_documento,3,today,'',0);
	end if

end foreach



return _cantidad;
end
end procedure;