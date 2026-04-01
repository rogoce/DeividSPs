-- Procedimiento para Re-evaluar Filtros de Campaña de Aviso 
-- Creado    : 26/09/2018  Por: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob771;
create procedure sp_cob771(a_cod_avican char (10), a_no_documento char(20))
returning integer, char(100);

define _filt_especiales		smallint;
define _ramo_sis		    smallint;
define _evaluar		        smallint;
define _cliente_vip			smallint;
define _error				smallint;
define _dia_cob				smallint;
define _error_desc			char(100);
define _estatus_poliza	    char(1);
define _cod_ramo		    char(3);  
define _cod_tipoprod		char(3);
define v_no_documento		char(20);
define _cod_contratante		char(10);
define _filtro_esp			char(10);
define v_no_poliza			char(10);
define _cod_grupo		    char(5);
define _acreencia			char(3);
define _pagos				char(3);
define _moros				char(3);
define _ramo				char(3);
define _zona				char(3);
define _suc					char(3);
define _status				char(1);
define _formapag			char(3);
define _agente				char(5);
define _grupo				char(5);
define _area				char(5);

on exception set _error
	return _error, 'Error al Evaluar la Roliza ';
end exception  

--if a_cod_avican = '02206' then
--set debug file to 'sp_cob771.trc';
---trace on;
--end if


set isolation to dirty read;

let _evaluar = 0;

select filt_acre,
	   filt_agente,
	   filt_area,
	   filt_diacob,
	   filt_formapag,
	   filt_grupo,
	   filt_moros,
	   filt_pago,
	   filt_ramo,
	   filt_status,
	   filt_sucursal,
	   filt_zonacob,
	   filt_especiales
  into _acreencia,
       _agente,
	   _area,
       _dia_cob,
       _formapag,
       _grupo,
       _moros,
       _pagos,
       _ramo,
       _status,
       _suc,
       _zona,
	   _filt_especiales
  from avicanpar 
 where cod_avican = a_cod_avican;
 
IF _acreencia = '0' and  _agente = '0' and _area = '0' and _dia_cob = '0' and _formapag = '0' and _grupo = '0' and _moros = '0' and _pagos = '0' and _ramo = '0' and _status = '0' and _suc = '0' and _zona = '0' and _filt_especiales = '0' then
   return 0, 'Se adicionan todos los filtros posibles';
END IF

LET v_no_poliza    = trim(a_no_documento);

SELECT cod_tipoprod,
	   cod_contratante,
	   cod_ramo,
	   cod_grupo
  INTO _cod_tipoprod,
	   _cod_contratante,
	   _cod_ramo,
	   _cod_grupo
  FROM emipomae
 WHERE no_poliza = v_no_poliza;
 
-- No Valido  Coaseguro Minoritario ni Reaseguro Asumido
IF _cod_tipoprod = '002' THEN
  return 1, 'No Valido  Coaseguro Minoritario ni Reaseguro Asumido';
END IF

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;


if _status = '1' then
	let _evaluar = 0;
	if _ramo_sis in (5,6,7)  then
		let _estatus_poliza = '1' ;		
		Select count(*)
		  into _evaluar
		 from avicanfil 
		where cod_avican = a_cod_avican 
		  and tipo_filtro = 8 ---1
		  and cod_filtro in ('1','3');
		  --and cod_filtro = _estatus_poliza;
	else	
	
		Select count(*)
		  into _evaluar
		  from emipoliza
		 where cod_status in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 8)
		   and no_poliza = v_no_poliza ;
	end if	   

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Status';
	end if
	
end if -- end if del Filtro por Estatus de Poliza, ENILDA 27/09/2018 ESTADO, los demas filtros PENDIENTES a evaluar.

{
if _moros = '1' then
let _evaluar = 0;	
	Select count(*)
	  into _evaluar
	  from emipoliza 
	 where cod_corriente  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '001') 
		or cod_monto_30   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '002') 
		or cod_monto_60   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '003') 
		or cod_monto_90   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '004') 
		or cod_monto_120  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '005') 
		or cod_monto_150  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '006') 
		or cod_monto_180  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '007') 				
		and no_poliza = v_no_poliza; 	

		let _cliente_vip = 0;

		call sp_sis233(_cod_contratante) returning _cliente_vip, _error_desc;

		if _cliente_vip < 0 then
			return _cliente_vip,_error_desc;
		end if
		
		if _evaluar = '0' or _evaluar is null then
			return 1, 'No Valido  Filtro de Morosidad';
		end if				

		if _filt_especiales = 1 then

			select cod_filtro
			  into _filtro_esp
			  from avicanfil
			 where cod_avican = a_cod_avican
			   and tipo_filtro = 13;

			if _filtro_esp = '1' then
				if _cliente_vip = 0 then
					return 1, 'No Valido  VIP del Filtro';
				end if
			else
				if _cliente_vip = 1 then
					return 1, 'No Valido  VIP del Filtro';
				end if 
			end if
		else
			if _cliente_vip = 1 then
				return 1, 'No Valido  VIP del Filtro';
			end if 
		end if	

end if


if _ramo = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_ramo in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 1)
	 and no_poliza = v_no_poliza ;			 	 
	
	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro del Ramo';
	end if		
			
end if -- end if del Filtro por Ramo



if _formapag = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_formapag in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 3)
	   and no_poliza = v_no_poliza ;
			   
	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Forma Pago';
	end if	
	
end if-- end if del Filtro por Forma de Pago

if _zona = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_zona in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 4)
		and no_poliza = v_no_poliza ;

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Zona';
	end if	
	
end if-- end if del Filtro por Zona de Cobros


if _agente = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_agente in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 5)
		or cod_agente = '00000'
		and no_poliza = v_no_poliza ;						
	
	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Agente';
	end if	
	
end if-- end if del Filtro por Agente


if _suc = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_sucursal in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 6)
	   and no_poliza = v_no_poliza ;
	   
	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Sucursal';
	end if		   

end if-- end if del Filtro por Sucursal


if _area = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_area in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 7)
	   and no_poliza = v_no_poliza ;

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Area';
	end if		
	
end if-- end if del Filtro por Area
 
if _grupo = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_grupo in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 9)
	   and no_poliza = v_no_poliza ;
			 
	--Pólizas del Grupo Colectivo Scotiabank 25/10/2016.
	--CASO: 29066 USER: ASTANZIO Execpcion pólizas del GRUPOS 125 Y 162 23/08/2018. ASTANZIO
	if _cod_grupo in ('1090', '124', '125', '162') then
	   return 1, 'No Valido  Filtro Grupo Especiales';
	end if

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Grupo';
	end if
	
end if-- end if del Filtro por Grupo

if _dia_cob = '1' then
let _evaluar = 0;	
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where dia_cobros1 in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican)
		or dia_cobros2 in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican)
	   and no_poliza = v_no_poliza ;

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Dia Cobros';
	end if
	
end if-- end if del Filtro por Dias de Cobros


if _acreencia = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_acreencia in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 11)
	   and no_poliza = v_no_poliza ;

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Acreencia';
	end if
	
end if     -- end if del Filtro por Acreencia


if _pagos = '1' then
let _evaluar = 0;
	Select count(*)
	  into _evaluar
	  from emipoliza
	 where cod_pagos in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 12)
	   and no_poliza = v_no_poliza ;

	if _evaluar = '0' or _evaluar is null then
		return 1, 'No Valido  Filtro de Pagos';
	end if
	
end if -- end if del Filtro por Prima Original
}

{
-- Evaluar si el cliente pago y la poliza estaba sin procesar para no ser reimpreso o enviado HGIRON 20042023
	let _evaluar = 0;
 Select count(*)
   into _evaluar
   FROM avisocanc
  WHERE no_aviso  = a_cod_avican
    AND no_poliza = v_no_poliza 
	AND impreso    = 0
	and estatus = 'Y';
	
	 if _evaluar is null then
		let _evaluar = 0;
	end if	

	if _evaluar <> '0'  then
		return 1, 'No Valido  Filtro de Pagado Antes del Aviso';
	end if
}
--trace off;
return 0,'Exito';


end procedure;